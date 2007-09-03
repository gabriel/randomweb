//
//  MainView.h
//  RandomWeb
//
//  Created by g4b3 on Mon Jun 21 2004.
//  Copyright (c) 2004 Cellar Door Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ScreenSaver/ScreenSaver.h>
#import "ImageManager.h"

static bool TRANSFER_OFF = YES;

@interface MainView : ScreenSaverView {

	Searcher *searcher;
	NSDate *lastChangeDate;
		
	NSImageRep *currentImage;
	NSRect scaledRect;
	NSString *currentPath;
	NSString *status;
}

-(void) setStatus:(NSString*)st;
-(void) pingCellarDoor;
-(void) drawStatus;
-(void) drawStatus:(BOOL)force fgcolor:(NSColor*)fg bgcolor:(NSColor*)bg;
-(void) drawImage;
-(void) drawWaitMessage;
-(void) drawFileName:(NSString*)s;
-(void) clearScreen;

@end
