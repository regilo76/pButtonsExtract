for f in $DataFolder"/"*; do 
    echo "Calculate standard deviation on $f file..";
    COLUMNS=$(head -1 $f | awk -F"," '{ print NF}');
    awk -F"," -v col=$COLUMNS '
        BEGIN{
            count=1;
            OFS=",";
            for ( i=2; i<=col; i++){
                a[i]=0;
            }
        
        }{
        if(NR==1){
            print $0;
        } else {
            if(count<20){
                for (i=2; i<=col; i++){
                    a[i]=a[i] + $i;
                }
                count++;
            } else {
                printf "%s,", $1;
                for (i=2; i<=col; i++){
                    a[i]=(a[i]+$i)/20;
                    if (i<col){
                        printf "%s,", a[i];
                    } else {
                        printf "%s\n", a[i];
                    }
                }
                count=0;
            }
        }
    }' $f > $f"_Standard_Deviation"

    if [ "$?" == "0" ]; then
        echo "Standard deviation for " $f " is complete."
    else
        echo "It was not possible to calculate standard deviation for " $f "."
        exit 1
    fi
done