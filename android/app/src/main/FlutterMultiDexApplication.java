package io.flutter.app;

import android.content.Context;
import androidx.multidex.MultiDex;
import io.flutter.multidex.FlutterMultiDexApplication;

public class MainApplication extends FlutterMultiDexApplication {
    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        MultiDex.install(this);
    }
}
