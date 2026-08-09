package com.wakeup.duck

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import java.util.Calendar

/**
 * 注册/取消系统级闹钟（AlarmManager.setAlarmClock）。
 * Channel：com.wakeup.duck/alarm → scheduleAlarm / cancelAlarm。
 */
object AlarmScheduler {

    private const val TAG = "AlarmScheduler"

    private fun alarmIntent(context: Context, alarmId: String): PendingIntent {
        val intent = Intent(context, RingingReceiver::class.java).apply {
            action = "com.wakeup.duck.ALARM_RING"
            putExtra("alarmId", alarmId)
        }
        return PendingIntent.getBroadcast(
            context,
            alarmId.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    /**
     * 注册闹钟。timestamp 为毫秒时间戳（下次响铃时刻）。
     * setAlarmClock 可显示系统闹钟图标、绕过部分勿扰。
     */
    fun schedule(context: Context, alarmId: String, timestamp: Long): Boolean {
        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val pi = alarmIntent(context, alarmId)

        val canSchedule = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            am.canScheduleExactAlarms()
        } else true

        val triggerAt = Calendar.getInstance().apply { timeInMillis = timestamp }

        // 精确闹钟授权被拒时降级为 setAlarmClock（不保证精确但尽力）。
        try {
            am.setAlarmClock(
                AlarmManager.AlarmClockInfo(triggerAt.timeInMillis, pi),
                pi
            )
            Log.i(TAG, "scheduled alarmId=$alarmId at $timestamp exact=$canSchedule")
            return true
        } catch (e: Exception) {
            Log.e(TAG, "schedule failed: ${e.message}")
            return false
        }
    }

    fun cancel(context: Context, alarmId: String): Boolean {
        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        am.cancel(alarmIntent(context, alarmId))
        Log.i(TAG, "cancelled alarmId=$alarmId")
        return true
    }
}
