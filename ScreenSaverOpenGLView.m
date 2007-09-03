//
//  ScreenSaverOpenGLView.m
//  RandomWeb
//
//  Created by Gabriel Handford on Wed Jul 21 2004.
//  Copyright 2004 Gabriel Handford. All rights reserved.
//

#import "ScreenSaverOpenGLView.h"
#import "RWOptions.h"
#import "ImageProcessor.h"
#import "SettingsController.h"
#import "RWLog.h"

@implementation ScreenSaverOpenGLView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
	
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {       
		canceled = NO;
		wasStopped = NO;
		lastChangeDate = [[NSDate distantPast] retain];
	  
        NSRect newFrame = frame;
        newFrame.origin.x = 0.0;
        newFrame.origin.y = 0.0;
        glView = [[RWOpenGLView alloc] initWithFrame:newFrame]; 

        if(glView) {
            [self setAutoresizesSubviews:YES];
            if(glView) [self addSubview:glView];
            [glView prepareOpenGL];
            //[self setAnimationTimeInterval:1];

            // Since our BasicOpenGLView class does it's setup in awakeFromNib, we call that here.
            // Note that this could be any method you want to use as the setup routine for your view.
            [glView awakeFromNib];
        }
        else // Log an error if we fail here
            RWLog(@"Error: OpenGL Screen Saver failed to initialize NSOpenGLView!");

    }
    return self;
}

-(void) setCanceled:(BOOL)b {
	canceled = b;
	[[ImageManager sharedInstance] setCanceled:b];
	if (glView) [glView setCanceled:b];
	
	if (b) {
		RWLog(@"Waiting for threads to finish");
		int attempt = 0;
		while(isImageCheckRunning || isSearchCheckRunning) {
			[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.05]];
			attempt++;
			if (attempt >= 200) {
				RWLog(@"Threads still running, giving up...");
				break;
			}
		}
		RWLog(@"Threads finished");
	}
}

-(void) dealloc {
	if (lastChangeDate) [lastChangeDate release];
	if (glView) [glView release];
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

-(void) drawRect:(NSRect)rect {
    [glView drawRect:rect];
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
				if ([image pixelsWide] > [glView bounds].size.width || [image pixelsHigh] > [glView bounds].size.height) 
					imageRep = [ImageProcessor scaleImageRep:image maxWidth:[glView bounds].size.width maxHeight:[glView bounds].size.height];
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
	RWLog(@"Starting image thread");
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[NSThread setThreadPriority:0.01];
	
	isImageCheckRunning = YES;
	if (![self isPreview]) [[ImageManager sharedInstance] addDelegate:self];
	
	if (![self isPreview]) {
		[self setStatus:@"Checking cache"];
		[[ImageManager sharedInstance] checkCache];
	}
	[self setStatus:@"RandomWeb loaded"];
	
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
	RWLog(@"Ending image thread");
	isImageCheckRunning = NO;
}

-(void) checkSearchRunnable {
	RWLog(@"Starting search thread");
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[NSThread setThreadPriority:0.01];
	
	isSearchCheckRunning = YES;
	while(!canceled) {
		if (![[ImageManager sharedInstance] isTransferring]) {
			if (![self isPreview] && !TRANSFER_OFF && [[RWOptions sharedInstance] isSearchEnabled])
				[[ImageManager sharedInstance] checkSearch];
			else 
				[self setStatus:nil];
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
	RWLog(@"Ending search thread");
	isSearchCheckRunning = NO;
}

-(void) animateOneFrame {
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
		
		int i = 0;
		for(i = 0; i < 5; i++) {
			//RWLog(@"Attempting image load (#%d)", i);
			if (currentPath) [currentPath release];
			if ([self isPreview]) {
				currentPath = [[[ImageManager sharedInstance] getFromImageCache] retain];
			} else {
				currentPath = [[[ImageManager sharedInstance] getFromImageArray] retain];
			}
		
			if (!currentPath) {
				[self clearImages];
				break;
			} else {
				if ([self loadImage:currentPath]) break;
			}
		}
	}
}

-(void) setImage:(NSBitmapImageRep*)image path:(NSString*)p {
	[glView setImage:image path:currentPath];
}

-(void) clearImages {
	[glView performSelectorOnMainThread:@selector(clearImages) withObject:nil waitUntilDone:NO];
}

-(void) setStatus:(NSString*)st {
	if (!glView) return;

	NSString *stat = @"";
	NSString *mode = [self getModeString];
		
	if (st) {
		if (mode && ![mode isEqual:@""]) stat = [NSString stringWithFormat:@"%@  %@", mode, st];
		else stat = [NSString stringWithFormat:@"%@", st];
	} else {
		if (mode && ![mode isEqual:@""]) stat = [NSString stringWithFormat:@"%@", mode];
	}
	
	[glView performSelectorOnMainThread:@selector(setStatus:) withObject:stat waitUntilDone:NO];
}

-(BOOL)hasConfigureSheet {
    return YES;
}

-(NSWindow*)configureSheet {
	return [[SettingsController sharedInstance] window];
}

/**
- (void)keyDown:(NSEvent *)theEvent {
	NSString *characters = [theEvent characters];
	int key = [characters characterAtIndex: 0];
	if (key == 'h') {
		[glView showHelp];
	} else {
		[super keyDown:theEvent];
	}
}
*/



@end
