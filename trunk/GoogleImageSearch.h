//
//  GoogleImageSearch.h
//  RandomWeb
//
//  Created by g4b3 on Tue Aug 24 2004.
//  Copyright (c) 2004 Cellar Door Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoogleSearchResult.h"
#import "GoogleImageQuery.h"
#import "GoogleSearchParamItem.h"

@interface GoogleImageSearch : NSObject {

}

+(GoogleSearchResult*) parseSearchData:(NSData*)data item:(GoogleSearchParamItem*)item encoding:(NSString*)encoding minSize:(NSSize)minSize maxCount:(int)maxCount ignoreHosts:(NSArray*)ignoreHosts;

+(GoogleImageQuery*) getImageQueryForSearch:(GoogleSearchParamItem*)item;
+(NSString*) getRandomDigitalPhotoFilename:(NSArray*)filePatterns;
+(NSURL*) getSearchURLForSearch:(GoogleSearchParamItem*)item;

+(int) getNextStartingPoint:(NSData*)data;

+(NSURL*) getNextSearchURL:(int)start sourceURL:(NSURL*)searchURL;

@end
