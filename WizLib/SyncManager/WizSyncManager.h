//
//  WizSyncManager.h
//  WizLib
//
//  Created by 朝 董 on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#define TypeOfCommonParamToken @"token"
#define TypeOfCommonParamKbGUID @"kb_guid"
#define TypeOfCommonParamApiUrl @"kapi_url"

@interface WizSyncManager : NSObject
- (NSString*) kbGuid;
- (NSString*) token;
- (NSURL*) apiUrl;
- (void) refreshLogInfo;
+ (id) shareManager;
- (BOOL) startSyncAccountInfo;
- (void) downloadDocument:(NSString*)guid;
- (void) downloadAttachment:(NSString*)guid;
- (void) uploadDocument:(NSString*)guid;
- (void) upAttachment:(NSString*)guid;
@end
