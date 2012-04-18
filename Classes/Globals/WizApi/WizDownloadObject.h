//
//  WizDownloadObject.h
//  Wiz
//
//  Created by dong zhao on 11-10-31.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizApi.h"

extern NSString* SyncMethod_DownloadProcessPartBeginWithGuid ;
extern NSString* SyncMethod_DownloadProcessPartEndWithGuid   ;

@interface WizDownloadObject : WizApi {
    BOOL busy;
}
@property (readonly) BOOL busy;
- (void) downloadDocument:(NSString*)documentGUID;
- (void) downloadAttachment:(NSString*)attachmentGUID;
@end
