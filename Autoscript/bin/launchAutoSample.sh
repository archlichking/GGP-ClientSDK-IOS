#coding=utf-8
# params :
#       $1 : simulator position
#       $2 : app name
#       $3 : simulator version

echo "$1"
APP_PATH_PREFIX="/Users/thunderzhulei/Library/Application Support/iPhone Simulator/"
if [ ! -z "$1" ]
then
  APP_PATH_PREFIX=$1
fi

echo "$2"
APP_NAME="QAAutoSample"
if [ ! -z "$2" ]
then
  APP_NAME=$2
fi

echo "$3"
IOS_VERSION="5.0"
if [ ! -z "$3" ]
then
  IOS_VERSION=$3
fi

../lib/ios-sim/Release/ios-sim launch "$APP_PATH_PREFIX/$IOS_VERSION/Applications/$APP_NAME.app" --args JenkinsMode 
exit 0
