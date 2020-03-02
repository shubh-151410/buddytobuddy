package com.example.buddytobuddy;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.app.FlutterApplication;
 import io.flutter.plugin.common.PluginRegistry;
 import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback;
 import io.flutter.plugins.GeneratedPluginRegistrant;
 import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService;

public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
  }

}
