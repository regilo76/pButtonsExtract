for f in $DataFolder"/"*; do echo "Processing $f file.."; genchart.sh $f | bash; done

gnuplot -persistent -e "n='4'"  -e "filename='$CPUTimeFile'" -e "graphic_title='CPU Time'" -e "max_y_stat=100" /usr/local/bin/plotline.plg > $CPUTimeFile.eps
gnuplot -persistent -e "n='4'"  -e "filename='$CPUUtilizationFile'" -e "graphic_title='CPU Time'" -e "max_y_stat=100" /usr/local/bin/plotline.plg > $CPUUtilizationFile.eps
        #genchart.sh $RunBlockedFile | bash
        #genchart.sh $TotalProcessFile | bash
        #genchart.sh $FreePagesFile | bash
        #genchart.sh $PageInFile | bash
        #genchart.sh $ContextSwitchFile | bash
        #genchart.sh $MgstatFile | bash