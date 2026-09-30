# TestFlight 빌드 번호 YYYYMMDD.N 을 계산한다.
# 번호는 마침표로 나눠 칸마다 정수로 다룬다. 소수로 읽으면 .10 과 .1 이 같아진다.
module BuildNumber
  module_function

  def next(latest, today)
    first, sequence = latest.to_s.split(".", 2)
    if first.to_s.match?(/\A\d{8}\z/) && Integer(first, 10) > Integer(today, 10)
      raise ArgumentError, "마지막 빌드 번호 #{latest} 가 오늘 #{today} 보다 뒤 날짜입니다"
    end
    return "#{today}.1" unless first == today && sequence.to_s.match?(/\A\d+\z/)

    "#{today}.#{Integer(sequence, 10) + 1}"
  end

  def today_kst(now = Time.now)
    now.getlocal("+09:00").strftime("%Y%m%d")
  end
end
