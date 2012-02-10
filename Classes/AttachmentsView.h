//
//  AttachmentsView.h
//  Wiz
//
//  Created by dong zhao on 11-11-18.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AttachmentsView : UITableViewController {
    NSMutableArray* attachmentsAraay;
    NSString* accoutUserId;
    NSString* docGuid;
    NSIndexPath* lastIndexPath;
    BOOL isPlayingAudio;
    UIAlertView* waitAlertView;
}
@property (nonatomic, retain)     NSMutableArray* attachmentsAraay;
@property (nonatomic, retain)     NSString*       accountUserId;
@property (nonatomic, retain)     NSString*       docGuid;
@property (nonatomic, retain)   NSIndexPath* lastIndexPath;
@property (nonatomic, retain) UIAlertView* waitAlertView;
@property (assign) BOOL isPlayingAudio;
-(void) audioPlayStop;

@end
