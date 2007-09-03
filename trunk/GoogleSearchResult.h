//
//  GoogleSearchResult.h
//  RandomWeb
//
//  Created by Gabriel Handford on Tue Sep 28 2004.
//  Copyright 2004 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchResult.h"

@interface GoogleSearchResult : SearchResult {

	int start;
	int end;
	int total;
	int totalLinksOnPage;
}

-(id) initWithLinks:(NSArray*)links start:(int)s end:(int)e total:(int)t totalLinksOnPage:(int)tl;
-(void) dealloc;

-(int) getStart;
-(int) getEnd;
-(int) getTotal;
-(int) getTotalLinksOnPage;

-(NSString*) description;

@end
