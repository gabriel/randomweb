
#import <Foundation/Foundation.h>

@protocol MatchListener

-(void) didFindMatch:(NSURL*)url savePath:(NSString*)savePath count:(int)count;
-(void) didCompleteMatchSearch;
-(int) downloadCount;

@end