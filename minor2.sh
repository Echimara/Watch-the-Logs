#!/bin/bash

# HOW TO RUN: Into a terminal environment, type:
# 1) chmod +x minor2.sh   --> to make sure the file is executable 
# 2) ./minor2.sh          --> to compile
# 3) ctrl+C twice         --> to terminate

# Definition of function, custom_handler.
# It traps the first input of ctrl+C i.e., SIGINT
custom_handler() {
    echo "(SIGINT) ignored. Enter ^C 1 more time to terminate the program."
    trap SIGINT
}

# Set up the previously defined signal handler
trap custom_handler SIGINT

# Get the formatted system date
f_date=$(date +"%a %b %d %H:%M:%S %Z %Y")

# Get the hostname and remove "-cse" if present
host=$(hostname | sed 's/-cse//')

# Prints the list of initially logged-in users and the total user count
echo "$f_date: Initial users logged in"
who -u | awk -v host="$host" '{print "> " $1 " logged in to " host}'

# A continuous while loop that is terminated by a second SIGINT
while true; do
    # A while loop that reads lines from the redirected output of "last -F"
    while read -r line; do
        # Check if a line indicates a user logging in at the current time
        if [[ $(echo "$line" | awk '{print $11}') == "in" && $(echo "$line" | awk '{print $9}') == $(date +"%T") ]]; then
            echo "> $(echo "$line" | awk '{print $1}') logged in to $host"
        elif [[ $(echo "$line" | awk '{print $9}') == "-" && $(echo "$line" | awk '{print $13}') == $(date +"%T") ]]; then
            echo "> $(echo "$line" | awk '{print $1}') logged out of $host"
        fi
        echo "$(date +"%a %b %d %H:%M:%S %Z %Y"): # of users: $(who | wc -l)"
        sleep 10
    done < <(last -F)
done
