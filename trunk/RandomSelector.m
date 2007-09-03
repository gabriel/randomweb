//
//  RandomSelector.m
//  RandomWeb
//
//  Created by Gabriel Handford on Mon Sep 06 2004.
//  Copyright 2004 Gabriel Handford. All rights reserved.
//

#import "RandomSelector.h"
#import <ScreenSaver/ScreenSaver.h>


@implementation RandomSelector

+(int) getRandomInt:(int)min max:(int)max {
	return SSRandomIntBetween(min, max);
}

+(float) getRandomFloat:(float)min max:(float)max {
	return SSRandomFloatBetween(min, max);
}

@end
