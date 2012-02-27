//
//  WizCheckAttachments.h
//  Wiz
//
//  Created by wiz on 12-2-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WizCheckAttachments : UITableViewController <UIAlertViewDelegate>
{
    NSString* accountUserId;
    NSMutableArray* attachments;
    NSString* documentGUID;
    UIAlertView* waitAlert;
}
@property (nonatomic, retain) NSString* accountUserId;
@property (nonatomic, retain) NSMutableArray* attachments;
@property (nonatomic, retain) NSString* documentGUID;
@property (nonatomic, retain) UIAlertView* waitAlert;
- (void) downloadDone:(NSNotification*)nc;
@end
