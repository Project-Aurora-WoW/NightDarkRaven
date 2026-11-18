package com.nightdarkraven.launcher

import android.os.Bundle
import android.os.Environment
import android.webkit.JavascriptInterface
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import java.io.File

class MainActivity : AppCompatActivity() {

    private lateinit var webView: WebView
    private lateinit var statusText: TextView
    private lateinit var logText: TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        webView = findViewById(R.id.webView)
        statusText = findViewById(R.id.statusText)
        logText = findViewById(R.id.logText)

        // Настройка WebView
        webView.settings.javaScriptEnabled = true
        webView.settings.domStorageEnabled = true
        webView.settings.allowFileAccessFromFileURLs = true
        webView.settings.allowUniversalAccessFromFileURLs = true
        webView.addJavascriptInterface(AndroidLauncherInterface(this), "AndroidLauncher")
        webView.webViewClient = object : WebViewClient() {
            override fun onPageFinished(view: WebView?, url: String?) {
                log("Веб-лаунчер загружен")
                status("Готов")
            }
        }

        // Загружаем локальный HTML лаунчер (из assets)
        webView.loadUrl("file:///android_asset/www/index.html")

        log("Ночь темного Ворона — Лаунчер v1.1.0")
    }

    private fun log(message: String) {
        runOnUiThread {
            logText.append("[${java.time.LocalTime.now()}] $message\n")
        }
    }

    private fun status(text: String) {
        runOnUiThread { statusText.text = text }
    }

    // JS-интерфейс для вызова из веб-лаунчера
    class AndroidLauncherInterface(private val activity: MainActivity) {
        @JavascriptInterface
        fun patchRealmlist(realm: String, wowPath: String) {
            activity.runOnUiThread {
                activity.log("Патч realmlist: $realm, путь: $wowPath")
                // Запись realmlist.wtf в папку WTF клиента
                val wtfDir = File(wowPath, "WTF")
                if (!wtfDir.exists()) wtfDir.mkdirs()
                val realmFile = File(wtfDir, "realmlist.wtf")
                realmFile.writeText("set realmlist $realm\n")
                activity.log("realmlist.wtf обновлён")
                Toast.makeText(activity, "realmlist.wtf обновлён", Toast.LENGTH_SHORT).show()
            }
        }

        @JavascriptInterface
        fun launchWow(wowPath: String, realm: String) {
            activity.runOnUiThread {
                activity.log("Запуск WoW: $wowPath")
                // Здесь можно запустить WoW.exe через Intent или 명령ную строку
                // (требует корневых прав или эмулятор)
                Toast.makeText(activity, "Запуск WoW...", Toast.LENGTH_SHORT).show()
            }
        }

        @JavascriptInterface
        fun openUrl(url: String) {
            activity.runOnUiThread {
                activity.log("Открытие URL: $url")
                val intent = android.content.Intent(android.content.Intent.ACTION_VIEW)
                intent.data = android.net.Uri.parse(url)
                activity.startActivity(intent)
            }
        }
    }
}