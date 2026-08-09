package com.wakeup.duck

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * 设备重启后恢复闹钟。
 * 简化方案：重启后拉起 MainActivity，Dart 侧启动时会从本地读取全部启用闹钟并重新注册。
 * （AlarmManager 的闹钟在重启后丢失，BOOT_COMPLETED 后需重建。）
 */
class BootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) return
        Log.i(TAG, "boot completed, restoring alarms")

        val launch = Intent(context, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            putExtra("fromBoot", true)
        }
        context.startActivity(launch)
    }

    companion object {
        private const val TAG = "BootReceiver"
    }
}
