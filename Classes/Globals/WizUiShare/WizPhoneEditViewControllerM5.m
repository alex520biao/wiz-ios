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
    UIImageView* hideKeyBoardBtn;
}
@end

@implementation WizPhoneEditViewControllerM5

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [hideKeyBoardBtn release];
    [super dealloc];
}
- (void) showFontTools:(NSNotification*)nc
{
    CGRect kbRect = [[[nc userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSLog(@"hight is %f",kbRect.size.height);
    fontToolBar.frame = CGRectMake(0.0,self.view.frame.size.height-kbRect.size.height-44, kbRect.size.width, 44);
    hideKeyBoardBtn.frame = CGRectMake(self.view.frame.size.width - 65, self.view.frame.size.height - kbRect.size.height - 44 - 35, 60, 30);
}

- (void) hideFontTools:(NSNotification*)nc
{
    fontToolBar.frame = CGRectMake(-120, -120, 0, 0);
    hideKeyBoardBtn.frame = CGRectMake(-120, -120, 0, 0);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showFontTools:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideFontTools:) name:UIKeyboardWillHideNotification object:nil];
        hideKeyBoardBtn = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"keyHidden"]];
        
        UITapGestureRecognizer* tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBord)] autorelease];
        tap.numberOfTapsRequired =1;
        tap.numberOfTouchesRequired =1;
        [hideKeyBoardBtn addGestureRecognizer:tap];
        hideKeyBoardBtn.userInteractionEnabled = YES;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //
    fontToolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:fontToolBar];
    hideKeyBoardBtn.frame = CGRectMake(-120, -120, 0, 0);
    [self.view addSubview:hideKeyBoardBtn];
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
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [editorWebView setHackishlyHidesInputAccessoryView:YES];
}
@end
