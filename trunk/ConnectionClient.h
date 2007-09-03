//
//  ConnectionClient.h
//  RandomWeb
//
//  Created by g4b3 on Fri Jun 25 2004.
//  Copyright (c) 2004 Cellar Door Software. All rights reserved.
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
