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
grep -i "voopix\=odlazni" $ASTLOGDIR/Master-*-$MONTH-$YEAR_*.csv  | awk 'BEGIN{ FS=","; print "Pozivatelj\tBirani broj\tPocetak \t \tAnswer \t \t \tKraj\t \t \tTrajanje(s)"; } { if ($12 == "") print $2"\t"$3"\t"$11"\t""\t\"NO ANSWER\"\t"$13"\t"$15; if ($12 != "") print $2"\t"$3"\t"$11"\t"$12"\t"$13"\t"$15;}' > $TMPDIR/$TMPFILE

BR_POZIVA_TOTAL=`cat /tmp/cdrfiltered | wc -l`
totalsec=0
for sec in `cat $TMPDIR/$TMPFILE | sed 1d | awk -F'\t' '{ if ($5 !~ "NO ANSWER") print $6}'`
do
secinline=`echo ${sec} | cut -f 1`
totalsec=`expr ${totalsec} + ${secinline}`  
done
totalmin=`expr $totalsec / 60`

echo "Asterisk CDR izvjestaj za $(hostname) 
Mjesec/godina: $MONTH/$YEAR
Ukupan broj besplatnih poziva: $BR_POZIVA_TOTAL
Ukupan broj besplatnih minuta: $totalmin
--
Vas voopIX tim

" > $TMPDIR/email2fkit-msg.txt 
cat $TMPDIR/$TMPFILE >> $TMPDIR/email2fkit-att.txt 
rm $TMPDIR/$TMPFILE
exit 0




