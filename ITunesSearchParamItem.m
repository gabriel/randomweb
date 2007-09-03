//
//  ITunesSearchParamItem.m
//  RandomWeb
//
//  Created by Gabriel Handford on 5/5/05.
//  Copyright 2005 Gabriel Handford. All rights reserved.
//

#import "ITunesSearchParamItem.h"
#import "ITunesAccessor.h"
#import "StringUtil.h"
#import "FileUtil.h"
#import "RWOptions.h"
#import "RWLog.h"

@implementation ITunesSearchParamItem

-(id) initWithIdentifier:(int)i enabled:(BOOL)e minSize:(NSSize)ms {
	self = [super initWithIdentifier:i enabled:e type:RWPhraseSearch keyword:nil minSize:ms];
	if (self) {
		needsReload = NO;
	}
	return self;
}

-(NSString*) getCompleteImagePath {
	NSString *artist = [self getKeyword];
	NSString *tempDir = [[RWOptions sharedInstance] getTempPath];
	if (!artist) return tempDir;
	NSString *path = [tempDir stringByAppendingPathComponent:artist];
	[FileUtil ensureDirectoryExists:path]; 
	return path;
}

+(ITunesSearchParamItem*) load:(int)identifier dict:(NSDictionary*)dict {
	BOOL isEnabled = [[dict objectForKey:@"IsEnabled"] boolValue];
	NSString* minSize = [dict objectForKey:@"MinSize"];
		
	ITunesSearchParamItem *item = [[ITunesSearchParamItem alloc] initWithIdentifier:identifier enabled:isEnabled minSize:[SearchParamItem getMinSize:minSize]];
	return [item autorelease];
}

-(void) save:(NSUserDefaults*)std sync:(BOOL)sync {
	NSString *name = [NSString stringWithFormat:@"SearchItem-%d", identifier];
	RWLog(@"Saving iTunes search item #%d", identifier);
	NSArray *keys = [NSArray arrayWithObjects:@"IsEnabled", @"Class", @"MinSize", nil];	
	NSArray *values = [NSArray arrayWithObjects:[NSNumber numberWithBool:enabled], [NSString stringWithFormat:@"iTunesSearch"], [self getMinSizeString], nil];
	NSDictionary *dict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
	[std setObject:dict forKey:name];
	if (sync) [std synchronize];
}

-(BOOL) shouldSelect {
	NSString *kw = [self getKeyword];
	if (kw) return YES;
	else return NO;
}

-(BOOL) isHighPriority {
	return [[RWOptions sharedInstance] isITunesHighPriority];
}

-(NSString*) getKeyword {
	@synchronized(self) {
		if (lastCheckDate && fabs([lastCheckDate timeIntervalSinceNow]) < 5) {
			RWLog(@"Last check too soon, returning cached keyword: %@", keyword);
			return keyword;
		}

		NSString *artist = [ITunesAccessor getCurrentArtistIgnoreVA];
		if (lastCheckDate) [lastCheckDate release];
		lastCheckDate = [[NSDate date] retain];
		
		artist = [StringUtil trim:artist];
		
		if (!artist || [artist isEqual:@""]) {
			if (keyword && !artist) needsReload = YES;
			return nil;
		}
		
		if (keyword && artist && ![keyword isEqual:artist]) needsReload = YES;
		
		[self setKeyword:artist];
	}
	return keyword;
}

-(NSURL*) getSearchURL {
	[self getKeyword];
	return [super getSearchURL];
}

-(NSString*) getModeString {
	if (keyword) return [NSString stringWithFormat:@"iTunes Search: %@", keyword];
	else return @"iTunes Search";
}

-(NSString*) getTypeString {
	return @"iTunes";
}

-(NSString*) getInfoString {
	return @"Searches by current artist";
}

-(BOOL) needsReload {
	if (needsReload) {
		needsReload = NO;
		return YES;
	}
	return NO;
}

-(BOOL) isDeletable {
	return NO;
}

-(NSString*) description {
	return [NSString stringWithFormat:@"iTunes Search, %@", [super description]];
}

@end
