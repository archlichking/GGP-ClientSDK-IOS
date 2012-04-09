1. you need the whole folder of GGP_SDK/release and put it in somewhere  
redirect to OFQAAPI_IOS folder and type
`open OFQAAPI.xcodeproj`
2. add necessary bundles to your xcode project  
find OFQASample in your targets, click on "Build Phases" and "Copy Bundle Resources". click on + icon, find all *.bundle files in GGP_SDK/release/resources and add them here
3. set header search paths in xcode 
find OFQASample in your targets, click on "Build Settings" and search Search Paths in search box. set "Always Search User Paths" to Yes, and set GGP_SDK/release/includes in "User Header Search Paths"  
4. add linked library in xcode
find OFQASample in your targets, click on "Build Phases" and "Link Binary With Libraries". click on + icon, find libGreePlatform.a in GGP_SDK/release and add it here  
5. now everything should be ok, click on Run in xcode, and see the magic begins  
