//
//  WizUploadObjet.h
//  Wiz
//
//  Created by dong zhao on 11-11-1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizApi.h"
@class WizDocument;
@class WizDocumentAttach;
@interface WizUploadObjet : WizApi
{
    BOOL        busy;
    NSString* accountUserId;
}
@property       (readonly)           BOOL        busy;
@property (nonatomic, retain) NSString* accountUserId;
- (BOOL) uploadDocument:(WizDocument*)document;
- (BOOL) uploadAttachment:(WizDocumentAttach*)attachment;
@end
