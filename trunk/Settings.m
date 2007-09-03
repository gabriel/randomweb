//
//  SearchParameters.m
//  RandomWeb
//
//  Created by g4b3 on Tue Jun 22 2004.
//  Copyright (c) 2004 Cellar Door Software. All rights reserved.
//

#import "Settings.h"
#import "RandomSelector.h"
#import "FileUtil.h"
#import "RWLog.h"
#import <AppKit/AppKit.h>
#import <ScreenSaver/ScreenSaverDefaults.h>

static Settings *sharedInstance = nil;
static NSLock *sharedLock = nil;
static BOOL hasBeenInitialized = NO;
static int MAX_QUERY_START = 999;
static int QUERY_INCREMENT = 20;
static NSString *DEFAULT_SEARCH_SIZE = @"xxlarge|xlarge";
static NSString *DEFAULT_SEARCH_SIZE_STEP1 = @"xxlarge";
static NSString *DEFAULT_SEARCH_SIZE_STEP2 = @"xlarge";
static NSString *DEFAULT_SEARCH_SIZE_STEP3 = nil;


@implementation Settings

+(Settings*) sharedInstance {
	[sharedLock lock];
	if(!sharedInstance) {
		sharedInstance = [[self alloc] init];
	}
	[sharedLock unlock];
    return sharedInstance;
}

+ (void)initialize {
	[super initialize];
	if (hasBeenInitialized) return;
	hasBeenInitialized = YES;
	sharedLock = [[NSLock alloc] init];
}


-(id) init {
    self = [super init];
    
    if (self) {
		RWLog(@"Loading default settings");
        [self loadDefaultSettings];
		RWLog(@"Loading user settings");
        [self loadUserSettings];
    }
    return self;
}

-(void) dealloc {
	if (imagePath) [imagePath release];
	if (searchSafeness) [searchSafeness release];
	if (phrases) [phrases release];
	if (sites) [sites release];
	if (ignoreHosts) [ignoreHosts release];
	if (filePatterns) [filePatterns release];
	[super dealloc];
}

-(void) loadDefaultSettings {
    settings.minWidthPhoto = 1024;
	settings.minHeightPhoto = 768;
	NSString *s = @"~/Pictures/RandomWeb";
	[self setBaseImagePath:[s stringByExpandingTildeInPath]];
	settings.searchInterval = 2.0;
	settings.imageInterval = 15.0;

	//settings.searchSize = @"xxlarge%7Cxlarge";

	[self setSearchSafeness:@"active"];
	settings.maxImagePerSearch = 10;
	settings.imageExpiration = 30;
	settings.maxCacheSize = 1000;
	settings.minImageCount = 10;
	settings.showStatus = YES;
	settings.showFileName = NO;
	
	settings.isFadeEnabled = YES;
	settings.fadeAmount = 5;
	settings.isZoomEnabled = YES;
	
	settings.isDigitalSearchEnabled = YES;
	
	settings.isSiteSearchEnabled = NO;
	settings.useRandomSite = NO;
	
	settings.isPhraseSearchEnabled = NO;
	settings.useRandomPhrase = NO;
	
	settings.focusCameraPhoto = YES;
	settings.focusCameraSite = YES;
	settings.focusCameraPhrase = YES;
	
	settings.minWidthSite = 640;
	settings.minHeightSite = 480;
	settings.minWidthPhrase = 640;
	settings.minHeightPhrase = 480;
	
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
		
	phrases = [[NSMutableArray arrayWithCapacity:10] retain];
	
	[phrases addObjectsFromArray:
		[NSArray arrayWithObjects:
			@"beer",
			@"party",
			nil] ];
	
	sites = [[NSMutableArray arrayWithCapacity:10] retain];
	[sites addObjectsFromArray:
		[NSArray arrayWithObjects:
			@"imdb.com",
			@"watman.com",
			nil] ];
	
	[self setSelectedSite:@""];
	[self setSelectedPhrase:@""];
	
	settings.socketTimeout = 10;

}

-(NSUserDefaults*) getUserDefaults {
	return [ScreenSaverDefaults defaultsForModuleWithName:@"com.cellardoorsw.randomweb"];
}

-(void)loadUserSettings {
	NSUserDefaults* std = [self getUserDefaults];

    if( [std objectForKey:@"RWMinWidth"] )
        settings.minWidthPhoto = [std integerForKey:@"RWMinWidth"];
		
	if( [std objectForKey:@"RWMinHeight"] )
		settings.minHeightPhoto = [std integerForKey:@"RWMinHeight"];
		
	if( [std objectForKey:@"RWImagePath"] )
		[self setBaseImagePath:[std stringForKey:@"RWImagePath"]];

	if( [std objectForKey:@"RWSearchInterval"] )
        settings.searchInterval = [std floatForKey:@"RWSearchInterval"];
		
	if( [std objectForKey:@"RWImageInterval"] )
        settings.imageInterval = [std floatForKey:@"RWImageInterval"];

	if( [std objectForKey:@"RWSearchSafeness"] )
		[self setSearchSafeness:[std stringForKey:@"RWSearchSafeness"]];

	if( [std objectForKey:@"RWMaxImagePerSearch"] )
        settings.maxImagePerSearch = [std integerForKey:@"RWMaxImagePerSearch"];
		
	if( [std objectForKey:@"RWImageExpiration"] )
        settings.imageExpiration = [std integerForKey:@"RWImageExpiration"];
		
	if( [std objectForKey:@"RWMaxCacheSize"] )
        settings.maxCacheSize = [std integerForKey:@"RWMaxCacheSize"];
		
	if( [std objectForKey:@"RWMinImageCount"] )
        settings.minImageCount = [std integerForKey:@"RWMinImageCount"];
		
	if( [std objectForKey:@"RWShowStatus"] )
        settings.showStatus = [std boolForKey:@"RWShowStatus"];
		
	if( [std objectForKey:@"RWShowFileName"] )
        settings.showFileName = [std boolForKey:@"RWShowFileName"];
		
	if( [std objectForKey:@"RWSocketTimeout3"] )
        settings.socketTimeout = [std integerForKey:@"RWSocketTimeout3"];
		
	if ( [std objectForKey:@"isFadeEnabled"] )
		settings.isFadeEnabled = [std boolForKey:@"isFadeEnabled"];
		
	if ( [std objectForKey:@"FadeAmount"] )
		settings.fadeAmount = [std integerForKey:@"FadeAmount"];
		
	if ( [std objectForKey:@"isZoomEnabled"] )
		settings.isZoomEnabled = [std boolForKey:@"isZoomEnabled"];
		
	if ( [std objectForKey:@"RWMinWidth_Site"] )
        settings.minWidthSite = [std integerForKey:@"RWMinWidth_Site"];
		
	if ( [std objectForKey:@"RWMinHeight_Site"] )
		settings.minHeightSite = [std integerForKey:@"RWMinHeight_Site"];
		
	if ( [std objectForKey:@"RWMinWidth_Phrase"] )
        settings.minWidthPhrase = [std integerForKey:@"RWMinWidth_Phrase"];
		
	if ( [std objectForKey:@"RWMinHeight_Phrase"] )
		settings.minHeightPhrase = [std integerForKey:@"RWMinHeight_Phrase"];
	
	if ( [std objectForKey:@"isDigitalPhotoSearchEnabled"] )
		settings.isDigitalSearchEnabled = [std boolForKey:@"isDigitalPhotoSearchEnabled"];
		
	if ( [std objectForKey:@"isSiteSearchEnabled"] )
		settings.isSiteSearchEnabled = [std boolForKey:@"isSiteSearchEnabled"];
	
	if ( [std objectForKey:@"isPhraseSearchEnabled"] )
		settings.isPhraseSearchEnabled = [std boolForKey:@"isPhraseSearchEnabled"];
		
	if ( [std objectForKey:@"useRandomSite"] )
		settings.useRandomSite = [std boolForKey:@"useRandomSite"];
		
	if ( [std objectForKey:@"useRandomPhrase"] )
		settings.useRandomPhrase = [std boolForKey:@"useRandomPhrase"];
		
	if ( [std objectForKey:@"focusCameraPhoto"] )
		settings.focusCameraPhoto = [std boolForKey:@"focusCameraPhoto"];
		
	if ( [std objectForKey:@"focusCameraSite"] )
		settings.focusCameraSite = [std boolForKey:@"focusCameraSite"];
		
	if ( [std objectForKey:@"focusCameraPhrase"] )
		settings.focusCameraPhrase = [std boolForKey:@"focusCameraPhrase"];
		
	if ( [std objectForKey:@"IgnoreHosts"] ) {
		[ignoreHosts removeAllObjects];
		[ignoreHosts addObjectsFromArray:[std stringArrayForKey:@"IgnoreHosts"] ];
	}
		
	if ( [std objectForKey:@"Phrases"] ) {
		[phrases removeAllObjects];
		[phrases addObjectsFromArray:[std stringArrayForKey:@"Phrases"] ];
	}
	
	if ( [std objectForKey:@"Sites"] ) {
		[sites removeAllObjects];
		[sites addObjectsFromArray:[std stringArrayForKey:@"Sites"] ];
	}
		
	if ( [std objectForKey:@"SelectedPhrase"] )
		selectedPhrase = [[std stringForKey:@"SelectedPhrase"] retain];
		
	if ( [std objectForKey:@"SelectedSite"] )
		selectedSite = [[std stringForKey:@"SelectedSite"] retain];
		
	[self fillSettings];
}

-(void) reload {
	[self fillSettings];
}

-(void) fillSettings {
	// Select random search type (that is enabled)
	searchType = RWDigitalPhotoSearch; // - if none selected, do digital photo search
	NSMutableArray *searchTypes = [[[NSMutableArray alloc] init] autorelease];
	if (settings.isDigitalSearchEnabled) [searchTypes addObject:@"Photo"];
	if (settings.isSiteSearchEnabled) [searchTypes addObject:@"Site"];
	if (settings.isPhraseSearchEnabled) [searchTypes addObject:@"Phrase"];
	
	if (settings.isDigitalSearchEnabled) RWLog(@"Digital photo search enabled");
	if (settings.isSiteSearchEnabled) RWLog(@"Site search enabled");
	if (settings.isPhraseSearchEnabled) RWLog(@"Phrase search enabled");
	
	if ([searchTypes count] != 0) {
		int n = [RandomSelector getRandomInt:0 max:[searchTypes count]-1];
		NSString *entry = [searchTypes objectAtIndex:n];
		if ([entry isEqualToString:@"Photo"]) searchType = RWDigitalPhotoSearch;
		else if ([entry isEqualToString:@"Site"]) searchType = RWSiteSearch;
		else if ([entry isEqualToString:@"Phrase"]) searchType = RWPhraseSearch;
	} else {
		RWLog(@"No search types enabled");
	}
	
	switch(searchType) {
		case RWDigitalPhotoSearch: RWLog(@"Digital photo search selected"); break;
		case RWSiteSearch: RWLog(@"Site search selected"); break;
		case RWPhraseSearch: RWLog(@"Phrase search selected"); break;
	}

		
	// Find random seleted phrase (if set)
	if (searchType == RWPhraseSearch) {
		if (settings.useRandomPhrase) {
			if ([phrases count] != 0) {
				RWLog(@"Finding random phrase");
				int n = [RandomSelector getRandomInt:0 max:[phrases count]-1];
				selectedPhrase = [phrases objectAtIndex:n];
				RWLog(@"Found random phrase: %@", selectedPhrase);
			}
		} else {
			if ([selectedPhrase isEqualToString:@""] && [phrases count] > 0) selectedPhrase = [phrases objectAtIndex:0];
			RWLog(@"Using phrase: %@", selectedPhrase);
		}
	}
	
	// Find random site (if set)
	if (searchType == RWSiteSearch) {
		if (settings.useRandomSite) {
			if ([sites count] != 0) {
				RWLog(@"Finding random site");
				int n = [RandomSelector getRandomInt:0 max:[sites count]-1];
				selectedSite = [sites objectAtIndex:n];
				RWLog(@"Found random site: %@", selectedSite);
			}
		} else {
			if ([selectedSite isEqualToString:@""] && [sites count] > 0) selectedSite = [sites objectAtIndex:0];
			RWLog(@"Using site: %@", selectedSite);
		}
	}
}

-(int) getInteger:(NSString*)key def:(int)def {
	NSUserDefaults* std = [self getUserDefaults];
	if ( [std objectForKey:key] ) return [std integerForKey:key];
	return def;
}

-(NSString*) getString:(NSString*)key def:(NSString*)def {
	NSUserDefaults* std = [self getUserDefaults];
	if ( [std objectForKey:key] ) return [std stringForKey:key];
	return def;
}

-(void) setInteger:(NSString*)key value:(int)value {
	NSUserDefaults* std = [self getUserDefaults];
	[std setInteger:value forKey:key];
	[std synchronize];
}

-(void) setString:(NSString*)key value:(NSString*)value {
	NSUserDefaults* std = [self getUserDefaults];
	[std setObject:value forKey:key];
	[std synchronize];
}

-(void) saveSettings { 
	RWLog(@"Saving settings");
	ScreenSaverDefaults *std = [ScreenSaverDefaults defaultsForModuleWithName:@"com.cellardoorsw.randomweb"];
	[std setInteger:settings.minWidthPhoto forKey:@"RWMinWidth"];
	[std setInteger:settings.minHeightPhoto forKey:@"RWMinHeight"];
	[std setObject:imagePath forKey:@"RWImagePath"];
	[std setFloat:settings.searchInterval forKey:@"RWSearchInterval"];
	[std setFloat:settings.imageInterval forKey:@"RWImageInterval"];
	[std setObject:searchSafeness forKey:@"RWSearchSafeness"];
	[std setInteger:settings.maxImagePerSearch forKey:@"RWMaxImagePerSearch"];
	[std setInteger:settings.imageExpiration forKey:@"RWImageExpiration"];
	[std setInteger:settings.maxCacheSize forKey:@"RWMaxCacheSize"];
	[std setInteger:settings.minImageCount forKey:@"RWMinImageCount"];
	[std setBool:settings.showStatus forKey:@"RWShowStatus"];
	[std setBool:settings.showFileName forKey:@"RWShowFileName"];
	[std setInteger:settings.socketTimeout forKey:@"RWSocketTimeout3"];
	[std setBool:settings.isFadeEnabled forKey:@"isFadeEnabled"];
	[std setInteger:settings.fadeAmount forKey:@"FadeAmount"];
	[std setBool:settings.isZoomEnabled forKey:@"isZoomEnabled"];

    [std setInteger:settings.minWidthSite forKey:@"RWMinWidth_Site"];
	[std setInteger:settings.minHeightSite forKey:@"RWMinHeight_Site"];
	[std setInteger:settings.minWidthPhrase forKey:@"RWMinWidth_Phrase"];
	[std setInteger:settings.minHeightPhrase forKey:@"RWMinHeight_Phrase"];
	[std setBool:settings.isDigitalSearchEnabled forKey:@"isDigitalPhotoSearchEnabled"];
	[std setBool:settings.isSiteSearchEnabled forKey:@"isSiteSearchEnabled"];
	[std setBool:settings.isPhraseSearchEnabled forKey:@"isPhraseSearchEnabled"];
	[std setBool:settings.useRandomSite forKey:@"useRandomSite"];
	[std setBool:settings.useRandomPhrase forKey:@"useRandomPhrase"];
	[std setBool:settings.focusCameraPhoto forKey:@"focusCameraPhoto"];
	[std setBool:settings.focusCameraSite forKey:@"focusCameraSite"];
	[std setBool:settings.focusCameraPhrase forKey:@"focusCameraPhrase"];
	
	[std setObject:sites forKey:@"Sites"];
	[std setObject:phrases forKey:@"Phrases"];
	[std setObject:selectedSite forKey:@"SelectedSite"];
	[std setObject:selectedPhrase forKey:@"SelectedPhrase"];
	[std synchronize];
}

-(NSString*) getSelectedSite {
	return selectedSite;
}

-(NSString*) getSelectedPhrase {
	return selectedPhrase;
}

-(void) setSelectedSite:(NSString*)s {
	if (selectedSite == s) return;
	if (selectedSite) [selectedSite release];
	selectedSite = [s retain];
}

-(void) setSelectedPhrase:(NSString*)s {
	if (selectedPhrase == s) return;
	if (selectedPhrase) [selectedPhrase release];
	selectedPhrase = [s retain];
}

-(void) setHostsToIgnore:(NSMutableArray*)h {
	if (ignoreHosts == h) return;
	if (ignoreHosts) [ignoreHosts release];
	ignoreHosts = [h retain];
}

-(void) setSites:(NSMutableArray*)s {
	if (sites) [sites release];
	sites = [s retain];
}

-(void) setPhrases:(NSMutableArray*)p {
	if (phrases == p) return;
	if (phrases) [phrases release];
	phrases = [p retain];
}

-(NSArray*) getSites {
	return sites;
}

-(NSArray*) getPhrases {
	return phrases;
}

-(NSArray*) getFilePatterns {
    return filePatterns;
}

-(NSString*) getVersion {
	return @"1.1c";
}

-(NSArray*) getHostsToIgnore {
	return ignoreHosts;
}

-(NSSize) getMinSize {
	if (![self useMinSize]) return NSMakeSize(0, 0);

	switch(searchType) {
		case RWDigitalPhotoSearch: return NSMakeSize(settings.minWidthPhoto, settings.minHeightPhoto);
		case RWSiteSearch: return NSMakeSize(settings.minWidthSite, settings.minHeightSite);
		case RWPhraseSearch: return NSMakeSize(settings.minWidthPhrase, settings.minHeightPhrase);
	}
    return NSMakeSize(0, 0);
}

-(BOOL) useMinSize {
	return YES;
}

-(BOOL) focusCamera {
	switch(searchType) {
		case RWDigitalPhotoSearch: return settings.focusCameraPhoto;
		case RWSiteSearch: return settings.focusCameraSite;
		case RWPhraseSearch: return settings.focusCameraPhrase;
	}
	return NO;
}

-(BOOL) useHostsToIgnore {
	return (searchType == RWDigitalPhotoSearch); 
}

-(void) toggleDefaultSearchSize {
	NSString *param = [self getSearchParameterForType];
	if (param) {
		NSString *oldSize = [self getSearchSize];
		if (!oldSize || [oldSize isEqualToString:DEFAULT_SEARCH_SIZE_STEP1]) [self setSearchSize:param searchSize:DEFAULT_SEARCH_SIZE_STEP2];
		else if ([oldSize isEqualToString:DEFAULT_SEARCH_SIZE_STEP2]) [self setSearchSize:param searchSize:DEFAULT_SEARCH_SIZE_STEP3];
		//else if ([oldSize isEqualToString:DEFAULT_SEARCH_SIZE_STEP3]) [self setSearchSize:param searchSize:DEFAULT_SEARCH_SIZE_STEP1];
		//else RWLog(@"Dont know how to toggle from search size: %@", oldSize);
	}
}

-(void) setSearchExhausted {
	[self setQueryStartingCount:MAX_QUERY_START+1];
}

-(int) getQueryStartingCount {
	if (searchType == RWDigitalPhotoSearch) {
		RWLog(@"Starting point always 0 for digital photo searches");
		return 0;
	}

	NSString *param = [self getSearchParameterForType];
	if (!param) {
		RWLog(@"No parameter type specified, returning starting point of 0");
		return 0;
	}
	NSString *key = [param stringByAppendingString:@"_StartCount"];

	int count = [self getInteger:key def:-1];
	if (count > MAX_QUERY_START) {
		RWLog(@"Search exhausted, resetting...");
		return 0;
	} 	
	
	if (count == -1) {
		RWLog(@"No starting point for parameter yet, returning 0");
		return 0;
	}
	return count;
}

-(void) finishedQueryStartingCount:(int)count {
	[self setQueryStartingCount:(count+QUERY_INCREMENT)];
}

-(void) setQueryStartingCount:(int)count {
	[self setQueryStartingCount:count parameter:[self getSearchParameterForType]];
}

-(void) setQueryStartingCount:(int)count parameter:(NSString*)param {
	if (param == nil) return;
	NSString *key = [param stringByAppendingString:@"_StartCount"];
	[self setInteger:key value:count];
	if (count > MAX_QUERY_START) [self toggleDefaultSearchSize];
}

-(void) setBaseImagePath:(NSString*)s {
	if (imagePath) [imagePath release];
    imagePath = [s retain];
}

-(NSString*) getSearchParameterForType {
	switch(searchType) {
		case RWSiteSearch: return selectedSite;
		case RWPhraseSearch: return selectedPhrase;
		case RWDigitalPhotoSearch: return nil;
	}	
	return nil;
}

-(RWSearchType) getSearchType {
	return searchType;
}

-(NSString*) getBaseImagePath {
	return imagePath;
}

-(NSString*) getImagePath {
	switch (searchType) {
	case RWSiteSearch: return [self getSitesPath];
	case RWPhraseSearch: return [self getPhrasesPath];
	case RWDigitalPhotoSearch: return imagePath;
	default: return @"";
	}
}

-(NSString*) getSitesPath {
	return [[self getBaseImagePath] stringByAppendingPathComponent:@"Sites"];
}

-(NSString*) getPhrasesPath {
	return [[self getBaseImagePath] stringByAppendingPathComponent:@"Phrases"];
}

-(NSString*) getFullImagePath {
	switch (searchType) {
	case RWSiteSearch:
	case RWPhraseSearch:
		return [[self getImagePath] stringByAppendingPathComponent:[self getSearchParameterForType]];

	case RWDigitalPhotoSearch:
		return [self getImagePath];
	
	default:
		return nil;
	}
}

-(float) getWaitBetweenTransfer {
	return settings.searchInterval;
}

-(float) getInterval {
	return settings.imageInterval;
}

-(NSString*) getSearchSize {
	// Can be xxlarge, medium|large|xlarge
	// All sizes is an empty string
	// @"xxlarge%7Cxlarge"
	if (![self useSearchSize]) return nil;
	
	NSString *param = [self getSearchParameterForType];
	if (param) {
		NSString *key = [param stringByAppendingString:@"_SearchSize"];
		NSString *val = [self getString:key def:DEFAULT_SEARCH_SIZE_STEP1];
		if ([val isEqualToString:@""]) return nil;
		return val;
	}
	
	RWLog(@"Return default search size");
	return DEFAULT_SEARCH_SIZE;
}

-(void) setSearchSize:(NSString*)param searchSize:(NSString*)searchSize {
	if (param == nil) return;
	if (!searchSize) searchSize = @"";
	RWLog(@"Setting search size for param: %@, size: %@", param, searchSize);
	NSString *key = [param stringByAppendingString:@"_SearchSize"];
	[self setString:key value:searchSize];
}

-(BOOL) useSearchSize {
	return YES; //YES; //(searchType == RWDigitalPhotoSearch);
}

-(void) setSearchSafeness:(NSString*)s {
	if (searchSafeness) [searchSafeness release];
    searchSafeness = [s retain];
}

-(NSString*) getSearchSafeness {
	// Can be active, images, off
	return searchSafeness;
}

-(int) getMaxImagePerSearch {
	return settings.maxImagePerSearch;
}

-(int) getImageExpiration {
	return settings.imageExpiration;
}

-(int) getMaxCacheSize {
	return settings.maxCacheSize;
}

-(int) getMinImageCount {
	return settings.minImageCount;
}

-(BOOL) showStatus {
	return settings.showStatus;
}

-(BOOL) showFileName {
	return settings.showFileName;
}

-(int) getSocketTimeout {
	return settings.socketTimeout;
}

-(BOOL) isFadeEnabled {
	return settings.isFadeEnabled;
}

-(int) getFadeAmount {
	return settings.fadeAmount;
}

-(BOOL) isZoomEnabled {
	return settings.isZoomEnabled;
}

-(RWSettings*) settingsStruct {
	return &settings;
}

-(void) getCacheStats:(NSString*)path traverse:(BOOL)traverse count:(int*)count size:(float*)size {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:path];

	NSString* file;
	while (file = [enumerator nextObject]) {
		file = [path stringByAppendingPathComponent:file];
		if ([FileUtil isDirectory:file]) {
			if (!traverse) [enumerator skipDescendents];
			continue;
		}
		NSDictionary *fattrs = [fileManager fileAttributesAtPath:file traverseLink:NO];
		NSNumber *fsize;
		if (fsize = [fattrs objectForKey:NSFileSize]) {
			double mb = [fsize floatValue]/1000000.0;
			(*size) += mb;
			(*count)++;
		}

	}
}
@end
