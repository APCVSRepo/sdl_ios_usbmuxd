//
// Represents a communication channel between two endpoints talking the same
// SDLUSBMUXDProtocol.
//
#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>
#import <netinet/in.h>
#import <sys/socket.h>

#import "SDLUSBMUXDProtocol.h"
#import "SDLUSBMUXDUSBHub.h"

@class SDLUSBMUXDData, SDLUSBMUXDAddress;
@protocol SDLUSBMUXDChannelDelegate;

@interface SDLUSBMUXDChannel : NSObject

// Delegate
@property (strong) id<SDLUSBMUXDChannelDelegate> delegate;

// Communication protocol. Must not be nil.
@property SDLUSBMUXDProtocol *protocol;

// YES if this channel is a listening server
@property (readonly) BOOL isListening;

// YES if this channel is a connected peer
@property (readonly) BOOL isConnected;

// Arbitrary attachment. Note that if you set this, the object will grow by
// 8 bytes (64 bits).
@property (strong) id userInfo;

// Create a new channel using the shared SDLUSBMUXDProtocol for the current dispatch
// queue, with *delegate*.
+ (SDLUSBMUXDChannel*)channelWithDelegate:(id<SDLUSBMUXDChannelDelegate>)delegate;


// Initialize a new frame channel, configuring it to use the calling queue's
// protocol instance (as returned by [SDLUSBMUXDProtocol sharedProtocolForQueue:
//   dispatch_get_current_queue()])
- (id)init;

// Initialize a new frame channel with a specific protocol.
- (id)initWithProtocol:(SDLUSBMUXDProtocol*)protocol;

// Initialize a new frame channel with a specific protocol and delegate.
- (id)initWithProtocol:(SDLUSBMUXDProtocol*)protocol delegate:(id<SDLUSBMUXDChannelDelegate>)delegate;


// Connect to a TCP port on a device connected over USB
- (void)connectToPort:(int)port overUSBHub:(SDLUSBMUXDUSBHub*)usbHub deviceID:(NSNumber*)deviceID callback:(void(^)(NSError *error))callback;

// Connect to a TCP port at IPv4 address. Provided port must NOT be in network
// byte order. Provided in_addr_t must NOT be in network byte order. A value returned
// from inet_aton() will be in network byte order. You can use a value of inet_aton()
// as the address parameter here, but you must flip the byte order before passing the
// in_addr_t to this function.
- (void)connectToPort:(in_port_t)port IPv4Address:(in_addr_t)address callback:(void(^)(NSError *error, SDLUSBMUXDAddress *address))callback;

// Listen for connections on port and address, effectively starting a socket
// server. Provided port must NOT be in network byte order. Provided in_addr_t
// must NOT be in network byte order.
// For this to make sense, you should provide a onAccept block handler
// or a delegate implementing ioFrameChannel:didAcceptConnection:.
- (void)listenOnPort:(in_port_t)port IPv4Address:(in_addr_t)address callback:(void(^)(NSError *error))callback;

// Send a frame with an optional payload and optional callback.
// If *callback* is not NULL, the block is invoked when either an error occured
// or when the frame (and payload, if any) has been completely sent.
- (void)sendFrameOfType:(uint32_t)frameType tag:(uint32_t)tag withPayload:(dispatch_data_t)payload callback:(void(^)(NSError *error))callback;

// Lower-level method to assign a connected dispatch IO channel to this channel
- (BOOL)startReadingFromConnectedChannel:(dispatch_io_t)channel error:(__autoreleasing NSError**)error;

// Close the channel, preventing further reading and writing. Any ongoing and
// queued reads and writes will be aborted.
- (void)close;

// "graceful" close -- any ongoing and queued reads and writes will complete
// before the channel ends.
- (void)cancel;

@end


// Wraps a mapped dispatch_data_t object. The memory pointed to by *data* is
// valid until *dispatchData* is deallocated (normally when the receiver is
// deallocated).
@interface SDLUSBMUXDData : NSObject
@property (readonly) dispatch_data_t dispatchData;
@property (readonly) void *data;
@property (readonly) size_t length;
@end


// Represents a peer's address
@interface SDLUSBMUXDAddress : NSObject
// For network addresses, this is the IP address in textual format
@property (readonly) NSString *name;
// For network addresses, this is the port number. Otherwise 0 (zero).
@property (readonly) NSInteger port;
@end


// Protocol for SDLUSBMUXDChannel delegates
@protocol SDLUSBMUXDChannelDelegate <NSObject>

@required
// Invoked when a new frame has arrived on a channel.
- (void)ioFrameChannel:(SDLUSBMUXDChannel*)channel didReceiveFrameOfType:(uint32_t)type tag:(uint32_t)tag payload:(SDLUSBMUXDData*)payload;

@optional
// Invoked to accept an incoming frame on a channel. Reply NO ignore the
// incoming frame. If not implemented by the delegate, all frames are accepted.
- (BOOL)ioFrameChannel:(SDLUSBMUXDChannel*)channel shouldAcceptFrameOfType:(uint32_t)type tag:(uint32_t)tag payloadSize:(uint32_t)payloadSize;

// Invoked when the channel closed. If it closed because of an error, *error* is
// a non-nil NSError object.
- (void)ioFrameChannel:(SDLUSBMUXDChannel*)channel didEndWithError:(NSError*)error;

// For listening channels, this method is invoked when a new connection has been
// accepted.
- (void)ioFrameChannel:(SDLUSBMUXDChannel*)channel didAcceptConnection:(SDLUSBMUXDChannel*)otherChannel fromAddress:(SDLUSBMUXDAddress*)address;

@end
