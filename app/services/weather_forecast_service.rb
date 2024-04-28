# frozen_string_literal: true

# app/services/weather_service.rb
class WeatherForecastService
  include HTTParty
  base_uri 'https://api.weather.gov'

  # fetch hourly forecast for given latitude and longitude
  def self.hourly_forecast(params)
    gridpoint = fetch_gridpoint(params)
    return gridpoint unless gridpoint['status'] == 200

    begin
      # fetch the hourly periods weather data for next seven days
      forecast_hourly_url = gridpoint['data']['properties']['forecastHourly']

      # Cache the forecast response with a 1-hour expiry time
      Rails.cache.fetch(forecast_cache_key(forecast_hourly_url), expires_in: 1.hour) do
        response = get(forecast_hourly_url)
        { data: JSON.parse(response.body), status: response.code }
      end
    rescue JSON::ParserError => e
      { error: "Error parsing JSON response: #{e.message}", status: 500 }
    rescue StandardError => e
      { error: "Error occurred while fetching girdpoint: #{e.message}", status: 500 }
    end
  end

  # fetch the national weather service api with latitude and longitude of specific place
  def self.fetch_gridpoint(params)
    latitude = params[:latitude]
    longitude = params[:longitude]

    # Cache the gridpoint response with a 1-hour expiry time
    Rails.cache.fetch(gridpoint_cache_key(latitude, longitude), expires_in: 1.hour) do
      response = get("/points/#{latitude},#{longitude}")
      { 'data' => JSON.parse(response.body), 'status' => response.code }
    end
  rescue SocketError => e
    { 'error' => "Socket error occurred: #{e.message}", 'status' => 500 }
  end

  # Method to generate cache key for hourly forecast
  def self.forecast_cache_key(url)
    "forecast:#{url}"
  end

  # Method to generate cache key for gridpoint data
  def self.gridpoint_cache_key(latitude, longitude)
    "gridpoint:#{latitude}_#{longitude}"
  end
end
