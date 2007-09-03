//
//  RWOptions.m
//  RandomWeb
//
//  Created by g4b3 on 2/9/05.
//  Copyright 2005 Cellar Door Software. All rights reserved.
//

#import <ScreenSaver/ScreenSaverDefaults.h>
#import "RWOptions.h"
#import "RWLog.h"
#import "FileUtil.h"
#import "RandomSelector.h"
#import "RWOptionsListener.h"
#import "SettingsConvertor.h"
#import "URLSearchParamItem.h"
#import "ITunesSearchParamItem.h"

static RWOptions *sharedInstance = nil;
static NSLock *sharedLock = nil;
static BOOL hasBeenInitialized = NO;

@implementation RWOptions

+(RWOptions*) sharedInstance {
	[sharedLock lock];
	if(!sharedInstance) {
		sharedInstance = [[self alloc] init];
	}
	[sharedLock unlock];
    return sharedInstance;
}

+(void) initialize {
	[super initialize];
	if (hasBeenInitialized) return;
	hasBeenInitialized = YES;
	sharedLock = [[NSLock alloc] init];
}


-(id) init {
    self = [super init];
    if (self) {
		listeners = [[NSMutableArray arrayWithCapacity:2] retain];
	
		RWLog(@"Loading default settings");
        [self loadDefaultSettings];
		RWLog(@"Loading user settings");
        [self loadUserSettings];
		[RWOptions checkConvert:self];
    }
    return self;
}

+(void) checkConvert:(RWOptions*)options {
	RWLog(@"Check if convert needed");
	if (![options hasConverted]) {
		RWLog(@"Converting...");
		[SettingsConvertor convert:options];
	}
}

-(void) loadDefaultSettings {
	NSString *s = @"~/Pictures/RandomWeb";
	[self setBaseImagePath:[s stringByExpandingTildeInPath]];
	settings.searchInterval = 2.0;
	settings.imageInterval = 15.0;

	[self setSearchSafeness:@"active"];
	settings.maxImagePerSearch = 20;
	settings.imageExpiration = 365;
	settings.maxCacheSize = 1000;
	settings.minImageCount = 10;
	settings.showStatus = YES;
	settings.showFileName = NO;
	
	settings.isFadeEnabled = YES;
	settings.fadeAmount = 5;
	settings.isZoomEnabled = YES;
	settings.socketTimeout = 10;
	settings.typeChangeInterval = 5;
	settings.isSearchEnabled = YES;
	settings.locationSearchWait = 12;
	settings.isITunesHighPriority = YES;
	settings.locationMaxCount = 100;
	
	filePatterns = [[NSArray arrayWithObjects:
		@"dcp0####",
		@"dsc0####",
		@"dscn####",
		@"mvc-###",
		@"mvc00###",
		@"IM00####",
		@"EX0000##",
		@"P101####",
		@"100-####",
		@"dscf####",
		@"pdrm####",
		@"pict####",
		@"CIMG####",
		@"img_####",
		@"imgp####", nil] retain];
	// @"PMDD####.jpg"
	// @"DC####S.jpg"
	// @"crw_####.jpg"
	// @"0309####.jpg"
	// @"fxcd####"
	
	ignoreHosts = [[NSMutableArray arrayWithCapacity:10] retain];
	[ignoreHosts addObjectsFromArray:
		[NSArray arrayWithObjects:
			@"watman.com",
			@"www.rootsweb.com",
			@"rubens.anu.edu.au",
			@"fbody-event.org", nil] ];
			
	searchItems = [[NSMutableArray arrayWithCapacity:10] retain];

}

+(NSUserDefaults*) getUserDefaults {
	return [ScreenSaverDefaults defaultsForModuleWithName:@"com.cellardoorsw.randomweb.options"];
}

-(void) addListener:(byref id <RWOptionsListener>)listener {
	if (listener && ![listeners containsObject:listener]) [listeners addObject:listener];
}

-(void) removeListener:(byref id <RWOptionsListener>)listener {
	[listeners removeObject:listener];
}

-(void) notifyDidReload {
	int i;
	for(i = 0; i < [listeners count]; i++) {
		id <RWOptionsListener> listener = [listeners objectAtIndex:i];
		[listener didReloadOptions];
	}
}

-(void)loadUserSettings {
	NSUserDefaults* std = [RWOptions getUserDefaults];
		
	if( [std objectForKey:@"ImagePath"] )
		[self setBaseImagePath:[std stringForKey:@"ImagePath"]];

	if( [std objectForKey:@"SearchInterval"] )
        settings.searchInterval = [std floatForKey:@"SearchInterval"];
		
	if( [std objectForKey:@"ImageInterval"] )
        settings.imageInterval = [std floatForKey:@"ImageInterval"];

	if( [std objectForKey:@"SearchSafeness"] )
		[self setSearchSafeness:[std stringForKey:@"SearchSafeness"]];

	if( [std objectForKey:@"MaxImagePerSearch"] )
        settings.maxImagePerSearch = [std integerForKey:@"MaxImagePerSearch"];
		
	if( [std objectForKey:@"ImageExpiration"] )
        settings.imageExpiration = [std integerForKey:@"ImageExpiration"];
		
	if( [std objectForKey:@"MaxCacheSize"] )
        settings.maxCacheSize = [std integerForKey:@"MaxCacheSize"];
		
	if( [std objectForKey:@"MinImageCount"] )
        settings.minImageCount = [std integerForKey:@"MinImageCount"];
		
	if( [std objectForKey:@"ShowStatus"] )
        settings.showStatus = [std boolForKey:@"ShowStatus"];
		
	if( [std objectForKey:@"ShowFileName"] )
        settings.showFileName = [std boolForKey:@"ShowFileName"];
		
	if( [std objectForKey:@"SocketTimeout"] )
        settings.socketTimeout = [std integerForKey:@"SocketTimeout"];
		
	if ( [std objectForKey:@"IsFadeEnabled"] )
		settings.isFadeEnabled = [std boolForKey:@"IsFadeEnabled"];
		
	if ( [std objectForKey:@"FadeAmount"] )
		settings.fadeAmount = [std integerForKey:@"FadeAmount"];
		
	if ( [std objectForKey:@"IsZoomEnabled"] )
		settings.isZoomEnabled = [std boolForKey:@"IsZoomEnabled"];
		
	if ( [std objectForKey:@"IgnoreHosts"] ) {
		[ignoreHosts removeAllObjects];
		[ignoreHosts addObjectsFromArray:[std stringArrayForKey:@"IgnoreHosts"] ];
	}
	
	if ( [std objectForKey:@"TypeChangeInterval"] )
		settings.typeChangeInterval = [std integerForKey:@"TypeChangeInterval"];
		
	if ( [std objectForKey:@"IsSearchEnabled"] )
		settings.isSearchEnabled = [std boolForKey:@"IsSearchEnabled"];
		
	if ( [std objectForKey:@"LocationSearchWait"] )
		settings.locationSearchWait = [std integerForKey:@"LocationSearchWait"];
		
	if ( [std objectForKey:@"IsITunesHighPriority"] )
		settings.isITunesHighPriority = [std boolForKey:@"IsITunesHighPriority"];
		
	if ( [std objectForKey:@"LocationMaxCount"] )
		settings.locationMaxCount= [std integerForKey:@"LocationMaxCount"];
		
	NSMutableArray *items = [self loadSearchParamItems];
	[self checkMainSearchParamItems:items];
	[self setSearchItems:items];
	
}

-(void) reload {
	[self notifyDidReload];
}

-(NSArray*) getFilePatterns {
	return filePatterns;
}

-(NSArray*) getHostsToIgnore {
	return ignoreHosts;
}

-(SearchParamItem*) getRandomItem {
	return [self getRandomItem:nil];
}

-(SearchParamItem*) getRandomItem:(SearchParamItem*)ignore {
	NSMutableArray *enabledItems = [NSMutableArray arrayWithCapacity:[searchItems count]+1];
	int i;
	for(i = 0; i < [searchItems count]; i++) {
		SearchParamItem *item = [searchItems objectAtIndex:i];
		if ([item isHighPriority] && [item isEnabled] && [item shouldSelect]) return item;
		if (ignore && [item getIdentifier] == [ignore getIdentifier]) continue;
		if ([item isEnabled] && [item shouldSelect]) [enabledItems addObject:item];
	}
	
	RWLog(@"Found %d enabled item(s), ignoring last", [enabledItems count]);
	if ([enabledItems count] == 0) return ignore;
	int n = [RandomSelector getRandomInt:0 max:[enabledItems count]-1];
	return (SearchParamItem*)[enabledItems objectAtIndex:n];
}

-(NSMutableArray*) loadSearchParamItems {
	NSUserDefaults* std = [RWOptions getUserDefaults];
	NSArray *identifiers = [std stringArrayForKey:@"SearchItems"];
	NSMutableArray *items = [NSMutableArray arrayWithCapacity:[identifiers count]+1];
	RWLog(@"Found %d search item(s) in list", [identifiers count]);
	int i;
	for(i = 0; i < [identifiers count]; i++) {
		int identifier = [[identifiers objectAtIndex:i] intValue];
		RWLog(@"Loading search item #%d", identifier);
		SearchParamItem *item = [self loadSearchParamItem:identifier];
		if (item) [items addObject:item];
	}
	return items;
}

-(void) checkMainSearchParamItems:(NSMutableArray*)items {
	
	if ([items count] == 0) {
		GoogleSearchParamItem *item = [[GoogleSearchParamItem alloc] initWithIdentifier:0 enabled:YES type:RWDigitalPhotoSearch keyword:@"" minSize:NSMakeSize(1024,768) searchSize:nil startingPosition:-1];
		RWLog(@"Creating digital photo search param");
		[items addObject:item];
	}
	
	BOOL existsITunesSearchItem = NO;
	
	if ([items count] > 1) {
		SearchParamItem *item = [items objectAtIndex:1];
		if ([item isKindOfClass:[ITunesSearchParamItem class]]) existsITunesSearchItem = YES;
	}
	
	if (!existsITunesSearchItem) {
		RWLog(@"Creating iTunes search param");
		SearchParamItem *iTunesSPI = [[ITunesSearchParamItem alloc] init:NO minSize:NSMakeSize(640, 480)];
		[items insertObject:iTunesSPI atIndex:1];
	}
}

-(void) saveSearchItemsList {
	NSUserDefaults* std = [RWOptions getUserDefaults];
	NSMutableArray *identifiers = [NSMutableArray arrayWithCapacity:[searchItems count]+1];
	int i;
	for(i = 0; i < [searchItems count]; i++) {
		SearchParamItem *item = [searchItems objectAtIndex:i];
		[identifiers addObject:[NSString stringWithFormat:@"%d", [item getIdentifier]]];
	}
	[std setObject:identifiers forKey:@"SearchItems"];
}

-(SearchParamItem*) loadSearchParamItem:(int)identifier {
	NSUserDefaults* std = [RWOptions getUserDefaults];
	NSString *name = [NSString stringWithFormat:@"SearchItem-%d", identifier];
	if ([std objectForKey:name]) {
		RWLog(@"Loading item: %@", name);
		NSDictionary *dict = [std dictionaryForKey:name];
		
		if ([dict objectForKey:@"Class"]) {
			NSString *s = [dict objectForKey:@"Class"];
			if ([s isEqualTo:@"URLSearch"]) {
				return [URLSearchParamItem load:identifier dict:dict];
			} else if ([s isEqualTo:@"iTunesSearch"]) {
				return [ITunesSearchParamItem load:identifier dict:dict];
			}
		} else {
			return [GoogleSearchParamItem load:identifier dict:dict];
		}
	}
	RWLog(@"Didn't know how to load: %@", name);
	return nil;
}

-(void) saveSearchParamItems:(BOOL)sync {
	int i;
	for(i = 0; i < [searchItems count]; i++) {
		SearchParamItem *item = [searchItems objectAtIndex:i];
		//RWLog(@"Item: %@, isDirty: %@", item, [NSNumber numberWithBool:[item isEnabled]]);
		if ([item isDirty]) {
			[self saveSearchParamItem:item sync:NO];
			[item isDirty:NO];
		}
	}
	if (sync) [[RWOptions getUserDefaults] synchronize];		
}

-(BOOL) containsSearchItem:(SearchParamItem*)item {
	return [searchItems containsObject:item];
}

-(void) addSearchParamItem:(SearchParamItem*)item sync:(BOOL)sync {
	[searchItems addObject:item];
	[self saveSearchParamItem:item sync:NO];
	[self saveSearchItemsList];
	if (sync) [[RWOptions getUserDefaults] synchronize];
}

-(void) sync {
	[[RWOptions getUserDefaults] synchronize];
}

-(void) removeSearchParamItem:(SearchParamItem*)item sync:(BOOL)sync {
	int identifier = [item getIdentifier];
	[searchItems removeObject:item];
	NSUserDefaults* std = [RWOptions getUserDefaults];
	NSString *name = [NSString stringWithFormat:@"SearchItem-%d", identifier];
	[std removeObjectForKey:name];
	[self saveSearchItemsList];
	if (sync) [[RWOptions getUserDefaults] synchronize];
}

-(void) saveSearchParamItem:(SearchParamItem*)item sync:(BOOL)sync {
	NSUserDefaults* std = [RWOptions getUserDefaults];
	[item save:std sync:sync];
}

-(NSArray*) getSearchItems {
	return searchItems;
}

-(void) setSearchItems:(NSArray*) items {
	[searchItems removeAllObjects];
	[searchItems addObjectsFromArray:items];
	RWLog(@"Set search item(s), count: %d", [searchItems count]);
}

-(BOOL) containsItemLike:(SearchParamItem*) item {
	int i;
	for(i = 0; i < [searchItems count]; i++) {
		SearchParamItem *it = [searchItems objectAtIndex:i];
		if ([it like:item]) return YES;
	}
	return NO;
}

-(NSString*) getBaseImagePath {
	return imagePath;
}

-(void) setBaseImagePath:(NSString*)s {
	if (imagePath) [imagePath release];
    imagePath = [s retain];
}

-(NSString*) getDigitalPhotoPath {
	return [[self getBaseImagePath] stringByAppendingPathComponent:@"Digital Photos"];
}

-(NSString*) getSitesPath {
	return [[self getBaseImagePath] stringByAppendingPathComponent:@"Sites"];
}

-(NSString*) getPhrasesPath {
	return [[self getBaseImagePath] stringByAppendingPathComponent:@"Phrases"];
}

-(NSString*) getLocationPath {
	return [[self getBaseImagePath] stringByAppendingPathComponent:@"Location"];
}

-(NSString*) getTempPath {
	return [[self getBaseImagePath] stringByAppendingPathComponent:@"Temp"];
}

-(NSString*) getSearchSafeness {
	// Can be active, images, off
	return searchSafeness;
}

-(void) setSearchSafeness:(NSString*)s {
	if (searchSafeness) [searchSafeness release];
    searchSafeness = [s retain];
}

-(RWSimpleSettings*) getSimpleSettings {
	return &settings;
}

-(BOOL) hasConverted {
	NSUserDefaults* std = [RWOptions getUserDefaults];
	if ( [std objectForKey:@"HasConverted"] )
		return [std boolForKey:@"HasConverted"];
	return NO;
}

-(void) setConverted:(BOOL)b {
	NSUserDefaults* std = [RWOptions getUserDefaults];
	[std setBool:b forKey:@"HasConverted"];
}

-(NSString*) getVersion {
	return @"1.3.1";
}

-(BOOL) focusCamera { return YES; } 

-(void) saveSettings { 
	RWLog(@"Saving settings");
	NSUserDefaults* std = [RWOptions getUserDefaults];
	[std setObject:imagePath forKey:@"ImagePath"];
	[std setFloat:settings.searchInterval forKey:@"SearchInterval"];
	[std setFloat:settings.imageInterval forKey:@"ImageInterval"];
	[std setObject:searchSafeness forKey:@"SearchSafeness"];
	[std setInteger:settings.maxImagePerSearch forKey:@"MaxImagePerSearch"];
	[std setInteger:settings.imageExpiration forKey:@"ImageExpiration"];
	[std setInteger:settings.maxCacheSize forKey:@"MaxCacheSize"];
	[std setInteger:settings.minImageCount forKey:@"MinImageCount"];
	[std setBool:settings.showStatus forKey:@"ShowStatus"];
	[std setBool:settings.showFileName forKey:@"ShowFileName"];
	[std setInteger:settings.socketTimeout forKey:@"SocketTimeout"];
	[std setBool:settings.isFadeEnabled forKey:@"IsFadeEnabled"];
	[std setInteger:settings.fadeAmount forKey:@"FadeAmount"];
	[std setBool:settings.isZoomEnabled forKey:@"IsZoomEnabled"];
	[std setInteger:settings.typeChangeInterval forKey:@"TypeChangeInterval"];
	[std setBool:settings.isSearchEnabled forKey:@"IsSearchEnabled"];
	[std setInteger:settings.locationSearchWait forKey:@"LocationSearchWait"];
	[std setBool:settings.isITunesHighPriority forKey:@"IsITunesHighPriority"];
	[std setInteger:settings.locationMaxCount forKey:@"LocationMaxCount"];
	
	[self saveSearchParamItems:NO];
	[self saveSearchItemsList];
	[std synchronize];
}

-(float) getInterval { return settings.imageInterval; }
-(int) getMaxImagePerSearch { return settings.maxImagePerSearch; }
-(int) getImageExpiration { return settings.imageExpiration; }
-(int) getMaxCacheSize { return settings.maxCacheSize; }
-(int) getMinImageCount { return settings.minImageCount; }
-(BOOL) showStatus { return settings.showStatus; }
-(BOOL) showFileName { return settings.showFileName; }
-(int) getSocketTimeout { return settings.socketTimeout; }
-(BOOL) isFadeEnabled { return settings.isFadeEnabled; }
-(int) getFadeAmount { return settings.fadeAmount; }
-(BOOL) isZoomEnabled { return settings.isZoomEnabled; }
-(float) getDefaultWaitBetweenTransfer { return settings.searchInterval; }
-(int) getTypeChangeInterval { return settings.typeChangeInterval; }
-(BOOL) isSearchEnabled { return settings.isSearchEnabled; }
-(int) getLocationSearchWait { return settings.locationSearchWait; }
-(BOOL) isITunesHighPriority { return settings.isITunesHighPriority; }
-(int) getLocationMaxCount { return settings.locationMaxCount; }
	

@end
