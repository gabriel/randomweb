//
//  InfoDataItem.m
//  RandomWeb
//
//  Created by g4b3 on 3/8/05.
//  Copyright 2005 Cellar Door Software. All rights reserved.
//

#import "InfoDataItem.h"


@implementation InfoDataItem

-(id) initWithDir:(NSString*)d count:(int)c size:(float)s {
	self = [super init];
	if (self) {
		dir = [d retain];
		count = c;
		size = s;
	}
	return self;
}

-(NSString*) getDir {
	return dir;
}

-(int) getCount {
	return count;
}

-(float) getSize {
	return size;
}

@end
