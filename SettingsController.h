//
//  SettingsController.h
//  RandomWeb
//
//  Created by g4b3 on 2/8/05.
//  Copyright 2005 Cellar Door Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GoogleSearchParamItem.h"
#import "AddSearchItem.h"

@interface SettingsController : NSObject {

	IBOutlet id window;
	IBOutlet id addSearchWindow;
	
	IBOutlet NSTableView *itemsTable;
	IBOutlet id addItemButton;
	IBOutlet id removeItemButton;
	
	IBOutlet id saveButton;
	IBOutlet id cancelButton;
	
	IBOutlet id versionLbl;
	IBOutlet id aboutWebView;
	
	//IBOutlet id aboutTextView;
	
	IBOutlet id advSettingsController;
	IBOutlet id infoSettingsController;
	IBOutlet id addSettingsController;
	
	NSMutableArray *items;
	
	BOOL infoTabBuilt;
	BOOL aboutTabBuilt;
	
	IBOutlet id helpLbl;
	
	
}

+(SettingsController*) sharedInstance;

-(IBAction) cancelPressed:(id)sender;
-(IBAction) okPressed:(id)sender;

-(IBAction) refreshInfoPressed:(id) sender;

-(IBAction) addItemPressed:(id)sender;
-(IBAction) removeItemPressed:(id)sender;

-(IBAction) enableAllPressed:(id) sender;
-(IBAction) disableAllPressed:(id) sender;

-(void) setupAboutTab;
-(void) showWindow:(id)sender;
-(void) setupGUISettings;
-(void) saveGUISettings;
-(NSWindow*) window;


-(void) removeAlert:(NSString*)msg item:(NSObject*)obj;
-(void) removeAlert:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo;
-(void) removeItem:(SearchParamItem*)item;

@end
