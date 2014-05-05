#!/bin/sh

./py.sh

cat htmllist.txt | while read a
do
	addr=`echo $a | cut -d',' -f1`
	mp3name=`echo $a | cut -d',' -f2`
	html1=$(basename "$addr")
	wget -q $addr
	wait

	path=`grep -o -m 1 '/audio/Audio/[^ ]*html' $html1`
	html2=$(basename "$path")
	wget -q http://learningenglish.voanews.com$path
	wait

	mp3addr=`grep -o 'src=[^ ]*mp3' $html2 | grep -o 'http[^ ]*'`
	echo $mp3addr
	echo $mp3name

	if [ ! -f "$mp3name" ]
	then
		wget -O "$mp3name" $mp3addr
	fi

	textname=`echo $mp3name | sed 's/.mp3$/.txt/'`
	sed '/^$/d' -i "$textname"

	rm *.html
done

