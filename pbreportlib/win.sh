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
                                if(mg_imprime >= 3){
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

                echo "Extracting perfmon data from:" $1"/"${Files[$CountFile]};
                awk -F"," -v initime=$InitialTime -v fcount=$CountFile -v folder=$DataFolder"/" 'BEGIN{OFS=","}{
                        if($0 ~ /end_win_perfmon/){
				            printf "\n";
				            exit;
			            }
			            
                        if(pm_imprime > 0){
                            if(pm_imprime == 1){
                                gsub(/\"/, "");
                                gsub(/\\\\/, "");
                                gsub(/\\/, " ");
                                gsub(/\{/, "");
                                gsub(/\}/, "");
                                for(tx=1; tx<=NF; tx++){
                                    text[tx]=$tx;
                                }
                            }
                            
                            if(pm_imprime == 1){
                                gsub(/ /, "_"); 
                                gsub(/\(/, "_"); 
                                gsub(/\)/, "_"); 
                                gsub("/", "_");
                                gsub(/__/, "_");  
                                for(tl=2; tl <= NF; tl++){
                                    pm_file[tl]=folder $tl;
                                }
                            }
                            
                            if(fcount == 0 && pm_imprime == 1){
                                for(col=2; col<=NF; col++){
                                    print text[1]","text[col] >> pm_file[col];
                                    close(pm_file[col]);
                                }
                                    
                            }

                            if(pm_imprime > 2 && $1 != "") {
                                printf "\rprocessing perfmon line: %s", pm_imprime;
                                gsub(/"/, "");
                                split($1, pdt, ".");
					            gsub(/ /, "_", pdt[1]);
					            for(res=2; res<=NF; res++){
					               if($res == "" || $res ~ /[[:digit:]]/){ print pdt[1], $res >> pm_file[res];}
					                close(pm_file[res])
					            }
                           }
                            
                            pm_imprime++;
                        }
                        
                        if($0 ~ /id=perfmon/) pm_imprime = 1;
                }' $1"/"${Files[$CountFile]};

                gzip $1"/"${Files[$CountFile]};
                mv -v $1"/"${Files[$CountFile]}".gz" $ProcessedFolder;

                CountFile=$(( CountFile + 1 ));
        done
