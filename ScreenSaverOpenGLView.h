//
//  ScreenSaverOpenGLView.h
//  RandomWeb
//
//  Created by Gabriel Handford on Mon Jun 21 2004.
//  Copyright 2004 Gabriel Handford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ScreenSaver/ScreenSaver.h>
#import "ImageManager.h"
#import "RWOpenGLView.h";

static bool TRANSFER_OFF = NO;

@interface ScreenSaverOpenGLView : ScreenSaverView <RWOptionsListener> {

	NSDate *lastChangeDate;
		
	NSString *currentPath;
	NSString *status;
	
	RWOpenGLView *glView;
    NSRect theRect;
	
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
