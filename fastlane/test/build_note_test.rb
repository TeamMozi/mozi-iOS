require "minitest/autorun"
require "open3"
require "shellwords"
require_relative "../lib/build_note"

class BuildNoteTest < Minitest::Test
  # Projects/DemoApp/Tests/DemoBuildInfoTests.swift 와 같은 짝이다. 한쪽을 바꾸면 다른 쪽도 바꾼다.
  FIXTURE_NOTE = %(로그인 "오류" 문구, 'Apple' 버튼 $HOME (6c004cd)).freeze
  FIXTURE_BASE64 = "66Gc6re47J24ICLsmKTrpZgiIOusuOq1rCwgJ0FwcGxlJyDrsoTtirwgJEhPTUUgKDZjMDA0Y2Qp".freeze

  def test_changelog_appends_commit_hash
    assert_equal "로그인 화면 (6c004cd)", BuildNote.changelog("로그인 화면", "6c004cd")
  end

  def test_encode_matches_swift_fixture
    assert_equal FIXTURE_BASE64, BuildNote.encode(FIXTURE_NOTE)
  end

  def test_xcargs_split_back_into_two_settings
    args = Shellwords.split(BuildNote.xcargs(FIXTURE_NOTE, "6c004cd"))

    assert_equal ["MOZI_BUILD_NOTE=#{FIXTURE_BASE64}", "MOZI_BUILD_HASH=6c004cd"], args
  end

  def test_xcargs_survive_real_shell_with_quotes_spaces_and_korean
    output, status = Open3.capture2("/bin/sh", "-c", "printf '%s\\n' #{BuildNote.xcargs(FIXTURE_NOTE, '6c004cd')}")

    assert status.success?
    note_arg, hash_arg = output.force_encoding(Encoding::UTF_8).lines.map(&:chomp)
    assert_equal FIXTURE_NOTE, note_arg.delete_prefix("MOZI_BUILD_NOTE=").unpack1("m0").force_encoding(Encoding::UTF_8)
    assert_equal "MOZI_BUILD_HASH=6c004cd", hash_arg
  end
end
