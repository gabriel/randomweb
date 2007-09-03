//
//  RWLog.h
//  RandomWeb
//
//  Created by Gabriel Handford on Fri Oct 08 2004.
//  Copyright 2004 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>

static void RWLog(NSString *format, ...) {
#ifdef LOG	
	@try {
		va_list argList;
		va_start(argList, format);
		NSString *formattedString = [[NSString alloc] initWithFormat:format arguments:argList];
		va_end(argList);
		NSLog(@"%@", formattedString);
		[formattedString release];
	} @catch(NSException *nse) {
		NSLog(@"Unknown error logging string");
	}
#endif
}