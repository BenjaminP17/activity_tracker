package com.benjamin.activity_tracker

import io.flutter.embedding.android.FlutterFragmentActivity

// FlutterFragmentActivity (not FlutterActivity) is required by the `health`
// plugin: registering the Health Connect permission request launcher needs
// a ComponentActivity/FragmentActivity, otherwise it fails with
// "Permission launcher not found".
class MainActivity : FlutterFragmentActivity()
