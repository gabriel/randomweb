//
//  ImageCache.h
//  RandomWeb
//
//  Created by g4b3 on Mon Jul 19 2004.
//  Copyright (c) 2004 Cellar Door Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoogleSearchParamItem.h"

@interface ImageDirectoryCache : NSObject {
	NSMutableArray *cacheDir;
	float cacheDirSize;
	
	NSMutableArray *randomImageArray;
}

-(id) init;
-(id) init:(SearchParamItem*)item;
-(void) dealloc;

-(int) count;

-(NSString*) getRandomImage;

-(void) readCacheDir:(NSString*)path;

+(NSDictionary*) createFileEntry:(NSString*)path;
+(void) sortModDate:(NSMutableArray*)array;

-(void) addToCacheDir:(NSDictionary*)dict;
-(void) addToCacheDir:(NSString*)path destPath:(NSString*)destPath;

-(void) removeFile:(NSString*)path;

-(BOOL) checkFile:(NSString*)path;

-(float) getCacheSize;

-(void) load:(SearchParamItem*)item;

+(void) checkTotalCacheSize:(NSString*)baseDir;
+(void) deleteSomeCache:(float)sizeMB path:(NSString*)baseDir;
+(void) checkDirectories:(id)listener;
+(void) removeTempDir;
-(void) removeFromCacheDir:(NSString*)path;

@end
