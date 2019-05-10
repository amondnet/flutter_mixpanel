import Flutter
import UIKit
import Mixpanel

public class SwiftFlutterMixpanelPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "net.amond.flutter_mixpanel", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterMixpanelPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    do {
          if (call.method == "initialize") {
            Mixpanel.initialize(token: call.arguments as! String)
          } else if(call.method == "people.setProperties") {
            let arguments = call.arguments as! Dictionary<String, MixpanelType>;
            Mixpanel.mainInstance().people.set(properties: arguments);
          } else if(call.method == "people.setProperty") {
            let arguments = call.arguments as! Dictionary<String, MixpanelType>;
            let property = arguments["property"] as! String;
            let to = arguments["to"]!;
            Mixpanel.mainInstance().people.set(property: property, to: to);
          } else if(call.method == "people.setOnce") {
            let arguments = call.arguments as! Dictionary<String, MixpanelType>;
            
            Mixpanel.mainInstance().people.setOnce(properties: arguments );
          } else if(call.method == "people.unset") {
            let arguments = call.arguments as! Properties;
            
            Mixpanel.mainInstance().people.setOnce(properties: arguments);
          } else if(call.method == "people.increment") {
            let arguments = call.arguments as! Properties;
            Mixpanel.mainInstance().people.increment(properties: arguments);
          } else if(call.method == "people.append") {
            let arguments = call.arguments as! Properties;
            Mixpanel.mainInstance().people.append(properties: arguments);
          } else if(call.method == "people.deleteUser") {
            Mixpanel.mainInstance().people.deleteUser();
          } else if(call.method == "identify") {
            let arguments = call.arguments as? String;
            Mixpanel.mainInstance().identify(distinctId: arguments ?? Mixpanel.mainInstance().distinctId );
          } else if (call.method == "track") {
            let arguments = call.arguments as! Properties;
            let event = arguments["__event"] as! String;
            Mixpanel.mainInstance().track(event: event, properties: arguments);
          } else {
            Mixpanel.mainInstance().track(event: call.method)
          }

          result(true)
        } catch {
          print(error.localizedDescription)
          result(false)
        }
     }
  }

