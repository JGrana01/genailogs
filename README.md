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
$ genailog.sh user7 skynet
```
This changes the default .asp file and addes skynet logs

