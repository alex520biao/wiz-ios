//
//  UserSttingsViewController.m
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-13.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "UserSttingsViewController.h"
#import "WizIndex.h"
#import "WizGlobals.h"
#import "WizGlobalData.h"
#import "WizSettings.h"
#import "CommonString.h"
#import "LoginViewController.h"
#import "PickViewController.h"
#import "WizPhoneNotificationMessage.h"
#import "WizPadNotificationMessage.h"
#define ChangePasswordTag 888

@implementation UserSttingsViewController
@synthesize accountUserId;

@synthesize mobileViewCell;
@synthesize mobileViewSwitch;
@synthesize mbileViewCellLabel;
@synthesize downloadDataDurationCell;
@synthesize downloadDataDurationCellNameLabel;
@synthesize waitAlertView;
@synthesize imageQualityLabel;
@synthesize imageQualityCell;
@synthesize protectCell;
@synthesize protectCellSwitch;
@synthesize protectCellNameLabel;
@synthesize oldPassword;
@synthesize defaultUserCell;
@synthesize defaultUserLabel;
@synthesize defaultUserSwitch;
@synthesize newAccountPassword;
@synthesize downloadDuration;
@synthesize imageQulity;
- (void) dealloc
{
    self.newAccountPassword = nil;
    self.accountUserId = nil;
    self.defaultUserCell = nil;
    self.defaultUserLabel = nil;
    self.defaultUserSwitch = nil;
    self.mobileViewCell = nil;
    self.mobileViewSwitch = nil;
    self.mbileViewCellLabel = nil;
    self.downloadDataDurationCell = nil;
    self.downloadDataDurationCellNameLabel = nil;
    self.waitAlertView = nil;
    self.imageQualityLabel = nil;
    self.imageQualityCell = nil;
    self.oldPassword = nil;
    [super dealloc];
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void) saveSettings
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    [index setDocumentMoblleView:self.mobileViewSwitch.on];
    if (self.downloadDuration) {
        [index setDownloadDocumentData:YES];
        [index setDurationForDownloadDocument:self.downloadDuration];
    }
    else
    {
        [index setDownloadDocumentData:NO];
    }
    if (self.newAccountPassword != nil && ![self.newAccountPassword isEqualToString:@""]) {
        [WizSettings changeAccountPassword:self.accountUserId password:self.newAccountPassword];
        [[WizGlobalData sharedData] removeAccountData:self.accountUserId];
    }
    if (self.defaultUserSwitch.on) {
        [WizSettings setDefalutAccount:self.accountUserId];
    }
    if (!self.protectCellSwitch.on) {
        [WizSettings setAccountProtectPassword:@""];
    }
    [index setImageQualityValue:self.imageQulity];
    if (!WizDeviceIsPad()) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:MessageOfPoperviewDismiss object:nil userInfo:nil];
    }

}

- (void) cancelSettings
{
    if (self.oldPassword != nil )
        [WizSettings setAccountProtectPassword:oldPassword];
    else
        [WizSettings setAccountProtectPassword:@""];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void) imageQualityChanged:(id)sender
{
    switch ([sender selectedSegmentIndex]) {
        case 0:
            self.imageQulity = 300;
            break;
        case 1:
            self.imageQulity = 750;
            break;
        case 2:
            self.imageQulity = 1024;
            break;
        default:
            break;
    }
}

- (void) downloadDurationChanged:(id)sender
{
    switch ([sender selectedSegmentIndex]) {
        case 0:
            self.downloadDuration = 0;
            break;
        case 1:
            self.downloadDuration = 1;
            break;
        case 2:
            self.downloadDuration = 7;
            break;
        case 3:
            self.downloadDuration = 1000;
            break;
        default:
            break;
    }
}
- (void) changedSegmentFont:(UISegmentedControl*)seg
{
    for (UIView* each in [seg subviews]) {
        if ([each isKindOfClass:[UILabel class]]) {
            UILabel* text = (UILabel*)each;
            text.font = [UIFont systemFontOfSize:15];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.accountUserId;
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
                                                                                   target:self action:@selector(saveSettings)];
    self.navigationItem.rightBarButtonItem = anotherButton;
    [anotherButton release];
    
    if (!WizDeviceIsPad()) {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                                      target:self action:@selector(cancelSettings)];
        self.navigationItem.leftBarButtonItem = cancelButton;
        [cancelButton release];
    }


    self.mbileViewCellLabel.text = NSLocalizedString(@"Mobile view" , nil);
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    self.mobileViewSwitch.on = [index isMoblieView];
    NSString* password = [WizSettings accountProtectPassword];
    self.protectCellNameLabel.text = NSLocalizedString(@"Account Protection", nil);
    if (password != nil && ![password isEqualToString:@""]) {
        self.oldPassword = password;
        self.protectCellSwitch.on = YES;
    }
    else
    {
        self.protectCellSwitch.on = NO;
    }
    
    self.defaultUserLabel.text = NSLocalizedString(@"Set the default user", nil);
    [self.defaultUserLabel setFont:[UIFont boldSystemFontOfSize:17]];
    NSString* defaultUserID = [WizSettings defaultAccountUserId];
    if ([self.accountUserId isEqualToString:defaultUserID]) {
        self.defaultUserSwitch.on = YES;
    }
    else
    {
        self.defaultUserSwitch.on = NO;
    }
    NSArray* imageQulityItems = [NSArray arrayWithObjects:NSLocalizedString(@"Low", nil),
                                 NSLocalizedString(@"Medium", nil),
                                 NSLocalizedString(@"High", nil), nil];
    UISegmentedControl* imageQulitySeg_ = [[UISegmentedControl alloc] initWithItems:imageQulityItems];
    [imageQulitySeg_ addTarget:self action:@selector(imageQualityChanged:) forControlEvents:UIControlEventValueChanged];
    [self.imageQualityCell.contentView addSubview:imageQulitySeg_];
    imageQulitySeg_.segmentedControlStyle = UISegmentedControlStyleBar;
    imageQulitySeg_.frame = CGRectMake(140, 0.0, 160, 44);

    NSArray* downloadDurationItems = [NSArray arrayWithObjects:NSLocalizedString(@"Zero", nil), 
                                      NSLocalizedString(@"A Day", nil),
                                      NSLocalizedString(@"Week", nil),
                                      NSLocalizedString(@"All", nil), nil];
    UISegmentedControl* downloadDurationSeg = [[UISegmentedControl alloc] initWithItems:downloadDurationItems];
    [downloadDurationSeg addTarget:self action:@selector(downloadDurationChanged:) forControlEvents:UIControlEventValueChanged];
    [self.downloadDataDurationCell addSubview:downloadDurationSeg];
    downloadDurationSeg.segmentedControlStyle = UISegmentedControlStyleBar;
    downloadDurationSeg.frame = CGRectMake(150, 0.0, 160, 44);
    self.downloadDataDurationCellNameLabel.text = NSLocalizedString(@"Download Data", nil);
    self.imageQualityLabel.text = NSLocalizedString(@"Image Quality", nil);
    int downloadDuration_ = [index durationForDownloadDocument];
    self.downloadDuration = downloadDuration_;
    switch (downloadDuration_) {
        case 0:
            [downloadDurationSeg setSelectedSegmentIndex:0];
            break;
        case 1:
            [downloadDurationSeg setSelectedSegmentIndex:1];
            break;
        case 7:
            [downloadDurationSeg setSelectedSegmentIndex:2];
            break;
        case 1000:
            [downloadDurationSeg setSelectedSegmentIndex:3];
            break;
        default:
            break;
    }
    [downloadDurationSeg release];
    int imageQuality_ = (int)[index imageQualityValue];
    self.imageQulity = imageQuality_;
    switch (imageQuality_) {
        case 300:
            [imageQulitySeg_ setSelectedSegmentIndex:0];
            break;
        case 750:
            [imageQulitySeg_ setSelectedSegmentIndex:1];
            break;
        case 1024:
            [imageQulitySeg_ setSelectedSegmentIndex:2];
            break;
        default:
            break;
    }
    [imageQulitySeg_ release];
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 4;
        case 1  :
            return 4;
        case 2:
            if ([[WizSettings accounts] count] >1) {
                return 4;
            }
            else
            {
                return 3;
            }
        default:
            return 0;
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (0 == section)
		return [NSString stringWithString: NSLocalizedString(@"Account Info", nil)];
	else if (1 == section)
		return [NSString stringWithString: NSLocalizedString(@"Account Settings", nil)];
	else if (2 == section)
		return [NSString stringWithString: NSLocalizedString(@"Operate Account", nil)];
	else 
		return nil;
}

- (NSString*) setStringDisplayWidth:(NSString*) str :(float)width
{
    CGSize detailSize = [NSLocalizedString(str, nil) sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(200, MAXFLOAT) lineBreakMode:UILineBreakModeCharacterWrap];
    str = NSLocalizedString(str, nil);
    while (detailSize.width <= width) {
        str = [NSString stringWithFormat:@"%@ ",str];
        detailSize = [str sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(200, MAXFLOAT) lineBreakMode:UILineBreakModeCharacterWrap];
    }
    return str;
}

- (NSString*) formatteStringToDisplay:(NSString*) str  :(NSString*) strValue
{
    NSString* displayString = [NSString stringWithFormat:@"%@:%@",[self setStringDisplayWidth:str :100] ,strValue];
    return displayString;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d",indexPath.row ];
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (1 == indexPath.section) {
        if (0 == indexPath.row) {
            return self.mobileViewCell;
        }
        else if ( 1 == indexPath.row)
        {
            return self.protectCell;
        }
        else if ( 2 == indexPath.row )
        {
            return self.downloadDataDurationCell;
        }
        else if ( 3 == indexPath.row )
        {
            return  self.imageQualityCell;
        }
    }
    
    if (0 == indexPath.section) {
        UILabel* nameLabel = nil;
        UILabel* valueLabel = nil;
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 200, 40)];
            valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 5, 200, 40)];
            [cell addSubview:nameLabel];
            [nameLabel release];
            [cell addSubview:valueLabel];
            [valueLabel release];
            valueLabel.textColor = [UIColor grayColor];
            nameLabel.textAlignment = UITextAlignmentLeft;
            valueLabel.textAlignment = UITextAlignmentRight;
            [valueLabel setFont:[UIFont systemFontOfSize:15]];
            nameLabel.backgroundColor = [UIColor clearColor];
            valueLabel.backgroundColor = [UIColor clearColor];
        }
        if (0 == indexPath.row) {
            nameLabel.text = NSLocalizedString(@"ID", nil);
            valueLabel.text = self.accountUserId;
            cell.selectionStyle  = UITableViewCellSelectionStyleNone;
            return cell;
        }
        else  if (1 == indexPath.row) {
            nameLabel.text = NSLocalizedString(@"User Type", nil);
            valueLabel.text =  NSLocalizedString([index userType], nil);
            cell.selectionStyle  = UITableViewCellSelectionStyleNone;
            return cell;
        }
        else if ( 2 == indexPath.row)
        {
            nameLabel.text = NSLocalizedString(@"User Points", nil);
            valueLabel.text = [index userPointsString];
            cell.selectionStyle  = UITableViewCellSelectionStyleNone;
            return cell;
        }
        else if ( 3 == indexPath.row)
        {
            nameLabel.text = NSLocalizedString(@"Traffic Usage", nil);
            valueLabel.text = [NSString stringWithFormat:@"%@/%@",[index userTrafficUsageString],[index userTrafficLimitString]];
            cell.selectionStyle  = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
       
    if (2 == indexPath.section) {
        static NSString* accountCell = @"account";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:accountCell];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:accountCell] autorelease];
        }
        if (0 == indexPath.row) {
            cell.textLabel.text = NSLocalizedString(@"Change Password", nil);
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            return cell;
        }
        else if (1 == indexPath.row) {
            cell.textLabel.text = NSLocalizedString(@"Remove Account", nil);
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            return cell;
        }
        else if (2 == indexPath.row)
        {
            cell.textLabel.text =NSLocalizedString( @"Change Account", nil);
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            return cell;
        }
        else if (3 == indexPath.row)
        {
            return self.defaultUserCell;
        }
    }
    return nil;
}
- (IBAction)setUserProtectPassword:(id)sender
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    if (self.protectCellSwitch.on) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Password", nil)
                                                        message:NSLocalizedString(@"                        ", nil)
                                                       delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        UITextField* text = [[UITextField alloc] initWithFrame:CGRectMake(12, 45, 260, 25)];
        text.keyboardType = UIKeyboardTypeNumberPad;
        [text becomeFirstResponder];
        [text setBackgroundColor:[UIColor whiteColor]];
        [alert addSubview:text];
        NSString* password = [WizSettings accountProtectPassword];
        if (password == nil) {
            password = @"";
        }
        text.text = password;
        [alert show];
        [alert release];
        [text release];
    }
    else
    {
        [index setUserProtectPassword:@""];
    }
}

#pragma mark - Table view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == ChangePasswordTag) {
        if (buttonIndex == 0) {
            for (UIView* each in alertView.subviews) {
                if ([each isKindOfClass:[UITextField class]]) {
                    UITextField* textField = (UITextField*)each;
                    NSString* text = textField.text;
                    if (nil != text && ![text isEqualToString:@""]) {
                        self.newAccountPassword = text;
                    }
                }
            }

        }
        
        return;
    }
    
    if (alertView == self.waitAlertView) {

        if( buttonIndex == 0 ) //NO
        {
            [[[WizGlobalData sharedData] indexData:accountUserId] close];
            [WizSettings removeAccount:accountUserId];
            [[WizGlobalData sharedData] removeAccountData:self.accountUserId];
            if (WizDeviceIsPad()) {
                [[NSNotificationCenter defaultCenter] postNotificationName:MessageOfPadChangeUser object:nil userInfo:nil];
            }
            else
            {
                LoginViewController* mainView = [[WizGlobalData sharedData] wizMainLoginView:DataMainOfWiz];
                mainView.contentTableView.hidden = NO;
                mainView.willChangedUser = YES;
                [self.navigationController popViewControllerAnimated:NO];
                [[NSNotificationCenter defaultCenter] postNotificationName:MessageOfWizMainPickerViewPopSelf object:nil userInfo:nil];
            }
        }
        else 
        {
        }
    }
    else
    {
        for (UIView* each in alertView.subviews) {
            if ([each isKindOfClass:[UITextField class]]) {
                UITextField* textField = (UITextField*)each;
                NSString* text = textField.text;
                if (nil != text && ![text isEqualToString:@""]) {
                    [WizSettings setAccountProtectPassword:text];
                }
                else
                {
                    self.protectCellSwitch.on = NO;
                    [WizSettings setAccountProtectPassword:text];
                }
            }
        }
    }
}


- (void)removeAccount
{
	NSString *title = nil;
	if(accountUserId != nil && [accountUserId length] > 0 )
		title = [NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to delete %@ ?", nil), accountUserId];
	else
		title = [NSString stringWithString:NSLocalizedString(@"Are you sure you want to delete this account?", nil)];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:NSLocalizedString(@"The account information and local drafts will be deleted permanently from your device.", nil) 
												   delegate:self 
										  cancelButtonTitle:nil 
										  otherButtonTitles:WizStrRemove, WizStrCancel, nil];
    alert.delegate = self;
	self.waitAlertView = alert;
	[alert show];
	[alert release];
}

- (void) changeUserPassword
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Password", nil)
                                                    message:NSLocalizedString(@"                     ", nil)
                                                   delegate:self 
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    UITextField* text = [[UITextField alloc] initWithFrame:CGRectMake(12, 45, 260, 25)];
    [text becomeFirstResponder];
    [text setBackgroundColor:[UIColor whiteColor]];
    [alert addSubview:text];
    [alert show];
        alert.tag = ChangePasswordTag;
    [alert release];
    [text release];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    if (2 == indexPath.section) {
        if (0 == indexPath.row) {
            [self changeUserPassword];
        }
        else if (1 == indexPath.row) {
            [self removeAccount];
        }
        else if (2 == indexPath.row)
        {
            if (WizDeviceIsPad()) {
                [nc postNotificationName:MessageOfPadChangeUser object:nil userInfo:nil];
            }
            else
            {
                LoginViewController* mainView = [[WizGlobalData sharedData] wizMainLoginView:DataMainOfWiz];
                mainView.willChangedUser = YES;
                mainView.contentTableView.hidden = NO;
                [self.navigationController popViewControllerAnimated:NO];
                [[NSNotificationCenter defaultCenter] postNotificationName:MessageOfWizMainPickerViewPopSelf object:nil userInfo:nil];
                mainView.accountsArray = [WizSettings accounts];
                [[WizGlobalData sharedData] removeAccountData:self.accountUserId];
                [mainView.contentTableView reloadData];
            }

        }
    }
}
@end
