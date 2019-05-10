#import "FlutterMixpanelPlugin.h"
#import <flutter_mixpanel/flutter_mixpanel-Swift.h>

@implementation FlutterMixpanelPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterMixpanelPlugin registerWithRegistrar:registrar];
}
@end
