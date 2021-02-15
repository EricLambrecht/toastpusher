package com.ericlambrecht.toastpusher.notifications

import android.os.Bundle
import com.google.firebase.messaging.RemoteMessage
import org.json.JSONObject
import java.net.URL
import java.time.ZonedDateTime
import java.time.format.DateTimeFormatter
import java.util.*

/**
 * A notification item representing a piece of content.
 */
data class NotificationItem(
    val id: String,
    val title: String,
    val body: String,
    val date: ZonedDateTime,
    val url: URL?,
    val type: NotificationType
) {
    override fun toString(): String = body

    companion object {
        fun from(intentExtra: Bundle): NotificationItem {
            val pusherDataRaw = intentExtra.getString("pusher")
            if (pusherDataRaw.isNullOrBlank()) {
                throw Exception("Missing 'pusher' key in intentExtra bundle")
            }
            val pusherData = JSONObject(pusherDataRaw)
            val publishID = pusherData.getString("publishId") ?: throw Exception("Cannot find publish id in 'pusher' json")
            val title = intentExtra.getString("title") ?: throw Exception("Could not find title in bundle")
            val body = intentExtra.getString("title") ?: throw Exception("Could not find body in bundle")
            val date = intentExtra.getString("date") ?: throw Exception("Could not find date in bundle")

            val url = intentExtra.getString("url")?.let { URL(it) }
            val typeString = intentExtra.getString("type")
            val typeEnum = typeString?.let { NotificationType.valueOf(it) } ?: NotificationType.STANDARD

            return NotificationItem(
                id = publishID,
                title = title,
                body = body,
                date = ZonedDateTime.parse(date),
                url = url,
                type = typeEnum
            )
        }

        fun from(remoteMessage: RemoteMessage): NotificationItem {
            var data = remoteMessage.data
            val pusherDataRaw = data.get("pusher")
            if (pusherDataRaw.isNullOrBlank()) {
                throw Exception("Missing 'pusher' key in data bundle")
            }
            val pusherData = JSONObject(pusherDataRaw)
            val publishID = pusherData.getString("publishId") ?: throw Exception("Cannot find publish id in 'pusher' json")
            val title = data.get("title") ?: throw Exception("Could not find title in bundle")
            val body = data.get("title") ?: throw Exception("Could not find body in bundle")
            val date = data.get("date") ?: throw Exception("Could not find date in bundle")

            val url = data.get("url")?.let { URL(it) }
            val typeString = data.get("type")
            val typeEnum = typeString?.let { NotificationType.valueOf(it) } ?: NotificationType.STANDARD

            return NotificationItem(
                    id = publishID,
                    title = title,
                    body = body,
                    date = ZonedDateTime.parse(date),
                    url = url,
                    type = typeEnum
            )
        }
    }

    enum class NotificationType(val type: String) {
        STANDARD("standard"),
        MULTIPLE_URL_RESULT("multiple-url-result")
    }
}
