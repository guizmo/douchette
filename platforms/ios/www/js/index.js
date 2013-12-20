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
	scanButton: null,
	openStatusLabel: null,
	syncStatusLabel: null,
	resultFormat: null,
	resultValue: null,
	resultFormat1: null,
	resultValue1: null,
	menuContainer: null,
	overlayContainer: null,
	torchButton: null,

	scanOptions: {
		image: false,
		ean8: false,
		ean13: true,
		qrcode: true,
		dmtx: false
	},
	
	scanFlags: {
		useDeviceOrientation: true,
		noPartialMatching: true,
		smallTargetSupport: false
	},

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
        document.addEventListener('rresume', this.onDeviceResume, false);
    },
    // deviceready Event Handler
    //
    // The scope of 'this' is the event. In order to call the 'receivedEvent'
    // function, we must explicity call 'app.receivedEvent(...);'
    onDeviceReady: function() {
        app.receivedEvent('deviceready');

		StatusBar.hide();

		app.scanButton = $('#scanButton');
		app.openStatusLabel = $('#openStatus');
		app.syncStatusLabel = $('#syncStatus');
		app.resultFormat = $('#resultFormat');
		app.resultValue = $('#resultValue');
		app.resultFormat1 = $('#resultFormat1');
		app.resultValue1 = $('#resultValue1');
		app.menuContainer = $('#menuContainer');
		app.overlayContainer = $('#overlayContainer');
		app.torchButton = $('#torchButton');

        app.startScanner();
        
        app.torchToggle();
    },
    onDeviceResume: function() {
        app.receivedEvent('onDeviceResume');
	},
    // Update DOM on a Received Event
    receivedEvent: function(id) {
/*
		StatusBar.styleLightContent();
		StatusBar.backgroundColorByHexString("#80AC3B");
*/
    },
    
    torchToggle: function(){
	    app.torchButton.on('click', function(){	
		    if (torch.isOn) {
		        torch.off();
		    }else{
			    torch.on();
		    }
	    })
    },
    
    startScanner: function(){
		var scanButton = app.scanButton;

        MoodstocksPlugin.open( app.openSuccess, app.openFailure );
	    
	    scanButton.on('click', function(){
		    app.clickScan();
	    });

    },
    
    openSuccess: function(message) {
		app.openStatusLabel.text("Scanner open succeeded.");
		app.scanButton.css('display', 'inline');
	},
	
	openFailure: function(message) {
		app.openStatusLabel.text("Scanner open failed: " + message);
		app.openStatusLabel.css('background', 'red');
		app.scanButton.css('display', 'none');
	},
	
	scannerOff: function() {
		// When scanner is dismissed, display the menu and hide the overlay
		console.log('scannerOff')
		app.overlayContainer.css('display', 'none');
		app.menuContainer.css('display', 'inline');

	},

	scannerOn: function() {
		// When scanner is launched, hide the menu and show the overlay
		app.menuContainer.css('display', 'none');
		app.overlayContainer.css('display', 'inline');
	},

	// Scan callbacks
	scanSuccess: function(format, value) {
		var formatString = JSON.stringify(format),
			valueString = JSON.stringify(value);

		app.resultFormat.text(formatString);
		app.resultValue.text(valueString);
		app.resultFormat1.text(formatString);
		app.resultValue1.text(valueString);

		
		navigator.notification.beep();
		navigator.notification.vibrate();
		
		console.log('scanSuccess')
		
		MoodstocksPlugin.pause(function(){
			console.log('paused')
			MoodstocksPlugin.resume(function(){
				console.log('resume')
			}, function(){
				console.log('failed paused')
			});

		}, function(){
			console.log('failed paused')
		});

	},
	
    scanCancelled: function() {
		console.log('scanCancelled')
		app.scannerOff();
    },

    scanFailure: function(message) {
		console.log('scanFailure')
		app.resultSpan.text(JSON.stringify(message));
    },

     
    clickScan: function() {
    	// Scan button
		console.log('clickScan');

		MoodstocksPlugin.scan(app.scanSuccess, app.scanCancelled, app.scanFailure, app.scanOptions, app.scanFlags);
		
		app.scannerOn();


		/*
		function alertDismissed() {
		    // do something
		}
		
		navigator.notification.alert(
		    'Ce ticket a deja était scanner!',  // message
		    alertDismissed,      				// callback
		    'Erreur',            				// title
		    'Fermer'            				// buttonName
		);
		*/
    }

};
