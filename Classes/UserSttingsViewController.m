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
#import "PickViewController.h"
#import "WizPhoneNotificationMessage.h"
#import "WizPadNotificationMessage.h"
#import "WizUserSettingCell.h"
#import "WizChangePasswordController.h"
#import "WizCheckProtectPassword.h"
#import "WizGlobalNotificationMessage.h"
#import "CloudReview.h"

#define ClearCacheTag          1201
#define ChangePasswordTag 888
#define RemoveAccountTag  1002
#define ProtectPasswordTag 1003

#define ImageQualityTag 1000
#define DownloadDurationTag 1001
#define TableListViewOptionTag 1101
#define ProtectPasswordSucceedTag 1301

@implementation UserSttingsViewController
@synthesize accountUserId;
@synthesize tablelistViewOption;
@synthesize mobileViewCell;
@synthesize mobileViewSwitch;
@synthesize mbileViewCellLabel;
@synthesize protectCell;
@synthesize protectCellSwitch;
@synthesize protectCellNameLabel;
@synthesize defaultUserCell;
@synthesize defaultUserLabel;
@synthesize defaultUserSwitch;
@synthesize downloadDuration;
@synthesize imageQulity;
@synthesize pickView;
@synthesize imageQualityData;
@synthesize downloadDurationData;
@synthesize accountProtectPassword;
@synthesize downloadDurationRemind;
@synthesize viewOptions;
- (void) dealloc
{
    self.viewOptions = nil;
    self.downloadDurationRemind = nil;
    self.accountProtectPassword = nil;
    self.pickView = nil;
    self.imageQualityData = nil;
    self.downloadDurationData = nil;
    self.accountUserId = nil;
    self.defaultUserCell = nil;
    self.defaultUserLabel = nil;
    self.defaultUserSwitch = nil;
    self.mobileViewCell = nil;
    self.mobileViewSwitch = nil;
    self.mbileViewCellLabel = nil;
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
- (BOOL) isIndexPathInTheRowAndSection:(NSIndexPath*) indexPath  :(NSUInteger)row :(NSUInteger)section
{
    return indexPath.row == row && indexPath.section == section;
}
- (void) saveSettings
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    if (self.tablelistViewOption != [index userTablelistViewOption]) {
        [index setUserTableListViewOption:self.tablelistViewOption];
        if ([WizGlobals WizDeviceIsPad]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:MessageOfChangeDocumentListOrderMethod object:nil];
        }
        else
        {
           [[NSNotificationCenter defaultCenter] postNotificationName:MessageOfDocumentlistWillReloadData object:nil]; 
        }
        
    }
    [index setDocumentMoblleView:self.mobileViewSwitch.on];
    [index setDurationForDownloadDocument:self.downloadDuration];
    if (self.defaultUserSwitch.on) {
        [WizSettings setDefalutAccount:self.accountUserId];
    }
    if (!self.protectCellSwitch.on) {
        [WizSettings setAccountProtectPassword:@""];
    }
    else
    {
        [WizSettings setAccountProtectPassword:self.accountProtectPassword];
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
    [self.navigationController popViewControllerAnimated:YES];
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
- (NSInteger) indexOfImageQuality:(NSInteger)quality
{
    switch (quality) {
        case 300:
            return 0;
            break;
        case 750:
            return 1;
            break;
        case 1024:
            return 2;
            break;
        default:
            break;
    }
    return 300;
}

- (NSInteger) imageQulityFormIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            return 300;
            break;
        case 1:
            return 750;
            break;
        case 2:
            return 1024;
            break;
        default:
            break;
    }
    return 0;
}

- (NSInteger) indexOfDownloadDuration:(NSInteger)duration
{
    switch (duration) {
        case 0:
            return 0;
            break;
        case 1:
            return 1;
            break;
        case 7:
            return 2;
            break;
        case 1000:
            return 3;
            break;
        default:
            break;
    }
    return 1;
}

- (NSInteger) downloadDurationFromIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            return 0;
            break;
        case 1:
            return 1;
            break;
        case 2:
            return 7;
            break;
        case 3:
            return 1000;
            break;
        default:
            break;
    }
    return 1;
}
- (void) buildDisplayInfo
{
    NSArray* imageQulityItems = [NSArray arrayWithObjects:NSLocalizedString(@"Low", nil),
                                 NSLocalizedString(@"Medium", nil),
                                 NSLocalizedString(@"High", nil), nil];
    self.imageQualityData = imageQulityItems;
    NSArray* downloadDurationItems = [NSArray arrayWithObjects:NSLocalizedString(@"Zero", nil), 
                                      NSLocalizedString(@"One day", nil),
                                      NSLocalizedString(@"One week", nil),
                                      NSLocalizedString(@"All", nil), nil];
    
    NSArray* downloadDurationRemind_ = [NSArray arrayWithObjects:NSLocalizedString(@"Do not download any notes data", nil),
                                        NSLocalizedString(@"Download notes data in one day", nil),
                                        NSLocalizedString(@"Download notes data in one week", nil),
                                        NSLocalizedString(@"Download all notes data", nil),
                                        nil];
    
    self.viewOptions = [NSArray arrayWithObjects:NSLocalizedString(@"Date modified" , nil)
                    ,NSLocalizedString(@"Date modified (Reverse)" , nil)
                    ,NSLocalizedString(@"Title", nil)
                    ,NSLocalizedString(@"Title (Reverse)", nil)
                    ,NSLocalizedString(@"Date created", nil)
                    ,NSLocalizedString(@"Date created (Reverse)", nil)
                    ,nil];
    
    self.downloadDurationData = downloadDurationItems;
    self.downloadDurationRemind = downloadDurationRemind_;
}
- (void)viewDidLoad
{
    [super viewDidLoad];

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
     [self buildDisplayInfo];
    self.title = self.accountUserId;
    self.mbileViewCellLabel.text = NSLocalizedString(@"Mobile view" , nil);
    self.protectCellNameLabel.text = NSLocalizedString(@"App Lunch Protection", nil);
    self.defaultUserLabel.text = NSLocalizedString(@"Set default account", nil);
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    self.mobileViewSwitch.on = [index isMoblieView];
    NSString* password = [WizSettings accountProtectPassword];
    if (password != nil && ![password isEqualToString:@""]) {
        self.accountProtectPassword = password;
        self.protectCellSwitch.on = YES;
    }
    else
    {
        self.protectCellSwitch.on = NO;
    }
    NSString* defaultUserID = [WizSettings defaultAccountUserId];
    if (defaultUserID == nil) {
        defaultUserID = @"";
    }
    if ([self.accountUserId isEqualToString:defaultUserID]) {
        self.defaultUserSwitch.on = YES;
    }
    else
    {
        self.defaultUserSwitch.on = NO;
    }
    self.downloadDuration = [index durationForDownloadDocument];
    self.imageQulity = [index imageQualityValue];
    self.tablelistViewOption = [index userTablelistViewOption];
    
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
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 7;
        case 1  :
            return 2;
        case 2:
            return 1;
        case 3:
            return 3;
        case 4:
            return 1;
        case 5:
            return 4;
        default:
            return 0;
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (0 == section)
		return [NSString stringWithString: NSLocalizedString(@"Account", nil)];
	else if (1 == section)
		return [NSString stringWithString: NSLocalizedString(@"View", nil)];
    else if (2 == section)
		return [NSString stringWithString: NSLocalizedString(@"Sync", nil)];
    else if (3 == section)
		return [NSString stringWithString: NSLocalizedString(@"Settings", nil)];
	else if (4 == section)
		return [NSString stringWithString: NSLocalizedString(@"Switch accounts", nil)];
	else if (5 == section)
		return [NSString stringWithString: NSLocalizedString(@"Help", nil)];
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
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell",indexPath.row ];
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    WizUserSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[WizUserSettingCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.nameLabel.text = @"";
    cell.valueLabel.text = @"";
    cell.textLabel.text = @"";
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.detailTextLabel.text = @"";
    if (0 == indexPath.row && 0 == indexPath.section) {
        cell.nameLabel.text = NSLocalizedString(@"User ID", nil);
        cell.valueLabel.text = self.accountUserId;
        cell.selectionStyle  = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else  if (1 == indexPath.row && 0 == indexPath.section) {
        cell.nameLabel.text = NSLocalizedString(@"User Type", nil);
        cell.valueLabel.text =  NSLocalizedString([index userType], nil);
        cell.selectionStyle  = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if ( 2 == indexPath.row && 0 == indexPath.section)
    {
        cell.nameLabel.text = NSLocalizedString(@"User Points", nil);
        cell.valueLabel.text = [index userPointsString];
        cell.selectionStyle  = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if ( 3 == indexPath.row && 0 == indexPath.section)
    {
        cell.nameLabel.text = NSLocalizedString(@"Traffic Usage", nil);
        cell.valueLabel.text = [NSString stringWithFormat:@"%@/%@",[index userTrafficUsageString],[index userTrafficLimitString]];
        cell.selectionStyle  = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if ( 4 == indexPath.row && 0 == indexPath.section)
    {
        cell.textLabel.text = NSLocalizedString(@"Change Password", nil);
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        return cell;
    }
    else if (5 == indexPath.row && 0 == indexPath.section)
    {
        cell.textLabel.text = NSLocalizedString(@"Remove Account", nil);
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        return cell;
    }
    else if ( 6== indexPath.row && 0 == indexPath.section)
    {
        return self.defaultUserCell;
    }
    else if (0 == indexPath.row && 1 == indexPath.section)
    {
        cell.nameLabel.text = NSLocalizedString(@"Notes sort order", nil);
        cell.valueLabel.text  = [self.viewOptions objectAtIndex:(self.tablelistViewOption-1)];
        return cell;
    }
    else if (1 == indexPath.row && 1 == indexPath.section)
    {
        return self.mobileViewCell;
    }
    else if (0 == indexPath.row && 2 == indexPath.section)
    {
        cell.nameLabel.text = NSLocalizedString(@"Download the document data", nil);
        cell.valueLabel.text  = [self.downloadDurationData objectAtIndex:[self indexOfDownloadDuration:self.downloadDuration]];
        return cell;
        
    }
    else if (0 == indexPath.row && 3 == indexPath.section)
    {
        cell.nameLabel.text = NSLocalizedString(@"Image dimensions", nil);
        cell.valueLabel.text = [self.imageQualityData objectAtIndex:[self indexOfImageQuality:self.imageQulity]];
        return cell;
    }
    else if (1 == indexPath.row && 3 == indexPath.section)
    {
        cell.textLabel.text = NSLocalizedString(@"Clear cache",nil);
    }
    else if (2 == indexPath.row && 3 == indexPath.section)
    {
        return self.protectCell;
    }

    else if (0 == indexPath.row && 4 == indexPath.section)
    {
        cell.textLabel.text =NSLocalizedString( @"Switch accounts", nil);
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        return cell;
    }
    else if (0 == indexPath.row && 5 == indexPath.section)
    {
        cell.textLabel.text =NSLocalizedString( @"About WizNote", nil);
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        return cell;
    }
    else if (1 == indexPath.row && 5 == indexPath.section)
    {
        cell.textLabel.text =NSLocalizedString( @"User Manual", nil);
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        return cell;
    }
    else if (2 == indexPath.row && 5 == indexPath.section)
    {
        cell.textLabel.text =NSLocalizedString( @"Feedback", nil);
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        return cell;
    }
    else if (3 == indexPath.row && 5 == indexPath.section)
    {
        cell.textLabel.text =NSLocalizedString( @"Rate WizNote", nil);
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        return cell;
    }
    return cell;
}

- (void) makeSureProtectPassword:(NSNotification*)nc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MessageOfProtectPasswordInputEnd object:nil];
    NSDictionary* userInfo = [nc userInfo];
    NSString* protectPassword = [userInfo valueForKey:TypeOfProtectPassword];
    NSLog(@"%@",protectPassword);
    if ([protectPassword isEqualToString:@"-1"]) {
        self.protectCellSwitch.on = NO;
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:WizStrError
                                                 message:NSLocalizedString(@"The password you entered does not match", nil) 
                                                delegate:nil 
                                              cancelButtonTitle:WizStrCancel otherButtonTitles:nil , nil];
        [alert show];
        [alert release];
        return;
    }
    else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:WizStrSucceed
                                                        message:NSLocalizedString(@"The protect password will be setted after saving setting", nil) 
                                                       delegate:self
                                              cancelButtonTitle:WizStrOK otherButtonTitles:nil , nil];
        [alert show];
        [alert release];
    }
    self.accountProtectPassword = protectPassword;
}
- (void) clearCache
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Clear cache",nil)   
                                                       message:NSLocalizedString(@"You will delete all the cache files, are you sure?",nil)   
                                                       delegate:self   
                                                       cancelButtonTitle:WizStrCancel 
                                                       otherButtonTitles:WizStrDelete,nil];  
    alert.tag = ClearCacheTag;
    [alert show];
    [alert release];
}
- (void) setProtectPassword
{
    WizCheckProtectPassword* check = [[WizCheckProtectPassword alloc] init];
    check.title = NSLocalizedString(@"Password", nil);
    check.willMakeSure = YES;
    UINavigationController* nav = [[UINavigationController alloc ] initWithRootViewController:check];
    [check release];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.navigationController presentModalViewController:nav animated:YES];;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeSureProtectPassword:) name:MessageOfProtectPasswordInputEnd object:nil];
}
- (IBAction)setUserProtectPassword:(id)sender
{

    if (self.protectCellSwitch.on) {
        [self setProtectPassword];
    }
    else
    {
        self.accountProtectPassword = @"";
    }
}

#pragma mark - Table view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == ChangePasswordTag) {
        return;
    }
    else   if (alertView.tag == RemoveAccountTag) {

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
                [self.navigationController popViewControllerAnimated:NO];
                [[NSNotificationCenter defaultCenter] postNotificationName:MessageOfWizMainPickerViewPopSelf object:nil userInfo:nil];
            }
        }

    }
    else if (alertView.tag == ProtectPasswordTag)
    {
        for (UIView* each in alertView.subviews) {
            if ([each isKindOfClass:[UITextField class]]) {
                UITextField* textField = (UITextField*)each;
                NSString* text = textField.text;
                if (nil != text && ![text isEqualToString:@""]) {
                    self.accountProtectPassword = text;
                }
                else
                {
                    self.protectCellSwitch.on = NO;
                    self.accountProtectPassword = text;
                }
            }
        }
    }
    else if (alertView.tag == ClearCacheTag)
    {
        if (buttonIndex == 1) {
            WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
            [index clearCache];
        }
    }
}


- (void)removeAccount
{
	NSString *title = nil;
	if(accountUserId != nil && [accountUserId length] > 0 )
		title = [NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to delete %@?", nil), accountUserId];
	else
		title = [NSString stringWithString:NSLocalizedString(@"Are you sure you want to delete this account?", nil)];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:NSLocalizedString(@"The account information and local drafts will be deleted permanently from your device.", nil) 
												   delegate:self 
										  cancelButtonTitle:nil 
										  otherButtonTitles:WizStrRemove, WizStrCancel, nil];
    alert.delegate = self;
	alert.tag = RemoveAccountTag;
	[alert show];
	[alert release];
}

- (void) changeUserPassword
{
    WizChangePasswordController* changepw = [[WizChangePasswordController alloc] init];
    changepw.accountUserId = self.accountUserId;
    [self.navigationController pushViewController:changepw animated:YES];
    [changepw release];

}
- (void) sendFeedback
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController* mailPocker = [[MFMailComposeViewController alloc] init];
        mailPocker.mailComposeDelegate = self;
        NSString* deviceStr = nil;
        if (WizDeviceIsPad()) {
            deviceStr = @"ipad";
        }
        else
        {
            deviceStr = @"iphone";
        }
        
        [mailPocker setSubject:[NSString stringWithFormat:@"[%@] %@ by %@",[[UIDevice currentDevice] model],NSLocalizedString(@"Feedback", nil),self.accountUserId]];
        NSArray* toRecipients = [NSArray arrayWithObject: @"support@wiz.cn"];
        NSString* mailBody = [NSString stringWithFormat:@"%@:\n\n\n\n\n\n\n\n\n\n\n\n\n\n %@\n %@"
                              ,NSLocalizedString(@"Your advice", nil)
                              ,[[UIDevice currentDevice] systemName]
                              ,[[UIDevice currentDevice] systemVersion]];
        [mailPocker setToRecipients:toRecipients];
        [mailPocker setMessageBody:mailBody isHTML:NO];
        mailPocker.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentModalViewController: mailPocker animated:YES];  
        [mailPocker release];
    }
}
- (void) rateWizNote
{
    [[CloudReview sharedReview] reviewFor:[[WizGlobals wizNoteAppleID] intValue]];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    
    if ( 4 == indexPath.row && 0 == indexPath.section)
    {
        [self changeUserPassword];
    }
    else if (5 == indexPath.row && 0 == indexPath.section) {
        [self removeAccount];
    }
    else  if (0 == indexPath.row && 1 == indexPath.section) {
        UIPickerView* pick = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, self.tableView.contentOffset.y+self.view.frame.size.height-180, 320, 200)];
        pick.delegate = self;
        pick.dataSource = self;
        pick.showsSelectionIndicator = YES;
        pick.tag = TableListViewOptionTag;
        self.tableView.scrollEnabled = NO;
        [self.view addSubview:pick];
    }
     else if ( 0 == indexPath.row && 2 == indexPath.section ) {
         
         UIPickerView* pick = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, self.tableView.contentOffset.y+self.view.frame.size.height-180, 320, 200)];
         pick.delegate = self;
         pick.dataSource = self;
         pick.showsSelectionIndicator = YES;
         pick.tag = DownloadDurationTag;
         self.tableView.scrollEnabled = NO;
         [self.view addSubview:pick];
    }
    else if (0 == indexPath.row && 3 == indexPath.section) {
        UIPickerView* pick = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, self.tableView.contentOffset.y+self.view.frame.size.height-180, 320, 200)];
        pick.delegate = self;
        pick.dataSource = self;
        pick.showsSelectionIndicator = YES;
        pick.tag = ImageQualityTag;
        self.tableView.scrollEnabled = NO;
        [self.view addSubview:pick];
    }
        else if (1 == indexPath.row && 3 == indexPath.section)
        {
                    [self clearCache];
    }
    else if (0 == indexPath.row && 4 == indexPath.section) {
        if (WizDeviceIsPad()) {
            [nc postNotificationName:MessageOfPadChangeUser object:nil userInfo:nil];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:MessageOfWizMainPickerViewPopSelf object:nil userInfo:nil];
        }
    }
    else if ( (0 == indexPath.row ||1 == indexPath.row) && 5 == indexPath.section) { 
        NSURL* url = nil;
        if (indexPath.row ==0) {
            url = [[NSURL alloc] initWithString:@"http://api.wiz.cn/?p=wiz&v=3.0.0.0&c=iphonehelp&l="];
        }
        else
        {
            url = [[NSURL alloc] initWithString:@"http://api.wiz.cn/?p=wiz&v=3.0.0.0&c=iphonehelp&l="];
        }
        NSURLRequest* req = [[NSURLRequest alloc] initWithURL:url];
        UIWebView* web = [[UIWebView alloc] init];
        UIViewController* con = [[UIViewController alloc] init];
        con.view = web;
        [web loadRequest:req];
        [self.navigationController pushViewController:con animated:YES];
        [req release];
        [url release];
        [web release];
        [con release];
    }
    else if (2 == indexPath.row && 5 == indexPath.section) {
        [self sendFeedback];
    }
    else if (3 == indexPath.row && 5 == indexPath.section)
    {
        [self rateWizNote];
    }
}

//picker delegate
- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView.tag == ImageQualityTag) {
        self.imageQulity = [self imageQulityFormIndex:row];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:3]] withRowAnimation:UITableViewRowAnimationRight];
    }
    else if (pickerView.tag == DownloadDurationTag)
    {
        self.downloadDuration = [self downloadDurationFromIndex:row];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationRight];
    }
    else if (pickerView.tag == TableListViewOptionTag)
    {
        self.tablelistViewOption = row+1;
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationRight];
    }
    self.tableView.scrollEnabled = YES;
    [pickerView removeFromSuperview];
}
- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag == ImageQualityTag) {
        return [imageQualityData count];
    }
    else if (pickerView.tag == DownloadDurationTag)
    {
        return [downloadDurationData count];
    }
    else if (pickerView.tag == TableListViewOptionTag)
    {
        return [viewOptions count];
    }
    return 0;
}
- (NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView.tag == ImageQualityTag) {
        return [imageQualityData objectAtIndex:row];
    }
    else if (pickerView.tag == DownloadDurationTag)
    {
        return [downloadDurationRemind objectAtIndex:row];
    }
    else if (pickerView.tag == TableListViewOptionTag)
    {
        return [viewOptions objectAtIndex:row];
    }
    return @"";
}
- (void) alertWithTitle: (NSString *)_title_ msg: (NSString *)msg   
{  
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_title_   
                                                    message:msg   
                                                   delegate:nil   
                                          cancelButtonTitle:WizStrOK 
                                          otherButtonTitles:nil];  
    [alert show];  
    [alert release];  
}  
- (void)mailComposeController:(MFMailComposeViewController *)controller   
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error   
{  
    NSString *msg;  
    
    switch (result)   
    {  
        case MFMailComposeResultCancelled:  
            msg = NSLocalizedString(@"Mail has been canceled", nil);
            break;  
        case MFMailComposeResultSaved:  
            msg =NSLocalizedString(@"Mail saved successfully", nil);
            [self alertWithTitle:nil msg:msg];  
            break;  
        case MFMailComposeResultSent:  
            msg = NSLocalizedString(@"Mail sended succeddfully", nil);  
            [self alertWithTitle:nil msg:msg];  
            break;  
        case MFMailComposeResultFailed:  
            msg = NSLocalizedString(@"Mail sended failed" , nil);
            [self alertWithTitle:nil msg:msg];  
            break;  
        default:  
            break;  
    }
    [self dismissModalViewControllerAnimated:YES];  
}  
@end
