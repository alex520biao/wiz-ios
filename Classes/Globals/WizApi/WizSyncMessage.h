//
//  WizSyncMessage.h
//  Wiz
//
//  Created by 朝 董 on 12-5-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum WizSyncMessageCode {
    WizSyncUploadObjectCode = 2000,
    WizSyncDownloadObjectCode = 2001
    };

@interface WizSyncMessage : NSError

@end
