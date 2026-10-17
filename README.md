# InstallNwRtlSdr.com
## Introduction 
This repository is a weather website leveraging [Saratoga weather station scriptsi](https://saratoga-weather.org/scripts.php). 
I have configured it to retrieve weather data from my home weather station, a [Davis Instruments Vantage Pro2.](https://www.davisinstruments.com/collections/vantage-pro2).
The weather scripts are written in php by Ken True and have been serving my weather web site for many years.  

The repository builds an apache/php image that pulls in php sripts and weather images.  
http://localhost:80/index.php renders the website leveraging weather found on an ftp server.  
The ftp server is managed outside of this repository. It is NFS mounted on this host to /mnt/weewxrtlsdr_share.  The docker-compose.yml shows the mounting.

A separate software application called [Weewx](https://weewx.com/) polls the weather station and ftps weather data and station specific graphes to the ftp server. 
Weewx is replacing [Cumulus](https://cumuluswiki.org/a/Software) weather software.  I had been using it since 2017.  It still works, but I have to dedicate a whole windows 10 VM to use it.

The Dockerfile pulls official Saratoga repository files, unzips them, copies them into the Apache/php image. 
The scripts are generic.  I have a shell script customizesettings.sh that tailors the Settings.php file and other files to match the specifics of my weather station. 
I follow this approach because when a new Saratoga release comes out, I can do a `docker compose build --no-cache --pull` and avoid applying all the Settings. Please look at the customerizesettings.sh script.  It is really complicated, too complicated.  I set this up, because I used to manually update all these settings after each update. 
As an example, the path to the weather data inside the container is /var/www/html/mount and the Settings.php files are edited to point to that path. 

The Weewx application runs in a separate container, in a separate VM, that has a physical connecto to a TV-Tuner USB dongle called [RTL-SDR.COM](https://www.rtl-sdr.com/). The Weewx software runs an extension that programs the tuner to demodulatte the 915MHz signal from my Vantage Pro2 and convert it into a stream of realtime weather data.  The old repository was named InstallNw.com this one is called InstallNwRtlSdr.com because of the RTL-SDR.COM dongle. 


# Setup
```
$ git clone https://github.com/jkozik/InstallNwRtlSdr.com.git
$ cd InstallNwRtlSdr.com
```
The `docker-compose.yml` is really simple.  I used to do docker run but I would always get the parameters wrong and I found this easier. 
```bash
jkozik@u2004:~/projects/InstallNwRtlSdr.com$ cat docker-compose.yml
services:
  nwrtlsdr.com:
    build:
      context: ./
      dockerfile: Dockerfile
    image: jkozik/nwrtlsdr.com
    ports:
      - "8086:80"
    container_name: nwrtlsdr.com-app
    volumes:
      - /mnt/weewxrtlsdr_share:/var/www/html/mount
jkozik@u2004:~/projects/InstallNwRtlSdr.com$
```
Build the image
```bash
$ docker compose build --pull        # add --no-cache to force a full rebuild
```
The build output is long. Look for errors.  Since the Saratoga repositories change from release to release, something might break.  Most recently, there were php deprecation errors.  The scripts have been upgraded to the latest version of php and some of the older scripts needed tweaks. 

The host must already have the WeeWX output share mounted here.  For my home LAB, the ftp server is on another host and NFS mounted onto this host.  Verify that the contents looks something like this. Look for clientraw.txt, WEEWXtags.php, NOAA/, graphs
```bash
jkozik@u2004:~/projects/InstallNwRtlSdr.com$ ls /mnt/weewxrtlsdr_share
celestial.html      dayhumin.png      daywinddir.png      monthET.png         monthuv.png       seasons.js         weekhum.png        weekwind.png       yearrain.png
clientrawdaily.txt  dayhum.png        daywind.png         monthhumidity.png   monthUV.png       statistics.html    weekradiation.png  weekwindvec.png    yeartempchill.png
clientrawextra.txt  dayradiation.png  daywindrose.png     monthhumin.png      monthwinddir.png  tabular.html       weekrain.png       WEEWXtags.php      yeartempdew.png
clientrawhour.txt   dayrain.png       daywindvec.png      monthhum.png        monthwind.png     telemetry.html     weektempchill.png  yearbarometer.png  yeartempin.png
clientraw.txt       daytempchill.png  favicon.ico         monthradiation.png  monthwindvec.png  webcam             weektempdew.png    yearET.png         yearuv.png
cumulus             daytempdew.png    font                monthrain.png       NOAA              weekbarometer.png  weektempin.png     yearhumidity.png   yearUV.png
daybarometer.png    daytempin.png     gauge-data.txt      monthtempchill.png  rss.xml           weekET.png         weekuv.png         yearhumin.png      yearwinddir.png
dayET.png           dayuv.png         index.html          monthtempdew.png    saratoga          weekhumidity.png   weekUV.png         yearhum.png        yearwind.png
dayhumidity.png     dayUV.png         monthbarometer.png  monthtempin.png     seasons.css       weekhumin.png      weekwinddir.png    yearradiation.png  yearwindvec.png
jkozik@u2004:~/projects/InstallNwRtlSdr.com$
```
The key file clientraw.txt changes frequently, with realtime weather data. Less frequently, image files get regenerate every 10 or 15 minutes.
```bash
jkozik@u2004:~/projects/InstallNwRtlSdr.com$ cat /mnt/weewxrtlsdr_share/clientraw.txt
12345 2.2 1.7 346 12.6 60 1020.2 0.0 33.5 180.1 0.0 0.0 21.6 62 100.0 0 0.0 0 0.0 0.0 -100.0 -100.0 -100.0 -100.0 -100.0 -100.0 -100 -100 -100 13 05 11 weewxrtlsdr.kozik.net-13:05:11 0 31 16 10 0 0 100 100 100 100 100 12.6 0.0 13.7 -4.2 0 --- 0.2 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 8.7 0.0 0.0 16/10/2026 13.5 9.6 13.7 -4.2 1.2 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 11.5 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 11.1 8.1 0.0 8.7 0 --- --- 268.5 0.0 0.0 -100.0 -100.0 -100 -100 -100 -100 -100 188.1 22.5 21.6 0.0 1020.3 1011.4 8.7 12:45 09:45 9.6 7.2 2.1 -51.4 7.0 2026 0.0 +1 +1 0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 255.0 2.3 0.0 41.7900009 88.1200027 0.0 61 0 0.0 08:19 1.7 0.0 0.0 0.0 0.0 0.0 25.4 00:33 08:19 297 !!WS0.3.8!!
jkozik@u2004:~/projects/InstallNwRtlSdr.com$
```
Run the image.
```bash
jkozik@u2004:~/projects/InstallNwRtlSdr.com$ docker compose up -d
[+] Running 1/2
 ⠇ Network installnwrtlsdrcom_default  Created                                                                                                                                   0.8s
 ✔ Container nwrtlsdr.com-app          Started                                                                                                                                   0.7s
jkozik@u2004:~/projects/InstallNwRtlSdr.com$ 
```
The image runs apache on port 8086.  But first, check the logs:
```bash
jkozik@u2004:~/projects/InstallNwRtlSdr.com$ docker compose logs
nwrtlsdr.com-app  | AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 172.25.0.2. Set the 'ServerName' directive globally to suppress this message
nwrtlsdr.com-app  | AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 172.25.0.2. Set the 'ServerName' directive globally to suppress this message
nwrtlsdr.com-app  | [Fri Oct 16 18:25:18.551662 2026] [mpm_prefork:notice] [pid 1:tid 1] AH00163: Apache/2.4.68 (Debian) PHP/8.2.34 configured -- resuming normal operations
nwrtlsdr.com-app  | [Fri Oct 16 18:25:18.551754 2026] [core:notice] [pid 1:tid 1] AH00094: Command line: 'apache2 -D FOREGROUND'
jkozik@u2004:~/projects/InstallNwRtlSdr.com$
```
Then check that basic web functionality is working.
```bash
jkozik@u2004:~/projects/InstallNwRtlSdr.com$ URL=http://192.168.100.128:8086/wxstatus.php
G=$'\e[32m✔\e[0m'; R=$'\e[31m✘\e[0m'
page=$(curl -sf --max-time 30 "$URL") || { echo "$R $URL not reachable"; exit 1; }
echo "$G $URL reachable"
✔ http://192.168.100.128:8086/wxstatus.php reachable
jkozik@u2004:~/projects/InstallNwRtlSdr.com$
```
Also, if this works, then browsing to http://192.168.100.128:8086.  You should see the weather web page.  

Next verify, that the website sees data from Weewx on the ftp server:
```bash
jkozik@u2004:~/projects/InstallNwRtlSdr.com$ (
URL=http://192.168.100.128:8086/wxstatus.php
G=$'\e[32m✔\e[0m'; R=$'\e[31m✘\e[0m'
page=$(curl -sf --max-time 30 "$URL") || { echo "$R $URL not reachable"; exit 1; }
echo "$G $URL reachable"
ok=$(grep -c '<b>Current</b>' <<<"$page")
bad=$(grep -c '<b>NOT Current</b>' <<<"$page")
echo "$page" | grep -oP '(?<=<td>)WeeWX [^<]+|(?<=<b>)(NOT )?Current(?=</b>)' | paste - -
if [ "$ok" -eq 4 ] && [ "$bad" -eq 0 ]; then echo "$G PASS: 4/4 current"; else echo "$R FAIL: $ok current, $bad NOT current"; exit 1; fi
)
✔ http://192.168.100.128:8086/wxstatus.php reachable
WeeWX realtime  Current
WeeWX FTP       Current
WeeWX weather data      Current
WeeWX NOAA report       Current
✔ PASS: 4/4 current
```
This is a status page that indicates where the Saratoga template php script see current weather data on the ftp server.  Current is good. Sometimes the Weewx tool skips a report -- Not Current.  It should be rare.  If it is stuck like that something needs to be fixed.  If no data is seen, the a possible troubleshooting step would be to exec into the container:
```bash
jkozik@u2004:~/projects/InstallNwRtlSdr.com$ docker compose exec nwrtlsdr.com bash
root@3fd3d2a157d7:/var/www/html# cd mount
root@3fd3d2a157d7:/var/www/html/mount# ls
NOAA                dayUV.png         daytempin.png    index.html          monthtempchill.png  seasons.css        weekhum.png        weekwind.png       yearradiation.png
WEEWXtags.php       daybarometer.png  dayuv.png        monthET.png         monthtempdew.png    seasons.js         weekhumidity.png   weekwinddir.png    yearrain.png
celestial.html      dayhum.png        daywind.png      monthUV.png         monthtempin.png     statistics.html    weekhumin.png      weekwindvec.png    yeartempchill.png
clientraw.txt       dayhumidity.png   daywinddir.png   monthbarometer.png  monthuv.png         tabular.html       weekradiation.png  yearET.png         yeartempdew.png
clientrawdaily.txt  dayhumin.png      daywindrose.png  monthhum.png        monthwind.png       telemetry.html     weekrain.png       yearUV.png         yeartempin.png
clientrawextra.txt  dayradiation.png  daywindvec.png   monthhumidity.png   monthwinddir.png    webcam             weektempchill.png  yearbarometer.png  yearuv.png
clientrawhour.txt   dayrain.png       favicon.ico      monthhumin.png      monthwindvec.png    weekET.png         weektempdew.png    yearhum.png        yearwind.png
cumulus             daytempchill.png  font             monthradiation.png  rss.xml             weekUV.png         weektempin.png     yearhumidity.png   yearwinddir.png
dayET.png           daytempdew.png    gauge-data.txt   monthrain.png       saratoga            weekbarometer.png  weekuv.png         yearhumin.png      yearwindvec.png
root@3fd3d2a157d7:/var/www/html/mount#
```
Also, to help with troubleshooting, you can find all the settings and script files as follows:
```bash
root@3fd3d2a157d7:/var/www/html/mount# cd ..
root@3fd3d2a157d7:/var/www/html# ls *.php
DualImage.php                   ajax-dashboard.php     get-UV-forecast-inc.php       nws-alerts-log.php          thermometer.php     wxnewpage.php             wxssgauges.php
GR3-radar-inc.php               ajax-gizmo.php         get-metar-conditions-inc.php  nws-alerts-summary-inc.php  top.php             wxnoaaclimatereports.php  wxstatus.php
NWS-regional-radar-animate.php  check-fetch-times.php  header.php                    nws-alerts.php              wxStartNoaaFct.php  wxnws-alerts-log.php      wxtrends.php
Settings-weather.php            clientraw.php          include-NOAA-reports.php      nws-all-zones-inc.php       wxabout.php         wxnws-details.php         wxuvforecast.php
Settings.php                    common.php             include-metar-display.php     plaintext-parser.php        wxadvisory.php      wxnwsradar-iframe.php     wxweatherlink.php
USA-regional-maps-inc.php       davconvp2CW-inc.php    include-style-switcher.php    post_clientraw.php          wxastronomy.php     wxnwsradar-inc.php        wxwebcam.php
WEEWX-defs.php                  davconvp2CW.php        include-wxstatus.php          quake-json.php              wxforecast.php      wxnwsradar.php
WEEWX-trends-inc.php            davconvueCW-inc.php    index.php                     quakes.php                  wxgr3radar.php      wxquake.php
WEEWXtags.php                   flyout-menu.php        menubar.php                   radar-status.php            wxgraphs.php        wxradar.php
WU-satellite-animate.php        footer.php             nws-alerts-config.php         sunposa-lang.php            wxlinks.php         wxsimforecast.php
advforecast2.php                get-USNO-sunmoon.php   nws-alerts-details-inc.php    sunposa.php                 wxmetar.php         wxsitemap.php
root@3fd3d2a157d7:/var/www/html#
```
And one of the most important files, clientraw.txt, must be visible and frequently changing:
```bash
root@3fd3d2a157d7:/var/www/html# cat clientraw.txt
12345 0.0 0.0 54 13.3 81 1015.0 0.0 0.0 189.7 0.0 0.0 24.9 36 100.0 0 0.0 0 0.0 0.0 -100.0 -100.0 -100.0 -100.0 -100.0 -100.0 -100 -100 -100 09 32 47 Saratoga,_CA,_USA-9:32:47_AM 0 53 14 5 0 0 100 100 100 100 100 13.3 14.6 13.7 12.1 0 --- -0.1 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 6.1 10.1 1679.9 5/14/2021 15.4 12.9 13.7 12.1 1.7 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 12.3 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 13.3 11.5 12.8 6.1 0 --- --- 11.1 0.0 0.0 -100.0 -100.0 -100 -100 -100 -100 -100 326.0 26.3 24.9 13.3 1015.3 1014.0 6.1 9:20_AM 7:53_AM 14.0 10.0 10.9 8.9 0.0 2021 0.0 +1 -1 +1 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 255.0 0.6 11.5 37.27471 122.02295 0.0 85 81 0.0 7:30_AM 0.0 0.0 0.0 0.0 0.0 0.0 0.0 12:00_AM 7:30_AM 50 !!WS0.3.0!!root@3fd3d2a157d7:/var/www/html#
```
## Publish to image repository
I will eventually run this on a Kubernetes cluster.  Thus the last step in my workflow is to publish to docker hub:
```bash
jkozik@u2004:~/projects/InstallNwRtlSdr.com$ docker login
Authenticating with existing credentials...
WARNING! Your password will be stored unencrypted in /home/jkozik/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
jkozik@u2004:~/projects/InstallNwRtlSdr.com$ docker tag jkozik/nwrtlsdr.com jkozik/nwrtlsdr.com:v1
jkozik@u2004:~/projects/InstallNwRtlSdr.com$ docker push jkozik/nw.com:v1
The push refers to repository [docker.io/jkozik/nw.com]
tag does not exist: jkozik/nw.com:v1
jkozik@u2004:~/projects/InstallNwRtlSdr.com$ docker push jkozik/nwrtlsdr.com:v1
The push refers to repository [docker.io/jkozik/nwrtlsdr.com]
3e7682899c59: Preparing
4f55485e00db: Preparing
59cd070b2d8f: Preparing
06a94fc0e619: Pushed
ecba0edb3442: Pushed
13516129be46: Pushed
7090c6c3fb09: Pushed
dd68c4e3b769: Pushed
7b8f155a7211: Pushed
073d1851870c: Pushed
0c635cf27a2b: Pushed
a3e52c3c5c63: Pushed
c911a4ccde72: Pushed
4322cb1c7b74: Pushed
9eea7d0ed7bd: Pushed
1e1f2e52e7af: Pushed
5f70bf18a086: Mounted from jkozik/chw.com
4083c80280fd: Pushed
2d1b06316c86: Mounted from library/php
6402c9815a80: Mounted from library/php
7ca0f80213f9: Mounted from library/php
689ddc5cf6a8: Mounted from library/php
db9963efbce6: Mounted from library/php
abb08a604857: Mounted from library/php
b4956574881b: Mounted from library/php
9a9d6ce8f5f3: Mounted from library/php
7d7efb85c25e: Mounted from library/php
e62060154640: Mounted from library/php
b43502e2f94d: Mounted from library/php
8274fdcba677: Mounted from library/php
c7901d44d433: Mounted from library/php
a6dc765193a5: Mounted from library/php
v1: digest: sha256:207612ca4cf08c2f455f6a5246009e1fdbe022779eee5d451e636d2dace27c93 size: 7222
jkozik@u2004:~/projects/InstallNwRtlSdr.com$
```



## OLD Setup 


NapervilleWeather.com is made from the scripts at Saratoga Weather. With this repository, I hope to automate putting these scripts into a docker container, making it easier for me to keep up to date and move as my server environment evolves.
First, setup a data storage container that wraps the realtime weather data files (eg realtime.txt) into something that can be shared across multiple containers.  So run below, but only once.  If you are running multiple websites from the same weather data, this container is shared.  So optionally run below:
```
$ # OLD docker run -dit --name wjr-data -v /mount/wjr:/var/www/html/mount php:7.2-apache
$ docker run -dit --name wjr-data -v /home/wjr/public_html:/var/www/html/mount php:7.2-apache
$ docker exec -it wjr-data /bin/bash     # verify that you can find realtime.txt in the directory sited above
```

Next, clone the repository, build and run it
```
$ git clone https://github.com/jkozik/InstallNw.com
# Optionally edit customerSettings.sh 
$ docker build -t jkozik/nw.com .
$ docker run -dit --name nw.com-app -p 8082:80 --volumes-from wjr-data jkozik/nw.com

# shell prompt, logs, and restart needed for rebuild
$ docker exec -it nw.com-app /bin/bash
$ docker logs -f nw.com-app
$ docker stop nw.com-app; docker rm nw.com-app

```

The wjr-data contain mounts a host directory. The data comes from the Cumulus program that runs in a separte Windows 10 instance.  The following data is expected there:
```
-realtime.txt -- key realtime file updated every minute
-davconfcst.php,davcon24.txt -- data to recreate the Davis Console.  Scripts from Silver Acron Weather
-Reports/ -- Cumulus reports by month
-images/ -- Cumulus station graphes
-awekas_wl.htm -- retrieved by https://www.awekas.at/
```
The Cumulus program has an Internet Files menu tab that generates these files from templates.  Setup for generating these files is outside of the scope for this repository.
The precise paths to the data above are not fixed.  EG, the key file realtime.txt is found at mount/cumulus/realtime.txt.  This path needs to get reflected in Settings.php and Settings-weather.php; I use the customizeSettings.sh script to set this. You'll need to edit customizeSettings.sh for your setup.

I decided to run the nw.com application straight on the server, no VMs.  Here's the two key commands I ran as user jkozik on the server:
```
$ docker run -dit --name wjr-data -v /home/wjr/public_html:/var/www/html/mount php:7.2-apache
$ docker run -dit --name nw.com-app -p 8082:80 --volumes-from wjr-data jkozik/nw.com
```
At this point, it is good to verify that the web server can correctly see the realtime weather data. Run the following test:
```
$ curl http://napervilleweather.com/mount/cumulus/realtime.txt
```
# Updates
The weather scripts update frequently.  I read the updates and every few months I apply the updates. Here's the steps I follow.
```
$ docker build --no-cache -t jkozik/nw.comtmp .
$ docker stop nw.com-app
$ docker run -dit --name nw.com-apptmp -p 8082:80 --volumes-from wjr-data jkozik/nw.comtmp
$ docker rm nw.com-app
$ docker rename nw.com-apptmp nw.com-app
```
Note: I rebuild everything with the no-cache option, but I build it to a temp name, so that I can fall back to the old version if the updates don't work. Once the new version works, I delete the old continer and rename the temp version.
# Restart after power outage
Rarely, I have to restart the server.  Most recently, this was because of a power outage.  On my todo list is to re-run the containers with the --restart unless-stopped and make sure the dependency with the shared data volume is addressed.  But for now, I run the following commands to manually restart the weather servers on the dell2 server. The following commands are run from the jkozik login:
``` 
$ docker start wjr-data
$ docker start weather-data
$ docker start nw.com-app
$ docker start chw.com-app
$ docker start chw.net-app
```
Verify that everything is working by running docker ps.
```
$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                  NAMES
207c0f39ef59        jkozik/chw.com      "docker-php-entryp..."   3 weeks ago         Up 16 hours         0.0.0.0:8083->80/tcp   chw.com-app
b10d2f81c3d7        jkozik/nw.com       "docker-php-entryp..."   3 weeks ago         Up 16 hours         0.0.0.0:8082->80/tcp   nw.com-app
fcae2d91f8ac        jkozik/chw.net      "docker-php-entryp..."   7 months ago        Up 16 hours         0.0.0.0:8081->80/tcp   chw.net-app
d6b0265159e4        jkozik/nw.net       "docker-php-entryp..."   7 months ago        Up 16 hours         0.0.0.0:8080->80/tcp   nw.net-app
c4527394f999        php:7.2-apache      "docker-php-entryp..."   7 months ago        Up 16 hours         80/tcp                 weather-data
37de44712020        php:7.2-apache      "docker-php-entryp..."   8 months ago        Up 16 hours         80/tcp                 wjr-data
$
```
Updated to work with ssh access.



