require "shellwords"

# 업로드 문구와 커밋 해시를 아카이브 빌드 설정으로 넘긴다. 데모 앱 첫 화면이 이 값을 읽는다.
# 문구는 UTF-8 → Base64 로 바꿔 넘긴다. 따옴표·공백·한글·$ 가 셸과 xcodebuild 설정값 해석을 거쳐도 그대로 남는다.
module BuildNote
  NOTE_SETTING = "MOZI_BUILD_NOTE".freeze
  HASH_SETTING = "MOZI_BUILD_HASH".freeze

  module_function

  def changelog(note, commit_hash)
    "#{note} (#{commit_hash})"
  end

  def encode(text)
    [text.encode(Encoding::UTF_8)].pack("m0")
  end

  # gym 이 셸로 돌리는 xcodebuild 명령에 그대로 붙일 문자열.
  def xcargs(changelog, commit_hash)
    ["#{NOTE_SETTING}=#{encode(changelog)}", "#{HASH_SETTING}=#{commit_hash}"].shelljoin
  end
end
