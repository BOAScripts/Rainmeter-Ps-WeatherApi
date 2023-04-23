<#
https://www.weatherapi.com/docs/

    allData = {
        "location": {
            "name": "Court-Saint-Etienne",
            "region": "",
            "country": "Belgium",
            "lat": 50.65,
            "lon": 4.56,
            "tz_id": "Europe/Brussels",
            "localtime_epoch": 1682077935,
            "localtime": "2023-04-21 13:52"
        },
        "current": {
            "last_updated_epoch": 1682077500,
            "last_updated": "2023-04-21 13:45",
            "temp_c": 13.0,
            "temp_f": 55.4,
            "is_day": 1,
            "condition": {
                "text": "Partly cloudy",
                "icon": "//cdn.weatherapi.com/weather/64x64/day/116.png",
                "code": 1003
            },
            "wind_mph": 10.5,
            "wind_kph": 16.9,
            "wind_degree": 50,
            "wind_dir": "NE",
            "pressure_mb": 1011.0,
            "pressure_in": 29.85,
            "precip_mm": 0.0,
            "precip_in": 0.0,
            "humidity": 58,
            "cloud": 50,
            "feelslike_c": 12.3,
            "feelslike_f": 54.2,
            "vis_km": 10.0,
            "vis_miles": 6.0,
            "uv": 4.0,
            "gust_mph": 8.1,
            "gust_kph": 13.0
        }
    }
#>

# VARS #
# !!! MODIFY THESE STING VALUES TO MATCH YOUR API KEY AND LOCATION #
$apiKey = "YOUR-API-KEY-HERE"
$locGeoCoords = "YOUR-LOCATION-HERE" # can be named location(Paris) or latitude,longitude(48.8567,2.3508) -> https://www.weatherapi.com/docs/

$protocol = "https:"
$apiUrl = "$protocol//api.weatherapi.com/v1/current.json?key=$apiKey&q=$locGeoCoords&aqi=no"
$jsonData = ""

# FUNCTIONS #
function get-conditionImg($imgName,$imgUrl){
    try{
        Invoke-WebRequest -Uri $imgUrl -OutFile $imgName
        Write-Host "[i] Img downloaded"
    }
    catch{
        Write-Host "[!] Error downloading img"
        Write-Host $_.Exception
    }
}

# ZHU-LI, Do the thing #
try {
    $jsonData = Invoke-WebRequest -Uri $apiUrl    
    if ($jsonData.StatusCode -eq 200){
        Write-Host "[OK] Answer from weatherapi.com"
        $allData = $jsonData | ConvertFrom-Json
        $myData = @{
            LocName = $allData.location.name;
            Temps = " " + [string]$allData.current.temp_c + "󰔄 - " + [string]$allData.current.feelslike_c + "󰔄";
            Wind = " " + [string]$alldata.current.wind_kph + " km/h " + [string]$alldata.current.wind_dir;
            Precip = " " + [string]$alldata.current.precip_mm + " mm";
            UV = "  " + [string]$alldata.current.uv;
            CondTxt = $alldata.current.condition.text;
            CondIcoUrl = $protocol + $alldata.current.condition.icon;
            LastUpdated = "Updated on: " + [string]$allData.current.last_updated
        }
        $myData | ConvertTo-Json | Out-File "./@Resources/scripts/response.json"
        $imgName = "./@Resources/scripts/PNG/" + $myData.CondTxt + ".png"
        if (!(Test-Path $imgName)){
            write-host "[+] Downloading condition img"
            get-conditionImg -imgName $imgName -imgUrl $myData.CondIcoUrl
        }
        else {
            Write-Host "[i] Condition img already downloaded"
        }
    }
    elseif ($jsonData.StatusCode -eq 401 -or $jsonData.StatusCode -eq 403) {
        Write-Host "[!] Issue with API key - weatherapi.com"
    } 
    else{
        Write-Host "[!] Error retriving data from weatherapi.com. Status code: " + $jsonData.StatusCode
    }
}
catch {
    Write-Host "[!!] Error in powershell"
    Write-Host $_.Exception
    break
}
