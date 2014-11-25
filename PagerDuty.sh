#!/bin/sh -x
# This script will send notifications from OpenNMS to pagerduty.
# This script was created by Kevin Sonney http://about.me/ksonney and is (C) Copyright 2014 Kevin Sonney.
# This script is released under the AGPL v3 license. https://www.gnu.org/licenses/agpl-3.0.html
# OpenNMS is (c) Copyright 2002-2014 The OpenNMS Group, INC http://www.opennms.com/
#
# To use this script with OpenNMS, set up a notificationCommand similar to the following :
#  <command binary="true">
#        <name>PagerDuty</name>
#        <execute>/opt/opennms/contrib/pagerduty/PagerDuty.sh</execute>
#        <comment>scripted pagerduty http transaction via curl</comment>
#        <argument streamed="false">
#            <substitution>-d</substitution>
#            <switch>-subject</switch>
#        </argument>
#        <argument streamed="false">
#            <substitution>-s</substitution>
#            <switch>-nm</switch>
#        </argument>
#  </command>
#
# And assign this command to a user.
#
# The expected command line arguments are :
# -d device_name -t test_name -s severity

# The PagerDuty API Key
APIKEY="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

# A Debug Log. Does not Rotate
LOGFILE="/tmp/pagerduty.log"

# Turn On (1) or Off (0) Debug Logging
DEBUG=0

# There should be no need to` modify anything below this line
time=`date '+%Y%m%d-%H:%M'`
nodetest=$2
state=$4
log="/dev/null"
if [ "$DEBUG" == "1" ]; then
  log=$LOGFILE
  touch $log
fi
echo "Start Notification" >> $log
echo "Params : \"$@\" ">> $log
while getopts d:t:s: opt; do
  case $opt in
    s)
      state=$OPTARG
      ;;
    d)
      message="$OPTARG"
      ;;
    t)
      textmsg="$OPTARG"
      ;;
    *)
      echo "Unknown Option \"$opt\" = \"$OPTARG\"" >> $log
      ;;
  esac
done

if [ "$state" == "" ]; then
  echo "No State Specified" >> $log
  return 1
fi

if [ "$message" == "" ]; then
   echo "No message specified" >> $log
fi

if [ "$(echo $message | grep RESOLVED)" == "" ]; then
   key=$(echo $message | tr ':' ' ' | awk '{ print $1 }')
else
    key=$(echo $message | tr ':' ' ' | awk '{ print $2 }')
fi
echo "Key is $key taken from \"$message\"" >> $log

case $state in
    RESOLVE* )
      payload="\
      {    \
      \"service_key\": \"$APIKEY\",\
      \"incident_key\": \"$key\",\
      \"event_type\": \"resolve\",\
      \"description\": \"$message\"\
      }"
      ;;
    WARN*|CRIT* )
      payload="\
      {    \
      \"service_key\": \"$APIKEY\",\
      \"incident_key\": \"$key\",\
      \"event_type\": \"trigger\",\
      \"description\": \"$message\"\
      }"
      ;;
    * )
       echo "Unknown state \"$state\", exiting..."  >> $log
       return 1
    ;;
esac

echo "Payload is \"$payload\"" >> $log
echo Sending notification... >> $log
curl -H "Content-type: application/json" -X POST -d "$payload" "https://events.pagerduty.com/generic/2010-04-15/create_event.json"

echo "End notification" >> $log
