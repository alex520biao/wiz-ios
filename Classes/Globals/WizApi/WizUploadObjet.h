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
-(BOOL) uploadObjectData;
@end
@interface WizUploadDocument : WizUploadObjet {
}
-(void) initWithObjectGUID:(NSURL*)apiUrl token:(NSString*)token_ kbguid:(NSString*)kbGuid  documentGUID:(NSString *)documentIGUID;
@end

@interface WizUploadAttachment : WizUploadObjet {
}
-(void) initWithObjectGUID:(NSURL*)apiUrl token:(NSString*)token_ kbguid:(NSString*)kbGuid attachmentGUID:(NSString *)attachmentIGUID;
@end