//
//  FileUtil.h
//  RandomWeb
//
//  Created by g4b3 on Wed Sep 29 2004.
//  Copyright (c) 2004 Cellar Door Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FileUtil : NSObject {

}

+(BOOL) isDirectory:(NSString*)path;
+(BOOL) pathContainsDirectory:(NSString*)path;
+(void) directoryStats:(NSString*)path traverse:(BOOL)traverse count:(int*)count size:(double*)size;
+(NSArray*) getSubDirectories:(NSString*)path;
+(BOOL) ensureDirectoryExists:(NSString*)p;

+(float) getFileSizeInMB:(NSString*)path;
+(void) readDir:(NSString*)path array:(NSMutableArray*)array skipDescendants:(BOOL)skipDescendants;
+(NSDate*) getModificationDate:(NSString*)path;

+(BOOL) removeFile:(NSString*)dir;
+(BOOL) touch:(NSString*)path;
+(FileUtil*) handler;

@end
