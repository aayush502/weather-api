# frozen_string_literal: true

module Api
  # V1 for version 1 of API
  module V1
    # get the weather forecasts data
    class WeatherForecastsController < ApplicationController
      def index
        # call forecast service to fetch weather api
        hourly_forecast = WeatherForecastService.hourly_forecast(weather_forecast_params)

        if hourly_forecast.is_a?(Hash) && hourly_forecast.key?(:error)
          render json: hourly_forecast, status: :unprocessable_entity
        else
          render json: hourly_forecast, status: :ok
        end
      end

      private

      def weather_forecast_params
        params.permit(:latitude, :longitude)
      end
    end
  end
end
