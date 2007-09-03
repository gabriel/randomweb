//
//  RandomSelector.h
//  RandomWeb
//
//  Created by Gabriel Handford on Mon Sep 06 2004.
//  Copyright 2004 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RandomSelector : NSObject {

}

+(int) getRandomInt:(int)min max:(int)max;
+(float) getRandomFloat:(float)min max:(float)max;

@end
