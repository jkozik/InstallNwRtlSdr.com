echo "Customize Settings.php"
sed -i  -e  '/SITE\[\x27organ/s/= \x27.*;/= \x27NapervilleWeather.com\x27;/' \
        -e  '/SITE\[\x27copyr/s/Your Weather Website/NapervilleWeather.com/' \
        -e  '/SITE\[\x27location/s/Somewhere, SomeState, USA/Naperville, Illinois, USA/' \
        -e  '/SITE\[\x27email/s/mailto:somebody@somemail.org/jackkozik at email.com/' \
        -e  '/SITE\[\x27latitude/s/= \x27.*;/= \x2741.790072\x27;/' \
        -e  '/SITE\[\x27longitude/s/= \x27.*;/= \x27-88.124239\x27;/' \
        -e  '/SITE\[\x27cityname/s/Saratoga/Naperville/' \
        -e  '/SITE\[\x27tz/s/Los_Angeles/Chicago/' \
        -e  '/SITE\[\x27WXSIM/s/true/false/' \
        -e  '/SITE\[\x27noaazone/s/= \x27.*;/= \x27ILZ013\x27;/' \
        -e  '/SITE\[\x27noaaradar/s/= \x27.*;/= \x27LOT\x27;/' \
        -e  '/SITE\[\x27WUregion/s/= \x27.*;/= \x27mw\x27;/' \
        -e  '/SITE\[\x27WUsatellite/s/= \x27.*;/= \x27nc\x27;/' \
        -e  '/SITE\[\x27GR3radar/s/= \x27.*;/= \x27lot\x27;/' \
        -e   '/SITE\[\x27fcsturlNWS/s@= \x27.*;@= \x27https://forecast\.weather\.gov/MapClick\.php?lat=41\.790072\&lon=-88\.124239\&unit=0\&lg=english\&FcstType=text\&TextType=2\x27;@' \
        Settings.php


sed -i  '/SITE\[\x27NWSforecasts/,/^);/ c\
$SITE[\x27NWSforecasts\x27]   = array( // for the advforecast2.php V3.xx version script \
// use "Zone|Location|Point-printableURL",  as entries .. first one will be the default forecast. \
"ILZ013|Naperville|http://forecast.weather.gov/MapClick.php?CityName=Naperville&state=IL&site=LOT&textField1=41.7626&textField2=-88.1543&e=0&TextType=2", \
"ILZ014|Chicago Midway|http://forecast.weather.gov/MapClick.php?CityName=Chicago&state=IL&site=LOT&textField1=41.837&textField2=-87.685&e=1&TextType=2", \
"ILZ014|Chicago OHare|http://forecast.weather.gov/MapClick.php?CityName=Amf+Ohare&state=IL&site=LOT&lat=41.9803&lon=-87.9023&TextType=2", \
"ILZ012|St. Charles|http://forecast.weather.gov/MapClick.php?CityName=Saint+Charles&state=IL&site=LOT&textField1=41.9203&textField2=-88.3008&e=0&TextType=2", \
"ILZ012|Campton Hills|http://forecast.weather.gov/MapClick.php?lat=41.9861&lon=-88.3844&unit=0&lg=english&FcstType=text&TextType=2", \
);\
' Settings.php

sed -i '/SITE\[\x27NWSalertsCodes\x27/,/^);/ c\
$SITE[\x27NWSalertsCodes\x27] = array( \
"Naperville|ILZ013|ILC043",\
"Campton Hills|ILZ012|ILC089"\
);\
' Settings.php

echo "Customize Settings-weather.php"
sed -i  -e  '/SITE\[\x27clientrawfile/s/clientraw.txt/mount\/clientraw.txt/' \
        -e  '/SITE\[\x27WXtags/s/WEEWXtags.php/mount\/WEEWXtags.php/' \
        -e  '/SITE\[\x27graphImageDir/s/\.\//.\/mount\//' \
        -e  '/SITE\[\x27NOAAdir/s/\.\/NOAA\//.\/mount\/NOAA\//' \
        -e  '/SITE\[\x27conditionsMETAR/s/= \x27.*;/= \x27KDPA\x27;/' \
        Settings-weather.php
# WEEWXtags.php $date is day/month/year ($datefmt = 'd/m/y')
grep -q 'WDdateMDY' Settings-weather.php || \
  sed -i '/SITE\[\x27WXtags/a\$SITE[\x27WDdateMDY\x27] = false; // WEEWXtags.php dates are d/m/y' Settings-weather.php

echo "Customize include-wxstatus.php: WeeWX clientraw.txt updates every 5 min archive, not realtime"
sed -i '/WXsoftware.. == .WEEWX. and isset(\$SITE\[.clientrawfile/,+1s/\$SITE\[\x27clientrawfile\x27\],60+30,/$SITE[\x27clientrawfile\x27],60*5+15,/' include-wxstatus.php

echo "Customize check-fetch-times.php: strip :port from HTTP_HOST before gethostbyaddr()"
grep -q "preg_replace('/:\\\\d+\$/'" check-fetch-times.php || \
  sed -i "/\$ourIP = gethostbyname(\$ourHost);/i\\\\t\t\$ourHost = preg_replace('/:\\\\d+\$/','',\$ourHost);" check-fetch-times.php

echo "Customize ajaxWEEWXwx.js"
sed -i '/^var clientrawFile = \x27/s/clientraw.txt/.\/mount\/clientraw.txt/' ajaxWEEWXwx.js

#echo "Customize ajaxCUwx.js"
#sed -i '/realtimeFile = \x27/s/realtime.txt/.\/mount\/cumulus\/realtime.txt/' ajaxCUwx.js

echo "Customize wxquake.php"
sed -i -e '/$setLatitude/s//#&/' \
       -e '/$setLongitude/s//#&/' \
       -e '/$setLocationName/s//#&/' \
       -e '/$setTimeZone/s//#&/' \
       wxquake.php

echo "Customize wxmetar.php"
sed -i '/MetarList = array/,/^);/ c\
$MetarList = array ( // set this list to your local METARs \
  // Metar(ICAO) | Name of station | dist-mi | dist-km | direction | \
  "KDPA|Chicago/Dupage, Illinois, USA|11|18|NW|", // lat=41.9167,long=-88.2500, elev=231, dated=24-MAY-17 \
  "KLOT|Romeoville/Chi, Illinois, USA|13|21|S|", // lat=41.6000,long=-88.1000, elev=205, dated=24-MAY-17 \
  "KORD|Chicago O\x27Hare, Illinois, USA|17|27|NE|", // lat=41.9833,long=-87.9333, elev=200, dated=24-MAY-17 \
  "KARR|Chicago/Aurora, Illinois, USA|19|30|W|", // lat=41.7667,long=-88.4833, elev=215, dated=24-MAY-17 \
  "KJOT|Joliet, Illinois, USA|19|31|S|", // lat=41.5167,long=-88.1833, elev=177, dated=24-MAY-17 \
  "KMDW|Chicago, Illinois, USA|19|31|E|", // lat=41.7833,long=-87.7500, elev=188, dated=24-MAY-17 \
  "KPWK|Palwaukee, Illinois, USA|25|41|NNE|", // lat=42.1167,long=-87.9000, elev=203, dated=24-MAY-17 \
  "KC09|Morris-Washburn, Illinois, USA|29|47|SSW|", // lat=41.4333,long=-88.4167, elev=178, dated=24-MAY-17 \
  "KDKB|De Kalb, Illinois, USA|31|50|WNW|", // lat=41.9333,long=-88.7000, elev=279, dated=24-MAY-17 \
  "KIGQ|Chicago/Lansing, Illinois, USA|35|57|ESE|", // lat=41.5333,long=-87.5333, elev=188, dated=24-MAY-17 \
  "KGYY|Gary Regional, Indiana, USA|38|62|ESE|", // lat=41.6167,long=-87.4167, elev=180, dated=22-OCT-17 \
  "KUGN|Waukegan, Illinois, USA|45|73|NNE|", // lat=42.4167,long=-87.8667, elev=222, dated=24-MAY-17 \
  "KRPJ|Rochelle/Koritz, Illinois, USA|50|80|W|", // lat=41.8833,long=-89.0833, elev=238, dated=24-MAY-17 \
// list generated Sat, 02-May-2020 11:10am PDT at https://saratoga-weather.org/wxtemplates/find-metar.php \
);\
' wxmetar.php

echo "Customize menubar.php"
sed -i '/External Links/, /^<.ul>/ c\
<p class="sideBarTitle"><?php langtrans(\x27External Links\x27); ?></p>\
<ul>\
   <li><a href="http://www.wunderground.com/" title="Weather Underground">Weather Underground</a></li>\
   <li><a href="https://www.wunderground.com/personal-weather-station/dashboard?ID=KILNAPER7" title="-KILNAPER7">-KILNAPER7</a></li>\
   <li><a href="http://www.wxforum.net/" title="WXForum">WXforum.net</a></li>\
   <li><a href="http://www.wxqa.com/sss/search1.cgi?keyword=CW7164" title="CW7164">APRS-CW7164</a></li>\
   <li><a href="https://www.awekas.at/en/instrument.php?id=3086" title="-AWEKAS">AWEKAS-3086</a></li>\
   <li><a href="https://www.pwsweather.com/obs/NAPERVILLE.html" title="PWS-NAPERVILLE">PWS-NAPER</a></li>\
   <li><a href="http://weewx.kozik.net" title="WeeWx">WeeWx</a></li>\
   <li><a href="http://napervilleweather.com/wxweatherlink.php" title="WeatherLink">WeatherLink</a></li>\
</ul>\
' menubar.php

echo "Customize flyout-menu.xml"
sed -i '/Nearby METAR Reports/a\
                <item caption="Steel Guages" link="wxssgauges.php"/>\
                <item caption="WeatherLink" link="wxweatherlink.php"/>\
     
' flyout-menu.xml


echo "Customize include-wxstatus.php"
sed -i '/realtimefile/s/15/60/' include-wxstatus.php

echo "Customize include-wxstatus.php"
sed -i '/realtimefile/s/15/60/' include-wxstatus.php

echo "Customize noaafct/noaaSettings.php"
sed -i -e '/myLatitude/s/= \x27.*\x27;/= \x2741.7900009\x27;/' \
       -e '/myLongitude/s/= \x27.*\x27;/= \x27-88.1200027\x27;/'   \
       -e '/myArea/s/= \x27.*\x27;/= \x27Naperville\x27;/'   \
       -e '/myStation/s/= \x27.*\x27;/= \x27NapervilleWeather.com\x27;/'   noaafct/noaaSettings.php

echo "Customize noaafct/noaaDigitalGenerateHtml.php"
sed -i '/<?php/a\
error_reporting(0);
' noaafct/noaaDigitalGenerateHtml.php

echo "Customize davconvp2CW.php"
sed -i '/graphurl/s/davcon24.txt/mount\/saratoga\/davcon24.txt/'  davconvp2CW.php
# WeeWX writes WD-style clientraw.txt/clientrawextra.txt, so run davcon in WD mode
grep -q "WXsoftware == 'WEEWX'" davconvp2CW.php || \
  sed -i -e "/if (isset(\$SITE\[.WXsoftware.\])) {\$WXsoftware = \$SITE\[.WXsoftware.\];}/a\\      if (\$WXsoftware == \x27WEEWX\x27) {\$WXsoftware = \x27WD\x27;}  // WeeWX writes WD-style clientraw files\n      if (!isset(\$vpforecasttext)) {\$vpforecasttext = \x27\x27;}  // not provided by WEEWXtags.php" \
         -e "s|^\$graphurl = \x27./clientrawextra.txt\x27;|\$graphurl = \x27./mount/clientrawextra.txt\x27;|" davconvp2CW.php
# clientraw.txt is always metric; have davcon convert to US units (F, mph, inHg, in)
sed -i "s/^\$uomsys     = 'M';/\$uomsys     = 'I';/" davconvp2CW.php
# Vantage Pro2 has UV and Solar sensors: show UV/Solar/ET on the console
sed -i "s/^\$vp2Plus    = 'N';/\$vp2Plus    = 'Y';/" davconvp2CW.php

echo "Customize Steel Gauges"
sed -i '/Combined/,$s/scripts/.\/ssg\/scripts/' ssg/gauges-ss-basic-inc.php
# WeeWX: gauge-data.txt from the weewx-realtime_gauge-data extension, written to the share root.
# No Cumulus-style trend images with WeeWX, so turn off the pop-up graphs.
# UV and Solar gauges stay on (defaults): the Vantage Pro2 has both sensors.
sed -i -e '/^\s*weatherProgram\s*:/s/: [0-9]*,/: 6,/' \
	-e '/realTimeUrlWeewx/s/\x27gauge-data.txt\x27/\x27.\/mount\/gauge-data.txt\x27/' \
	-e '/^\s*showPopupGraphs\s*:/s/true/false/' ssg/scripts/gauges.js
# gauge-data.txt is currently generated every 5 min report cycle, not realtime.
# Poll every 60s and allow 10 min without new data before showing the station offline.
# When WeeWX moves to realtime gauge-data, delete these two lines to get the defaults (15s / 3 min).
sed -i -e '/^\s*realtimeInterval\s*:/s/: [0-9]*,/: 60,/' \
	-e '/^\s*stationTimeout\s*:/s/: [0-9]*,/: 10,/' ssg/scripts/gauges.js


echo "rename wxindex.php to index.php"
mv wxindex.php index.php
sed -i  -e '/wxindex/s/wxindex/index/' flyout-menu.xml

echo "New Radar view in Settings.php"
sed -i -e '/NWSregion/s/sw/nc/' Settings.php

echo "PHP 8.x compatibility fixes"

# Fix: noaacommontemperature() receives e.g. '54F' (string+unit suffix) -- round() is a TypeError in PHP 8.
# The end-of-line anchor avoids a false match on the same variable in an inline else clause.
# Guard: grep skips the sed if upstream has already added a (float) cast.
grep -q '(float)\$value' noaafct/noaaSettings.php || \
    sed -i 's/\(\$color[[:space:]]*= \x27red\x27;[[:space:]]*\)$/\1\n\t\$value\t\t\t= (float)\$value;/' \
        noaafct/noaaSettings.php

# Fix: wsnoaafcttransstr() passes $trans (never initialized, so null) to str_replace() -- deprecated in PHP 8.1.
# Guard: grep skips if upstream has already added the null-coalescing operator.
grep -q '\$trans ?? ' noaafct/noaaSettings.php || \
    sed -i 's/str_replace (\$trans,\x27\x27,/str_replace (\$trans ?? \x27\x27,\x27\x27,/' \
        noaafct/noaaSettings.php

# Fix: liquidNU stores '-' as a missing-data sentinel; string * float is a TypeError in PHP 8.
# Guard: grep skips if upstream has already added a (float) cast.
grep -q '(float)\$arr\[' noaafct/noaaDigitalGenerateHtml.php || \
    sed -i "s/(1\.0 \* \$arr\['liquidNU'\]) > 0/((float)\$arr['liquidNU']) > 0/" \
        noaafct/noaaDigitalGenerateHtml.php

  # Fix: tempAppNU stores '-' as a missing-data sentinel; string * float is a TypeError in PHP 8.
  grep -q '(float)\$arr\[.tempAppNU' noaafct/noaaDigitalGenerateHtml.php || \
      sed -i "s/1\.0\*\$arr\['tempAppNU'\]/(float)\$arr['tempAppNU']/" \
          noaafct/noaaDigitalGenerateHtml.php

  # Fix: defailtIcon can be a non-numeric string; string * float is a TypeError in PHP 8.
  grep -q '(float)\$arrFcst\[.defailtIcon' noaafct/noaaDigitalGenerateHtml.php || \
      sed -i "s/1\.0\*\$arrFcst\['defailtIcon'\]/(float)\$arrFcst['defailtIcon']/" \
          noaafct/noaaDigitalGenerateHtml.php

# Fix: windGustNU stores '-' as missing-data sentinel; 1.0*$gust is a TypeError in PHP 8.
grep -q '(float)\$gust > 0' noaafct/noaaDigitalGenerateHtml.php || \
    sed -i 's/1\.0\*\$gust > 0/(float)\$gust > 0/' \
        noaafct/noaaDigitalGenerateHtml.php

  # Fix: $graphTempMin/$graphTempMax can be '-' sentinel; floor/ceil reject non-numeric strings in PHP 8.
  grep -q 'floor((float)' noaafct/noaaDigitalGenerateHtml.php || \
      sed -i 's/floor (\$graphTempMin)/floor((float)\$graphTempMin)/' \
          noaafct/noaaDigitalGenerateHtml.php

  grep -q 'ceil((float)' noaafct/noaaDigitalGenerateHtml.php || \
      sed -i "s/ceil \t(\$graphTempMax)/ceil((float)\$graphTempMax)/" \
          noaafct/noaaDigitalGenerateHtml.php

  # Fix: fmod() returns float; PHP 8 requires (int) cast for array index.
  grep -q '(int)fmod' noaafct/noaaSettings.php || \
      sed -i 's/\$windlabel\[ fmod(/\$windlabel[ (int)fmod(/' \
          noaafct/noaaSettings.php

  grep -q '(int)fmod' noaafct/noaaLoadJson.php || \
      sed -i 's/\$windlabel\[ fmod(/\$windlabel[ (int)fmod(/' \
          noaafct/noaaLoadJson.php

  # Fix: NWS API no longer always returns 'updated' key; null passed to strtotime/date deprecated in PHP 8.1.
  grep -q '\$string !== null' noaafct/noaaLoadJson.php || {
      sed -i "s/\$array\['updated'\];/\$array['updated'] ?? null;/" noaafct/noaaLoadJson.php
      sed -i "s/\$time\t\t= strtotime(\$string);/\$time\t\t= \$string !== null ? strtotime(\$string) : false;/" noaafct/noaaLoadJson.php
      sed -i "s/= date('c', strtotime(\$string ) );/= \$string !== null ? date('c', strtotime(\$string)) : '';/" noaafct/noaaLoadJson.php
      sed -i "s/date( \$dateLongFormat, \$time).' '.date(\$timeFormat, \$time)/\$time !== false ? date(\$dateLongFormat, \$time).' '.date(\$timeFormat, \$time) : ''/" noaafct/noaaLoadJson.php
  }


echo "rename wxindex.php to index.php"
mv wxindex.php index.php
sed -i  -e '/wxindex/s/wxindex/index/' flyout-menu.xml

echo "New Radar view in Settings.php"
sed -i -e '/NWSregion/s/sw/nc/' Settings.php


#echo "Fix PHP 8.1 deprecation in CU-defs.php"
#sed -i '/windlabel\[ fmod/s/fmod(/(int)fmod(/' CU-defs.php


echo "Fix PHP 8 errors in WEEWX-defs.php (non-numeric '--' values, \${var} deprecation)"
grep -q 'is_numeric(\$rawwind)' WEEWX-defs.php || \
  sed -i "s/^\(\s*\)\$WINDkts = 0.0;/\1\$WINDkts = 0.0;\n\1if(!is_numeric(\$rawwind)) { \$rawwind = 0.0; }/" WEEWX-defs.php
grep -q 'is_numeric(\$WC)' WEEWX-defs.php || \
  sed -i "/convert F to C if need be/i\\  if(!is_numeric(\$WC)) { \$WC = \$TC; }\n  if(!is_numeric(\$HC)) { \$HC = \$TC; }" WEEWX-defs.php
sed -i "s/\\\${\(now_[a-z]*\)}/{\$\1}/g" WEEWX-defs.php
