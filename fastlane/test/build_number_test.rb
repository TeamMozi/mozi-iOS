require "minitest/autorun"
require_relative "../lib/build_number"

class BuildNumberTest < Minitest::Test
  def test_first_upload_of_the_day_starts_at_one
    assert_equal "20260923.1", BuildNumber.next("20260922.4", "20260923")
  end

  def test_same_day_increments_sequence
    assert_equal "20260923.3", BuildNumber.next("20260923.2", "20260923")
  end

  def test_sequence_is_compared_as_integer_not_decimal
    assert_equal "20260923.11", BuildNumber.next("20260923.10", "20260923")
  end

  def test_no_previous_build_starts_at_one
    assert_equal "20260923.1", BuildNumber.next(nil, "20260923")
  end

  def test_legacy_integer_build_number_starts_at_one
    assert_equal "20260923.1", BuildNumber.next("1", "20260923")
  end

  def test_latest_from_the_future_is_rejected
    assert_raises(ArgumentError) { BuildNumber.next("20260924.1", "20260923") }
  end

  def test_today_uses_korean_time
    utc_evening = Time.utc(2026, 9, 22, 16, 0, 0)
    assert_equal "20260923", BuildNumber.today_kst(utc_evening)
  end
end
