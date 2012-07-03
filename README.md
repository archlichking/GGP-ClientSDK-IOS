1. Put GGP_SDK somewhere inside OFQAAPI_IOS folder and type `open OFQAAPI.xcodeproj` in terminal.
2. Add necessary bundles to your Xcode project:
   * Find OFQASample in your targets, click on "Build Phases" and "Copy Bundle Resources". 
   * Click on + icon, find all *.bundle files in GGP_SDK/release/resources and add them here.
3. Set header search paths in Xcode:
   * Find OFQASample in your targets, click on "Build Settings" and search "Search Paths" in search box.
   * Set "Always Search User Paths" to "Yes".
   * Set GGP_SDK/release/includes in "User Header Search Paths".
   * Set GGP_SDK/sdk/source/core/authorization in "Header Search Paths"
4. Add linked library in Xcode:
   * Find OFQASample in your targets, click on "Build Phases" and "Link Binary With Libraries". 
   * Click on + icon, find libGreePlatform.a in GGP_SDK/release and add it here.
5. Click on Run in Xcode, and see the magic begins.
