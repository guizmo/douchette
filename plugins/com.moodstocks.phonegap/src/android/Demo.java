/*
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

package com.moodstocks.phonegap.demo;

import org.apache.cordova.Config;
import org.apache.cordova.CordovaActivity;
import org.apache.cordova.CordovaChromeClient;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebViewClient;
import org.apache.cordova.IceCreamCordovaWebViewClient;

import android.content.Intent;
import android.os.Bundle;
import android.view.ViewManager;

import com.moodstocks.phonegap.plugin.MoodstocksWebView;

/**
 * This is a sample file of Cordova's main activity for PhoneGap 3.1+. DroidGap
 * class is deprecated and replaced by CordovaActivity.
 * <p>
 * To make sure that our plugin runs normally, remember to replace the
 * {@code super.init()} by {@code this.init()}.
 *
 */
public class Demo extends CordovaActivity {

  private boolean scanActivityStarted = false;

  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    this.init();
    // Set by <content src="index.html" /> in config.xml
    super.loadUrl(Config.getStartUrl());
    //super.loadUrl("file:///android_asset/www/index.html")
  }

  @Override
  public void init() {
    MoodstocksWebView webView = new MoodstocksWebView(this);
    webView.setBackgroundColor(0x00000000);
    CordovaWebViewClient webViewClient;

    if (android.os.Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.HONEYCOMB) {
      webViewClient = new CordovaWebViewClient(this, webView);
    } else {
      webViewClient = new IceCreamCordovaWebViewClient(this, webView);
    }

    super.init(webView, webViewClient, new CordovaChromeClient(this,
        webView));
  }

  @Override
  public void onPause() {
    super.onPause();

    // Remove the web view from the root view during launching
    if (scanActivityStarted) {
      super.root.removeView(super.appView);
    }
  }

  @Override
  public void onResume() {
    super.onResume();

    // this case is occurred when the scanActivity fails at launching
    // the failure of launching scanner is often caused by the camera's
    // unavailability in this case we retrieve & reload the web view before
    // inserting it back
    if (scanActivityStarted && (super.appView.getParent() != null)) {
      ((ViewManager) super.appView.getParent()).removeView(super.appView);
      super.appView.reload();
    }

    // Reset the web view to root container after dismissing
    if (scanActivityStarted && (super.appView.getParent() == null)) {
      super.root.addView(super.appView);
      scanActivityStarted = false;
    }
  }

  @Override
  public void startActivityForResult(CordovaPlugin command, Intent intent,
      int requestCode) {
    // If the intent indicate the activity is a MoodtsocksScanActivity,
    // launch the activity and keep the js/native code running onbackground
    if (intent.getExtras().getString("com.moodstocks.phonegap.plugin") != null) {
      if (intent.getExtras().getString("com.moodstocks.phonegap.plugin")
          .equals("MoodstocksScanActivity")) {
        scanActivityStarted = true;
        this.startActivityForResult(intent, requestCode);
      }
    } else {
      super.startActivityForResult(command, intent, requestCode);
    }
  }
}
