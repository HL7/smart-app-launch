#!/bin/bash
echo PUSH $(date -u)
git status
git add .
git status
git commit
git push

echo " ----- upload output to smart app viewer and push----------- "

cp -R output/* ../smart-app-launch-viewer/docs
cd ../smart-app-launch-viewer
echo PUSH $(date -u)
git status
git add .
git status
git commit
git push
