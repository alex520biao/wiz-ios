//
//  UIBarButtonItem+WizTools.m
//  Wiz
//
//  Created by wiz on 12-7-3.
//
//

#import "UIBarButtonItem+WizTools.h"

@implementation UIBarButtonItem (WizTools)
+ (UIBarButtonItem*) barButtonItem:(UIImage*)image   hightImage:(UIImage*)hightImage  target:(id)target   action:(SEL)action
{
    
    UITapGestureRecognizer* singleRecognizer;
    singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    singleRecognizer.numberOfTapsRequired = 1; // 单击
    //
    UIImageView* buttonView = [[UIImageView alloc] initWithImage:image highlightedImage:hightImage];
    buttonView.userInteractionEnabled = YES;
    [buttonView addGestureRecognizer:singleRecognizer];
    [singleRecognizer release];
    //
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
    [buttonView release];
    return [item autorelease];
}
@end
