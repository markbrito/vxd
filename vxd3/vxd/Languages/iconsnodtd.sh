for i in `cat icons.txt `;do echo $i `grep $i dtdelements.txt |wc -l` ;done
