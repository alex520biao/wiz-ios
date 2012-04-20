//
//  WizAddAcountViewController.m
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-27.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "WizAddAcountViewController.h"
#import "WizInputView.h"
#import "WizGlobalData.h"
#import "WizVerifyAccount.h"
#import "WizIndex.h"
#import "WizAccountManager.h"
#import "WizNotification.h"




@interface WizAddAcountViewController()
{
        UIButton* accountButton;
}
@property (nonatomic, retain)    UIButton* accountButton;
- (void)showAllAccounts:(id)sender;
@end

@implementation WizAddAcountViewController
@synthesize nameInput;
@synthesize passwordInput;
@synthesize waitAlertView;
@synthesize existAccountsTable;
@synthesize fitAccounts;
@synthesize accountButton;
- (void) dealloc
{
    [nameInput release];
    [waitAlertView release];
    [passwordInput release];
    [accountButton release];
    [existAccountsTable release];
    [fitAccounts release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UITableView* table = [[UITableView alloc] initWithFrame:CGRectMake(60, 80, 200, 60) style:UITableViewStyleGrouped];
        self.existAccountsTable = table;
        table.delegate = self;
        table.dataSource = self;
        CALayer* layer = [table.backgroundView layer];
        layer.borderColor = [UIColor whiteColor].CGColor;
        layer.borderWidth = 0.5f;
        layer.shadowColor = [UIColor grayColor].CGColor;
        layer.shadowOffset = CGSizeMake(5, 5);
        layer.shadowOpacity = 0.5;
        layer.shadowRadius = 6;
        table.backgroundView = nil;
        table.backgroundColor = [UIColor clearColor];
        [table release];
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) cancel
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}
- (void) xmlrpcDone: (NSNotification*)nc
{

}
- (void) didVerifyAccountFaild
{
    if (self.waitAlertView)
	{
		[self.waitAlertView dismissWithClickedButtonIndex:0 animated:YES];
		self.waitAlertView = nil;
	}
}
- (void) didVerifyAccountSucceed
{
    if (self.waitAlertView)
	{
		[self.waitAlertView dismissWithClickedButtonIndex:0 animated:YES];
		self.waitAlertView = nil;
	}
	//

	NSString* accountIDString = nameInput.textInputField.text;
    NSString* accountPasswordString = passwordInput.textInputField.text;
    [[WizAccountManager defaultManager] addAccount:accountIDString password:accountPasswordString];
    [self.navigationController dismissModalViewControllerAnimated:NO];
    [WizNotificationCenter postPadSelectedAccountMessge:accountIDString];
}

- (void) login
{
    [self.nameInput.textInputField resignFirstResponder];
    [self.passwordInput.textInputField resignFirstResponder];
    NSString* error = WizStrError;
    NSString* accountIDString = nameInput.textInputField.text;
    NSString* accountPasswordString = passwordInput.textInputField.text;
    
	if (accountIDString == nil|| [accountIDString length] == 0)
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error message:WizStrPleaseenteuserid delegate:self cancelButtonTitle:WizStrOK otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	if (accountPasswordString == nil || [accountPasswordString length] == 0)
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error message:WizStrPleaseenterpassword delegate:self cancelButtonTitle:WizStrOK otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
    //
    UIAlertView* alert = nil;
    [WizGlobals showAlertView:WizStrSignIn message:WizStrPleasewaitwhileloggingin delegate:self retView:&alert];
	[alert show];
	self.waitAlertView = alert;
	[alert release];
	WizVerifyAccount* api = [[WizGlobalData sharedData] verifyAccountData: accountIDString];
    api.verifyDelegate = self;

    api.accountUserId = accountIDString;
    api.accountPassword = accountPasswordString;
	[api verifyAccount];
}
- (void) setExistAccountsTableViewFrame
{
    CGFloat height = 35*[self.fitAccounts count];
    if (WizDeviceIsPad()) {
        self.existAccountsTable.frame= CGRectMake(175, 70, 245, height+20);
    }
    else {
        self.existAccountsTable.frame = CGRectMake(75, 50, 245, height+20);
    }
}
- (void) removeTable
{
    [self.existAccountsTable removeFromSuperview];
    if (self.accountButton != nil) {
        [self.accountButton removeTarget:self action:@selector(removeTable) forControlEvents:UIControlEventTouchUpInside];
        [self.accountButton addTarget:self action:@selector(showAllAccounts:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void) showExistAccounts:(NSArray*)array
{
    self.fitAccounts = [NSMutableArray arrayWithArray:array];
    [self setExistAccountsTableViewFrame];
    [self.view addSubview:self.existAccountsTable];
    [self.existAccountsTable reloadData];
    
    if (self.accountButton != nil) {
        [self.accountButton removeTarget:self action:@selector(showAllAccounts:) forControlEvents:UIControlEventTouchUpInside];
        [self.accountButton addTarget:self action:@selector(removeTable) forControlEvents:UIControlEventTouchUpInside];
    }
}
- (void)showAllAccounts:(id)sender
{
    [self showExistAccounts:[[WizAccountManager defaultManager] accounts]];
}
- (void) viewDidLoad
{
    [super viewDidLoad];
    UIView* backView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1024, 768)];
    backView.backgroundColor = [UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:1.0];
    [self.view addSubview:backView];
    WizInputView* nameInput_ = [[WizInputView alloc] initWithFrame:CGRectMake(100, 40, 320, 40)];
    [self.view addSubview:nameInput_];
    [nameInput_ release];
    self.nameInput = nameInput_;
    nameInput.nameLable.text = WizStrUserId;
    nameInput.textInputField.placeholder = @"exmaple@email.com";
    nameInput.textInputField.keyboardType = UIKeyboardTypeEmailAddress;
    nameInput.textInputField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    nameInput.textInputField.delegate = self;
    UITapGestureRecognizer* ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeTable)];
    ges.numberOfTapsRequired = 1;
    UIView* titleView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 250, 44)];
    if (WizDeviceIsPad()) {
        titleView.frame = CGRectMake(0.0, 0.0, 400, 44);
    }
    [titleView addGestureRecognizer:ges];
    [backView addGestureRecognizer:ges];
    self.navigationItem.titleView = titleView;
    [titleView release];
    [ges release];
    [backView release];
    
    if ([[[WizAccountManager defaultManager] accounts] count]) {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"userIcons"] forState:UIControlStateNormal];
        nameInput.textInputField.rightView = button;
        button.frame = CGRectMake(0.0, 0.0, 35, 35);
        nameInput.textInputField.rightViewMode = UITextFieldViewModeAlways;
        [button addTarget:self action:@selector(showAllAccounts:) forControlEvents:UIControlEventTouchUpInside];
        self.accountButton = button;
    }
    WizInputView* passwordInput_ = [[WizInputView alloc] initWithFrame:CGRectMake(100, 120, 320, 40)];
     [self.view addSubview:passwordInput_];
    [passwordInput_ release];
    self.passwordInput = passwordInput_;
    passwordInput.nameLable.text = WizStrPassword;
    passwordInput.textInputField.placeholder = @"password";
    passwordInput.textInputField.secureTextEntry = YES;
    passwordInput.textInputField.delegate = self;
    UIButton* loginButton_ = [[UIButton alloc] initWithFrame:CGRectMake(110, 200, 300, 40)];
    [loginButton_ setBackgroundImage:[UIImage imageNamed:@"loginButtonBackgroud"] forState:UIControlStateNormal];
    [loginButton_ setTitle:WizStrSignIn forState:UIControlStateNormal];
    [loginButton_ addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton_];
    if (WizDeviceIsPad()) {
        UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:WizStrCancel 
                                                                         style:UIBarButtonItemStyleDone
                                                                        target:self 
                                                                        action:@selector(cancel)];
        self.navigationItem.leftBarButtonItem = cancelButton;
        [cancelButton release];
    }
    else {
        self.nameInput.frame = CGRectMake(0, 20, 310, 40);
        self.passwordInput.frame= CGRectMake(0, 80, 310, 40);
        loginButton_.frame = CGRectMake(10, 140, 300, 40);
    }
    [loginButton_ release];
    
}
- (void)viewDidUnload
{
    [super viewDidUnload];
   
    
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.nameInput.textInputField becomeFirstResponder];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (WizDeviceIsPad()) {
        return YES;
    }
    else {
        return NO;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.fitAccounts count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
         cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        
    }
    NSString* userId = [self.fitAccounts objectAtIndex:indexPath.row];
    cell.textLabel.text = userId;
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    cell.imageView.image = [UIImage imageNamed:@"userIcon"];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35;
}
- (void) textFieldDidEndEditing:(UITextField *)textField
{
    [self.existAccountsTable removeFromSuperview];
}
- (void) reloadAccountsTable:(NSString*)match
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"SELF like %@",match];
    NSArray* nameIn = [[[WizAccountManager defaultManager] accounts] filteredArrayUsingPredicate:predicate];
    self.fitAccounts = [NSMutableArray arrayWithArray:nameIn];
    if ([fitAccounts count] > 1) {
        [self setExistAccountsTableViewFrame];
        [self.view addSubview:self.existAccountsTable];
        [self showExistAccounts:fitAccounts];
    } else if ([fitAccounts count] == 1)
    {
        NSString* string = [fitAccounts lastObject];
        if (string.length >1) {
            if ([string isEqualToString:[match substringToIndex:match.length-1]]) {
                [self removeTable];
            }
            else {
                [self setExistAccountsTableViewFrame];
                [self.view addSubview:self.existAccountsTable];
                [self showExistAccounts:fitAccounts];
            }
        }

    }
    else {
        [self removeTable];
    }
}
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isEqual:self.passwordInput.textInputField]) {
        [self removeTable];
        return YES;
    }
    NSString* willDisplayStr = nil;
    if (range.length > 0) {
        willDisplayStr = [NSString stringWithFormat:@"%@",[textField.text substringToIndex:range.location]];
    }
    else {
        willDisplayStr = [NSString stringWithFormat:@"%@%@",textField.text,string];
    }
    if (willDisplayStr == nil || [willDisplayStr isEqualToString:@""]) {
        [self.existAccountsTable removeFromSuperview];
        return YES;
    }
    NSString* match = [NSString stringWithFormat:@"%@*",willDisplayStr];
    [self reloadAccountsTable:match];
   return YES;
}
- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.passwordInput.textInputField]) {
        [self removeTable];
    }
    else if ([textField isEqual:self.nameInput.textInputField])
    {
        if (textField.text == nil || [textField.text isEqualToString:@""]) {
            [self removeTable];
            return;
        }
        NSString* match = [NSString stringWithFormat:@"%@*",textField.text];
        [self reloadAccountsTable:match];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* accountUserId = [self.fitAccounts objectAtIndex:indexPath.row];
    self.nameInput.textInputField.text = accountUserId;
    [self.nameInput.textInputField resignFirstResponder];
    [self.passwordInput.textInputField becomeFirstResponder];
    [self removeTable];
}
@end
