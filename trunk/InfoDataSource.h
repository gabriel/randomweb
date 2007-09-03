//
//  InfoDataSource.h
//  RandomWeb
//
//  Created by Gabriel Handford on 3/8/05.
//  Copyright 2005 Gabriel Handford. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface InfoDataSource : NSObject {

	IBOutlet id infoTable;
	
	IBOutlet id totalSizeLbl;
	IBOutlet id totalCountLbl;
	
	IBOutlet id imagesDir;
	
	NSMutableArray *items;
}

-(id) init;
-(void) setupGUISettings;

@end
