//
//  RWViewItem.m
//  RandomWeb
//
//  Created by g4b3 on 11/22/04.
//  Copyright 2004 Cellar Door Software. All rights reserved.
//

#import "RWViewItem.h"


@implementation RWViewItem


-(id) initWithImage:(NSBitmapImageRep*)image path:(NSString*)path {
	self = [super init];
    if (self) {
		currentImage = [image retain];
		currentPath = [path retain];
	}
    return self;
}

-(void) dealloc {
	if (currentImage) [currentImage release];
	if (currentPath) [currentPath release];
	[super dealloc];
}

-(void) releaseImage {
	if (currentImage) {
		[currentImage release];
		currentImage = nil;
	}
}

-(float) getFadeAlpha:(float)fadeAmount elapsedTime:(double)elapsedTime {
	float viewTime;
	if (fadingIn) viewTime = viewStartTime;
	else viewTime = viewEndTime;

	GLfloat comp = 1 - ((fadeAmount - elapsedTime + viewTime) * (1.0f/fadeAmount));
	if (!fadingIn) comp = 1 - comp;
	if (comp > 1.0) return 1.0;
	else if (comp < 0.0) return 0.0;
	
	return comp;
}

-(recVec) getCurrentPos:(float)elapsedTime total:(float)imageTimeTotal {
	float percentDistance = ((imageTimeTotal - elapsedTime + viewStartTime) * (1.0f/imageTimeTotal));
	if (percentDistance < 0) percentDistance = 0;
	else if (percentDistance > 1) percentDistance = 1;

	currentPos.x = originalPos.x - ((movingIn ? 1-percentDistance : percentDistance)*movementVector.x);
	currentPos.y = originalPos.y - ((movingIn ? 1-percentDistance : percentDistance)*movementVector.y);
	currentPos.z = originalPos.z - ((movingIn ? 1-percentDistance : percentDistance)*movementVector.z);

	return currentPos;
}

-(BOOL) fadingIn {
	return fadingIn;
}

-(void) fadingIn:(BOOL)f {
	fadingIn = f;
}

-(BOOL) movingIn {
	return movingIn;
}

-(void) movingIn:(BOOL)b {
	movingIn = b;
}

-(BOOL) notifiedVisible {
	return notifiedVisible;
}

-(void) notifiedVisible:(BOOL)b {
	notifiedVisible = b;
}

-(void) setParameters:(recVec)position movementVector:(recVec)movement bounds:(NSRect)bounds {
	originalPos = position;
	currentPos = position;
	movementVector = movement;
	texBounds = bounds;
}

-(recVec) getMovementVector {
	return movementVector;
}

-(recVec) getCurrentPosition {
	return currentPos;
}

-(recVec) getOriginalPosition {
	return originalPos;
}

-(BOOL) hasTexture {
	return texName;
}

-(void) setCurrentPosition:(recVec)position {
	currentPos = position;
}

-(NSRect) getBounds {
	return texBounds;
}

-(NSBitmapImageRep*) getImage {
	return currentImage;
}

-(NSString*) getPath {
	return currentPath;
}

-(GLuint) getTextureName {
	return texName;
}

-(void) setTextureName:(GLuint)textureName {
	texName = textureName;
}

-(void) setViewStartTime:(float)start {
	viewStartTime = start;
	[self fadingIn:YES];
}

-(float) getViewStartTime {
	return viewStartTime;
}

-(void) setViewEndTime:(float)end {
	viewEndTime = end;
	[self fadingIn:NO];
}

-(float) getViewEndTime {
	return viewEndTime;
}


@end
