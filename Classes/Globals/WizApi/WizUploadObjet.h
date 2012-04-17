//
//  WizUploadObjet.h
//  Wiz
//
//  Created by dong zhao on 11-11-1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizApi.h"

@interface WizUploadObjet : WizApi
{
        BOOL        busy;
}
@property       (readonly)           BOOL        busy;
- (BOOL) uploadDocument:(NSString*)documentGUID;
- (BOOL) uploadAttachment:(NSString*)attachmentGUID;
@end
