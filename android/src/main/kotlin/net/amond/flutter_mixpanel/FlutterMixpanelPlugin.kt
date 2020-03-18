package net.amond.flutter_mixpanel

import android.app.Activity
import com.mixpanel.android.mpmetrics.MixpanelAPI
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import org.json.JSONObject

class FlutterMixpanelPlugin : MethodCallHandler, ActivityAware {
  var activity: Activity? = null
  var mixpanel: MixpanelAPI? = null

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "net.amond.flutter_mixpanel")
      channel.setMethodCallHandler(FlutterMixpanelPlugin())
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "initialize" -> {
        activity?.let {
          mixpanel = MixpanelAPI.getInstance(activity, call.arguments as String);
          return result.success(null)
        }
        return result.error("NOT_INITIALIZED", null, null)
      }
      "track" -> {
        mixpanel?.let {
          val track = call.arguments as Track
          it.track(track.event, track.properties?.toMixpanelProperties())
          return result.success(null)
        }
        return result.error("NOT_INITIALIZED", null, null)
      }
      "identify" -> {
        mixpanel?.let {
          val distinctId = call.arguments as String
          it.identify(distinctId)
          return result.success(null)
        }
        return result.error("NOT_INITIALIZED", null, null)
      }
      "time" -> {
        mixpanel?.let {
          val time = call.arguments as Time
          it.timeEvent(time.event)
          return result.success(null)
        }
        return result.error("NOT_INITIALIZED", null, null)
      }
      "flush" -> {
        mixpanel?.let {
          it.flush()
          return result.success(null)
        }
        return result.error("NOT_INITIALIZED", null, null)
      }
      "people.setProperties" -> {
        mixpanel?.let {
          val properties = call.arguments as Map<String, Any>?
          it.people.set(properties?.toMixpanelProperties())
          return result.success(null)
        }
        return result.error("NOT_INITIALIZED", null, null)
      }
      "people.setOnce" -> {
        mixpanel?.let {
          val properties = call.arguments as Map<String, Any>?
          it.people.setOnce(properties?.toMixpanelProperties())
          return result.success(null)
        }
        return result.error("NOT_INITIALIZED", null, null)
      }
      "people.unset" -> {
        mixpanel?.let {
          val name = call.arguments as String
          it.people.unset(name)
          return result.success(null)
        }
        return result.error("NOT_INITIALIZED", null, null)
      }
      "people.append" -> {
        mixpanel?.let {
          val append = call.arguments as Append
          it.people.append(append.name, append.value)
          return result.success(null)
        }
        return result.error("NOT_INITIALIZED", null, null)
      }
      "people.increment" -> {
        mixpanel?.let {
          val increment = call.arguments as Map<String, out Number>
          it.people.increment(increment)
          return result.success(null)
        }
        return result.error("NOT_INITIALIZED", null, null)
      }
      else -> {
        return result.notImplemented()
      }
    }
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }
}
