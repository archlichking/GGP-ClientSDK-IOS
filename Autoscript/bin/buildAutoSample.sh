#coding=utf-8
# params:
#        $1 : project path
#        $2 : app name
#        $3 : sdk version
#        $4 : simulator locatoin

PROJECT="/Users/thunderzhulei/lay-zhu/ios/OFQAAPI_IOS/QAAutoSample/QAAutoSample.xcodeproj"
#PROJECT="/Users/thunderzhulei/lay-zhu/ios/OFQAAPI_IOS/QAAutoLib/QAAutoLib.xcodeproj"
WORKSPACE="/Users/thunderzhulei/lay-zhu/ios/OFQAAPI_IOS/QAAutomation.xcworkspace"
TARGET="QAAutoSample"
SCHEMA="QAAutoSample"
#TARGET="QAAutoLib"
#AIMSDK="iphonesimulator5.1"
DSTROOT="/Users/thunderzhulei/Library/Application Support/iPhone Simulator/5.1/"
COMMAND="install"

echo "$2"
AIMSDK="iphonesimulator5.0"
if [ ! -z "$2" ]
then
  AIMSDK=$2
fi

echo "$4"
WORKSPACE="/Users/thunderzhulei/lay-zhu/ios/OFQAAPI_IOS/QAAutomation.xcworkspace"
if [ ! -z "$4" ]
then
  WORKSPACE=$4
fi

#xcodebuild -project "$PROJECT" -target "$2" -configuration Debug -sdk "$AIMSDK" DSTROOT="$1/$3" $COMMAND
xcodebuild -workspace "$WORKSPACE" -scheme "$SCHEMA" -configuration Debug -sdk "$AIMSDK" DSTROOT="$1/$3" $COMMAND | grep 'BUILD SUCCEEDED'
exit $?
