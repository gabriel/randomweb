//
//  SearchDownloadClient.h
//  RandomWeb
//
//  Created by Gabriel Handford on Thu Jun 24 2004.
//  Copyright 2004 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ImageDownloadHandler.h"
#import "ConnectionClient.h"
#import "DownloadClient.h"
#import "SearchListener.h"
#import "DownloadListener.h"
#import "RWOptions.h"
#import "GoogleImageQuery.h"
#import "GoogleSearchResult.h"

@interface SearchDownloadClient : NSObject {

	// Search parameters
	id <SearchListener> searchListener;
	id <DownloadListener> downloadListener;
	
	// Search connection
	ConnectionClient *connClient;
	bool canceled;
	
	// Image download client
	DownloadClient *downloadClient;
	
	//id handler;
	ImageDownloadHandler *handler;

	// Last search parameters
	int maxCount;
	SearchParamItem *currentItem;
	NSMutableData *searchData;
	int started;
	SearchResult *lastResult;
	
	int level;
}

-(id) initWithSearchListener:(byref id <SearchListener>)l1 downloadListener:(byref id <DownloadListener>)l2;
-(BOOL) downloadImages:(int)count search:(id)search;
-(void) didFailWithError:(NSError *)error;
-(void) didFinishLoading:(NSMutableData*)data encoding:(NSString*)encoding;
-(void) setCanceled:(BOOL)b;

-(NSData*) getSearchData;
-(SearchResult*) getLastResult;

@end

