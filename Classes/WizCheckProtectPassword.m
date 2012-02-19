//
//  WizCheckProtectPassword.m
//  Wiz
//
//  Created by wiz on 12-2-19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizCheckProtectPassword.h"

@implementation WizCheckProtectPassword
@synthesize number1,number2,number3,number4;
- (void) dealloc
{
    self.number4 = nil;
    self.number3 = nil;
    self.number2 = nil;
    self.number1 = nil;
    [super dealloc];
}
- (UITextField*) textView
{
    UITextField* n1 = [[UITextField alloc] init];
    n1.keyboardAppearance = UIKeyboardAppearanceAlert;
    n1.keyboardType = UIKeyboardTypeNumberPad;
    n1.delegate = self;
    n1.backgroundColor = [UIColor lightGrayColor];
    n1.font = [UIFont systemFontOfSize:25];
    n1.textAlignment = UITextAlignmentCenter;
    n1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    n1.inputDelegate = self;
    return [n1 autorelease];
}
-  (id) init
{
    self = [super init];
    if (self) {
        self.number1 = [self textView];
        self.number2 = [self textView];
        self.number3 = [self textView];
        self.number4 = [self textView];
        
        self.number1.frame = CGRectMake(32, 20, 40, 40);
        self.number2.frame = CGRectMake(104, 20, 40, 40);
        self.number3.frame = CGRectMake(176, 20, 40, 40);
        self.number4.frame = CGRectMake(248, 20, 40, 40);
        
        [self.view addSubview:number1];
        [self.view addSubview:number2];
        [self.view addSubview:number3];
        [self.view addSubview:number4];
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"%@",textField.text);
    if (textField == number1) {
        [number2 becomeFirstResponder];
    }
    else if (textField == number2)
    {
        [number3 becomeFirstResponder];
    }
    else if (textField == number3)
    {
        [number4 becomeFirstResponder];
    }

    return YES;
}

//- (void) textViewDidChange:(UITextView *)textView
//{
//    }
//}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.number1 becomeFirstResponder];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
