//  SDLUSBMUXDTransport.m
//

#import "SDLUSBMUXDTransport.h"
#import "SDLUSBMUXDChannel.h"
#import "SDLHexUtility.h"

static const int USBMUXDProtocolIPv4PortNumber = 20001;

enum {
    SDLUSBMUXDFrameTypeDeviceInfo = 100,
    SDLUSBMUXDFrameTypeTextMessage = 101,
    SDLUSBMUXDFrameTypePing = 102,
    SDLUSBMUXDFrameTypePong = 103,
};

typedef struct _SDLUSBMUXDTextFrame {
    uint32_t length;
    uint8_t utf8text[0];
} SDLUSBMUXDTextFrame;

@interface SDLUSBMUXDTransport () <SDLUSBMUXDChannelDelegate>
{
    SDLUSBMUXDChannel *_channel;
}
@end

@implementation SDLUSBMUXDTransport

- (void)connect {
    if (_channel) {
        [self disconnect];
    }
    
    // Create a new channel that is listening on our IPv4 port
    _channel = [SDLUSBMUXDChannel channelWithDelegate:self];
    [_channel listenOnPort:USBMUXDProtocolIPv4PortNumber IPv4Address:INADDR_LOOPBACK callback:^(NSError *error) {
        if (error) {
            [SDLDebugTool logInfo:[NSString stringWithFormat:@"SDLUSBMUXDTransport Failed to listen on 127.0.0.1:%d: %@", USBMUXDProtocolIPv4PortNumber, error] withType:SDLDebugType_Transport_USBMUXD];
        } else {
            [SDLDebugTool logInfo:[NSString stringWithFormat:@"SDLUSBMUXDTransport Listening on 127.0.0.1:%d", USBMUXDProtocolIPv4PortNumber]];
        }
    }];
}

- (void)dealloc {
    [self destructObjects];
}

- (void)destructObjects {
    [SDLDebugTool logInfo:@"SDLUSBMUXDTransport invalidate and dispose"];
    
    if (_channel) {
        [_channel close];
        _channel.delegate = nil;
        _channel = nil;
    }
}

- (void)disconnect {
    [self dispose];
}

- (void)sendData:(NSData *)dataToSend {
    if (_channel) {
        NSString *byteStr = [SDLHexUtility getHexString:dataToSend];
        [SDLDebugTool logInfo:[NSString stringWithFormat:@"SDLUSBMUXDTransport Sent %lu bytes: %@", (unsigned long)dataToSend.length, byteStr] withType:SDLDebugType_Transport_USBMUXD toOutput:SDLDebugOutput_DeviceConsole];
        
        dispatch_data_t payload = [dataToSend createReferencingDispatchData];
        [_channel sendFrameOfType:SDLUSBMUXDFrameTypeTextMessage tag:SDLUSBMUXDFrameNoTag withPayload:payload callback:^(NSError *error) {
            if (error) {
                [SDLDebugTool logInfo:[NSString stringWithFormat:@"SDLUSBMUXDTransport Failed to send message: %@", error]];
            }
        }];
    } else {
        [SDLDebugTool logInfo:@"SDLUSBMUXDTransport Can not send message — not connected"];
    }
}

- (void)dispose {
    [self destructObjects];
}

#pragma mark - SDLUSBMUXDChannelDelegate

// Invoked to accept an incoming frame on a channel. Reply NO ignore the
// incoming frame. If not implemented by the delegate, all frames are accepted.
- (BOOL)ioFrameChannel:(SDLUSBMUXDChannel*)channel shouldAcceptFrameOfType:(uint32_t)type tag:(uint32_t)tag payloadSize:(uint32_t)payloadSize {
    if (channel != _channel) {
        // A previous channel that has been canceled but not yet ended. Ignore.
        return NO;
    } else if (type != SDLUSBMUXDFrameTypeTextMessage && type != SDLUSBMUXDFrameTypePing) {
        [SDLDebugTool logInfo:[NSString stringWithFormat:@"SDLUSBMUXDTransport Unexpected frame of type %u", type]];
        [channel close];
        return NO;
    } else {
        return YES;
    }
}

// Invoked when a new frame has arrived on a channel.
- (void)ioFrameChannel:(SDLUSBMUXDChannel*)channel didReceiveFrameOfType:(uint32_t)type tag:(uint32_t)tag payload:(SDLUSBMUXDData*)payload {
    if (type == SDLUSBMUXDFrameTypeTextMessage) {
        // Check if Core disconnected from us
        if (payload.length <= 0) {
            [SDLDebugTool logInfo:@"SDLUSBMUXDTransport Got a data packet with length 0, the connection was terminated on the other side"];
            if (self.delegate) {
                [self.delegate onTransportDisconnected];
            }
            
            return;
        }
        
        // Handle the data we received
        SDLUSBMUXDTextFrame *textFrame = (SDLUSBMUXDTextFrame*)payload.data;
        textFrame->length = ntohl(textFrame->length);
        NSString *byteStr = [[NSString alloc] initWithBytes:textFrame->utf8text length:textFrame->length encoding:NSUTF8StringEncoding];
        
        [SDLDebugTool logInfo:[NSString stringWithFormat:@"SDLUSBMUXDTransport Read %d bytes: %@", textFrame->length, byteStr] withType:SDLDebugType_Transport_USBMUXD toOutput:SDLDebugOutput_DeviceConsole];
        
        if (self.delegate) {
            [self.delegate onDataReceived:[NSData dataWithBytes:textFrame->utf8text length:textFrame->length]];
        }
    } else if (type == SDLUSBMUXDFrameTypePing && _channel) {
        [_channel sendFrameOfType:SDLUSBMUXDFrameTypePong tag:tag withPayload:nil callback:nil];
    }
}

// Invoked when the channel closed. If it closed because of an error, *error* is
// a non-nil NSError object.
- (void)ioFrameChannel:(SDLUSBMUXDChannel*)channel didEndWithError:(NSError*)error {
    if (error) {
        [SDLDebugTool logInfo:[NSString stringWithFormat:@"SDLUSBMUXDTransport %@ ended with error: %@", channel, error]];
    }
    if (channel.userInfo) {
        [SDLDebugTool logInfo:[NSString stringWithFormat:@"SDLUSBMUXDTransport Disconnected from %@", channel.userInfo]];
        
        if (self.delegate) {
            [self disconnect];
            [self.delegate onTransportDisconnected];
        }
    }
}

// For listening channels, this method is invoked when a new connection has been
// accepted.
- (void)ioFrameChannel:(SDLUSBMUXDChannel*)channel didAcceptConnection:(SDLUSBMUXDChannel*)otherChannel fromAddress:(SDLUSBMUXDAddress*)address {
    // Cancel any other connection. We are FIFO, so the last connection
    // established will cancel any previous connection and "take its place".
    if (_channel) {
        [_channel cancel];
    }
    
    // Weak pointer to current connection. Connection objects live by themselves
    // (owned by its parent dispatch queue) until they are closed.
    _channel = otherChannel;
    _channel.userInfo = address;
    
    [SDLDebugTool logInfo:[NSString stringWithFormat:@"SDLUSBMUXDTransport Connected to %@", address]];
    
    // Send some information about ourselves to the other end
    if (self.delegate) {
        [self.delegate onTransportConnected];
    }
}

@end
