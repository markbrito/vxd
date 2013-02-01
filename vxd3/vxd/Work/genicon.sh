[A[B$ for i in `ls |grep -v ico `; do echo $i |sed -e 's/\..*//'|XARGS echo "<Icon
Name=\""|sed -e 's/\" /\"/'|sed -e 's/$/\" Image=\"/' |sed -e 's|\ge=\"|ge=\"La
nguages/AltaBPM/Images/'$i'\"/>|'; done
