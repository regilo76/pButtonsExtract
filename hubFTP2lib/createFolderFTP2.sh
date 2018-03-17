#! /bin/bash

sftp 'regilo.souza@intersystems.com'@ftp2.intersystems.com <<comm1 > ftp2Folders.txt 
 ls -1 SEC/*
 bye
comm1

echo "Assessing folders in svcpbuttons1 server. If necessary customer folders will be created in /pprocess and /pbuttons mounting points."
awk -F"/" '{
	if($1 == "SEC"){
		folder = "/pprocess/"$2; 
		print "if [ ! -d " folder " ]; then"
		print "echo \"Folder " folder " do not exist. Creating work folder(s) in /pprocess.\";"
		print "mkdir " folder
		print " fi"
                dfolder = "/pprocess/"$2"/Download";
                print "if [ ! -d " dfolder " ]; then"
                print "echo \"Folder " dfolder " do not exist. Creating download folder(s) in /pprocess.\";"
                print "mkdir " dfolder
                print " fi"
                qfolder = "/pprocess/"$2"/Quarentine";
                print "if [ ! -d " qfolder " ]; then"
                print "echo \"Folder " qfolder " do not exist. Creating quarentine folder(s) in /pprocess.\";"
                print "mkdir " qfolder
                print " fi"
                lfolder = "/pprocess/"$2"/Log";
                print "if [ ! -d " lfolder " ]; then"
                print "echo \"Folder " lfolder " do not exist. Creating log folder(s) in /pprocess.\";"
                print "mkdir " lfolder
                print " fi"
                gfolder = "/pbuttons/"$2;
                print "if [ ! -d " gfolder " ]; then"
                print "echo \"Folder " gfolder " do not exist. Creating archiving folder(s) in /pbuttons.\";"
                print "mkdir " gfolder
                print " fi"
	}
}' ftp2Folders.txt | bash

echo
