package com.carriez.flutter_hbb

import android.app.Activity
import android.os.Bundle
import android.util.Log

class TestActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_test)
        Log.d("Sting","test intent:${intent.extras}")
    }
}