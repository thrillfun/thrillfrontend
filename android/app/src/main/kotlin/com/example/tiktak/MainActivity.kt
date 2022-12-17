package com.example.tiktak
import com.thrill.media.NativeConfigurationInjection
import ly.img.android.pesdk.backend.model.state.manager.StateHandler
import ly.img.android.pesdk.ui.model.state.UiConfigMainMenu
import io.flutter.embedding.android.FlutterActivityLaunchConfigs
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.util.GeneratedPluginRegister


class MainActivity: FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegister.registerGeneratedPlugins(flutterEngine)
    }

    override fun getBackgroundMode(): FlutterActivityLaunchConfigs.BackgroundMode {
        return FlutterActivityLaunchConfigs.BackgroundMode.transparent
    }
    companion object {
        init {
            StateHandler.replaceStateClass(UiConfigMainMenu::class.java, NativeConfigurationInjection::class.java)
        }
    }
}
