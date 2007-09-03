//
//  URLSearchParamItem.m
//  RandomWeb
//
//  Created by g4b3 on 4/13/05.
//  Copyright 2005 Cellar Door Software. All rights reserved.
//

#import "URLSearchParamItem.h"
#import "AGRegex.h"
#import "StringUtil.h"
#import "RWLog.h"
#import "RWOptions.h"
#import "SearchResult.h"
#import "FileUtil.h"
#import "ImageManager.h"

@implementation URLSearchParamItem

-(id) init:(BOOL)e url:(NSString*)surl minSize:(NSSize)s {
	return [self initWithIdentifier:([SearchParamItem getMaxIdentifier]+1) enabled:e url:surl minSize:s lastSearch:[NSDate distantPast]];
}

-(id) initWithIdentifier:(int)i enabled:(BOOL)e url:(NSString*)surl minSize:(NSSize)s lastSearch:(NSDate*)d {
	self = [super initWithIdentifier:i enabled:e minSize:s];
	if (self) {
		url = [[NSURL URLWithString:surl] retain];
		if (!d) d = [NSDate distantPast]; 
		lastSearch = [d retain];
	}
	return self;
}

-(void) dealloc {
	if (url) [url release];
	if (lastSearch) [lastSearch release];
	[super dealloc];
}

-(NSURL*) getSearchURL {
	return url;
}

-(NSURL*) getURL {
	return url;
}

-(NSArray*) getFileExtensions {
	return [NSArray arrayWithObjects:@"jpg",@"gif",@"png",@"tiff",@"jpeg",@"jpe", nil];
}

-(NSString*) getFileExtensionsString:(NSString*)seperator {
	int i;
	NSArray *fe = [self getFileExtensions];
	NSMutableString *fes = [NSMutableString stringWithCapacity:20];
	for(i = 0; i < [fe count]; i++) {
		NSString *s = [fe objectAtIndex:i];
		if (i != ([fe count]-1)) [fes appendFormat:@"%@%@", s, seperator];
		else [fes appendString:s];
	}
	return fes;
}

-(BOOL) isDirectory:(NSString*)path {
	if ([path hasSuffix:@"/"]) return YES;
	NSRange range = [[path lastPathComponent] rangeOfString:@"."];
	if (range.location == NSNotFound) return YES;
	return NO;
}

/**
 * Parse the regex match.
 */
-(BOOL) handleMatch:(AGRegexMatch*)match ignoreHosts:(NSArray*)ignoreHosts listener:(byref id <MatchListener>)listener count:(int)count {
   
	NSString *smatch = [match groupAtIndex:1];
	if (!smatch) {
		RWLog(@"Invalid match");
		return NO;
	}

	//smatch = [StringUtil removeURLEscapes:smatch];
	//smatch = [StringUtil removeURLEscapes:smatch];
	//if (!smatch) {
	//	RWLog(@"URL escapes nullified the object");
	//	return nil;
	//}
	
	//RWLog(@"%@", NSStringFromRange([match rangeAtIndex:1]));
	//RWLog(@"%@", smatch);
	
	NSString *rawURL = [match groupAtIndex:1];
	if (!rawURL) {
		RWLog(@"Invalid (nil) raw url");
		return NO;
	}
	
	// Fix the URLS
	rawURL = [StringUtil removeFromString:rawURL string:@"\""];
	//rawURL = [StringUtil replaceInString:rawURL string:@"\n" replace:@" "];
	rawURL = [StringUtil trim:rawURL];
	NSNumber *port = [url port];
	if ([rawURL hasPrefix:@"/"]) {
		if (port) rawURL = [NSString stringWithFormat: @"%@://%@:%@%@", [url scheme], [url host], port, rawURL];
		else rawURL = [NSString stringWithFormat: @"%@://%@%@", [url scheme], [url host], rawURL];
	} else if ([rawURL hasPrefix:@"http://"]) {
		// Its fine
	} else {
		NSString *path = [url path];
		if (!path) path = @"";
		RWLog(@"Path: %@", path);
		if (![self isDirectory:path]) path = [path stringByDeletingLastPathComponent];
		if (port) rawURL = [NSString stringWithFormat: @"%@://%@:%@/%@/%@", [url scheme], [url host], [url port], path, rawURL];
		else rawURL = [NSString stringWithFormat: @"%@://%@/%@/%@", [url scheme], [url host], path, rawURL];
	}
	
	/**
	if (![rawURL hasPrefix:@"http://"]) rawURL = [NSString stringWithFormat: @"http://%@", rawURL];
	rawURL = [StringUtil removeURLEscapes:rawURL];
	rawURL = [StringUtil removeURLEscapes:rawURL];
	rawURL = [StringUtil addURLEscapes:rawURL];
	*/
	if (!rawURL) {
		RWLog(@"Invalid (nil) raw url after url escapes");
		return NO;
	}
	//RWLog(@"URL: %@", rawURL);
	NSURL *surl = [NSURL URLWithString:rawURL];
	if (!surl) {
		RWLog(@"Invalid (nil) url");
		return NO;
	}
	
	if (ignoreHosts && [ignoreHosts containsObject:[surl host]]) {
		return NO;
	}
	
	RWLog(@"Did find match: %@", surl);
	NSString* savePath = [self getSaveFilePath:surl];
	if (listener) [listener didFindMatch:surl savePath:savePath count:count];
	
	/**
	NSDictionary *dictEntry = [NSDictionary dictionaryWithObjectsAndKeys:
	//[NSNumber numberWithInt:i], @"index",
	//[NSNumber numberWithInt:0], @"width",
	//[NSNumber numberWithInt:0], @"height",
	//[NSNumber numberWithInt:0], @"size",
	surl, @"url", nil];
	return dictEntry;
	*/
	return YES;
}

-(BOOL) searchData:(AGRegex*) regex ignoreHosts:(NSArray*)ignoreHosts listener:(byref id <MatchListener>)listener {
	if (canceled) return NO;
	RWLog(@"Getting enumerator");
	NSEnumerator *iterator = [regex findEnumeratorInString];
	id object;
	int i = 0;
	while(object = [iterator nextObject]) {
		RWLog(@"Handling possible match");
		i++;
		[self handleMatch:(AGRegexMatch*)object ignoreHosts:ignoreHosts listener:listener count:i];
		//if (dict) [matches addObject:dict];
		if (canceled) break;
		int count = [listener downloadCount];
		int maxDownloadCount = [[RWOptions sharedInstance] getLocationMaxCount];
		if (count >= 0 && count >= maxDownloadCount) return NO;
	}
	return YES;
}

-(void) handleInvalidImage:(NSString*)path {
	NSString *destPath = [path stringByAppendingPathExtension:@"ignore"];
	RWLog(@"Invalid image: %@, using touch ignore: %@", [path lastPathComponent], [destPath lastPathComponent]);
	[FileUtil touch:destPath];
	[[[ImageManager sharedInstance] getDirectoryCache] removeFile:path];
}

/**
 * Parse the search data.
 */
-(SearchResult*) parseSearchData:(NSData*)data encoding:(NSString*)encoding maxCount:(int)maxCount ignoreHosts:(NSArray*)ignoreHosts level:(int)level listener:(byref id <MatchListener>)listener {
	NSString *sdata = [StringUtil decodeData:data encoding:encoding];
	
	NSString *fes = [self getFileExtensionsString:@"|"];
	RWLog(@"File extensions: %@", fes);
	
	NSDate *start = [NSDate date];
	
	//NSMutableSet *matches = [[[NSMutableSet alloc] initWithCapacity:200] autorelease];
	BOOL continueSearch = YES;

	NSString *lookupURLS1 = [NSString stringWithFormat:@"<img.*src=\"(.*)\"", fes];
	AGRegex *regexURLS1 = [[AGRegex alloc] initWithPattern:lookupURLS1 options:AGRegexLazy|AGRegexCaseInsensitive string:sdata]; 
	continueSearch &= [self searchData:regexURLS1 ignoreHosts:ignoreHosts listener:listener];
	[regexURLS1 release];
	
	if (continueSearch) {
		NSString *lookupURLS2 = [NSString stringWithFormat:@"<a.*href=\"(.*%@)\"", fes];
		AGRegex *regexURLS2 = [[AGRegex alloc] initWithPattern:lookupURLS2 options:AGRegexLazy|AGRegexCaseInsensitive string:sdata]; 
		continueSearch &= [self searchData:regexURLS2 ignoreHosts:ignoreHosts listener:listener];
		[regexURLS2 release];
	}

	if (continueSearch) {
		NSString *lookupURLS3 = [NSString stringWithFormat:@"<img.*src=([^\"\\S]*%@)", fes];
		AGRegex *regexURLS3 = [[AGRegex alloc] initWithPattern:lookupURLS3 options:AGRegexLazy|AGRegexCaseInsensitive string:sdata]; 
		continueSearch &= [self searchData:regexURLS3 ignoreHosts:ignoreHosts listener:listener];
		[regexURLS3 release];
	}

	if (continueSearch) {
		NSString *lookupURLS4 = [NSString stringWithFormat:@"<a.*href=([^\"\\S]*%@)", fes];
		AGRegex *regexURLS4 = [[AGRegex alloc] initWithPattern:lookupURLS4 options:AGRegexLazy|AGRegexCaseInsensitive string:sdata]; 
		continueSearch &= [self searchData:regexURLS4 ignoreHosts:ignoreHosts listener:listener];
		[regexURLS4 release];
	}
	
	RWLog(@"Match search took: %0.1f secs", -[start timeIntervalSinceNow]);
	
	//NSArray *searchLinks = nil;
	
	/**
	if (level < 1) {
		NSString *lookupURLS5 = @"<a\\s*href=\"(.*[^jpg|^gif|^png|^tiff])\"";
		AGRegex *regexURLS5 = [[[AGRegex alloc] initWithPattern:lookupURLS5 options:AGRegexLazy|AGRegexCaseInsensitive] autorelease]; 
		NSArray *matchesURLS5 = [regexURLS5 findAllInString:sdata];
		searchLinks = matchesURLS5;
	}
	*/
	
	if (listener) [listener didCompleteMatchSearch];
	return nil;
}

-(NSString*) getCompleteImagePath {
	NSString *path = [StringUtil replaceInString:[url path] string:@"/" replace:@"--"];
	RWLog(@"URL host: %@, path: %@", [url host], path);
	NSString *directory = [NSString stringWithFormat:@"%@%@", [url host], path];

	NSString *dir = [[[RWOptions sharedInstance] getLocationPath] stringByAppendingPathComponent:directory];
	RWLog(@"Search param dir: %@", dir);
	return dir;
}

-(NSString*) getSaveFilePath:(NSURL*)u {
	NSString *path = [u path];
	path = [StringUtil trim:path chars:@"/"];
	path = [StringUtil replaceInString:path string:@"//" replace:@"--"];
	path = [StringUtil replaceInString:path string:@"/" replace:@"--"];
	return [[self getCompleteImagePath] stringByAppendingPathComponent: path];
}


-(NSString*) getModeString {
	return [NSString stringWithFormat:@"Location Search: %@", url];
}

-(void) checkResults:(SearchResult*)result {
	if (lastSearch) [lastSearch release];
	lastSearch = [[NSDate date] retain];
	dirtyFlag = YES;
}

+(URLSearchParamItem*) load:(int)identifier dict:(NSDictionary*)dict {
	BOOL isEnabled = [[dict objectForKey:@"IsEnabled"] boolValue];
	NSString* minSize = [dict objectForKey:@"MinSize"];
	NSString* url = [dict objectForKey:@"URL"];
	NSDate *date = [dict objectForKey:@"LastSearch"];
		
	RWLog(@"Creating url search param item with identifier: %d, url: %@, date: %@", identifier, url, date);
	URLSearchParamItem *item = [[URLSearchParamItem alloc] initWithIdentifier:identifier enabled:isEnabled url:url minSize:[SearchParamItem getMinSize:minSize] lastSearch:date];
	return [item autorelease];
}

-(void) save:(NSUserDefaults*)std sync:(BOOL)sync {
	NSString *name = [NSString stringWithFormat:@"SearchItem-%d", identifier];
	RWLog(@"Saving location search item #%d", identifier);
	NSArray *keys = [NSArray arrayWithObjects:@"IsEnabled", @"Class", @"MinSize", @"URL", @"LastSearch", nil];	
	NSArray *values = [NSArray arrayWithObjects:[NSNumber numberWithBool:enabled], [NSString stringWithFormat:@"URLSearch"], [self getMinSizeString], [NSString stringWithFormat:@"%@", url], lastSearch, nil];
	NSDictionary *dict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
	[std setObject:dict forKey:name];
	if (sync) [std synchronize];
}

-(BOOL) like:(SearchParamItem*)i {
	if (![i isKindOfClass:[URLSearchParamItem class]]) return NO;
	URLSearchParamItem *item = (URLSearchParamItem*)i;
	if (!url || ![item getURL]) return NO;
	if ([url isEqual:[item getURL]]) return YES;
	return NO;
}

-(NSString*) getTypeString {
	return @"Location";
}

-(NSString*) getInfoString {
	return [NSString stringWithFormat:@"%@", url];
}

-(void) reset {
	if (lastSearch) [lastSearch release];
	lastSearch = [[NSDate distantPast] retain];
	dirtyFlag = YES;
}

-(NSDate*) getLastSearchDate {
	return lastSearch;
}

-(BOOL) isAggressive { return NO; }

-(float) getWaitBetweenTransfer {
	int searchWait = [[RWOptions sharedInstance] getLocationSearchWait];
	if (lastSearch && fabs([lastSearch timeIntervalSinceNow]) < (60 * 60 * searchWait)) {
		float wait = (60 * searchWait);
		//RWLog(@"Wait %g", wait);
		return wait;
	}
	return [super getWaitBetweenTransfer];
}

-(BOOL) vetoSearch {
	int searchWait = [[RWOptions sharedInstance] getLocationSearchWait];
	if (lastSearch && fabs([lastSearch timeIntervalSinceNow]) < (60 * 60 * searchWait)) {
		RWLog(@"Search already occurred within %d hours, veto-ing", searchWait);
		return YES;
	}
	return NO;
}

-(NSString*) description {
	return [NSString stringWithFormat:@"Location Search, %@ Min Size: %@, URL: %@, Last Search: %@", [super description], [self getMinSizeString], [NSString stringWithFormat:@"%@", url], lastSearch];
}

@end
