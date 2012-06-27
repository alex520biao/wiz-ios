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
#import "WizFileManager.h"
#import "WizSyncManager.h"
#import "WizDbManager.h"
#import "SelectFloderView.h"



#define ClearCacheTag          1201
#define ChangePasswordTag 888
#define RemoveAccountTag  1002
#define ProtectPasswordTag 1003

#define ImageQualityTag 1000
#define DownloadDurationTag 1001
#define TableListViewOptionTag 1101
#define ProtectPasswordSucceedTag 1301


@interface UserSttingsViewController()
{
    WizSwitchCell* mobileViewCell;
    WizSwitchCell* protectCell;
    WizSwitchCell* connectViaWifiCell;
    WizSwitchCell* automicSyncCell;
    NSInteger      settingKind;
    NSString* usedSpaceString;
     
    //clearcache
    BOOL  isStopClearCache;
    MBProgressHUD* hub;
}
@property (nonatomic, retain) WizSwitchCell* mobileViewCell;
@property (nonatomic, retain) WizSwitchCell* protectCell;
@property (nonatomic, retain) WizSwitchCell* connectViaWifiCell;
@property (nonatomic, retain) WizSwitchCell* automicSyncCell;
@property (atomic, retain) NSString* usedSpaceString;
@property (atomic, assign) BOOL isStopClearCache;
@end
@implementation UserSttingsViewController
@synthesize mobileViewCell;
@synthesize protectCell;
@synthesize connectViaWifiCell;
@synthesize automicSyncCell;
@synthesize usedSpaceString;
@synthesize isStopClearCache;
@synthesize navigationDelegate;
- (void) dealloc
{
    navigationDelegate = nil;
    [automicSyncCell release];
    [mobileViewCell release];
    [connectViaWifiCell release];
    [protectCell release];
    [usedSpaceString release];
    hub = nil;
    [super dealloc];
}

- (NSString*) selectedFolderOld
{
    return [[WizSettings defaultSettings] newNoteDefaultFolder];
}

- (void) didSelectedFolderString:(NSString *)folderString
{
    [[WizSettings defaultSettings] setNewNoteDefaultFolder:folderString];
}
- (void) selectDefaultNewNoteFolder
{
    SelectFloderView* selecteView = [[SelectFloderView alloc] initWithStyle:UITableViewStyleGrouped];
    selecteView.selectDelegate = self;
    [self.navigationController pushViewController:selecteView animated:YES];
    [selecteView release];
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
        
        self.usedSpaceString = @"";
        
    }
    return self;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void) logOutCurrentAccount
{
    WizAccountManager* manager = [WizAccountManager defaultManager];
    [manager logoutAccount:nil];
    if ([WizGlobals WizDeviceIsPad]) {
        [self.navigationDelegate willChangAccount];
    }
    else
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}
- (void) buildNavItems
{
    UIBarButtonItem* logoutItem = [[UIBarButtonItem alloc] initWithTitle:WizStrLogOut style:UIBarButtonItemStylePlain target:self action:@selector(logOutCurrentAccount)];
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
- (void) reloadUsedSpaceCell
{
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:2 inSection:4]] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (void) loadUserSpaceStirng
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    NSInteger usedSpace = [[WizFileManager shareManager] activeAccountFolderSize];
    CGFloat mUsedSpace = (CGFloat)usedSpace/1024/1024;
    NSString* str = NSLocalizedString(@"Used", nil);
    NSString* displayStr = [str stringByAppendingFormat:@" %.2fM",mUsedSpace];
    self.usedSpaceString =  NSLocalizedString(displayStr, nil);
    [self performSelectorOnMainThread:@selector(reloadUsedSpaceCell) withObject:nil waitUntilDone:NO];
    [pool drain];
}
- (void) didChangedSyncDescription:(NSString *)description
{
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self performSelectorInBackground:@selector(loadUserSpaceStirng) withObject:nil];
    WizSyncManager* sync = [WizSyncManager shareManager];
    sync.displayDelegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    WizSyncManager* sync = [WizSyncManager shareManager];
    sync.displayDelegate = nil;
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
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 0;
        case 1:
            return 2;
        case 2:
            return 2;
        case 3:
            return 3;
        case 4:
            return 4;
        case 5:
            return 3;
        default:
            return 0;
    }
}

//- (NSString*)tableView:(UITableView*) tableView titleForFooterInSection:(NSInteger)section
//{
//    if (section == 0) {
//        WizSettings* settings = [WizSettings defaultSettings];
//        NSString* str = NSLocalizedString(@"Last synchronized: ", nil);
//        NSString* ret = [str stringByAppendingString:[[settings lastSynchronizeDate] stringSql]];
//        return ret;
//    }
//    return nil;
//}
//- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if (1 == section)
//		return [NSString stringWithString: NSLocalizedString(@"Account", nil)];
//	else if (2 == section)
//		return [NSString stringWithString: NSLocalizedString(@"View", nil)];
//    else if (3 == section)
//		return [NSString stringWithString: WizStrSync];
//    else if (4 == section)
//		return [NSString stringWithString: WizStrSettings];
//	else if (5 == section)
//		return [NSString stringWithString: NSLocalizedString(@"Help", nil)];
//	else
//		return nil;
//}

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
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.textLabel.textAlignment = UITextAlignmentLeft;
    if ([indexPath isEqualToSectionAndRow:0 row:0]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        if ([[[WizSyncManager shareManager] activeGroupSync] isSyncing]) {
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.textLabel.text = NSLocalizedString(@"Synchronization in process. Tap to stop it.", nil);
        }
        else {
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.textLabel.text = NSLocalizedString(@"Syncchronize now", nil);
        }
    }
    if ([indexPath isEqualToSectionAndRow:1 row:0])
    {
        cell.textLabel.text = WizStrUserId;
        cell.detailTextLabel.text = [[WizAccountManager defaultManager] activeAccountUserId];
        cell.selectionStyle  = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else  if ([indexPath isEqualToSectionAndRow:1 row:1]) {
        cell.textLabel.text = NSLocalizedString(@"User Type", nil);
        cell.detailTextLabel.text =  NSLocalizedString([defaultSettings userType], nil);
        cell.selectionStyle  = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else if ( [indexPath isEqualToSectionAndRow:1 row:2])
    {
        cell.textLabel.text = NSLocalizedString(@"User Points", nil);
        cell.detailTextLabel.text = [defaultSettings userPointsString];
        cell.selectionStyle  = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else if ( [indexPath isEqualToSectionAndRow:1 row:3])
    {
        cell.textLabel.text = WizStrChangePassword;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    else if ([indexPath isEqualToSectionAndRow:1 row:4])
    {
        cell.textLabel.text = NSLocalizedString(@"Remove account", nil);
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    else if ([indexPath isEqualToSectionAndRow:2 row:0])
    {
        cell.textLabel.text = NSLocalizedString(@"View Option", nil);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        NSInteger option = [defaultSettings userTablelistViewOption];
        cell.detailTextLabel.text = [[NSArray tableViewOptions] descriptionForWizSettingValue:option];
    }
    else if ([indexPath isEqualToSectionAndRow:3 row:0])
    {
        cell.textLabel.text = NSLocalizedString(@"Download Space", nil);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        NSInteger duration = [defaultSettings durationForDownloadDocument];
        cell.detailTextLabel.text = [[NSArray downloadDurationArray] descriptionForWizSettingValue:duration];
    }
    else if ([indexPath isEqualToSectionAndRow:4 row:0])
    {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.textLabel.text = NSLocalizedString(@"Default Folder", nil);
        cell.detailTextLabel.text = [WizGlobals  folderStringToLocal:[[WizSettings defaultSettings] newNoteDefaultFolder]];
    }
    else if ([indexPath isEqualToSectionAndRow:4 row:1])
    {
        cell.textLabel.text = NSLocalizedString(@"Photo Quality", nil);
        NSInteger quality = [defaultSettings imageQualityValue];
        cell.detailTextLabel.text = [[NSArray imageQulityArray] descriptionForWizSettingValue:quality];
    }
    else if ([indexPath isEqualToSectionAndRow:4 row:2])
    {
        cell.textLabel.text = NSLocalizedString(@"Clear cache",nil);
        cell.detailTextLabel.text = usedSpaceString;
    }
    else if ([indexPath isEqualToSectionAndRow:5 row:0])
    {
        cell.textLabel.text =NSLocalizedString( @"About WizNote", nil);
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    else if ([indexPath isEqualToSectionAndRow:5 row:1])
    {
        cell.textLabel.text =NSLocalizedString( @"Feedback", nil);
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    else if ([indexPath isEqualToSectionAndRow:5 row:2])
    {
        cell.textLabel.text =WizStrRateWizNote;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    //
    else if ([indexPath isEqualToSectionAndRow:2 row:1]) {
        self.mobileViewCell.valueSwitch.on = [defaultSettings isMoblieView];
    }
    else if ([indexPath isEqualToSectionAndRow:3 row:1])
    {
         self.automicSyncCell.valueSwitch.on = [defaultSettings isAutomicSync];
    }
    else if ([indexPath isEqualToSectionAndRow:3 row:2])
    {
        self.connectViaWifiCell.valueSwitch.on = [defaultSettings connectOnlyViaWifi];
    }
    else if ([indexPath isEqualToSectionAndRow:4 row:2])
    {
        self.protectCell.valueSwitch.on = [defaultSettings isPasscodeEnable];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if ([indexPath isEqualToSectionAndRow:2 row:1]) {
        return self.mobileViewCell;
    }
    else if ([indexPath isEqualToSectionAndRow:3 row:1])
    {
        return self.automicSyncCell;
    }
    else if ([indexPath isEqualToSectionAndRow:3 row:2])
    {
        return self.connectViaWifiCell;
    }
    else if ([indexPath isEqualToSectionAndRow:4 row:3])
    {
        return self.protectCell;
    }
    if ([indexPath isEqualToSectionAndRow:0 row:0]) {
        NSString* syncCellIdentifier = @"SyncCell";
        UITableViewCell* cell =  [tableView dequeueReusableCellWithIdentifier:syncCellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:syncCellIdentifier] autorelease];
        }
        return cell;
    }
    
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    return cell;
}


- (void) clearCache
{
    [self willClearCache];
}

- (void) hudWasHidden:(MBProgressHUD *)hud
{
    [hud removeFromSuperview];
    [hud release];
    hud = nil;
    self.usedSpaceString = @"";
    [self reloadUsedSpaceCell];
    [self performSelectorInBackground:@selector(loadUserSpaceStirng) withObject:nil];
}
- (void) doClearCache:(NSNumber*)timeInval
{
//    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
//    
//    id<WizDbDelegate> dbManager = [[WizDataBase alloc] init];
//    WizFileManager* share = [WizFileManager shareManager];
//    [dbManager reloadDb];
//    WizDocument* document = nil;
//    CGFloat time = [timeInval floatValue];
//    self.isStopClearCache = NO;
//    do
//    {
//        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
//        document = [dbManager documentForClearCacheNext];
//        if (document == nil) {
//            break;
//        }
//        if (ABS([document.dateModified timeIntervalSinceNow]) < time) {
//            break;
//        }
//        NSLog(@"real timeinterval is %f",[document.dateModified timeIntervalSinceNow]);
//        NSString* path = [share objectFilePath:document.guid];
//        if ([share removeItemAtPath:path error:nil]) {
//            if([dbManager setDocumentServerChanged:document.guid changed:YES])
//            {
//                [dbManager deleteAbstractByGUID:document.guid];
//                NSArray* attachments = [document attachments];
//                for (WizAttachment* each in attachments) {
//                    NSLog(@"attachment guid is %@",each.guid);
//                    if (each.localChanged == 0) {
//                        if ([dbManager setAttachmentServerChanged:each.guid changed:YES]) {
//                            [share removeObjectPath:each.guid];
//                        }
//                    }
//                }
//            }
//        }
//        [pool drain];
//    }
//    while (document != nil && !self.isStopClearCache);
//    [dbManager close];
//    [dbManager release];
//    [pool drain];
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([WizGlobals WizDeviceIsPad]) {
        UINavigationController* nav = [self.navigationDelegate settingsViewControllerParentViewController];
        hub = [[MBProgressHUD alloc] initWithView:nav.view];
        [nav.view addSubview:hub];
    }
    else {
        hub = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:hub];
    }
    hub.delegate = self;
    hub.labelText = NSLocalizedString(@"Clearing Cache ...", nil);
    switch (buttonIndex) {
        case 0:
            [hub showWhileExecuting:@selector(doClearCache:) onTarget:self withObject:[NSNumber numberWithFloat:86400] animated:YES];
            break;
        case 1:
            [hub showWhileExecuting:@selector(doClearCache:) onTarget:self withObject:[NSNumber numberWithFloat:604800] animated:YES];
            break;
        case 2:
            [hub showWhileExecuting:@selector(doClearCache:) onTarget:self withObject:[NSNumber numberWithFloat:2592000] animated:YES];
            break;
        case 3:
            [hub showWhileExecuting:@selector(doClearCache:) onTarget:self withObject:[NSNumber numberWithFloat:0] animated:YES];
            break;
        default:
            break;
    }
}

- (void) willClearCache
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:WizStrClearCache delegate:self cancelButtonTitle:WizStrCancel destructiveButtonTitle:nil otherButtonTitles:WizStrBeforeToday,WizStrBeforeAWeek,WizStrBeforeAMonth,WizStrAll,nil];
    [actionSheet showInView:self.view];
    [actionSheet release];
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
                [self.navigationDelegate willChangAccount];
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
        [self willClearCache];

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
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissModalViewControllerAnimated:YES];
}
- (void) sendFeedback
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController* mailPocker = [[MFMailComposeViewController alloc] init];
        mailPocker.mailComposeDelegate = self;
        [mailPocker setSubject:[NSString stringWithFormat:@"[%@] %@ by %@",[[UIDevice currentDevice] model],NSLocalizedString(@"Feedback", nil),[[WizAccountManager defaultManager] activeAccountUserId]]];
        NSArray* toRecipients = [NSArray arrayWithObjects:@"support@wiz.cn",@"ios@wiz.cn",nil];
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
            if ([WizGlobals WizDeviceIsPad]) {
                [WizNotificationCenter postMessageWithName:MessageTypeOfPadTableViewListChangedOrder userInfoObject:nil userInfoKey:nil];
            }
            break;
        case WizSetImageQulityCode:
            [[WizSettings defaultSettings] setImageQualityValue:[[NSArray imageQulityArray] wizSettingValueAtIndex:index]];
            break;
        case WizSelectGroup:
                  break;
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
    if ([indexPath isEqualToSectionAndRow:0 row:0]) {
        [self.tableView beginUpdates];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
    else if ([indexPath isEqualToSectionAndRow:1 row:3]) {
        [self changeUserPassword];
    }
    else if ([indexPath isEqualToSectionAndRow:1 row:4]) {
        [self removeAccount];
    }
    else if ([indexPath isEqualToSectionAndRow:2 row:0]) {
        [self selectTableOptions];
    }
    else if ([indexPath isEqualToSectionAndRow:3 row:0]) {
        [self selectDownoadDuration];
    }
    else if ([indexPath isEqualToSectionAndRow:4 row:0])
    {
        [self selectDefaultNewNoteFolder];
    }
    else if ([indexPath isEqualToSectionAndRow:4 row:1])
    {
        [self selectPhotoQuality];
    }
    else if ([indexPath isEqualToSectionAndRow:4 row:2])
    {
        [self clearCache];
    }
    else if ( 0 == indexPath.row && 5 == indexPath.section) {
        NSURL* url = nil;
        NSString* key = @"ioshelp";
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
    else if (1 == indexPath.row && 5 == indexPath.section) {
        [self sendFeedback];
    }
    else if (2 == indexPath.row && 5 == indexPath.section)
    {
        [self rateWizNote];
    }
    else
    {
        
    }
}
@end
