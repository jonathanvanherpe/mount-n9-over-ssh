#!/bin/sh
ping -c 1 RM696 > /dev/null;
if [ "$?" -eq 0 ] ; then
	sshfs -C -o Ciphers=arcfour user@RM696:/ /media/ssh/n9/;

	DATA=`ssh -C -o Ciphers=arcfour user@RM696 exec 'hal-device bme'`;
	#echo "$DATA";
	UPTIME=`ssh -C -o Ciphers=arcfour user@RM696 exec 'uptime'`;
	#BATTERY=`ssh user@Nokia-N900-42-11.local exec 'hal-device bme' | grep 'percentage'`;
	BATTERY=`echo "$DATA" | grep 'percentage'`;
	CHARGESTATUS=`echo "$DATA" | grep 'charging_status' | cut -d' ' -f 5`;
	#echo "$CHARGESTATUS";
	
	LOAD=`echo "$UPTIME" | grep 'load average' | sed -e "s/.*load average: \(.*\...\), \(.*\...\), \(.*\...\)/\1/" -e "s/ //g"`;
	#echo "$BATTERY";
	BATTERYSHORT=`echo $BATTERY | cut -d' ' -f 3`;
	#echo "$BATTERYSHORT";
	LOADISHIGH=`echo "$LOAD > 1.0" | bc`;

	if [ $CHARGESTATUS != "'on'" ] ; then
		if [ $BATTERYSHORT -lt 21 -a $BATTERYSHORT -ne 0 ] ; then
			notify-send --hint=int:transient:1 "Recharge phone" "only <b>$BATTERYSHORT%</b> remaining!" -i /media/ssh/n9/home/user/MyDocs/.icon.ico;
		elif [ $BATTERYSHORT -eq 0 ] ; then
			notify-send --hint=int:transient:1 "Phone can die any minute now" "oh noes!!!" -i /media/ssh/n9/home/user/MyDocs/.icon.ico;
		elif [ $LOADISHIGH -eq 1 ] ; then
			notify-send --hint=int:transient:1 "Phone is under high load" "Load is <b>$LOAD</b>." -i /media/ssh/n9/home/user/MyDocs/.icon.ico;
		fi
	fi	
	#notify-send --hint=int:transient:1 "N9" "notifications work!" -i /media/ssh/n9/home/user/MyDocs/.icon.ico;
else
	fusermount -u /media/ssh/n9/;
	echo "phone unmounted";
fi


