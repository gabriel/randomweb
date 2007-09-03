//
//  RandomImageFactory.h
//  RandomWeb
//
//  Created by g4b3 on Tue Jun 22 2004.
//  Copyright (c) 2004 Cellar Door Software. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>

@interface ImageProcessor : NSObject {

}

//+(NSString*) getSaveFilePath:(NSURL*)url basePath:(NSString*)p;
//+(NSMutableArray*) getImageURLs:(NSURL*)searchURL;
+(NSData*) getImageWithURL:(NSURL*)url;
//+(void) saveImages:(NSMutableArray*)urls basePath:(NSString*)basePath;
+(NSData*) testImage:(NSData*)data;

+(BOOL) checkImage:(NSBitmapImageRep*)image minSize:(NSSize)minSize;
+(BOOL) testImageFromPath:(NSString*)savePath minSize:(NSSize)minSize;

+(NSBitmapImageRep*) scaleImageRep:(NSBitmapImageRep*)rep width:(float)nw height:(float)nh;
+(NSBitmapImageRep*) scaleImageRepToHeight:(NSBitmapImageRep*)rep height:(float)nh;
+(NSBitmapImageRep*) scaleImageRepToWidth:(NSBitmapImageRep*)rep width:(float)nw;

+(NSBitmapImageRep*) draw:(NSBitmapImageRep*)rep;

+(NSImage*) flipImage:(NSImage*)source;
+(int) isPowerOfTwo:(int)size;
+(int) nextPowerOfTwo:(int)size;
+(NSBitmapImageRep*) getBitmap:(NSImage*)image;
+(NSSize) getSize:(float)nh viewSize:(NSSize)size;
+(NSImage*) scaleImageToHeight:(NSImage*)rep height:(float)nh flipped:(bool)f;
+(NSImage*) scaleImage:(NSImage*)rep width:(float)nw height:(float)nh flipped:(bool)f;
+(NSImage*) scaleImageToWidth:(NSImage*)rep width:(float)nw flipped:(bool)flipped;
+(NSBitmapImageRep*) scaleImageRep:(NSBitmapImageRep*)rep maxWidth:(float)width maxHeight:(float)height;



@end
