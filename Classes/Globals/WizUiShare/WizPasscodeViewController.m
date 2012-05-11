//
//  WizPasscodeViewController.m
//  Wiz
//
//  Created by 朝 董 on 12-5-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "WizPasscodeViewController.h"
#import "WizSettings.h"

@interface WizPasscodeViewController ()
{
    UITextField* passcodeInputField;
    NSArray* codeViewArray;
    NSString* passcode;
    NSInteger checkCount;
    UILabel* remindLabel;
}
@property (nonatomic, retain) NSString* passcode;
@end

@implementation WizPasscodeViewController
@synthesize checkType;
@synthesize passcode;
- (void) dealloc
{
    [passcode release];
    passcode = nil;
    [codeViewArray release];
    codeViewArray = nil;
    [remindLabel release];
    remindLabel = nil;
    [super dealloc];
}
- (void) buildPasscodeView
{
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:4];
    for (int i = 0 ; i < 4; i ++) {
        UIImageView* view = [[UIImageView alloc] init];
        view.frame = CGRectMake(15+80*i, 80, 50, 50);
        [self.view addSubview:view];
        view.image = [UIImage imageNamed:@"box_empty"];
        [array addObject:view];
        [view release];
    }
    codeViewArray =array;
    [codeViewArray retain];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UITextField* text = [[UITextField alloc] initWithFrame:CGRectZero];
        text.keyboardType = UIKeyboardTypeNumberPad;
        text.delegate = self;
        passcodeInputField = text;
        [self.view addSubview:text];
        [text release];
        
        UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dialog_title1"]];
        imageView.frame = CGRectMake(0.0, 0.0, 320, 40);
        [self.view addSubview:imageView];
        [imageView release];
        
        remindLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 150, 320, 40)];
        remindLabel.textAlignment = UITextAlignmentCenter;
        remindLabel.textColor = [UIColor grayColor];
        [remindLabel setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:remindLabel];
        
        [self buildPasscodeView];
    }
    return self;
}
- (void) fillCodeViewNext
{
    UIImageView* view = [codeViewArray objectAtIndex:passcodeInputField.text.length];
    view.image = [UIImage imageNamed:@"box_filled"];
}

- (void) unfillCodeViewNext
{
    UIImageView* view = [codeViewArray objectAtIndex:passcodeInputField.text.length -1];
    view.image = [UIImage imageNamed:@"box_empty"];
}

- (void) unFillAllCodeView
{
    for (UIImageView* each in codeViewArray) {
        each.image = [UIImage imageNamed:@"box_empty"];
    }
}
- (void) initCheckCout
{
    if (WizCheckPasscodeTypeOfNew == self.checkType ) {
        checkCount = 1;
    }
    else {
        checkCount = 0;
    }
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initCheckCout];
    [passcodeInputField becomeFirstResponder];
}
- (void) checkAgain
{
    self.passcode = nil;
    [self initCheckCout];
    remindLabel.text = NSLocalizedString(@"Passcodes did not match. Try agsin.", nil);
}
- (void) didGetUserInput:(NSString*)code
{
    WizSettings* set = [WizSettings defaultSettings];
    if (code.length!= 4) {
        [self checkAgain];
        return;
    }
    if ( WizCheckPasscodeTypeOfNew ==self.checkType ) {
        NSLog(@"code is %@",code);
        [set setPasscode:code];
        [set setPasscodeEnable:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else 
    {
        NSString* oldPasscode = [[WizSettings defaultSettings] passCode];
        NSLog(@"old is %@",oldPasscode);
        if ([code isEqualToString:oldPasscode]) {
            if (WizCheckPasscodeTypeOfClear == self.checkType) {
                [set setPasscode:@""];
                [set setPasscodeEnable:NO];
                [self.navigationController popViewControllerAnimated:YES];
            }
            else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        else {
            [self checkAgain];
        }
    }
}
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.length == 0) {
        [self fillCodeViewNext];
        if (textField.text.length == 3) {
            NSString* final = [textField.text stringByAppendingString:string];
            passcodeInputField.text = @"";
            [self unFillAllCodeView];
            if (checkCount) {
                self.passcode = final;
                checkCount--;
                remindLabel.text = NSLocalizedString(@"Re-enter your passcode", nil);
            }
            else {
                if (nil != self.passcode) {
                    if (![self.passcode isEqualToString:final]) {
                        [self checkAgain];
                        return NO;
                    }
                }
                NSLog(@"final %@",final);
                remindLabel.text = @"";
                [self didGetUserInput:final];
            }
            return NO;
        }
    }
    else if (1 == range.length)
    {
        [self unfillCodeViewNext];
    }
    return YES;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"passcode is %@",[[WizSettings defaultSettings] passCode]);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
