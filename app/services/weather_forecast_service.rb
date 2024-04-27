# frozen_string_literal: true

# app/services/weather_service.rb
class WeatherForecastService
  include HTTParty
  base_uri 'https://api.weather.gov'

  def self.hourly_forecast(params)
    gridpoint = fetch_gridpoint(params)
    return gridpoint unless gridpoint['status'] == 200

    begin
      # fetch the hourly periods weather data for next seven days
      forecast_hourly_url = gridpoint['data']['properties']['forecastHourly']
      response = get(forecast_hourly_url)

      raise StandardError, "Failed to fetch gridpoint: #{response.code}" unless response.success?

      { data: JSON.parse(response.body), status: response.code }
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

    response = get("/points/#{latitude},#{longitude}")
    { 'data' => JSON.parse(response.body), 'status' => response.code }
  rescue SocketError => e
    { 'error' => "Socket error occurred: #{e.message}", 'status' => 500 }
  end
end
