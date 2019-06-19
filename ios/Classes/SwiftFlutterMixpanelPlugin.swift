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
            
            let token = call.arguments as! String;
            print("initialize " + token);
            Mixpanel.initialize(token: token);
            result(token);
            return;
            
          } else if(call.method == "people.setProperties") {
            
            let arguments = call.arguments as! Dictionary<String, Any>;
            let properties = parseProperty(arguments: arguments);
            Mixpanel.mainInstance().people.set(properties: properties);
          } else if(call.method == "people.setProperty") {
            
            let arguments = call.arguments as? Dictionary<String, Any>;
            if ( arguments == nil ) {
                result(false);
                return;
            }
            let properties = parseProperty(arguments: arguments!);
            let property = properties["property"] as! String;
            let to = properties["to"];
            if ( property == nil || to == nil ) {
                result("property must not be null");
                return;
            }

            Mixpanel.mainInstance().people.set(property: property, to: to!);
            result(true);
            
          } else if(call.method == "people.setOnce") {
            let arguments = call.arguments as? Dictionary<String, Any>;
            if ( arguments == nil ) {
                result(false);
                return;
            }
            let properties = parseProperty(arguments: arguments!);
            Mixpanel.mainInstance().people.setOnce(properties: properties );
            result(true);
            
          } else if(call.method == "people.unset") {
            
            let arguments = call.arguments as? Dictionary<String, Any>;
            if ( arguments == nil ) {
                result(false);
                return;
            }
            let properties = parseProperty(arguments: arguments!);
            
            Mixpanel.mainInstance().people.setOnce(properties: properties);
            result(true);
            
          } else if(call.method == "people.increment") {
            
            let arguments = call.arguments as? Dictionary<String, Any>;
            if ( arguments == nil ) {
                result(false);
                return;
            }
            let properties = parseProperty(arguments: arguments!);

            Mixpanel.mainInstance().people.increment(properties: properties);
            
          } else if(call.method == "people.append") {
            
            let arguments = call.arguments as? Dictionary<String, Any>;
            if ( arguments == nil ) {
                result(false);
                return;
            }
            let properties = parseProperty(arguments: arguments!);
            
            Mixpanel.mainInstance().people.append(properties: properties);
            result(true);
          } else if(call.method == "people.union") {
            
            let arguments = call.arguments as? Dictionary<String, Any>;
            if ( arguments == nil ) {
                result(false);
                return;
            }
            let properties = parseProperty(arguments: arguments!);
            
            Mixpanel.mainInstance().people.union(properties: properties);
            result(true);
          } else if(call.method == "people.deleteUser") {
            
            Mixpanel.mainInstance().people.deleteUser();
            result(true);
            
          } else if(call.method == "identify") {
            
            let arguments = call.arguments as? String;
            let distinctId = arguments ?? Mixpanel.mainInstance().distinctId;
            
            Mixpanel.mainInstance().identify(distinctId: distinctId );
            
            result(distinctId);
            
          } else if (call.method == "track") {
            
            let arguments = call.arguments as! Dictionary<String, Any>?;
            if ( arguments == nil ) {
                result("failed");
                return;
            }
            let event = arguments!["__event"] as! String;
            let prop = parseProperty(arguments: arguments!);
            
            Mixpanel.mainInstance().track(event: event, properties: prop);
        
            result(event);
          } else if ( call.method == "flush" ) {
            
            Mixpanel.mainInstance().flush();
            result(true);
            
          } else {
            result(FlutterMethodNotImplemented);
          }

          result(true)
        } catch {
            let _error = error as NSError;
            result([FlutterError( code: String(_error.code), message: _error.domain, details: _error.userInfo  )]);
          print(error.localizedDescription)
            //result(error);

          // result(false)
        }
     }
    
    func parseProperty( arguments : Dictionary<String, Any> ) -> Properties {
        var prop :Dictionary<String, MixpanelType> = [:];
        arguments.filter({ (key: String, value: Any) -> Bool in
            key != "__event"
        }).forEach({ (arg) in
            let (key, value) = arg
            if ( value is String ) {
                prop[key] = value as! String;
            } else if ( value is Int ) {
                prop[key] = value as! Int;
            } else if ( value is UInt ) {
                prop[key] = value as! UInt;
            } else if ( value is Double ) {
                prop[key] = value as! Double;
            } else if ( value is Float ) {
                prop[key] = value as! Float;
            } else if ( value is Bool ) {
                prop[key] = value as! Bool;
            } else if ( value is MixpanelType ) {
                prop[key] = value as? MixpanelType;
            } else if ( value is [String: MixpanelType] ) {
                prop[key] = value as! [String: MixpanelType];
            } else if ( value is URL ) {
                prop[key] = value as! URL;
            } else if ( value is NSNull ) {
                prop[key] = value as! NSNull;
            } else if ( value is NSDictionary ) {
                prop[key] = parseProperty(arguments: value as! Dictionary<String, Any>);
            } else if ( value is Array<String> ) {
                prop[key] = value as! Array<String>;
            } else if ( value is Array<Int> ) {
                prop[key] = value as! Array<Int>;
            } else if ( value is Array<UInt> ) {
                prop[key] = value as! Array<UInt>;
            } else if ( value is Array<Double> ) {
                prop[key] = value as! Array<Double>;
            } else if ( value is Array<Float> ) {
                prop[key] = value as! Array<Float>;
            } else if ( value is Array<Bool> ) {
                prop[key] = value as! Array<Bool>;
            } else if ( value is Array<MixpanelType> ) {
                prop[key] = value as! Array<MixpanelType>;
            } else if ( value is Array<URL> ) {
                prop[key] = value as! Array<URL>;
            }
        });
        return prop;
    }
  }

