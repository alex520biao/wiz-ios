//
//  DocumentInfoViewController.h
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WizDocument;
@interface DocumentInfoViewController : UITableViewController
{
    WizDocument* doc;
    NSString* accountUserId;
    UISlider* fontSlider;
    
    
    NSMutableString* documentFloder;
    NSMutableString* documentTags;
    
    NSIndexPath* lastIndexPath;
}
@property (nonatomic, retain) WizDocument* doc;
@property (nonatomic, retain)    NSString* accountUserId;
@property (nonatomic, retain)  UISlider* fontSlider;

@property (nonatomic, retain) NSMutableString* documentFloder;
@property (nonatomic, retain) NSMutableString* documentTags;
@property (nonatomic, retain)    NSIndexPath* lastIndexPath;
@end
