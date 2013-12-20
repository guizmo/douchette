/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
var app = {
    // Application Constructor
    initialize: function() {
        this.bindEvents();
    },
    // Bind Event Listeners
    //
    // Bind any events that are required on startup. Common events are:
    // 'load', 'deviceready', 'offline', and 'online'.
    bindEvents: function() {
        document.addEventListener('deviceready', this.onDeviceReady, false);
    },
    // deviceready Event Handler
    //
    // The scope of 'this' is the event. In order to call the 'receivedEvent'
    // function, we must explicity call 'app.receivedEvent(...);'
    onDeviceReady: function() {
        app.receivedEvent('deviceready');
        
        app.letsScanThisShit();
    },
    // Update DOM on a Received Event
    receivedEvent: function(id) {
/*
        var parentElement = document.getElementById(id);
        var listeningElement = parentElement.querySelector('.listening');
        var receivedElement = parentElement.querySelector('.received');

        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');

        console.log('Received Event: ' + id);
*/
    },
    
    letsScanThisShit: function(){


	    //function onBodyLoad() {
	      //document.addEventListener("deviceready", onDeviceReady, false);
	
	      scanButton = document.getElementById("scanButton");
	      openStatusLabel = document.getElementById("openStatus");
	      syncStatusLabel = document.getElementById("syncStatus");
	      resultFormat = document.getElementById("resultFormat");
	      resultValue = document.getElementById("resultValue");
	      menuContainer = document.getElementById("menuContainer");
	      overlayContainer = document.getElementById("overlayContainer");
	    //}
	    
	    
	    $('#scanButton').on('click', function(){
		    //alert('test');
		    clickScan();
	    });
		    
	    
	
	     // Sync scanner callbacks
	    function syncInProgress(progress) {
	      syncStatusLabel.innerHTML = "Syncing..." + progress + "%";
	      syncStatusLabel.style.backgroundColor = "#349DF4";
	    }
	
	    function syncFinished() {
	      syncStatusLabel.innerHTML = "Sync finished!";
	      syncStatusLabel.style.backgroundColor = "#80AC3B";
	    }
	
	    function syncFailure(message) {
	      syncStatusLabel.innerHTML = "Sync failed:" + JSON.stringify(message);
	      syncStatusLabel.style.backgroundColor = "red";
	    }
	
	     // Open scanner callbacks
	    function openSuccess(message) {
	      openStatusLabel.innerHTML = "Scanner open succeeded.";
	      scanButton.style.display = "inline";
	      MoodstocksPlugin.sync(null, syncInProgress, syncFinished, syncFailure);
	    }
	
	    function openFailure(message) {
	      openStatusLabel.innerHTML = "Scanner open failed: " + message;
	      openStatusLabel.style.backgroundColor = "red";
	      scanButton.style.display = "none";
	    }
	
	     // When scanner is dismissed, display the menu and hide the overlay
	    function scannerOff() {
	      overlayContainer.style.display = "none";
	      menuContainer.style.display = "inline";
	    }
	
	     // When scanner is launched, hide the menu and show the overlay
	    function scannerOn() {
	      menuContainer.style.display = "none";
	      overlayContainer.style.display = "inline";
	    }
	
	     // Scan callbacks
	    function scanSuccess(format, value) {
	      resultFormat.innerHTML = JSON.stringify(format);
	      resultValue.innerHTML = JSON.stringify(value);
	      MoodstocksPlugin.dismiss(scannerOff, null);
	    }
	
	    function scanCancelled() {
	      scannerOff();
	    }
	
	    function scanFailure(message) {
	      resultSpan.innerHTML = "Scan failure: " + JSON.stringify(message);
	    }
	
	     // Scan button
	    function clickScan() {
	      scanOptions = {
	        image: true,
	        ean8: true,
	        ean13: true,
	        qrcode: true,
	        dmtx: true
	      };
	
	      scanFlags = {
	        useDeviceOrientation: false,
	        noPartialMatching: true,
	        smallTargetSupport: false
	      };
	
	      MoodstocksPlugin.scan(scanSuccess, scanCancelled, scanFailure, scanOptions, scanFlags);
	      scannerOn();
	    }
	
	    function onDeviceReady() {
	      // open the scanner setting your apikey & apisecrect
	      MoodstocksPlugin.open(openSuccess, openFailure);
	    }



    }
};
