//
//  SettingsNode.h
//  RandomWeb
//
//  Created by Gabriel Handford on 2/19/05.
//  Copyright 2005 Gabriel Handford. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SettingsNode : NSObject {
	NSMutableArray *children;
    NSString *key;
	NSString *value;
	NSString *longDesc;
	int identifier;
	BOOL isBoolValue;
	BOOL isFloatValue;
}

-(id) init:(NSString*)k value:(NSString*)v identifier:(int)i;
-(id) init:(NSString*)key value:(NSString*)value identifier:(int)i isBool:(BOOL)b;
-(id) init:(NSString*)key value:(NSString*)value identifier:(int)i isFloat:(BOOL)b;
-(id) init:(NSString*)k value:(NSString*)v identifier:(int)i type:(int)t;
//-(void) setItemName:(NSString*)s;

-(NSString*) getKey;
-(NSString*) getValue;
-(void) setValue:(NSString*)v;
-(int) getIdentifier;
-(NSString*) getLongDesc;
-(void) setLongDesc:(NSString*)desc;

-(void) addChild:(SettingsNode *)n;
-(SettingsNode*) childAtIndex:(int)i;
-(int) childrenCount;
-(NSArray*) getChildren;
-(BOOL) expandable;
-(void) dealloc;

-(float) getValueAsFloat;
-(int) getValueAsInt;
-(BOOL) getValueAsBool;
-(BOOL) getValueAsBool:(NSString*)s;
@end
