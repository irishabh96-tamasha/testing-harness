package live.tamasha.mobile_app

import android.app.WallpaperManager
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.net.URL

class MainActivity : FlutterActivity() {
    private val wallpaperChannel = "tamasha/wallpaper"
    private val ringtoneChannel = "tamasha/ringtone"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, wallpaperChannel)
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

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ringtoneChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setRingtone" -> {
                        val url = call.argument<String>("url")
                        val title = call.argument<String>("title") ?: "Prabhuji Ringtone"
                        if (url == null) {
                            result.error("ARG", "url is required", null)
                        } else {
                            setRingtone(url, title, result)
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

    /**
     * Set the default device ringtone. Requires the special WRITE_SETTINGS
     * permission; if it isn't granted we open the system screen and return
     * "needs_permission" so the user can grant it and retry. Otherwise downloads
     * the audio into MediaStore and applies it, returning "ok" / "failed".
     */
    private fun setRingtone(url: String, title: String, result: MethodChannel.Result) {
        if (!Settings.System.canWrite(applicationContext)) {
            val intent = Intent(Settings.ACTION_MANAGE_WRITE_SETTINGS)
                .setData(Uri.parse("package:$packageName"))
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
            result.success("needs_permission")
            return
        }
        Thread {
            val r = try {
                val uri = downloadToRingtones(url, title)
                RingtoneManager.setActualDefaultRingtoneUri(
                    applicationContext, RingtoneManager.TYPE_RINGTONE, uri,
                )
                "ok"
            } catch (e: Exception) {
                "failed"
            }
            Handler(Looper.getMainLooper()).post { result.success(r) }
        }.start()
    }

    /** Save [url] into the shared Ringtones collection and return its content URI. */
    private fun downloadToRingtones(url: String, title: String): Uri {
        val resolver = applicationContext.contentResolver
        val fileName = "prabhuji_${title.replace(Regex("[^A-Za-z0-9]"), "_")}.mp3"
        val collection = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            MediaStore.Audio.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
        } else {
            MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
        }
        val values = ContentValues().apply {
            put(MediaStore.Audio.Media.DISPLAY_NAME, fileName)
            put(MediaStore.Audio.Media.TITLE, title)
            put(MediaStore.Audio.Media.MIME_TYPE, "audio/mpeg")
            put(MediaStore.Audio.Media.IS_RINGTONE, 1)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                put(MediaStore.Audio.Media.RELATIVE_PATH, "Ringtones")
            }
        }
        // Replace any prior copy so we don't accumulate duplicates.
        resolver.delete(
            collection,
            "${MediaStore.Audio.Media.DISPLAY_NAME}=?",
            arrayOf(fileName),
        )
        val itemUri = resolver.insert(collection, values)
            ?: throw IllegalStateException("MediaStore insert failed")
        resolver.openOutputStream(itemUri).use { out ->
            URL(url).openStream().use { input -> input.copyTo(out!!) }
        }
        return itemUri
    }
}
