#! /bin/bash
for i in $( awk -F"/" '{if($1 == "SEC") print $2}' ftp2Folders.txt ); do
WORKFOLDER="/pprocess/"$i"/Download";
LOGFOLDER="/pprocess/"$i"/Log";
LOG=$LOGFOLDER"/Log"$( date | sed "s/ /_/g;s/://g" )".log";

cd $WORKFOLDER;
echo "Moved to files folder: "$WORKFOLDER
  
sftp 'regilo.souza@intersystems.com'@ftp2.intersystems.com <<comm1 > $LOG
 cd ./SEC/$i
 mget *
 ls -1r *
 lls -1r *
 bye
comm1

echo "Checking if all files were downloaded before removing them from ftp server. There is no way to guarantee files are not corrupt as there is no integrity check."
retval=$(awk 'BEGIN{rem=0; loc=0}{
	if($0 ~ / ls -l/){rem=1};
	if($0 ~ /lls -l/){loc=1};
	if($0 ~ /bye/){loc=0};
	if(rem > 0 && loc == 0){remote[rem] = $1; rem++};
	if(loc > 0){local[loc] = $1; loc++};

	} END{ status=1;
	for (i = 1; i <= rem; i++){
		if(local[i] != remote[i]) status=0;
	}
	print status
	}' $LOG)

if [ $retval -eq 1 ]; then
	echo "Files seem to be transferred appropriately. Removing files from FTP server." 
sftp 'regilo.souza@intersystems.com'@ftp2.intersystems.com <<comm2
 cd ./SEC/$i
 rm *
 bye
comm2
else
	echo "Files not successfully download. Trying again in an hour."
fi

/usr/local/bin/hubFTP2lib/organizeFilesFTP2.sh "/pprocess/"$i
done
