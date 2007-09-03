//
//  SearchParamItem.h
//  RandomWeb
//
//  Created by g4b3 on 4/13/05.
//  Copyright 2005 Cellar Door Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SearchResult.h"
#import "MatchListener.h"

@interface SearchParamItem : NSObject {
	
	BOOL enabled;
	NSSize minSize;
	
	int identifier;
	BOOL dirtyFlag;
	
	BOOL canceled;

	int lastDownloadCount;
}

-(id) init:(BOOL)e minSize:(NSSize)m;

-(id) initWithIdentifier:(int)identifier enabled:(BOOL)enabled minSize:(NSSize)minSize;
-(void) dealloc;

// Subclasses should implement these
-(NSURL*) getSearchURL;
-(SearchResult*) parseSearchData:(NSData*)data encoding:(NSString*)encoding maxCount:(int)maxCount ignoreHosts:(NSArray*)ignoreHosts level:(int)level listener:(byref id <MatchListener>)listener;
-(NSString*) getCompleteImagePath;
-(NSString*) getModeString;
-(void) checkResults:(SearchResult*)result;
-(void) save:(NSUserDefaults*)std sync:(BOOL)sync;
-(BOOL) like:(SearchParamItem*)i;
-(NSString*) getTypeString;
-(NSString*) getInfoString;
-(NSString*) getSaveFilePath:(NSURL*)url;
-(BOOL) isAggressive;
-(BOOL) vetoSearch;
-(BOOL) shouldSelect;
-(BOOL) isHighPriority;
-(void) reset;
-(float) getWaitBetweenTransfer;

-(BOOL) isEnabled;
-(NSSize) getMinSize;
+(int) getMaxIdentifier;

-(void) isEnabled:(BOOL)enabled;
-(void) setMinSize:(NSSize)minSize;

-(void) setMinSizeString:(NSString*)value;
+(NSSize) getMinSize:(NSString*)value;
+(NSString*) getMinSizeString:(NSSize)s;
-(BOOL) isDirty;
-(void) isDirty:(BOOL)d;
-(int) getIdentifier;
-(NSString*) getMinSizeString;
-(BOOL) isSearchExhausted;
-(BOOL) isDeletable;
-(BOOL) needsReload;
-(void) handleInvalidImage:(NSString*)path;
-(NSDate*) getLastSearchDate;

-(void) setLastDownloadCount:(int)c;
-(int) getLastDownloadCount;

-(BOOL) isCanceled;
-(void) isCanceled:(BOOL)c;

@end
