package com.wakeup.duck

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * 闹钟到点广播接收器：启动前台响铃服务 + 拉起全屏 RingingActivity。
 */
class RingingReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val alarmId = intent.getStringExtra("alarmId") ?: return
        Log.i(TAG, "alarm ring received: $alarmId")

        // 前台服务播放鸭叫 + 保持进程存活
        val serviceIntent = Intent(context, RingingService::class.java)
            .putExtra("alarmId", alarmId)
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            context.startForegroundService(serviceIntent)
        } else {
            context.startService(serviceIntent)
        }

        // 拉起全屏响铃页（内嵌 FlutterView 渲染鸭群动画）
        val full = Intent(context, RingingActivity::class.java)
            .putExtra("alarmId", alarmId)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        context.startActivity(full)
    }

    companion object {
        private const val TAG = "RingingReceiver"
    }
}
