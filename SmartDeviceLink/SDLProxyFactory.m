//  SDLSyncProxyFactory.m
//

#import "SDLProxyFactory.h"

#import "SDLDebugTool.h"
#import "SDLIAPTransport.h"
#import "SDLProtocol.h"
#import "SDLProxy.h"
#import "SDLTCPTransport.h"
#import "SDLUSBMUXDTransport.h"


@implementation SDLProxyFactory

+ (SDLProxy *)buildSDLProxyWithiAPListener:(NSObject<SDLProxyListener> *)delegate {
    SDLIAPTransport *transport = [[SDLIAPTransport alloc] init];
    SDLProtocol *protocol = [[SDLProtocol alloc] init];
    SDLProxy *ret = [[SDLProxy alloc] initWithTransport:transport protocol:protocol delegate:delegate];
    
    return ret;
}

+ (SDLProxy *)buildSDLProxyWithTCPListener:(NSObject<SDLProxyListener> *)delegate
                              tcpIPAddress:(NSString *)ipaddress
                                   tcpPort:(NSString *)port {
    SDLTCPTransport *transport = [[SDLTCPTransport alloc] init];
    transport.hostName = ipaddress;
    transport.portNumber = port;
    
    SDLProtocol *protocol = [[SDLProtocol alloc] init];
    
    SDLProxy *ret = [[SDLProxy alloc] initWithTransport:transport protocol:protocol delegate:delegate];
    
    return ret;
}

+ (SDLProxy *)buildSDLProxyWithUSBMUXDListener:(NSObject<SDLProxyListener> *)delegate {
    SDLUSBMUXDTransport *transport = [[SDLUSBMUXDTransport alloc] init];
    SDLProtocol *protocol = [[SDLProtocol alloc] init];
    SDLProxy *ret = [[SDLProxy alloc] initWithTransport:transport protocol:protocol delegate:delegate];
    
    return ret;
}

@end
