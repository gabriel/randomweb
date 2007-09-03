//
//  InfoDataSource.m
//  RandomWeb
//
//  Created by g4b3 on 3/8/05.
//  Copyright 2005 Cellar Door Software. All rights reserved.
//

#import "InfoDataSource.h"
#import "FileUtil.h"
#import "RWOptions.h"
#import "InfoDataItem.h"


@implementation InfoDataSource

-(id) init {
	self = [super init];
	if (self) {
		items = [[NSMutableArray arrayWithCapacity:50] retain];
	}
	return self;
}

-(void) setupGUISettings {
	[items removeAllObjects];

	int i;
	int count = 0;
	double size = 0.0;
	
	int totalCount = 0;
	double totalSize = 0.0;
	
	[imagesDir setStringValue:[[RWOptions sharedInstance] getBaseImagePath]];
	
	NSString *dpsPath = [[RWOptions sharedInstance] getDigitalPhotoPath];
	[FileUtil directoryStats:dpsPath traverse:NO count:&count size:&size];
	[items addObject:[[[InfoDataItem alloc] initWithDir:@"Digital Photos" count:count size:size] autorelease]];
	totalCount += count;
	totalSize += size;
	
	NSString *phrasesPath = [[RWOptions sharedInstance] getPhrasesPath];
	NSArray *psubDirs = [FileUtil getSubDirectories:phrasesPath];
	for(i = 0; i < [psubDirs count]; i++) {
		count = 0;
		size = 0.0;
		NSString *fullPath = [phrasesPath stringByAppendingPathComponent:[psubDirs objectAtIndex:i]];
		[FileUtil directoryStats:fullPath traverse:NO count:&count size:&size];
		[items addObject:[[[InfoDataItem alloc] initWithDir:[NSString stringWithFormat:@"Phrase: %@", [psubDirs objectAtIndex:i]] count:count size:size] autorelease]];
		totalCount += count;
		totalSize += size;
	}
	
	
	NSString *sitesPath = [[RWOptions sharedInstance] getSitesPath];
	NSArray *ssubDirs = [FileUtil getSubDirectories:sitesPath];
	for(i = 0; i < [ssubDirs count]; i++) {
		count = 0;
		size = 0.0;
		NSString *fullPath = [sitesPath stringByAppendingPathComponent:[ssubDirs objectAtIndex:i]];
		[FileUtil directoryStats:fullPath traverse:NO count:&count size:&size];
		[items addObject:[[[InfoDataItem alloc] initWithDir:[NSString stringWithFormat:@"Site: %@", [ssubDirs objectAtIndex:i]] count:count size:size] autorelease]];
		totalCount += count;
		totalSize += size;
	}
	
	NSString *locationPath = [[RWOptions sharedInstance] getLocationPath];
	NSArray *lsubDirs = [FileUtil getSubDirectories:locationPath];
	for(i = 0; i < [lsubDirs count]; i++) {
		count = 0;
		size = 0.0;
		NSString *fullPath = [locationPath stringByAppendingPathComponent:[lsubDirs objectAtIndex:i]];
		[FileUtil directoryStats:fullPath traverse:NO count:&count size:&size];
		[items addObject:[[[InfoDataItem alloc] initWithDir:[NSString stringWithFormat:@"Location: %@", [lsubDirs objectAtIndex:i]] count:count size:size] autorelease]];
		totalCount += count;
		totalSize += size;
	}
	
	[infoTable reloadData];

	[totalCountLbl setIntValue:totalCount];
	[totalSizeLbl setStringValue:[NSString stringWithFormat:@"%.1f", totalSize]];
}

-(void) dealloc {
	[items release];
	[super dealloc];
}

/** 
 * Data source for the NSTableView
 */

-(int)numberOfRowsInTableView:(NSTableView*)tableView {
   return [items count];
}

-(id) tableView:(NSTableView*)tableView objectValueForTableColumn:(NSTableColumn*)tableColumn row:(int)index { 
	
	InfoDataItem *item = [items objectAtIndex:index];

	if ([[tableColumn identifier] isEqual:@"Directory"]) {
		return [item getDir];
	} else if ([[tableColumn identifier] isEqual:@"Size"]) {
		return [NSString stringWithFormat:@"%.1f", [item getSize]];
	}  else if ([[tableColumn identifier] isEqual:@"NumImages"]) {
		return [NSString stringWithFormat:@"%d", [item getCount]];
	} 		
	return @"Column identifiers not set";
}

@end
