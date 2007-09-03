#import "SQLDatabase.h"
#import "SQLDatabasePrivate.h"

@implementation SQLDatabase

+(id) databaseWithFile:(NSString*)inPath {
	return [[[SQLDatabase alloc] initWithFile:inPath] autorelease];
}

-(id) initWithFile:(NSString*)inPath {
	self = [super init];
    if (self) {
		mPath = [inPath copy];
		mDatabase = NULL;
	}
	return self;
}

-(id) init {
	self = [super init];
    if (self) {
		mPath = NULL;
		mDatabase = NULL;
	}
	return self;
}

-(void) dealloc {
	[self close];
	[mPath release];
	[super dealloc];
}

-(BOOL) open {
	int status;
	status = sqlite3_open([mPath fileSystemRepresentation], &mDatabase);
	return (status == SQLITE_OK);
}

-(void) close {
	if (!mDatabase)
		return;
	
	sqlite3_close(mDatabase);
	mDatabase = NULL;
}


+(NSString*) prepareStringForQuery:(NSString*)inString {
	NSMutableString*	string;
	NSRange				range = NSMakeRange(0, [inString length]);
	NSRange				subRange;
	
	subRange = [inString rangeOfString:@"'" options:NSLiteralSearch range:range];
	if(subRange.location == NSNotFound)
		return inString;
	
	string = [NSMutableString stringWithString:inString];
	for(; subRange.location != NSNotFound && range.length > 0;) {
		subRange = [string rangeOfString:@"'" options:NSLiteralSearch range:range];
		if( subRange.location != NSNotFound )
			[string replaceCharactersInRange:subRange withString:@"''"];
		
		range.location = subRange.location + 2;
		range.length = ([string length] < range.location) ? 0 : ([string length] - range.location);
	}
	
	return string;
}

-(SQLResult*) performQuery:(NSString*)inQuery {
	SQLResult*	sqlResult = nil;
	char**		results;
	int			result;
	int			columns;
	int			rows;
	
	if(!mDatabase)
		return nil;
	
	result = sqlite3_get_table(mDatabase, [inQuery cString], &results, &rows, &columns, NULL);
	if(result != SQLITE_OK) {
		sqlite3_free_table(results);
		return nil;
	}
	
	sqlResult = [[SQLResult alloc] initWithTable:results rows:rows columns:columns];
	if( !sqlResult )
		sqlite3_free_table(results);
	
	return sqlResult;
}

-(SQLResult*) performQueryWithFormat:(NSString*)inFormat, ... {
	SQLResult*	sqlResult = nil;
	NSString*	query = nil;
	va_list		arguments;
	
	if(inFormat == nil)
		return nil;
	
	va_start(arguments, inFormat);
	
	query = [[NSString alloc] initWithFormat:inFormat arguments:arguments];
	sqlResult = [self performQuery:query];
	[query release];
	
	va_end(arguments);
	
	return sqlResult;
}

@end
