all:
	javac -g -cp .. -nowarn -source 1.4 `find . -name '*.java'|grep -v bak` 2>&1 | head -20


clean:
	find . -name '*.class'|xargs rm -f


run:
	java -cp .. vxd.vxd

runeditor: 
	../XMLEditor/bin/Debug/XMLEditor.exe Config/vxd.xml

runaltabpmeditor:
	../XMLEditor/bin/Debug/XMLEditor.exe Languages/VisualAltaBPM/VisualAltaBPM.xml

cleancvs:
	find .. -name 'CVS'|xargs rm -rf


deletecvs:
	rm -rf /cvs/src; mkdir /cvs/src; cvs init


importcvs:
	find . -name '*.class'|xargs rm -f ; cd .. ; cvs import VisualXMLDesigner vxd init


checkoutcvs:
	cvs checkout VisualXMLDesigner VisualXMLDesigner/vxd


commitcvs:
	cvs commit


helpcvs:
	cvs --help-commands


changedcvs:
	cvs status -l |grep Status |grep -v Up
