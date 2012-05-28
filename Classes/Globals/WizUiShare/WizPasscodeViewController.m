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
    
    UIImageView* dilogTileImageView;
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
    
    [dilogTileImageView release];
    dilogTileImageView = nil;
    
    [super dealloc];
}
- (void) makeViewFrameFit
{
    CGFloat codeViewWidth = 0;
    CGFloat startY=60;

    
    if ([WizGlobals WizDeviceIsPad] && WizcheckPasscodeTypeOfCheck == self.checkType) {
        codeViewWidth = 100;
        dilogTileImageView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.width/320*40);
        
        startY = self.view.frame.size.width/320*40 + 30;
    }
    else
    {
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            dilogTileImageView.frame = CGRectMake(0.0, 0.0,0.0,0.0);
            startY = 10;
        }
        else {
            startY  = 80;
            dilogTileImageView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.width/320*40);
        }
        codeViewWidth = 60;
    }
    CGFloat startX = (self.view.frame.size.width -4*codeViewWidth)/5;
    for (int i = 0; i < [codeViewArray count]; i++) {
        UIView* each = [codeViewArray objectAtIndex:i];
        each.frame = CGRectMake(startX + (codeViewWidth + startX)*i, startY, codeViewWidth, codeViewWidth);
    }
    remindLabel.frame = CGRectMake(0.0, startY + codeViewWidth+10, self.view.frame.size.width, 20);
}
- (void) buildPasscodeView
{
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:4];
    for (int i = 0 ; i < 4; i ++) {
        UIImageView* view = [[UIImageView alloc] init];
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
        
        dilogTileImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dialog_title1"]];
        dilogTileImageView.frame = CGRectMake(0.0, 0.0, 320, 40);
        [self.view addSubview:dilogTileImageView];
        
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
    [self makeViewFrameFit];
    self.view.backgroundColor = [UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:1.0];
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
    
    switch (self.checkType) {
        case WizCheckPasscodeTypeOfNew:
            [set setPasscode:code];
            [set setPasscodeEnable:YES];
            [self.navigationController popViewControllerAnimated:YES];
            break;
            
        case WizCheckPasscodeTypeOfClear:
            if ([code isEqualToString:[set passCode]]) {
                [set setPasscode:@""];
                [set setPasscodeEnable:NO];
                [self.navigationController popViewControllerAnimated:YES];
            }
            else {
                [self checkAgain];
            }
            break;
        case WizcheckPasscodeTypeOfCheck:
            if ([code isEqualToString:[set passCode]]) {
                [self.navigationController dismissModalViewControllerAnimated:YES];
            }
            else {
                [self checkAgain];
            }
            break;
            
        default:
            [self.navigationController popViewControllerAnimated:YES];
            break;
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

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self makeViewFrameFit];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
