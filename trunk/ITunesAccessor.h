//
//  ITunesAccessor.h
//  RandomWeb
//
//  Created by Gabriel Handford on 5/4/05.
//  Copyright 2005 Gabriel Handford. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ITunesAccessor : NSObject {

}

+(NSString*) getCurrentArtist;
+(NSString*) getCurrentArtistIgnoreVA;
+(NSString*) getCurrentSong;
+(NSString*) getCurrentAlbum;
+(NSString*) extractArtist:(NSString*)name;
+(BOOL) isVariousArtist:(NSString*)artist;
+(NSString*) extractArtist:(NSString*)name;

@end
