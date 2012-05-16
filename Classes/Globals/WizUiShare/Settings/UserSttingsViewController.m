//
//  UserSttingsViewController.m
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-13.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "UserSttingsViewController.h"
#import "WizGlobals.h"
#import "WizGlobalData.h"
#import "WizPhoneNotificationMessage.h"
#import "WizPadNotificationMessage.h"
#import "WizUserSettingCell.h"
#import "WizChangePasswordController.h"
#import "WizCheckProtectPassword.h"
#import "WizGlobalNotificationMessage.h"
#import "CloudReview.h"
#import "WizNotification.h"
#import "WizAccountManager.h"
#import "WizPasscodeViewController.h"
#import "WizSwitchCell.h"
#import "WizSettings.h"
#import "WizSingleSelectViewController.h"
#import "NSArray+WizSetting.h"

#define ClearCacheTag          1201
#define ChangePasswordTag 888
#define RemoveAccountTag  1002
#define ProtectPasswordTag 1003

#define ImageQualityTag 1000
#define DownloadDurationTag 1001
#define TableListViewOptionTag 1101
#define ProtectPasswordSucceedTag 1301

enum WizSettingKind {
    WizSetDownloadDurationCode = 4000,
    WizSetImageQulityCode = 4001,
    WizSetTableOption = 4002,
};
@interface UserSttingsViewController()
{
    WizSwitchCell* mobileViewCell;
    WizSwitchCell* protectCell;
    WizSwitchCell* connectViaWifiCell;
    WizSwitchCell* automicSyncCell;
    NSInteger      settingKind;
}
@property (nonatomic, retain) WizSwitchCell* mobileViewCell;
@property (nonatomic, retain) WizSwitchCell* protectCell;
@property (nonatomic, retain) WizSwitchCell* connectViaWifiCell;
@property (nonatomic, retain) WizSwitchCell* automicSyncCell;
@end


@implementation UserSttingsViewController
@synthesize mobileViewCell;
@synthesize protectCell;
@synthesize connectViaWifiCell;
@synthesize automicSyncCell;
- (void) dealloc
{
    [automicSyncCell release];
    [mobileViewCell release];
    [connectViaWifiCell release];
    [protectCell release];
    [super dealloc];
}
- (void) setAutomicSync
{
    [[WizSettings defaultSettings] setAutomicSync:self.automicSyncCell.valueSwitch.on];
}
- (void) setMobileView
{
    [[WizSettings defaultSettings] setDocumentMoblleView:self.mobileViewCell.valueSwitch.on];
}
- (void) setConnectViaWifi
{
    [[WizSettings defaultSettings] setConnectOnlyViaWifi:self.connectViaWifiCell.valueSwitch.on];
}

- (void) setPasscode
{
    WizPasscodeViewController* pass = [[WizPasscodeViewController alloc] init];
    pass.checkType= self.protectCell.valueSwitch.on?WizCheckPasscodeTypeOfNew:WizCheckPasscodeTypeOfClear;
    NSLog(@" %d %d",self.protectCell.valueSwitch.on,self.protectCell.valueSwitch.on?WizCheckPasscodeTypeOfClear:WizCheckPasscodeTypeOfNew);
    [self.navigationController pushViewController:pass animated:YES];
    [pass release];
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.automicSyncCell = [WizSwitchCell switchCell];
        self.automicSyncCell.textLabel.text = WizStrAutomicSync;
        [self.automicSyncCell.valueSwitch addTarget:self action:@selector(setAutomicSync) forControlEvents:UIControlEventValueChanged];
        //
        self.mobileViewCell = [WizSwitchCell switchCell];
        self.mobileViewCell.textLabel.text = NSLocalizedString(@"Mobile View", nil);
        [self.mobileViewCell.valueSwitch addTarget:self action:@selector(setMobileView) forControlEvents:UIControlEventValueChanged];
        //
        self.connectViaWifiCell = [WizSwitchCell switchCell];
        self.connectViaWifiCell.textLabel.text = NSLocalizedString(@"Sync Only By Wifi", nil);
        [self.connectViaWifiCell.valueSwitch addTarget:self action:@selector(setConnectViaWifi) forControlEvents:UIControlEventValueChanged];
        //
        self.protectCell = [WizSwitchCell switchCell];
        self.protectCell.textLabel.text = NSLocalizedString(@"Passcode Lock", nil);
        [self.protectCell.valueSwitch addTarget:self action:@selector(setPasscode) forControlEvents:UIControlEventValueChanged];
        
    }
    return self;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

//- (void) buildDisplayInfo
//{
//    NSArray* imageQulityItems = [NSArray arrayWithObjects:NSLocalizedString(@"Small", nil),
//                                 NSLocalizedString(@"Medium", nil),
//                                 NSLocalizedString(@"Large", nil), nil];
//    self.imageQualityData = imageQulityItems;
//    NSArray* downloadDurationItems = [NSArray arrayWithObjects:NSLocalizedString(@"Do not download", nil), 
//                                      NSLocalizedString(@"One day", nil),
//                                      WizStrOneWeek,
//                                      NSLocalizedString(@"All", nil), nil];
//    
//    NSArray* downloadDurationRemind_ = [NSArray arrayWithObjects:NSLocalizedString(@"Does not download any notes automatic", nil),
//                                        NSLocalizedString(@"Download notes within a day", nil),
//                                        NSLocalizedString(@"Download notes within a week", nil),
//                                        NSLocalizedString(@"Download all notes", nil),
//                                        nil];
//    
//    self.viewOptions = [NSArray arrayWithObjects:WizStrDateModified
//                    ,NSLocalizedString(@"Date modified (Reverse)" , nil)
//                    ,WizStrTitle
//                    ,NSLocalizedString(@"Title (Reverse)", nil)
//                    ,WizStrDateCreated
//                    ,NSLocalizedString(@"Date created (Reverse)", nil)
//                    ,nil];
//    
//    self.downloadDurationData = downloadDurationItems;
//    self.downloadDurationRemind = downloadDurationRemind_;
//}
- (void) logOutCurrentAccount
{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    WizAccountManager* manager = [WizAccountManager defaultManager];
    [manager logoutAccount];
    if ([WizGlobals WizDeviceIsPad]) {
        [nc postNotificationName:MessageOfPadChangeUser object:nil userInfo:nil];
        return;
    }
    else
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}
- (void) buildNavItems
{
    UIBarButtonItem* logoutItem = [[UIBarButtonItem alloc] initWithTitle:WizStrLogOut style:UIBarButtonItemStyleDone target:self action:@selector(logOutCurrentAccount)];
    self.navigationItem.rightBarButtonItem = logoutItem;
    [logoutItem release];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self buildNavItems];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    WizSettings* set = [WizSettings defaultSettings];
//    [set setPasscode:@""];
//    [set setPasscodeEnable:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
// wiz-dzpqzb test
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
                return 6;
        case 1  :
            return 2;
        case 2:
            return 3;
        case 3:
            return 3;
        case 4:
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
		return [NSString stringWithString: WizStrSync];
    else if (3 == section)
		return [NSString stringWithString: WizStrSettings];
	else if (4 == section)
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    WizSettings* defaultSettings = [WizSettings defaultSettings];
    cell.detailTextLabel.text = @"";
    cell.accessoryType =UITableViewCellAccessoryDisclosureIndicator;
    if ([indexPath isEqualToSectionAndRow:0 row:0]) {
        cell.textLabel.text = WizStrUserId;
        cell.detailTextLabel.text = [[WizAccountManager defaultManager] activeAccountUserId];
        cell.selectionStyle  = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else  if ([indexPath isEqualToSectionAndRow:0 row:1]) {
        cell.textLabel.text = NSLocalizedString(@"User Type", nil);
        cell.detailTextLabel.text =  NSLocalizedString([defaultSettings userType], nil);
        cell.selectionStyle  = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else if ( [indexPath isEqualToSectionAndRow:0 row:2])
    {
        cell.textLabel.text = NSLocalizedString(@"User Points", nil);
        cell.detailTextLabel.text = [defaultSettings userPointsString];
        cell.selectionStyle  = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else if ( [indexPath isEqualToSectionAndRow:0 row:3])
    {
        cell.textLabel.text = NSLocalizedString(@"Traffic Usage", nil);
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@/%@",[defaultSettings userTrafficUsageString],[defaultSettings userTrafficLimitString]];
        cell.selectionStyle  = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else if ( [indexPath isEqualToSectionAndRow:0 row:4])
    {
        cell.textLabel.text = WizStrChangePassword;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    else if ([indexPath isEqualToSectionAndRow:0 row:5])
    {
        cell.textLabel.text = NSLocalizedString(@"Remove account", nil);
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    else if ([indexPath isEqualToSectionAndRow:1 row:0])
    {
        cell.textLabel.text = NSLocalizedString(@"View Option", nil);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        NSInteger option = [defaultSettings userTablelistViewOption];
        cell.detailTextLabel.text = [[NSArray tableViewOptions] descriptionForWizSettingValue:option];
    }
    else if ([indexPath isEqualToSectionAndRow:2 row:0])
    {
        cell.textLabel.text = NSLocalizedString(@"Download Space", nil);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        NSInteger duration = [defaultSettings durationForDownloadDocument];
        cell.detailTextLabel.text = [[NSArray downloadDurationArray] descriptionForWizSettingValue:duration];
    }
    else if ([indexPath isEqualToSectionAndRow:3 row:0])
    {
        cell.textLabel.text = NSLocalizedString(@"Photo Quality", nil);
        NSInteger quality = [defaultSettings imageQualityValue] ;
        cell.detailTextLabel.text = [[NSArray imageQulityArray] descriptionForWizSettingValue:quality];
    }
    else if ([indexPath isEqualToSectionAndRow:3 row:1])
    {
        cell.textLabel.text = NSLocalizedString(@"Clear cache",nil);
    }
    else if ([indexPath isEqualToSectionAndRow:4 row:0])
    {
        cell.textLabel.text =NSLocalizedString( @"About WizNote", nil);
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    else if ([indexPath isEqualToSectionAndRow:4 row:1])
    {
        cell.textLabel.text =NSLocalizedString( @"User Manual", nil);
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    else if ([indexPath isEqualToSectionAndRow:4 row:2])
    {
        cell.textLabel.text =NSLocalizedString( @"Feedback", nil);
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    else if ([indexPath isEqualToSectionAndRow:4 row:3])
    {
        cell.textLabel.text =WizStrRateWizNote;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
   
    
    //
    
    else if ([indexPath isEqualToSectionAndRow:1 row:1]) {
        self.mobileViewCell.valueSwitch.on = [defaultSettings isMoblieView];
    }
    else if ([indexPath isEqualToSectionAndRow:2 row:1])
    {
         self.automicSyncCell.valueSwitch.on = [defaultSettings isAutomicSync];
    }
    else if ([indexPath isEqualToSectionAndRow:2 row:2])
    {
        self.connectViaWifiCell.valueSwitch.on = [defaultSettings connectOnlyViaWifi];
    }
    else if ([indexPath isEqualToSectionAndRow:3 row:2])
    {
        self.protectCell.valueSwitch.on = [defaultSettings isPasscodeEnable];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if ([indexPath isEqualToSectionAndRow:1 row:1]) {
        return self.mobileViewCell;
    }
    else if ([indexPath isEqualToSectionAndRow:2 row:1])
    {
        return self.automicSyncCell;
    }
    else if ([indexPath isEqualToSectionAndRow:2 row:2])
    {
        return self.connectViaWifiCell;
    }
    else if ([indexPath isEqualToSectionAndRow:3 row:2])
    {
        return self.protectCell;
    }
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    return cell;
}


- (void) clearCache
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Clear cache",nil)   
                                                       message:NSLocalizedString(@"All the cache files will be deleted, are you sure?",nil)   
                                                       delegate:self   
                                                       cancelButtonTitle:WizStrCancel 
                                                       otherButtonTitles:WizStrDelete,nil];  
    alert.tag = ClearCacheTag;
    [alert show];
    [alert release];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == ChangePasswordTag) {
        return;
    }
    else  if (alertView.tag == RemoveAccountTag)
    {
        if( buttonIndex == 1 ) //NO
        {
            [[WizAccountManager defaultManager] removeAccount:[[WizAccountManager defaultManager] activeAccountUserId]];
            if ([WizGlobals WizDeviceIsPad]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:MessageOfPadChangeUser object:nil userInfo:nil];
            }
            else
            {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }
    }
    else if (alertView.tag == ProtectPasswordTag)
    {
    }
    else if (alertView.tag == ClearCacheTag)
    {
        if (buttonIndex == 1) {
//            WizIndex* index = [WizIndex activeIndex];
//            [index clearCache];
        }
    }
}

//
- (void)removeAccount
{
	NSString *title = nil;
    NSString* accountUserId = [[WizAccountManager defaultManager] activeAccountUserId];
	if(accountUserId != nil && [accountUserId length] > 0 )
		title = [NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to remove %@?", nil), accountUserId];
	else
		title = [NSString stringWithString:NSLocalizedString(@"Are you sure you want to remove this account?", nil)];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:NSLocalizedString(@"The account information and local drafts will be deleted permanently from your device.", nil) 
												   delegate:self 
										  cancelButtonTitle:nil 
										  otherButtonTitles:WizStrCancel,WizStrRemove , nil];
    alert.delegate = self;
	alert.tag = RemoveAccountTag;
	[alert show];
	[alert release];
}

- (void) changeUserPassword
{
    WizChangePasswordController* changepw = [[WizChangePasswordController alloc] init];
    [self.navigationController pushViewController:changepw animated:YES];
    [changepw release];

}
- (void) sendFeedback
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController* mailPocker = [[MFMailComposeViewController alloc] init];
        mailPocker.mailComposeDelegate = self;
        [mailPocker setSubject:[NSString stringWithFormat:@"[%@] %@ by %@",[[UIDevice currentDevice] model],NSLocalizedString(@"Feedback", nil),[[WizAccountManager defaultManager] activeAccountUserId]]];
        NSArray* toRecipients = [NSArray arrayWithObjects:@"support@wiz.cn",@"yishuiliunian@gmail.com",nil];
        NSString* mailBody = [NSString stringWithFormat:@"%@:\n\n\n\n\n\n\n\n\n\n\n\n\n\n %@\n %@ \n%@"
                              ,NSLocalizedString(@"Your advice", nil)
                              ,[[UIDevice currentDevice] systemName]
                              ,[[UIDevice currentDevice] systemVersion]
                              ,[WizGlobals wizNoteVersion]];
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
- (void) didSelectedIndex:(NSInteger)index
{
    NSLog(@"selected %d", index);
    switch (settingKind) {
        case WizSetDownloadDurationCode:
            [[WizSettings defaultSettings] setDurationForDownloadDocument:[[NSArray downloadDurationArray] wizSettingValueAtIndex:index]];
            break;
        case WizSetTableOption:
            [[WizSettings defaultSettings] setUserTableListViewOption:[[NSArray tableViewOptions] wizSettingValueAtIndex:index]];
        case WizSetImageQulityCode:
            [[WizSettings defaultSettings] setImageQualityValue:[[NSArray imageQulityArray] wizSettingValueAtIndex:index]];
        default:
            break;
    }
}
- (void) selectDownoadDuration
{
    NSArray* downloadDurationArray = [NSArray downloadDurationArray];
    NSInteger lastIndex = [downloadDurationArray indexForWizSettingValue:[[WizSettings defaultSettings] durationForDownloadDocument]];
    WizSingleSelectViewController* sigle = [[WizSingleSelectViewController alloc] initWithValusAndLastIndex:downloadDurationArray lastIndex:lastIndex];
    sigle.singleSelectDelegate = self;
    settingKind = WizSetDownloadDurationCode;
    [self.navigationController pushViewController:sigle animated:YES];
    [sigle release];
}
- (void) selectTableOptions
{
    NSArray* downloadDurationArray = [NSArray tableViewOptions];
    NSInteger lastIndex = [downloadDurationArray indexForWizSettingValue:[[WizSettings defaultSettings] userTablelistViewOption]];
    WizSingleSelectViewController* sigle = [[WizSingleSelectViewController alloc] initWithValusAndLastIndex:downloadDurationArray lastIndex:lastIndex];
    sigle.singleSelectDelegate = self;
    settingKind = WizSetTableOption;
    [self.navigationController pushViewController:sigle animated:YES];
    [sigle release];
}

- (void) selectPhotoQuality
{
    NSArray* imageQulityArray = [NSArray imageQulityArray];
    NSInteger lastIndex = [imageQulityArray indexForWizSettingValue:[[WizSettings defaultSettings] imageQualityValue]];
    WizSingleSelectViewController* sigle = [[WizSingleSelectViewController alloc] initWithValusAndLastIndex:imageQulityArray lastIndex:lastIndex];
    sigle.singleSelectDelegate = self;
    settingKind = WizSetTableOption;
    [self.navigationController pushViewController:sigle animated:YES];
    [sigle release];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqualToSectionAndRow:0 row:4]) {
        [self changeUserPassword];
    }
    else if ([indexPath isEqualToSectionAndRow:0 row:5]) {
        [self removeAccount];
    }
    else if ([indexPath isEqualToSectionAndRow:1 row:0]) {
        [self selectTableOptions];
    }
    else if ([indexPath isEqualToSectionAndRow:2 row:0]) {
        [self selectDownoadDuration];
    }
    else if ([indexPath isEqualToSectionAndRow:3 row:0])
    {
        [self selectPhotoQuality];
    }
    else if ([indexPath isEqualToSectionAndRow:3 row:1])
    {
        [self clearCache];
    }
    else if ( (0 == indexPath.row ||1 == indexPath.row) && 4 == indexPath.section) { 
        NSURL* url = nil;
        NSString* key = nil;
        if (0 == indexPath.row) {
            key = @"iosabout";
        }
        else {
            key = @"ioshelp";
        }
        NSString* urlStr = [NSString stringWithFormat:@"http://api.wiz.cn/?p=wiz&v=%@&c=%@&l=%@",[WizGlobals wizNoteVersion],key,[WizGlobals localLanguageKey]];
        url = [[NSURL alloc] initWithString:urlStr];
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
    else if (2 == indexPath.row && 4 == indexPath.section) {
        [self sendFeedback];
    }
    else if (3 == indexPath.row && 4 == indexPath.section)
    {
        [self rateWizNote];
    }
    else
    {
        
    }
}
@end
