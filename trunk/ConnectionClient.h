//
//  ConnectionClient.h
//  RandomWeb
//
//  Created by Gabriel Handford on Fri Jun 25 2004.
//  Copyright 2004 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ConnectionClient : NSObject {
	NSURLConnection *currentConnection;
	NSURLResponse *response;
	NSMutableData *data;
	id delegate;
	BOOL canceled;
}

-(void) connect:(NSURL*)url delegate:(id)d timeout:(int)socketTimeout;
-(void) setCanceled:(BOOL)b;
-(void) cleanup;

@end
