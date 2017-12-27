#!/bin/bash
name="Smart App Launcher"
path1=$PWD
path2=/Users/ehaas/Downloads/
path3=/Users/ehaas/Documents/FHIR/IG-tools/
echo "================================================================="
echo === Publish $name IG!!! $(date -u) ===
echo "================================================================="
echo getting rid of .DS_Store files since they gum up the igpublisher....
find . -name '.DS_Store' -type f -delete
sleep 1
git status
sleep 3
echo "================================================================="
echo === create ig.json in ${path1} and ig.xml in ${path1} ===
echo "================================================================="
python3.5 ${path3}definitions.py
sleep 3
echo "================================================================="
echo === run igpublisher ===
echo "================================================================="
java -jar ${path2}org.hl7.fhir.igpublisher.jar -ig ig.json -watch
