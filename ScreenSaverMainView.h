//
//  ScreenSaverMainView.h
//  RandomWeb
//
//  Created by Gabriel Handford on 5/21/05.
//  Copyright 2005 Gabriel Handford. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ScreenSaver/ScreenSaver.h>
#import "RWOptionsListener.h"

@interface ScreenSaverMainView : ScreenSaverView <RWOptionsListener> {

	NSDate *lastChangeDate;
		
	NSString *currentPath;
	NSString *currentStatus;
	
    NSRect scaledRect;
	NSBitmapImageRep *currentImage;
	
	BOOL canceled;
	BOOL wasStopped;
	
	BOOL isImageCheckRunning;
	BOOL isSearchCheckRunning;
}

-(void) setStatus:(NSString*)st;
-(void) checkImage;
-(void) expireImage;
-(BOOL) checkType;
-(void) imageLoadFinished:(id)image;
-(BOOL) loadImage:(id)path;
-(void) setCanceled:(BOOL)b;
-(void) checkRunnable;
-(NSString*) getModeString;

-(void) setImage:(NSBitmapImageRep*)image path:(NSString*)currentPath;
-(void) clearImages;

@end
