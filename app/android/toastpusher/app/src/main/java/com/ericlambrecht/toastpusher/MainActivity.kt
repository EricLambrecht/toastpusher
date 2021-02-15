package com.ericlambrecht.toastpusher

import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle
import android.util.Log
import android.view.Menu
import android.view.MenuItem
import androidx.appcompat.app.AppCompatActivity
import androidx.preference.PreferenceManager
import com.ericlambrecht.toastpusher.notifications.NotificationDataHolder
import com.ericlambrecht.toastpusher.notifications.NotificationItem
import com.google.android.material.floatingactionbutton.FloatingActionButton
import com.google.android.material.snackbar.Snackbar
import com.google.firebase.messaging.RemoteMessage
import com.pusher.pushnotifications.PushNotificationReceivedListener
import com.pusher.pushnotifications.PushNotifications
import java.lang.Exception
import java.util.*


class MainActivity : AppCompatActivity() {
    private val preferenceChangeListener: SharedPreferences.OnSharedPreferenceChangeListener =
        SharedPreferences.OnSharedPreferenceChangeListener { sharedPreferences: SharedPreferences, s: String ->
            onSharedPreferenceChanged(sharedPreferences, s)
        }

    private val notificationMap: Map<String, NotificationItem> = HashMap()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        setSupportActionBar(findViewById(R.id.toolbar))

        findViewById<FloatingActionButton>(R.id.fab).setOnClickListener { view ->
            Snackbar.make(view, "This will clear the list (soon!)", Snackbar.LENGTH_LONG)
                    .setAction("Clear", null).show()
        }

        val sharedPreferences = PreferenceManager.getDefaultSharedPreferences(this)
        val instanceId = sharedPreferences.getString("instance_id_setting", "")
        val interest = sharedPreferences.getString("interest_setting", "")
        Log.i("toastpusher", "read preferences: $instanceId, $interest")
        if (!instanceId.isNullOrBlank() && !interest.isNullOrBlank()) {
            PushNotifications.start(applicationContext, instanceId)
            PushNotifications.addDeviceInterest(interest)
        }
        try {
            intent.extras?.let {
                val item = NotificationItem.from(it)
                NotificationDataHolder.addItem(item)
            }
        } catch (e: Exception) {
            Log.i(TAG, "Error: $e")
        }
        sharedPreferences.registerOnSharedPreferenceChangeListener(preferenceChangeListener)
    }

    fun onSharedPreferenceChanged(sharedPreferences: SharedPreferences, key: String) {
        if (key == "instance_id_setting") {
            Log.i(TAG, "Instance ID value was updated to: " + sharedPreferences.getString(key, ""))
        }
        if (key == "interest_setting") {
            Log.i(TAG, "Interest value was updated to: " + sharedPreferences.getString(key, ""))
        }
    }

    override fun onResume() {
        super.onResume()
        val sharedPreferences = PreferenceManager.getDefaultSharedPreferences(this)
        Log.i(TAG, "registering change listener again")
        sharedPreferences.registerOnSharedPreferenceChangeListener(preferenceChangeListener)

        PushNotifications.setOnMessageReceivedListenerForVisibleActivity(
            this,
            object : PushNotificationReceivedListener {
                override fun onMessageReceived(remoteMessage: RemoteMessage) {
                    Log.i(TAG, "message received!")
                    try {
                        remoteMessage.let {
                            val item = NotificationItem.from(it)
                            NotificationDataHolder.addItem(item)
                        }
                    } catch (e: Exception) {
                        Log.i(TAG, "Error: $e")
                    }
                }
            })
    }

    override fun onPause() {
        super.onPause()
        val sharedPreferences = PreferenceManager.getDefaultSharedPreferences(this)
        Log.i(TAG, "unregistering change listener")
        sharedPreferences.unregisterOnSharedPreferenceChangeListener(preferenceChangeListener)
    }

    override fun onCreateOptionsMenu(menu: Menu): Boolean {
        // Inflate the menu; this adds items to the action bar if it is present.
        menuInflater.inflate(R.menu.menu_main, menu)
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        return when (item.itemId) {
            R.id.action_settings -> {
                startActivity(Intent(this, SettingsActivity::class.java))
                return true
            }
            else -> super.onOptionsItemSelected(item)
        }
    }

    companion object {
        private const val TAG = "TP-main-activity"
    }
}