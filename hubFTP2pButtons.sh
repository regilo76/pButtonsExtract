#!/bin/bash

echo "Assessing current folder in the ftp2.intersystems.com/SEC.";
/usr/local/bin/hubFTP2lib/createFolderFTP2.sh

echo "Downloading files from ftp2.intersystems.com";
/usr/local/bin/hubFTP2lib/getFilesFTP2.sh
#./hubFTP2lib/organizeFilesFTP2.sh
