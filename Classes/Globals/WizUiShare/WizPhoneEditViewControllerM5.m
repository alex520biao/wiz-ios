//
//  WizPhoneEditViewController.m
//  Wiz
//
//  Created by wiz on 12-7-2.
//
//

#import "WizPhoneEditViewControllerM5.h"
#import "UIBarButtonItem+WizTools.h"
#import "WizFileManager.h"

@interface WizPhoneEditViewControllerM5 ()
{
    
}
@end

@implementation WizPhoneEditViewControllerM5

- (void) dealloc
{
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //
   
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