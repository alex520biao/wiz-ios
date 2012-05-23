//
//  WizPadTabbarViewController.m
//  Wiz
//
//  Created by 朝 董 on 12-5-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizPadTabbarViewController.h"

@interface WizPadTabbarViewController ()
{
    NSArray* viewControllers;
    NSInteger* seletedItemIndex;
}
@property (nonatomic, retain) NSArray* viewControllers;
@end

@implementation WizPadTabbarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        seletedItemIndex = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
