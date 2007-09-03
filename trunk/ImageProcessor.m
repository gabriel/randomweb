//
//  RandomImageFactory.m
//  RandomWeb
//
//  Created by Gabriel Handford on Tue Jun 22 2004.
//  Copyright 2004 Gabriel Handford. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>

#import "ImageProcessor.h"
#import "AGRegex.h"
#import "RWLog.h"

@implementation ImageProcessor

//
// Get image at the URL (synchronous)
//
+(NSData*) getImageWithURL: (NSURL*) url {
	RWLog(@"Getting url: %@", url);
	NSData* data = [url resourceDataUsingCache:YES];
	return [ImageProcessor testImage: data];
}

//
// Get image from data
//
+(NSData*) testImage: (NSData*) data {
	if (!data) {
		RWLog(@"Data was null");
		return NULL;
	}
	
	//Check if an image
	NSImage* image = [[NSImage alloc] initWithData: data];
	if (image == nil) return NULL;
	return data;
}

+(BOOL) checkImage:(NSBitmapImageRep*)image minSize:(NSSize)minSize {

	//int dpiW = ([image pixelsWide] / [image size].width) * 72.0;
	//int dpiH = ([image pixelsHigh] / [image size].height) * 72.0;
	
	if ([image pixelsWide] < minSize.width || [image pixelsHigh] < minSize.height) return false;
	return true;
}

/**
+(void) saveImages: (NSMutableArray*) urls basePath:(NSString*)basePath {
	if (urls) {
		int i = 0;
		for(i = 0; i < [urls count]; i++) {
			NSURL *u = [urls objectAtIndex:i];
			NSData* data = [ImageProcessor getImageWithURL: u];
			if (data) {
				NSString *path = [ImageProcessor getSaveFilePath:u basePath:basePath];
				RWLog(@"Writing to path: %@", path);
				[data writeToFile: path atomically:NO];
			}   
		}
	}
}
*/

+(NSSize) getSize:(float)nh viewSize:(NSSize)size {
	//RWLog(@"New height %g", nh);
	//double ratio = (double)size.width/(double)size.height;
	//RWLog(@"Ratio before: %g", ratio);
	//ratio = (ceil(ratio * 1000.0f))/1000.0f;
	//RWLog(@"Ratio ceil: %g", ratio);
	
	//double width = nh * ratio;
	//RWLog(@"width: %g", width);
	//double height = width / ratio;
	//RWLog(@"height: %g", height);
	
	double ratio = nh/size.height;
	ratio = (ceil(ratio * 1000.0f))/1000.0f;
	double width = size.width*ratio;

	return NSMakeSize((float)width, (float)nh);
}

+(NSSize) getSizeForWidth:(float)nw viewSize:(NSSize)size {
	//RWLog(@"New width %g", nw);
	//double ratio = (double)size.width/(double)size.height;
	//RWLog(@"Ratio before: %g", ratio);
	//ratio = (ceil(ratio * 1000.0f))/1000.0f;
	//RWLog(@"Ratio ceil: %g", ratio);
	
	//double height = nw * (1.0f/ratio);
	//RWLog(@"height: %g", height);
	//double width = height * ratio;
	//RWLog(@"width: %g", width);
	
	double ratio = nw/size.width;
	ratio = (ceil(ratio * 1000.0f))/1000.0f;
	double height = size.height*ratio;
	
	return NSMakeSize((float)nw, (float)height);
}

+(NSBitmapImageRep*) scaleImageRepToWidth:(NSBitmapImageRep*)rep width:(float)nw {
	NSSize size = [ImageProcessor getSizeForWidth:nw viewSize:[rep size]];
	return [ImageProcessor scaleImageRep:rep width:size.width height:size.height];
}

+(NSBitmapImageRep*) scaleImageRepToHeight:(NSBitmapImageRep*)rep height:(float)nh {
	NSSize size = [ImageProcessor getSize:nh viewSize:[rep size]];
	return [ImageProcessor scaleImageRep:rep width:size.width height:size.height];
}

+(NSBitmapImageRep*) scaleImageRep:(NSBitmapImageRep*)rep maxWidth:(float)width maxHeight:(float)height {
	NSSize size = [ImageProcessor getSize:height viewSize:[rep size]];
	if (size.width > width) size = [ImageProcessor getSizeForWidth:width viewSize:size];
	return [ImageProcessor scaleImageRep:rep width:size.width height:size.height];
}

+(NSImage*) scaleImageToWidth:(NSImage*)rep width:(float)nw flipped:(bool)flipped {
	NSSize size = [ImageProcessor getSizeForWidth:nw viewSize:[rep size]];
	return [ImageProcessor scaleImage:rep width:size.width height:size.height flipped:flipped];
}

+(NSImage*) scaleImageToHeight:(NSImage*)rep height:(float)nh flipped:(bool)flipped {
	NSSize size = [ImageProcessor getSize:nh viewSize:[rep size]];
	return [ImageProcessor scaleImage:rep width:size.width height:size.height flipped:flipped];
}

+(NSImage*) scaleImage:(NSImage*)rep width:(float)nw height:(float)nh flipped:(bool)flipped {
	//double ratio = nw/[rep size].width;

	// image to render into
	NSRect sourceRect = NSMakeRect(0.0, 0.0, [rep size].width, [rep size].height);
	NSRect destRect = NSMakeRect(0.0, 0.0, nw, nh);
    NSImage *scratch = [[[NSImage alloc] initWithSize:destRect.size] autorelease];
	//[scratch setCachedSeparately:YES];
	
	NSAffineTransform *t = [NSAffineTransform transform];
	if (flipped) {
		//NSAffineTransform *f = [NSAffineTransform transform];
		//[t scaleXBy:-1.0 yBy:-1.0];
		[t translateXBy:nw yBy:nh];
		[t rotateByDegrees:180];
		//[f concat];
	}
	
	//[t scaleBy:ratio];
	
    // draw into image, to scale it
	//NSDate *start = [NSDate date];
    [scratch lockFocus];
	//[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
	//[[NSGraphicsContext currentContext] setShouldAntialias:YES]; 

	if (flipped) [t concat];
    [rep drawInRect:destRect fromRect:sourceRect operation:NSCompositeCopy fraction:1.0];
    [scratch unlockFocus];

	return scratch;
}

+(NSBitmapImageRep*) scaleImageRep:(NSBitmapImageRep*)rep width:(float)nw height:(float)nh {
	NSBitmapImageRep *output = nil;

	// image to render into
    NSImage *scratch = [[NSImage alloc] initWithSize:NSMakeSize(nw, nh)];
	//[scratch setCachedSeparately:YES];

    // draw into image, to scale it
	RWLog(@"Scaling %d x %d to %g x %g", [rep pixelsWide], [rep pixelsHigh], nw, nh);
	
    [scratch lockFocus];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
	[[NSGraphicsContext currentContext] setShouldAntialias:YES];
    [rep drawInRect:NSMakeRect(0.0, 0.0, nw, nh)];
    output = [[[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0,0,nw,nh)] autorelease];
    [scratch unlockFocus];
	[scratch release];
	
	return output;
}

+(NSBitmapImageRep*) draw:(NSBitmapImageRep*)rep {
	return [self scaleImageRep:rep width:[rep pixelsWide] height:[rep pixelsHigh]];
}

+(NSImage*) flipImage:(NSImage*)source {
	NSRect rect = NSMakeRect(0.0, 0.0, [source size].width, [source size].height);
	NSImage* canvas = [[NSImage alloc] initWithSize: rect.size];
	[canvas setCachedSeparately:YES];
	
	// we are going to draw self on canvas and return canvas
	[canvas lockFocus];
	
	NSAffineTransform *t = [NSAffineTransform transform];
	// by scaling Y negatively, we effectively flip the image
	[t scaleXBy:-1.0 yBy:-1.0];
	// but we also have to translate it back by its height:
	[t translateXBy:-rect.size.width yBy:-rect.size.height];
	// apply the transform
	[t concat];
	[source drawInRect:rect fromRect:rect operation:NSCompositeCopy fraction:1.0];
    [canvas unlockFocus];
    return [canvas autorelease];
}

+(NSBitmapImageRep*) getBitmap:(NSImage*)image { 
	NSRect r = { {0.,0.}, {[image size].width, [image size].height}};
	NSBitmapImageRep *bm = nil;
	NSImage *tiffCache = [[[NSImage allocWithZone:[self zone]] initWithSize:r.size] autorelease];
	//[tiffCache setCachedSeparately:YES];
	
	// Had depth = 520 before, have no idea why
	NSCachedImageRep *rep = [[[NSCachedImageRep alloc] initWithSize:r.size depth:520 separate:YES alpha:YES] autorelease];
	[tiffCache addRepresentation:rep];
	[tiffCache lockFocusOnRepresentation:rep];
	[image compositeToPoint:NSZeroPoint operation:NSCompositeCopy]; //SourceOver];
	
	// OK, now let's create an NSBitmapImageRep form the data.. 
	bm = [[[NSBitmapImageRep alloc] initWithFocusedViewRect:r] autorelease];
	if (bm == nil)
		bm = [NSBitmapImageRep imageRepWithData: [tiffCache TIFFRepresentation]];
	[tiffCache unlockFocus];
	if (bm == nil)
		RWLog(@"in getBitMap : no NSBitmapImageRep of the right depth found");
	return bm;
}

+(int) nextPowerOfTwo:(int)size {
	if (size <= 0) return false;
	int bitpos = -1;

	int i = -1;
    while(size != 0) {
		i++;
        size = size >> 1;
        if(size & 0x1) {
			bitpos = i;
		}
    }
	
	return pow(2, (bitpos+2));
}

+(int) isPowerOfTwo:(int)size {
    int bits = 0;
	if (size <= 0) return false;
	int bitpos = -1;

	int i = -1;
    while(size != 0) {
		i++;
        size = size >> 1;
        if(size & 0x1) {
			bits++;
			bitpos = i;
		}
    }
    //return bits<2;
	
	return pow(2, (bitpos+1));
}

+(BOOL) testImageFromPath:(NSString*)savePath minSize:(NSSize)minSize {
	NSURL *URL = [NSURL fileURLWithPath:savePath];
	NSImage *image = [[NSImage alloc] initWithContentsOfURL: URL];
	if (image) {
		if ([image size].width >= minSize.width && [image size].height >= minSize.height) {
			[image release];
			return YES;
		}
		RWLog(@"Test failed (actual image size too small): %d x %d", [image size].width, [image size].height);
		[image release];
	} else {
		RWLog(@"Test failed: Image couldn't be created from data");
	}
	return NO;
}

@end
