//
//  OptionsController.m
//  RandomWeb
//
//  Created by Gabriel Handford on Tue Jun 29 2004.
//  Copyright 2004 Gabriel Handford. All rights reserved.
//

#import "OptionsController.h"
#import "StringUtil.h"
#import "ImageManager.h"
#import "FileUtil.h"
#import "RWLog.h"

// Makes an NSArray work as an NSTableDataSource.
@implementation NSArray (NSTableDataSource)

// just returns the item for the right row
-(id) tableView:(NSTableView*)aTableView objectValueForTableColumn:(NSTableColumn*)aTableColumn row:(int)rowIndex {  
  return [self objectAtIndex:rowIndex];  
}

// just returns the number of items we have.
-(int) numberOfRowsInTableView:(NSTableView*)aTableView {
  return [self count];  
}
@end

@implementation OptionsController
 
static OptionsController *sharedInstance = nil;

+(OptionsController *) sharedInstance {
    if(!sharedInstance) {
		sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}

-(id)init {
    self = [super init];
    if (self) {
		infoTabBuilt = false;
		[NSBundle loadNibNamed:@"Options" owner:self];
    }
    return self;
}

-(void) awakeFromNib {
	// Called after NIB was read
	[self setupGUISettings];
}

-(void) showWindow:(id)sender {
    [window makeKeyAndOrderFront:sender];
}

-(void) setupGUISettings {
	RWLog(@"Setting up GUI settings");

	RWSettings *settings = [[Settings sharedInstance] settingsStruct];
	NSString *searchSafeness = [[Settings sharedInstance] getSearchSafeness];
	 
	[minImageCount setIntValue:settings->minImageCount];
	[minImageCountStepper setIntValue:settings->minImageCount];
	
	[imageInterval setFloatValue:settings->imageInterval];
	[imageIntervalStepper setFloatValue:settings->imageInterval];
	
	[searchInterval setFloatValue: (settings->searchInterval * 60.0)];
	[searchIntervalStepper setFloatValue: (settings->searchInterval * 60.0)];
	
	[imagesPerSearch setIntValue:settings->maxImagePerSearch];
	[imagesPerSearchStepper setIntValue:settings->maxImagePerSearch];
	
	if ([searchSafeness isEqualToString:@"off"]) [safeSearch setState:1 atRow:2 column:0];
	else if ([searchSafeness isEqualToString:@"images"]) [safeSearch setState:1 atRow:1 column:0];
	else if ([searchSafeness isEqualToString:@"active"]) [safeSearch setState:1 atRow:0 column:0];
	
	[minWidthPhoto setIntValue:settings->minWidthPhoto];
	[minWidthPhotoStepper setIntValue:settings->minWidthPhoto];
	
	[minHeightPhoto setIntValue:settings->minHeightPhoto];
	[minHeightPhotoStepper setIntValue:settings->minHeightPhoto];
	
	[expireDays setIntValue:settings->imageExpiration];
	[expireDaysStepper setIntValue:settings->imageExpiration];
	
	[cacheDirSizeMB setIntValue:settings->maxCacheSize];
	[cacheDirSizeMBStepper setIntValue:settings->maxCacheSize];
	
	[showStatus setState: (settings->showStatus ? NSOnState : NSOffState)];
	[showFileName setState: (settings->showFileName ? NSOnState : NSOffState)];
	
	[socketTimeout setIntValue:settings->socketTimeout];
	
	[fadeEnabled setState: (settings->isFadeEnabled ? NSOnState : NSOffState)];
	[fadeAmount setIntValue:settings->fadeAmount];
	[zoomEnabled setState: (settings->isZoomEnabled ? NSOnState : NSOffState)];
	
	// ---
	
	[randomPhotoEnabled setState: settings->isDigitalSearchEnabled];
	[focusCameraPhoto setState: settings->focusCameraPhoto];
	
	NSArray *hostsToIgnore = [[Settings sharedInstance] getHostsToIgnore];
	ignoreHostsDataSource = [[NSMutableArray arrayWithCapacity:[hostsToIgnore count]] retain];
	[ignoreHostsDataSource addObjectsFromArray:hostsToIgnore];
	
	[ignoreHostsTable setDataSource:ignoreHostsDataSource];
	[ignoreHostsTable reloadData];
	
	[minWidthPhoto setIntValue:settings->minWidthPhoto];
	[minHeightPhoto setIntValue:settings->minHeightPhoto];
	
	// --
	
	[randomSiteEnabled setState: settings->isSiteSearchEnabled];
	[focusCameraSite setState: settings->focusCameraSite];
	
	NSArray *sites = [[Settings sharedInstance] getSites];
	sitesDataSource = [[NSMutableArray arrayWithCapacity:[sites count]] retain];
	[sitesDataSource addObjectsFromArray:sites];
	
	[sitesTable setDataSource:sitesDataSource];
	[sitesTable reloadData];
	if (settings->useRandomSite)  [siteSelectMode setState:1 atRow:0 column:0];
	else [siteSelectMode setState:1 atRow:1 column:0];
	
	[siteSelected setStringValue:[[Settings sharedInstance] getSelectedSite]];
	
	[minWidthSite setIntValue:settings->minWidthSite];
	[minHeightSite setIntValue:settings->minHeightSite];
	
	// -- 
	
	[randomPhraseEnabled setState: settings->isPhraseSearchEnabled];
	[focusCameraPhrase setState: settings->focusCameraPhrase];
	
	NSArray *phrases = [[Settings sharedInstance] getPhrases];
	phrasesDataSource = [[NSMutableArray arrayWithCapacity:[phrases count]] retain];
	[phrasesDataSource addObjectsFromArray:phrases];
	
	[phrasesTable setDataSource:phrasesDataSource];
	[phrasesTable reloadData];
	if (settings->useRandomPhrase) [phraseSelectMode setState:1 atRow:0 column:0];
	else [phraseSelectMode setState:1 atRow:1 column:0];
	[phraseSelected setStringValue:[[Settings sharedInstance] getSelectedPhrase]];
	
	[minWidthPhrase setIntValue:settings->minWidthPhrase];
	[minHeightPhrase setIntValue:settings->minHeightPhrase];
}

-(void) setupInfoTab {
	RWSettings *settings = [[Settings sharedInstance] settingsStruct];
	int cacheCount = 0;
	float cacheSize = 0.0;
	float cachePercentFull = 0;
	
	int cacheCountSite = 0;
	float cacheSizeSite = 0.0;
	float cachePercentFullSite = 0;
	
	int cacheCountPhrase = 0;
	float cacheSizePhrase = 0.0;
	float cachePercentFullPhrase = 0;
	
	[[Settings sharedInstance] getCacheStats:[[Settings sharedInstance] getBaseImagePath] traverse:NO count:&cacheCount size:&cacheSize];
	if (settings->maxCacheSize > 0) cachePercentFull = (cacheSize/settings->maxCacheSize) * 100;
	
	[[Settings sharedInstance] getCacheStats:[[Settings sharedInstance] getSitesPath] traverse:YES count:&cacheCountSite size:&cacheSizeSite];
	if (settings->maxCacheSize > 0) cachePercentFullSite = (cacheSize/settings->maxCacheSize) * 100;
	
	[[Settings sharedInstance] getCacheStats:[[Settings sharedInstance] getPhrasesPath] traverse:YES count:&cacheCountPhrase size:&cacheSizePhrase];
	if (settings->maxCacheSize > 0) cachePercentFullPhrase = (cacheSize/settings->maxCacheSize) * 100;
	
	[infoNumImages setIntValue:cacheCount];
	[infoDir setStringValue:[[Settings sharedInstance] getBaseImagePath]];
	[infoCacheSizeLbl setFloatValue:cacheSize];
	[infoCacheSizePercent setFloatValue:cachePercentFull];
	[infoCacheSizeBar setDoubleValue:cachePercentFull];
	[infoCacheSizeMax setIntValue:settings->maxCacheSize];
	
	[infoSiteNumImages setIntValue:cacheCountSite];
	[infoSiteDir setStringValue:[[Settings sharedInstance] getSitesPath]];
	[infoSiteCacheSizeLbl setFloatValue:cacheSizeSite];
	[infoSiteCacheSizePercent setFloatValue:cachePercentFullSite];
	[infoSiteCacheSizeBar setDoubleValue:cachePercentFullSite];
	[infoSiteCacheSizeMax setIntValue:settings->maxCacheSize];
	
	[infoPhraseNumImages setIntValue:cacheCountPhrase];
	[infoPhraseDir setStringValue:[[Settings sharedInstance] getPhrasesPath]];
	[infoPhraseCacheSizeLbl setFloatValue:cacheSizePhrase];
	[infoPhraseCacheSizePercent setFloatValue:cachePercentFullPhrase];
	[infoPhraseCacheSizeBar setDoubleValue:cachePercentFullPhrase];
	[infoPhraseCacheSizeMax setIntValue:settings->maxCacheSize];
	infoTabBuilt = YES;
}

-(void) setupAboutTab {
	[aboutVersion setStringValue:[[Settings sharedInstance] getVersion]];
}

-(void) saveGUISettings {
	RWSettings *settings = [[Settings sharedInstance] settingsStruct];
    settings->minImageCount = [minImageCount intValue];
	settings->imageInterval = [imageInterval floatValue];
	settings->searchInterval = [searchInterval floatValue]/60.0;
	settings->maxImagePerSearch = [imagesPerSearch intValue];
	
	if ([safeSearch selectedRow] == 0) [[Settings sharedInstance] setSearchSafeness: @"active"];
	else if ([safeSearch selectedRow] == 1) [[Settings sharedInstance] setSearchSafeness: @"images"];
	else if ([safeSearch selectedRow] == 2) [[Settings sharedInstance] setSearchSafeness: @"off"];

	settings->minWidthPhoto = [minWidthPhoto intValue];
	settings->minHeightPhoto = [minHeightPhoto intValue];
	
	settings->imageExpiration = [expireDays intValue];
	settings->maxCacheSize = [cacheDirSizeMB intValue];
	settings->showStatus = ([showStatus intValue] == 1 ? YES : NO);		
	settings->showFileName = ([showFileName intValue] == 1 ? YES : NO);
	settings->socketTimeout = [socketTimeout intValue];
	
	settings->isFadeEnabled = ([fadeEnabled intValue] == 1 ? YES : NO);
	settings->fadeAmount = [fadeAmount intValue];
	settings->isZoomEnabled = ([zoomEnabled intValue] == 1 ? YES : NO);
	
	settings->isDigitalSearchEnabled = ([randomPhotoEnabled intValue] == 1 ? YES : NO);;
	settings->isSiteSearchEnabled = ([randomSiteEnabled intValue] == 1 ? YES : NO);;
	settings->isPhraseSearchEnabled = ([randomPhraseEnabled intValue] == 1 ? YES : NO);;
	
	settings->focusCameraPhoto = ([focusCameraPhoto intValue] == 1 ? YES : NO);
	settings->focusCameraSite = ([focusCameraSite intValue] == 1 ? YES : NO);
	settings->focusCameraPhrase = ([focusCameraPhrase intValue] == 1 ? YES : NO);
	
	settings->minWidthPhoto = [minWidthPhoto intValue];
	settings->minHeightPhoto = [minHeightPhoto intValue];
	settings->minWidthSite = [minWidthSite intValue];
	settings->minHeightSite = [minHeightSite intValue];
	settings->minWidthPhrase = [minWidthPhrase intValue];
	settings->minHeightPhrase = [minHeightPhrase intValue];
	
	settings->useRandomSite = ([siteSelectMode selectedRow] == 0);
	settings->useRandomPhrase = ([phraseSelectMode selectedRow] == 0);
	
	[[Settings sharedInstance] setSelectedSite:[siteSelected stringValue]];
	[[Settings sharedInstance] setSelectedPhrase:[phraseSelected stringValue]];
	
	[[Settings sharedInstance] setSites:sitesDataSource];
	[[Settings sharedInstance] setPhrases:phrasesDataSource];
	[[Settings sharedInstance] setHostsToIgnore:ignoreHostsDataSource];
}

- (void)controlTextDidChange:(NSNotification *)aNotification  {
	if ([aNotification object] == minImageCount) {
		[minImageCountStepper setIntValue:[minImageCount intValue]];
	} else if ([aNotification object] == imageInterval) {
		[imageIntervalStepper setIntValue:[imageInterval intValue]];
	} else if ([aNotification object] == searchInterval) {
		[searchIntervalStepper setIntValue:[searchInterval intValue]];
	} else if ([aNotification object] == imagesPerSearch) {
		[imagesPerSearchStepper setIntValue:[imagesPerSearch intValue]];
	} else if ([aNotification object] == minWidthPhoto) {
		[minWidthPhotoStepper setIntValue:[minWidthPhoto intValue]];
	} else if ([aNotification object] == minHeightPhoto) {
		[minHeightPhotoStepper setIntValue:[minHeightPhoto intValue]];
	} else if ([aNotification object] == expireDays) {
		[expireDaysStepper setIntValue:[expireDays intValue]];
	} else if ([aNotification object] == cacheDirSizeMB) {
		[cacheDirSizeMBStepper setIntValue:[cacheDirSizeMB intValue]];
	} else if ([aNotification object] == socketTimeout) {
		[socketTimeoutStepper setIntValue:[socketTimeout intValue]];
	} else if ([aNotification object] == fadeAmount) {
		[fadeAmountStepper setIntValue:[fadeAmount intValue]];
	} else if ([aNotification object] == minWidthSite) {
		[minWidthSiteStepper setIntValue:[minWidthSite intValue]];
	} else if ([aNotification object] == minHeightPhrase) {
		[minHeightPhraseStepper setIntValue:[minHeightPhrase intValue]];
		
	} else if ([aNotification object] == minWidthPhoto) {
		[minWidthPhotoStepper setIntValue:[minWidthPhoto intValue]];
	} else if ([aNotification object] == minHeightPhoto) {
		[minHeightPhotoStepper setIntValue:[minHeightPhoto intValue]];
	}
}

-(NSObject*) getSelectedObject:(NSTableView*)tableView {
	if ([tableView selectedRow] == -1) return nil;

	NSObject *obj = [[tableView dataSource] tableView:tableView
		objectValueForTableColumn:[[tableView tableColumns] objectAtIndex:0]
		row:[tableView selectedRow]];
	return obj;
}

-(IBAction) addIgnoreHostPressed:(id)sender {
	NSString *value = [StringUtil trim:[ignoreHostsAddEntry stringValue]];
	if (value && ![value isEqualToString:@""]) {
		NSString *s = [StringUtil trim:value];
		//[[Settings sharedInstance] addHostToIgnore:s];
		[ignoreHostsDataSource addObject:s];
		[ignoreHostsTable reloadData];
		[ignoreHostsAddEntry setStringValue:@""];
	}
}

-(IBAction) addSitePressed:(id)sender {
	NSString *value = [StringUtil trim:[sitesAddEntry stringValue]];
	if (value && ![value isEqualToString:@""]) {
		NSString *s = [StringUtil trim:value];
		//[[Settings sharedInstance] addSite:s];
		[sitesDataSource addObject:s];
		[sitesTable reloadData];
		[sitesAddEntry setStringValue:@""];
	}
}   

-(IBAction) addPhrasePressed:(id)sender {
	NSString *value = [StringUtil trim:[phrasesAddEntry stringValue]];
	if (value && ![value isEqualToString:@""]) {
		NSString *s = [StringUtil trim:value];
		//[[Settings sharedInstance] addPhrase:s];
		[phrasesDataSource addObject:s];
		[phrasesTable reloadData];
		[phrasesAddEntry setStringValue:@""];
	}
}

-(IBAction) delIgnoreHostPressed:(id)sender {
	NSTableView *tableView = ignoreHostsTable;
	NSObject *obj = [self getSelectedObject:tableView];
		
	if (obj) {		
		//[[Settings sharedInstance] removeHostToIgnore:(NSString*)obj];
		[ignoreHostsDataSource removeObject:obj];
		[tableView reloadData];
	}
}

-(void) deleteSiteAlert:(NSObject*)obj {
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert setMessageText:@"Removing this entry will delete all associated images!"];
	[alert addButtonWithTitle:@"OK"];
	[alert addButtonWithTitle:@"Cancel"];
	[alert setAlertStyle:NSWarningAlertStyle];
	//int val = [alert runModal];
	
	[alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:@selector(alertSiteDelete:returnCode:contextInfo:) contextInfo:obj];
}

-(void)alertSiteDelete:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	NSString *ci = (NSString*)contextInfo;
	if (returnCode == NSAlertFirstButtonReturn) {
		[self deleteSite:ci];
	}
}

-(void) deleteSite:(NSString*)site {
	if (site) {		
		[sitesDataSource removeObject:site];
		[sitesTable reloadData];
		
		NSString *path = [[[Settings sharedInstance] getSitesPath] stringByAppendingPathComponent:site];
		[FileUtil removeFile:path];
	}
	
	NSString *selected = [siteSelected stringValue];
	if (selected && site && [selected isEqualToString:site]) {
		[siteSelected setStringValue:@""];
	}
}

-(IBAction) delSitePressed:(id)sender {
	NSTableView *tableView = sitesTable;
	NSObject *obj = [self getSelectedObject:tableView];
	[self deleteSiteAlert:obj];
}

-(void) deletePhraseAlert:(NSObject*)obj {
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert setMessageText:@"Removing this entry will delete all associated images!"];
	[alert addButtonWithTitle:@"OK"];
	[alert addButtonWithTitle:@"Cancel"];
	[alert setAlertStyle:NSWarningAlertStyle];
	//int val = [alert runModal];
	
	[alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:@selector(alertPhraseDelete:returnCode:contextInfo:) contextInfo:obj];
}

-(void)alertPhraseDelete:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	NSString *ci = (NSString*)contextInfo;
	if (returnCode == NSAlertFirstButtonReturn) {
		[self deletePhrase:ci];
	}
}

-(void) deletePhrase:(NSString*)phrase {
	if (phrase) {		
		[phrasesDataSource removeObject:phrase];
		[phrasesTable reloadData];
		
		NSString *path = [[[Settings sharedInstance] getPhrasesPath] stringByAppendingPathComponent:phrase];
		[FileUtil removeFile:path];
	}
	
	NSString *selected = [phraseSelected stringValue];
	if (selected && phrase && [selected isEqualToString:(NSString*)phrase]) {
		[phraseSelected setStringValue:@""];
	}
}

-(IBAction) delPhrasePressed:(id)sender {
	NSTableView *tableView = phrasesTable;
	NSObject *obj = [self getSelectedObject:tableView];
	[self deletePhraseAlert:obj];	
}

-(void) tableViewSelectionDidChange:(NSNotification *)notification {
	RWLog(@"Selection changed");
	if ([notification object] == phrasesTable) {
		NSObject *obj = [self getSelectedObject:phrasesTable];
		if (obj) [phraseSelected setStringValue:(NSString*)obj];
	} else if ([notification object] == sitesTable) {
		NSObject *obj = [self getSelectedObject:sitesTable];
		if (obj) [siteSelected setStringValue:(NSString*)obj];
	}
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem {
	if ([[tabViewItem label] isEqualToString:@"Info"]) {
		if (!infoTabBuilt) [self setupInfoTab];
	} else if ([[tabViewItem label] isEqualToString:@"About"]) {
		[self setupAboutTab];
	}
}

-(IBAction) okPressed:(id)sender {
	[self saveGUISettings];
    [[Settings sharedInstance] saveSettings];
	[[Settings sharedInstance] reload];
	[[[ImageManager sharedInstance] getDirectoryCache] reload];
    [window close];
    [NSApp endSheet:window];
	infoTabBuilt = NO;
}

-(IBAction)cancelPressed:(id)sender {
    [self setupGUISettings];
    [window close];
    [NSApp endSheet:window];
	infoTabBuilt = NO;
}

-(NSWindow*) window {
    return window;
}

@end
