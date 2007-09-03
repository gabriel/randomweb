//
//  SearchParameters.h
//  RandomWeb
//
//  Created by Gabriel Handford on Tue Jun 22 2004.
//  Copyright 2004 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RWOptions.h"
#import "GoogleSearchParamItem.h"

typedef struct _RWSettings {
    int minWidthPhoto;
	int minHeightPhoto;
	int minWidthSite;
	int minHeightSite;
	int minWidthPhrase;
	int minHeightPhrase;
	
	float searchInterval;
	float imageInterval;
	int maxImagePerSearch;
	int imageExpiration;
	int maxCacheSize;
	int minImageCount;
	int socketTimeout;
	BOOL showStatus;
	BOOL showFileName;
	
	BOOL isFadeEnabled;
	int fadeAmount;
	BOOL isZoomEnabled;
	
	BOOL isDigitalSearchEnabled;
	
	BOOL isSiteSearchEnabled;
	BOOL useRandomSite;
	
	BOOL isPhraseSearchEnabled;
	BOOL useRandomPhrase;
	
	BOOL focusCameraPhoto;
	BOOL focusCameraSite;
	BOOL focusCameraPhrase;
	
} RWSettings;

//typedef enum _RWSearchType { RWDigitalPhotoSearch = 0, RWSiteSearch = 1, RWPhraseSearch = 2 } RWSearchType;

@interface Settings : NSObject {

	RWSettings settings;
	NSString *imagePath;
	NSString *searchSafeness;
	RWSearchType searchType;
	
	NSArray *filePatterns;
	NSMutableArray *ignoreHosts;
	NSMutableArray *phrases;
	NSMutableArray *sites;
	NSString *selectedSite;
	NSString *selectedPhrase;
}

-(id) init;
+(Settings*) sharedInstance;
-(RWSettings*) settingsStruct;

-(void)loadDefaultSettings;
-(void)loadUserSettings;
-(void) saveSettings;

-(NSArray*) getFilePatterns;

-(NSSize) getMinSize;

-(void) setBaseImagePath:(NSString*)s;
-(NSString*) getBaseImagePath;

-(float) getWaitBetweenTransfer;
-(float) getInterval;

-(int) getMaxImagePerSearch;

-(NSString*) getSearchSize;

-(void) setSearchSafeness:(NSString*)s;
-(NSString*) getSearchSafeness;

-(int) getImageExpiration;
-(int) getMaxCacheSize;

-(int) getMinImageCount;

-(BOOL) showStatus;

-(void) getCacheStats:(NSString*)path traverse:(BOOL)traverse count:(int*)count size:(float*)size;

-(int) getSocketTimeout;

-(BOOL) showFileName;

-(NSString*) getVersion;

-(BOOL) isFadeEnabled;
-(int) getFadeAmount;
-(BOOL) isZoomEnabled;

-(NSArray*) getHostsToIgnore;

-(RWSearchType) getSearchType;
-(NSString*) getSearchParameterForType;

-(void) setQueryStartingCount:(int)count;
-(void) setQueryStartingCount:(int)count parameter:(NSString*)param;

-(void) setSearchSize:(NSString*)param searchSize:(NSString*)searchSize;

-(BOOL) useMinSize;
-(BOOL) focusCamera;
-(BOOL) useHostsToIgnore;
-(int) getQueryStartingCount;
-(NSArray*) getSites;
-(NSArray*) getPhrases;

-(NSString*) getSelectedSite;
-(NSString*) getSelectedPhrase;
-(void) setSelectedSite:(NSString*)s;
-(void) setSelectedPhrase:(NSString*)s;

-(void) setHostsToIgnore:(NSMutableArray*)h;
-(void) setSites:(NSMutableArray*)s;
-(void) setPhrases:(NSMutableArray*)p;

-(void) setSearchExhausted;
-(void) finishedQueryStartingCount:(int)count;
-(BOOL) useSearchSize;

-(void) reload;
-(void) fillSettings;

-(NSString*) getFullImagePath;
-(NSString*) getSitesPath;
-(NSString*) getPhrasesPath;

-(int) getInteger:(NSString*)key def:(int)def;
-(void) setInteger:(NSString*)key value:(int)value;

@end
