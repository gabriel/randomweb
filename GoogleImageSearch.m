//
//  GoogleImageSearch.m
//  RandomWeb
//
//  Created by Gabriel Handford on Tue Aug 24 2004.
//  Copyright 2004 Gabriel Handford. All rights reserved.
//

#import "GoogleImageSearch.h"
#import "ImageProcessor.h"
#import "AGRegex.h"
#import "RWOptions.h"
#import "RandomSelector.h"
#import "StringUtil.h"
#import "RWLog.h"

@implementation GoogleImageSearch

+(GoogleImageQuery*) getImageQueryForSearch:(GoogleSearchParamItem*)item {

	GoogleImageQuery *query = nil;

	RWSearchType type = [item getType];
	switch(type) {
		case RWDigitalPhotoSearch: {
			NSString *keyword = [GoogleImageSearch getRandomDigitalPhotoFilename:[[RWOptions sharedInstance] getFilePatterns]];
			query = [[[GoogleImageQuery alloc] initWithDigitalPhotoQuery:keyword safeness:[[RWOptions sharedInstance] getSearchSafeness] size:[item getSearchSize]] autorelease];
			break;
		}

		case RWPhraseSearch: {
			query = [[[GoogleImageQuery alloc] initWithPhraseQuery:[item getKeyword] safeness:[[RWOptions sharedInstance] getSearchSafeness] size:[item getSearchSize]] autorelease];
			break;
		}

		case RWSiteSearch: {
			query = [[[GoogleImageQuery alloc] initWithSiteQuery:[item getKeyword] safeness:[[RWOptions sharedInstance] getSearchSafeness] size:[item getSearchSize]] autorelease];
			break;
		}
	}
	
	if (query) {
		if ([item isStartingPositionEnabled]) {
			[query setStart:[item getStartingPosition]];
		}
	}
	return query;
}

+(NSString*) getRandomDigitalPhotoFilename:(NSArray*)filePatterns {
	// Get random file pattern
    int index = [RandomSelector getRandomInt:0 max:([filePatterns count]-1)]; //random() % [filePatterns count]; //SSRandomIntBetween( 1, [filePatterns count] );
	NSString *fpat = [filePatterns objectAtIndex:index];
	
	RWLog(@"Selected file pattern: %@", fpat);
	
	if (!fpat) {
		RWLog(@"File pattern was null, array count: %d", [filePatterns count]);
		return NULL;
	}
      
	NSString *digitHolder = @"#";
    NSMutableString *fpatm = [[[NSMutableString alloc] init] autorelease];
    [fpatm setString: fpat];
    
    while (YES) {
        int ndigit = [RandomSelector getRandomInt:0 max:9];//random() % 9; //SSRandomIntBetween( -1, 10 );
        NSString *digit = [[NSString alloc] initWithFormat: @"%d", ndigit];
        NSRange range = [fpatm rangeOfString: digitHolder];
        if (range.length < 1) break;
        [fpatm replaceOccurrencesOfString: digitHolder withString: digit options: NSAnchoredSearch range: range];
        [digit release];
    }
	
	RWLog(@"Filled in search pattern: %@", fpatm);
	return fpatm;
}

+(NSURL*) getSearchURLForSearch:(GoogleSearchParamItem*)item {
	GoogleImageQuery *query = [self getImageQueryForSearch:item];
	if (!query) return nil;
	NSURL *url = [query getURL];
	return url;
}

+(int) getNextStartingPoint:(NSData*)data {
	//NSString *sdata = [[NSString alloc] initWithBytesNoCopy: (void *)[data bytes] length: [data length] encoding: NSISOLatin1StringEncoding freeWhenDone:NO];
	NSString *sdata = [[NSString alloc] initWithBytesNoCopy: (void *)[data bytes] length: [data length] encoding:NSUTF8StringEncoding freeWhenDone:NO];

	NSString *lookupHitRange = @"<b>(\\d*)</b> - <b>(\\d*)</b>.*<b>(\\d*)</b>";
	AGRegex *regexHitRange = [[AGRegex alloc] initWithPattern:lookupHitRange options:AGRegexLazy string:sdata];
	NSArray *matchesHitRange = [regexHitRange findAllInString];
	
	int value = -1;
	
	if ([matchesHitRange count] > 0) {
		AGRegexMatch *match = [matchesHitRange objectAtIndex:0];
		int end = [[match groupAtIndex:2] intValue];
		int totalCount = [[match groupAtIndex:3] intValue];

		if (totalCount > end) { 
			value = end;
		} else {
			RWLog(@"Total count: %d, larger than end: %d", totalCount, end);
		}
	} else {
		RWLog(@"No match for: %@", lookupHitRange);
	}
	[regexHitRange release];
	return value;
}

+(NSURL*) getNextSearchURL:(int)start sourceURL:(NSURL*)searchURL {
	if (start < 0) return nil;
	
	NSString *surl = [searchURL absoluteString];
	// & = %26 in url escape code
	NSString *nextURL = [surl stringByAppendingString:[NSString stringWithFormat:@"&start=%d", start]];
	
	if (nextURL) return [NSURL URLWithString:nextURL];
	return nil;
}

/**
 * Parses the html from search return and extracts all the urls
 * @return an array of dictionary objects containing:
 *		   url - NSURL
 *		   width - NSNumber
 *		   height - NSNumber
 *		   index - NSNumber
 *
 * Returned search result, links array is pre-sorted on the width field (ascending).
 */
+(GoogleSearchResult*) parseSearchData:(NSData*)data item:(GoogleSearchParamItem*)item encoding:(NSString*)encoding minSize:(NSSize)minSize maxCount:(int)maxCount ignoreHosts:(NSArray*)ignoreHosts {
	
	NSString *sdata = [StringUtil decodeData:data encoding:encoding];
	
	RWLog(@"Data length: %d", [data length]);
	
	RWLog(@"String length: %d", [sdata length]);
	
    // Get all data like: /imgres?imgurl=www.replayer.com/other/2000-09-09_elaine%27s_shower/DCP00987.jpg
	NSString *lookupURLS = @"\\/imgres\\?imgurl\\=(.*)&";
	AGRegex *regexURLS = [[[AGRegex alloc] initWithPattern:lookupURLS options:AGRegexLazy|AGRegexCaseInsensitive string:sdata] autorelease]; 
	NSArray *matchesURLS = [regexURLS findAllInString];
	
	NSString *lookupSizes = @"(\\d*) x (\\d*) - (\\d*)k";
	AGRegex *regexSizes = [[[AGRegex alloc] initWithPattern:lookupSizes options:AGRegexLazy|AGRegexCaseInsensitive string:sdata] autorelease];
	NSArray *matchesSizes = [regexSizes findAllInString];
	
	NSMutableArray *matchURLSArray = [[[NSMutableArray alloc] init] autorelease];
	NSMutableArray *matchSizesArray = [[[NSMutableArray alloc] init] autorelease];
	
	NSMutableArray *matchArray = [[[NSMutableArray alloc] init] autorelease];
	
	int i = 0;
	RWLog(@"Running through %d matches", [matchesURLS count]);
    for (i = 0; i < [matchesURLS count]; i++) {
		AGRegexMatch *match = [matchesURLS objectAtIndex:i];
		NSString *smatch = [match groupAtIndex:1];
		if (!smatch) {
			RWLog(@"Invalid match");
			continue;
		}
		//[smatch decomposedStringWithCanonicalMapping];
		
		//RWLog(@"Before url remove escapes: %@", smatch);
		smatch = [StringUtil removeURLEscapes:smatch];
		smatch = [StringUtil removeURLEscapes:smatch];
		if (!smatch) {
			RWLog(@"URL escapes nullified the object");
			continue;
		}
		
		RWLog(@"%d: %@", i, NSStringFromRange([match rangeAtIndex:1]));
        RWLog(@"%@", smatch);
		
		NSString *rawURL = [match groupAtIndex:1];
		if (!rawURL) {
			RWLog(@"Invalid (nil) raw url");
			continue;
		}
		
		if (![rawURL hasPrefix:@"http://"]) rawURL = [NSString stringWithFormat: @"http://%@", rawURL];
		rawURL = [StringUtil removeURLEscapes:rawURL];
		rawURL = [StringUtil removeURLEscapes:rawURL];
		rawURL = [StringUtil addURLEscapes:rawURL];
		if (!rawURL) {
			RWLog(@"Invalid (nil) raw url after url escapes");
			continue;
		}
		NSURL *url = [NSURL URLWithString:rawURL];
		if (url) [matchURLSArray addObject:url];
		else {
			RWLog(@"Invalid (nil) url");
			continue;
		}
		
		// Sizes
		if (i >= [matchesSizes count]) {
			RWLog(@"WARNING: regex match counts do not match, breaking out");
			break;
		}
		AGRegexMatch *matchSize = [matchesSizes objectAtIndex:i];
		
		//RWLog(@"Checking URL: %@", url);
		if (ignoreHosts && [ignoreHosts containsObject:[url host]]) {
			//RWLog(@"Ignored host: %@", [url host]);
			continue;
		}
		
		NSNumber *index = [NSNumber numberWithInt:i];
		NSNumber *width = [NSNumber numberWithInt:[[matchSize groupAtIndex:1] intValue]];
		NSNumber *height = [NSNumber numberWithInt:[[matchSize groupAtIndex:2] intValue]];
		NSNumber *size = [NSNumber numberWithInt:[[matchSize groupAtIndex:3] intValue]];
		
		if ([width intValue] < minSize.width || [height intValue] < minSize.height) {
			RWLog(@"Width or height less than minimum");
			continue;
		}
		
		NSString* savePath = [item getSaveFilePath:url];
		
		NSDictionary *dictEntry = [NSDictionary dictionaryWithObjectsAndKeys:
		index, @"index",
		width, @"width",
		height, @"height",
		size, @"size",
		url, @"url",
		savePath, @"savePath", nil];
		[matchSizesArray addObject:dictEntry];
    }
	
	// Sort sizes
	NSSortDescriptor *sortDesc = [[[NSSortDescriptor alloc] initWithKey:@"width" ascending:YES] autorelease];
	[matchSizesArray sortUsingDescriptors: [NSArray arrayWithObject:sortDesc]];
	
	for (i = 0; i < [matchSizesArray count] && i < maxCount; i++) {
		NSDictionary *dict = [matchSizesArray objectAtIndex:i];
		//RWLog(@"%@ -- %d x %d", [dict objectForKey:@"url"], [[dict objectForKey:@"width"] intValue], [[dict objectForKey:@"height"] intValue]);
		[matchArray addObject:dict];
	}
	
	// Check result range and max hits	
	NSString *lookupHitRange = @"Results <b>(.*)</b> - <b>(.*)</b>.*<b>(.*)</b>";
	AGRegex *regexHitRange = [[[AGRegex alloc] initWithPattern:lookupHitRange options:AGRegexLazy string:sdata] autorelease];
	NSArray *matchesHitRange = [regexHitRange findAllInString];
	
	int start = -1;
	int end = -1;
	int total = -1;
	
	if ([matchesHitRange count] > 0) {
		AGRegexMatch *match = [matchesHitRange objectAtIndex:0];
		
		NSString *sStart = [StringUtil removeFromString:[match groupAtIndex:1] string:@","];
		NSString *sEnd = [StringUtil removeFromString:[match groupAtIndex:2] string:@","];
		NSString *sTotal = [StringUtil removeFromString:[match groupAtIndex:3] string:@","];
		
		start = [sStart intValue];
		end = [sEnd intValue];
		total = [sTotal intValue];
	} else {
		RWLog(@"No match for: %@", lookupHitRange);
	}

	RWLog(@"Returning %d matches", [matchArray count]);
	
	//[sdata release];
	
	GoogleSearchResult *result = [[[GoogleSearchResult alloc] initWithLinks:matchArray start:start end:end total:total totalLinksOnPage:[matchesURLS count]] autorelease];
	return result;
}

@end
