//
//  SearchResult.h
//  RandomWeb
//
//  Created by Gabriel Handford on 4/13/05.
//  Copyright 2005 Gabriel Handford. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SearchResult : NSObject {
	NSArray *imageLinks;
	NSArray *searchLinks;
}

-(id) initWithLinks:(NSArray*)links;
-(id) initWithLinks:(NSArray*)links searchLinks:(NSArray*)searchLinks;

-(void) dealloc;

-(NSArray*) getLinks;
-(NSArray*) getSearchLinks;
-(NSString*) description;

@end
