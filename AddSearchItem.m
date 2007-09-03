//
//  AddSearchItem.m
//  RandomWeb
//
//  Created by Gabriel Handford on 3/8/05.
//  Copyright 2005 Gabriel Handford. All rights reserved.
//

#import "AddSearchItem.h"
#import "StringUtil.h"
#import "RWLog.h"
#import "RWOptions.h"
#import "URLSearchParamItem.h";
#import "GoogleSearchParamItem.h"

@implementation AddSearchItem

-(id) init {
	self = [super init];
	if (self) {
		okPressed = NO;
	}
	return self;
}

-(void) willBecomeVisible {
	[window makeFirstResponder:keywordTF];
	[keywordTF setStringValue:@""];
	[searchTypeCB selectItemAtIndex:0];
	[self fireChanged];
}

-(IBAction) okPressed:(id)sender {

	SearchParamItem *item = [self getItem];
	
	NSString *keyword = [keywordTF stringValue];
	if (!keyword || [StringUtil isEmptyString:keyword]) {
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert setMessageText:@"You must specify a search keyword."];
		[alert addButtonWithTitle:@"OK"];
		[alert setAlertStyle:NSInformationalAlertStyle];
		[alert runModal];
		return;
	}
	
	if ([[RWOptions sharedInstance] containsItemLike:item]) {
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert setMessageText:@"This item already exists, try a different keyword."];
		[alert addButtonWithTitle:@"OK"];
		[alert setAlertStyle:NSInformationalAlertStyle];
		[alert runModal];
		return;
	}
	
	if ([item isKindOfClass:[URLSearchParamItem class]]) {
		NSURL *url = [((URLSearchParamItem*)item) getURL];
		if (!url || ![url host]) {
			NSAlert *alert = [[[NSAlert alloc] init] autorelease];
			[alert setMessageText:[NSString stringWithFormat:@"%@ is not a valid URL", [keywordTF stringValue]]];
			[alert addButtonWithTitle:@"OK"];
			[alert setAlertStyle:NSInformationalAlertStyle];
			[alert runModal];
			return;
		}
	}

	okPressed = YES;
	[window close];
    [NSApp endSheet:window];
}

-(void) setHelpString:(NSString*)s {
	[helpLbl setStringValue:s];
}

-(void) fireChanged {
	if (![searchTypeCB objectValueOfSelectedItem]) return;
	NSString *type = [searchTypeCB objectValueOfSelectedItem];
	
	if ([type isEqual:@"Phrase"]) {
		[self setHelpString:@"Enter in a word or combination of words.\nExamples:\n  sunsets\n  fiery furnaces\n  earth, moon"];
	} else if ([type isEqual:@"Site"]) {
		[self setHelpString:@"Enter in a site (domain) name.\nExamples:\n  nasa.gov\n  wikipedia.org"];
	} else if ([type isEqual:@"Location"]) {
		[self setHelpString:@"Enter in a specific location.\nExample:\n  http://photojournal.jpl.nasa.gov/jpeg/"];
	} else {
		[self setHelpString:@""];
	}
}


-(void) comboBoxSelectionDidChange:(NSNotification *)notification {
	RWLog(@"Notification: %@", [notification object]);
	[self fireChanged];
}

-(void)controlTextDidChange:(NSNotification *)aNotification {
	[self fireChanged];
}

-(IBAction) cancelPressed:(id)sender {
	okPressed = NO;
	[window close];
    [NSApp endSheet:window];
}

-(BOOL) wasOkPressed {
	return okPressed;
}

-(SearchParamItem*) getItem {
	RWSearchType type = [GoogleSearchParamItem getType:[searchTypeCB stringValue]];
	if (type == NSNotFound) {
		NSString *surl = [keywordTF stringValue];
		NSURL *url = [NSURL URLWithString:surl];
		if (!url || ![url host]) surl = [NSString stringWithFormat:@"http://%@", surl];
	
		return [[[URLSearchParamItem alloc] init:YES url:surl
			minSize:[SearchParamItem getMinSize:[minSizeCB stringValue]]] autorelease];
	} else {
		return [[[GoogleSearchParamItem alloc] init:YES type:type keyword:[keywordTF stringValue] 
			minSize:[SearchParamItem getMinSize:[minSizeCB stringValue]]] autorelease];
	}
}

@end
