#!/bin/bash

city="" #You can set a city if you want
NB=3

moon_emoji() {
    phase="$1"
    case "$phase" in
        "New Moon") echo "🌑" ;;
        "Waxing Crescent") echo "🌒" ;;
        "First Quarter") echo "🌓" ;;
        "Waxing Gibbous") echo "🌔" ;;
        "Full Moon") echo "🌕" ;;
        "Waning Gibbous") echo "🌖" ;;
        "Last Quarter") echo "🌗" ;;
        "Waning Crescent") echo "🌘" ;;
        *) echo "🌚" ;;  # fallback
    esac
}

json=$(curl -s "wttr.in/$city?format=j1")
weather_t=""

weather_t+="Weather for $(echo "$json" | jq -r ".nearest_area[0].areaName[0].value"), $(echo "$json" | jq -r ".nearest_area[0].country[0].value")"
weather_t+="\n═════════════════════════════════════════════"


temp=$(echo "$json" | jq -r ".current_condition[].temp_C")
weather_t+="\n\nTemperature : $temp°C"
pressure=$(echo "$json" | jq -r ".current_condition[].pressure")
weather_t+="\tPressure : $pressure hPa"
humidity=$(echo "$json" | jq -r ".current_condition[].humidity")
weather_t+="\nHumidity : $humidity%"
windspeed=$(echo "$json" | jq -r ".current_condition[].windspeedKmph")
windpoint=$(echo "$json" | jq -r ".current_condition[].winddir16Point")
weather_t+="\t\tWind : $windspeed Km/h ($windpoint)"

moon=$(echo "$json" | jq -r ".weather[0].astronomy[0].moon_phase")
weather_t+="\n\nMoon phase : $(moon_emoji "$moon") $moon"
sunrise=$(echo "$json" | jq -r ".weather[0].astronomy[0].sunrise")
weather_t+="\nSunrise : $(date -d "$sunrise" +%H:%M)"
sunset=$(echo "$json" | jq -r ".weather[0].astronomy[0].sunset")
weather_t+="\nSunset : $(date -d "$sunset" +%H:%M)"

for i in $(seq 0 $((NB - 1))); do
    d=$(echo "$json" | jq -r ".weather[$i].date")
    weather_t+="\n\n$(date -d "$d" +%A) $d:"
    weather_t+="\n   Condition : $(echo "$json" | jq -r ".weather[$i].hourly[4].weatherDesc[0].value")"
    weather_t+="\n   Temperature : $(echo "$json" | jq -r ".weather[$i].avgtempC") °C"
    weather_t+="\n   Wind : $(echo "$json" | jq -r ".weather[$i].hourly[4].windspeedKmph") km/h ($(echo "$json" | jq -r ".weather[$i].hourly[4].winddir16Point"))"
    weather_t+="\n   Humidity : $(echo "$json" | jq -r ".weather[$i].hourly[4].humidity") %"
    weather_t+="\n   Pressure : $(echo "$json" | jq -r ".weather[$i].hourly[4].pressure") HPa"
    weather_t+="\n   Precipitation : $(echo "$json" | jq -r ".weather[$i].hourly[4].precipMM") mm"
    weather_t+="\n--------------------------------"
done

weather_m=$(curl -s "wttr.in/$city?format=1" | cut -d' ' -f 1)

echo "{\"text\": \"$weather_m\", \"tooltip\": \"$weather_t\"}"