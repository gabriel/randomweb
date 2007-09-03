//
//  ITunesAccessor.h
//  RandomWeb
//
//  Created by g4b3 on 5/4/05.
//  Copyright 2005 Cellar Door Software. All rights reserved.
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
