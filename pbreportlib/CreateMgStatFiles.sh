#Creating file with mgstat information regarding read ratio
MgstatFile=$DataFolder"/"$ServerName"_readratio";
echo "mgstat data for Read Ratio is in " $MgstatFile;

if [ ! -f $MgstatFile ]; then
	echo "Setting up Read Ratio file header.";
	echo "date_time,Read Ratio" > $MgstatFile;
fi

#Creating File with amount of Local Physical Reads request 
PhysicalReadFile=$DataFolder"/"$ServerName"_physicalread";
echo "Physical Read data is in " $PhysicalReadFile;

if [ ! -f $PhysicalReadFile ]; then
	echo "Setting up Physical Read file header.";
	echo "date_time,Physical Read" > $PhysicalReadFile;
fi

#Creating File with amount of I/O request Cache requested
IORequestFile=$DataFolder"/"$ServerName"_io_request";
echo "I/O Request data is in " $IORequestFile;

if [ ! -f $IORequestFile ]; then
	echo "Setting up I/O Request file header.";
	echo "date_time,I/O Request" > $IORequestFile;
fi

#Creating File with amount of Global references
GlobalReferenceFile=$DataFolder"/"$ServerName"_global_reference";
echo "Global Reference data is in " $GlobalReferenceFile;

if [ ! -f $GlobalReferenceFile ]; then
	echo "Setting up Global Reference file header.";
	echo "date_time,Global References" > $GlobalReferenceFile;
fi
#ConfigFile=$ServerName"_config";
#echo "Partial configuration data is in " $ConfigFile;

#End of file.
