//
//  AttachmentImageViewController.h
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AttachmentImageViewController : UIViewController
{
    UIWebView* web;
    NSURL* url;
}
@property (nonatomic, retain) IBOutlet UIWebView* web; 
@property (nonatomic, retain) NSURL* url;

@end
