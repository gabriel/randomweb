//
//  GoogleSearchParamItem.m
//  RandomWeb
//
//  Created by g4b3 on 2/8/05.
//  Copyright 2005 Cellar Door Software. All rights reserved.
//

#import "GoogleSearchParamItem.h"
#import "RWLog.h"
#import "GoogleImageSearch.h"
#import "RWOptions.h"
#import "AGRegex.h"

static int MAX_QUERY_START = 999;
static int QUERY_INCREMENT = 20;
//static NSString *DEFAULT_KEYWORD_SEARCH_SIZE = @"xxlarge|xlarge";
static NSString *DEFAULT_SEARCH_SIZE_STEP1 = @"xxlarge";
static NSString *DEFAULT_SEARCH_SIZE_STEP2 = @"xlarge";
static NSString *DEFAULT_SEARCH_SIZE_STEP3 = nil;

@implementation GoogleSearchParamItem

-(id) init:(BOOL)e type:(RWSearchType)t keyword:(NSString*)k minSize:(NSSize)m {
	NSString *ssize = nil;
	if (t != RWDigitalPhotoSearch) ssize = DEFAULT_SEARCH_SIZE_STEP1;

	return [self init:e type:t keyword:k minSize:m searchSize:ssize startingPosition:0];
}

-(id) init:(BOOL)e type:(RWSearchType)t keyword:(NSString*)k minSize:(NSSize)m searchSize:(NSString*)s startingPosition:(int)p {
	return [self initWithIdentifier:([SearchParamItem getMaxIdentifier]+1) enabled:e type:t keyword:k minSize:m searchSize:s startingPosition:p];
}

-(id) initWithIdentifier:(int)i enabled:(BOOL)e type:(RWSearchType)t keyword:(NSString*)k minSize:(NSSize)m {
	NSString *ssize = nil;
	if (t != RWDigitalPhotoSearch) ssize = DEFAULT_SEARCH_SIZE_STEP1;

	return [self initWithIdentifier:i enabled:e type:t keyword:k minSize:m searchSize:ssize startingPosition:0];
}

-(id) initWithIdentifier:(int)i enabled:(BOOL)e type:(RWSearchType)t keyword:(NSString*)k minSize:(NSSize)m searchSize:(NSString*)s startingPosition:(int)p {
	self = [super initWithIdentifier:i enabled:e minSize:m];
    if (self) {
		type = t;
		keyword = [k retain];
		searchSize = [s retain];
		startingPosition = p;
		if (p != -1) startingPositionEnabled = YES;
		else startingPositionEnabled = NO;
	}
    return self;
}

-(void) dealloc {
	if (keyword) [keyword release];
	if (searchSize) [searchSize release];
	[super dealloc];
}

-(NSURL*) getSearchURL {
	return [GoogleImageSearch getSearchURLForSearch:self];
}

-(RWSearchType) getType {
	return type;
}

-(NSString*) getKeyword {
	return keyword;
}

-(NSString*) getInfoString {
	if (type == RWDigitalPhotoSearch) return @"Random digital camera photos";
	return keyword;
}

-(NSString*) getSearchSize {
	return searchSize;
}

-(void) setType:(RWSearchType)t {
	type = t;
	dirtyFlag = YES;
}

-(void) setTypeString:(NSString*)value {
	[self setType:[GoogleSearchParamItem getType:value]];
}

+(RWSearchType) getType:(NSString*)value {
	if ([value isEqual:@"Digital Photo"]) return RWDigitalPhotoSearch;
	else if ([value isEqual:@"Site"]) return RWSiteSearch;
	else if ([value isEqual:@"Phrase"]) return RWPhraseSearch;
	
	RWLog(@"Unknown type for string: %@", value);
	return NSNotFound;
}

-(NSString*) getTypeString {
	return [GoogleSearchParamItem getTypeString:type];
}

+(NSString*) getTypeString:(RWSearchType)t {
	switch (t) {
		case RWDigitalPhotoSearch: return @"Digital Photo";
		case RWSiteSearch: return @"Site";
		case RWPhraseSearch: return @"Phrase";
	}
	RWLog(@"Unknown type string for type: %d", (int)t);
	return nil;
}

-(void) setKeyword:(NSString*)k {
	if (keyword) [keyword release];
	keyword = [k retain];
	dirtyFlag = YES;
}

-(void) setSearchSize:(NSString*)s {
	if (searchSize) [searchSize release];
	searchSize = s;
	dirtyFlag = YES;
}

-(NSString*) description {
	return [NSString stringWithFormat:@"Google Search, %@ Type: %@, Keyword: %@, SearchSize: %@, StartingPos: %d, Exhausted: %d", [super description], [self getTypeString], 
		[self getKeyword], [self getSearchSize], [self getStartingPosition], (int)[self isSearchExhausted]];
}

-(int) getStartingPosition {
	return startingPosition;
}

-(BOOL) isStartingPositionEnabled {
	return startingPositionEnabled;
}

-(void) setStartingPosition:(int)s {
	if (!startingPositionEnabled) return;
	startingPosition = s;
	dirtyFlag = YES;
}

-(void) incrementStartingPosition {
	if (!startingPositionEnabled) return;
	startingPosition += QUERY_INCREMENT;
	dirtyFlag = YES;
}

-(BOOL) isSearchExhaustedImpl {
	if (!startingPositionEnabled) return NO;
	return startingPosition > MAX_QUERY_START;
}

-(BOOL) isSearchExhausted {
	[self checkCycleSearchSize];
	return [self isSearchExhaustedImpl];
}

-(void) isSearchExhausted:(BOOL)b {
	if (!startingPositionEnabled) return;
	
	if (b) startingPosition = MAX_QUERY_START+1;
	else startingPosition = 0;
	dirtyFlag = YES;
}

-(BOOL) cycleSearchSize {
	NSString *oldSize = [self getSearchSize];
	[self isSearchExhausted:NO];
	if (!oldSize || [oldSize isEqualTo:@""])  {
		[self setSearchSize:DEFAULT_SEARCH_SIZE_STEP1];
		return YES;
	}
	else if ([oldSize isEqualToString:DEFAULT_SEARCH_SIZE_STEP1]) [self setSearchSize:DEFAULT_SEARCH_SIZE_STEP2];
	else if ([oldSize isEqualToString:DEFAULT_SEARCH_SIZE_STEP2]) [self setSearchSize:DEFAULT_SEARCH_SIZE_STEP3];
	return NO;
}

-(void) checkCycleSearchSize {
	
	if ([self isSearchExhaustedImpl]) {
		[self cycleSearchSize];
	}
}

-(NSString*) getCompleteImagePath {
	switch ([self getType]) {
	case RWSiteSearch:
		return [[[RWOptions sharedInstance] getSitesPath] stringByAppendingPathComponent:[self getKeyword]];
	case RWPhraseSearch:
		return [[[RWOptions sharedInstance] getPhrasesPath] stringByAppendingPathComponent:[self getKeyword]];
	case RWDigitalPhotoSearch:
		return [[RWOptions sharedInstance] getDigitalPhotoPath];
	
	default:
		return nil;
	}
}

-(SearchResult*) parseSearchData:(NSData*)data encoding:(NSString*)encoding maxCount:(int)maxCount ignoreHosts:(NSArray*)ignoreHosts level:(int)level listener:(byref id <MatchListener>)listener {
	return [GoogleImageSearch parseSearchData:data item:self encoding:encoding minSize:minSize maxCount:maxCount ignoreHosts:ignoreHosts];
}

-(NSString*) getModeString {
	NSString *mode = nil;
	switch (type) {
		case RWDigitalPhotoSearch: mode = @"Digital Photo Search"; break;
		case RWSiteSearch: mode = [NSString stringWithFormat:@"Site Search: %@", keyword]; break;
		case RWPhraseSearch: mode = [NSString stringWithFormat:@"Phrase Search: %@", keyword]; break;
	}
	return mode;
}

-(void) checkResults:(SearchResult*)r {
	[self incrementStartingPosition];
	int start = [self getStartingPosition];
		
	GoogleSearchResult *result = (GoogleSearchResult*)r;
		
	if (result && [result getTotal] != -1 && ([result getTotal] <= start || [result getEnd] < start)) {
		RWLog(@"Result total or end is less than starting point, setting the search as exhausted");
		[self isSearchExhausted:YES];		
	}
}

-(void) reset {
	if (type != RWDigitalPhotoSearch) [self setSearchSize: DEFAULT_SEARCH_SIZE_STEP1];
	[self isSearchExhausted:NO];
}

-(BOOL) isDeletable {
	return (type != RWDigitalPhotoSearch);
}

-(NSMutableDictionary*) getSaveDictionary {
	NSArray *keys = [NSArray arrayWithObjects:@"IsEnabled", @"SearchType", @"Keyword", @"MinSize", @"StartingPosition", @"SearchSize", nil];	
	NSArray *values = [NSArray arrayWithObjects:[NSNumber numberWithBool:enabled], [self getTypeString], (keyword ? keyword : @""), [self getMinSizeString], [[NSNumber numberWithInt:startingPosition] stringValue], (searchSize ? searchSize : @""), nil];
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjects:values forKeys:keys];
	return dict;
}

-(void) save:(NSUserDefaults*)std sync:(BOOL)sync {
	NSString *name = [NSString stringWithFormat:@"SearchItem-%d", identifier];
	RWLog(@"Saving Google search item #%d", identifier);
	NSDictionary *dict = [self getSaveDictionary]; 
	[std setObject:dict forKey:name];
	if (sync) [std synchronize];
}

+(GoogleSearchParamItem*) load:(int)identifier dict:(NSDictionary*)dict {
	BOOL isEnabled = [[dict objectForKey:@"IsEnabled"] boolValue];
	NSString* searchType = [dict objectForKey:@"SearchType"];
	NSString* keyword = [dict objectForKey:@"Keyword"];
	NSString* minSize = [dict objectForKey:@"MinSize"];
	int startingPosition = [[dict objectForKey:@"StartingPosition"] intValue];
	NSString* searchSize = [dict objectForKey:@"SearchSize"];
		
	GoogleSearchParamItem *item = [[GoogleSearchParamItem alloc] initWithIdentifier:identifier enabled:isEnabled type:[GoogleSearchParamItem getType:searchType] keyword:keyword minSize:[SearchParamItem getMinSize:minSize] searchSize:searchSize startingPosition:startingPosition];
	return [item autorelease];
}

-(BOOL) like:(SearchParamItem*)i {
	if (![i isKindOfClass:[GoogleSearchParamItem class]]) return NO;
	GoogleSearchParamItem *item = (GoogleSearchParamItem*)i;
	if (!keyword || ![item getKeyword]) return NO;
	if (type == [item getType] && [keyword isEqual:[item getKeyword]]) return YES;
	return NO;
}

-(NSString*) getSaveFilePath:(NSURL*)url {
	NSString *surl = [NSString stringWithFormat: @"%@", url];
	AGRegex *regex1 = [[AGRegex alloc] initWithPattern:@"http://" string:surl];
	NSString *result1 = [regex1 replaceWithString:@""];
	
	AGRegex *regex2 = [[AGRegex alloc] initWithPattern:@"/{1,10}" string:result1];
	NSString *result2 = [regex2 replaceWithString:@"--"];
	
	NSString *path = [[self getCompleteImagePath] stringByAppendingPathComponent:result2];
	path = [path stringByAppendingString:@".tmp"];
	
	[regex1 release];
	[regex2 release];
	return path;
}

@end
