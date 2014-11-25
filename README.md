PagerDuty-OpenNMS
========

PagerDuty-OpenNMS is a script run by OpenNMS that calls the PagerDuty Integration API with curl.

Configuration
======

The configuration itself is not overly complex: 

1. Place the attached script in $OPENNMS_HOME/contrib/pagerduty
2. Change the API key from “XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX” to the proper Service API Key (see below for instructions on how to add a service.)
3. Make the script executable
4. Add a notification command to $OPENNMS_HOME/etc/notificationCommands.xml calling the script. (There is an example in the script header)
5. Restart OpenNMS and Log in
6. Navigate to Admin->Configure Notifications->Destination Paths
7. Select and Escalation and click “Edit”
8. Select a target and click “Edit”
9. Click “Next” after selecting users or groups
10. Change the command for the target user to “PagerDuty” and click "Next"
11. Click “Finish”

Adding OpenNMS as a service in PagerDuty
======

1. Click "Services" in the menu bar.
2. Click "+ Add New Service"
3. Name your service and select an Escalation Policy
4. Select "Use our API directly" 
 - **Note**: When using this script, do not specify OpenNMS under "Select a Tool." This will create an email-based integration--and thus fail to generate a Service API Key--because neither PagerDuty nor OpenNMS officially support this script.

Credit and License
======

This script was written by and provided courtesy of [Kevin Sonney](http://about.me/ksonney) ([sonny](https://github.com/sonny)) and is ©2014, Kevin Sonney. It is licensed under the AGPLv3.