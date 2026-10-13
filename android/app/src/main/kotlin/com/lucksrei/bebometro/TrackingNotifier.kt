package com.lucksrei.bebometro

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.drawable.Icon
import android.net.Uri
import android.os.Build
import java.text.NumberFormat
import java.util.Locale

/**
 * The "rolê em andamento" notification. One fixed id, so every update replaces
 * the same notification; a silent, low-importance channel; the elapsed time is
 * drawn by the system chronometer (no timer in Dart, no foreground service).
 *
 * It only ever shows what Flutter sent. It never reads or writes the app's
 * records: its actions just open the app with a link, and the app asks for
 * confirmation before registering anything.
 */
object TrackingNotifier {
    const val CHANNEL_ID = "outing_tracking"
    const val NOTIFICATION_ID = 4101
    const val ACTION_LINK = "com.lucksrei.bebometro.TRACKING_LINK"
    const val ACTION_DISMISSED = "com.lucksrei.bebometro.TRACKING_DISMISSED"
    private const val PREFS = "bebometro_tracking"
    private const val KEY_SHOWN = "shown_outing"
    private const val KEY_DISMISSED = "dismissed_outings"

    private fun prefs(ctx: Context) = ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    fun hasPermission(ctx: Context): Boolean =
        Build.VERSION.SDK_INT < 33 ||
            ctx.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) ==
            PackageManager.PERMISSION_GRANTED

    fun enabledInSystem(ctx: Context): Boolean {
        val nm = ctx.getSystemService(NotificationManager::class.java)
        if (!nm.areNotificationsEnabled()) return false
        if (Build.VERSION.SDK_INT >= 26) {
            val ch = nm.getNotificationChannel(CHANNEL_ID)
            if (ch != null && ch.importance == NotificationManager.IMPORTANCE_NONE) return false
        }
        return true
    }

    private fun ensureChannel(ctx: Context) {
        if (Build.VERSION.SDK_INT < 26) return
        val nm = ctx.getSystemService(NotificationManager::class.java)
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Rolê em andamento",
            NotificationManager.IMPORTANCE_LOW,
        ).apply {
            description = "Tempo e contagem do rolê na tela bloqueada. Sem som nem vibração."
            setSound(null, null)
            enableVibration(false)
            enableLights(false)
            setShowBadge(false)
            lockscreenVisibility = Notification.VISIBILITY_PRIVATE
        }
        nm.createNotificationChannel(channel)
    }

    fun shownOuting(ctx: Context): String? = prefs(ctx).getString(KEY_SHOWN, null)

    fun dismissed(ctx: Context): Set<String> =
        prefs(ctx).getStringSet(KEY_DISMISSED, emptySet()) ?: emptySet()

    fun markDismissed(ctx: Context, outingId: String) {
        val set = dismissed(ctx).toMutableSet().apply { add(outingId) }
        prefs(ctx).edit().putStringSet(KEY_DISMISSED, set).remove(KEY_SHOWN).apply()
    }

    fun clearDismissed(ctx: Context, outingId: String) {
        val set = dismissed(ctx).toMutableSet().apply { remove(outingId) }
        prefs(ctx).edit().putStringSet(KEY_DISMISSED, set).apply()
    }

    /** True when the notification is really in the shade right now. */
    fun isShowing(ctx: Context): Boolean {
        val nm = ctx.getSystemService(NotificationManager::class.java)
        return nm.activeNotifications.any { it.id == NOTIFICATION_ID }
    }

    fun cancel(ctx: Context) {
        ctx.getSystemService(NotificationManager::class.java).cancel(NOTIFICATION_ID)
        prefs(ctx).edit().remove(KEY_SHOWN).apply()
    }

    private fun linkIntent(ctx: Context, outingId: String, action: String, code: Int): PendingIntent {
        val intent = Intent(ctx, MainActivity::class.java).apply {
            this.action = ACTION_LINK
            data = Uri.parse("bebometro://outing/$outingId?action=$action")
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        return PendingIntent.getActivity(
            ctx, code, intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
    }

    private fun money(cents: Long): String {
        val f = NumberFormat.getCurrencyInstance(Locale("pt", "BR"))
        return f.format(cents / 100.0).replace(' ', ' ')
    }

    private fun builder(ctx: Context): Notification.Builder =
        if (Build.VERSION.SDK_INT >= 26) Notification.Builder(ctx, CHANNEL_ID)
        else @Suppress("DEPRECATION") Notification.Builder(ctx)

    /** Posts or replaces the notification. Returns "started", "updated" or an error word. */
    fun show(ctx: Context, a: Map<*, *>): String {
        val outingId = a["outingId"] as? String ?: return "error"
        if (!hasPermission(ctx)) return "permissionDenied"
        if (!enabledInSystem(ctx)) return "systemOff"
        if (dismissed(ctx).contains(outingId)) return "dismissed"
        ensureChannel(ctx)

        val startedAt = (a["startedAtMs"] as? Number)?.toLong() ?: System.currentTimeMillis()
        val count = (a["alcoholicCount"] as? Number)?.toInt() ?: 0
        val unpriced = (a["unpricedCount"] as? Number)?.toInt() ?: 0
        val spend = (a["spendCents"] as? Number)?.toLong()
        val place = (a["place"] as? String)?.takeIf { it.isNotBlank() }
        val next = (a["nextLabel"] as? String)?.takeIf { it.isNotBlank() }

        val title = place ?: "Rolê em andamento"
        val countText = when (count) {
            0 -> "Nenhum registro de bebida alcoólica"
            1 -> "1 registro de bebida alcoólica"
            else -> "$count registros de bebida alcoólica"
        }
        val lines = mutableListOf(countText)
        if (spend != null) {
            lines.add(
                if (unpriced > 0) "${money(spend)} informados · $unpriced sem preço"
                else "${money(spend)} informados",
            )
        }

        // What the lock screen shows when the phone hides sensitive content.
        val public = builder(ctx)
            .setSmallIcon(R.drawable.ic_stat_bebometro)
            .setContentTitle("Rolê em andamento")
            .setWhen(startedAt)
            .setUsesChronometer(true)
            .setShowWhen(true)
            .build()

        val nm = ctx.getSystemService(NotificationManager::class.java)
        val first = prefs(ctx).getString(KEY_SHOWN, null) != outingId || !isShowing(ctx)

        val deleteIntent = PendingIntent.getBroadcast(
            ctx, 2,
            Intent(ctx, TrackingDismissReceiver::class.java).apply {
                action = ACTION_DISMISSED
                setPackage(ctx.packageName)
                putExtra("outingId", outingId)
            },
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )

        val b = builder(ctx)
            .setSmallIcon(R.drawable.ic_stat_bebometro)
            .setContentTitle(title)
            .setContentText(lines.joinToString(" · "))
            .setStyle(Notification.BigTextStyle().bigText(lines.joinToString("\n")))
            .setWhen(startedAt)
            .setUsesChronometer(true)
            .setShowWhen(true)
            .setOnlyAlertOnce(true)
            .setAutoCancel(false)
            .setOngoing(false)
            .setCategory(Notification.CATEGORY_STATUS)
            .setVisibility(Notification.VISIBILITY_PRIVATE)
            .setPublicVersion(public)
            .setColor(0xFFF2A81D.toInt())
            .setContentIntent(linkIntent(ctx, outingId, "open", 10))
            .setDeleteIntent(deleteIntent)
        if (Build.VERSION.SDK_INT < 26) {
            @Suppress("DEPRECATION")
            b.setPriority(Notification.PRIORITY_LOW)
        }
        if (next != null) {
            b.addAction(
                Notification.Action.Builder(
                    Icon.createWithResource(ctx, R.drawable.ic_stat_bebometro),
                    "Mais uma · $next",
                    linkIntent(ctx, outingId, "another", 11),
                ).build(),
            )
        }
        b.addAction(
            Notification.Action.Builder(
                Icon.createWithResource(ctx, R.drawable.ic_stat_bebometro),
                "Água",
                linkIntent(ctx, outingId, "water", 12),
            ).build(),
        )

        nm.notify(NOTIFICATION_ID, b.build())
        prefs(ctx).edit().putString(KEY_SHOWN, outingId).apply()
        return if (first) "started" else "updated"
    }
}
