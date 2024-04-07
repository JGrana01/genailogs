# genailogs
Get Google Gemini AI to opine on various log files

A different take on an snbforums.com user (aru) original python script that sends portions of log files
from Asuswrt-Merlin based routers and shows the results in a web page.

I used the help of AI to convert to Linux shell, tweaked the web page look and added some options

## About
genailogs will send log file(s) to Google Gemini AI and then format the results in html for viewing

The default action is to take the last 40 lines from /tmp/syslog.log and send for analysys.
There are some command line options:

```
Usage: genailogs [help] [install] [uninstall] [update] [results] [noweb] [verbose] [cron add|del|run] [chat]

        help - show this message
        results - just show the response/results from Gemini AI
        noweb - don't create the web page, just show the results
        verbose - both create the web page and show the results
        watch - send logs/get results every SLDELAY seconds in a loop
                press any key to exit
        cron [add|del|run] - cron job - log the last
                 additional argument: add - add a cron entry
                                      del - delete the cron job
                                      run - run the cron job
        chat - begin an interactive chat session with GeminiAI. q exits the chat
        install - install genailogs and create addon dir and config file
        uninstall - remove genailogs and its directory and config file
        update - check for and optionally update

```

You can add any of the command line options on one line. For example:

```
$ genailogs noweb results
```
This will not update the web page and just show the analysis results. If running from a terminal (stdin) it will send the output through "more". If running from a script or redirect, no paging._

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
API_KEY="PutYourAPIKeyHere"          # Put here ;-)
LOGFILES="/tmp/syslog.log"           # log files to analyze - always check syslog
                                     # add more logs seperated by a space like this (i.e add diversion log)
                                     # LOGFILES="/tmp/syslog.log /opt/var/log/dnsmasq.log" etc.
USERASP="$USERASP"                   # /tmp/var/wwwext output file. Shouldnt need to change
NUMLINES="40"                          # last number of lines from log file to analyze
                                     # less give less info, more can take some time and be chatty
SLDELAY="300"                        # time in secods between analysis for watch mode
                                     # (default=300 - 5 mins)
NUMLOGS="5"                          # number of logs to save - for cron job
SCHEDULEHRS="*"                      # hour of day to run genailogs in cron mode (default * - once per hour)
SCHEDULEMIN="01"                     # minutes of hour to run genailogs in cron mode

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
```
$ genailogs watch
```
This will run genailogs in a loop with the delay (in seconds) set by SLDELAY in the config file. It will both update the web page and display on the terminal.

```
$ genailogs noweb watch
```
This will run in a loop, displaying the analysis to the terminal but NOT update the web page.

The cron command will setup a cron job (using cru) and store the last NUMLOGS for display on the web page. Each log is seperated by a light blue line with the log file number (i.e. genailog2)
NUMLOG is default at 5. This can be changed in the genailog conf file (/jffs/addons/genailog/genailog.conf). The default period to run genailogs is 1 min. past every hour. Again, these can be changed by editting the conf file.
The cron command requires another argument - add, del or run:
```
cron add - adds the genailog cron function (or updates if it is already setup)
cron del - removes the cron job
cron run - runs the actaul job - genailogs rotates the previous log file (LIFO) based on the number of log files always stored (NUMLOGS)
```

genailogs with no command line options will update the web page and exit.

chat - The chat mode of genailogs will start an interactive "chat" session. You input a question at the prompt (chat > ) and genailogs will send it to GeminiAI for a response.
It then outputs the response in bold and presents another prompt.

Entering "q" at the prompt will end the session.

genailogs always appends the "?" character at the end of the question - but putting one in doesn't change the response.

```GeminiAI Chat mode. Enter a line of text and get a response.
    Enter q to exit this mode

chat> What is the difference between a WiFi Access Point and Router

 **WiFi Access Point (WAP)**

* **Primary Function:** Extends the wireless network coverage of an existing wired network.
* **Role:** Connects wireless devices to the wired network and provides wireless Internet access.
* **Does not have:** Routing capabilities, so it cannot connect to multiple networks or assign IP addresses.

**Wireless Router**

* **Primary Function:** Connects multiple devices (wired and wireless) to the Internet and manages traffic between them.
* **Role:** Acts as a central hub for network traffic, providing routing, DHCP, and firewall protection.
* **Has:** Routing capabilities, allowing it to connect to multiple networks, assign IP addresses, and manage traffic flow.

**Key Differences:**

| Feature | WiFi Access Point | Wireless Router |
|---|---|---|
| Routing Capabilities | No | Yes |
| IP Address Assignment | No | Yes |
| Network Management | None | Firewall, NAT, DHCP |
| Network Connectivity | Single | Multiple |
| Connection Type | Wireless | Both Wired and Wireless |
| Placement | Typically positioned at the edge of the network | Placed centrally to cover the entire area |
| Usage | Extends wireless coverage | Connects devices, manages traffic, and provides Internet access |

chat> Write a short shell script that reads an argument and outputs the number of characters in it

bash..
#!/bin/bash
# This script takes an argument and outputs the number of characters in it.
# Get the argument from the command line.
argument=$1
# Get the length of the argument.
length=${#argument}
# Print the length of the argument.
echo $length

chat> What is a swap file used for

 A swap file is used to extend the amount of physical memory (RAM) available on a computer. When the RAM is full, the system moves some of the less frequently used data from RAM to the swap file, which is stored on the hard drive. This frees up RAM for more active programs and processes.

chat> q
Exiting...

```


## Uninstall
If you decide to remove genailogs, simply run with the uninstall option:
```
$ genailogs uninstall
```
You will be prompted once to make sure you want to remove everything. Uninstall will delete the script, /jff/addons/genailogs directory and conf file and also remove itself from the Addons Menu tab.


