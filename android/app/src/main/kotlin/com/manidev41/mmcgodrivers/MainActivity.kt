package com.manidev41.mmcgodrivers

import android.os.Bundle
import androidx.activity.enableEdgeToEdge
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Activer l'affichage bord à bord pour la conformité Android 15 (SDK 35)
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
    }
}
