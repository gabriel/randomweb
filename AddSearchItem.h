//
//  AddSearchItem.h
//  RandomWeb
//
//  Created by g4b3 on 3/8/05.
//  Copyright 2005 Cellar Door Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SearchParamItem.h"


@interface AddSearchItem : NSObject {

	IBOutlet id window;

	IBOutlet id searchTypeCB;
	IBOutlet id keywordTF;
	IBOutlet id minSizeCB;
	IBOutlet id helpLbl;

	BOOL okPressed;
}

-(id) init;

-(IBAction) okPressed:(id)sender;
-(IBAction) cancelPressed:(id)sender;

-(SearchParamItem*) getItem;
-(void) setHelpString:(NSString*)s;
-(void) willBecomeVisible;

-(BOOL) wasOkPressed;
-(void) fireChanged;

@end
