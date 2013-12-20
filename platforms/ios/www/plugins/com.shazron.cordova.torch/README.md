Torch Plugin for Apache Cordova
=====================================
created by Shazron Abdullah

[Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0.html)

Follows the [Cordova Plugin spec](https://github.com/apache/cordova-plugman/blob/master/plugin_spec.md), so that it works with [Plugman](https://github.com/apache/cordova-plugman), or you can install it manually below.
 
2. Add the plugin files **(CDVTorch.h, CDVTorch.m)** in Xcode (add as a group)
3. Add **torch.js** to your **www** folder, and reference it in a script tag, after your cordova.js
4. 
	a. For __Cordova.plist__, under the **'Plugins'** key, add a new row: key is **"Torch"** and the value is **"CDVTorch"**
	
	b. For __config.xml__, under the **&lt;plugins&gt;** tag, add this (deprecated, 2.7.0 and below):
	     
	     <plugin name="Torch" value="CDVTorch" />
	
	c. For __config.xml__, add a new **&lt;feature&gt;** tag (2.8.0 and up):

         <feature name="Torch">
            <param name="ios-package" value="CDVTorch" />
         </feature>

	
6. Add the Framework **"AVFoundation.framework"** in your Build Phases tab of your Project, and set it to be weak linked
    
The plugin's JavaScript functions are called after getting the plugin object thus:
 
        var torch = cordova.require("cordova/plugin/torch");
        torch.on();
        torch.off();
        if (torch.isOn) {
        	// do something
        }
 