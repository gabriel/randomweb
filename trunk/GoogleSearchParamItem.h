//
//  GoogleSearchParamItem.h
//  RandomWeb
//
//  Created by Gabriel Handford on 2/8/05.
//  Copyright 2005 Gabriel Handford. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SearchParamItem.h"

typedef enum _RWSearchType { RWDigitalPhotoSearch = 0, RWSiteSearch = 1, RWPhraseSearch = 2 } RWSearchType;

@interface GoogleSearchParamItem : SearchParamItem {

	RWSearchType type;
	NSString *keyword;
	
	int startingPosition;
	BOOL startingPositionEnabled;
	NSString* searchSize;
}

-(id) init:(BOOL)e type:(RWSearchType)t keyword:(NSString*)k minSize:(NSSize)m;
-(id) init:(BOOL)e type:(RWSearchType)t keyword:(NSString*)k minSize:(NSSize)m searchSize:(NSString*)s startingPosition:(int)p;
-(id) initWithIdentifier:(int)identifier enabled:(BOOL)enabled type:(RWSearchType)type keyword:(NSString*)keyword minSize:(NSSize)minSize;
-(id) initWithIdentifier:(int)identifier enabled:(BOOL)enabled type:(RWSearchType)type keyword:(NSString*)keyword minSize:(NSSize)minSize searchSize:(NSString*)searchSize startingPosition:(int)startingPosition;
-(void) dealloc;

+(GoogleSearchParamItem*) load:(int)identifier dict:(NSDictionary*)dict;

-(NSURL*) getSearchURL;

-(RWSearchType) getType;
-(NSString*) getKeyword;
-(void) setType:(RWSearchType)type;
-(void) setKeyword:(NSString*)keyword;

-(void) setTypeString:(NSString*)value;
-(NSString*) getTypeString;
+(NSString*) getTypeString:(RWSearchType)t;
+(RWSearchType) getType:(NSString*)value;

-(BOOL) isSearchExhausted;
-(void) isSearchExhausted:(BOOL)b;
-(int) getStartingPosition;
-(void) setStartingPosition:(int)s;
-(NSString*) getSearchSize;
-(void) setSearchSize:(NSString*)searchSize;
-(BOOL) cycleSearchSize;

-(void) checkCycleSearchSize;
-(void) incrementStartingPosition;
-(BOOL) isStartingPositionEnabled;


@end
