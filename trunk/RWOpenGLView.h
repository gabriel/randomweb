//
//  RWOpenGLView.h
//  RandomWeb
//
//  Created by g4b3 on Thu Jul 22 2004.
//  Copyright (c) 2004 Cellar Door Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import <OpenGL/gl.h>
#import <OpenGL/glext.h>
#import <OpenGL/glu.h>

#import "StringTexture.h"
#import "glcheck.h"
#import "drawinfo.h"
#import "RWViewItem.h"

typedef struct {
	recVec viewPos; // View position
	recVec viewDir; // View direction vector
	recVec viewUp; // View up direction
	recVec rotPoint; // Point to rotate about
	GLdouble aperture; // pContextInfo->camera aperture
	GLint viewWidth, viewHeight; // current window/screen height and width
} recCamera;


@interface RWOpenGLView : NSOpenGLView {
	
	bool fGLInit;
	bool fAnimate;
	
	NSTimer* timer;
	
	// string attributes
	NSMutableDictionary *stanStringAttrib;
	NSMutableDictionary *stanStringAttrib2;

	// string textures
	StringTexture *statusStringTex;
	StringTexture *fileNameStringTex;
	StringTexture *cameraStringTex;
	StringTexture *currentInfoStringTex;
	StringTexture *oldInfoStringTex;
	StringTexture *waitStringTex;
	StringTexture *gErrStringTex;
	StringTexture *searchInfoStringTex;
	StringTexture *cacheInfoStringTex;
	
	// camera handling
	recCamera camera;
	
	// items on display
	RWViewItem *oldItem;
	RWViewItem *currentItem;
	RWViewItem *nextItem;
	
	// times
	float errorTime;
	float msgPersistence;
	NSDate *startTime;
	
	// movement & fading
	BOOL movingIn;
	
	// flags
	BOOL newImage;
	BOOL canceled;
	BOOL notifiedVisible;
	
	// caps
	GLCaps *gDisplayCaps; // array of GLCaps
	CGDisplayCount gNumDisplays;
	
	// help
	NSDate *showHelpStart;
	StringTexture *helpStringTex;
	
	NSRect frameRect;
}

+ (NSOpenGLPixelFormat*) basicPixelFormat;

- (void) updateProjection;
- (void) updateModelView;
- (void) resizeGL;
- (void) resetCamera;

- (void) animationTimer:(NSTimer *)timer;
- (void) drawInfo;

-(void) setStatus:(NSString*)s;
-(void) setImage:(NSBitmapImageRep*)image path:(NSString*)s;
-(void) deleteTexture:(GLuint)tex;

-(void) drawRect:(NSRect)rect;

- (void) prepareOpenGL;
- (void) update;		// moved or resized

- (BOOL) acceptsFirstResponder;
- (BOOL) becomeFirstResponder;
- (BOOL) resignFirstResponder;

- (id) initWithFrame: (NSRect) frameRect;
- (void) awakeFromNib;

-(void) clearImages;
-(void) drawImages;
-(void) drawImage:(RWViewItem*)item;
-(void) genImage:(RWViewItem*)viewItem;
-(void) setCanceled:(BOOL)b;
-(bool) isWidthFill:(NSSize)size;
-(float) getDistanceToFill:(NSSize)size;
-(void) updatePosition;

-(void) genImageFinished;

-(void) showHelp;


@end
