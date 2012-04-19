//
//  WizSyncManager.h
//  Wiz
//
//  Created by 朝 董 on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WizSyncManager : NSObject
{
    NSString* accountUserId;
    NSString* accountPassword;
}
@property (nonatomic, retain) NSString* accountUserId;
@property (nonatomic, retain) NSString* accountPassword;
- (BOOL) uploadNext:(NSNotification*)nc;
- (BOOL) uploadDocument:(NSString*)documentGUID;
- (BOOL) uploadAttachment:(NSString*)attachmentGUID;
- (void) downloadAttachment:(NSString*)attachmentGUID;
- (void) downloadDocument:(NSString*)documentGUID;
- (BOOL) startSyncInfo;
+ (id) shareManager;
@end
