//
//  ITunesSearchParamItem.h
//  RandomWeb
//
//  Created by Gabriel Handford on 5/5/05.
//  Copyright 2005 Gabriel Handford. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GoogleSearchParamItem.h"

@interface ITunesSearchParamItem : GoogleSearchParamItem {

	BOOL needsReload;
	NSDate *lastCheckDate;

}

-(id) initWithIdentifier:(int)i enabled:(BOOL)e minSize:(NSSize)ms;

@end
