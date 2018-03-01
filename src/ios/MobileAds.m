#import "Echo.h"
#import <Cordova/CDVPlugin.h>

@implementation Echo

- (void)run:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* message = [command.arguments objectAtIndex:0];

    if (message != nil && [message length] > 0) {
        NSString *answer = @"Plugin received ";
        answer = [answer stringByAppendingString:message];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:answer];
    } else {
        NSString *answer = @"Plugin did not receive parameter.";
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR  messageAsString:answer];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
