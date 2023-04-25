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
        
        $imgName = "./@Resources/scripts/PNG/WeatherImg.png"
        #$firstDL = $true        
        if (!(Test-Path $imgName)){
            write-host "[+] First img download"
            get-conditionImg -imgName $imgName -imgUrl $myData.CondIcoUrl
        }
        else{
            $localImgMd5 = (Get-FileHash $imgName -Algorithm MD5).Hash
            $urlImgContent = (New-Object System.Net.WebClient).DownloadData($myData.CondIcoUrl)
            $urlImgMd5Bytes = [System.Security.Cryptography.MD5]::Create().ComputeHash($urlImgContent)
            $urlImgMd5 = [System.BitConverter]::ToString($urlImgMd5Bytes).Replace("-","").ToUpper()
            if ($localImgMd5 -ne $urlImgMd5){
                Write-Host "[+] Update WeatherImg.png"
                get-conditionImg -imgName $imgName -imgUrl $myData.CondIcoUrl
            }
            else{
                Write-Host "[i] MD5sum of WeatherImg.png is the same"
            }
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
