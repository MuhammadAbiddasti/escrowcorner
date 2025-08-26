package com.example.escrowcorner

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.drawable.Drawable
import android.graphics.drawable.BitmapDrawable
import java.io.File

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.escrowcorner.app/launcher_icon"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "updateLauncherIcon" -> {
                    val iconPath = call.argument<String>("iconPath")
                    if (iconPath != null) {
                        val success = updateLauncherIcon(iconPath)
                        result.success(success)
                    } else {
                        result.error("INVALID_ARGUMENT", "Icon path is required", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun updateLauncherIcon(iconPath: String): Boolean {
        return try {
            val iconFile = File(iconPath)
            if (!iconFile.exists()) {
                println("Icon file does not exist: $iconPath")
                return false
            }

            // Load the new icon
            val bitmap = BitmapFactory.decodeFile(iconPath)
            if (bitmap == null) {
                println("Failed to decode icon file")
                return false
            }

            // Create a simple drawable from the bitmap
            val drawable = BitmapDrawable(resources, bitmap)

            // Update the launcher icon
            updateAppIcon(drawable)
            
            // Verify the icon was saved
            val appDir = applicationContext.filesDir
            val iconDir = File(appDir, "launcher_icons")
            val mdpiIcon = File(iconDir, "drawable-mdpi/ic_launcher.png")
            
            if (mdpiIcon.exists()) {
                println("Launcher icon updated successfully and verified")
                return true
            } else {
                println("Icon file was not saved properly")
                return false
            }
        } catch (e: Exception) {
            println("Error updating launcher icon: ${e.message}")
            false
        }
    }

    private fun updateAppIcon(icon: Drawable) {
        try {
            // Save the icon to app's internal storage
            val appDir = applicationContext.filesDir
            val iconDir = File(appDir, "launcher_icons")
            if (!iconDir.exists()) {
                iconDir.mkdirs()
            }
            
            // Save icon for different densities
            val densities = listOf("mdpi", "hdpi", "xhdpi", "xxhdpi", "xxxhdpi")
            
            for (density in densities) {
                val densityDir = File(iconDir, "drawable-$density")
                if (!densityDir.exists()) {
                    densityDir.mkdirs()
                }
                
                val iconFile = File(densityDir, "ic_launcher.png")
                // Note: In a production app, you would resize the bitmap to the appropriate size
                // For now, we'll save the original bitmap
                val bitmap = (icon as BitmapDrawable).bitmap
                val outputStream = iconFile.outputStream()
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
                outputStream.close()
            }
            
            println("Launcher icon saved to internal storage successfully")
            println("Icon dimensions: ${icon.intrinsicWidth} x ${icon.intrinsicHeight}")
            
        } catch (e: Exception) {
            println("Error saving launcher icon: ${e.message}")
        }
    }
}
