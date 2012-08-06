//
//  WizPadCheckAttachments.h
//  Wiz
//
//  Created by wiz on 12-2-7.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WizPadCheckAttachmentsDelegate <NSObject>
- (void) didRemoveAttachmentsDone;
@end

@interface WizPadCheckAttachments : UITableViewController
{
    NSMutableArray* source;
    id<WizPadCheckAttachmentsDelegate>  delegate;
}
@property (nonatomic, retain) NSMutableArray* source;
@property (nonatomic, assign) id<WizPadCheckAttachmentsDelegate>  delegate;
@end
