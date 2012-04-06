//
//  WizDownloadObject.h
//  WizLib
//
//  Created by 朝 董 on 12-4-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizApi.h"

@interface WizDownloadObject : WizApi
- (void) downloadDocument:(NSString*)documentGUID;
- (void) downloadAttachment:(NSString*)attachmentGUID;
@end
