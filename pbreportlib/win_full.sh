        while [ "$CountFile" -lt "$NumberFiles" ]
        do
		echo "File " $((CountFile + 1)) " out of " $NumberFiles;
		DateTime=$( awk '{ 
			if(imprime == 1){ print $6"_"$8"_"$9"_"$(10); exit;}; 
			if($0 ~ /id="Profile"/) imprime = 1;
		}' $1"/"${Files[$CountFile]});
		echo "**********Verifying date and time:" $DateTime; 
                InitialTime=`date -j -f "%H:%M_%b_%d_%Y." $DateTime +"%s"`

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
                                if(mg_imprime > 3 && $6 != 0){
                                        gsub(/ /, "");
                                        print $1"_"$2, $7 >> mgstat;
				                    	print $1"_"$2, $6 >> physicalread;
				                    	print $1"_"$2, $6 + $(12) + $(14) + $(18) + $(19) >> iorequest;
				                    	print $1"_"$2, $3 + $4 >> globalreference;
                                }
                                mg_imprime++;
                        }
                        if($0 ~ /beg_mgstat/) mg_imprime = 1;
                }' $1"/"${Files[$CountFile]};

                echo "Extracting perfmon data from:" $1"/"${Files[$CountFile]};
                awk -v initime=$InitialTime -v fcount=$CountFile -v folder=$DataFolder"/"$ServerName 'BEGIN{OFS=","}{
                        if($0 ~ /end_win_perfmon/){
				            printf "\n";
				            exit;
			            }
			            
                        if(pm_imprime > 0){
                            if(fcount == 0 && pm_imprime == 1){
                                for(tx=1; tx<=NF; tx++)
                                    text[tx]=$tx;
                                    print text[tx];
                            }
                            
#                            if(pm_imprime == 1){
#                                gsub(/ /, "_"); gsub(/\(/, "_"); gsub(/\)/, "_"); gsub(/\\/, "_");  gsub("/", "_");
 #                               for(tl=2; tl <= NF; tl++){
#                                    
#                                    pm_file[$tl]=folder $tl
#                                }
#                            }
#                            if(fcount == 0 && pm_imprime == 1){
#                                for(col=2; col<=NF; col++){
#                                    print text[1]","text[$col] >> pm_file[$col];
#                                }
#                                    
#                            }
#                            if(vm_imprime > 2 && $1 != "") {
#                                printf "\rprocessing perfmon line: %s", pm_imprime;
#                                gsub(/"/, "");
#                                split($1, pdt, ".")
#					            rdate = gsub(/ /, "_", pdt[1]);
#					            for(res=2; res<=NF; res++){
#					                print rdate, $res >> pm_file[$res];
#					            }
#                           }
                            pm_imprime++;
                        }
                        
                        if($0 ~ /id=perfmon/) pm_imprime = 1;
                }' $1"/"${Files[$CountFile]};


                CountFile=$(( CountFile + 1 ));
        done
        for f in $DataFolder"/"*; do echo "Processing $f file.."; genchart.sh $f | bash; done
        #gnuplot -persistent -e "n='4'"  -e "filename='$CPUTimeFile'" -e "graphic_title='CPU Time'" -e "max_y_stat=100" /usr/local/bin/plotline.plg > $CPUTimeFile.eps
        #gnuplot -persistent -e "n='4'"  -e "filename='$CPUUtilizationFile'" -e "graphic_title='CPU Time'" -e "max_y_stat=100" /usr/local/bin/plotline.plg > $CPUUtilizationFile.eps
        #genchart.sh $RunBlockedFile | bash
        #genchart.sh $TotalProcessFile | bash
        #genchart.sh $FreePagesFile | bash
        #genchart.sh $PageInFile | bash
        #genchart.sh $ContextSwitchFile | bash
        #genchart.sh $MgstatFile | bash
