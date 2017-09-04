//  SDLProxyFactory.h
//

#import <Foundation/Foundation.h>

#import "SDLProxyListener.h"

@class SDLProxy;

__deprecated_msg("Use SDLManager instead")
    @interface SDLProxyFactory : NSObject {
}

+ (SDLProxy *)buildSDLProxyWithiAPListener:(NSObject<SDLProxyListener> *)listener;

+ (SDLProxy *)buildSDLProxyWithTCPListener:(NSObject<SDLProxyListener> *)listener
                              tcpIPAddress:(NSString *)ipaddress
                                   tcpPort:(NSString *)port;

+ (SDLProxy *)buildSDLProxyWithUSBMUXDListener:(NSObject<SDLProxyListener> *)delegate;

@end
