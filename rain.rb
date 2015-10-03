require 'date'


def humanize(data_tip)
  "" if data_tip.nil?
  "#{(data_tip / 100.0).round(2)} inches of rain"
end

def total(date_regex)
  match = by_match_on_date(date_regex)
  match.map{|row| row[2..row.size]}.map{|row| row.map(&:to_i) }.flatten.inject(&:+) || 0
end

def by_match_on_date(date_regex)
  @match = @rain.select{|x| x[0] =~ date_regex}
  @missing = @match.map{|row| row[2..row.size]}.map{|row| row.select{|tip| tip == "-" }.size }.inject(&:+) 
  puts "Missing or incomplete data for #{@missing} hours" if @missing && @missing > 0
  @match
end

def request_rain_data(station = "open_meadows")
  response = `curl 'http://or.water.usgs.gov/precip/#{station}.rain' -H 'If-None-Match: "3e8201ee-af897-52138d7811740"' -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: en-US,en;q=0.8' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.99 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Referer: http://or.water.usgs.gov/precip/' -H 'Cookie: _gat_GSA_ENOR0=1; _gat_GSA_ENOR1=1; _ga=GA1.4.1921911598.1443906133; fsr.s={"v":1,"rid":"de358f9-93208624-87c8-11db-b8ee1","to":2.5,"c":"http://or.water.usgs.gov/precip/","pv":4,"lc":{"d0":{"v":4,"s":true}},"cd":0,"f":1443906433906,"sd":0}' -H 'Connection: keep-alive' -H 'If-Modified-Since: Sat, 03 Oct 2015 20:08:21 GMT' -H 'Cache-Control: max-age=0' --compressed`
  @rain = response.split("\n").map{|x| x.split(" ")}
end

def total_rain_by_month(year, month)
  total(month_regex(year, month))
end

def total_rain_by_month_report(year, month)
  date = Date.new(year, month)
  puts date.strftime("%b-%Y") + " Total: " + humanize(total_rain_by_month(year, month))
end


def total_rain_by_day(year, month, day)
  total(day_regex(year, month, day))
end

def total_rain_by_day_report(year, month, day)
  date = Date.new(year, month, day)
  puts date.strftime("%d-%b-%Y") + " Total: " + humanize(total_rain_by_day(year, month, day))
end


def month_regex(year, month)
  date = Date.new(year, month)
  month_str = date.strftime("%b").upcase
  /#{month_str}-#{year}/
end

def day_regex(year, month, day)
  date = Date.new(year, month, day)
  month_str = date.strftime("%b").upcase
  day_str = date.strftime("%d")
  /#{day_str}-#{month_str}-#{year}/
end

def big_report
  d = Date.today
  @match = [true]
  while @match.any? do
    total_rain_by_month_report(d.year, d.month)
    d = d << 1
  end
end

def rain_today_report
  d = Date.today
  total_rain_by_day_report(d.year, d.month, d.day)
end

def rain_last_n_months_report(n)
  d = Date.today
  n.times do |i|
     total_rain_by_month_report(d.year, d.month)
     d = d << 1
   end
end

def rain_last_n_days_report(n)
  n-=1
  now = Date.today

  (0..n).each do |i|
          d = now - (n - i)
          total_rain_by_day_report(d.year, d.month, d.day)
        end
end

def rain_this_week_report
  rain_last_n_days_report(7)
end

def rain_this_month_report
  d = Date.today
  total_rain_by_month_report(d.year, d.month)
end

def rain_last_month_report
  d = Date.today
  d << 1
  total_rain_by_month_report(d.year, d.month)
end

request_rain_data
rain_this_week_report
