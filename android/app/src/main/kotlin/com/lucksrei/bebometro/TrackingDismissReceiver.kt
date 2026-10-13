package com.lucksrei.bebometro

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Runs when the user swipes the notification away (its delete intent). The
 * removal is remembered per outing so the app does not post it again at the
 * next update; an app-side cancel does not trigger this.
 */
class TrackingDismissReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != TrackingNotifier.ACTION_DISMISSED) return
        val id = intent.getStringExtra("outingId") ?: return
        TrackingNotifier.markDismissed(context, id)
    }
}
