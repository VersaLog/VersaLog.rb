require "versalog"
require "net/http"
require "json"
require "uri"

logger = Versalog::VersaLog.new(
    enum: "detailed",
    show_tag: true,
    tag: "Request"
)

def main(logger)
    api = "http://api.openweathermap.org/data/2.5/weather"

    params = {
        q: "location name",
        appid: "api key",
        units: "metric",
        lang: "ja"
    }

    uri = URI(api)
    uri.query = URI.encode_www_form(params)

    res = Net::HTTP.get_response(uri)

    if res.is_a?(Net::HTTPSuccess)
        data = JSON.parse(res.body)

        location_name = data["name"]
        weather_description = data["weather"][0]["description"]
        temperature = data["main"]["temp"]
        humidity = data["main"]["humidity"]
        pressure = data["main"]["pressure"]
        wind_speed = data["wind"]["speed"]

        logger.info("success")
        msg = "< #{location_name}の天気予報 >\n\n> 天気\n・#{weather_description}\n\n> 気温\n・#{temperature}°C\n\n> 湿度\n・#{humidity}%\n\n> 気圧\n・#{pressure} hPa\n\n> 風速\n・#{wind_speed} m/s"
        puts msg
    else
        logger.error("failed (status: #{res.code})")
    end
rescue => e
    logger.error("failed: #{e.class} #{e.message}")
end

if __FILE__ == $0
    main(logger)
end


