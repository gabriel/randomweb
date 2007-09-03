//
//  SearchDownloadClient.m
//  RandomWeb
//
//  Created by Gabriel Handford on Thu Jun 24 2004.
//  Copyright 2004 Gabriel Handford. All rights reserved.
//

#import "SearchDownloadClient.h"
#import "RWOptions.h"
#import "GoogleImageSearch.h"
#import "RWLog.h"

@implementation SearchDownloadClient

-(id) initWithSearchListener:(byref id <SearchListener>)l1 downloadListener:(byref id <DownloadListener>)l2 {
	self = [super init];
	if (self) {
		searchData = [[NSMutableData alloc] init];
		searchListener = l1;
		downloadListener = l2;
		canceled = NO;
		started = 0;
		level = 0;
	}
    return self;
}

-(void) dealloc {
	if (currentItem) [currentItem release];
	if (searchData) [searchData release];
	if (connClient) [connClient release];
	if (downloadClient) [downloadClient release];
	[super dealloc];
}

-(void) setCanceled:(BOOL)b {
	RWLog(@"Search download client, setCanceled(%d)", (int)b);
	canceled = b;
	@synchronized(self) {
		if (connClient) [connClient setCanceled:b];
		if (downloadClient) [downloadClient setCanceled:b];
		if (canceled && handler) [handler cancel];
	}
}


//
// Perform search in background
//
-(BOOL) downloadImages:(int)count search:(id)search {
	if (canceled) return NO;
		
	NSURL *searchURL = nil;
	maxCount = count;
	
	if ([search isKindOfClass:[SearchParamItem class]]) {
		level = 0;
		SearchParamItem *item = (SearchParamItem*)search;
		if (currentItem) [currentItem release];
		currentItem = [item retain];
		searchURL = [[item getSearchURL] retain];
	}
	
	if (!searchURL) {
		RWLog(@"Search URL was nil, returning");
		return NO;
	}

	RWLog(@"Search URL: %@", searchURL);
	
	@synchronized(self) {
		if (connClient) [connClient release];
		connClient = [[ConnectionClient alloc] init];
		[connClient connect:searchURL delegate:self timeout:[[RWOptions sharedInstance] getSocketTimeout]];
	}
	
	if (searchListener) [searchListener didStartSearch:searchURL];
	[searchURL release];
	return YES;
}

-(SearchParamItem*) getCurrentSearchParamItem {
	return currentItem;
}

-(NSData*) getSearchData {
	if (!searchData) return nil;
	return [[searchData copy] autorelease];
}

-(SearchResult*) getLastResult {
	return lastResult;
}

//
// Called from ConnectionClient
//
- (void)didFailWithError:(NSError *)error {
	if (canceled) return;
	if (searchListener) [searchListener didErrorOnSearch:error];
}

- (void)didFinishLoading:(NSMutableData*)data encoding:(NSString*)encoding {
	if (canceled) return;
	[searchData setLength:0];
	if (data) [searchData setData:data];

	NSArray *hostsToIgnore = [[RWOptions sharedInstance] getHostsToIgnore];
	//GoogleSearchResult *result = [GoogleImageSearch parseSearchData:(NSData*)searchData encoding:encoding minSize:minSize maxCount:maxCount ignoreHosts:hostsToIgnore];
	@synchronized(self) {
		if (handler) [handler release];
		handler = [[ImageDownloadHandler alloc] initWithListener:downloadListener timeout:(double)[[RWOptions sharedInstance] getSocketTimeout]];
	}
	SearchResult *result = [currentItem parseSearchData:(NSData*)searchData encoding:encoding maxCount:maxCount ignoreHosts:hostsToIgnore level:level listener:handler];
	
	if (!result) {
		RWLog(@"Download count: %d", [handler downloadCount]);
		[currentItem setLastDownloadCount:[handler downloadCount]];
	} else RWLog(@"Search result: %@", result);
	level++;
	
	if (lastResult) [lastResult release];
	if (result) lastResult = [result retain];
	else lastResult = nil;
	
	if (result) {
		NSArray *urlsArray = [result getLinks];
		if (searchListener) [searchListener didFinishSearch:[urlsArray count]];
	
		// Initiate image downloads
		@synchronized(self) {
			if (downloadClient) [downloadClient release];
			downloadClient = [[DownloadClient alloc] initWithURLs:urlsArray timeout:(double)[[RWOptions sharedInstance] getSocketTimeout] listener:downloadListener];
		}
		[downloadClient downloadNext];
	} else {
		if (searchListener) [searchListener didFinishSearch:-1];
	}
}

@end
