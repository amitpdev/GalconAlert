#!/bin/bash


# This is where you should name the friends you want to track
FRIENDS_LIST='justrafi ronenli yakirh'

MAX_FILE_AGE_IN_SECONDS=1200 # 60*20
GALCON_RECENT_URL='http://www.galcon.com/iphone/recent.php'
TEMP_RECENT_FILE='/var/tmp/galcon_recent.php'

send_push_notif()
{
	touch /var/tmp/.$1
	# send me push notification
	/usr/bin/php galcon_push.php $1 &>/dev/null
	now=$(date)
	if [ $? -eq 0 ];then
		echo "$now: Notification was sent for user $1!"
	else
		echo "$now: Notification send failed for user $1"
	fi


}

# Fetch data from galcon.com
curl $GALCON_RECENT_URL -o $TEMP_RECENT_FILE &>/dev/null

# Grep the data line and parse it into lines
data=$(grep 'Winners' $TEMP_RECENT_FILE | sed 's/<tr><td>/\n/g' | sed 's/<td>/ /g')
 

for friend in $FRIENDS_LIST; do
	if [[ $data =~ $friend ]]; then
		if [ -f /var/tmp/.$friend ];then
	               time_d="$(stat /var/tmp/.$friend  | grep -i modify | /bin/awk '{print $2" "$3}' )"
		       time_epoch="$(date -d "$time_d" '+%s')"
		       time_now_epoch="$(date '+%s')"
		       delta_time=$(($time_now_epoch - $time_epoch))
		       if [ $delta_time -gt ${MAX_FILE_AGE_IN_SECONDS} ]; then
				send_push_notif $friend
		       fi
		else
				send_push_notif $friend
		fi
	fi

done

