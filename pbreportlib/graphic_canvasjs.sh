for f in $DataFolder"/"*; do 
    graphicFile=$(echo $f | awk -F"/" '{print $NF}')
    echo "Processing "$f" file to "$graphicFolder"/"$graphicFile".html";
    
    echo "<!DOCTYPE HTML>" > $graphicFolder"/"$graphicFile".html"
    echo "<html>" >> $graphicFolder"/"$graphicFile".html" 
    echo "<head>" >> $graphicFolder"/"$graphicFile".html"
    echo "  <script src=\"./canvasjs.min.js\"></script>" >> $graphicFolder"/"$graphicFile".html"
    echo "  <script type=\"text/javascript\">" >> $graphicFolder"/"$graphicFile".html"
    echo "  window.onload = function () {" >> $graphicFolder"/"$graphicFile".html"

    echo "    var chart = new CanvasJS.Chart(\"chartContainer\"," >> $graphicFolder"/"$graphicFile".html"
    echo "    {" >> $graphicFolder"/"$graphicFile".html"
    echo "      zoomEnabled: true," >> $graphicFolder"/"$graphicFile".html" 
    echo "  title:{" >> $graphicFolder"/"$graphicFile".html"
    echo "        text: \"Try Zooming And Panning\"," >> $graphicFolder"/"$graphicFile".html" 
    echo "        fontSize: 20"
    echo "      }," >> $graphicFolder"/"$graphicFile".html"
    echo "      exportEnabled: true," >> $graphicFolder"/"$graphicFile".html"
    echo "      axisY:{" >> $graphicFolder"/"$graphicFile".html"
    echo "        includeZero: false" >> $graphicFolder"/"$graphicFile".html"
    echo "      }," >> $graphicFolder"/"$graphicFile".html"
    echo "      data: [" >> $graphicFolder"/"$graphicFile".html"              
    
    total=`printf "%d\n" $(wc -l < $f)`
    qtDataPoints=$(head -1 $f | awk -F"," '{print NF}');
    counter=2;
    while [ $counter -le $qtDataPoints ]; do
        awk -F"," -v total=$total -v turn=$counter '{
            if (NR==1){
                print  "{ type: \"line\", showInLegend: true, legendText: \"" $turn "\", dataPoints: ["
            } else if (NR<total){
                print"{ label:\"" $1 "\", y: " $turn "},"
            } else {
                print"{ label:\"" $1 "\", y: " $turn "}]}"
            }
        }' $f >> $graphicFolder"/"$graphicFile".html"
        if [ $counter -lt $qtDataPoints ]; then
            echo "," >> $graphicFolder"/"$graphicFile".html";
        fi
        let counter=counter+1;
    done

    echo "		]" >> $graphicFolder"/"$graphicFile".html"
      
    echo "   });" >> $graphicFolder"/"$graphicFile".html"

    echo "    chart.render();" >> $graphicFolder"/"$graphicFile".html"
    echo "  }" >> $graphicFolder"/"$graphicFile".html"
  
    echo "  </script>" >> $graphicFolder"/"$graphicFile".html"
    echo "  <body>" >> $graphicFolder"/"$graphicFile".html"
    echo "    <div id=\"chartContainer\" style=\"height: 300px; width: 100%;\">" >> $graphicFolder"/"$graphicFile".html"
    echo "    </div>" >> $graphicFolder"/"$graphicFile".html"
    echo "  </body>" >> $graphicFolder"/"$graphicFile".html"
    echo "  </html>" >> $graphicFolder"/"$graphicFile".html"
    
done

#Removing pre-existing percent files to create new ones
rm -v $graphicFolder/*_percent.html;

percentFiles=$(ls $graphicFolder/*cpu*.html $graphicFolder/*utilization*.html);

for f in $percentFiles; do
    NAME=${f%.html}
    echo "Adjusting file $f to max Y to 100%. Results in file: " $NAME"_percent.html"
    awk '{sub("axisY:{","axisY:{\n\tmaximum: 100,"); print $0}' $f > $NAME"_percent.html"
done
