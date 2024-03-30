# genailogs
Get Google Gemini AI to opine on various log files

A different take on an snbforums.com user (aru) original python script that sends portions of log files
from Asuswrt-Merlin based routers and shows the results in a web page.

I used the help of AI to convert to Linux shell, tweaked the web page look and added some options

## About
genailogs.sh will send log file(s) to Google Gemini AI and then format the results in html for viewing

The default action is to take the last 40 lines from /tmp/syslog.log and send for analysys.
There are some command line options:
```
userXX - set the userXX.asp name instead of the default user19.asp
skynet - include skynets log
diversion - include diversions log
verbose - output the question (log) and response to terminal
debug - output some debug info
noweb - don't create the userXX.asp file, just display on the screen
```

You can add any of the command line options on one line:

```
$ genailogs.sh user7 skynet
```
This changes the default .asp file and adds the skynet log

## Installation

Before useing genailogs.sh you will need to get a Google API key:
```
Get API key from https://aistudio.google.com/app/apikey
```
Edit the genailogs.sh file and put the api key string in the line:
```
readonly API_KEY="Put your API key here"
```
You will also need to edit /tmp/menuTree.js to add the userXX.asp information
Search for the following crucial keywords index:"menu_Addons",
You'll notice that all other addon menus are uniformly integrated here
add the following line (useing either the default filename user19.asp or what you decide to use) after
```
menuName: "Addons",
index: "menu_Addons",
tab: [
```

```
{url: "user20.asp", tabName: "user19.asp"},
```
