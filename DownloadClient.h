//
//  ImageDownloadClient.h
//  RandomWeb
//
//  Created by Gabriel Handford on Wed Aug 18 2004.
//  Copyright 2004 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadListener.h"
#import "SearchParamItem.h"

@interface DownloadClient : NSObject {

	NSArray *urlsArray;
	int urlsIndex;
	id <DownloadListener> listener;
	
	NSURLDownload *currentDownload;
	NSURLResponse *response;
	NSTimer *timer;
	
	bool canceled;
	bool timedOut;
	bool finished;
	
	double timeout;
	int downloadCount;
}

-(id) initWithURL:(NSURL*)url savePath:(NSString*)s timeout:(double)timeout listener:(byref id <DownloadListener>)l;
-(id) initWithURLs:(NSArray*)urls timeout:(double)timeout listener:(byref id <DownloadListener>)l;
-(void) dealloc;
-(int) getDownloadCount;
-(void) setCanceled:(BOOL)b;
-(BOOL) downloadNext;
-(BOOL) download;
-(void) startTimer;
-(void) resetTimer;
-(void) stopTimer;
-(void) timedOut;
-(void) cleanup;
-(void) failWithError:(NSError*)error;

- (void)download:(NSURLDownload *)download didReceiveDataOfLength:(unsigned)length;
- (void)downloadDidBegin:(NSURLDownload *)download;
- (void)downloadDidFinish:(NSURLDownload *)download;
- (void)download:(NSURLDownload *)download didReceiveResponse:(NSURLResponse *)r;
- (void)download:(NSURLDownload*)download didFailWithError:(NSError*)error;

@end
