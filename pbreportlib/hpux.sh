        while [ "$CountFile" -lt "$NumberFiles" ]
        do
                DateTime=$(echo ${Files[$CountFile]} | cut -d "_" -f 3,4);
                InitialTime=`date -j -f "%Y%m%d_%H%M" $DateTime +"%s"`

                echo "Extracting mgstat data from: " ${Files[$CountFile]}
                awk  -v mgstat=$MgstatFile -F"," 'BEGIN{OFS=","}{
                        if($0 ~ /end_mgstat/) exit;
                        if(mg_imprime > 0){
                                if(mg_imprime > 3 && $6 != 0){
                                        gsub(/ /, "");
                                        print $1"_"$2, $7,1000,200 >> mgstat;
                                }
                                mg_imprime++;
                        }
                        if($0 ~ /beg_mgstat/) mg_imprime = 1;
                }' $1"/"${Files[$CountFile]};

                echo "Extracting vmstat data from:" $1"/"${Files[$CountFile]};
                awk -v vm_time=$InitialTime -v runblocked=$RunBlockedFile -v tpfile=$TotalProcessFile -v total_cores=$Cores -v fpfile=$FreePagesFile -v sffile=$ScannedFreedFile -v csfile=$ContextSwitchFile -v ctfile=$CPUTimeFile -v cufile=$CPUUtilizationFile 'BEGIN{OFS=","}{
                        if($0 ~ /end_vmstat/) exit;
                        if(vm_imprime > 0){
                                tmp = "date -r " vm_time " \"+%m/%d/%Y:%H:%M:%S\"";
                                tmp | getline myepoch
                                if(vm_imprime > 1 && $1 != "") {
                                        print myepoch, $1, $2 >> runblocked;
                                        total_process = $1 + $2;
                                        print myepoch, total_process, total_cores >> tpfile;
                                        print myepoch, $4, $6  >> fpfile;
                                        if ($(10) != 0) {
                                                sfratio = $(12) / $(10);
                                                print myepoch, sfratio  >> sffile
                                        }
                                        print myepoch, $(15) >> csfile
                                        print myepoch, $(16), $(17), (100 - $(16) - $(17) - $(18)) >> ctfile
                                        utilization = 100 - $(18)
                                        print myepoch, utilization >> cufile
                                }
                                vm_imprime++;
                                close(tmp);
                                vm_time = vm_time + 30;
                        }
                        if($0 ~ /beg_vmstat/) vm_imprime = 1;
                }' $1"/"${Files[$CountFile]};

                echo "Extracting iostat from "$1"/"${Files[$CountFile]};
                awk -v initime=$InitialTime -v fcount=$CountFile 'BEGIN{OFS=","; imprime = 0; disk = 1; count = 0; dcount = 0}{
                        if(imprime > 0){
                                if($0 ~ /Back to top/) exit;
                                if(disk != 0){
                                        if ($1  ~  /hdisk/ && $1 in wrdisk){
                                                print "There are " disk " disk(s). Spliting and formatting data.";
                                                disk = 0;
                                        } else if ($1 ~ /hdisk/){
                                                wrdisk[$1] = "write_"$1;
                                                rddisk[$1] = "read_"$1;
                                                wtdisk[$1] = "wait_"$1;
                                                if (fcount == 0){
                                                        print "date_time,write max service,write avg service" >> wrdisk[$1];
                                                        print "date_time,read max service,read avg service" >> rddisk[$1];
                                                        print "date_time,avg wait time,max wait time" >> wtdisk[$1];
                                                }
                                                disk++;
                                                dcount++;
                                        }
                                }
                                if(imprime > 3 && $1 in wrdisk){
                                        tmp = "date -r " initime " \"+%m/%d/%Y:%H:%M:%S\"";
                                        tmp | getline myepoch
                                        print myepoch, $(10),$8 >> rddisk[$1];
                                        print myepoch, $(16),$(14) >> wrdisk[$1];
                                        print myepoch, $(22), $(21) >> wtdisk[$1];
                                        close(tmp);
                                        close(rddisk[$1]);
                                        close(wrdisk[$1]);
                                        close(wtdisk[$1]);
                                        count++;
                                        if(count == dcount){
                                                count = 0;
                                                initime = initime + 10;
                                        }
                                }
                                imprime++;
                        }
                        if($0 ~ /div id=iostat/) imprime = 1;
                }' $1"/"${Files[$CountFile]}

                CountFile=$(( CountFile + 1 ));
        done
