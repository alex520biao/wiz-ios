//
//  WizUploadObject.m
//  WizLib
//
//  Created by 朝 董 on 12-4-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizUploadObject.h"
#import "WizFileManager.h"

#define UploadPartSize  (256*1024)

@interface WizUploadObject()
{
    NSFileHandle* fileHandle;
    NSString* guid;
    NSString* type;
    NSString* sumMd5;
    NSInteger fileSize;
}
@property (retain) NSFileHandle* fileHandle;
@property (retain, nonatomic) NSString* guid;
@property (retain, nonatomic) NSString* type;
@property (retain, nonatomic) NSString* sumMd5;
@property NSInteger fileSize;
@end
@implementation WizUploadObject
@synthesize fileHandle;
@synthesize guid;
@synthesize type;
@synthesize sumMd5;
@synthesize fileSize;
- (void) dealloc
{
    [self.fileHandle closeFile];
    [self.fileHandle release];
    self.fileHandle = nil;
    [self.guid release];
    self.guid = nil;
    [self.type release];
    self.type = nil;
    [super dealloc];
}
- (void) uploadNextPart
{
    NSInteger currentOffSet = [self.fileHandle offsetInFile];
    NSInteger sumCount = self.fileSize/UploadPartSize;
    if (self.fileSize%UploadPartSize >0) {
        sumCount++;
    }
    NSInteger currentPartCount =currentOffSet/UploadPartSize;
    NSData* data = [self.fileHandle readDataOfLength:UploadPartSize];
    [self callUploadObjectData:self.guid objectType:self.type data:data objectSize:self.fileSize count:currentPartCount sumMD5:self.sumMd5 sumPartCount:sumCount];
}
- (void) uploadObject
{
    NSString* uploadFilePath = [WizFileManager zipFileForUploadObject:self.guid];
    self.fileHandle = [NSFileHandle fileHandleForReadingAtPath:uploadFilePath];
    [self.fileHandle seekToFileOffset:0];
    self.fileSize = [[WizFileManager defaultManager] fileLengthAtPath:uploadFilePath];
    self.sumMd5 = [WizGlobals fileMD5:uploadFilePath];
    [self uploadNextPart];
}
- (void) setOffSetToPreviousPart
{
    NSInteger currentOffSet = [self.fileHandle offsetInFile];
    NSInteger sumCount = self.fileSize/UploadPartSize;
    if (self.fileSize%UploadPartSize >0) {
        sumCount++;
    }
    NSInteger currentPartCount =currentOffSet/UploadPartSize;
    if (self.fileSize/UploadPartSize >0) {
        if (sumCount >1 || currentPartCount >0) {
            [self.fileHandle seekToFileOffset:(currentPartCount-1)*UploadPartSize];
        }
        else {
            [self.fileHandle seekToFileOffset:0];
        }
    }
    else {
        [self.fileHandle seekToFileOffset:currentPartCount*UploadPartSize];
    }
    
}
- (void) reUploadCurrentPart
{
    [self setOffSetToPreviousPart];
    [self uploadNextPart];
}
- (void) onUploadObject:(id)retObject
{
    NSMutableDictionary* obj = (NSMutableDictionary*)retObject;
    BOOL succeed = ([[obj valueForKey:@"return_code"] isEqualToString:@"200"])? YES:NO;
    if (!succeed) {
        [self reUploadCurrentPart];
    }
    else {
        <#statements#>
    }
}
@end
