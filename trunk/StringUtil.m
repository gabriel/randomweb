//
//  StringUtil.m
//  RandomWeb
//
//  Created by Gabriel Handford on Wed Sep 08 2004.
//  Copyright 2004 Gabriel Handford. All rights reserved.
//

#import "StringUtil.h"
#import "RWLog.h"

@implementation StringUtil

+(NSString*) trim:(NSString*)s {
	return [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

+(NSString*) trim:(NSString*)s chars:(NSString*)cs {
	return [s stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:cs]];
}

+(NSString*) lossyString:(NSString*)s {
	const char *cstr = [s lossyCString];
	return [NSString stringWithCString:cstr];
}

+(NSString*) removeFromString:(NSString*)source string:(NSString*)s {
	return [StringUtil replaceInString:source string:s replace:@""];
}

+(NSString*) replaceInString:(NSString*)source string:(NSString*)s replace:(NSString*)r {
	//NSCharacterSet *cset = [NSCharacterSet characterSetWithCharactersInString:chars];
	//return [source stringByTrimmingCharactersInSet:cset];
	
	NSMutableString *ms = [NSMutableString stringWithCapacity:[source length]];
	[ms appendString:source];
	[ms replaceOccurrencesOfString:s withString:r options:0 range:NSMakeRange(0, [ms length])];
	return ms;
}

+(NSString*) addURLEscapes:(NSString*)url {
	return [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+(NSString*) removeURLEscapes:(NSString*)url {
	return [url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	//(NSString*)CFURLCreateStringByReplacingPercentEscapes(NULL,(CFStringRef)url,CFSTR(""));
}

+(NSStringEncoding) getStringEncoding:(NSString*)ename {
	if (!ename) return NSUTF8StringEncoding;//NSISOLatin1StringEncoding;
	return CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)ename));
}

+(BOOL) isEmptyString:(NSString*)s {
	if (!s) return YES;
	return [[StringUtil trim:s] isEqualTo:@""];
}

+(NSString*) decodeData:(NSData*)data encoding:(NSString*)encoding {
	if ([data length] == 0) return @"";
	if (encoding) {
		NSStringEncoding enc = [StringUtil getStringEncoding:encoding];
		RWLog(@"Using string encoding:%@", encoding);
		return [[[NSString alloc] initWithData:data encoding:enc] autorelease];
	} else {
		NSString *s = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
		if ([s length] == 0) return [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
		return s;
	}
}

@end
