//
//  ITunesSearchParamItem.h
//  RandomWeb
//
//  Created by g4b3 on 5/5/05.
//  Copyright 2005 Cellar Door Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GoogleSearchParamItem.h"

@interface ITunesSearchParamItem : GoogleSearchParamItem {

	BOOL needsReload;
	NSDate *lastCheckDate;

}

-(id) initWithIdentifier:(int)i enabled:(BOOL)e minSize:(NSSize)ms;

@end
