DOWNLOADFOLDER=$1"/Download"
gunzip $DOWNLOADFOLDER/*.gz
unzip $DOWNLOADFOLDER/*.zip

for i in $( ls $DOWNLOADFOLDER ); do 
	PBUTTONSFILE=$DOWNLOADFOLDER"/"$i;
	FILEMETADATA=$( head -4 $PBUTTONSFILE | tail -1 );
	echo "Assesing $PBUTTONSFILE metadata";
	if [[ $FILEMETADATA == *Performance* ]]; then
		echo "$PBUTTONSFILE is a valid pButtons.";
		SERVER=$( echo $i | awk -F"_" '{print $1}' );
		INSTANCE=$( echo $i | awk -F"_" '{print $2}' );
		if [ ! -d $1"/"$SERVER ]; then
			echo "Folder $1/$SERVER do not exist. Creating folders this server.";
			mkdir $1"/"$SERVER;
		fi
		if [ ! -d $1"/"$SERVER"/"$INSTANCE ]; then
                        echo "Folder $1/$SERVER/$INSTANCE do not exist.";
			mkdir $1"/"$SERVER"/"$INSTANCE;
                fi
                if [ ! -d $1"/"$SERVER"/"$INSTANCE"/newpbuttons" ]; then
                        echo "Folder $1/$SERVER/$INSTANCE/newpbuttons do not exist.";
                        mkdir $1"/"$SERVER"/"$INSTANCE"/newpbuttons";
			echo $( date +%M" "%H )" * * * root /usr/local/bin/pbreport "$1"/"$SERVER"/"$INSTANCE"/newpbuttons" >> /etc/crontab;
                fi

		mv -v $PBUTTONSFILE $1"/"$SERVER"/"$INSTANCE"/newpbuttons";
	else
		mv -v $DOWNLOADFOLDER/* $1/Quarentine
	fi
done
