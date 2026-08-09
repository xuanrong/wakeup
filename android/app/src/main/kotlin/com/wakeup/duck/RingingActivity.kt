package com.wakeup.duck

import android.content.Intent
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

/**
 * 全屏响铃 Activity（原生壳）。
 * 职责：保持屏幕常亮、锁屏显示；返回/Home 关闭在 Dart 响铃页用 PopScope 拦截。
 * 通过 intent extra "alarmId" 传入，冷启动时 AlarmChannel.getStartAlarmId 读取。
 *
 * MVP：复用 FlutterActivity，仅负责亮屏/锁屏展示与传参。
 */
class RingingActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        AlarmChannel.pendingAlarmId = intent.getStringExtra("alarmId")
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        AlarmChannel.register(flutterEngine, applicationContext)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        AlarmChannel.pendingAlarmId = intent.getStringExtra("alarmId")
    }
}
