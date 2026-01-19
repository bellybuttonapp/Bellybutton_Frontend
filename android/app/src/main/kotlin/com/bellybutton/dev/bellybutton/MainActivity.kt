package com.bellybutton.dev.bellybutton

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    companion object {
        private const val CHANNEL = "com.bellybutton.dev/deeplink"
        // Store the initial deep link before Flutter engine is ready
        private var initialDeepLink: String? = null
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        // Capture deep link BEFORE super.onCreate() to avoid timing issues
        if (savedInstanceState == null && intent?.data != null) {
            initialDeepLink = intent.data.toString()
            android.util.Log.d("MainActivity", "Deep link captured on cold start: $initialDeepLink")
        }
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Set up method channel for Flutter to retrieve the initial deep link
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialLink" -> {
                    android.util.Log.d("MainActivity", "Flutter requested initial link: $initialDeepLink")
                    result.success(initialDeepLink)
                    // Clear after retrieval to prevent duplicate processing
                    initialDeepLink = null
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)

        // Handle deep links when app is already running
        if (intent.data != null) {
            android.util.Log.d("MainActivity", "Deep link received while running: ${intent.data}")

            flutterEngine?.let { engine ->
                MethodChannel(
                    engine.dartExecutor.binaryMessenger,
                    CHANNEL
                ).invokeMethod("onDeepLink", intent.data.toString())
            }
        }
    }
}
