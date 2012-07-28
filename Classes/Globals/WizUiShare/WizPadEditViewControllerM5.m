//
//  WizPadEditViewControllerM5.m
//  Wiz
//
//  Created by wiz on 12-7-19.
//
//

#import "WizPadEditViewControllerM5.h"

@interface WizPadEditViewControllerM5 ()

@end

@implementation WizPadEditViewControllerM5

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    fontToolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    fontToolBar.frame = CGRectMake(0.0, 0.0, backGroudScrollView.frame.size.width, 44);
    titleTextField.frame = CGRectMake(0.0, 44, backGroudScrollView.frame.size.width, 31);
    editorWebView.frame = CGRectMake(0.0, 44+31, backGroudScrollView.frame.size.width, self.view.frame.size.height-44-31);

    fontToolBar.tintColor = [UIColor lightGrayColor];
    fontToolBar.translucent = YES;
    [backGroudScrollView addSubview:fontToolBar];

	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
