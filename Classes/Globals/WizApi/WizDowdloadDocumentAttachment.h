//
//  WizDowdloadDocumentAttachment.h
//  Wiz
//
//  Created by dong zhao on 11-10-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizApi.h"

@interface WizDowdloadDocumentAttachment : WizApi {
    NSString* attachGuid;
    NSString* documentGuid;

    BOOL busy;
}
@property (nonatomic, retain) NSString* attachGuid;
@property (nonatomic, retain) NSString* documentGuid;

@property (readonly) BOOL busy;


@end
