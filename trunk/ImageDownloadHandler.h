//
//  ImageDownloadHandler.h
//  RandomWeb
//
//  Created by g4b3 on 4/27/05.
//  Copyright 2005 Cellar Door Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DownloadClient.h"
#import "MatchListener.h"

@interface ImageDownloadHandler : NSObject <MatchListener,DownloadListener>  {

	id <DownloadListener> listener;
	DownloadClient *downloadClient;
	
	//NSLock *lock;
	//BOOL downloading;
	//BOOL finished;
	
	//NSURL *url;
	//NSString *savePath;
	int timeout;
	int downloadCount;
}

-(id) initWithListener:(byref id <DownloadListener>)l timeout:(double)timeout;
-(void) cancel;

@end
