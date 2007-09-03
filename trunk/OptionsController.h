//
//  OptionsController.h
//  RandomWeb
//
//  Created by g4b3 on Tue Jun 29 2004.
//  Copyright (c) 2004 Cellar Door Software. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <Cocoa/Cocoa.h>

#import "Settings.h"

@interface OptionsController : NSObject {
    IBOutlet id minImageCount;
	IBOutlet id minImageCountStepper;
	IBOutlet id imageInterval;
	IBOutlet id imageIntervalStepper;
	IBOutlet id searchInterval;
	IBOutlet id searchIntervalStepper;
	IBOutlet id imagesPerSearch;
	IBOutlet id imagesPerSearchStepper;
	IBOutlet id safeSearch;
	
	IBOutlet id expireDays;
	IBOutlet id expireDaysStepper;
	IBOutlet id cacheDirSizeMB;
	IBOutlet id cacheDirSizeMBStepper;
	IBOutlet id showStatus;
	IBOutlet id socketTimeout;
	IBOutlet id socketTimeoutStepper;
	
	IBOutlet id aboutVersion;
	IBOutlet id directory;
	
	IBOutlet id window;
	
	IBOutlet id infoNumImages;
	IBOutlet id infoDir;
	IBOutlet id infoCacheSizeLbl;
	IBOutlet id infoCacheSizeMax;
	IBOutlet id infoCacheSizePercent;
	IBOutlet id infoCacheSizeBar;
	
	IBOutlet id infoSiteNumImages;
	IBOutlet id infoSiteDir;
	IBOutlet id infoSiteCacheSizeLbl;
	IBOutlet id infoSiteCacheSizeMax;
	IBOutlet id infoSiteCacheSizePercent;
	IBOutlet id infoSiteCacheSizeBar;
	
	IBOutlet id infoPhraseNumImages;
	IBOutlet id infoPhraseDir;
	IBOutlet id infoPhraseCacheSizeLbl;
	IBOutlet id infoPhraseCacheSizeMax;
	IBOutlet id infoPhraseCacheSizePercent;
	IBOutlet id infoPhraseCacheSizeBar;
	
	BOOL infoTabBuilt;
	
	IBOutlet id showFileName;
	
	IBOutlet id fadeEnabled;
	IBOutlet id fadeAmount;
	IBOutlet id fadeAmountStepper;
	IBOutlet id zoomEnabled;
	
	// -- RandomPhoto Tab
	
	IBOutlet id randomPhotoEnabled;
	IBOutlet id focusCameraPhoto;
	
	IBOutlet id ignoreHostsTable;
	NSMutableArray *ignoreHostsDataSource;
	IBOutlet id ignoreHostsAddEntry;
	IBOutlet id ignoreHostsAddButton;
	IBOutlet id ignoreHostsDelButton;
	
	IBOutlet id minWidthPhoto;
	IBOutlet id minWidthPhotoStepper;
	IBOutlet id minHeightPhoto;
	IBOutlet id minHeightPhotoStepper;
	
	// -- RandomSite Tab
	
	IBOutlet id randomSiteEnabled;
	IBOutlet id focusCameraSite;
	
	IBOutlet id sitesTable;
	NSMutableArray *sitesDataSource;
	IBOutlet id sitesAddEntry;
	IBOutlet id sitesAddButton;
	IBOutlet id sitesDelButton;
	
	IBOutlet id siteSelectMode;
	IBOutlet id siteSelected;
	
	IBOutlet id minWidthSite;
	IBOutlet id minWidthSiteStepper;
	IBOutlet id minHeightSite;
	IBOutlet id minHeightSiteStepper;
	
	// -- RandomPhrase Tab
	
	IBOutlet id randomPhraseEnabled;
	IBOutlet id focusCameraPhrase;
	
	IBOutlet id phrasesTable;
	NSMutableArray *phrasesDataSource;
	IBOutlet id phrasesAddEntry;
	IBOutlet id phrasesAddButton;
	IBOutlet id phrasesDelButton;
	
	IBOutlet id phraseSelectMode;
	IBOutlet id phraseSelected;
	
	IBOutlet id minWidthPhrase;
	IBOutlet id minWidthPhraseStepper;
	IBOutlet id minHeightPhrase;
	IBOutlet id minHeightPhraseStepper;
}

+(OptionsController*) sharedInstance;

-(IBAction) cancelPressed:(id)sender;
-(IBAction) okPressed:(id)sender;

-(IBAction) addIgnoreHostPressed:(id)sender;
-(IBAction) addSitePressed:(id)sender;
-(IBAction) addPhrasePressed:(id)sender;
-(IBAction) delIgnoreHostPressed:(id)sender;
-(IBAction) delSitePressed:(id)sender;
-(IBAction) delPhrasePressed:(id)sender;

-(void) showWindow:(id)sender;
-(void) setupGUISettings;
-(void) setupInfoTab;
-(void) setupAboutTab;
-(void) saveGUISettings;
-(NSWindow*) window;

-(void) deletePhrase:(NSString*)phrase;
-(void) deleteSite:(NSString*)site;

@end