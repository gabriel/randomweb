//
//  RWOption.h
//  RandomWeb
//
//  Created by g4b3 on 2/9/05.
//  Copyright 2005 Cellar Door Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchParamItem.h"
#import "RWOptionsListener.h"

typedef struct _RWSimpleSettings {
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
	int typeChangeInterval;
	BOOL isSearchEnabled;
	int locationSearchWait;
	BOOL isITunesHighPriority;
	int locationMaxCount;
	
} RWSimpleSettings;

@interface RWOptions : NSObject {

	RWSimpleSettings settings;
	NSString *imagePath;
	NSString *searchSafeness;
	
	NSArray *filePatterns;
	NSMutableArray *ignoreHosts;
	
	NSMutableArray *searchItems;
	NSMutableArray *listeners;
}

-(void) addListener:(byref id <RWOptionsListener>)listener;
-(void) removeListener:(byref id <RWOptionsListener>)listener;

+(RWOptions*) sharedInstance;
-(void) loadDefaultSettings;
-(NSString*) getSearchSafeness;
-(RWSimpleSettings*) getSimpleSettings;
-(void)loadUserSettings;

-(void) setSearchSafeness:(NSString*)s;
-(void) setBaseImagePath:(NSString*)s;

-(SearchParamItem*) loadSearchParamItem:(int)identifier;
-(NSMutableArray*) loadSearchParamItems;
-(SearchParamItem*) getRandomItem;
-(SearchParamItem*) getRandomItem:(SearchParamItem*)ignore;

-(void) saveSearchParamItems:(BOOL)sync;
-(void) saveSearchParamItem:(SearchParamItem*)item sync:(BOOL)sync;
-(void) addSearchParamItem:(SearchParamItem*)item sync:(BOOL)sync;
-(void) removeSearchParamItem:(SearchParamItem*)item sync:(BOOL)sync;
-(NSArray*) getSearchItems;
-(void) setSearchItems:(NSArray*) items;
-(void) saveSettings;

-(BOOL) containsItemLike:(SearchParamItem*) item;
-(BOOL) containsSearchItem:(SearchParamItem*)item;

-(NSArray*) getFilePatterns;
-(NSString*) getBaseImagePath;
-(NSString*) getDigitalPhotoPath;
-(NSString*) getPhrasesPath;
-(NSString*) getSitesPath;
-(NSString*) getLocationPath;
-(NSString*) getTempPath;
-(NSString*) getVersion;
-(BOOL) focusCamera;
-(NSArray*) getHostsToIgnore;
-(void) reload;
-(void) saveSearchItemsList;

-(float) getInterval;
-(int) getMaxImagePerSearch;
-(int) getImageExpiration;
-(int) getMaxCacheSize;
-(int) getMinImageCount;
-(BOOL) showStatus;
-(BOOL) showFileName;
-(int) getSocketTimeout;
-(BOOL) isFadeEnabled;
-(int) getFadeAmount;
-(BOOL) isZoomEnabled;
-(float) getDefaultWaitBetweenTransfer;
-(int) getTypeChangeInterval;
-(BOOL) isSearchEnabled;
-(int) getLocationSearchWait;
-(BOOL) isITunesHighPriority;
-(int) getLocationMaxCount;

+(void) checkConvert:(RWOptions*)options;
-(BOOL) hasConverted;
-(void) setConverted:(BOOL)b;
-(void) sync;

-(void) checkMainSearchParamItems:(NSMutableArray*)items;

@end

