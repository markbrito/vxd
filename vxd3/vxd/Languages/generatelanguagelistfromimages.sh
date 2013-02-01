echo VXD ICON LIST VISUAL LANGUAGE XML AND DTD GENERATOR
echo ===================================================
export lang="VisualAltaBPM"
export imgdir="Languages/${lang}/"
echo "(" >langlist.txt
for i in `ls ../${imgdir}Images/*.[gGijb][pciIm][pjofF] |sed -e 's|^.*/||' | sort |uniq `; do echo $i|sed -e 's|\([^\.]*\..*\)|\1|g' |sed -e 's/\([^\.]*\)\.[^\.]*$/\1|/g';done >uniq.txt;cat uniq.txt|sort|uniq > uniqsorted.txt ; cat uniqsorted.txt |tail -1 > tail.txt; cat tail.txt >> uniqsorted.txt; cat tail.txt |tr '|' ' ' > tailtr.txt; cat uniqsorted.txt |sort |uniq -u >> langlist.txt; cat tailtr.txt >>langlist.txt; echo ")" >>langlist.txt
echo
echo -------------
echo LANGUAGE LIST
echo langlist.txt
echo -------------
echo
cat langlist.txt
echo

cat ../${imgdir}${lang}.xml |grep Icon |sed -e 's/" Ima.*//g'|sed -e 's/^.*\"\(.*\)$/\1/g'|grep -v ">"  >iconsLangXML.txt
echo
echo ---------
echo ICONS XML
echo iconsLangXML.txt
echo ---------
echo
cat iconsLangXML.txt |perl -ne 'while(<>){s/^(.*)$/\1 /g;print;}'
grep "ELEMENT" ../${imgdir}${lang}.dtd |sed -e 's/ (.*$//g'|sed -e 's/.*[ ]\(.*\)$/\1/g' >dtdelements.txt
echo
echo ------------
echo DTD ELEMENTS
echo ------------
echo
cat dtdelements.txt
echo
echo -------------------------------
echo XML ICON TO DTD REFERENCE COUNT
echo -------------------------------
echo
for i in `cat iconsLangXML.txt `;do echo $i `grep "^$i$" dtdelements.txt |wc -l`;done > iconsMissingDTD.txt
cat iconsMissingDTD.txt
echo
echo -----------------------------------------
echo IMAGE TO XML ICON AND DTD REFERENCE COUNT
echo -----------------------------------------
echo
for i in `cat langlist.txt |grep -v '(' | grep -v ')'|sed -e 's/|//g'`;do echo $i `grep "^$i$" iconsLangXML.txt |wc -l` `grep "^$i$" dtdelements.txt |wc -l`;done > imagesMissingXMLandDTD.txt
cat imagesMissingXMLandDTD.txt
echo
echo -----------------------
echo ICONS XML CONFIGURATION
echo langicons.txt
echo -----------------------
echo  
for i in `cat langlist.txt |sort |uniq |grep -v '(' |grep -v ')'|sed -e 's/|//g'`; do echo '<Icon Name="'$i'" Image="Languages/'`ls ${lang}/Images/${i}.* |tail -1`'"/>'; done > langicons.txt
#cat langicons.txt
echo
echo ----------
echo EDITOR XML
echo editorxml.txt
echo ----------
echo
for i in `cat langlist.txt |grep -v ")" |grep -v "("|sed -e 's/|//g'`; do echo '<Editor Name="VariableSelector" Class="vxd.Languages.VisualHTML.Editors.VariableSelector" ElementName="ELEMENT" AttributeName="Variable" Type="PANEL"/>' |sed -e 's/ELEMENT/'$i'/'; done > editorxml.txt
#cat editorxml.txt
echo
echo ===============
echo ${lang}_NEW.xml
echo ===============
echo

cat languagexmltemplate.txt | sed -e 's/\[name\]/'${lang}'/g' | sed -e 's|<Icon/>.*|'`cat langicons.txt | sed -e "s/\"/\\\"/g" |sed -e "s/\|/\\\|/g" |xargs echo`'|g' |sed -e 's|<Editor/>.*|'`cat editorxml.txt | sed -e "s/\"/\\\"/g"|sed -e "s/\|/\\\|/g" |xargs echo`'|g' > ${lang}_NEW.xml


echo
echo ===============
echo ${lang}_NEW.dtd
echo ===============
echo
cat languagedtdtemplate.txt >  ${lang}_NEW.dtd
for i in `cat langlist.txt iconsLangXML.txt |sort |uniq -u |grep -v '(' |grep -v ')'|sed -e 's/|//g'`; do echo $i `grep "^$i$" dtdelements.txt |wc -l` |grep -v 1;cat elattr.txt |sed -e 's/Panel\([\" ]\)/'$i'\1/g';done >> ${lang}_NEW.dtd


