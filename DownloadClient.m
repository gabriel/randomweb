//
//  ImageDownloadClient.m
//  RandomWeb
//
//  Created by g4b3 on Wed Aug 18 2004.
//  Copyright (c) 2004 Cellar Door Software. All rights reserved.
//

#import "DownloadClient.h"
#import "RWLog.h"

@implementation DownloadClient

-(id) initWithURL:(NSURL*)url savePath:(NSString*)s timeout:(double)t listener:(byref id <DownloadListener>)l {
	
	NSDictionary *dictEntry = [NSDictionary dictionaryWithObjectsAndKeys:
		url, @"url", s, @"savePath", nil];

	return [self initWithURLs:[NSArray arrayWithObjects:dictEntry, nil] timeout:t listener:l];
}

-(id) initWithURLs:(NSArray*)urls timeout:(double)t listener:(byref id <DownloadListener>)l {
	self = [super init];
	if (self) {
		urlsIndex = 0;
		downloadCount = 0;
		urlsArray = [urls retain];
		timeout = t;
		listener = l;
		timedOut = NO;
		finished = NO;
		canceled = NO;
	}
    return self;
}

-(void) dealloc {
	if (currentDownload) [currentDownload release];
	if (response) [response release];
	if (urlsArray) [urlsArray release];
	[super dealloc];
}

-(int) getDownloadCount {
	return downloadCount;
}

-(void) setCanceled:(BOOL)b {
	canceled = b;
	if (canceled) {
		//[self stopTimer];
		@synchronized(self) {
			if (currentDownload) {
				RWLog(@"Calling cancel on current download...");
				[currentDownload cancel];
			}
		}
	}
}

-(void) downloadThreadRun {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	RWLog(@"Download thread start");
	[NSThread setThreadPriority:0.01];
	if ([self downloadNext]) {
		while(!canceled && !finished) {
			if (![[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.2]]) {
				[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
			}
		}
	}
	RWLog(@"Download thread end");
	[pool release];
}

-(BOOL) currentExists {
	if (urlsIndex < [urlsArray count]) {
		
		NSDictionary *dict = [urlsArray objectAtIndex: urlsIndex];
		NSString *savePath = [dict objectForKey:@"savePath"];
		
		NSString *pext = [savePath pathExtension];
		if ([pext isEqual:@"tmp"]) savePath = [savePath stringByDeletingPathExtension];

		BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:savePath]
			|| [[NSFileManager defaultManager] fileExistsAtPath:[savePath stringByAppendingPathExtension:@"ignore"]];
			
		RWLog(@"%@, exists: %d", [savePath lastPathComponent], (int)exists);
		return exists;
	}
	return NO;
}

-(BOOL) download {
	RWLog(@"Download start");
	
	if (![self currentExists]) {
		[NSThread detachNewThreadSelector:@selector(downloadThreadRun) toTarget:self withObject:nil];

		while(!canceled && !finished) {
			[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
		}
 	} else {
		RWLog(@"Ignore download, file exists");
	}
	RWLog(@"Download done, canceled:%d, finished:%d, timedOut:%d", (int)canceled, (int)finished, (int)timedOut);
	return finished;
}

-(BOOL) downloadNext {
	if (canceled) return NO;
	if (!urlsArray) return NO;

	if (urlsIndex < [urlsArray count]) {
		
		NSDictionary *dict = [urlsArray objectAtIndex: urlsIndex];
		NSString *savePath = [dict objectForKey:@"savePath"];
		BOOL exists = [self currentExists];
		urlsIndex++;		
		
		if (exists) {
			NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"Already exists: %@", savePath], NSLocalizedDescriptionKey, nil];
			NSError *error = [NSError errorWithDomain:@"Already exists" code:0 userInfo:dict];
			[self failWithError:error];
			return [self downloadNext];
		}
		
		NSURL *url = [dict objectForKey:@"url"];
		if (url) {
	
			if (listener) [listener didStartDownload:url count:urlsIndex-1 path:savePath];
			
			NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:timeout]; 
			
			@synchronized(self) {
				if (currentDownload) [currentDownload release];
				currentDownload = [[NSURLDownload alloc] initWithRequest:request delegate:self]; 
			}
			RWLog(@"Set save path: %@", savePath);
			[currentDownload setDestination:savePath allowOverwrite:YES]; 
			
			[self startTimer];
			return YES;
		}
	}
	finished = YES;
	return NO;
}

-(void) startTimer {
	[self stopTimer];
	RWLog(@"Starting timer with timeout: %g", timeout);
	timer = [[NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(timedOut) userInfo:nil repeats:NO] retain];
}

-(void) resetTimer {
	if (timer && [timer isValid]) {
		[timer setFireDate: [NSDate dateWithTimeIntervalSinceNow:timeout]];
	}
}

-(void) stopTimer {
	if (timer) {
		RWLog(@"Stopping timer");
		if ([timer isValid]) [timer invalidate];
		[timer release];
		timer = nil;
	}
}

-(void) timedOut { 
	RWLog(@"Timed out");
	
	@synchronized(self) {
		if (currentDownload) {
			RWLog(@"Calling cancel on current download (timed out)");
			[currentDownload cancel];
		}
	}
	
	if (canceled) {
		RWLog(@"Canceled, ignoring timeout");
		return;
	}
	timedOut = YES;
	
	if (timer && ![timer isValid]) {
		RWLog(@"Timer isn't valid, ignoring");
		return;
	}
	
	if (currentDownload) {
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys: @"Download timed out", NSLocalizedDescriptionKey, nil];
		NSError *error = [NSError errorWithDomain:@"Timeout" code:0 userInfo:dict];
		
		[self download:currentDownload didFailWithError:error];
	}
}

- (void)download:(NSURLDownload *)download didReceiveDataOfLength:(unsigned)length {
	if (canceled || timedOut) return;
	
	if (listener) [listener didLoadData:[response URL] length:length total:[response expectedContentLength]];
	[self resetTimer];
}

- (void)downloadDidBegin:(NSURLDownload *)download { 
	if (canceled || timedOut) return;
	[self resetTimer];
}


- (void)downloadDidFinish:(NSURLDownload *)download {
	if (canceled || timedOut) return;
	downloadCount++;
	NSDictionary *dict = [urlsArray objectAtIndex: (urlsIndex-1)];
	NSURL *url = [dict objectForKey:@"url"];
	NSString *savePath = [dict objectForKey:@"savePath"];
	if (listener) [listener didFinishDownload:url count:(urlsIndex-1) path:savePath];
	[self cleanup];
	[self downloadNext];
}

- (void)download:(NSURLDownload *)download didReceiveResponse:(NSURLResponse *)r {
	if (canceled || timedOut) return;
	if (response) [response release];
	response = [r retain];
	[self resetTimer];
}

-(void) failWithError:(NSError*)error {
	if (canceled) return;
	if (listener) [listener didErrorOnDownload:error count:(urlsIndex-1)];
	[self cleanup];
}

//
//
//
-(void) download:(NSURLDownload*)download didFailWithError:(NSError*)error {
	[self failWithError:error];
	[self downloadNext];
}

-(void) cleanup {
	[self stopTimer];
	timedOut = NO;
}




@end
