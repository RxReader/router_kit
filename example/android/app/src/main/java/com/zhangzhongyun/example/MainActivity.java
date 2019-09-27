package com.zhangzhongyun.example;

import android.os.Bundle;
import android.text.TextUtils;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    final Registrar registrar = registrarFor("app");
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "app");
    channel.setMethodCallHandler(new MethodChannel.MethodCallHandler() {

      @Override
      public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if (TextUtils.equals(call.method, "getNativeLibraryDir")) {
          result.success(registrar.context().getApplicationInfo().nativeLibraryDir);
        }
      }
    });
  }
}
