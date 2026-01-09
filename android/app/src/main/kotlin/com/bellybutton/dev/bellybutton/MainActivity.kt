package com.bellybutton.dev.bellybutton

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        // Log deep link on cold start for debugging
        if (savedInstanceState == null && intent?.data != null) {
            android.util.Log.d("MainActivity", "Deep link detected on cold start: ${intent.data}")
        }
        super.onCreate(savedInstanceState)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)

        // CRITICAL: Update the activity's intent so app_links can access it
        // Without this, the Flutter side cannot retrieve the new deep link
        setIntent(intent)

        // Handle deep links when app is already running
        if (intent.data != null) {
            android.util.Log.d("MainActivity", "Deep link received while running: ${intent.data}")

            // Send intent to Flutter engine via MethodChannel for immediate processing
            flutterEngine?.let { engine ->
                io.flutter.plugin.common.MethodChannel(
                    engine.dartExecutor.binaryMessenger,
                    "bellybutton/deep_link"
                ).invokeMethod("onDeepLink", intent.data.toString())
                android.util.Log.d("MainActivity", "Deep link sent to Flutter: ${intent.data}")
            }
        }
    }
}
