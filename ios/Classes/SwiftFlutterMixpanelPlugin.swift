import Flutter
import UIKit
import Mixpanel

func getFlutterError(error: NSError?) -> FlutterError? {
    if ( error == nil ) {
        return nil;
    } else {
        return FlutterError(code: String(format: "%ld", error!.code), message: error!.domain, details: error!.localizedDescription)
    }
    
}


let DATE_TIME: UInt8 = 128
let URI: UInt8 = 129
let BOOL_TRUE: UInt8 = 1
let BOOL_FALSE: UInt8 = 2

public class MixpanelReader : FlutterStandardReader {
    public override func readValue(ofType type: UInt8) -> Any? {
        switch type {
            case DATE_TIME:
                var value: Int64 = 0
                readBytes(&value, length: 8)
                return Date(timeIntervalSince1970: TimeInterval(value / 1000 ))
            case URI:
                let urlString = readUTF8()
                return URL(string: urlString)
            case BOOL_TRUE:
                return true
            case BOOL_FALSE:
                return false
            default:
                return super.readValue(ofType: type)
        }
    }
}

public class MixpanelWriter : FlutterStandardWriter {
    override public func writeValue(_ value: Any) {
        if ( value is Date ) {
            writeByte(DATE_TIME)
            let date = value as! Date
            let time = date.timeIntervalSince1970
            var ms = time * 1000.0
            writeBytes(&ms, length: 8)
        } else if ( value is URL ) {
            let url = value as! URL
            let urlString = url.absoluteString
            writeByte(URI)
            writeUTF8(urlString)
        } else if (value is Bool ) {
            if ( value ) as! Bool {
                writeByte(BOOL_TRUE)
            } else {
                writeByte(BOOL_FALSE)
            }
        }
        else {
            super.writeValue(value)
        }
    }
}

public class MixpanelReaderWriter : FlutterStandardReaderWriter {
    public override func writer(with data: NSMutableData) -> FlutterStandardWriter {
        return MixpanelWriter(data: data)
    }
    public override func reader(with data: Data) -> FlutterStandardReader {
        return MixpanelReader(data: data)
    }
}



public class SwiftFlutterMixpanelPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let readWriter = MixpanelReaderWriter()
    //let readWriter = FlutterStandardReaderWriter()
    let codec = FlutterStandardMethodCodec(readerWriter: readWriter)
    let channel = FlutterMethodChannel(name: "net.amond.flutter_mixpanel", binaryMessenger: registrar.messenger(), codec: codec)

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
            let property = properties["property"] as? String;
            let to = properties["to"];
            if ( property == nil || to == nil ) {
                result("property must not be null");
                return;
            }

            Mixpanel.mainInstance().people.set(property: property!, to: to!);
            result(true);
            
          } else if(call.method == "people.identify") {
            let arguments = call.arguments as? String;
                      let distinctId = arguments ?? Mixpanel.mainInstance().distinctId;
                      
                      Mixpanel.mainInstance().identify(distinctId: distinctId );
                      
                      result(distinctId);
                     
          }
          else if(call.method == "people.setOnce") {
            let arguments = call.arguments as? Dictionary<String, Any>;
            if ( arguments == nil ) {
                result(false);
                return;
            }
            let properties = parseProperty(arguments: arguments!);
            Mixpanel.mainInstance().people.setOnce(properties: properties );
            result(true);
            
          } else if(call.method == "people.unset") {
            
            let arguments = call.arguments as? [String];
            if ( arguments == nil ) {
                result(false);
                return;
            }
            
            Mixpanel.mainInstance().people.unset(properties: arguments!);
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
            let prop = parseProperty(arguments: arguments!);
            let event = prop["event"] as! String;

            Mixpanel.mainInstance().track(event: event, properties: prop["properties"] as? Properties);
        
            result(event);
          } else if (call.method == "time") {
            
            let arguments = call.arguments as! Dictionary<String, Any>?;
            if ( arguments == nil ) {
                result("failed");
                return;
            }
            let event = arguments!["event"] as! String;
            
            Mixpanel.mainInstance().time(event: event);
            
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
                let stringValue = value as! String
                if ( stringValue == "true" ) {
                    prop[key] = true
                } else if ( stringValue == "false" ) {
                    prop[key] = false
                } else {
                    prop[key] = stringValue;
                }
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
                let parse = parseProperty(arguments: value as! Dictionary<String, Any>)
                prop[key] = parse;
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

