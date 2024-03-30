#!/bin/sh

# genailogs - feed some log files to Googles Gemini AI and output the results
#
# default usage sends the output to a userXX.asp file in /tmp/var/wwwext for viewing on
# the Addons tab for Asuswrt-Merlin based routers
#

# Debug and verbose flags
debug=0
verbose=0
noweb=0
debughtml=0

readonly API_KEY="Put your API key here"
USERASP=user19

# Function to check for options and installed needed apps
#          and build the log file list
initgenai() {

	if [ ! -x /opt/bin/opkg ]; then
		printf "\\nEntware not deteted (and needed)\\n"
		printf "Install using AMTM and try again.\\n"
		exit 1
	fi

	if [ ! -x /opt/bin/fold ]; then
		printf "\\nThe application fold is needed.\\n"
		printf "   Install now (Y|N) ? "
		read -r answr
		case $answr in
			Y|y)
				printf "\\nInstalling..."
				/opt/bin/opkg update
				/opt/bin/opkg install coreutils-fold
				if [ ! -x /opt/bin/fold ]; then
					printf "\\nError - can't seem to install fold...\\n"
					printf "   Exiting\\n"
					exit 1
				fi
				printf "\\nSuccess\\n"
			;;
			N|n)
				printf "This scripts requires fold...exiting\\n"
				exit 1
			;;
			*)
				printf "Enter either Y or N...exiting\\n"
				exit 1
			;;
		esac
	fi

	logfiles=/tmp/syslog.log

	if [ ! "$#" -eq 0 ]; then
		while [ "$#" -gt 0 ]; do
    			case $1 in
				user*)
					USERASP="$1"
					printf "\\nUser ASP is $USERASP\\n"
				;;
				skynet)
					skybase=$(grep skynetloc /jffs/scripts/firewall-start | awk '{print $4}' | sed 's/skynetloc=//')
					logfiles="$logfiles $skybase/skynet.log"
				;;
				diversion)
					logfiles="$logfiles /opt/var/log/dnsmasq.log"
				;;
				verbose)
					verbose=1
					printf "\\nVerbose On\\n"
		 		;;
				noweb) 
					noweb=1
					printf "\\nNo Web On\\n"
				;;
				debug)
					debug=1
					printf "\\nDebug On\\n"
           			;;
				debughtml)
					debughtml=1
				;;
				*)
	   				echo "Invalid argument $1"
	   				exit
           			;;
    			esac
    		shift
		done
	fi

	# Set output file path based on debug mode
	if [ $debughtml = 1 ]; then
    		output_file_path="/tmp/$USERASP.asp"
		printf "\\nNote: Using debug asp file\\n"
	else
    		output_file_path="/tmp/var/wwwext/$USERASP.asp"
	fi

echo "files:" "$logfiles"
read a
}

# Function to call GenAI
genaiqa() {

# only look at logs for todays date
    todayis=$(date +"%b %d")
    logis=$(basename $1)
    grep "$todayis" "$1" > $logis


    d=$(tail -n "$2" "$logis")

    question="Please analyze the following log file for issues: '${d}'"

    # Call GenAI API
    curl -sSX POST \
        -H 'Content-Type: application/json' \
        -H "x-goog-api-key: ${API_KEY}" \
        -o "genresp" \
        -d '{
                "contents": [
                        {
                        "role": "user",
                        "parts": [
                                {
                                "text": "Please analyze the following log file for issues: '"${d}"'"
                                }
                        ]
                        }
                ]
                }' \
        "https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent"

    if [ -s genresp ]; then
        output=$(jq -r '.candidates[0].content.parts[0].text' genresp | tr -d "'")
        if [ $debug = 1 ]; then
            printf "DEBUG:%s" "$output"
        fi
    else
        output="Unable to get any answers from Google AI"
    fi
    rm -f $logis
}

# Function to start HTML file
starthtmlfile() {
    if [ $noweb = 0 ]; then
	echo "<!DOCTYPE html>" > "$output_file_path"
    	echo "<html>" >> "$output_file_path"
    	echo "<head>" >> "$output_file_path"
    	echo "<title> GeminiAI Log Analyze </title>" >> "$output_file_path"
    	echo "</head><body>" >> "$output_file_path"
    fi
}

# Function to close HTML file
closehtmlfile() {
    if [ $noweb = 0 ]; then
    	echo "</body></html>" >> "$output_file_path"
    fi
}

# Function to prepare output
prepareoutput() {

	request="<b><i>Please analyze the following log file ($log) for issues:</i></b><br><br>'"${d}"'"
	prettyout="$(printf "%s" "$output" | fold -w 80 -s)"

	if [ $debug = 1 ]; then
		printf "DEBUG: $request"
		echo
		printf "DEBUG: $prettyout"
		echo
		read -r
	fi

	if [ $noweb = 0 ]; then

		# Save the log content and analysis result to a file
    		echo "<h2> Question ($log):</h2>" >> $output_file_path
    		echo "<pre style=\"background-color:lightgrey;\"> $request</pre>" >> $output_file_path
    		echo "<h2 style=\"background-color:white;\"> GenAI Analysis Result ($log):</h2>" >> $output_file_path
    		echo "<pre>$prettyout</pre>" >> $output_file_path
	fi
}

# Function to print request and answer to screen if verbose or noweb mode on
showverbose() {
	if [ $verbose = 1 ] || [ $noweb = 1 ]; then
    		printf "\\nHere is the question and response:\\n\\n"
    		printf "%s\\n" "$question"
    		read -rp "Press Enter to continue..."
    		printf "\\n%s\\n" "$prettyout"
	fi
}

# remove temp files
cleanupfiles() {
	rm -f genresp
}



# Main script

initgenai "$@"

starthtmlfile

for log in $logfiles
do
	genaiqa "$log" 30
	prepareoutput
	printf "\\nQuestion, Log content, and GenAI analysis result for "$log" saved to $output_file_path\\n"
	showverbose
done

closehtmlfile

cleanupfiles

exit

