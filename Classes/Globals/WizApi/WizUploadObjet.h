//
//  WizUploadObjet.h
//  Wiz
//
//  Created by dong zhao on 11-11-1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizSyncObjectSourceDelegate.h"
#import "WizApi.h"
@interface WizUploadObjet : WizApi
{
    id<WizSyncObjectSourceDelegate> sourceDelegate;
}
@property (assign) id<WizSyncObjectSourceDelegate> sourceDelegate;
- (BOOL) startUpload;
- (void) stopUpload;
- (BOOL) isUploadWizObject:(WizObject*)object;
@end
