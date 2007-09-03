//
//  ScreenSaverMainView.m
//  RandomWeb
//
//  Created by g4b3 on 5/21/05.
//  Copyright 2005 Cellar Door Software. All rights reserved.
//

#import "ScreenSaverMainView.h"
#import "ImageManager.h"
#import "RWOptions.h"
#import "RWLog.h"
#import "ImageProcessor.h"
#import "SettingsController.h"

@implementation ScreenSaverMainView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
	self = [super initWithFrame:frame isPreview:isPreview];
	
	if (self) {
		canceled = NO;
		wasStopped = NO;
		lastChangeDate = [[NSDate distantPast] retain];

		[self setAnimationTimeInterval:1];
	}
	
    return self;
}

-(void) setCanceled:(BOOL)b {
	canceled = b;
	[[ImageManager sharedInstance] setCanceled:b];
	
	if (b) {
		RWLog(@"Waiting for threads to finish");
		while(isImageCheckRunning || isSearchCheckRunning)
			[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.05]];
		RWLog(@"Threads finished");
	}
}

-(void) dealloc {
	if (lastChangeDate) [lastChangeDate release];
	if (currentPath) [currentPath release];
	if (currentStatus) [currentStatus release];
	if (currentImage) [currentImage release];
	[super dealloc];
}

-(void) didReloadOptions {
	RWLog(@"Notified of reloaded options");
	[self expireImage];
}

-(void) startAnimation {
	[super startAnimation];
	RWLog(@"Starting animation");
	[self setCanceled:NO];
	[[ImageManager sharedInstance] reload];
	[[RWOptions sharedInstance] addListener:self];
	[NSThread detachNewThreadSelector:@selector(checkRunnable) toTarget:self withObject:nil];
	RWLog(@"Starting animation completed");
}

-(NSString*) getModeString {
	SearchParamItem *item = [[ImageManager sharedInstance] getSearchItem];
	if (item) return [item getModeString];
	return @"";
}

-(void) stopAnimation {
	[super stopAnimation];
	RWLog(@"Stopping animation");
	wasStopped = YES;
	[self setCanceled:YES];
	[[RWOptions sharedInstance] removeListener:self];
	RWLog(@"Stopping animation completed");
}

+(BOOL) performGammaFade {
	return YES;
}

-(BOOL) loadImage:(id)path {
	NSBitmapImageRep *imageRep = nil;
	@try {
		NSDate *start = [NSDate date];
		NSBitmapImageRep *image = [NSBitmapImageRep imageRepWithData:[NSData dataWithContentsOfFile:path]];
		if (image) {
			BOOL imageOK = [ImageProcessor checkImage:image minSize:[[[ImageManager sharedInstance] getSearchItem] getMinSize]];
			RWLog(@"Image check took: %0.1f secs", -[start timeIntervalSinceNow]);
			if (!imageOK) {
				RWLog(@"Image load failed to pass minimum size (@ 72 DPI) constraints)");
				[[ImageManager sharedInstance] handleInvalidImage:path];
			} else {					
				NSDate *start = [NSDate date];
				if ([image pixelsWide] > [self bounds].size.width || [image pixelsHigh] > [self bounds].size.height) 
					imageRep = [ImageProcessor scaleImageRep:image maxWidth:[self bounds].size.width maxHeight:[self bounds].size.height];
				else imageRep = [ImageProcessor draw:image];
				RWLog(@"Image transform took: %0.1f secs", -[start timeIntervalSinceNow]);
			}
		}
	} @catch(NSException *nse) {
		RWLog(@"Error: %@", nse);
		[[ImageManager sharedInstance] handleInvalidImage:path];
	}
	[self imageLoadFinished:imageRep];
	return (imageRep != nil);
}

-(void) imageLoadFinished:(id)image { 

	if (image) {
		[self setImage:(NSBitmapImageRep*)image path:currentPath];
		[lastChangeDate release];
		lastChangeDate = [[NSDate date] retain];
	}
}

-(void) checkRunnable {
	RWLog(@"Check image selector STARTED");
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[NSThread setThreadPriority:0.01];
	
	isImageCheckRunning = YES;
	if (![self isPreview]) [[ImageManager sharedInstance] addDelegate:self];
	
	if (![self isPreview]) {
		[self setStatus:@"Checking cache"];
		[[ImageManager sharedInstance] checkCache];
	}
	
	[NSThread detachNewThreadSelector:@selector(checkSearchRunnable) toTarget:self withObject:nil];	
	
	while(!canceled) {
		BOOL changed = [self checkType];
		if (changed) [self expireImage];
		[self checkImage];
		[pool release];
		pool = [[NSAutoreleasePool alloc] init];
		//if (!canceled) [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
		int count = 0;
		while(!canceled && count < 10) {
			if (![[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]]) {
				[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
			}
			count++;
		}
	}

	if (![self isPreview]) [[ImageManager sharedInstance] removeDelegate:self];
	
	[pool release];
	RWLog(@"Check image selector ENDED");
	isImageCheckRunning = NO;
}

-(void) checkSearchRunnable {
	RWLog(@"Check search selector STARTED");
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[NSThread setThreadPriority:0.01];
	
	isSearchCheckRunning = YES;
	while(!canceled) {
		if (![[ImageManager sharedInstance] isTransferring]) {
			if (![self isPreview] && [[RWOptions sharedInstance] isSearchEnabled])
				[[ImageManager sharedInstance] checkSearch];
			else 
				[self setStatus:@"cellardoorsw.com"];
		}
		[pool release];
		pool = [[NSAutoreleasePool alloc] init];
		//if (!canceled) [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
		int count = 0;
		while(!canceled && count < 10) {
			if (![[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]]) {
				[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
			}
			count++;
		}
	}
	
	[pool release];
	RWLog(@"Check search selector ENDED");
	isSearchCheckRunning = NO;
}

-(void) animateOneFrame {
	[self setNeedsDisplay:YES];	
}

-(BOOL) checkType {
	if ([[ImageManager sharedInstance] checkSearchItemNeedsReload]) return YES;

	if ([[RWOptions sharedInstance] getTypeChangeInterval] <= 0) return NO;
	if ([[ImageManager sharedInstance] isTransferring]) return NO;
	return [[ImageManager sharedInstance] checkSearchItem];
}

-(void) expireImage {
	RWLog(@"Expiring image");
	if (currentPath) {
		int interval = [[RWOptions sharedInstance] getInterval];
		//int fadeTime = [[RWOptions sharedInstance] getFadeAmount];
		[lastChangeDate release];
		lastChangeDate = [[NSDate dateWithTimeIntervalSinceNow:(-interval+1)] retain];
	} else {
		[lastChangeDate release];
		lastChangeDate = [[NSDate distantPast] retain];
	}
}

-(void) checkImage {	
	if (fabs([lastChangeDate timeIntervalSinceNow]) > [[RWOptions sharedInstance] getInterval]) {
		
		if (currentPath) [currentPath release];
		if ([self isPreview]) {
			currentPath = [[[ImageManager sharedInstance] getFromImageCache] retain];
		} else {
			currentPath = [[[ImageManager sharedInstance] getFromImageArray] retain];
		}
		
		if (!currentPath) {
			[self clearImages];
		} else {
			[self loadImage:currentPath];
		}
	}
}

-(void) setImage:(NSBitmapImageRep*)image path:(NSString*)p {
	@synchronized(self) {
		if (currentImage) [currentImage release];
		currentImage = [image retain];
		
		int width = [currentImage size].width;
		int height = [currentImage size].height;
		
		if ([currentImage size].width < [self bounds].size.width &&
			[currentImage size].height < [self bounds].size.height) {
			
			double mag = ([self bounds].size.height - [currentImage size].height)/[currentImage size].height;
			height = [self bounds].size.height;
			width = [currentImage size].width * (mag+1);
			
		}
		
		int x = ([self bounds].size.width - width)/2;
		int y = ([self bounds].size.height - height)/2;
		scaledRect = NSMakeRect(x, y, width, height);
	}
	[self setNeedsDisplay:YES];
}

-(void) clearScreen {
	NSSize size = [self bounds].size;
	[[NSColor blackColor] set];
	NSRectFill(NSMakeRect(0.0, 0.0, size.width, size.height));
}

-(void) clearImages {
	@synchronized(self) {
		if (currentImage) {
			[currentImage release];
			currentImage = nil;
		}
	}
	[self clearScreen];
	[self setNeedsDisplay:YES];
}

-(void) drawImage {
	@synchronized(self) {
		if (currentImage) {		
			[currentImage drawInRect:scaledRect];
		}
	}
}

-(void) drawStatus {
	if (currentStatus && [[RWOptions sharedInstance] showStatus]) {
		NSColor *fg = [NSColor whiteColor];
		NSColor *bg = [NSColor blackColor];
	
		@synchronized(self) {

			NSFont* font = [NSFont fontWithName: @"Geneva" size: ([self isPreview] ? 10 : 16)];
			float width = [font widthOfString: currentStatus];
	
			NSSize size = [self bounds].size;
		
			if (bg) {				
				NSRect rect = NSMakeRect(size.width-width-5, 0, size.width, ([self isPreview] ? 15 : 20));
				[bg set];
				[[NSBezierPath bezierPathWithRect:rect] fill];
			}
		
			NSDictionary* attrs = [NSDictionary dictionaryWithObjectsAndKeys:
				font, NSFontAttributeName,
				fg, NSForegroundColorAttributeName, nil];
		
			[currentStatus drawAtPoint:NSMakePoint(size.width-width-5, 0) withAttributes:attrs];
		}
	}
}

-(void) drawRect:(NSRect)r {
	[super drawRect:r];
	[self drawImage];
	[self drawStatus];
}

-(void) setStatus:(NSString*)st {

	NSString *mode = [self getModeString];
	NSString *stat = @"";
	if (st) {
		if (mode && ![mode isEqual:@""]) stat = [NSString stringWithFormat:@"%@ | %@", mode, st];
		else stat = [NSString stringWithFormat:@"%@", st];
	}
	
	@synchronized(self) {
		if (currentStatus) [currentStatus release];
		currentStatus = [stat retain];
	}
}

-(BOOL)hasConfigureSheet {
    return YES;
}

-(NSWindow*)configureSheet {
	return [[SettingsController sharedInstance] window];
}

@end
