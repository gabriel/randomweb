//
//  ConnectionClient.m
//  RandomWeb
//
//  Created by Gabriel Handford on Fri Jun 25 2004.
//  Copyright 2004 Gabriel Handford. All rights reserved.
//

#import "ConnectionClient.h"
#import "RWLog.h"

@implementation ConnectionClient
	
- (id)init {
    self = [super init];
    if (self) {
		data = [[NSMutableData alloc] init];
		canceled = NO;
    }
    return self;
}

-(void) dealloc {
	[self cleanup];
	if (data) [data release];
	if (response) [response release];
	if (currentConnection) [currentConnection release];
	[super dealloc];
}

-(void) setCanceled:(BOOL)b {
	RWLog(@"Connection client, setCanceled(%d)", (int)b);
	canceled = b;
	@synchronized(self) {
		if (canceled && currentConnection) [currentConnection cancel];
	}
}

-(void) connect:(NSURL*)url delegate:(id)d timeout:(int)socketTimeout {
	if (canceled) {
		RWLog(@"Canceled, returning");
		return;
	}
	delegate = [d retain];
	
	NSURLRequest *request = [NSURLRequest requestWithURL:url 
		cachePolicy:NSURLRequestUseProtocolCachePolicy 
		timeoutInterval:socketTimeout];
				
	RWLog(@"Connecting to host: %@", [url host]);
	@synchronized(self) {
		if (currentConnection) [currentConnection release];
		currentConnection = [[NSURLConnection connectionWithRequest:request delegate:self] retain]; 
	}
}

-(void) cleanup {
	if (data) [data setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)r {
	if (canceled) return;
	[data setLength:0];
	if (response) [response release];
	response = [r retain];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d  {
	if (canceled) return;
	[data appendData:d];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection  {
	if (canceled || !delegate) return;
	RWLog(@"Finished loading");

	SEL sel = @selector(didFinishLoading:encoding:);
	if ([delegate respondsToSelector:sel])
		[delegate performSelector:sel withObject:data withObject:[response textEncodingName]];
    else { 
        [NSException raise:NSInternalInconsistencyException
            format:@"Delegate doesn't respond to didFinishLoading"];
	}

	[self cleanup];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	if (canceled || !delegate) return;	
	SEL sel = @selector(didFailWithError:);
	if ([delegate respondsToSelector:sel])
		[delegate performSelector:sel withObject:error];
	 else { 
        [NSException raise:NSInternalInconsistencyException
            format:@"Delegate doesn't respond to didFailWithError:NSError*"];
    }
	[self cleanup];
}

@end
