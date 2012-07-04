1. please download latest GGP SDK (zip) package from jenkins 
2. unzip the package to somewhere, and copy all unzipped files/folders to ios/ggplib_ios folder.  

normally these two steps should be all configurations you are supposed to make  

**just in case you need extra setup if your xcode wont let you play**  

1. go into ios folder and type `open OFQAAPI.xcodeproj` in terminal.  

2. Set header search paths in Xcode:  
   * Find OFQASample in your targets, click on "Build Settings" and search "Search Paths" in search box.  
   * Set "Always Search User Paths" to "Yes".  
   * Set ggplib_ios/release/includes in "User Header Search Paths".  
   * Set ggplib_ios/sdk/source/core/authorization in "Header Search Paths"  
4. Add linked library in Xcode:  
   * Find OFQASample in your targets, click on "Build Phases" and "Link Binary With Libraries".  
   * Click on + icon, find libGreePlatform.a and libGreeWallet.a (if exists) in ggplib_ios/release and add it here.  
5. Click on Run in Xcode, and see the magic begins.  
