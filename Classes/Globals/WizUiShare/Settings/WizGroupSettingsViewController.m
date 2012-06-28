//
//  WizGroupSettingsViewController.m
//  Wiz
//
//  Created by wiz on 12-6-26.
//
//

#import "WizGroupSettingsViewController.h"
#import "WizAccountManager.h"
#import "WizSwitchCell.h"
#import "WizSettings.h"
#import "WizPasscodeViewController.h"
#import "NSArray+WizSetting.h"
#import "WizSingleSelectViewController.h"
#import "WizNotification.h"
#import "WizChangePasswordController.h"
#import "CloudReview.h"
#import "WizGroupDownloadViewController.h"
#import "MBProgressHUD.h"
#import "WizDbManager.h"
#import "WizFileManager.h"
#import "WizAbstractCache.h"


#define WizSettingTableAlertKindRemoveAccount 1000

enum WizTableIndex {
    WizSettingIndexUserType = 0,
    WizSettingIndexUserPoints = 1,
    WizSettingIndexManagerOffLine = 10,
    WizSettingIndexSyncByWifi = 11,
    WizSettingIndexAutoSync = 12,
    WizSettingIndexViewOption    =20,
    WizSettingIndexMoblieView = 21,
    WizSettingIndexPasscode = 30,
    WizSettingIndexChangePassword = 31,
    WizSettingIndexRemoveAccount = 32,
    WizSettingIndexClearCache = 40,
    WizSettingIndexAbout = 50,
    WizSettingIndexFeedBack = 51,
    WizSettingIndexRote = 52
};

typedef NSInteger WizSettingTableIndex;

@interface WizGroupSettingsViewController () <MBProgressHUDDelegate, UIActionSheetDelegate>
{
    NSArray* sectionHeadTitle;
    NSArray* sectionNailTitle;
    NSArray* cellsTitleArray;
    
    NSArray* switchCellsIndex;
    
    WizSwitchCell* mobileViewCell;
    WizSwitchCell* protectCell;
    WizSwitchCell* connectViaWifiCell;
    WizSwitchCell* automicSyncCell;
    
    NSInteger settingKind;
    
    MBProgressHUD* hub;
}
@end

@implementation WizGroupSettingsViewController

- (void) dealloc
{
    [sectionHeadTitle release];
    [sectionNailTitle release];
    [cellsTitleArray release];
    [switchCellsIndex release];
    
    
    [mobileViewCell release];
    [protectCell release];
    [connectViaWifiCell release];
    [automicSyncCell release];
    [super dealloc];
}
- (void) buildTitles
{
    sectionHeadTitle = [[NSArray alloc] initWithObjects:
                        [[WizAccountManager defaultManager]activeAccountUserId]
                        ,@""
                        ,@""
                        ,@""
                        ,@""
                        ,@""
                        , nil];
    sectionNailTitle = [[NSArray alloc] initWithObjects:
                        @""
                        ,@""
                        ,@""
                        ,@""
                        ,NSLocalizedString(@"The documents recently downloaded will be removed from the local after clicking.",nil)
                        ,@""
                        , nil];
    NSArray* user = [[NSArray alloc] initWithObjects:
                     NSLocalizedString(@"User Type", nil)
                     ,NSLocalizedString(@"User Points", nil)
                     , nil];
    
    NSArray* global = [[NSArray alloc] initWithObjects:
                       NSLocalizedString(@"Passcode Lock", nil)
                       ,WizStrChangePassword
                       ,NSLocalizedString(@"Remove account", nil)
                       ,nil];
    NSArray* syncOption = [[NSArray alloc] initWithObjects:
                           NSLocalizedString(@"Offline Download", nil)
                           , NSLocalizedString(@"Sync Only By Wifi",nil)
                           , WizStrAutomicSync
                           , nil];
    NSArray* clearCache = [[NSArray alloc] initWithObjects:
                           NSLocalizedString(@"Clear cache",nil)
                           , nil];
    
    NSArray* viewOption = [[NSArray alloc] initWithObjects:
                           NSLocalizedString(@"View Option", nil)
                           ,NSLocalizedString(@"Mobile View", nil)
                           , nil];
    
    NSArray* about = [[NSArray alloc] initWithObjects:
                      NSLocalizedString( @"About WizNote", nil)
                      ,NSLocalizedString( @"Feedback", nil)
                      ,WizStrRateWizNote
                      , nil];
    
    cellsTitleArray = [[NSArray alloc] initWithObjects:
                       user
                       ,syncOption
                       ,viewOption
                       ,global
                       ,clearCache
                       ,about
                       , nil];
    
    switchCellsIndex = [[NSArray alloc] initWithObjects:
                        [NSNumber numberWithInt:WizSettingIndexAutoSync]
                        ,[NSNumber numberWithInt:WizSettingIndexMoblieView]
                        ,[NSNumber numberWithInt:WizSettingIndexPasscode]
                        ,[NSNumber numberWithInt:WizSettingIndexAutoSync]
                        , nil];
    [user release];
    [syncOption release];
    [viewOption release];
    [global release];
    [clearCache release];
    [about release];
}

- (NSString*) titleForSwithCell:(NSInteger)index
{
    NSInteger section = index/10;
    NSInteger row = index%10;
    
    return [[cellsTitleArray objectAtIndex:section] objectAtIndex:row];
}
- (void) setAutomicSync
{
    [[WizSettings defaultSettings] setAutomicSync:automicSyncCell.valueSwitch.on];
}
- (void) setMobileView
{
    [[WizSettings defaultSettings] setDocumentMoblleView:mobileViewCell.valueSwitch.on];
}
- (void) setConnectViaWifi
{
    [[WizSettings defaultSettings] setConnectOnlyViaWifi:connectViaWifiCell.valueSwitch.on];
}

- (void) setPasscode
{
    WizPasscodeViewController* pass = [[WizPasscodeViewController alloc] init];
    pass.checkType= protectCell.valueSwitch.on?WizCheckPasscodeTypeOfNew:WizCheckPasscodeTypeOfClear;
    [self.navigationController pushViewController:pass animated:YES];
    [pass release];
}
- (void) buildSwitchCell
{
    automicSyncCell = [[WizSwitchCell switchCell] retain];
    automicSyncCell.textLabel.text = [self titleForSwithCell:WizSettingIndexAutoSync];
    [automicSyncCell.valueSwitch addTarget:self action:@selector(setAutomicSync) forControlEvents:UIControlEventValueChanged];
    
    mobileViewCell = [[WizSwitchCell switchCell] retain];
    mobileViewCell.textLabel.text = [self titleForSwithCell:WizSettingIndexMoblieView];
    [mobileViewCell.valueSwitch addTarget:self action:@selector(setMobileView) forControlEvents:UIControlEventValueChanged];
    
    connectViaWifiCell = [[WizSwitchCell switchCell] retain];
    connectViaWifiCell.textLabel.text = [self titleForSwithCell:WizSettingIndexSyncByWifi];
    [connectViaWifiCell.valueSwitch addTarget:self action:@selector(setConnectViaWifi) forControlEvents:UIControlEventValueChanged];
    
    protectCell = [[WizSwitchCell switchCell] retain];
    protectCell.textLabel.text = [self titleForSwithCell:WizSettingIndexPasscode];
    [protectCell.valueSwitch addTarget:self action:@selector(setPasscode) forControlEvents:UIControlEventValueChanged];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self buildTitles];
        [self buildSwitchCell];
    }
    return self;
}
- (void) logOutCurrentAccount
{
    WizAccountManager* manager = [WizAccountManager defaultManager];
    [manager logoutAccount:[manager activeAccountUserId]];
    [self.navigationController popToRootViewControllerAnimated:YES];
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
//    self.tableView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [sectionNailTitle count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[cellsTitleArray objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.section*10 + indexPath.row;
    switch (index) {
        case WizSettingIndexAutoSync:
            return automicSyncCell;
        case WizSettingIndexMoblieView:
            return mobileViewCell;
        case WizSettingIndexPasscode:
            return protectCell;
        case WizSettingIndexSyncByWifi:
            return connectViaWifiCell;
        default:
        {
            static NSString *CellIdentifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
            }
            cell.textLabel.text = [[cellsTitleArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            return cell;
        }
    }
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    WizSettings* settings = [WizSettings defaultSettings];
    NSInteger index = indexPath.section*10 + indexPath.row;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.detailTextLabel.text = @"";
    switch (index) {
        case WizSettingIndexUserType:
            cell.detailTextLabel.text = [settings userType];
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        case WizSettingIndexUserPoints:
            cell.detailTextLabel.text = [settings userPointsString];
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        case WizSettingIndexManagerOffLine:
            break;
        case WizSettingIndexSyncByWifi:
            connectViaWifiCell.valueSwitch.on = [settings connectOnlyViaWifi];
            break;
        case WizSettingIndexAutoSync:
            automicSyncCell.valueSwitch.on = [settings isAutomicSync];
            break;
        case WizSettingIndexViewOption:
            break;
        case WizSettingIndexMoblieView:
            mobileViewCell.valueSwitch.on = [settings isMoblieView];
            break;
        case WizSettingIndexPasscode:
            protectCell.valueSwitch.on = [settings isPasscodeEnable];
            break;
        case WizSettingIndexChangePassword:
            break;
        case WizSettingIndexRemoveAccount:
            break;
        case WizSettingIndexClearCache:
            break;
        default:
            break;
    }
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate
- (void) didSelectedIndex:(NSInteger)index
{
    switch (settingKind) {
        case WizSetTableOption:
            [[WizSettings defaultSettings] setUserTableListViewOption:[[NSArray tableViewOptions] wizSettingValueAtIndex:index]];
            if ([WizGlobals WizDeviceIsPad]) {
                [WizNotificationCenter postMessageWithName:MessageTypeOfPadTableViewListChangedOrder userInfoObject:nil userInfoKey:nil];
            }
            break;
        default:
            break;
    }
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

- (void) changeUserPassword
{
    WizChangePasswordController* changepw = [[WizChangePasswordController alloc] init];
    [self.navigationController pushViewController:changepw animated:YES];
    [changepw release];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (WizSettingTableAlertKindRemoveAccount == alertView.tag)
    {
        if (1==buttonIndex) {
            [[WizAccountManager defaultManager] removeAccount:[[WizAccountManager defaultManager] activeAccountUserId]];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}
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
	alert.tag = WizSettingTableAlertKindRemoveAccount;
	[alert show];
	[alert release];
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
- (void) managerGroupDownloadOffline
{
    WizGroupDownloadViewController* download = [[WizGroupDownloadViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:download animated:YES];
    [download release];
}


- (void) doClearCache:(NSNumber*)timeInval
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    WizDocument* document = nil;
    CGFloat time = [timeInval floatValue];
    NSArray* groups = [[WizAccountManager defaultManager] activeAccountGroupsWithoutSection];
    NSString* accountUserId = [[WizAccountManager defaultManager] activeAccountUserId];
    WizFileManager* share = [WizFileManager shareManager];
    id<WizAbstractDbDelegate> abstractDataBase = [[WizDbManager shareDbManager] getWizTempDataBase:accountUserId];
    for (WizGroup* each in groups) {
        id<WizDbDelegate> dateBase = [[WizDbManager shareDbManager] getWizDataBase:accountUserId groupId:each.kbguid];
        do
        {
            NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
            document = [dateBase documentForClearCacheNext];
            if (document == nil) {
                break;
            }
            if (ABS([document.dateModified timeIntervalSinceNow]) < time) {
                break;
            }
            NSLog(@"real timeinterval is %f",[document.dateModified timeIntervalSinceNow]);
            NSString* path = [share objectFilePath:document.guid];
            if ([share removeItemAtPath:path error:nil]) {
                if([dateBase setDocumentServerChanged:document.guid changed:YES])
                {
                    [abstractDataBase deleteAbstractByGUID:document.guid];
                    NSArray* attachments = [document attachments];
                    for (WizAttachment* each in attachments) {
                        NSLog(@"attachment guid is %@",each.guid);
                        if (each.localChanged == 0) {
                            if ([dateBase setAttachmentServerChanged:each.guid changed:YES]) {
                                [share removeObjectPath:each.guid];
                            }
                        }
                    }
                }
            }
            [pool drain];
        }
        while (document != nil );
    }
    [[WizAbstractCache shareCache] didReceivedMenoryWarning];
    [pool drain];
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if (!hub) {
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.section*10 + indexPath.row;
    switch (index) {
        case WizSettingIndexManagerOffLine:
            [self managerGroupDownloadOffline];
            break;
        case WizSettingIndexViewOption:
            [self selectTableOptions];
            break;
        case WizSettingIndexChangePassword:
            [self changeUserPassword];
            break;
        case WizSettingIndexRemoveAccount:
            [self removeAccount];
            break;
        case WizSettingIndexClearCache:
            [self willClearCache];
            break;
        case WizSettingIndexAbout:
            break;
        case WizSettingIndexFeedBack:
            [self sendFeedback];
            break;
        case WizSettingIndexRote:
            [self rateWizNote];
            break;
        default:
            break;
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [sectionHeadTitle objectAtIndex:section];
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return [sectionNailTitle objectAtIndex:section];
}
@end
