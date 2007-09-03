
#import <Foundation/Foundation.h>

@protocol DownloadListener
-(void) didStartDownload:(NSURL*)url count:(int)index path:(NSString*)savePath;
-(void) didFinishDownload:(NSURL*)url count:(int)index path:(NSString*)savePath;

-(void) didErrorOnDownload:(NSError*)error count:(int)c;

-(void) didLoadData:(NSURL*)url length:(unsigned)l total:(long long)t;
-(void) didAbort;
-(void) didFinishDownloads:(BOOL)interrupted;
@end