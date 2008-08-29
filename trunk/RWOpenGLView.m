//
//  RWOpenGLView.m
//  RandomWeb
//
//  Created by Gabriel Handford on Thu Jul 22 2004.
//  Copyright 2004 Gabriel Handford. All rights reserved.
//

#import "RWOpenGLView.h"
#import "ImageProcessor.h"
#import "RWOptions.h"
#import "RWLog.h"
#import "GoogleSearchParamItem.h"
#import "ImageManager.h"
#import "ImageDirectoryCache.h"

static double SHOW_HELP_TIME = 10.0;

@implementation RWOpenGLView

-(double) getElapsedTime {
	if (startTime) return fabs([startTime timeIntervalSinceNow]);
	else return 0.0;
}

#pragma mark ---- OpenGL Capabilities ----

// GL configuration info globals
// see glcheck.h for more info

// related DM change notification:
//DMExtendedNotificationUPP gConfigEDMUPP = NULL;

-(void) getCurrentCaps {
 	// Check for existing opengl caps here
	// This can be called again with same display caps array when display configurations are changed and
	//   your info needs to be updated.  Note, if you are doing dynmaic allocation, the number of displays
	//   may change and thus you should always reallocate your display caps array.
	if (gDisplayCaps && HaveOpenGLCapsChanged (gDisplayCaps, gNumDisplays)) { // see if caps have changed
		free (gDisplayCaps);
		gDisplayCaps = NULL;
	}
	if (!gDisplayCaps) { // if we do not have caps
		CheckOpenGLCaps (0, NULL, &gNumDisplays); // will just update number of displays
		gDisplayCaps = (GLCaps*) malloc (sizeof (GLCaps) * gNumDisplays);
		CheckOpenGLCaps (gNumDisplays, gDisplayCaps, &gNumDisplays);
		initCapsTexture (gDisplayCaps, gNumDisplays); // (re)init the texture for printing caps
	}
}

#pragma mark ---- Error Reporting ----

// error reporting as both window message and debugger string
-(void) reportError:(NSString*)strError {
    NSMutableDictionary *attribs = [NSMutableDictionary dictionary];
    [attribs setObject: [NSFont fontWithName: @"Monaco" size: 9.0f] forKey: NSFontAttributeName];
    [attribs setObject: [NSColor whiteColor] forKey: NSForegroundColorAttributeName];

	errorTime = [self getElapsedTime];
	NSString *errString = [NSString stringWithFormat:@"Error: %@ (at time: %0.1f secs).", strError, errorTime];
	RWLog (@"%@\n", errString);
	NSLog(@"%@\n", errString);
	if (gErrStringTex)
		[gErrStringTex setString:errString withAttributes:attribs];
	else {
		gErrStringTex = [[StringTexture alloc] initWithString:errString withAttributes:attribs withTextColor:[NSColor colorWithDeviceRed:0.8f green:0.8f blue:0.8f alpha:1.0f] withBoxColor:[NSColor colorWithDeviceRed:1.0f green:0.0f blue:0.0f alpha:0.3f] withBorderColor:[NSColor colorWithDeviceRed:1.0f green:0.0f blue:0.0f alpha:0.8f]];
	}
}

// ---------------------------------

// if error dump gl errors to debugger string, return error
-(GLenum) glReportError {
	GLenum err = glGetError();
	char *s_err = (char *) gluErrorString (err);
	if (GL_NO_ERROR != err) {
		NSString *strError = [NSString stringWithFormat:@"%s", s_err];
		[self reportError:strError];
	}
	return err;
}

// ===================================



// pixel format definition
+(NSOpenGLPixelFormat*) basicPixelFormat {
    NSOpenGLPixelFormatAttribute attributes [] = {
        NSOpenGLPFAWindow,
        NSOpenGLPFAAllRenderers,
        NSOpenGLPFAAccelerated,
        NSOpenGLPFADoubleBuffer,	// double buffered
        NSOpenGLPFAColorSize, (NSOpenGLPixelFormatAttribute)32, // 32 bit color buffer
        NSOpenGLPFADepthSize, (NSOpenGLPixelFormatAttribute)16, // 32 bit depth buffer
        (NSOpenGLPixelFormatAttribute)nil
    };
    return [[[NSOpenGLPixelFormat alloc] initWithAttributes:attributes] autorelease];
}

// update the projection matrix based on camera and view info
-(void) updateProjection {
	GLdouble ratio, radians, wd2;
	GLdouble left, right, top, bottom, near, far;
	GLfloat shapeSize = 4000.0f;

    [[self openGLContext] makeCurrentContext];

	// set projection
	glMatrixMode (GL_PROJECTION);
	glLoadIdentity ();
	near = -camera.viewPos.z - shapeSize * 0.5;
	if (near < 0.00001)
		near = 0.00001;
	far = -camera.viewPos.z + shapeSize * 0.5;
	if (near < 1.0)
		near = 1.0;
	radians = 0.0174532925 * camera.aperture / 2; // half aperture degrees to radians 
	wd2 = near * tan(radians);
	
	ratio = camera.viewWidth / (float) camera.viewHeight;
	if (ratio >= 1.0) {
		left  = -ratio * wd2;
		right = ratio * wd2;
		top = wd2;
		bottom = -wd2;	
	} else {
		left  = -wd2;
		right = wd2;
		top = wd2 / ratio;
		bottom = -wd2 / ratio;	
	}

	glFrustum (left, right, bottom, top, near, far);
}

-(void) updateCameraString {
	NSString *string = [NSString stringWithFormat:@"Camera at (%0.1f, %0.1f, %0.1f)\nlooking at (%0.1f, %0.1f, %0.1f)\nwith %0.1f aperture\nview size (%d x %d)", camera.viewPos.x, camera.viewPos.y, camera.viewPos.z, camera.viewDir.x, camera.viewDir.y, camera.viewDir.z, camera.aperture, camera.viewWidth, camera.viewHeight];
	[cameraStringTex setString:string withAttributes:stanStringAttrib];
}

-(void) updateCurrentInfoString {
	recVec currentPos = [currentItem getCurrentPosition];
	NSRect texBounds = [currentItem getBounds];
	recVec movementVector = [currentItem getMovementVector];
	NSString *string = [NSString stringWithFormat:@"Image with position (%0.1f x %0.1f x %0.1f)\ntexture size (%0.1f x %0.1f)\nmovement (%0.1f, %0.1f, %0.1f)", currentPos.x, currentPos.y, currentPos.z, texBounds.size.width, texBounds.size.height, movementVector.x, movementVector.y, movementVector.z];
	[currentInfoStringTex setString:string withAttributes:stanStringAttrib];
}

-(void) updateOldInfoString {
	recVec currentPosOld = [oldItem getCurrentPosition];
	NSRect texBoundsOld = [oldItem getBounds];
	recVec movementVectorOld = [oldItem getMovementVector];
	NSString *string = [NSString stringWithFormat:@"Last image with position (%0.1f x %0.1f x %0.1f)\ntexture size (%0.1f x %0.1f)\nmovement (%0.1f, %0.1f, %0.1f)", currentPosOld.x, currentPosOld.y, currentPosOld.z, texBoundsOld.size.width, texBoundsOld.size.height, movementVectorOld.x, movementVectorOld.y, movementVectorOld.z];
	[oldInfoStringTex setString:string withAttributes:stanStringAttrib];
}

-(void) updateSearchInfoString {
	SearchParamItem *item = [[ImageManager sharedInstance] getSearchItem];
	NSString *string = [NSString stringWithFormat:@"Search info: %@", item];
	[searchInfoStringTex setString:string withAttributes:stanStringAttrib];
}

-(void) updateCacheInfoString {
	SearchParamItem *item = [[ImageManager sharedInstance] getSearchItem];
	ImageDirectoryCache *cache = [[ImageManager sharedInstance] getDirectoryCache];
	NSString *string = [NSString stringWithFormat:@"Dir: %@, Items: %d, Cache size: %g", [item getCompleteImagePath], [cache count], [cache getCacheSize]];
	[cacheInfoStringTex setString:string withAttributes:stanStringAttrib];
}

-(void) showHelp {
	if (showHelpStart) [showHelpStart release];
	showHelpStart = [[NSDate date] retain];
}

-(float) getShapeHeight {
	return (float)[self bounds].size.height;
}

// sets the camera data to initial conditions
-(void) resetCamera {
   camera.aperture = 90;
   recVec origin = {0.0, 0.0, 0.0};
   camera.rotPoint = origin;

   camera.viewPos.x = 0.0;
   camera.viewPos.y = 0.0;
   camera.viewPos.z =  -[self getDistanceToFill:[self bounds].size];
   camera.viewDir.x = -camera.viewPos.x; 
   camera.viewDir.y = -camera.viewPos.y; 
   camera.viewDir.z = -camera.viewPos.z;

   camera.viewUp.x = 0;  
   camera.viewUp.y = -1; 
   camera.viewUp.z = 0;
}

-(bool) isWidthFill:(NSSize)size {
	float ratio = camera.viewWidth / (float) camera.viewHeight;
	float w = (ratio > 1.0 ? size.width/ratio : size.width);
	float h = (ratio < 1.0 ? size.height*ratio : size.height);
	return (w < h);
}

-(float) getDistanceToFill:(NSSize)size {
	float opposite = 0.0;
	float ratio = camera.viewWidth / (float) camera.viewHeight;
	bool widthFill = [self isWidthFill:size];
	if (widthFill) opposite = size.width;
	else opposite = size.height;

	if (ratio > 1.0  && widthFill) opposite /= ratio;
	else if (ratio < 1.0 && !widthFill) opposite *= ratio;

	float radians = 0.0174532925 * camera.aperture / 2;
	float far = opposite / 2;
	return (far / tan(radians));
}

// updates the contexts model view matrix for object and camera moves
-(void) updateModelView {
    [[self openGLContext] makeCurrentContext];
	
	// move view
	glMatrixMode (GL_MODELVIEW);
	glLoadIdentity ();
	gluLookAt (camera.viewPos.x, camera.viewPos.y, camera.viewPos.z,
			   camera.viewPos.x + camera.viewDir.x,
			   camera.viewPos.y + camera.viewDir.y,
			   camera.viewPos.z + camera.viewDir.z,
			   camera.viewUp.x, camera.viewUp.y, camera.viewUp.z);
}


// handles resizing of GL need context update and if the window dimensions change, a
// a window dimension update, reseting of viewport and an update of the projection matrix
-(void) resizeGL {
	NSRect rectView = [self bounds];
	
	// ensure camera knows size changed
	if ((camera.viewHeight != rectView.size.height) ||
	    (camera.viewWidth != rectView.size.width)) {
		camera.viewHeight = rectView.size.height;
		camera.viewWidth = rectView.size.width;
		
		glViewport (0, 0, camera.viewWidth, camera.viewHeight);
		[self updateProjection];  // update projection matrix
	}
}

-(void) reshape {
    NSRect bounds  = [self bounds];
    NSRect visRect = [self visibleRect];

    [[self openGLContext] makeCurrentContext];
    glViewport(-floor(visRect.origin.x), -floor(visRect.origin.y),  floor(bounds.size.width),  floor(bounds.size.height));
    glScissor(0, 0, floor(visRect.size.width), floor(visRect.size.height));
}

// ---------------------------------

// per-window timer function, basic time based animation preformed here
-(void) animationTimer:(NSTimer*)timer {
	[self drawRect:[self bounds]]; // redraw now instead dirty to enable updates during live resize
}


-(void) createStringTextures {
	NSString *string1 = [NSString stringWithFormat:@"Cellar Door Software (cellardoorsw.com)"];
	statusStringTex = [[StringTexture alloc] initWithString:string1 withAttributes:stanStringAttrib withTextColor:[NSColor colorWithDeviceRed:1.0f green:1.0f blue:1.0f alpha:1.0f] withBoxColor:[NSColor colorWithDeviceRed:0.0f green:0.5f blue:0.0f alpha:0.5f] withBorderColor:[NSColor colorWithDeviceRed:0.3f green:0.8f blue:0.3f alpha:0.8f]];
	
	NSString *string2 = [NSString stringWithFormat:@"Gabriel Handford - gh38@cornell.edu"];
	fileNameStringTex = [[StringTexture alloc] initWithString:string2 withAttributes:stanStringAttrib withTextColor:[NSColor colorWithDeviceRed:1.0f green:1.0f blue:1.0f alpha:1.0f] withBoxColor:[NSColor colorWithDeviceRed:0.0f green:0.0f blue:0.5f alpha:0.5f] withBorderColor:[NSColor colorWithDeviceRed:0.3f green:0.3f blue:0.8f alpha:0.8f]];
	
	NSString *string3 = [NSString stringWithFormat:@"Image Info"];
	currentInfoStringTex = [[StringTexture alloc] initWithString:string3 withAttributes:stanStringAttrib withTextColor:[NSColor colorWithDeviceRed:1.0f green:1.0f blue:1.0f alpha:1.0f] withBoxColor:[NSColor colorWithDeviceRed:0.0f green:0.5f blue:0.0f alpha:0.5f] withBorderColor:[NSColor colorWithDeviceRed:0.3f green:0.8f blue:0.3f alpha:0.8f]];

	NSString *string4 = [NSString stringWithFormat:@"Old Image Info"];
	oldInfoStringTex = [[StringTexture alloc] initWithString:string4 withAttributes:stanStringAttrib withTextColor:[NSColor colorWithDeviceRed:1.0f green:1.0f blue:1.0f alpha:1.0f] withBoxColor:[NSColor colorWithDeviceRed:0.0f green:0.5f blue:0.0f alpha:0.5f] withBorderColor:[NSColor colorWithDeviceRed:0.3f green:0.8f blue:0.3f alpha:0.8f]];
	
	NSString *string5 = [NSString stringWithFormat:@"Camera Info"];
	cameraStringTex = [[StringTexture alloc] initWithString:string5 withAttributes:stanStringAttrib withTextColor:[NSColor colorWithDeviceRed:1.0f green:1.0f blue:1.0f alpha:1.0f] withBoxColor:[NSColor colorWithDeviceRed:0.0f green:0.5f blue:0.0f alpha:0.5f] withBorderColor:[NSColor colorWithDeviceRed:0.3f green:0.8f blue:0.3f alpha:0.8f]];
	
	NSString *string6 = [NSString stringWithFormat:@"RandomWeb %@", [[RWOptions sharedInstance] getVersion]];
	waitStringTex = [[StringTexture alloc] initWithString:string6 withAttributes:stanStringAttrib2 withTextColor:[NSColor colorWithDeviceRed:1.0f green:1.0f blue:1.0f alpha:1.0f] withBoxColor:[NSColor colorWithDeviceRed:0.5f green:0.0f blue:0.0f alpha:0.5f] withBorderColor:[NSColor colorWithDeviceRed:0.8f green:0.3f blue:0.3f alpha:0.8f]];
	
	NSString *string7 = [NSString stringWithFormat:@"Search info: --"];
	searchInfoStringTex = [[StringTexture alloc] initWithString:string7 withAttributes:stanStringAttrib withTextColor:[NSColor colorWithDeviceRed:1.0f green:1.0f blue:1.0f alpha:1.0f] withBoxColor:[NSColor colorWithDeviceRed:0.0f green:0.5f blue:0.0f alpha:0.5f] withBorderColor:[NSColor colorWithDeviceRed:0.3f green:0.8f blue:0.3f alpha:0.8f]];
	
	NSString *string8 = [NSString stringWithFormat:@"Cache info: --"];
	cacheInfoStringTex = [[StringTexture alloc] initWithString:string8 withAttributes:stanStringAttrib withTextColor:[NSColor colorWithDeviceRed:1.0f green:1.0f blue:1.0f alpha:1.0f] withBoxColor:[NSColor colorWithDeviceRed:0.0f green:0.5f blue:0.0f alpha:0.5f] withBorderColor:[NSColor colorWithDeviceRed:0.3f green:0.8f blue:0.3f alpha:0.8f]];
	
	NSString *string9 = [NSString stringWithFormat:@"Help\n(D)elete image\n(F)lag image"];
	helpStringTex = [[StringTexture alloc] initWithString:string9 withAttributes:stanStringAttrib withTextColor:[NSColor colorWithDeviceRed:1.0f green:1.0f blue:1.0f alpha:1.0f] withBoxColor:[NSColor colorWithDeviceRed:0.5f green:0.5f blue:0.0f alpha:0.5f] withBorderColor:[NSColor colorWithDeviceRed:0.8f green:0.8f blue:0.0f alpha:0.8f]];
}

// draw text info using our StringTexture class for much more optimized text drawing
- (void) drawInfo {	
	GLint matrixMode;
	GLboolean depthTest = glIsEnabled (GL_DEPTH_TEST);
	GLfloat height, width;
	
	height = camera.viewHeight;
	width = camera.viewWidth;
	
	glDisable (GL_DEPTH_TEST); // ensure text is not remove by depth buffer test.
	glEnable (GL_BLEND); // for text fading
	glBlendFunc (GL_ONE, GL_ONE_MINUS_SRC_ALPHA); // ditto
	glEnable (GL_TEXTURE_RECTANGLE_EXT);
	
	// set orthograhic 1:1  pixel transform in local view coords
	glGetIntegerv (GL_MATRIX_MODE, &matrixMode);
	glMatrixMode (GL_PROJECTION);
	glPushMatrix();
		glLoadIdentity ();
		glMatrixMode (GL_MODELVIEW);
		glPushMatrix();
			glLoadIdentity ();
			glScalef (2.0f / width, -2.0f /  height, 1.0f);
			glTranslatef (-width / 2.0f, -height / 2.0f, 0.0f);
			
			glColor4f (1.0f, 1.0f, 1.0f, 1.0f);
			
			glPixelStorei(GL_UNPACK_CLIENT_STORAGE_APPLE, GL_FALSE); 
			if ([[RWOptions sharedInstance] showFileName]) {
				if (fileNameStringTex) [fileNameStringTex drawAtPoint:NSMakePoint (floor ((width - [fileNameStringTex frameSize].width)/2.0f), 5)]; 
			}
			
			if ([[RWOptions sharedInstance] showStatus] && ![statusStringTex isEmptyString] ) {
				float x = floor (width - [statusStringTex frameSize].width) - 5;
				float y = floor (height - [statusStringTex frameSize].height) - 5;
				[statusStringTex drawAtPoint:NSMakePoint(x, y)];
			}
			
			if (showHelpStart && fabs([showHelpStart timeIntervalSinceNow]) < SHOW_HELP_TIME) {
				float x = floor (width - [helpStringTex frameSize].width) - 5;
				float y = 50;
				[helpStringTex drawAtPoint:NSMakePoint(x, y)];
			}
			
			/**
			if (YES) {
				float x = floor (width - [searchInfoStringTex frameSize].width) - 5;
				float y = floor (height - [searchInfoStringTex frameSize].height) - 25;
				[searchInfoStringTex drawAtPoint:NSMakePoint(x, y)];
			}
			
			if (YES) {
				float x = floor (width - [cacheInfoStringTex frameSize].width) - 5;
				float y = floor (height - [cacheInfoStringTex frameSize].height) - 45;
				[cacheInfoStringTex drawAtPoint:NSMakePoint(x, y)];
			}
			*/
			
			/**
			if ([[RWOptions sharedInstance] showStatus] && ![modeStringTex isEmptyString] ) {
				float x2 = 5;
				float y2 = floor (height - [modeStringTex frameSize].height) - 5;
				[modeStringTex drawAtPoint:NSMakePoint(x2, y2)];
			}
			*/
			
			if (!currentItem) {
				float x = (width/2.0f) - ([waitStringTex frameSize].width/2.0f);
				float y = (height/2.0f) - ([waitStringTex frameSize].height/2.0f);
				[waitStringTex drawAtPoint:NSMakePoint(x, y)];
			}
			
#ifdef DEBUG
				float cameraInfoX = 5;
				float cameraInfoY = floor (height - [cameraStringTex frameSize].height) - 5;
				[cameraStringTex drawAtPoint:NSMakePoint(cameraInfoX, cameraInfoY)];
				
				float currentInfoX = 5;
				float currentInfoY = floor (cameraInfoY - [currentInfoStringTex frameSize].height) - 5;
				[currentInfoStringTex drawAtPoint:NSMakePoint(currentInfoX, currentInfoY)];
				
				float oldInfoX = 5;
				float oldInfoY = floor (currentInfoY - [oldInfoStringTex frameSize].height) - 5;
				[oldInfoStringTex drawAtPoint:NSMakePoint(oldInfoX, oldInfoY)];
#endif
			
			// global error message
			float currTime = [self getElapsedTime];
			// global error message
			if ((currTime - errorTime) < msgPersistence) {
				GLfloat comp = (msgPersistence - currTime + errorTime) * 0.1; // premultiplied fade
				glColor4f (comp, comp, comp, comp);
				[gErrStringTex drawAtPoint:NSMakePoint (10.0f, 50.0f)];
			}
			
			
		// reset orginal matrices
		glPopMatrix(); // GL_MODELVIEW
		glMatrixMode (GL_PROJECTION);
	glPopMatrix();
	glMatrixMode (matrixMode);

	glDisable (GL_TEXTURE_RECTANGLE_EXT);
	glDisable (GL_BLEND);
	if (depthTest)
		glEnable (GL_DEPTH_TEST);
	if (!canceled) [self glReportError];
}

-(NSSize) getViewSize:(float)z {
	float ratio = camera.viewWidth / (float)camera.viewHeight;
	float radians = 0.0174532925 * camera.aperture / 2;	
	float actualDistance = -(camera.viewPos.z - z);
	float opposite = (tan(radians) * actualDistance) * 2;
	
	if (ratio > 1.0) return NSMakeSize(opposite*ratio, opposite);
	else return NSMakeSize(opposite, opposite/ratio);
}

/**
-(NSSize) getFocusedViewportSize {
	NSSize viewportSize;
	if ([[Settings sharedInstance] focusCamera]) viewportSize = [bitmap size];
	else viewportSize = NSMakeSize(frameRect.size.width, frameRect.size.height);
	return viewportSize;
}
*/

-(void) setImage:(NSBitmapImageRep*)image path:(NSString*)s {
	if (image && s) {
		if (newImage || nextItem) return;
		nextItem = [[RWViewItem alloc] initWithImage:image path:s];
		NSRect texBoundsNext = NSMakeRect(0, 0, [image pixelsWide], [image pixelsHigh]);
		
		NSSize viewportSize = NSMakeSize([image pixelsWide], [image pixelsHigh]);
		recVec originalPosNext;
		recVec movementVectorNext;
		
		if ([[RWOptions sharedInstance] focusCamera]) {
			originalPosNext.z = -(-camera.viewPos.z-[self getDistanceToFill:viewportSize]);
			NSSize zoomedViewSize = [self getViewSize:originalPosNext.z];
			
			originalPosNext.x = -zoomedViewSize.width/2.0f;
			originalPosNext.y = -zoomedViewSize.height/2.0f;
			
			movementVectorNext.x = viewportSize.width - zoomedViewSize.width;
			movementVectorNext.y = viewportSize.height - zoomedViewSize.height;
			movementVectorNext.z = -(camera.viewPos.z - originalPosNext.z)/6;
		} else {
			originalPosNext.x = -viewportSize.width/2.0f;
			originalPosNext.y = -viewportSize.height/2.0f;
			originalPosNext.z = 0;
			
			movementVectorNext.x = 0;
			movementVectorNext.y = 0;
			movementVectorNext.z = 0;
		}
		[nextItem setParameters:originalPosNext movementVector:movementVectorNext bounds:texBoundsNext];
	} else {
		RWLog(@"Set next item to null");
		if (nextItem) {
			[nextItem release];
			nextItem = nil;
		}
	}
	
	newImage = YES;
}

-(void) clearImages {
	if (!nextItem && !currentItem) return;
	RWLog(@"Called clear images");
	[self setImage:nil path:nil];
}

-(void) deleteTexture:(GLuint)tex {
	if (tex) glDeleteTextures(1, &tex);
}

-(void) genImage:(RWViewItem*)viewItem {
	if (!viewItem) return;
	NSBitmapImageRep *bitmap = [viewItem getImage];
	if (!bitmap) return;
		
	// Non-mipmap filtering (redundant for texture_rectangle)
    glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_MIN_FILTER, GL_LINEAR); 
    int samplesPerPixel = [bitmap samplesPerPixel];
	
	//
	// GL_TEXTURE_RECTANGLE_EXT is used for non-power of two textures and is not supported on the Rage 128
	//
	
	// Non-planar, RGB 24 bit bitmap, or RGBA 32 bit bitmap
    if(![bitmap isPlanar] && 
       (samplesPerPixel == 3 || samplesPerPixel == 4)) { 
		//glEnable(GL_UNPACK_CLIENT_STORAGE_APPLE);
		//glEnable(GL_APPLE_texture_range); 
		GLuint texNameNext;
		glEnable (GL_TEXTURE_RECTANGLE_EXT);
		glGenTextures (1, &texNameNext);
		glBindTexture (GL_TEXTURE_RECTANGLE_EXT, texNameNext);
		
		glTexParameterf(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_PRIORITY, 1.0); 
		glPixelStorei(GL_UNPACK_CLIENT_STORAGE_APPLE, GL_TRUE); 
		//glTexParameteri( GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
		//glTexParameteri( GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
		
		// Set proper unpacking row length for bitmap
		//glPixelStorei(GL_UNPACK_ROW_LENGTH, [bitmap pixelsWide]);

		// Set byte aligned unpacking (needed for 3 byte per pixel bitmaps)
		if (samplesPerPixel == 3) glPixelStorei (GL_UNPACK_ALIGNMENT, 1);

		//glTexParameteri(GL_APPLE_texture_range, GL_TEXTURE_STORAGE_HINT_APPLE, GL_STORAGE_SHARED_APPLE); 
		//glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_MIN_FILTER, GL_NEAREST); 
		//glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_MAG_FILTER, GL_NEAREST); 
		//glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE); 
		//glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE); 
		//glPixelStorei(GL_UNPACK_ROW_LENGTH, 0); 
		
		//if (texNameOld) glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_BLEND);
		//glTexImage2D(GL_TEXTURE_RECTANGLE_EXT, 0, GL_RGBA8, [bitmap size].width, [bitmap size].height, 0, GL_BGRA_EXT, GL_UNSIGNED_INT_8_8_8_8_REV, [bitmap bitmapData]);

		RWLog(@"GL_TEXTURE_RECTANGLE_EXT");
		glTexImage2D(GL_TEXTURE_RECTANGLE_EXT, 
		             0, 
					 samplesPerPixel == 4 ? GL_RGBA8 : GL_RGB8,
					 [bitmap pixelsWide], 
					 [bitmap pixelsHigh], 
					 0, 
					 samplesPerPixel == 4 ? GL_RGBA : GL_RGB,
					 GL_UNSIGNED_BYTE, 
					 [bitmap bitmapData]);
					 
		glDisable (GL_TEXTURE_RECTANGLE_EXT);
		
		[viewItem setTextureName:texNameNext];
		
		//glDisable(GL_UNPACK_CLIENT_STORAGE_APPLE);
		//glDisable(GL_APPLE_texture_range); 
    } else {
    /*
        Error condition...
        The above code handles 2 cases (24 bit RGB and 32 bit RGBA),
        it is possible to support other bitmap formats if desired.
        
        So we'll log out some useful information.
    */
        RWLog (@"-textureFromView: Unsupported bitmap data format: isPlanar:%d, samplesPerPixel:%d, bitsPerPixel:%d, bytesPerRow:%d, bytesPerPlane:%d",
            [bitmap isPlanar], 
            [bitmap samplesPerPixel], 
            [bitmap bitsPerPixel], 
            [bitmap bytesPerRow], 
            [bitmap bytesPerPlane]);
    }

	/**
	//glEnable (GL_TEXTURE_RECTANGLE_EXT);
	glGenTextures (1, &texName);
	glBindTexture (GL_TEXTURE_RECTANGLE_EXT, texName);
	glTexImage2D (GL_TEXTURE_RECTANGLE_EXT, 0, format, texBounds.size.width, texBounds.size.height, 0, format, GL_UNSIGNED_BYTE, texData);
	//glDisable (GL_TEXTURE_RECTANGLE_EXT);
	*/
}

-(void) genImageFinished {
	if (nextItem && [nextItem hasTexture]) {
	
		oldItem = currentItem;
		currentItem = nextItem;
		nextItem = nil;
		
		movingIn = !movingIn;
		[currentItem setViewStartTime:[self getElapsedTime]];
		[oldItem setViewEndTime:[self getElapsedTime]];
		[currentItem movingIn:movingIn];
		[oldItem movingIn:!movingIn];
		
	} else if (!nextItem) {
		RWLog(@"Gen image finished, no next item...");
		oldItem = currentItem;
		currentItem = nil;
		[oldItem setViewEndTime:[self getElapsedTime]];
		[oldItem movingIn:movingIn];
		[fileNameStringTex setString:[NSString stringWithFormat:@"Gabriel Handford - gh38@cornell.edu"] withAttributes:stanStringAttrib];
	}
	newImage = NO;
}

-(void) updatePosition {
	
	if (newImage) {
	
		if (oldItem) {
			[self deleteTexture:[oldItem getTextureName]];
			[oldItem release];
			oldItem = nil;
		}
	
		[self genImage:nextItem];
		[self genImageFinished];
	}
}

-(void) notifyVisible:(RWViewItem*)item {
	[item notifiedVisible:YES];
	NSString *currentPath = [item getPath];
    RWLog(@"Set filename: %@", [currentPath lastPathComponent]);
    if (currentPath) [fileNameStringTex setString:[currentPath lastPathComponent] withAttributes:stanStringAttrib];
	//if (currentPath) [fileNameStringTex setString:currentPath withAttributes:stanStringAttrib];
	
	[self updateSearchInfoString];
	[self updateCacheInfoString];
}

-(void) drawImages {
	[self updatePosition];
	if (currentItem) [self drawImage:currentItem];
	if (oldItem) [self drawImage:oldItem];
}

-(void) drawImage:(RWViewItem*)item {
	GLuint tex = [item getTextureName];
	if (!tex) return;
	NSSize size = [item getBounds].size;
	recVec pos = [item getOriginalPosition];
	
	if ([[RWOptions sharedInstance] isZoomEnabled]) {
		float imageTimeTotal = [[RWOptions sharedInstance] getInterval] + [[RWOptions sharedInstance] getFadeAmount] + 2.0f;
		pos = [item getCurrentPos:[self getElapsedTime] total:imageTimeTotal];
	}
	
	int width = size.width;
	int height = size.height;
	
	float x = pos.x;
	float y = pos.y;
	float z = pos.z;
	
	GLfloat comp = [item fadingIn] ? 1.0 : 0.0;
	
	// Fading in
	if ([[RWOptions sharedInstance] isFadeEnabled]) {
		int fadeAmount = [[RWOptions sharedInstance] getFadeAmount];
		comp = [item getFadeAlpha:fadeAmount elapsedTime:[self getElapsedTime]];
	}
	
	if (comp == 0.0) return;
	
	if (comp >= .50 && ![item notifiedVisible])
		[self notifyVisible: item];
	
	
	if (tex) {
		GLboolean depthTest = glIsEnabled (GL_DEPTH_TEST);
		glDisable (GL_DEPTH_TEST);
		glEnable (GL_BLEND); // for text fading
		glBlendFunc (GL_ONE, GL_ONE_MINUS_SRC_ALPHA); // ditto
		glColor4f (comp, comp, comp, comp);
		glEnable (GL_TEXTURE_RECTANGLE_EXT);
		glBindTexture (GL_TEXTURE_RECTANGLE_EXT, tex);
		glBegin (GL_QUADS);
		glTexCoord2f (0.0f, 0.0f); // draw upper left in world coordinates
		glVertex3f (x, y, z);
		
		glTexCoord2f (0.0f, height); // draw lower left in world coordinates
		glVertex3f (x, y + height, z);
		
		glTexCoord2f (width, height); // draw upper right in world coordinates
		glVertex3f (x + width, y + height, z);
		
		glTexCoord2f (width, 0.0f); // draw lower right in world coordinates
		glVertex3f (x + width, y, z);
		glEnd ();
		glDisable (GL_TEXTURE_RECTANGLE_EXT);
		
		//if (primaryImage) {
		//[self psychedelicMode:comp x:-200.0f y:-100.0f z:camera.viewPos.z+50 width:400 height:200];
		//}
		
		glDisable (GL_BLEND);
		if (depthTest) glEnable(GL_DEPTH_TEST);
	}
}

-(void) psychedelicMode:(float)progress x:(float)x y:(float)y z:(float)z width:(float)width height:(float)height {
	float r = 0.0;
	if (progress < 0.66) r = progress > 0.33 ? 0.33 - (progress - 0.33) : progress;
	
	float g = 0.0;
	if (progress > 0.33) g = progress > 0.66 ? 0.66 - (progress - 0.66) : progress - 0.33;
	
	float b = 0.0;
	if (progress > 0.66) b = progress - 0.66;
	
	if (r < 0) r = 0.0;
	if (g < 0) g = 0.0;
	if (b < 0) b = 0.0;
	
	float a = 0.35;
	
	if (r > 1) r = (1 - r) + 1;
	if (g > 1) g = (1 - g) + 1;
	if (b > 1) b = (1 - b) + 1;
	
	glColor4f (r, g, b, a);
	glBegin (GL_QUADS);
	glVertex3f (x, y, z);
	glVertex3f (x, y + height, z);
	glVertex3f (x + width, y + height, z);
	glVertex3f (x + width, y, z);
	glEnd ();

}

-(void) setStatus:(NSString*)s {
	[statusStringTex setString:s withAttributes:stanStringAttrib];
}

-(void) drawRect:(NSRect)rect {
	if (canceled) return;

	if (NO == fGLInit) { 
		[self prepareOpenGL];
	}
	fGLInit = YES;
	
	[self resizeGL]; // forces projection matrix update (does test for size changes)
	[self updateModelView];  // update model view matrix for object
		
#ifdef DEBUG
		[self updateCameraString];
		[self updateCurrentInfoString];
		[self updateOldInfoString];
#endif
		

	// clear our drawable
	glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	// model view and projection matricies already set

	// draw stuff
	[self drawImages];
	[self drawInfo];
		
	if ([self inLiveResize] && !fAnimate)
		glFlush ();
	else
		[[self openGLContext] flushBuffer];
	[self glReportError];
}

// set initial OpenGL state (current context is set)
// called after context is created
- (void) prepareOpenGL {
    long swapInt = 1;

    [[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval]; // set to vbl sync

	// init GL stuff here
	glEnable(GL_DEPTH_TEST);

	glShadeModel(GL_SMOOTH);    
	glEnable(GL_CULL_FACE);
	glFrontFace(GL_CCW);
	glPolygonOffset (1.0f, 1.0f);
	glPolygonMode(GL_FRONT, GL_FILL);
	
	glClearDepth(1.0f);
	glDepthFunc(GL_LEQUAL);//glHint(GL.GL_PERSPECTIVE_CORRECTION_HINT, GL.GL_NICEST); 
	
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	[self resetCamera];

	// init fonts for use with strings
	NSFont *font =[NSFont fontWithName:@"Helvetica" size:12.0];
	stanStringAttrib = [[NSMutableDictionary dictionary] retain];
	[stanStringAttrib setObject:font forKey:NSFontAttributeName];
	[stanStringAttrib setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
	
	NSFont *font2 =[NSFont fontWithName:@"Helvetica" size:20];
	stanStringAttrib2 = [[NSMutableDictionary dictionary] retain];
	[stanStringAttrib2 setObject:font2 forKey:NSFontAttributeName];
	[stanStringAttrib2 setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
	
	// ensure strings are created
	[self createStringTextures];
}

// this can be a troublesome call to do anything heavyweight, as it is called on window moves, resizes, and display config changes.  So be
// careful of doing too much here.
- (void) update // window resizes, moves and display changes (resize, depth and display config change)
{
	[super update];
	if (![self inLiveResize])  {// if not doing live resize
		[self getCurrentCaps]; // this call checks to see if the current config changed in a reasonably lightweight way to prevent expensive re-allocations
	}
}

-(id) initWithFrame: (NSRect) rect {
	NSOpenGLPixelFormat * pf = [RWOpenGLView basicPixelFormat];

	self = [super initWithFrame: rect pixelFormat: pf];
	if (self) {
		canceled = NO;
		startTime = [[NSDate date] retain];
		frameRect = rect;
	}
    return self;
}

-(void) dealloc {
	[self setCanceled:YES];
	[startTime release];
	[stanStringAttrib release];
	[stanStringAttrib2 release];
	[statusStringTex release];
	[fileNameStringTex release];
	[cameraStringTex release];
	[currentInfoStringTex release];
	[oldInfoStringTex release];
	[waitStringTex release];
	[gErrStringTex release];
	[searchInfoStringTex release];
	if (currentItem) [currentItem release];
	[super dealloc];
}

// ---------------------------------

- (BOOL)acceptsFirstResponder
{
  return YES;
}

// ---------------------------------

- (BOOL)becomeFirstResponder
{
  return  YES;
}

// ---------------------------------

- (BOOL)resignFirstResponder
{
  return YES;
}

-(void) endTimer {
	if (timer) {
		[timer invalidate];
		timer = nil;
	}
}

-(void) startTimer {
	if (timer) [self endTimer];

	timer = [NSTimer timerWithTimeInterval:(1.0f/36.0f) target:self selector:@selector(animationTimer:) userInfo:nil repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSEventTrackingRunLoopMode]; // ensure timer fires during resize
}

- (void) awakeFromNib {
	msgPersistence = 10.0;
	[self getCurrentCaps];
	fAnimate = YES;
	canceled = NO;
	
	// Start animation timer
	[self startTimer];
}

-(void) setCanceled:(BOOL)b {
	canceled = b;
	if (canceled) [self endTimer];
	else [self startTimer];
}


@end
