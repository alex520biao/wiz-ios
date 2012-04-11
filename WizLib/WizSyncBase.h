//
//  WizSyncBase.h
//  WizLib
//
//  Created by 朝 董 on 12-4-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizApi.h"

@interface WizSyncBase : WizApi
- (BOOL) startSync;
- (void) onDownloadDocumentList:(id)retObject;
@end
