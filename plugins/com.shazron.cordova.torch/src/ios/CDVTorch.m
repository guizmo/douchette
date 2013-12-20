/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import "CDVTorch.h"

@interface CDVTorch (PrivateMethods)

- (void) setup;

@end


@implementation CDVTorch

@synthesize session;

- (CDVPlugin*) initWithWebView:(UIWebView*)theWebView
{
    self = (CDVTorch*)[super initWithWebView:theWebView];
    if (self) {
		[self setup];
    }
    return self;
}

- (void) setup
{
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) 
	{
        AVCaptureDevice* captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([captureDevice hasTorch] && [captureDevice hasFlash] && captureDevice.torchMode == AVCaptureTorchModeOff)
		{
			AVCaptureDeviceInput* deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error: nil];
			AVCaptureVideoDataOutput* videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
			
			AVCaptureSession* captureSession = [[AVCaptureSession alloc] init];
			
			[captureSession beginConfiguration];
			[captureDevice lockForConfiguration:nil];
			
			[captureSession addInput:deviceInput];
			[captureSession addOutput:videoDataOutput];
			
			[captureDevice unlockForConfiguration];
			
#if !__has_feature(objc_arc)
			[videoDataOutput release];
#endif
			
			[captureSession commitConfiguration];
			[captureSession startRunning];
			
			self.session = captureSession;
#if !__has_feature(objc_arc)
			[captureSession release];
#endif
        }
		else {
			NSLog(@"Torch not available, hasFlash: %d hasTorch: %d torchMode: %d", 
				  captureDevice.hasFlash,
				  captureDevice.hasTorch,
				  captureDevice.torchMode
				  );
		}

    }
	else {
		NSLog(@"Torch not available, AVCaptureDevice class not found.");
	}
}

- (void) on:(CDVInvokedUrlCommand*)command
{
	// test if this class even exists to ensure flashlight is turned on ONLY for iOS 4 and above
	Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
	if (captureDeviceClass != nil) {
		
		AVCaptureDevice* captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
		
		[captureDevice lockForConfiguration:nil];
		
		[captureDevice setTorchMode:AVCaptureTorchModeOn];
		[captureDevice setFlashMode:AVCaptureFlashModeOn];
		
		[captureDevice unlockForConfiguration];
        
        if (command != nil) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
	}
}

- (void) off:(CDVInvokedUrlCommand*)command
{
	Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
	if (captureDeviceClass != nil) 
	{
		AVCaptureDevice* captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
		
		[captureDevice lockForConfiguration:nil];
		
		[captureDevice setTorchMode:AVCaptureTorchModeOff];
		[captureDevice setFlashMode:AVCaptureFlashModeOff];
		
		[captureDevice unlockForConfiguration];

        if (command != nil) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
	}
}

- (void) dealloc
{
	[self off:nil];
	self.session = nil;
#if !__has_feature(objc_arc)
	[super dealloc];
#endif
}

@end
