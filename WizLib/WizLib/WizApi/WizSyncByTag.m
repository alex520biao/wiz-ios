//
//  WizSyncByTag.m
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizSyncByTag.h"
#import "WizIndex.h"
#import "WizGlobalData.h"
@implementation WizSyncByTag
@synthesize tag;
- (void) dealloc
{
    self.tag = nil;
    [super dealloc];
}
//- (NSString*)notificationName:(NSString *)prefix
//{
//    NSString* ret = [NSString stringWithFormat:@"%@_%@",@"syncByTag",[super notificationName:prefix]];
//    return ret;
//}
- (void) prepareSyncArray
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    NSArray* docArray = [index documentsByTag:self.tag];
    if (nil == self.uploadArray) {
        self.uploadArray = [NSMutableArray array];
    }
    else
    {
        [self.uploadArray removeAllObjects];
    }
    if (nil == self.downloadArray) {
        self.downloadArray = [NSMutableArray array];
    }
    else
    {
        [self.downloadArray removeAllObjects];
    }
    if (nil == self.uploadAttachArray) {
        self.uploadAttachArray = [NSMutableArray array];
    }
    else
    {
        [self.uploadAttachArray removeAllObjects];
    }
    for (WizDocument* each in docArray) {
        if (each.serverChanged) {
            [self.downloadArray addObject:each];
        }
        else if (each.localChanged)
        {
            [self.uploadArray addObject:each];
            NSArray* attachArray = [index attachmentsByDocumentGUID:each.guid];
            for (WizDocumentAttach* eachAttach in attachArray) {
                if (eachAttach.localChanged) {
                    [self.uploadAttachArray addObject:eachAttach];
                }
            }
        }
    }
}

- (void) onDocumentsByTag:(id)retObject
{
    [super onDocumentsByTag:retObject];
    [self uploadAllObject];
}

- (BOOL) callSyncMethod
{
    return [self callDocumentsByTag:self.tag];
}

@end
