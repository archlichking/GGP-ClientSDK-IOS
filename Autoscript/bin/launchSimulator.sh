#coding=utf-8

SIMU_APP="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/Applications/iPhone Simulator.app"
echo "$1"
if [ ! -z "$1" ]
then
  SIMU_APP=$1
fi
open "$SIMU_APP"
