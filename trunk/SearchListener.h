#import <Foundation/Foundation.h>

@protocol SearchListener

-(void) didStartSearch:(NSURL*)url;
-(void) didFinishSearch:(int)count;
-(void) didErrorOnSearch:(NSError*)error;

@end