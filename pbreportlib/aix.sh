#!
	while [ "$CountFile" -lt "$NumberFiles" ]
	do
		echo "File " $((CountFile + 1)) " out of " $NumberFiles;
		
		DateTime=$(echo ${Files[$CountFile]} | awk -F"_" '{print $3" "substr($4,1,4)}');
		echo "********Verifying Date and Time:" $DateTime;
		InitialTime=`date --date="$DateTime" +"%s"`

		Intervals=$(awk '{if($0 ~ /Run over/) {print $0; exit;}}' $1"/"${Files[$CountFile]});
		echo $Intervals
		NumberLines=$(echo $Intervals | cut -d " " -f 3);
		#echo "File contains " $NumberLines " records."
		TimeUnit=$(echo $Intervals | cut -d " " -f 7);
		IntervalValue=$(echo $Intervals | cut -d " " -f 6);
		#echo "running every " $IntervalValue " " $TimeUnit
		if [ $TimeUnit == "minutes." ]; then
			IntervalValue=$((IntervalValue * 60));
		fi

		echo "Extracting mgstat data from: " ${Files[$CountFile]}
		awk  -v mgstat=$MgstatFile -v physicalread=$PhysicalReadFile -v iorequest=$IORequestFile -v globalreference=$GlobalReferenceFile -F"," 'BEGIN{OFS=","}{
			if($0 ~ /end_mgstat/) exit; 
			if(mg_imprime > 0){ 
				if(mg_imprime > 3){
					gsub(/ /, ""); 
					if ($6 != 0) print $1"_"$2, $7 >> mgstat;
				    print $1"_"$2, $6 >> physicalread;
				    print $1"_"$2, $6 + $(12) + $(14) + $(18) + $(19) >> iorequest;
				    print $1"_"$2, $3 + $4 >> globalreference;
				} 
				mg_imprime++; 
			} 
			if($0 ~ /beg_mgstat/) mg_imprime = 1; 
		}' $1"/"${Files[$CountFile]};

		echo "Extracting vmstat data from:" $1"/"${Files[$CountFile]};
		awk -v tm_interval=$IntervalValue -v vm_time=$InitialTime -v runblocked=$RunBlockedFile -v tpfile=$TotalProcessFile -v total_cores=$Cores -v fpfile=$FreePagesFile -v sffile=$ScannedFreedFile -v csfile=$ContextSwitchFile -v ctfile=$CPUTimeFile -v cufile=$CPUUtilizationFile 'BEGIN{OFS=","}{
                        if($0 ~ /end_vmstat/) {
				printf "\n";
				exit;
			}
                        if(vm_imprime > 0){
                                tmp = "date -d@" vm_time " \"+%m/%d/%Y_%H:%M:%S\"";
                                tmp | getline myepoch
                                if(vm_imprime > 1 && $1 != "") {
					printf "\rprocessing vmstat line: %s", vm_imprime - 1;
                                        print myepoch, $1, $2 >> runblocked;
					total_process = $1 + $2;
					print myepoch, total_process, total_cores >> tpfile;
					print myepoch, $4, $6  >> fpfile;
					if ($8 != 0) {
						sfratio = $9 / $8;
						print myepoch, sfratio  >> sffile
					} 
					print myepoch, $(13) >> csfile
					print myepoch, $(14), $(15), $(17) >> ctfile
					utilization = $(14) + $(15) + $(17)
					print myepoch, utilization >> cufile

                                }
                                vm_imprime++;
                                close(tmp);
                                vm_time = vm_time + tm_interval;
                        }
                        if($0 ~ /beg_vmstat/) vm_imprime = 1;
		}' $1"/"${Files[$CountFile]};
reqiostat=1;
        if [ $reqiostat -eq 1 ]; then
		echo "Extracting iostat data from "$1"/"${Files[$CountFile]};
		awk -v folder=$DataFolder"/"$ServerName -v tm_interval=$IntervalValue -v initime=$InitialTime -v fcount=$CountFile 'BEGIN{OFS=","; imprime = 0; disk = 1; count = 0; dcount = 0}{
		        if(imprime > 0){
		                if($0 ~ /Back to top/){
					printf "\n";
					exit;
				}
		                if(disk != 0){
		                        if ($1  ~  /hdisk/ && $1 in wrdisk){
						printf "\nThere are " disk " physical disk(s). Spliting and formatting data.\n";
		                                disk = 0;
		                        } else if ($1 ~ /hdisk/ || $1 ~ /hdiskpower/){
						wrdisk[$1] = folder"_write_"$1;
						rddisk[$1] = folder"_read_"$1;
						utdisk[$1] = folder"_service_time_"$1;
						rwdisk[$1] = folder"_wait_"$1;
						if (fcount == 0){
							print "date_time,write avg service" >> wrdisk[$1];
							print "date_time,read avg service" >> rddisk[$1];
							print "date_time,avg read service,avg write service,avg wait time" >> utdisk[$1];
							print "date_time,wait" >> rwdisk[$1];
						}
		                                disk++;
		                                dcount++;
		                        }
		                }
				if($0 ~ /Disks:/) printf"\rProcessing ocorrence: %s", ioline++;
		                if(imprime > 3 && $1 in wrdisk){
		                        tmp = "date -d@" initime " \"+%m/%d/%Y_%H:%M:%S\"";
		                        tmp | getline myepoch
					
		                        print myepoch, $8 >> rddisk[$1];
					print myepoch, $(14) >> wrdisk[$1];
					print myepoch, $8, $(14), $(19) >> utdisk[$1];
					print myepoch, $(19) >> rwdisk[$1];
		                        close(tmp);
		                        close(rddisk[$1]);
					close(wrdisk[$1]);
					close(utdisk[$1]);
					close(rwdisk[$1]);
		                        count++;
		                        if(count == dcount){
		                                count = 0;
		                                initime = initime + tm_interval;
		                        }
		                }
		                imprime++;
		        }
		        if($0 ~ /div id=iostat/) imprime = 1;
		}' $1"/"${Files[$CountFile]}
        fi

                gzip $1"/"${Files[$CountFile]};
                mv -v $1"/"${Files[$CountFile]}".gz" $ProcessedFolder;
        
		CountFile=$(( CountFile + 1 ));
	done
