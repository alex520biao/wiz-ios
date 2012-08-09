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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
- (void) showFontTools:(NSNotification*)nc
{
    CGRect kbRect = [[[nc userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSLog(@"hight is %f",kbRect.size.height);
    fontToolBar.frame = CGRectMake(0.0,self.view.frame.size.height-kbRect.size.height-44, kbRect.size.width, 44);
}

- (void) hideFontTools:(NSNotification*)nc
{
    fontToolBar.frame = CGRectMake(-120, -120, 0, 0);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showFontTools:) name:UIKeyboardDidShowNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideFontTools:) name:UIKeyboardWillHideNotification object:nil];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //
    fontToolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:fontToolBar];
   
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
