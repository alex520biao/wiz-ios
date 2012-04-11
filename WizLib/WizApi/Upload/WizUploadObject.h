//
//  WizUploadObject.h
//  WizLib
//
//  Created by 朝 董 on 12-4-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizApi.h"

@interface WizUploadObject : WizApi
- (BOOL) uploadDocument:(NSString*)Guid;
- (BOOL) uploadAttachment:(NSString*)Guid;
@end
