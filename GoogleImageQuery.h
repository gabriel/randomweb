//
//  GoogleImageQuery.h
//  RandomWeb
//
//  Created by Gabriel Handford on Tue Aug 24 2004.
//  Copyright 2004 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GoogleImageQuery : NSObject {

	NSString *_phrase;
	NSString *_safeness;
	NSString *_size;
	NSString *_fileType;
	int _start;

}

//
// Size:
//   Options: xxlarge, xlarge, large, medium, small
//   Seperator: %7C
//   Example: xxlarge%7Cxlarge
//
// Safeness:
//   Options: active, images, off
//


-(id) initWithSiteQuery:(NSString*)host safeness:(NSString*)safeness size:(NSString*)size;
-(id) initWithPhraseQuery:(NSString*)phrase safeness:(NSString*)safeness size:(NSString*)size;
-(id) initWithDigitalPhotoQuery:(NSString*)fileName safeness:(NSString*)safeness size:(NSString*)size;
-(void) dealloc;
-(void) setStart:(int)start;
-(NSURL*) getURL;
-(NSString*) parsePhraseKeyword:(NSString*)keyword;

@end
