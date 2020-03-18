package net.amond.flutter_mixpanel

import org.json.JSONObject

fun Map<String, Any>.toMixpanelProperties(): JSONObject {
  val jsonObject = JSONObject()
  for ((k, v) in this) {
    if (v == "true") {
      jsonObject.put(k, true)
    } else if (v == "false") {
      jsonObject.put(k, false)
    }
    jsonObject.put(k, v)
  }

  return jsonObject
}


data class Track(val event: String, val properties: Map<String, Any>? = null)

data class Time(val event: String)

data class Append(val name: String, val value: Any)

