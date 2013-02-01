for i in `ls System*`; do  echo $i | sed -e 's/\./_/g'| sed -e 's/^\(.*\)_\(...\)$/\1\.\2/'|xargs mv $i ; done
