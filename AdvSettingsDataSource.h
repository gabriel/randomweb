//
//  AdvSettingsDataSource.h
//  RandomWeb
//
//  Created by Gabriel Handford on 2/19/05.
//  Copyright 2005 Gabriel Handford. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SettingsNode.h"

@interface AdvSettingsDataSource : NSObject {
    IBOutlet NSOutlineView *outlineView;
	IBOutlet id longDescView;
	IBOutlet id safeSearch;
	
    SettingsNode *rootNode;
}

-(void) saveSettings;
-(void) setupGUISettings;
-(void) buildNodes;

-(id) outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item;
-(BOOL) outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item;
-(int) outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item;
-(id) outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;

@end
