//
//  WizDownloadObject.h
//  Wiz
//
//  Created by dong zhao on 11-10-31.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizApi.h"
#import "WizSyncObjectSourceDelegate.h"


@interface WizDownloadObject : WizApi
{
    id<WizSyncObjectSourceDelegate> sourceDelegate;
}
@property (atomic, assign) id<WizSyncObjectSourceDelegate> sourceDelegate;
- (NSString*)currentDownloadObjectGuid;
- (BOOL) isDownloadWizObject:(WizObject*)wizObject;
- (void) stopDownload;
- (BOOL) startDownload;
@end
