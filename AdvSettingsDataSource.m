//
//  AdvSettingsDataSource.m
//  RandomWeb
//
//  Created by g4b3 on 2/19/05.
//  Copyright 2005 Cellar Door Software. All rights reserved.
//

#import "AdvSettingsDataSource.h"
#import "RWOptions.h"
#import "RWLog.h"

@implementation AdvSettingsDataSource

-init {
    self = [super init];
	if (self) {
		rootNode = [[SettingsNode alloc] init:@"Settings" value:nil identifier:-1];
		[rootNode setLongDesc:@"Select a setting to view its description, change a setting by clicking on its value."];
		
		[self buildNodes];
	}
    return self;
}

-(void) setupGUISettings {
	[outlineView expandItem:rootNode expandChildren:YES];
	
	NSString *searchSafeness = [[RWOptions sharedInstance] getSearchSafeness];
	if ([searchSafeness isEqualToString:@"off"]) [safeSearch setState:1 atRow:2 column:0];
	else if ([searchSafeness isEqualToString:@"images"]) [safeSearch setState:1 atRow:1 column:0];
	else if ([searchSafeness isEqualToString:@"active"]) [safeSearch setState:1 atRow:0 column:0];
}

-(void) buildNodes {
	RWSimpleSettings *settings = [[RWOptions sharedInstance] getSimpleSettings];

	SettingsNode *node = nil;
	
	node = [[[SettingsNode alloc] init:@"Search interval (minutes)" value:[NSString stringWithFormat:@"%g", settings->searchInterval] identifier:1 isFloat:YES] autorelease];
	[node setLongDesc:@"This specifies how long to wait between searches. When a search is finished, it will wait this many minutes before trying another search. This is to prevent you from spamming the search engine with requests."];
	[rootNode addChild:node];
	
	node = [[[SettingsNode alloc] init:@"Image display interval (seconds)" value:[NSString stringWithFormat:@"%g", settings->imageInterval] identifier:2 isFloat:YES] autorelease];
	[node setLongDesc:@"The amount of time an image is displayed on the screen."];
	[rootNode addChild:node];
	
	node = [[[SettingsNode alloc] init:@"Search type change interval (minutes)" value:[NSString stringWithFormat:@"%d", settings->typeChangeInterval] identifier:3] autorelease];
	[node setLongDesc:@"If you have more than one type of search type enabled (e.g. a digital photo search and a phrase search), it will change randomly after the specified time has elapsed. If it is searching when the change is supposed to happen, it will wait until its finished."];
	[rootNode addChild:node];
	
	node = [[[SettingsNode alloc] init:@"Maximum # of images per search" value:[NSString stringWithFormat:@"%d", settings->maxImagePerSearch] identifier:4] autorelease];
	[node setLongDesc:@"This is the maximum number of images that will be downloaded for a single search. A search is not guaranteed to download any images at all."];
	[rootNode addChild:node];
	
	node = [[[SettingsNode alloc] init:@"Image expiration (days)" value:[NSString stringWithFormat:@"%d", settings->imageExpiration] identifier:5] autorelease];
	[node setLongDesc:@"Images older than the a set number of days will be deleted. If this is set to 0, images never expire."];
	[rootNode addChild:node];
	
	node = [[[SettingsNode alloc] init:@"Maximum cache size (MB)" value:[NSString stringWithFormat:@"%d", settings->maxCacheSize] identifier:6] autorelease];
	[node setLongDesc:@"The maximum total size (disk space usage) of images. Only the oldest images are deleted."];
	[rootNode addChild:node];
	
	node = [[[SettingsNode alloc] init:@"Minimum # of images saved" value:[NSString stringWithFormat:@"%d", settings->minImageCount] identifier:7] autorelease];
	[node setLongDesc:@"While the number of images is less than this amount, it ignores the search interval time. This is so that initially you don't have to wait a long time before seeing new images."];
	[rootNode addChild:node];
	
	node = [[[SettingsNode alloc] init:@"Connection timeout (seconds)" value:[NSString stringWithFormat:@"%d", settings->socketTimeout] identifier:8] autorelease];
	[node setLongDesc:@"The timeout for connections when searching and downloading images. For example, if it tries to connect to a web site that no longer exists, it will give up after this much time."];
	[rootNode addChild:node];
	
	node = [[[SettingsNode alloc] init:@"Show status (bottom right)" value:(settings->showStatus ? @"Yes" : @"No") identifier:9 isBool:YES] autorelease];
	[node setLongDesc:@"If set to Yes, it will show status information, such as download progress, wait time, and your current search type."];
	[rootNode addChild:node];
	
	node = [[[SettingsNode alloc] init:@"Show image filename (top center)" value:(settings->showFileName ? @"Yes" : @"No") identifier:10 isBool:YES] autorelease];
	[node setLongDesc:@"If set to Yes, it will show the image filename used."];
	[rootNode addChild:node];
	
	node = [[[SettingsNode alloc] init:@"Fade enabled" value:(settings->isFadeEnabled ? @"Yes" : @"No") identifier:11 isBool:YES] autorelease];
	[node setLongDesc:@"If set to Yes, images will fade in and out."];
	[rootNode addChild:node];
	
	node = [[[SettingsNode alloc] init:@"Fade amount (seconds)" value:[NSString stringWithFormat:@"%d", settings->fadeAmount] identifier:12 ] autorelease];
	[node setLongDesc:@"The amount of time to spent fading images in and out."];
	[rootNode addChild:node];
	
	node = [[[SettingsNode alloc] init:@"Zoom enabled" value:(settings->isZoomEnabled ? @"Yes" : @"No") identifier:13 isBool:YES] autorelease];
	[node setLongDesc:@"If set to Yes, the image will zoom in or out a small amount."];
	[rootNode addChild:node];
	
	node = [[[SettingsNode alloc] init:@"Search enabled" value:(settings->isSearchEnabled ? @"Yes" : @"No") identifier:14 isBool:YES] autorelease];
	[node setLongDesc:@"If set to No, then no searches will be performed."];
	[rootNode addChild:node];
	
	node = [[[SettingsNode alloc] init:@"Location wait (hours)" value:[NSString stringWithFormat:@"%d", settings->locationSearchWait] identifier:15 isBool:NO] autorelease];
	[node setLongDesc:@"How often a location search should reload its page."];
	[rootNode addChild:node];
	
	node = [[[SettingsNode alloc] init:@"Maximum # of images (Location)" value:[NSString stringWithFormat:@"%d", settings->locationMaxCount] identifier:16 isBool:NO] autorelease];
	[node setLongDesc:@"This is the maximum number of new images that will be downloaded when re-loading a location."];
	[rootNode addChild:node];
	
	node = [[[SettingsNode alloc] init:@"iTunes high priority" value:(settings->isITunesHighPriority ? @"Yes" : @"No") identifier:17 isBool:YES] autorelease];
	[node setLongDesc:@"If set to Yes, and if the iTunes search is enabled and playing a song, will supercede other enabled search items."];
	[rootNode addChild:node];
	
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
	SettingsNode *item = [outlineView itemAtRow:[outlineView selectedRow]];
	[longDescView setStringValue:[item getLongDesc]];
}

-(void) saveNodes:(NSArray*)nodes {
	RWSimpleSettings *settings = [[RWOptions sharedInstance] getSimpleSettings];
	int i;
	for(i = 0; i < [nodes count]; i++) {
		SettingsNode *node = [nodes objectAtIndex:i];
		switch([node getIdentifier]) {
			case 1: settings->searchInterval = [node getValueAsFloat]; break;
			case 2: settings->imageInterval = [node getValueAsFloat]; break;
			case 3: settings->typeChangeInterval = [node getValueAsInt]; break;
			case 4: settings->maxImagePerSearch = [node getValueAsInt]; break;
			case 5: settings->imageExpiration = [node getValueAsInt]; break;
			case 6: settings->maxCacheSize = [node getValueAsInt]; break;
			case 7: settings->minImageCount = [node getValueAsInt]; break;
			case 8: settings->socketTimeout = [node getValueAsInt]; break;
			case 9: settings->showStatus = [node getValueAsBool]; break;
			case 10: settings->showFileName = [node getValueAsBool]; break;
			case 11: settings->isFadeEnabled = [node getValueAsBool]; break;
			case 12: settings->fadeAmount = [node getValueAsInt]; break;
			case 13: settings->isZoomEnabled = [node getValueAsBool]; break;
			case 14: settings->isSearchEnabled = [node getValueAsBool]; break;
			case 15: settings->locationSearchWait = [node getValueAsInt]; break;
			case 16: settings->locationMaxCount = [node getValueAsInt]; break;
			case 17: settings->isITunesHighPriority = [node getValueAsBool]; break;
		}
	}
}

-(void) saveSettings {
	RWLog(@"Advanced settings... Saving");

	[self saveNodes:[rootNode getChildren]];
	
	if ([safeSearch selectedRow] == 0) [[RWOptions sharedInstance] setSearchSafeness: @"active"];
	else if ([safeSearch selectedRow] == 1) [[RWOptions sharedInstance] setSearchSafeness: @"images"];
	else if ([safeSearch selectedRow] == 2) [[RWOptions sharedInstance] setSearchSafeness: @"off"];
}

-(BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	if (item == rootNode) return NO;
	return ([[tableColumn identifier] isEqual:@"Value"]);
}

// This method is called repeatedly when the table view is displaying it self. 
-(id) outlineView:(NSOutlineView *)ov child:(int)index ofItem:(id)item {
    // is the parent non-nil?
    if (item)
        // Return the child
        return [item childAtIndex:index];
    else 
        // Else return the root
        return rootNode;
}

// Called repeatedly to find out if there should be an
// "expand triangle" next to the label
-(BOOL) outlineView:(NSOutlineView *)ov isItemExpandable:(id)item {
    // Returns YES if the node has children
    return [item expandable];
}

// Called repeatedly when the table view is displaying itself
-(int) outlineView:(NSOutlineView *)ov numberOfChildrenOfItem:(id)item {
    if (item == nil) {
        // The root object;
        return 1;
    }
    return [item childrenCount];
}

// This method gets called repeatedly when the outline view is trying
// to display it self.

-(id) outlineView:(NSOutlineView *)ov 
    objectValueForTableColumn:(NSTableColumn *)tableColumn 
    byItem:(id)item
{
    // I set the identifier of the columns in IB's inspector
    NSString *identifier = [tableColumn identifier];
    
    // What is returned depends upon which column it is
    // going to appear.
    if ([identifier isEqual:@"Key"]){
        return [item getKey];
    } else {
        return [item getValue];
    }
}

// This method gets called when the user edits the field.

-(void) outlineView:(NSOutlineView *)ov 	
    setObjectValue:(id)object 
    forTableColumn:(NSTableColumn *)tableColumn 
    byItem:(id)item
{
    // The only editable column in the item name column
    // so I know immediately where to put it.
    // If there were more editable columns I would
    // need an if-statement like in the previous method
    [item setValue:object];
    
    // Brute force reload to update sums
    [outlineView reloadItem:rootNode reloadChildren:YES];
}

-(void)dealloc {
    [rootNode release];
    [super dealloc];
}
@end

