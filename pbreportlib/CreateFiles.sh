#!/bin/bash

#Creating Run Blocked File
RunBlockedFile=$DataFolder"/"$ServerName"_run_blocked";
echo "vmstat data for run and blocked processes is in " $RunBlockedFile;

if [ ! -f $RunBlockedFile ]; then
	echo "Setting up vmstat file header.";
	echo "date_time,run,blocked" > $RunBlockedFile;
	echo "Run and Blocked file header is completed.";
fi

#Creating File with Total Process count
TotalProcessFile=$DataFolder"/"$ServerName"_total_process";
echo "vmstat data for the sum of processes is in " $TotalProcessFile;

if [ ! -f $TotalProcessFile ]; then
	echo "Setting up header for Total Processes File.";
	echo "date_time,Total Processes" > $TotalProcessFile;
fi

#Creating File with Free Pages count
FreePagesFile=$DataFolder"/"$ServerName"_free_pages";
echo "vmstat data for the free pages is in " $FreePagesFile;

if [ ! -f $FreePagesFile ]; then
	echo "Setting up Free Pages header";
	echo "date_time,Free Pages" > $FreePagesFile;
fi

#Creating File with Page In
PageInFile=$DataFolder"/"$ServerName"_Page_In";
echo "vmstat data for Pages In is in" $PageInFile;

if [ ! -f $PageInFile ]; then
	echo "Setting up Page In file header.";
	echo "date_time,Page In" > $PageInFile;
fi

#Creating File with Page In
PageOutFile=$DataFolder"/"$ServerName"_Page_Out";
echo "vmstat data for Pages Out is in" $PageOutFile;

if [ ! -f $PageOutFile ]; then
	echo "Setting up Page Out file header.";
	echo "date_time,Page Out" > $PageOutFile;
fi

#For AIX only. Creating File with relation Scanned Pages / Freed Pages
if [ $OS == "aix" ]; then
	ScannedFreedFile=$DataFolder"/"$ServerName"_scanned_freed_ratio";
	echo "Ratio of Scanned Pages by Freed Pages is in " $ScannedFreedFile;
	if [ ! -f $ScannedFreedFile ]; then
		echo "Setting up Ratio of Scanned Pages by Freed Pages file header";
		echo "date_time,sr/fr ratio" > $ScannedFreedFile;
	fi
fi

#Creating file with Context Switch information
ContextSwitchFile=$DataFolder"/"$ServerName"_context_switch";
echo "vmstat data for context switch is in " $ContextSwitchFile;

if [ ! -f $ContextSwitchFile ]; then
	echo "Setting up Context Switch file header.";
	echo "date_time,Context Switch" > $ContextSwitchFile;
fi

#For Linux only. Creating file with Swap usage
SwapFile=$DataFolder"/"$ServerName"_swap";
echo "vmstat data for Swap is in " $SwapFile;

if [ ! -f $SwapFile ] && [ $OS == "lnx" ]; then
	echo "Setting up Swapd file header.";
	echo "date_time,Swapd" > $SwapFile;
fi

#Creating file with CPU time utilization
CPUTimeFile=$DataFolder"/"$ServerName"_cpu_time";
echo "vmstat data for CPU time is in " $CPUTimeFile;

if [ ! -f $CPUTimeFile ]; then
	echo "Setting up CPU time file header."
	echo "date_time,User,System,Wait" > $CPUTimeFile;
fi

#Creating file with total CPU utilization
CPUUtilizationFile=$DataFolder"/"$ServerName"_cpu_utilization";
echo "vmstat data for CPU utilization is in " $CPUUtilizationFile;

if [ ! -f $CPUUtilizationFile ]; then
	echo "Setting up CPU Utilization file header";
	echo "date_time,CPU Utilization" > $CPUUtilizationFile;
fi

#IOwaitFile=$DataFolder"/"$ServerName"_iowait";
#echo "vmstat data for I/O wait is in " $IOwaitFile;

#End of file.
