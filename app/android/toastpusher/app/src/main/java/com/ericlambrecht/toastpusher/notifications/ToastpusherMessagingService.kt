package com.ericlambrecht.toastpusher.notifications

import android.util.Log
import com.google.firebase.messaging.RemoteMessage
import com.pusher.pushnotifications.fcm.MessagingService

class ToastpusherMessagingService: MessagingService() {
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        Log.i(TAG, "remote message received: $remoteMessage")
        remoteMessage.data.let { data -> Log.i(TAG, "data: $data")}
        remoteMessage.notification.let { notification -> Log.i(TAG, "notification: $notification") }
        remoteMessage.messageType.let { type -> Log.i(TAG, "type: $type")}
    }

    companion object {
        private const val TAG = "TP-Messaging-Service"
    }
}