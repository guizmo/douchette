/**
 * Copyright (c) 2013 Moodstocks SAS
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "MSScannerController.h"

#import "MSDebug.h"
#import "MSImage.h"

#include "moodstocks_sdk.h"

@implementation MSScannerController

- (id)initWithHandler:(MSHandler *)handler
          scanOptions:(NSInteger)scanOptions
 useDeviceOrientation:(BOOL)useDeviceOrientation
    noPartialMatching:(BOOL)noPartialMatching
   smallTargetSupport:(BOOL)smallTargetSupport
               plugin:(MoodstocksPlugin *)plugin {
    self = [super init];

    if (self) {
        self.handler = handler;
        _scanOptions = scanOptions;
        _useDeviceOrientation = useDeviceOrientation;

        _scannerSession = [[MSScannerSession alloc] initWithScanner:[MSScanner sharedInstance]];
#if MS_SDK_REQUIREMENTS
        [_scannerSession setScanOptions:_scanOptions];
        [_scannerSession setDelegate:self];
        [_scannerSession setUseDeviceOrientation:useDeviceOrientation];
        [_scannerSession setNoPartialMatching:noPartialMatching];
        [_scannerSession setSmallTargetSupport:smallTargetSupport];

        _plugin = plugin;
        _resultOverlay = plugin.webView;
#endif
    }

    return self;
}

- (void)dealloc {
#if !__has_feature(objc_arc)
    [super dealloc];
    [_scannerSession release];
#endif
    self.result = nil;
    self.handler = nil;
}

- (void)loadView {
    [super loadView];

    CGRect scannerFrame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
#if __has_feature(objc_arc)
    _videoPreview = [[UIView alloc] initWithFrame:scannerFrame];
#else
    _videoPreview = [[[UIView alloc] initWithFrame:scannerFrame] autorelease];
#endif
    _videoPreview.backgroundColor = [UIColor blackColor];
    _videoPreview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _videoPreview.autoresizesSubviews = YES;
    [self.view addSubview:_videoPreview];

    // Set up html overlay
    [_resultOverlay setFrame:scannerFrame];
    _originBGColor = _resultOverlay.backgroundColor;
    _resultOverlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    _resultOverlay.opaque = NO;
    _resultOverlay.scrollView.scrollEnabled = NO;

    [self.view addSubview:_resultOverlay];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor = nil;

    CALayer *videoPreviewLayer = [_videoPreview layer];
    [videoPreviewLayer setMasksToBounds:YES];

    AVCaptureVideoPreviewLayer *captureLayer = (AVCaptureVideoPreviewLayer *)[_scannerSession previewLayer];
    [captureLayer setFrame:[_videoPreview bounds]];

    [videoPreviewLayer insertSublayer:captureLayer below:[[videoPreviewLayer sublayers] objectAtIndex:0]];

#if __has_feature(objc_arc)
    _toolbar = [[UIToolbar alloc] init];
#else
    _toolbar = [[[UIToolbar alloc] init] autorelease];
#endif
    _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    _toolbar.barStyle = UIBarStyleBlack;
    _toolbar.tintColor = nil;

#if __has_feature(objc_arc)
    _barButton = [[UIBarButtonItem alloc]
                   initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                   target:self
                   action:@selector(dismissAction)];
#else
    _barButton = [[[UIBarButtonItem alloc]
                   initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                   target:self
                   action:@selector(dismissAction)] autorelease];
#endif

#if __has_feature(objc_arc)
    id flexSpace = [[UIBarButtonItem alloc]
                    initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                    target:nil
                    action:nil];
#else
    id flexSpace = [[[UIBarButtonItem alloc]
                    initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                    target:nil
                    action:nil] autorelease];
#endif

    _toolbar.items = [NSArray arrayWithObjects:_barButton,flexSpace,nil];
    [_toolbar sizeToFit];
    CGFloat toolbarHeight = _toolbar.frame.size.height;
    CGFloat rootViewWidth = CGRectGetWidth(self.view.bounds);
    CGRect rectArea = CGRectMake(0, 0, rootViewWidth, toolbarHeight);
    [_toolbar setFrame:rectArea];

    [self.view addSubview:_toolbar];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_scannerSession startCapture];
}

#pragma mark -
#pragma mark Autorotation setting

- (BOOL)shouldAutorotate {
    if (_useDeviceOrientation)
        return self.presentingViewController.shouldAutorotate;
    else
        return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    if (_useDeviceOrientation)
        return self.presentingViewController.supportedInterfaceOrientations;
    else
        return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (_useDeviceOrientation)
        return YES;
    else
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark

- (void)pause {
    [_scannerSession pause];
}

- (void)resume {
    self.result = nil;
    [_scannerSession resume];
}

- (void)dismissAction {
    [_scannerSession stopCapture];
    [_scannerSession cancel];

    [self.handler scanDismissed];

    _resultOverlay.backgroundColor = _originBGColor;
    _resultOverlay.opaque = YES;
    _resultOverlay.scrollView.scrollEnabled = YES;

    [_resultOverlay removeFromSuperview];

    // insert web view back into the MainViewController
    CGRect mainFrame = CGRectMake(0, 0, CGRectGetWidth(_plugin.viewController.view.bounds),
                                  CGRectGetHeight(_plugin.viewController.view.bounds));
    [_resultOverlay setFrame:mainFrame];
    [_plugin.viewController.view addSubview:_resultOverlay];

    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - MSScannerSessionDelegate

#if MS_SDK_REQUIREMENTS
- (void)session:(MSScannerSession *)scanner didScan:(MSResult *)result {
    if (result != nil){
        if (![self.result isEqualToResult:result]) {
            self.result = nil;
            self.result = result;

            [self pause];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.handler scanResultFound:[result getValue] format:[result getType]];
            });
        }
    }
}

- (void)session:(MSScannerSession *)scanner failedToScan:(NSError *)error {
    MSDLog(@" [MOODSTOCKS SDK] SCAN ERROR: %@", MSErrMsg([error code]));
}

#endif

#pragma mark - Orientation

- (void)viewWillLayoutSubviews
{
    [self updateCaptureWithInterfaceOrientation:self.interfaceOrientation];
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:orientation duration:duration];

    [self updateCaptureWithInterfaceOrientation:orientation];
}

- (void)updateCaptureWithInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    AVCaptureVideoPreviewLayer *captureLayer = (AVCaptureVideoPreviewLayer *) [_scannerSession previewLayer];

    captureLayer.frame = self.view.bounds;

    // AVCapture orientation is the same as UIInterfaceOrientation
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
            [[captureLayer connection] setVideoOrientation:AVCaptureVideoOrientationPortrait];
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            [[captureLayer connection] setVideoOrientation:AVCaptureVideoOrientationPortraitUpsideDown];
            break;
        case UIInterfaceOrientationLandscapeLeft:
            [[captureLayer connection] setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
            break;
        case UIInterfaceOrientationLandscapeRight:
            [[captureLayer connection] setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
            break;
        default:
            break;
    }
}

@end
