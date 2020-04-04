package net.amond.flutter_mixpanel

import androidx.annotation.NonNull
import android.app.Activity
import android.content.Context
import com.mixpanel.android.mpmetrics.MixpanelAPI
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.common.StandardMethodCodec
import java.io.ByteArrayOutputStream
import java.net.URI
import java.nio.ByteBuffer
import java.nio.charset.Charset
import java.util.*

public class FlutterMixpanelPlugin(
    private var context: Context? = null) : FlutterPlugin, MethodCallHandler {
  var mixpanel: MixpanelAPI? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    val channel = MethodChannel(flutterPluginBinding.binaryMessenger, "net.amond.flutter_mixpanel",
        StandardMethodCodec(MixpanelMessageCodec.instance))
    channel.setMethodCallHandler(FlutterMixpanelPlugin(flutterPluginBinding.applicationContext))
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    mixpanel?.flush()
    //mixpanel = null
    //context = null
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "net.amond.flutter_mixpanel",
          StandardMethodCodec(MixpanelMessageCodec.instance))
      channel.setMethodCallHandler(FlutterMixpanelPlugin(registrar.activity()))
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "initialize" -> {
        context?.let {
          mixpanel = MixpanelAPI.getInstance(context, call.arguments as String);
          return result.success(null)
        }
        return result.error("NOT_INITIALIZED", null, null)
      }
      "track" -> {
        mixpanel?.let {
          val track = call.arguments as Map<String, Any>
          val event = track["event"]!! as String
          val properties = track["properties"] as Map<String, Any>?
          it.track(event, properties?.toMixpanelProperties())
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
          val time = call.arguments as Map<String, Any>
          val event = time["event"] as String
          it.timeEvent(event)
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
          val properties = call.arguments as Map<String, Any>
          //it.people.set(properties.toMixpanelProperties())
          it.people.setMap(properties)
          return result.success(null)
        }
        return result.error("NOT_INITIALIZED", null, null)
      }
      "people.setProperty" -> {
        mixpanel?.let {
          val properties = call.arguments as Map<String, Any>
          val property = properties["property"] as String
          val to = properties["to"]
          it.people.set(property,to)
          return result.success(null)
        }
        return result.error("NOT_INITIALIZED", null, null)
      }
      "people.setOnce" -> {
        mixpanel?.let {
          val properties = call.arguments as Map<String, Any>
          it.people.setOnce(properties.toMixpanelProperties())
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
          val append = call.arguments as Map<String, Any>
          val first = append.entries.first()
          it.people.append(first.key, first.value)
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

  /*
  override fun onDetachedFromActivity() {
    context = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    context = binding.activity
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    context = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    context = null
  }*/
}

public class MixpanelMessageCodec : StandardMessageCodec() {
  companion object {
    @JvmStatic
    val instance = MixpanelMessageCodec()
    @JvmStatic
    val UTF8: Charset = Charset.forName("UTF8")
    @JvmStatic
    val DATE_TIME = 128
    @JvmStatic
    val URI = 129
  }
  override fun writeValue(stream: ByteArrayOutputStream, value: Any?) {
    if (value is Date) {
      stream.write(DATE_TIME)
      writeLong(stream, value.time)
    } else if (value is URI) {
      stream.write(URI)
      writeBytes(stream, value.toString().toByteArray(UTF8))
    }
    super.writeValue(stream, value)
  }

  override fun readValueOfType(type: Byte, buffer: ByteBuffer): Any {
    return when (type) {
      DATE_TIME.toByte() ->
        Date(buffer.long)
      URI.toByte() -> {
        val urlBytes = readBytes(buffer)
        val url = String(urlBytes, UTF8)
        URI(url)
      }
      else -> super.readValueOfType(type, buffer)
    }
  }
}