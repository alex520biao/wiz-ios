//
//  AboutViewController.h
//  Wiz
//
//  Created by Wei Shijun on 3/18/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AboutViewController : UIViewController {

	UIWebView* webView;
}

@property (nonatomic, retain) IBOutlet UIWebView* webView;

@end
