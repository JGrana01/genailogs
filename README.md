# genailogs
Get Google Gemini AI to opine on various log files

A different take on an snbforums.com user (aru) original python script that sends portions of log files
from Asuswrt-Merlin based routers and shows the results in a web page.

I used the help of AI to convert to Linux shell, tweaked the web page look and added some options

## About
genailogs will send log file(s) to Google Gemini AI and then format the results in html for viewing

The default action is to take the last 40 lines from /tmp/syslog.log and send for analysys.
There are some command line options:

genailogs (Ver 0.2.0) - send one or more log files to Google Gemini AI
            and display the results in an Addon web page and/or the terminal

Usage: genailogs [help] [install] [uninstall] [update] [results] [noweb] [verbose]

        help - show this message
        install - install genailogs and create addon dir and config file
        uninstall - remove genailogs and its directory and config file
        results - just show the response/results from Gemini AI
        noweb - don't create the web page, just show the results
        verbose - both create the web page and show the results
        watch - send logs/get results every SLDELAY seconds in a loop
                press any key to exit
        update - check for and optionally update

```

You can add any of the command line options on one line. For example:

```
$ genailogs noweb results
```
This will not update the web page and just show the analysis results. If running from a terminal (stdin) it will send the output through "more". If running from a script or redirect, no paging._

```
$ genailogs watch
```
This will run genailogs in a loop with the delay (in seconds) set by SLDELAY in the config file. It will both update the web page and display on the terminal.

```
$ genailogs noweb watch
```
This will run in a loop, displaying the analysis to the terminal but NOT update the web page.

genailogs with no command line options will update the web page and exit.

## Installation
For Asuswrt-merlin based routers running Entware, using your preferred SSH client/terminal, copy and paste the following command, then press Enter:

/usr/sbin/curl --retry 3 "https://raw.githubusercontent.com/JGrana01/genailogs/master/genailogs" -o "/jffs/scripts/genailogs" && chmod 0755 /jffs/scripts/genailogs && /jffs/scripts/genailogs install

genailogs uses a few Entware applications - fold and jq. If they are not installed, they will be during installation.
The install script will generate a config file by creating the directory /jffs/addons/genailogs and then the genailogs.conf file in that directory

Install will also find a spare slot in the Addons tab in the WebUI and insert the link to the results.

After a successful installation and before useing genailogs you will need to get a Google API key:

Get the API key from https://aistudio.google.com/app/apikey

![image](https://github.com/JGrana01/genailogs/assets/11652784/e0b13ae5-cb94-405c-842f-9acf43c63056)

Edit the /jffs/addons/genailogs/genailogs.conf file and put the api key string in the line:
```
readonly API_KEY="Put your API key here"
```
After installation, some of the variables can be changed in the /jffs/addons/genailogs/genailogs.conf file.

Leave the USERASP line alone - it is generated during install!
```
LOGFILEs - the default log file to have analyzed is /tmp/syslog. You can add as many log files as you want.
           Append them to this line with a space between them.
           For example, to add Diversions log (and still anaylze syslog) change the line to:
           LOGFILES="/tmp/syslog /opt/var/log/dnsmasq.log"
           (be sure to enclose in double quotes)
NUMLINES - this is the number of lines to get from the logfile. Default is 40. The more lines, the more analysis (and output!!!)
           the less - the less.
SLDELAY - in "watch" mode, this is the number of seconds between sending logs to get and display/write results.
```

## Using

In it's simplest form, to send the log(s) and get Gemini AI's analysis just run genailogs with no options:
```
$ genailogs
```
This will send the log(s), get the results and update the Addons tab. Something like this:

![image](https://github.com/JGrana01/genailogs/assets/11652784/526e5d14-7427-4433-a7c3-189086e77d99)

If you add the "noweb" option, it would just output the above to standard out.

The "watch" option can be used to monitor a log (or logs) every n minutes. Change the SLDELAY variable in /jffs/addons/genailogs/genailogs.conf to how long between analysis.
Alone, it will update the Addons tab; combined with noweb, it will display the results to standard out. It's useful to open a seperate ssh session/window to keep an eye on potential issues or when monitoring a known network event.

## Uninstall
If you decide to remove genailogs, simply run with the uninstall option:
```
$ genailogs uninstall
```
You will be prompted once to make sure you want to remove everything. Uninstall will delete the script, /jff/addons/genailogs directory and conf file and also remove itself from the Addons Menu tab.


