        while [ "$CountFile" -lt "$NumberFiles" ]
        do
		echo "File " $((CountFile + 1)) " out of " $NumberFiles;
		DateTime=$(echo ${Files[$CountFile]} | awk -F"_" '{print $3 " " substr($4,1,4)}');
		echo "**********Verifying date and time:" $DateTime; 
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
                                if(mg_imprime >= 3){
                                    gsub(/ /, "");
                                    if($6 != 0) print $1"_"$2, $7 >> mgstat;
                                    print $1"_"$2, $6 >> physicalread;
				                    print $1"_"$2, $6 + $(12) + $(14) + $(18) + $(19) >> iorequest;
				                    print $1"_"$2, $3 + $4 >> globalreference;
                                }
                              mg_imprime++;
                        }
                        if($0 ~ /beg_mgstat/) mg_imprime = 1;
                }' $1"/"${Files[$CountFile]};

                echo "Extracting vmstat data from:" $1"/"${Files[$CountFile]};
                awk -v vm_time=$InitialTime -v runblocked=$RunBlockedFile -v tpfile=$TotalProcessFile -v total_cores=$Cores -v fpfile=$FreePagesFile -v swfile=$SwapFile -v pifile=$PageInFile -v pofile=$PageOutFile -v csfile=$ContextSwitchFile -v ctfile=$CPUTimeFile -v cufile=$CPUUtilizationFile 'BEGIN{OFS=","}{
                        if($0 ~ /end_vmstat/){
				printf "\n";
				exit;
			}
                        if(vm_imprime > 0){
                                if(vm_imprime > 1 && $1 != "") {
                                        printf "\rprocessing vmstat line: %s", vm_imprime;
					                    split($1,vmdate,"/");
					                    rdate = vmdate[1]"/"vmdate[2]"/20"vmdate[3];
                                        print rdate"_"$2, $3, $4 >> runblocked;
                                        total_process = $3 + $4;
                                        print rdate"_"$2, total_process, total_cores >> tpfile;
                                        print rdate"_"$2, $6 >> fpfile;
					                    print rdate"_"$2, $9 >> pifile;
					                    print rdate"_"$2, $(10) >> pofile;
                                        print rdate"_"$2, $(14) >> csfile
					                    print rdate"_"$2, $5 >> swfile;
                                        print rdate"_"$2, $(15), $(16), $(18) >> ctfile
                                        utilization = $(15) + $(16) + $(18)
                                        print rdate"_"$2, utilization >> cufile
                                }
                                vm_imprime++;
                        }
                        if($0 ~ /beg_vmstat/) vm_imprime = 1;
                }' $1"/"${Files[$CountFile]};

                echo "Extracting iostat from "$1"/"${Files[$CountFile]};
                awk -v initime=$InitialTime -v tm_interval=$IntervalValue -v fcount=$CountFile -v folder=$DataFolder"/"$ServerName 'BEGIN{OFS=","; imprime = 0; disk = 1; count = 0; dcount = 0}{
                        if(imprime > 0){
                                if($0 ~ /Back to top/){
					                printf "\n";
					                exit;
				                }
                                if(disk != 0 && imprime > 5){
                                        if ($0 ~ /avg-cpu/ || $0 ~ /:/){
                                                printf "\nThere are " disk " disk(s). Spliting and formatting data.\n";
                                                disk = 0;
                                        } else {
                                                rddisk[$1] = folder"service_time_"$1;
                                                wtdisk[$1] = folder"wait_"$1;
						                        utdisk[$1] = folder"utilization_"$1;
                                                if (fcount == 0){
                                                        print "date_time,avg service time (svctm)" >> rddisk[$1];
                                                        print "date_time,avg wait time (await)" >> wtdisk[$1];
							                            print "date_time,utilization (%util)" >> utdisk[$1];
                                                }
                                                disk++;
                                                dcount++;
                                        }
                                }

				                if($0 ~ /Device:/) printf"\rProcessing ocorrence: %s", ioline++;

                                if(imprime > 4 && $1 in rddisk){
                                        tmp = "date -d@" initime " \"+%m/%d/%Y_%H:%M:%S\"";
                                        tmp | getline myepoch
                                        print myepoch, $(11) >> rddisk[$1];
                                        print myepoch, $(12) >> utdisk[$1];
                                        print myepoch, $(10) >> wtdisk[$1];
                                        close(tmp);
                                        count++;
                                        if(count == dcount){
                                                count = 0;
                                                initime = initime + tm_interval;
                                        }
                                }
                                imprime++;
                        }
                        if($0 ~ /div id=iostat/) imprime = 1;
		}' $1"/"${Files[$CountFile]};

		gzip $1"/"${Files[$CountFile]};
		mv -v $1"/"${Files[$CountFile]}".gz" $ProcessedFolder;

                CountFile=$(( CountFile + 1 ));
        done

