//
//  CASTV2PlatformReader.m
//  ChromeCastCore
//
//  Created by Guilherme Rambo on 20/10/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

#import "CASTV2PlatformReader.h"

#define MAX_BUFFER_LENGTH 8192

@interface CASTV2PlatformReader ()

@property (strong) NSInputStream *stream;

@property (assign) NSUInteger readPosition;
@property (strong) NSMutableData *buffer;

@end

@implementation CASTV2PlatformReader

- (instancetype)initWithStream:(NSInputStream *)stream
{
    self = [super init];
    
    self.stream = stream;
    self.buffer = [[NSMutableData alloc] initWithCapacity:MAX_BUFFER_LENGTH];
    
    return self;
}

- (void)readStream
{
    @synchronized (self) {
        NSInteger totalBytesRead = 0;
        size_t bufferSize = 32;
        
        while (self.stream.hasBytesAvailable) {
            uint8_t *bytes = malloc(sizeof(uint8_t) * bufferSize);
            
            NSInteger bytesRead = [self.stream read:bytes maxLength:bufferSize];
            if (bytesRead < 0) continue;
        
            [self.buffer appendBytes:(const void *)bytes length:bytesRead];
            
            free(bytes);
            
            totalBytesRead += bytesRead;
        }
    }
}

- (NSData *)nextMessage
{
    @synchronized (self) {
        size_t headerSize = sizeof(SInt32);
        
        // no data yet
        if (self.buffer.length - self.readPosition < headerSize) return nil;
        
        // read message header (contains the size of the payload)
        const void *bufferPtr = self.buffer.bytes + self.readPosition;
        SInt32 header = 0;
        memcpy(&header, bufferPtr, headerSize);
        SInt32 payloadSize = CFSwapInt32BigToHost(header);
        
        // increment buffer reading position
        self.readPosition += headerSize;
        NSUInteger payloadEnd = self.readPosition + payloadSize;
        // see if there's a full message in the buffer for us to read
        if (payloadEnd > self.buffer.length || payloadSize > self.buffer.length - self.readPosition || payloadSize < 0) {
            // message has not arrived yet
            self.readPosition -= headerSize;
            return nil;
        }
        
        // memory to hold the actual message payload
        void *message = malloc(payloadSize);
        memcpy(message, (self.buffer.bytes + self.readPosition), payloadSize);
        
        // increment buffer reading position for the next call
        self.readPosition += payloadSize;
        
        [self resetBufferIfNeeded];
        
        return [[NSData alloc] initWithBytesNoCopy:message length:payloadSize freeWhenDone:YES];
    }
}

- (void)resetBufferIfNeeded {
    if (self.buffer.length < MAX_BUFFER_LENGTH) return;
    
    @synchronized (self) {
        // store the bytes remaining on the buffer to be used later
        size_t remainingBytes = self.buffer.length - self.readPosition;
        void *rest = malloc(remainingBytes);
        memcpy(rest, (self.buffer.bytes + self.readPosition), remainingBytes);
        
        // allocate the new buffer
        self.buffer = [[NSMutableData alloc] initWithBytes:(const void *)rest length:remainingBytes];
        
        // reset read position
        self.readPosition = 0;
        
        NSLog(@"BUFFER RESET WITH %zu bytes remaining", remainingBytes);
    }
}

@end
