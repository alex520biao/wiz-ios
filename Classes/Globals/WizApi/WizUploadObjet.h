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
- (BOOL) uploadWizObject:(WizObject*)wizobject;
- (BOOL) isUploadWizObject:(WizObject*)object;
- (void) stopUpload;
@end
