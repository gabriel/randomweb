//
//  InfoDataItem.h
//  RandomWeb
//
//  Created by g4b3 on 3/8/05.
//  Copyright 2005 Cellar Door Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface InfoDataItem : NSObject {

	NSString *dir;
	int count;
	float size;

}

-(id) initWithDir:(NSString*)d count:(int)c size:(float)s;
-(NSString*) getDir;
-(int) getCount;
-(float) getSize;

@end
