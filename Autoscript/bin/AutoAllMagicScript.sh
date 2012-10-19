#coding=utf-8

#APP_LOCATION="/Users/thunderzhulei/Library/Application Support/iPhone Simulator/"
APP_LOCATION="/Users/thunderzhulei/Library/Developer/Xcode/DerivedData"
echo "$1"
if [ ! -z "$1" ]
then
  APP_LOCATION=$1
fi

echo "$2"
SDK_NAME="iphonesimulator5.0"
#APP_NAME="QAAutoLib"
if [ ! -z "$2" ]
then
  SDK_NAME=$2
fi

echo "$3"
IOS_VERSION="5.0"
if [ ! -z "$3" ]
then
  IOS_VERSION=$3
fi

echo "$4"
APP_NAME="QAAutoSample"
if [ ! -z "$4" ]
then
  APP_NAME=$4
fi

echo "$5"
WORKSPACE="/Users/thunderzhulei/lay-zhu/ios/OFQAAPI_IOS/QAAutomation.xcworkspace"
if [ ! -z "$5" ]
then
  WORKSPACE=$5
fi

SIMULATOR_LOCATION="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/Applications/iPhone Simulator.app"

# 0. build OFQAJenkins
# params : 
sh -x buildAutoSample.sh "$APP_LOCATION" "$SDK_NAME" "$IOS_VERSION" "$WORKSPACE"
if [ $? == 0 ]
# fail if build failed
then
  exit 1
fi
# 1. launch ios simulator with parameters
# params : sim version = 5.1
sh -x launchSimulator.sh "$SIMULATOR_LOCATION"
if [ $? == 0 ]
# fail if simulator launch  failed
then
  exit 1
fi

# 2. launch OFQAJenkins in simulator with parameters.
# params : tcm suite id = 178
#          tcm run id   = 402
sh -x launchAutoSample.sh "$APP_LOCATION" "$APP_NAME" "$IOS_VERSION"
