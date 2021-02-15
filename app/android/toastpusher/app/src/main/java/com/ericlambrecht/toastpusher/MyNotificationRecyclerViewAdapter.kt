package com.ericlambrecht.toastpusher

import androidx.recyclerview.widget.RecyclerView
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView

import com.ericlambrecht.toastpusher.dummy.DummyContent.DummyItem
import com.ericlambrecht.toastpusher.notifications.NotificationItem
import java.time.format.DateTimeFormatter

/**
 * [RecyclerView.Adapter] that can display a [NotificationItem].
 */
class MyNotificationRecyclerViewAdapter(
        private val values: List<NotificationItem>)
    : RecyclerView.Adapter<MyNotificationRecyclerViewAdapter.ViewHolder>() {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view = LayoutInflater.from(parent.context)
                .inflate(R.layout.fragment_notification, parent, false)
        return ViewHolder(view)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val item = values[position]
        val formatter = DateTimeFormatter.ofPattern("MM/dd HH:mm")
        holder.dateView.text = item.date.format(formatter)
        holder.titleView.text = item.title
        holder.bodyView.text = item.body
    }

    override fun getItemCount(): Int = values.size

    inner class ViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val dateView: TextView = view.findViewById(R.id.date)
        val titleView: TextView = view.findViewById(R.id.title)
        val bodyView: TextView = view.findViewById(R.id.body)

        override fun toString(): String {
            return super.toString() + " '" + bodyView.text + "'"
        }
    }
}