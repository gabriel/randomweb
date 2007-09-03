//
//  ImageCache.m
//  RandomWeb
//
//  Created by Gabriel Handford on Mon Jul 19 2004.
//  Copyright 2004 Gabriel Handford. All rights reserved.
//

#import "ImageDirectoryCache.h"
#import "RWOptions.h"
#import "RandomSelector.h"
#import "FileUtil.h"
#import "RWLog.h"
#import <ScreenSaver/ScreenSaver.h>

@implementation ImageDirectoryCache

-(id) init {
	return [self init:nil];
}

-(id) init:(SearchParamItem*)item {
	self = [super init];
    if (self) {
		[self load:item];
	}
	return self;
}


-(void) dealloc {
	[cacheDir release];
	[randomImageArray release];
	[super dealloc];
}

/**
 * Load the search item.
 */
-(void) load:(SearchParamItem*)item {	

	if (cacheDir) [cacheDir release];
	cacheDir = [[NSMutableArray alloc] initWithCapacity:100];
	cacheDirSize = 0;
	
	if (randomImageArray) [randomImageArray release];
	randomImageArray = [[NSMutableArray alloc] initWithCapacity:20];

	if (item) {
		NSString *dir = [[item getCompleteImagePath] retain];
		RWLog(@"Using directory: %@", dir);

		[FileUtil ensureDirectoryExists:dir];
		[self readCacheDir:dir];
	}
}

/**
 * Find dictionary entry for path.
 */
-(NSDictionary*) findEntry:(NSString*)path {
	int i;
	for(i = 0; i < [cacheDir count]; i++) {
		NSDictionary *dict = [cacheDir objectAtIndex:i];
		NSString *file = [dict objectForKey:@"path"];
		if ([file isEqualToString:path]) {
			RWLog(@"Found entry: %@ at index: %d", path, i);
			return dict;
		}
	}
	return nil;
}

/**
 * Remove path from cache dir.
 */
-(void) removeFromCacheDir:(NSString*)path {
	NSDictionary *dict = [self findEntry:path];
	if (dict) [cacheDir removeObject:dict];
	//else RWLog(@"Couldn't find %@ in cache dir array", path);
}

+(void) removeTempDir {
	[FileUtil removeFile:[[RWOptions sharedInstance] getTempPath]];
}

/**
 * Check and fix the directories.
 */
+(void) checkDirectories:(id)listener {
	NSString *path = [[RWOptions sharedInstance] getBaseImagePath];
	NSString *dpPath = [[RWOptions sharedInstance] getDigitalPhotoPath];
	[FileUtil ensureDirectoryExists:dpPath];

	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:path];

	SEL sel = @selector(setStatus:);
	if (listener && [listener respondsToSelector:sel]) {
		[listener performSelector:sel withObject:@"Cleaning up directories"];
	}

	NSString* file;
	int count = 0;
	while (file = [enumerator nextObject]) {
		NSString *fullPath = [path stringByAppendingPathComponent:file];
		if ([FileUtil isDirectory:fullPath]) {
			[enumerator skipDescendents];
			continue;
		}
		if ([file hasPrefix:@"."]) continue;
		NSString *toPath = [dpPath stringByAppendingPathComponent:file];
		RWLog(@"Moving %@ to %@", fullPath, toPath);
		[fileManager movePath:fullPath toPath:toPath handler:[FileUtil handler]];
		count++;
	}
}

/**
 * Read all files in path into the cache dir.
 */
-(void) readCacheDir:(NSString*)path {
	[cacheDir removeAllObjects];
	cacheDirSize = 0;
	
	NSMutableArray *files = [NSMutableArray arrayWithCapacity:300];
	[FileUtil readDir:path array:files skipDescendants:YES];
	
	int i;
	for(i = 0; i < [files count]; i++) {
		NSString *file = [files objectAtIndex:i];
		NSString *ext = [[file pathExtension] lowercaseString];
		if ([ext isEqualToString:@"ignore"]) {			
			// Do nothing
		} else if ([ext isEqualToString:@"tmp"]) {
			[self removeFile:file];
		} else {
			NSDictionary *dict = [ImageDirectoryCache createFileEntry:file];
			[self addToCacheDir:dict];
		}
	}
	
	[ImageDirectoryCache sortModDate:cacheDir];
	RWLog(@"Cache directory size: %f (MB), #elements: %d, path: %@", cacheDirSize, [cacheDir count], path);
}



/**
 * Sort the cache dir array by moddate key (Modification time).
 */
+(void) sortModDate:(NSMutableArray*)array {
	// Sort the cache dir
	NSSortDescriptor *sortDesc = [[[NSSortDescriptor alloc] initWithKey:@"moddate" ascending:YES] autorelease];
	[array sortUsingDescriptors: [NSArray arrayWithObject:sortDesc]];
}

/**
 * Remove file.
 * From local cache, then file system.
 */
-(void) removeFile:(NSString*)path {
	[self removeFromCacheDir:path];
	[FileUtil removeFile:path];
}

/**
 * Check file to see if its older than the expire setting.
 * @return YES if its older than expire time (and should probably be deleted)
 */
-(BOOL) checkFile:(NSString*)path {
	int expireDays = [[RWOptions sharedInstance] getImageExpiration];
	if (expireDays > 0) {
		NSDate *moddate = [FileUtil getModificationDate:path];
		if (moddate) {
			if (fabs([moddate timeIntervalSinceNow]) > (60 * 60 * 24 * expireDays)) {
				RWLog(@"Should delete image (older than %d days): %@ [%@]", expireDays, path, [moddate description]);
				return NO;
			}
		}
	}
	return YES;
}

/**
 * Add to cache dir. (New image files only)
 * Moves from the source path to the destination path (if different).
 * Resets the modification date to the current date.
 */
-(void) addToCacheDir:(NSString*)path destPath:(NSString*)destPath {	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSDate date], NSFileModificationDate, nil];
	[fileManager changeFileAttributes:dict atPath:path];
	
	if (![path isEqualToString:destPath]) {
		if (![fileManager movePath:path toPath:destPath handler:self])
			RWLog(@"Error moving source: %@ to dest: %@", path, destPath);
	}
	
	NSDictionary *fileDict = [ImageDirectoryCache createFileEntry:destPath];
	[self addToCacheDir:fileDict];
}

/**
 * Add to cache dir, and add to cache dir size.
 */
-(void) addToCacheDir:(NSDictionary*)dict {
	cacheDirSize += [FileUtil getFileSizeInMB:[dict objectForKey:@"path"]];
	[cacheDir addObject:dict];
}

-(BOOL) fileManager:(NSFileManager *)manager shouldProceedAfterError:(NSDictionary *)errorDict {
	RWLog(@"File operation error: %@ with file: %@", [errorDict objectForKey:@"Error"], [errorDict objectForKey:@"Path"]);
	return NO;
}

/**
 * Create a file entry.
 */
+(NSDictionary*) createFileEntry:(NSString*)path {
	NSDictionary *dictEntry = [NSDictionary dictionaryWithObjectsAndKeys:
		path, @"path",
		[FileUtil getModificationDate:path], @"moddate", nil];
	
	return dictEntry;
}

/**
 * Check the cache dir size (total).
 */
+(void) checkTotalCacheSize:(NSString*)baseDir {

	int count = 0;
	double size = 0.0;
	[FileUtil directoryStats:baseDir traverse:YES count:&count size:&size];
	
	RWLog(@"Current size: %g, Max cache size: %d", size, [[RWOptions sharedInstance] getMaxCacheSize]);
	
	if (size > [[RWOptions sharedInstance] getMaxCacheSize]) {
		float deleteAmount = (size*1.02) - [[RWOptions sharedInstance] getMaxCacheSize];
		RWLog(@"Delete amount (mb): %g", deleteAmount);
		[self deleteSomeCache:deleteAmount path:baseDir];
	}
}

/**
 * Delete some data from the base directory. Deletion in order of oldest directory.
 */
+(void) deleteSomeCache:(float)sizeMB path:(NSString*)baseDir {
	if (sizeMB < 1) return;
	RWLog(@"Deleting some cache: %f", sizeMB);
	int i;
	float deletedAmountMB = 0;
	
	NSMutableArray *files = [NSMutableArray arrayWithCapacity:300];
	[FileUtil readDir:baseDir array:files skipDescendants:NO];
	NSMutableArray *fileDicts = [NSMutableArray arrayWithCapacity:[files count]];
	RWLog(@"Building file dictionary array...");
	for(i = 0; i < [files count]; i++) {
		NSString *path = [files objectAtIndex:i];
		NSDictionary *dict = [self createFileEntry:path];
		[fileDicts addObject:dict];
	}
	RWLog(@"Sorting file dictionary array...");
	[self sortModDate:fileDicts];
	
	RWLog(@"Deleting starting from beginning of dictionary array...");
	for(i = 0; i < [fileDicts count]; i++) {
		if (deletedAmountMB >= sizeMB) return;
		NSDictionary *dict = [fileDicts objectAtIndex:i];
		NSString *file = [dict objectForKey:@"path"];
		//RWLog(@"Deleting file with date: %@", [FileUtil getModificationDate:file]);
		float fileSizeMB = [FileUtil getFileSizeInMB:file];
		if (fileSizeMB > 0) {
			[FileUtil removeFile:file];
			deletedAmountMB += fileSizeMB;
			RWLog(@"Deleted %f mb from cache (%@)", fileSizeMB, file);
		}
	}
}

-(int) count {
	if (cacheDir) return [cacheDir count];
	return 0;
}

-(float) getCacheSize {
	return cacheDirSize;
}

-(NSDictionary*) getRandomPathDict {
	int index = [RandomSelector getRandomInt:0 max:[cacheDir count]-1];
	NSDictionary *dict = [cacheDir objectAtIndex:index];
	return dict;
}

-(NSArray*) getRandomChunk:(int)count except:(NSArray*)except {
	RWLog(@"Getting new random chunk, count: %d, exception size: %d", count, [except count]);
	NSMutableArray *randomChunk = [[NSMutableArray alloc] initWithCapacity:count];
	NSMutableArray *array = [NSMutableArray arrayWithArray:cacheDir];
	int i;
	for(i = 0; i < count && [array count] > 0; i++) {
		int index = [RandomSelector getRandomInt:0 max:[array count]-1];
		NSDictionary *entry = [array objectAtIndex:index];
		NSString *path = [entry objectForKey:@"path"];
		//RWLog(@"Random path: %@", path);
		if (![except containsObject:path]) {
			//RWLog(@"Added random path");
			[randomChunk addObject:path];
		}
		[array removeObjectAtIndex:index];
	}
	return [randomChunk autorelease];
}

-(NSString*) getRandomPath {
	NSDictionary *dict = [self getRandomPathDict];
	if (!dict) return nil;
	NSString *path = [dict objectForKey:@"path"];
	return path;
}

-(NSString*) getRandomImage {
	if ([cacheDir count] == 0) return nil;
	
	int chunkSize = [cacheDir count];
	if (chunkSize > 100) chunkSize = 100;
	
	if ([randomImageArray count] == 1 || [randomImageArray count] <= (chunkSize/4)) {
		[randomImageArray addObjectsFromArray:[self getRandomChunk:chunkSize except:randomImageArray]];
	}
	
	if ([randomImageArray count] == 0) return nil;
		
	NSString *path = (NSString*)[randomImageArray objectAtIndex:0];
	[randomImageArray removeObjectAtIndex:0];
	return path;
}
@end
