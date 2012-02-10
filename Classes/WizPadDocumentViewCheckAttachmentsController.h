//
//  WizPadDocumentViewCheckAttachmentsController.h
//  Wiz
//
//  Created by wiz on 12-2-8.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WizPadDocumentViewCheckAttachmentsController : UITableViewController
{
    NSString* accountUserId;
    NSMutableArray* attachments;
    NSString* documentGUID;
}
@property (nonatomic, retain) NSString* accountUserId;
@property (nonatomic, retain) NSMutableArray* attachments;
@property (nonatomic, retain) NSString* documentGUID;
@end
