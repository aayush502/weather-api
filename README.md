# README

## Overview
This is the weather forecast api application in rails. This api fetches the hourly weather forcast accepting latitude and longitude as parameter.

## Requirements
- Ruby Version: 3.2.2
- Rails Version: 7.1.3

## Development
- bundle install
- rails s

## Access Data
- Send HTTP GET request to rails server with latitude and logitude in request body or query params
- Example Url: http://localhost:3000/api/v1/weather_forecasts, http://localhost:3000/api/v1/weather_forecasts?latitude=39.7456&longitude=-97.0892