//
//  SettingsController.m
//  RandomWeb
//
//  Created by Gabriel Handford on 2/8/05.
//  Copyright 2005 Gabriel Handford. All rights reserved.
//

#import "SettingsController.h"
#import "Settings.h"
#import "ImageManager.h"
#import "RWLog.h"
#import "FileUtil.h"
#import "ITunesAccessor.h"
#import "ITunesSearchParamItem.h"
#import <WebKit/WebKit.h>

/**
 * SettingsController: The controller for the Settings window.
 * If saved, all changes are saved to the Settings struct, and persisted
 * there using the preferences API.
 * For this to work, the class must be set as:
 *  - data source for the table view
 *  - delegate for the table view 
 */

@implementation SettingsController

static SettingsController *sharedInstance = nil;

+(SettingsController *) sharedInstance {
    if(!sharedInstance) {
		sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}

-(id)init {
    self = [super init];
    if (self) {
		infoTabBuilt = NO;
		aboutTabBuilt = NO;
		items = [[NSMutableArray arrayWithCapacity:25] retain];
		[NSBundle loadNibNamed:@"Settings" owner:self];
    }
    return self;
}

-(void)dealloc {
	if (items) [items release];
	[super dealloc];
}

-(void) awakeFromNib {
	// Called after NIB was read
	[self setupGUISettings];
}

-(void) showWindow:(id)sender {
    [window makeKeyAndOrderFront:sender];
}

/** 
 * Data source for the NSTableView
 */

-(int)numberOfRowsInTableView:(NSTableView*)tableView {
   return [items count];
}

-(id) tableView:(NSTableView*)tableView objectValueForTableColumn:(NSTableColumn*)tableColumn row:(int)index { 
	
	SearchParamItem *item = [items objectAtIndex:index];

	if ([[tableColumn identifier] isEqual:@"Enabled"]) {
		return ([NSNumber numberWithBool:[item isEnabled]]);
	} else if ([[tableColumn identifier] isEqual:@"Type"]) {
		return [item getTypeString];
	} else if ([[tableColumn identifier] isEqual:@"Info"]) {
		return [item getInfoString];
	} else if ([[tableColumn identifier] isEqual:@"MinSize"]) {
		return [item getMinSizeString];
	}
	
	return nil;
}

-(void)tableView:(NSTableView*)tableView setObjectValue:(id)value forTableColumn:(NSTableColumn*)tableColumn row:(int)index {
	if(nil == value) value = @"";

	SearchParamItem *item = [items objectAtIndex:index];
	  
	if ([[tableColumn identifier] isEqual:@"Enabled"]) {
		[item isEnabled:[value boolValue]];
		if ([value boolValue]) [item reset];
	} else if ([[tableColumn identifier] isEqual:@"Type"]) {
		// TODO: error
	} else if ([[tableColumn identifier] isEqual:@"Info"]) {
		// TODO: error
	} else if ([[tableColumn identifier] isEqual:@"MinSize"]) {
		[item setMinSizeString:value];
	}	  
}

/**
 * Delegate for the NSTableView
   since there's only one combo box for all the lines, we need to populate it with the proper
   values for the line as set its selection, etc.
   this is optional, the alternative is to set a list of values in interface builder  */
/**
-(void)tableView:(NSTableView*)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn*)tableColumn row:(int)index {
	if([[tableColumn identifier] isEqual:@"Type"] && [cell isKindOfClass:[NSComboBoxCell class]]) {
		if (index == 0) {
			NSString *value = @"Digital Photo";
			[cell setRepresentedObject:value];
			[cell reloadData];
			[cell selectItemAtIndex:0];
			[cell setObjectValue:value];
		} else {
			GoogleSearchParamItem *item = [items objectAtIndex:index];
			NSString *value = [item getTypeString];
			[cell setRepresentedObject:value];
			[cell reloadData];
			[cell selectItemAtIndex:[self comboBoxCell:cell indexOfItemWithStringValue:value]-1];
			[cell setObjectValue:value];
		}
   }
}
*/


/** 
 * Data source for the NSComboBoxCell
 */
/**
-(id)comboBoxCell:(NSComboBoxCell*)cell objectValueForItemAtIndex:(int)index {
	if ([itemsTable selectedRow] == 0) return @"Digital Photo";
	return [GoogleSearchParamItem getTypeString:index+1];
}

-(int)numberOfItemsInComboBoxCell:(NSComboBoxCell*)cell {
	if ([itemsTable selectedRow] == 0) return 1;
	return sizeof(RWSearchType) - 2;
}

-(unsigned int)comboBoxCell:(NSComboBoxCell*)cell indexOfItemWithStringValue:(NSString*)st {
	if ([itemsTable selectedRow] == 0) return 0;
	return (unsigned int)[GoogleSearchParamItem getType:st];
}
*/

/**
 * Load the settings.
 */
-(void) setupGUISettings {
	NSString *helpString = @"Add a search item by pressing the (+) button.\n\
To remove an item, select it and click on the (-) button.\n\
Removing an entry will remove all of the images it has accumulated.\n\n";

	[helpLbl setStringValue:helpString];

	[items removeAllObjects];
	[items addObjectsFromArray:[[RWOptions sharedInstance] getSearchItems]];
	[itemsTable noteNumberOfRowsChanged];
	[advSettingsController setupGUISettings];
	[self setupAboutTab];
}

/**
 * Save the settings.
 */
-(void) saveGUISettings {
	//[[RWOptions sharedInstance] setSearchItems:items];
}

-(void) setupInfoTab {
	[infoSettingsController setupGUISettings];
	infoTabBuilt = YES;
}

-(NSURL*) getCreditsURL {
	// Setup our credits
	NSString *creditsPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"Credits" ofType:@"html"];
	RWLog(@"Credits Path: %@", creditsPath);
	return [NSURL fileURLWithPath:creditsPath];
}

-(void) setupAboutTab {
	if (aboutTabBuilt) return;
	[versionLbl setStringValue:[[RWOptions sharedInstance] getVersion]];
	
	[[aboutWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:[self getCreditsURL]]];
	[aboutWebView setPolicyDelegate:self];
	[aboutWebView setNeedsDisplay:YES];
	aboutTabBuilt = YES;
}

-(void) webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation 
  request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener {
  
	if (![[request URL] isFileURL]) {
		RWLog(@"Web view: %@", [request URL]);
		[[NSWorkspace sharedWorkspace] openURL:[request URL]];
	}
}


-(IBAction) refreshInfoPressed:(id) sender {
	[self setupInfoTab];
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem {
	if ([[tabViewItem label] isEqualToString:@"Info"]) {
		if (!infoTabBuilt) [self setupInfoTab];
	} else if ([[tabViewItem label] isEqualToString:@"About"]) {
		[self setupAboutTab];
	}
}

-(IBAction) enableAllPressed:(id) sender {
	int i;
	for(i = 0; i < [items count]; i++) {
		SearchParamItem *item = [items objectAtIndex:i];
		[item isEnabled:YES];
	}
	[itemsTable reloadData];
}

-(IBAction) disableAllPressed:(id) sender {
	int i;
	for(i = 0; i < [items count]; i++) {
		SearchParamItem *item = [items objectAtIndex:i];
		[item isEnabled:NO];
	}
	[itemsTable reloadData];
}

-(void) showMessageDialog:(NSString*)s {
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert setMessageText:s];
	[alert addButtonWithTitle:@"OK"];
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert runModal];
}

-(IBAction) addItemPressed:(id)sender {
	//GoogleSearchParamItem *item = [[GoogleSearchParamItem alloc] init:NO type:RWPhraseSearch keyword:@"enter phrase here" minSize:NSMakeSize(640,480) searchSize:nil startingPosition:0];
	//[items addObject:item];
	//[itemsTable reloadData];
	[addSettingsController willBecomeVisible];
	[NSApp beginSheet:addSearchWindow modalForWindow:window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	RWLog(@"Sheet did end");
	if ([addSettingsController wasOkPressed]) {
		SearchParamItem *item = [addSettingsController getItem];
		if (item) {
			[[RWOptions sharedInstance] addSearchParamItem:item sync:YES];
			[items addObject:item];
			[itemsTable reloadData];
			[itemsTable noteNumberOfRowsChanged];
			[itemsTable scrollRowToVisible:[items count]-1];
		}
	}
}


-(IBAction) removeItemPressed:(id)sender {
	int row = [itemsTable selectedRow];
	if (row >= 0 && row < [items count]) {
		
		SearchParamItem *item = [items objectAtIndex:row];
		
		NSString *path = [item getCompleteImagePath];
		if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:nil]) {
			[self removeItem:item];
		} else {
			NSString *msg = @"Removing this entry will delete all associated images!";
			[self removeAlert:msg item:[items objectAtIndex:row]];
		}
	}
}

-(void) removeAlert:(NSString*)msg item:(NSObject*)obj {
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert setMessageText:msg];
	[alert addButtonWithTitle:@"OK"];
	[alert addButtonWithTitle:@"Cancel"];
	[alert setAlertStyle:NSWarningAlertStyle];
	//int val = [alert runModal];
	
	[alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:@selector(removeAlert:returnCode:contextInfo:) contextInfo:obj];
}

-(void)removeAlert:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	if (returnCode == NSAlertFirstButtonReturn) {
		[self removeItem:(SearchParamItem*)contextInfo];
	}
}

-(void) removeItem:(SearchParamItem*)item {
	if (![item isDeletable]) {
		if ([item isEnabled]) [self showMessageDialog:@"You cannot delete this entry. Just disable it."];
		else  [self showMessageDialog:@"You cannot delete this entry."];
		return;
	}
		
	NSString *path = [item getCompleteImagePath];
	[FileUtil removeFile:path];
	
	[[RWOptions sharedInstance] removeSearchParamItem:item sync:YES];
	[items removeObject:item];
	[itemsTable reloadData];
	[itemsTable noteNumberOfRowsChanged];
}


-(BOOL) checkHasEnabled {
	int i;
	BOOL ok = NO;
	for(i = 0; i < [items count]; i++) {
		SearchParamItem *item = [items objectAtIndex:i];
		if ([item isEnabled]) {
			ok = YES;
			break;
		}
	}

	if (!ok) {
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert setMessageText:@"At least one search item must be enabled."];
		[alert addButtonWithTitle:@"OK"];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert runModal];
		return NO;
	}
	return YES;
}

-(IBAction) okPressed:(id)sender {
	if (![self checkHasEnabled]) return;	
	[self saveGUISettings];
	
	RWLog(@"Calling save on advanced settings controller");
	[advSettingsController saveSettings];
	
    [[RWOptions sharedInstance] saveSettings];
	[[ImageManager sharedInstance] reload];
	[[RWOptions sharedInstance] reload];
    [window close];
    [NSApp endSheet:window];
}

-(IBAction)cancelPressed:(id)sender {
	if (![self checkHasEnabled]) return;
    [self setupGUISettings];
    [window close];
    [NSApp endSheet:window];
}

-(NSWindow*) window {
    return window;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
	NSString *helpString = @"Add a search item by pressing the (+) button.\n\
To remove an item, select it and click on the (-) button.\n\
Removing an entry will remove all of the images it has accumulated.\n\n";

	int row = [itemsTable selectedRow];
	if (row >= 0 && row < [items count]) {		
		SearchParamItem *item = [items objectAtIndex:row];
		
		NSString *itemHelp = nil;
		if ([item isKindOfClass:[ITunesSearchParamItem class]]) {
			itemHelp = @"If iTunes is currently playing a song, a search is performed using the current artist name. If enabled, this search will supercede all other searches when iTunes is active.";
		} else if ([item isKindOfClass:[GoogleSearchParamItem class]]) {
			GoogleSearchParamItem *gItem = (GoogleSearchParamItem*)item;
			if ([gItem getType] == RWDigitalPhotoSearch) itemHelp = @"This search randomly finds digital camera photos. This works by searching for some of the common file name formats used by digital camera manufacturers.";
			else {
				itemHelp = [[item getTypeString] stringByAppendingFormat:@": %@", [item getInfoString]];
			}
		} else {
			itemHelp = [[item getTypeString] stringByAppendingFormat:@": %@", [item getInfoString]];
		}
		
		[helpLbl setStringValue:[helpString stringByAppendingString:itemHelp]];
	} else {
		[helpLbl setStringValue:helpString];
	}
}

@end
