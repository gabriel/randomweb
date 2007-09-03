//
//  RandomSelector.h
//  RandomWeb
//
//  Created by g4b3 on Mon Sep 06 2004.
//  Copyright (c) 2004 Cellar Door Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RandomSelector : NSObject {

}

+(int) getRandomInt:(int)min max:(int)max;
+(float) getRandomFloat:(float)min max:(float)max;

@end
