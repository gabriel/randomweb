//
//  RandomSelector.m
//  RandomWeb
//
//  Created by g4b3 on Mon Sep 06 2004.
//  Copyright (c) 2004 Cellar Door Software. All rights reserved.
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
