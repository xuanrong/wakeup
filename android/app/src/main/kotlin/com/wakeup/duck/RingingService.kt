package com.wakeup.duck

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.Ringtone
import android.media.RingtoneManager
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import android.util.Log

/**
 * 前台响铃服务：循环播放鸭叫 + 音量渐增，保持进程存活。
 * MVP：使用系统闹钟铃声兜底（音频素材导入后替换为 raw 资源路径）。
 * 音量策略：起点 30% → 100%，20 秒线性渐增（见设计文档 4.1）。
 */
class RingingService : Service() {

    private var alarmId: String = ""
    private var wakeLock: PowerManager.WakeLock? = null
    private var ringtone: Ringtone? = null
    private var isMuted = false
    private var currentVolume = 0f

    private val mainHandler = Handler(Looper.getMainLooper())
    private val volumeStep = object : Runnable {
        override fun run() {
            if (isMuted || ringtone?.isPlaying != true) return
            fadeStep++
            if (fadeStep > FADE_STEPS) return
            currentVolume = FADE_IN_START + (1f - FADE_IN_START) * (fadeStep.toFloat() / FADE_STEPS)
            ringtone?.volume = currentVolume.coerceIn(0f, 1f)
            mainHandler.postDelayed(this, FADE_STEP_MS)
        }
    }
    private var fadeStep = 0

    override fun onCreate() {
        super.onCreate()
        instance = this
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        alarmId = intent?.getStringExtra("alarmId") ?: ""
        startForeground(ONGOING_ID, buildNotification())
        acquireWakeLock()
        startRinging()
        return START_STICKY
    }

    override fun onDestroy() {
        stopRinging()
        releaseWakeLock()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun startRinging() {
        stopRinging()
        fadeStep = 0
        val uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
        ringtone = RingtoneManager.getRingtone(this, uri)?.apply {
            audioAttributes = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_ALARM)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()
            isLooping = true
        }
        currentVolume = if (isMuted) 0f else FADE_IN_START
        ringtone?.volume = currentVolume
        ringtone?.play()

        if (!isMuted) {
            mainHandler.postDelayed(volumeStep, FADE_STEP_MS)
        }
        Log.i(TAG, "ringing started alarmId=$alarmId")
    }

    private fun stopRinging() {
        mainHandler.removeCallbacks(volumeStep)
        ringtone?.stop()
        ringtone = null
    }

    /** 进入全屏后由 Flutter 接管音效：原生静音待命。 */
    fun muteBackground(muted: Boolean) {
        isMuted = muted
        if (muted) {
            mainHandler.removeCallbacks(volumeStep)
            ringtone?.volume = 0f
        } else if (ringtone?.isPlaying == true) {
            mainHandler.postDelayed(volumeStep, FADE_STEP_MS)
            ringtone?.volume = currentVolume
        }
    }

    /** 任务完成：彻底停止。 */
    fun stopAndDestroy() {
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    private fun acquireWakeLock() {
        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "wakeup:ringing")
        wakeLock?.acquire(5 * 60 * 1000L)
    }

    private fun releaseWakeLock() {
        if (wakeLock?.isHeld == true) wakeLock?.release()
        wakeLock = null
    }

    private fun createNotificationChannel() {
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channel = NotificationChannel(
            CHANNEL_ID,
            "响铃",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "闹钟响铃提醒"
        }
        nm.createNotificationChannel(channel)
    }

    private fun buildNotification(): Notification {
        val contentIntent = PendingIntent.getActivity(
            this, 0,
            Intent(this, MainActivity::class.java),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val builder = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }
        return builder
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle("醒醒鸭")
            .setContentText("闹钟响啦！完成任务才能关掉鸭～")
            .setContentIntent(contentIntent)
            .setOngoing(true)
            .setCategory(Notification.CATEGORY_ALARM)
            .build()
    }

    companion object {
        private const val TAG = "RingingService"
        private const val CHANNEL_ID = "wakeup_ringing"
        private const val ONGOING_ID = 1001
        private const val FADE_IN_START = 0.30f
        private const val FADE_STEPS = 40
        private const val FADE_STEP_MS = 500L

        /** 单例引用，供 AlarmChannel 调 mute/stop。 */
        @Volatile var instance: RingingService? = null
            private set
    }
}
