//
//  WizSyncBase.m
//  WizLib
//
//  Created by 朝 董 on 12-4-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizSyncBase.h"
#import "WizDbManager.h"
#import "WizFileManager.h"
#import "WizDocument.h"

@implementation WizSyncBase
- (BOOL) startSync
{
    return [self callDownloadDocumentList];
}
- (void) onDownloadDocumentList:(id)retObject
{
    NSArray* obj = nil;
    if ([retObject isKindOfClass:[NSArray class]]) {
        obj = retObject;
    }
    else {
        [self onError:retObject];
    }
    
	[[WizDbManager shareDbManager] updateDocuments:obj];
    int64_t newVer = [[WizDbManager shareDbManager] documentVersion];
    int64_t oldVer = [[WizDbManager shareDbManager] documentVersion];
    for (NSDictionary* dict in obj)
    {
        NSString* verString = [dict valueForKey:@"version"];
        
        int64_t ver = [verString longLongValue];
        if (ver > newVer)
        {
            newVer = ver;
        }
    }
    //
    if(oldVer != newVer)
    {
        [[WizDbManager shareDbManager] setDocumentVersion:newVer + 1];
        [self callDownloadDocumentList];
    }
    else {
        NSArray* recentDocument = [[WizDbManager shareDbManager] recentDocuments];
        for (WizDocument* each in recentDocument) {
            [[WizSyncManager shareManager] downloadDocument:each.guid];
        }
        
    }
}
@end
