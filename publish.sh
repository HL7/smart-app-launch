#!/bin/bash
name="Smart App Launcher"
path1=$PWD
path2=/Users/ehaas/Downloads/
echo "================================================================="
echo === Publish $name IG!!! $(date -u) ===
echo === run bash publish2.sh to update ig.json ===
echo === ig.json needs to be in ${path1} ===
echo "================================================================="
# get rid of .DS_Store files since they gum up the igpublisher
find . -name '.DS_Store' -type f -delete
git status
echo "================================================================================="
echo === run igpublisher - to run without a terminology server use the '-tx N/A' option ===
echo "================================================================================"
java -jar ${path2}org.hl7.fhir.igpublisher.jar -ig ig.json -watch -tx N/A
