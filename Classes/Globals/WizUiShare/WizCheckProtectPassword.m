//
//  WizCheckProtectPassword.m
//  Wiz
//
//  Created by wiz on 12-2-19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "WizCheckProtectPassword.h"
#import "WizGlobalNotificationMessage.h"
#import "WizGlobals.h"
@implementation WizCheckProtectPassword
@synthesize number1,number2,number3,number4;
@synthesize willMakeSure;
@synthesize isMakeSure;
@synthesize finalPassword;
- (void) dealloc
{
    [finalPassword release];
    [number4 release];
    [number3 release];
    [number2 release];
    [number1 release];
    [super dealloc];
}
- (UITextView*) textView
{
    UITextView* n1 = [[UITextView alloc] init];
    n1.keyboardAppearance = UIKeyboardAppearanceAlert;
    n1.keyboardType = UIKeyboardTypeNumberPad;
    n1.delegate = self;
    n1.backgroundColor = [UIColor whiteColor];
    n1.font = [UIFont boldSystemFontOfSize:30];
    n1.secureTextEntry = YES;
    n1.textAlignment = UITextAlignmentCenter;
    CALayer* layer = n1.layer;
    layer.borderColor = [UIColor grayColor].CGColor;
    layer.borderWidth = 1.0f;
    layer.shadowColor = [UIColor grayColor].CGColor;
    layer.shadowOffset = CGSizeMake(1, 1);
    layer.shadowOpacity = 0.5;
    layer.shadowRadius = 0.5;
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
        UIImageView* logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dialog_title"]];
        float zoomWidth = 0;
        if (WizDeviceIsPad()) {
            zoomWidth = 110;
        }
        else
        {
            zoomWidth = 0;
        }
        logo.frame  = CGRectMake(0.0 + zoomWidth, 20, 320, 40);
        [self.view addSubview:logo];
        [logo release];
        self.number1.frame = CGRectMake(25+ zoomWidth, 110, 60, 60);
        self.number2.frame = CGRectMake(95+ zoomWidth, 110, 60, 60);
        self.number3.frame = CGRectMake(165+ zoomWidth, 110, 60, 60);
        self.number4.frame = CGRectMake(235+ zoomWidth, 110, 60, 60);
        
        
        number1.scrollEnabled = NO;
        number2.scrollEnabled = NO;
        number3.scrollEnabled = NO;
        number4.scrollEnabled = NO;
        [self.view addSubview:number1];
        [self.view addSubview:number2];
        [self.view addSubview:number3];
        [self.view addSubview:number4];
        self.isMakeSure = NO;
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
- (void)viewDidLoad
{
    [super viewDidLoad];
    

    if (self.finalPassword == nil) {
        self.finalPassword = @"";
    }
    self.view.backgroundColor = [UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:1.0];
    
}
- (void) viewDidUnload
{
    
}
- (void) makeSure:(NSNotification*)nc
{
    NSDictionary* userInfo = [nc userInfo];
    NSString* password = [userInfo valueForKey:TypeOfProtectPassword];
    if (![self.finalPassword isEqualToString:password]) {
        self.finalPassword = @"-1";
    }
}

- (void) textViewDidChange:(UITextView *)textView
{
    if (textView.text == nil || [textView.text isEqualToString:@""]) {
        return;
    }
    textView.editable = NO;
    self.finalPassword = [finalPassword stringByAppendingString:textView.text];
    textView.text = @"*";
    if (textView == number1) {

        [number2 becomeFirstResponder];
    }
    else if (textView == number2)
    {
        [number3 becomeFirstResponder];
    }
    else if (textView == number3)
    {
        [number4 becomeFirstResponder];
    }
    else if (textView == number4)
    {
        if (willMakeSure) {
            WizCheckProtectPassword* check = [[WizCheckProtectPassword alloc] init];
            check.willMakeSure = NO;
            check.title = WizStrConfirm;
            check.isMakeSure = YES;
            [self.navigationController pushViewController:check animated:YES];
            self.isMakeSure = YES;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeSure:) name:MessageOfCheckPasswordMakesure object:nil];
            [check release];
        }
        else
        {
            if (self.isMakeSure) {
                [[NSNotificationCenter defaultCenter] postNotificationName:MessageOfCheckPasswordMakesure object:nil userInfo:[NSDictionary dictionaryWithObject:finalPassword forKey:TypeOfProtectPassword]];
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                [self.navigationController dismissModalViewControllerAnimated:NO];
                [[NSNotificationCenter defaultCenter] postNotificationName:MessageOfProtectPasswordInputEnd object:nil userInfo:[NSDictionary dictionaryWithObject:finalPassword forKey:TypeOfProtectPassword]];
            }
        }
        
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.number1 becomeFirstResponder];
    if (!willMakeSure && !isMakeSure) {
        [self.navigationController setNavigationBarHidden:YES];
    }
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.willMakeSure && self.isMakeSure) {
        [self.navigationController dismissModalViewControllerAnimated:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:MessageOfProtectPasswordInputEnd object:nil userInfo:[NSDictionary dictionaryWithObject:finalPassword forKey:TypeOfProtectPassword]];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
