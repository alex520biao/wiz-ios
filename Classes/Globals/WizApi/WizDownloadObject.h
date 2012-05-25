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

@interface WizDownloadObject : WizApi 
- (BOOL) downloadWizObject:(WizObject*)wizObject;
- (NSString*)currentDownloadObjectGuid;
- (BOOL) isDownloadWizObject:(WizObject*)wizObject;
- (void) stopDownload;
@end
