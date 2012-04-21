//
//  WizFileManger.m
//  Wiz
//
//  Created by MagicStudio on 12-4-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizFileManager.h"
#import "WizGlobalData.h"

@implementation WizFileManager
@synthesize accountUserId;

+(NSString*) documentsPath
{
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* documentDirectory = [paths objectAtIndex:0];
	return documentDirectory;
}

-(BOOL) ensurePathExists:(NSString*)path
{
	BOOL b = YES;
    if (![self fileExistsAtPath:path])
	{
		NSError* err = nil;
		b = [self createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&err];
		if (!b)
		{
			[WizGlobals reportError:err];
		}
	}
	return b;
}

- (NSString*) accountPath
{
	NSString* documentPath = [WizFileManager documentsPath];
	NSString* subPathName = [NSString stringWithFormat:@"%@/", self.accountUserId]; 
	NSString* path = [documentPath stringByAppendingPathComponent:subPathName];
	[self ensurePathExists:path];
	return path;
}

+ (id) shareManager
{
    return nil;
}

- (NSString*) dbPath
{
    NSString* accountPath = [self accountPath];
	return [accountPath stringByAppendingPathComponent:@"index.db"];
}
- (NSString*) tempDbPath
{
    NSString* accountPath = [self accountPath];
	return [accountPath stringByAppendingPathComponent:@"temp.db"];
}
@end
