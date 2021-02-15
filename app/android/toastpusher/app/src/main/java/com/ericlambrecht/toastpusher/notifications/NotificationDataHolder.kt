package com.ericlambrecht.toastpusher.notifications

import java.net.URL
import java.time.ZonedDateTime
import java.util.*

object NotificationDataHolder {
    /**
     * An array of notification items.
     */
    private val ITEMS: MutableList<NotificationItem> = ArrayList()

    /**
     * A map of notification items, by ID.
     */
    private val ITEM_MAP: MutableMap<String, NotificationItem> = HashMap()


    init {
        // Add some sample items.
        // TODO: Remove later
        for (i in 1..10) {
            addItem(createNotificationItem(i))
        }
    }

    fun addItem(item: NotificationItem) {
        ITEMS.add(item)
        ITEM_MAP[item.id] = item
    }

    fun getItem(publishId: String): NotificationItem? {
        return ITEM_MAP[publishId]
    }

    fun getItemList(): List<NotificationItem> {
        return ITEMS
    }

    fun getItemMapById(): Map<String, NotificationItem> {
        return ITEM_MAP
    }

    private fun createNotificationItem(position: Int): NotificationItem {
        return NotificationItem(
            position.toString(),
            "Notification " + position,
            "Notification " + position,
            ZonedDateTime.now(),
            URL("http://google.de"),
            NotificationItem.NotificationType.STANDARD
        )
    }

    private fun makeDetails(position: Int): String {
        val builder = StringBuilder()
        builder.append("Details about Item: ").append(position)
        for (i in 0..position - 1) {
            builder.append("\nMore details information here.")
        }
        return builder.toString()
    }
}