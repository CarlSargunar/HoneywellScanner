#import <Cordova/CDVPlugin.h>
#import "Captuvo.h"

//------------------------------------------------------------------------------
// plugin definition
//------------------------------------------------------------------------------
@interface CDVHoneywellScanner : CDVPlugin <CaptuvoEventsProtocol>
@property (nonatomic, retain) NSString* callbackId;
- (void)registerCallback:(CDVInvokedUrlCommand*)command;
- (void)trigger:(CDVInvokedUrlCommand*)command;
@end

//------------------------------------------------------------------------------
// plugin internals
//------------------------------------------------------------------------------
@implementation CDVHoneywellScanner
@synthesize callbackId;

- (void)pluginInitialize {
    [super pluginInitialize];
    
    Captuvo* scanner = [Captuvo sharedCaptuvoDevice];
    [scanner startDecoderHardware];
    [scanner addCaptuvoDelegate:self];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)dispose {
    Captuvo* scanner = [Captuvo sharedCaptuvoDevice];
    [scanner removeCaptuvoDelegate:self];
    [scanner stopDecoderHardware];

    [super dispose];
}


- (void) onDidEnterBackground {
    [[Captuvo sharedCaptuvoDevice] stopDecoderHardware];
}

- (void) onDidBecomeActive {
    [[Captuvo sharedCaptuvoDevice] startDecoderHardware];
}

//--------------------------------------------------------------------------
// CaptuvoEventsProtocol methods
//--------------------------------------------------------------------------

- (void) decoderDataReceived:(NSString*)data {
    
    NSString *jsonData = [NSString stringWithFormat:@"{\"data\":\"%@\"}", data];
        
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                          messageAsString:jsonData ];
    [pluginResult setKeepCallbackAsBool: YES];

    [self.commandDelegate sendPluginResult:pluginResult
                                callbackId:self.callbackId];
}

//--------------------------------------------------------------------------
// Cordova methods
//--------------------------------------------------------------------------

- (void)registerCallback:(CDVInvokedUrlCommand*)command {
    self.callbackId = command.callbackId;
    [[Captuvo sharedCaptuvoDevice] startDecoderHardware];
    [self updateConnectionStatus];
}
- (void)disable:(CDVInvokedUrlCommand*)command {
    self.callbackId = nil;
    [[Captuvo sharedCaptuvoDevice] stopDecoderHardware];
}

- (void)trigger:(CDVInvokedUrlCommand*)command {
    [[Captuvo sharedCaptuvoDevice]startDecoderScanning];
}

    
- (void)prompt:(NSString*) message {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Honeywell Scanner"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

//************************************************************************
//  Connection Status Related Functionality
//************************************************************************
/**
 *  Sends message to the JS side of the Cordova plugin to update device connection status.
 */
- (void) updateConnectionStatus
{
    NSString* status = [[[Captuvo sharedCaptuvoDevice] getCaptuvoName] isEqual: @"Not Available"] ? @"DISCONNECTED" : @"CONNECTED";

    NSString* message = [NSString stringWithFormat:  @"{\"status\": \"%@\"}", status];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK
                                                      messageAsString: message];

    [pluginResult setKeepCallbackAsBool: YES];

    [self.commandDelegate sendPluginResult: pluginResult
                                callbackId: self.callbackId];
}

@end
