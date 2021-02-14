package com.ericlambrecht.toastpusher

import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle
import android.util.Log
import com.google.android.material.floatingactionbutton.FloatingActionButton
import com.google.android.material.snackbar.Snackbar
import androidx.appcompat.app.AppCompatActivity
import android.view.Menu
import android.view.MenuItem
import androidx.preference.PreferenceManager
import com.pusher.pushnotifications.PushNotifications;

class MainActivity : AppCompatActivity() {
    private val preferenceChangeListener: SharedPreferences.OnSharedPreferenceChangeListener =
        SharedPreferences.OnSharedPreferenceChangeListener { sharedPreferences: SharedPreferences, s: String ->
            onSharedPreferenceChanged(sharedPreferences, s)
        }

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
        sharedPreferences.registerOnSharedPreferenceChangeListener(preferenceChangeListener)
    }

    fun onSharedPreferenceChanged(sharedPreferences: SharedPreferences, key: String) {
        if (key == "instance_id_setting") {
            Log.i("toastpusher", "Instance ID value was updated to: " + sharedPreferences.getString(key, ""))
        }
        if (key == "interest_setting") {
            Log.i("toastpusher", "Interest value was updated to: " + sharedPreferences.getString(key, ""))
        }
    }

    override fun onResume() {
        super.onResume()
        val sharedPreferences = PreferenceManager.getDefaultSharedPreferences(this)
        Log.i("toastpusher", "registering change listener again")
        sharedPreferences.registerOnSharedPreferenceChangeListener(preferenceChangeListener)
    }

    override fun onPause() {
        super.onPause()
        val sharedPreferences = PreferenceManager.getDefaultSharedPreferences(this)
        Log.i("toastpusher", "unregistering change listener")
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
}