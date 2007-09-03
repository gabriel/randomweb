//
//  GoogleImageQuery.m
//  RandomWeb
//
//  Created by Gabriel Handford on Tue Aug 24 2004.
//  Copyright 2004 Gabriel Handford. All rights reserved.
//

#import "GoogleImageQuery.h"
#import "RWLog.h"
#import "StringUtil.h"


@implementation GoogleImageQuery

-(id) init {
	self = [super init];
    if (self) {
		_phrase = nil;
		_safeness = nil;
		_size = nil;
		_fileType = nil;
    }
    return self;
}

-(id) initWithSiteQuery:(NSString*)host safeness:(NSString*)safeness size:(NSString*)size {
	self = [super init];
    if (self) {
		_phrase = [[NSString stringWithFormat:@"+site:%@", host] retain];
		_safeness = [safeness retain];
		_size = [size retain];
	}
    return self;
	
}

-(id) initWithPhraseQuery:(NSString*)phrase safeness:(NSString*)safeness size:(NSString*)size {
	self = [super init];
    if (self) {
		_phrase = [[self parsePhraseKeyword:phrase] retain];
		_safeness = [safeness retain];
		_size = [size retain];
	}
    return self;
	
}

-(id) initWithDigitalPhotoQuery:(NSString*)fileName safeness:(NSString*)safeness size:(NSString*)size {
	self = [super init];
    if (self) {
		_phrase = [fileName retain];
		_safeness = [safeness retain];
		_size = [size retain];
		_fileType = [@"jpg" retain];
    }
    return self;
}

-(void) dealloc {
	if (_phrase) [_phrase release];
	if (_safeness) [_safeness release];
	if (_size) [_size release];
	if (_fileType) [_fileType release];
	[super dealloc];
}

-(void) setStart:(int)start {
	_start = start;
}

-(NSString*) parsePhraseKeyword:(NSString*)keyword {
	if (!keyword) return nil;
	NSMutableString *searchWords = [NSMutableString stringWithCapacity:[keyword length]];
	NSArray *words = [keyword componentsSeparatedByString:@","];
	int i;
	for(i = 0; i < [words count]; i++) {
		[searchWords appendString:[StringUtil trim:(NSString*)[words objectAtIndex:i]]];
		if ((i+1) != [words count]) [searchWords appendString:@" OR "];
	}
	return searchWords;
}

-(NSURL*) getURL {

	NSMutableString *surl = [[[NSMutableString alloc] initWithCapacity:255] autorelease];
	[surl appendString:@"http://images.google.com/images?"];
	
	if (_phrase && ![_phrase isEqualTo:@""]) [surl appendFormat:@"q=%@", _phrase];
	if (_fileType && ![_fileType isEqualTo:@""]) [surl appendFormat:@"+filetype:%@", _fileType];
	
	[surl appendString:@"&hl=en&lr=lang_en&ie=UTF-8"];
	
	if (_safeness && ![_safeness isEqualTo:@""]) [surl appendFormat:@"&safe=%@", _safeness];
	[surl appendString:@"&sa=G"];
	if (_size && ![_size isEqualTo:@""]) [surl appendFormat:@"&imgsz=%@", _size];
	
	if (_start > 0) [surl appendFormat:@"&start=%d", _start];
	
	RWLog(@"Got URL string: %@", surl);
	NSString *esurl = [StringUtil addURLEscapes:surl];
	
	
	if (esurl) {
		RWLog(@"Escaped string: %@", esurl);
		return [NSURL URLWithString:esurl];
	}
	return [NSURL URLWithString:surl];
}

@end
