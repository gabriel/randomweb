//
//  ITunesAccessor.m
//  RandomWeb
//
//  Created by g4b3 on 5/4/05.
//  Copyright 2005 Cellar Door Software. All rights reserved.
//

#import "ITunesAccessor.h"
#import "RWLog.h"
#import "StringUtil.h"

@implementation ITunesAccessor


+(void) getCurrentArtistImpl:(NSMutableString*)artist {

	NSString *currentArtistScript = @" \
tell application \"System Events\"\n \
    if ((application processes whose (name is equal to \"iTunes\")) count) is greater than 0 then\n \
        tell application \"iTunes\"\n \
            if player state is playing then\n \
                set the_artist to artist of current track\n \
            end if\n \
        end tell\n \
	end if\n \
	return the_artist\n \
end tell";

	NSAppleScript *script = [[NSAppleScript alloc] initWithSource:currentArtistScript];
	
	NSDictionary *errorDict = [NSDictionary dictionary];
	
	NSObject *errorMsg = [errorDict objectForKey:NSAppleScriptErrorMessage];
	if (errorMsg) RWLog(@"Error: %@", errorMsg);
	
	NSAppleEventDescriptor *eventDesc = [script executeAndReturnError:&errorDict];
	
	[script release];
	if (eventDesc) {
		RWLog(@"Found artist: %@", [eventDesc stringValue]);
		[artist appendFormat:@"%@", [eventDesc stringValue]];
		return;
	}

	RWLog(@"No artist playing");
	return;
}

+(void) getCurrentSongImpl:(NSMutableString*)name {

	NSString *currentNameScript = @" \
tell application \"System Events\"\n \
    if ((application processes whose (name is equal to \"iTunes\")) count) is greater than 0 then\n \
        tell application \"iTunes\"\n \
            if player state is playing then\n \
                set the_name to name of current track\n \
            end if\n \
        end tell\n \
	end if\n \
	return the_name\n \
end tell";

	NSAppleScript *script = [[NSAppleScript alloc] initWithSource:currentNameScript];
	
	NSDictionary *errorDict = [NSDictionary dictionary];
	
	NSObject *errorMsg = [errorDict objectForKey:NSAppleScriptErrorMessage];
	if (errorMsg) RWLog(@"Error: %@", errorMsg);
	
	NSAppleEventDescriptor *eventDesc = [script executeAndReturnError:&errorDict];
	
	[script release];
	if (eventDesc) {
		RWLog(@"Found name: %@", [eventDesc stringValue]);
		[name appendFormat:@"%@", [eventDesc stringValue]];
		return;
	}

	RWLog(@"No name playing");
	return;
}

+(void) getCurrentAlbumImpl:(NSMutableString*)name {

	NSString *currentNameScript = @" \
tell application \"System Events\"\n \
    if ((application processes whose (name is equal to \"iTunes\")) count) is greater than 0 then\n \
        tell application \"iTunes\"\n \
            if player state is playing then\n \
                set the_name to album of current track\n \
            end if\n \
        end tell\n \
	end if\n \
	return the_name\n \
end tell";

	NSAppleScript *script = [[NSAppleScript alloc] initWithSource:currentNameScript];
	
	NSDictionary *errorDict = [NSDictionary dictionary];
	
	NSObject *errorMsg = [errorDict objectForKey:NSAppleScriptErrorMessage];
	if (errorMsg) RWLog(@"Error: %@", errorMsg);
	
	NSAppleEventDescriptor *eventDesc = [script executeAndReturnError:&errorDict];
	
	[script release];
	if (eventDesc) {
		RWLog(@"Found album: %@", [eventDesc stringValue]);
		[name appendFormat:@"%@", [eventDesc stringValue]];
		return;
	}

	RWLog(@"No album playing");
	return;
}


+(NSString*) getCurrentArtist {
	RWLog(@"Checking artist");
	NSMutableString *artist = [[NSMutableString alloc] initWithCapacity:20];
	[ITunesAccessor performSelectorOnMainThread:@selector(getCurrentArtistImpl:) withObject:artist waitUntilDone:YES];
	[artist autorelease];
	RWLog(@"Done checking artist");
	if ([artist isEqual:@""]) return nil;
	return artist;
}

+(NSString*) getCurrentArtistIgnoreVA {
	NSString *artist = [self getCurrentArtist];
	if ([self isVariousArtist:artist]) 
		return [self extractArtist:[self getCurrentSong]];
	return artist;
}

+(NSString*) extractArtist:(NSString*)name {
	if (!name) return nil;
	RWLog(@"Extract artist: %@", name);
	NSArray *array = [name componentsSeparatedByString:@"-"];
	if ([array count] > 1) return [array objectAtIndex:0];
	
	array = [name componentsSeparatedByString:@"/"];
	if ([array count] > 1) return [array objectAtIndex:0];
	return name;
}

+(BOOL) isVariousArtist:(NSString*)artist {
	if (!artist) return FALSE;
	NSString *trimmed = [StringUtil trim:artist];
	return ([trimmed  compare:@"VA" options:NSCaseInsensitiveSearch] == NSOrderedSame ||
			[trimmed compare:@"Various Artists" options:NSCaseInsensitiveSearch] == NSOrderedSame);
}

+(NSString*) getCurrentSong {
	RWLog(@"Checking name");
	NSMutableString *name = [[NSMutableString alloc] initWithCapacity:20];
	[ITunesAccessor performSelectorOnMainThread:@selector(getCurrentSongImpl:) withObject:name waitUntilDone:YES];
	[name autorelease];
	RWLog(@"Done checking name");
	if ([name isEqual:@""]) return nil;
	return name;
}

+(NSString*) getCurrentAlbum {
	RWLog(@"Checking album");
	NSMutableString *name = [[NSMutableString alloc] initWithCapacity:20];
	[ITunesAccessor performSelectorOnMainThread:@selector(getCurrentAlbumImpl:) withObject:name waitUntilDone:YES];
	[name autorelease];
	RWLog(@"Done checking album");
	if ([name isEqual:@""]) return nil;
	return name;
}

@end
