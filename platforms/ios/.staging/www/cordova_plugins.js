cordova.define('cordova/plugin_list', function(require, exports, module) {
module.exports = [
    {
        "file": "plugins/com.moodstocks.phonegap/www/MoodstocksPlugin.js",
        "id": "com.moodstocks.phonegap.MoodstocksPlugin",
        "clobbers": [
            "MoodstocksPlugin"
        ]
    },
    {
        "file": "plugins/org.apache.cordova.statusbar/www/statusbar.js",
        "id": "org.apache.cordova.statusbar.statusbar",
        "clobbers": [
            "window.StatusBar"
        ]
    },
    {
        "file": "plugins/org.apache.cordova.device/www/device.js",
        "id": "org.apache.cordova.device.device",
        "clobbers": [
            "device"
        ]
    },
    {
        "file": "plugins/org.apache.cordova.dialogs/www/notification.js",
        "id": "org.apache.cordova.dialogs.notification",
        "merges": [
            "navigator.notification"
        ]
    },
    {
        "file": "plugins/org.apache.cordova.vibration/www/vibration.js",
        "id": "org.apache.cordova.vibration.notification",
        "merges": [
            "navigator.notification"
        ]
    },
    {
        "file": "plugins/org.apache.cordova.splashscreen/www/splashscreen.js",
        "id": "org.apache.cordova.splashscreen.SplashScreen",
        "clobbers": [
            "navigator.splashscreen"
        ]
    }
];
module.exports.metadata = 
// TOP OF METADATA
{
    "com.moodstocks.phonegap": "1.0.0",
    "org.apache.cordova.statusbar": "0.1.3",
    "org.apache.cordova.device": "0.2.5",
    "org.apache.cordova.dialogs": "0.2.4",
    "org.apache.cordova.vibration": "0.3.5",
    "org.apache.cordova.splashscreen": "0.2.5",
    "com.shazron.cordova.torch": "1.0.0"
}
// BOTTOM OF METADATA
});