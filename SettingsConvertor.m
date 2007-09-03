//
//  SettingsConvertor.m
//  RandomWeb
//
//  Created by g4b3 on 3/23/05.
//  Copyright 2005 Cellar Door Software. All rights reserved.
//

#import <ScreenSaver/ScreenSaverDefaults.h>
#import "SettingsConvertor.h"
#import "GoogleSearchParamItem.h"

@implementation SettingsConvertor

+(void) convert:(RWOptions*)options {

	RWSimpleSettings *settings = [options getSimpleSettings];
	
	NSUserDefaults *std = [ScreenSaverDefaults defaultsForModuleWithName:@"com.cellardoorsw.randomweb"];
	
	int minWidthPhoto = 1024;
	int minHeightPhoto = 768;
	int minWidthSite = 640;
	int minHeightSite = 480;
	int minWidthPhrase = 640;
	int minHeightPhrase = 480;
	
	if( [std objectForKey:@"RWMinWidth"] )
        minWidthPhoto = [std integerForKey:@"RWMinWidth"];
		
	if( [std objectForKey:@"RWMinHeight"] )
		minHeightPhoto = [std integerForKey:@"RWMinHeight"];

	if( [std objectForKey:@"RWSearchInterval"] )
        settings->searchInterval = [std floatForKey:@"RWSearchInterval"];
		
	if( [std objectForKey:@"RWImageInterval"] )
        settings->imageInterval = [std floatForKey:@"RWImageInterval"];

	if( [std objectForKey:@"RWSearchSafeness"] )
		[options setSearchSafeness:[std stringForKey:@"RWSearchSafeness"]];

	if( [std objectForKey:@"RWMaxImagePerSearch"] )
        settings->maxImagePerSearch = [std integerForKey:@"RWMaxImagePerSearch"];
		
	if( [std objectForKey:@"RWImageExpiration"] )
        settings->imageExpiration = [std integerForKey:@"RWImageExpiration"];
		
	if( [std objectForKey:@"RWMaxCacheSize"] )
        settings->maxCacheSize = [std integerForKey:@"RWMaxCacheSize"];
		
	if( [std objectForKey:@"RWMinImageCount"] )
        settings->minImageCount = [std integerForKey:@"RWMinImageCount"];
		
	if( [std objectForKey:@"RWShowStatus"] )
        settings->showStatus = [std boolForKey:@"RWShowStatus"];
		
	if( [std objectForKey:@"RWShowFileName"] )
        settings->showFileName = [std boolForKey:@"RWShowFileName"];
		
	if( [std objectForKey:@"RWSocketTimeout3"] )
        settings->socketTimeout = [std integerForKey:@"RWSocketTimeout3"];
		
	if ( [std objectForKey:@"isFadeEnabled"] )
		settings->isFadeEnabled = [std boolForKey:@"isFadeEnabled"];
		
	if ( [std objectForKey:@"FadeAmount"] )
		settings->fadeAmount = [std integerForKey:@"FadeAmount"];
		
	if ( [std objectForKey:@"isZoomEnabled"] )
		settings->isZoomEnabled = [std boolForKey:@"isZoomEnabled"];
		
	if ( [std objectForKey:@"RWMinWidth_Site"] )
        minWidthSite = [std integerForKey:@"RWMinWidth_Site"];
		
	if ( [std objectForKey:@"RWMinHeight_Site"] )
		minHeightSite = [std integerForKey:@"RWMinHeight_Site"];
		
	if ( [std objectForKey:@"RWMinWidth_Phrase"] )
        minWidthPhrase = [std integerForKey:@"RWMinWidth_Phrase"];
		
	if ( [std objectForKey:@"RWMinHeight_Phrase"] )
		minHeightPhrase = [std integerForKey:@"RWMinHeight_Phrase"];
	
	NSMutableArray *items = [NSMutableArray arrayWithCapacity:50];
				
	if ( [std objectForKey:@"Phrases"] ) {
		NSArray *array = [std stringArrayForKey:@"Phrases"];
		int i;
		for(i = 0; i < [array count]; i++) {
			GoogleSearchParamItem *item = [[GoogleSearchParamItem alloc] init:YES type:RWPhraseSearch keyword:[array objectAtIndex:i] minSize:NSMakeSize(minWidthPhrase, minHeightPhrase)];
			[items addObject:item];
		}
	}
	
	if ( [std objectForKey:@"Sites"] ) {
		NSArray *array = [std stringArrayForKey:@"Sites"];
		int i;
		for(i = 0; i < [array count]; i++) {
			GoogleSearchParamItem *item = [[GoogleSearchParamItem alloc] init:YES type:RWSiteSearch keyword:[array objectAtIndex:i] minSize:NSMakeSize(minWidthSite, minHeightSite)];
			[items addObject:item];
		}
	}
	
	int i;
	for(i = 0; i < [items count]; i++) 
		[options addSearchParamItem:[items objectAtIndex:i] sync:NO];
	
	[options setConverted:YES];
	[options saveSettings];
}

@end
