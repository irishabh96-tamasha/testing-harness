package live.tamasha.mobile_app

import android.app.WallpaperManager
import android.graphics.BitmapFactory
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.net.URL

class MainActivity : FlutterActivity() {
    private val channelName = "tamasha/wallpaper"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setWallpaper" -> {
                        val url = call.argument<String>("url")
                        val location = call.argument<Int>("location") ?: 3
                        if (url == null) {
                            result.error("ARG", "url is required", null)
                        } else {
                            setWallpaper(url, location, result)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /** Download [url] off the main thread and apply it via WallpaperManager. */
    private fun setWallpaper(url: String, location: Int, result: MethodChannel.Result) {
        Thread {
            val ok = try {
                val bitmap = URL(url).openStream().use { BitmapFactory.decodeStream(it) }
                val wm = WallpaperManager.getInstance(applicationContext)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    val which = when (location) {
                        1 -> WallpaperManager.FLAG_SYSTEM
                        2 -> WallpaperManager.FLAG_LOCK
                        else -> WallpaperManager.FLAG_SYSTEM or WallpaperManager.FLAG_LOCK
                    }
                    wm.setBitmap(bitmap, null, true, which)
                } else {
                    @Suppress("DEPRECATION")
                    wm.setBitmap(bitmap)
                }
                true
            } catch (e: Exception) {
                false
            }
            Handler(Looper.getMainLooper()).post { result.success(ok) }
        }.start()
    }
}
