#!/bin/bash

MONTH=`date -d"1 month ago" +"%m"`
if [ $MONTH != "12" ];then
YEAR=`date +"%Y"`
else
YEAR=`date -d"1 year ago" +"%Y"`
fi
ASTLOGDIR=/var/log/asterisk/cdr-csv
TMPDIR=/tmp
TMPFILE=cdrfiltered
USERFIELD=somethingyouwanttofilterby
grep -i "$USERFIELD" $ASTLOGDIR/Master-*-$MONTH-$YEAR_*.csv  | awk 'BEGIN{ FS=","; print "Caller\tDailed number\tStart \t \tAnswer \t \t \tEnd\t \t \tDuration(s)"; } { if ($12 == "") print $2"\t"$3"\t"$11"\t""\t\"NO ANSWER\"\t"$13"\t"$15; if ($12 != "") print $2"\t"$3"\t"$11"\t"$12"\t"$13"\t"$15;}' > $TMPDIR/$TMPFILE

#total number of calls
BR_POZIVA_TOTAL=`cat /tmp/cdrfiltered | wc -l`
totalsec=0
for sec in `cat $TMPDIR/$TMPFILE | sed 1d | awk -F'\t' '{ if ($5 !~ "NO ANSWER") print $6}'`
do
secinline=`echo ${sec} | cut -f 1`
totalsec=`expr ${totalsec} + ${secinline}`  
done
#total duration in minutes
totalmin=`expr $totalsec / 60`

echo "Asterisk CDR report for $(hostname) 
Month/Year: $MONTH/$YEAR
Total number of USERFIELD filtered calls: $BR_POZIVA_TOTAL
Total duration of USERFIELD filtered calls in minutes: $totalmin
--
YOUR SIGNATURE

" > $TMPDIR/email2user-msg.txt 
cat $TMPDIR/$TMPFILE >> $TMPDIR/email2user-att.txt 
rm $TMPDIR/$TMPFILE
exit 0




