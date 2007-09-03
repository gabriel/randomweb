//
//  MainView.m
//  RandomWeb
//
//  Created by Gabriel Handford on Mon Jun 21 2004.
//  Copyright 2004 Gabriel Handford. All rights reserved.
//

#import "MainView.h"
#import "RWOptions.h"
#import "SettingsController.h"
#import "RandomImageFactory.h"

#import <Cocoa/Cocoa.h>

@implementation MainView

-(id) initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
    self = [super initWithFrame:frame isPreview:isPreview];
	
	if (self) {
		searcher = [[Searcher alloc] initWithDelegate:self];
		lastChangeDate = [[NSDate distantPast] retain];
		[self setAnimationTimeInterval:1];
	}
	
    return self;
}

-(void) dealloc {
	RWLog(@"MainView dealloc");
	[searcher release];
	[lastChangeDate release];
	[super dealloc];
}

-(void) startAnimation {
	RWLog(@"Start animation");
	RWLog(@"Search interval: %f", [[RWOptions sharedInstance] getWaitBetweenTransfer]);
	RWLog(@"Min image count: %d", [[RWOptions sharedInstance] getMinImageCount]);
	
	[super startAnimation];
}

-(void) stopAnimation {
	RWLog(@"Stopping animation");
	[searcher cancel];
	[super stopAnimation];
}

/**
 * Animate frame.
 * Called every n seconds, where n is equal to the animation time interval.
 */
-(void) animateOneFrame {

	if (![self isPreview] && !TRANSFER_OFF)
		[searcher triggerSearch];
		
	if (!currentImage || fabs([lastChangeDate timeIntervalSinceNow]) > [[RWOptions sharedInstance] getInterval]) {
	
		if (currentPath) [currentPath release];
		currentPath = [[searcher getFromImageArray] retain];
					
		if (currentPath) {
			[currentPath retain];
			
			if (currentImage) {
				RWLog(@"Releasing current image");
				[currentImage release];
			}
			
			[lastChangeDate release];
			lastChangeDate = [NSDate date];
			[lastChangeDate retain];
			
			RWLog(@"Creating image: %@", currentPath);
			currentImage = [RandomImageFactory scaleImageToHeight:[NSBitmapImageRep imageRepWithContentsOfFile:currentPath] height:[self bounds].size.height];
			int x = ([self bounds].size.width - [currentImage size].width)/2;
			scaledRect = NSMakeRect(x, 0, [currentImage size].width, [currentImage size].height);
			[currentImage retain];
			[self setNeedsDisplay:YES];
		}
	}
}

+(BOOL) performGammaFade {
	return YES;
}

/**
 * Fades entire display.
 */
 /**
-(void) fadeIn {
	CGDisplayReservationInterval seconds = 2.0;
    CGDisplayFadeReservationToken newToken;
    CGAcquireDisplayFadeReservation(seconds, &newToken); // reserve display hardware time
	
	CGDisplayFade(newToken,
                  2,                          // 0.5 seconds
                  kCGDisplayBlendSolidColor,    // Starting state
                  kCGDisplayBlendNormal,        // Ending state
                  0.0, 0.0, 0.0,                // black
                  true);                       // Don't wait for completion
	
	CGReleaseDisplayFadeReservation(newToken);
}
*/

-(void) clearScreen {
	NSSize size = [self bounds].size;
	[[NSColor blackColor] set];
	NSRectFill(NSMakeRect(0.0, 0.0, size.width, size.height));
}

-(void) drawRect:(NSRect)r {
	[super drawRect:r];
	RWLog(@"Draw rect");
	if ([self isAnimating] && [searcher cacheCount] == 0) {
		[self drawWaitMessage];
		return;
	}

	[self drawImage];
	[self drawFileName:currentPath];
	[self drawStatus];
}

-(void) drawImage {
	if (currentImage) {		
		[currentImage drawInRect:scaledRect]; //fromRect:NSMakeRect(0, 0, scaledRect.size.width, scaledRect.size.height) operation:NSCompositeCopy fraction:1.0];
	}
}

-(void) drawStatus {
	[self drawStatus:NO fgcolor:[NSColor whiteColor] bgcolor:[NSColor blackColor]];
}

-(void) drawStatus:(BOOL)force fgcolor:(NSColor*)fg bgcolor:(NSColor*)bg {
	if ([[RWOptions sharedInstance] showStatus] || force) {
		if (status) {
			NSFont* font = [NSFont fontWithName: @"Geneva" size: 16];
			float width = [font widthOfString: status];
			NSSize size = [self bounds].size;
			
			if (bg) {				
				NSRect rect = NSMakeRect(size.width-width-5, 0, size.width, 20);
				[bg set];
				[[NSBezierPath bezierPathWithRect:rect] fill];
			}
			
			NSDictionary* attrs = [NSDictionary dictionaryWithObjectsAndKeys:
				font, NSFontAttributeName,
				fg, NSForegroundColorAttributeName, nil];
			
			[status drawAtPoint:NSMakePoint(size.width-width-5, 0) withAttributes:attrs];
		}
	}
}

-(void) drawWaitMessage {
	NSSize size = [self bounds].size;
	NSFont* font30 = [NSFont fontWithName: @"Geneva" size: (![self isPreview] ? 30 : 18)];
	
	NSDictionary* attrs1 = [NSDictionary dictionaryWithObjectsAndKeys:
				font30, NSFontAttributeName,
				[NSColor whiteColor], NSForegroundColorAttributeName, nil];
			
	NSString *s1 = NULL;
	if (![self isPreview]) s1 = [NSString stringWithFormat:@"Downloading %d images to get you started...", [[RWOptions sharedInstance] getMinImageCount]];
	else  s1 = @"RandomWeb v1.0 Beta";
	NSString *s2 = NULL;
	if (![self isPreview]) s2 = @"(This will go away once the first image has been dowloaded)";
	else s2 = @"(No images currently available)";
	
	float width1 = [font30 widthOfString: s1];
	[s1 drawAtPoint:NSMakePoint(size.width/2 - width1/2, size.height/2) withAttributes:attrs1];
	
	NSFont* font16 = [NSFont fontWithName: @"Geneva" size: (![self isPreview] ? 16 : 12)];
	
	NSDictionary* attrs2 = [NSDictionary dictionaryWithObjectsAndKeys:
				font16, NSFontAttributeName,
				[NSColor whiteColor], NSForegroundColorAttributeName, nil];
			
	float width2 = [font16 widthOfString: s2];
	[s2 drawAtPoint:NSMakePoint((size.width/2.0) - (width2/2.0), size.height/2 - 40) withAttributes:attrs2];
	
	[self drawStatus:YES fgcolor:[NSColor whiteColor] bgcolor:NULL];
}

/**
 * Draw file name.
 * @param s
 */
-(void) drawFileName:(NSString*)s {
	if ([self isPreview]) return;
	if (![[RWOptions sharedInstance] showFileName]) return;
	if (!s) return;
	s = [s lastPathComponent];
	NSSize size = [self bounds].size;
	NSFont* font = [NSFont fontWithName: @"Geneva" size:12];
	float height = 15;
	
	NSDictionary* attrs = [NSDictionary dictionaryWithObjectsAndKeys:
				font, NSFontAttributeName,
				[NSColor whiteColor], NSForegroundColorAttributeName, nil];
	
	float width = [font widthOfString:s] + 5;
					
	NSRect rect = NSMakeRect(size.width/2-width/2, size.height-height, width, height);
	[[NSColor blackColor] set];
	[[NSBezierPath bezierPathWithRect:rect] fill];
	
	[s drawAtPoint:NSMakePoint(size.width/2-width/2, size.height-height) withAttributes:attrs];
}

/**
 * Set status.
 */
-(void) setStatus:(NSString*)st {
	if (st && status && [st isEqualToString:status]) return;

	if (status) [status release];
	if (st) status = [st retain];
	else status = NULL;

	[self setNeedsDisplay:YES];
}

-(BOOL)hasConfigureSheet {
    return YES;
}

-(NSWindow*)configureSheet {
	return [[SettingsController sharedInstance] window];
}

@end
