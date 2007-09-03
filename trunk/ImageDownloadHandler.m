//
//  ImageDownloadHandler.m
//  RandomWeb
//
//  Created by g4b3 on 4/27/05.
//  Copyright 2005 Cellar Door Software. All rights reserved.
//

#import "ImageDownloadHandler.h"
#import "RWLog.h"

@implementation ImageDownloadHandler

-(id) initWithListener:(byref id <DownloadListener>)l timeout:(double)t {
	self = [super init];
	if (self) {
		listener = l;
		timeout = t;
		downloadCount = 0;
	}
	return self;
}

-(void) dealloc {
	if (downloadClient) [downloadClient release];
	[super dealloc];
}

-(int) downloadCount {
	return downloadCount;
}

-(void) didFindMatch:(NSURL*)u savePath:(NSString*)sp count:(int)count {
	RWLog(@"Found match, starting download");
	downloadClient = [[DownloadClient alloc] initWithURL:u savePath:sp timeout:timeout listener:self];
	[downloadClient download];
	RWLog(@"Download finished");
}


-(void) cancel {
	if (downloadClient) [downloadClient setCanceled:YES];
}

-(void) didFinishDownloads:(BOOL)interrupted {
	[listener didFinishDownloads:interrupted];
}

-(void) didCompleteMatchSearch {
	[listener didFinishDownloads:NO];
}


-(void) didStartDownload:(NSURL*)u count:(int)index path:(NSString*)sp { 
	[listener didStartDownload:u count:-1 path:sp];
}

-(void) didAbort {
	[listener didAbort];
}

-(void) didFinishDownload:(NSURL*)u count:(int)index path:(NSString*)sp {
	downloadCount++;
	[listener didFinishDownload:u count:-1 path:sp];
}
 
-(void) didErrorOnDownload:(NSError*)error count:(int)c { 
	[listener didErrorOnDownload:error count:-1];
} 

-(void) didLoadData:(NSURL*)u length:(unsigned)l total:(long long)t { 
	[listener didLoadData:u length:l total:t];
}

@end
