//
//  SettingsNode.m
//  RandomWeb
//
//  Created by g4b3 on 2/19/05.
//  Copyright 2005 Cellar Door Software. All rights reserved.
//

#import "SettingsNode.h"
#import "RWLog.h"

@implementation SettingsNode

-(id) init:(NSString*)k value:(NSString*)v identifier:(int)i {
	return [self init:k value:v identifier:i type:0];
}

-(id) init:(NSString*)k value:(NSString*)v identifier:(int)i isFloat:(BOOL)b {
	return [self init:k value:v identifier:i type:(b ? 2 : 0)];
}

-(id) init:(NSString*)k value:(NSString*)v identifier:(int)i isBool:(BOOL)b {
	return [self init:k value:v identifier:i type:(b ? 1 : 0)];
}

-(id) init:(NSString*)k value:(NSString*)v identifier:(int)i type:(int)t {
    self = [super init];
	if (self) {
		if (k) key = [k retain];
		identifier = i;
		isBoolValue = (t == 1);
		isFloatValue = (t == 2);
		children = [[NSMutableArray alloc] init];
		[self setValue:v];
	}
    return self;
}

-(NSString*) getLongDesc { return longDesc; }

-(void) setLongDesc:(NSString*)desc {
	if (longDesc) [longDesc release];
	longDesc = [desc retain];
}

-(int) getIdentifier {
	return identifier;
}

-(NSArray*) getChildren {
	return children;
}

-(NSString*) getKey {
    return key;
}

-(NSString*) getValue {
	return value;
}

-(float) getValueAsFloat {
	return [value floatValue];
}

-(int) getValueAsInt {
	return [value intValue];
}

-(BOOL) getValueAsBool {
	return [self getValueAsBool:value];
}

-(BOOL) getValueAsBool:(NSString*)s {
	if (!s) return NO;
	return [[s lowercaseString] isEqual:@"yes"];
}

-(void) setValue:(NSString*)v {
	[value release];
	if (!v) return;

	if (isBoolValue) {
		 if ([self getValueAsBool:v]) v = @"Yes";
		 else v = @"No";
	} else if (isFloatValue) {
		v = [NSString stringWithFormat:@"%g", [v floatValue]];
	} else {
		v = [NSString stringWithFormat:@"%d", [v intValue]];
	}
	
	value = [v retain];
	RWLog(@"[%@] Set value: %@", key, value);
}

-(void) addChild:(SettingsNode *)n {
    [children addObject:n];
}

-(SettingsNode*) childAtIndex:(int)i { 
    return [children objectAtIndex:i];
}

-(int) childrenCount {
    return [children count];
}

-(BOOL) expandable {
    return ([children count] > 0);
}

-(void) dealloc {
    [children release];
	if (key) [key release];
	if (value) [value release];
    [super dealloc];
}

@end

