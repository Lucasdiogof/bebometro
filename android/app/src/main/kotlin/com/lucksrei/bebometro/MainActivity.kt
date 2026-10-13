package com.lucksrei.bebometro

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var channel: MethodChannel? = null
    private var permissionResult: MethodChannel.Result? = null

    /** A tap on the notification waiting for Flutter to ask for it, once. */
    private var pendingLink: Map<String, String>? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val ch = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "bebometro/tracking")
        channel = ch
        ch.setMethodCallHandler { call, result ->
            try {
                handle(call.method, call.arguments as? Map<*, *>, result)
            } catch (e: Exception) {
                result.error("tracking", e.message, null)
            }
        }
        captureLink(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        if (captureLink(intent)) channel?.invokeMethod("linkReceived", null)
    }

    /** Reads a notification tap once; an already-read intent is ignored. */
    private fun captureLink(intent: Intent?): Boolean {
        if (intent == null || intent.action != TrackingNotifier.ACTION_LINK) return false
        if (intent.getBooleanExtra("tracking_consumed", false)) return false
        intent.putExtra("tracking_consumed", true)
        val uri = intent.data ?: return false
        if (uri.scheme != "bebometro" || uri.host != "outing") return false
        val id = uri.pathSegments.firstOrNull() ?: return false
        pendingLink = mapOf("outingId" to id, "action" to (uri.getQueryParameter("action") ?: "open"))
        return true
    }

    private fun handle(method: String, args: Map<*, *>?, result: MethodChannel.Result) {
        val ctx = applicationContext
        when (method) {
            "capabilities" -> {
                val permission = when {
                    Build.VERSION.SDK_INT < 33 -> "notRequired"
                    TrackingNotifier.hasPermission(ctx) -> "granted"
                    else -> "denied"
                }
                result.success(
                    mapOf(
                        "supported" to true,
                        "permission" to permission,
                        "systemEnabled" to TrackingNotifier.enabledInSystem(ctx),
                    ),
                )
            }
            "requestPermission" -> {
                if (TrackingNotifier.hasPermission(ctx)) {
                    result.success(if (Build.VERSION.SDK_INT < 33) "notRequired" else "granted")
                } else if (permissionResult != null) {
                    result.success("denied")
                } else {
                    permissionResult = result
                    requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), REQUEST_NOTIFICATIONS)
                }
            }
            "sync" -> result.success(TrackingNotifier.show(ctx, args ?: emptyMap<Any, Any>()))
            "end" -> {
                val id = args?.get("outingId") as? String
                val shown = TrackingNotifier.shownOuting(ctx)
                if (id == null || id == shown) TrackingNotifier.cancel(ctx)
                result.success(null)
            }
            "status" -> {
                val shown = TrackingNotifier.shownOuting(ctx)
                val live = shown != null && TrackingNotifier.isShowing(ctx)
                result.success(
                    mapOf(
                        "shown" to if (live) listOf(shown) else emptyList<String>(),
                        "dismissed" to TrackingNotifier.dismissed(ctx).toList(),
                    ),
                )
            }
            "clearDismissed" -> {
                (args?.get("outingId") as? String)?.let { TrackingNotifier.clearDismissed(ctx, it) }
                result.success(null)
            }
            "consumeLink" -> {
                val link = pendingLink
                pendingLink = null
                result.success(link)
            }
            else -> result.notImplemented()
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != REQUEST_NOTIFICATIONS) return
        val granted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
        permissionResult?.success(if (granted) "granted" else "denied")
        permissionResult = null
    }

    companion object {
        private const val REQUEST_NOTIFICATIONS = 4711
    }
}
