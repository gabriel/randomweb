//
//  SearchResult.m
//  RandomWeb
//
//  Created by g4b3 on 4/13/05.
//  Copyright 2005 Cellar Door Software. All rights reserved.
//

#import "SearchResult.h"


@implementation SearchResult

-(id) initWithLinks:(NSArray*)links {
	self = [super init];
    if (self) {
		imageLinks = [links retain];
	}
	return self;
}

-(id) initWithLinks:(NSArray*)links searchLinks:(NSArray*)slinks {
	self = [self initWithLinks:links];
    if (self) {
		searchLinks = [slinks retain];
	}
	return self;
}

-(void) dealloc {
	if (imageLinks) [imageLinks release];
	[super dealloc];
}

-(NSArray*) getLinks {
	return imageLinks;
}

-(NSArray*) getSearchLinks {
	return searchLinks;
}

-(NSString*) description {
	return [NSString stringWithFormat:@"#Links: %d", [imageLinks count]];
}

@end
