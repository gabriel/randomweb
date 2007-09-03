//
//  ImageManager.h
//  RandomWeb
//
//  Created by Gabriel Handford on Wed Jul 21 2004.
//  Copyright 2004 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchDownloadClient.h"
#import "ImageDirectoryCache.h"
#import "GoogleSearchParamItem.h"
//#import "SQLDatabase.h"
#import "SearchListener.h"
#import "DownloadListener.h"

@interface ImageManager : NSObject <SearchListener,DownloadListener> {
	NSMutableArray *delegateList;
	
	SearchDownloadClient *client;
	ImageDirectoryCache *dirCache;
	//SQLDatabase *database;
	
	NSDate *lastTransferDate;
	NSDate *lastTypeChangeDate;
	NSMutableArray *imageArray;
	SearchParamItem *currentSearchItem;
	
	NSString *status;
	bool transfering;
	int transferImageCount;
	int imagesDownloaded;
	unsigned bytesTransfered;
	
	int adaptiveMinWait;
	bool canceled;
	
	NSDate *lastStatusUpdate;
}

+(ImageManager*) sharedInstance;

-(id) init;
-(id) initWithDelegate:(id)d;

-(void) addDelegate:(id)d;
-(void) removeDelegate:(id)d;

-(int) count;
-(int) cacheCount;
-(void) notifyTransferAttempt;
-(NSString*) getFromImageArray;
-(NSString*) getFromImageCache;
-(void) addToImageArray:(NSArray*)args;
-(void) addToImageArray:(NSString*)srcPath destPath:(NSString*)destPath;
-(void) setCanceled:(BOOL)b;
-(void) stoppedTransferring;
-(BOOL) triggerSearch;
-(BOOL) checkSearch;

-(BOOL) serverIsReachable:(NSString*)server;
-(void) checkIfFinished:(int)index;
-(ImageDirectoryCache*) getDirectoryCache;
-(BOOL) isTransferring;
-(BOOL) checkSearchItem;
-(SearchParamItem*) getSearchItem;
-(BOOL) setSearchItem:(SearchParamItem*)item;

-(void) reload;
-(void) reloadCache;
-(void) checkCache;
-(void) handleInvalidImage:(NSString*)path;

-(BOOL) checkSearchItemNeedsReload;
-(void) setStatus:(NSString*)s;

@end
