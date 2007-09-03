//
//  SearchParamItem.m
//  RandomWeb
//
//  Created by g4b3 on 4/13/05.
//  Copyright 2005 Cellar Door Software. All rights reserved.
//

#import "SearchParamItem.h"
#import "MatchListener.h"
#import "RWLog.h"
#import "RWOptions.h"
#import "ImageManager.h"


static int MAX_IDENTIFIER = -1;

@implementation SearchParamItem

-(id) init:(BOOL)e minSize:(NSSize)m {
	return [self initWithIdentifier:MAX_IDENTIFIER+1 enabled:e minSize:m];
}

-(id) initWithIdentifier:(int)i enabled:(BOOL)e minSize:(NSSize)m {
	self = [super init];
    if (self) {
		identifier = i;
		if (identifier > MAX_IDENTIFIER) MAX_IDENTIFIER = identifier;
		enabled = e;
		minSize = m;
		dirtyFlag = YES;
	}
    return self;
}

-(void) dealloc {
	[super dealloc];
}

-(NSURL*) getSearchURL {
	return nil;
}

-(SearchResult*) parseSearchData:(NSData*)data encoding:(NSString*)encoding maxCount:(int)maxCount ignoreHosts:(NSArray*)ignoreHosts level:(int)level listener:(byref id <MatchListener>)listener {
	return nil;
}

-(NSString*) getCompleteImagePath {
	return nil;
}

-(NSString*) getModeString {
	return @"";
}

-(BOOL) shouldSelect {
	return YES;
}

-(BOOL) isHighPriority {
	return NO;
}

-(void) checkResults:(SearchResult*)result { }

-(void) save:(NSUserDefaults*)std sync:(BOOL)sync { 
	RWLog(@"ERROR: called save() on base item");
}

-(BOOL) like:(SearchParamItem*)i { 
	RWLog(@"ERROR: called like() on base item");
	return NO; 
}

-(NSString*) getSaveFilePath:(NSURL*)url { 
	RWLog(@"ERROR: called getSaveFilePath() on base item");
	return nil; 
}

-(BOOL) isAggressive { return YES; }

-(BOOL) vetoSearch { return NO; }

-(BOOL) isDeletable {
	return YES;
}

-(NSString*) getTypeString {
	return @"Unknown";
}

-(NSString*) getInfoString {
	return @"Unknown";
}

+(int) getMaxIdentifier {
	return MAX_IDENTIFIER;
}

-(int) getIdentifier {
	return identifier;
}

-(BOOL) isEnabled {
	return enabled;
}

-(BOOL) isCanceled {
	return canceled;
}

-(NSDate*) getLastSearchDate {
	return nil;
}

-(void) reset { }

-(float) getWaitBetweenTransfer {
	return [[RWOptions sharedInstance] getDefaultWaitBetweenTransfer];
}

-(void) handleInvalidImage:(NSString*)path {
	[[[ImageManager sharedInstance] getDirectoryCache] removeFile:path];
}

-(void) isCanceled:(BOOL)c {
	canceled = c;
}

-(NSSize) getMinSize {
	return minSize;
}

-(void) isEnabled:(BOOL)e {
	if (e == enabled) return;
	enabled = e;
	dirtyFlag = YES;
}

-(void) setMinSize:(NSSize)s {
	minSize = s;
	dirtyFlag = YES;
}

+(NSSize) getMinSize:(NSString*)value {
	if (value) {
		NSArray *sizes = [value componentsSeparatedByString:@"x"];
		if ([sizes count] == 2) {
			int width = [[sizes objectAtIndex:0] intValue];
			int height = [[sizes objectAtIndex:1] intValue];
			return NSMakeSize(width, height);
		}
	}
	return NSMakeSize(0,0);
}

+(NSString*) getMinSizeString:(NSSize)s {
	return [NSString stringWithFormat:@"%dx%d", (int)s.width, (int)s.height];
}

-(NSString*) getMinSizeString {
	return [SearchParamItem getMinSizeString:minSize];
}

-(void) setMinSizeString:(NSString*)value {
	[self setMinSize:[SearchParamItem getMinSize:value]];
}

-(NSString*) description {
	return [NSString stringWithFormat:@"[%d] MinSize: %@", identifier, [self getMinSizeString]];
}

-(BOOL) isDirty {
	return dirtyFlag;
}

-(void) isDirty:(BOOL)d {
	dirtyFlag = d;
}

-(BOOL) isSearchExhausted {
	return NO;
}

-(BOOL) needsReload {
	return NO;
}

-(void) setLastDownloadCount:(int)c {
	lastDownloadCount = c;
}

-(int) getLastDownloadCount {
	return lastDownloadCount;
}

@end
