//
//  GoogleSearchResult.m
//  RandomWeb
//
//  Created by Gabriel Handford on Tue Sep 28 2004.
//  Copyright 2004 Gabriel Handford. All rights reserved.
//

#import "GoogleSearchResult.h"


@implementation GoogleSearchResult

-(id) initWithLinks:(NSArray*)links start:(int)s end:(int)e total:(int)t totalLinksOnPage:(int)tl {
	self = [super initWithLinks:links];
    if (self) {
		start = s;
		end = e;
		total = t;
		totalLinksOnPage = tl;
	}
	return self;
}

-(void) dealloc {
	if (imageLinks) [imageLinks release];
	[super dealloc];
}

-(int) getStart {
	return start;
}

-(int) getEnd {
	return end;
}

-(int) getTotal {
	return total;
}

-(int) getTotalLinksOnPage {
	return totalLinksOnPage;
}

-(NSArray*) getLinks {
	return imageLinks;
}

-(NSString*) description {
	return [NSString stringWithFormat:@"#Links: %d, Start: %d, End: %d, Total: %d, Total links: %d", [imageLinks count], start, end, total, totalLinksOnPage];
}

@end
