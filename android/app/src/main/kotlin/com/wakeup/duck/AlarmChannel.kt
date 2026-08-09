package com.wakeup.duck

import android.content.Context
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodCall

/**
 * 原生 ↔ Dart 通信（Channel：com.wakeup.duck/alarm）。
 * 接口表见设计文档 4.4。
 */
object AlarmChannel {
    private const val CHANNEL = "com.wakeup.duck/alarm"
    private const val EVENTS = "com.wakeup.duck/alarm/events"
    private const val TAG = "AlarmChannel"

    /** 待消费的冷启动 alarmId（RingingActivity 传入，getStartAlarmId 读取后清空）。 */
    @Volatile var pendingAlarmId: String? = null

    private var eventSink: EventChannel.EventSink? = null

    fun register(engine: FlutterEngine, context: Context) {
        val method = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
        method.setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
            when (call.method) {
                "scheduleAlarm" -> {
                    val alarmId = call.argument<String>("alarmId") ?: ""
                    val timestamp = call.argument<Number>("timestamp")?.toLong() ?: 0L
                    result.success(AlarmScheduler.schedule(context, alarmId, timestamp))
                }
                "cancelAlarm" -> {
                    val alarmId = call.argument<String>("alarmId") ?: ""
                    result.success(AlarmScheduler.cancel(context, alarmId))
                }
                "getStartAlarmId" -> {
                    val id = pendingAlarmId
                    pendingAlarmId = null
                    result.success(id)
                }
                "stopRinging" -> {
                    RingingService.instance?.stopAndDestroy()
                    result.success(null)
                }
                "muteBackground" -> {
                    val muted = call.arguments as? Boolean ?: false
                    RingingService.instance?.muteBackground(muted)
                    result.success(null)
                }
                "triggerTest" -> {
                    // 开发调试：立即响铃（kDebugMode 下从 Dart 调用）。
                    val alarmId = call.argument<String>("alarmId") ?: "test"
                    val intent = android.content.Intent(context, RingingActivity::class.java)
                        .putExtra("alarmId", alarmId)
                        .addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK)
                    context.startActivity(intent)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        val events = EventChannel(engine.dartExecutor.binaryMessenger, EVENTS)
        events.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
        Log.i(TAG, "channel registered")
    }

    /** App 存活时通知 Dart 推响铃页（当前 MVP 使用冷启动路径，此方法预留）。 */
    fun notifyOnRing(alarmId: String) {
        eventSink?.success(alarmId)
    }
}
