//
//  RWViewItem.h
//  RandomWeb
//
//  Created by g4b3 on 11/22/04.
//  Copyright 2004 Cellar Door Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/gl.h>
#import <OpenGL/glext.h>
#import <OpenGL/glu.h>

typedef struct {
   GLdouble x,y,z;
} recVec;

@interface RWViewItem : NSObject {
	
	GLuint texName;
	
	NSRect texBounds;
	recVec originalPos;
	recVec currentPos;
	recVec movementVector;	
	
	NSString *currentPath;
	NSBitmapImageRep *currentImage;
	float viewStartTime;
	float viewEndTime;
	BOOL fadingIn;
	BOOL movingIn;
	BOOL notifiedVisible;

}

-(id) initWithImage:(NSBitmapImageRep*)image path:(NSString*)path;
-(void) dealloc;

-(void) setParameters:(recVec)position movementVector:(recVec)movement bounds:(NSRect)bounds;
-(void) setViewStartTime:(float)start;
-(float) getViewStartTime;
-(void) setViewEndTime:(float)t;
-(float) getViewEndTime;
-(recVec) getCurrentPosition;
-(void) setCurrentPosition:(recVec)position;
-(NSRect) getBounds;
-(NSBitmapImageRep*) getImage;
-(recVec) getOriginalPosition;
-(recVec) getMovementVector;
-(BOOL) hasTexture;
-(void) releaseImage;

-(float) getFadeAlpha:(float)fadeAmount elapsedTime:(double)elapsedTime;
-(BOOL) fadingIn;
-(void) fadingIn:(BOOL)f;
-(BOOL) movingIn;
-(void) movingIn:(BOOL)b;
-(BOOL) notifiedVisible;
-(void) notifiedVisible:(BOOL)b;

-(recVec) getCurrentPos:(float)elapsedTime total:(float)imageTimeTotal;

-(NSString*) getPath;

-(GLuint) getTextureName;
-(void) setTextureName:(GLuint)textureName;

@end
