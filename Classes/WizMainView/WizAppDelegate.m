//
//  WizAppDelegate.m
//  Wiz
//
//  Created by Wei Shijun on 3/7/11.
//  Copyright 2011 WizBrother. All rights reserved.
//
#import "WizAbstractCache.h"
#import "WizAppDelegate.h"
#import "WizIphoneLoginViewController.h"
#import "WizPadLoginViewController.h"
#import "UIView-TagExtensions.h"

#import "WizCheckProtectPassword.h"
#import "WizGlobalNotificationMessage.h"
#import "NSDate-Utilities.h"
#import "WizPhoneNotificationMessage.h"
#import "WizPadNotificationMessage.h"
#import "WizNotification.h"
#import "WizAccountManager.h"
#import "WizSyncManager.h"
#import "WizFileManager.h"
#import "WizPasscodeViewController.h"
#import "WizSettings.h"
#import "WizDbManager.h"

#import "WizDataBaseBase.h"
#import "WizInfoDataBase.h"
#import "WizGlobals.h"
#import "WizDocument.h"

#define WizAbs(x) x>0?x:-x

@interface WizAppDelegate()
{
    UILabel* syncLabel;
}
@property (nonatomic, retain) UILabel* syncLabel;
@end

@implementation WizAppDelegate
@synthesize syncLabel;
@synthesize window;
- (void) dealloc
{
    [syncLabel release];
    [window release];
    [super dealloc];
}
#pragma mark -
#pragma mark Application lifecycle

- (void) testDate
{
    static NSDateFormatter* formatter= nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    NSDate* date = [NSDate date];
    
    NSString* dateString = [formatter stringFromDate:date];
    
    NSDate* date2 = [formatter dateFromString:dateString];
    
    int64_t interval = [date timeIntervalSinceReferenceDate];
    NSLog(@"%lld",interval);
    NSDate* date3 = [NSDate dateWithTimeIntervalSinceReferenceDate:interval];
    
    NSLog(@"%@ %@ %f %f",date, date2, [date timeIntervalSinceDate:date2],[date timeIntervalSinceDate:date3]);
}

- (void) testVersion:(WizInfoDataBase*)data
{
    [data setDocumentVersion:43];
    NSLog(@"data documentVersion %lld",[data documentVersion]);
    int version = 50;
    [data setDocumentVersion:version];
    if ([data documentVersion] == version) {
        NSLog(@"pass document");
    }
    [data setAttachmentVersion:version];
    if ([data attachmentVersion] == version) {
        NSLog(@"pass attachmentVersion");
    }
    [data setTagVersion:version];
    if ([data tagVersion] == version) {
        NSLog(@"pass tagVersion");
    }
    [data setDeletedGUIDVersion:version];
    if ([data deletedGUIDVersion] == version) {
        NSLog(@"pass deletedGUIDVersion");
    }
    version = 56;
    
    [data setDocumentVersion:version];
    if ([data documentVersion] == version) {
        NSLog(@"pass update document");
    }
    [data setAttachmentVersion:version];
    if ([data attachmentVersion] == version) {
        NSLog(@"pass update attachmentVersion");
    }
    [data setTagVersion:version];
    if ([data tagVersion] == version) {
        NSLog(@"pass update  tagVersion");
    }
    [data setDeletedGUIDVersion:version];
    if ([data deletedGUIDVersion] == version) {
        NSLog(@"pass update  deletedGUIDVersion");
    }

}
- (BOOL) isIDEqueToID:(id)data1  data2:(id)data2
{
    if ([data1 isKindOfClass:[NSString class]]) {
       return [data1 isEqualToString:data2];
    }
    
    else if ([data1 isKindOfClass:[NSNumber class]])
    {
        return [data1 isEqualToNumber:data2];
    }
    return NO;
}

- (BOOL) testData:(id)data  updateData:(id)updatedata  type:(NSString*)key  inDataBase:(WizInfoDataBase*)dataBase;
{
    NSString* guid = [WizGlobals genGUID];
    NSMutableDictionary* doc = [NSMutableDictionary dictionaryWithObject:data forKey:key];
    [doc setObject:guid forKey:DataTypeUpdateDocumentGUID];
    [dataBase updateDocument:doc];
    WizDocument* document = [dataBase documentFromGUID:guid];
    NSDictionary* insertDoc = [document dataBaseModelData];
    id insertData = [insertDoc valueForKey:key];
    if ([self isIDEqueToID:data data2:insertData]) {
        NSLog(@"pass insert %@",key);
    }
    else
    {
        NSLog(@"not pass insert %@",key);
    }
    //update
    [doc setObject:updatedata forKey:key];
    [dataBase updateDocument:doc];
    WizDocument* document1 = [dataBase documentFromGUID:guid];
    NSDictionary* insertDoc1 = [document1 dataBaseModelData];
    id insertData1= [insertDoc1 valueForKey:key];
    if ([self isIDEqueToID:updatedata data2:insertData1]) {
        NSLog(@"pass update %@",key);
    }
    else
    {
        NSLog(@"not pass update %@",key);
    }
    
}

- (void) testDocument:(WizInfoDataBase*)data
{
    
    [self testData:@"dddddddd" updateData:@"xxxxxxxxx" type:DataTypeUpdateDocumentTitle inDataBase:data];
    [self testData:@"dddddddd" updateData:@"xxxxxxxxx" type:DataTypeUpdateDocumentLocation inDataBase:data];
    [self testData:@"dddddddd" updateData:@"xxxxxxxxx" type:DataTypeUpdateDocumentTagGuids inDataBase:data];
    [self testData:@"dddddddd" updateData:@"xxxxxxxxx" type:DataTypeUpdateDocumentDataMd5 inDataBase:data];
    [self testData:@"dddddddd" updateData:@"xxxxxxxxx" type:DataTypeUpdateDocumentGPS_COUNTRY inDataBase:data];
    [self testData:@"dddddddd" updateData:@"xxxxxxxxx" type:DataTypeUpdateDocumentFileType inDataBase:data];
    [self testData:@"dddddddd" updateData:@"xxxxxxxxx" type:DataTypeUpdateDocumentType inDataBase:data];
    [self testData:@"dddddddd" updateData:@"xxxxxxxxx" type:DataTypeUpdateDocumentGPS_ADDRESS inDataBase:data];
    [self testData:@"dddddddd" updateData:@"xxxxxxxxx" type:DataTypeUpdateDocumentGPS_DESCRIPTION inDataBase:data];
    [self testData:@"dddddddd" updateData:@"xxxxxxxxx" type:DataTypeUpdateDocumentUrl inDataBase:data];
    [self testData:@"dddddddd" updateData:@"xxxxxxxxx" type:DataTypeUpdateDocumentGPS_LEVEL1 inDataBase:data];
    [self testData:@"dddddddd" updateData:@"xxxxxxxxx" type:DataTypeUpdateDocumentGPS_LEVEL2 inDataBase:data];
    [self testData:@"dddddddd" updateData:@"xxxxxxxxx" type:DataTypeUpdateDocumentGPS_LEVEL3 inDataBase:data];

    NSNumber* initBoolNumber = [NSNumber numberWithInt:1];
    NSNumber* updateBollNumder = [NSNumber numberWithInt:0];
    NSNumber* bigNumber = [NSNumber numberWithInt:56];
    [self testData:initBoolNumber updateData:bigNumber type:DataTypeUpdateDocumentAttachmentCount inDataBase:data];
    [self testData:initBoolNumber updateData:updateBollNumder type:DataTypeUpdateDocumentProtected inDataBase:data];
    [self testData:initBoolNumber updateData:updateBollNumder type:DataTypeUpdateDocumentServerChanged inDataBase:data];
    [self testData:initBoolNumber updateData:updateBollNumder type:DataTypeUpdateDocumentLocalchanged inDataBase:data];
    [self testData:initBoolNumber updateData:bigNumber type:DataTypeUpdateDocumentREADCOUNT inDataBase:data];
    
    
    NSNumber* realNumber = [NSNumber numberWithFloat:21.3];
    NSNumber* updataRealNumber = [NSNumber numberWithFloat:96.2];
    
    [self testData:realNumber updateData:updataRealNumber type:DataTypeUpdateDocumentGPS_DOP inDataBase:data];
    [self testData:realNumber updateData:updataRealNumber type:DataTypeUpdateDocumentGPS_LONGTITUDE inDataBase:data];
    [self testData:realNumber updateData:updataRealNumber type:DataTypeUpdateDocumentGPS_ALTITUDE inDataBase:data];
    [self testData:realNumber updateData:updataRealNumber type:DataTypeUpdateDocumentGPS_LATITUDE inDataBase:data];
}

- (void) initRootNavigation
{
    {
        [self testDate];
        NSString* db = [[WizFileManager documentsPath] stringByAppendingPathComponent:@"ddd.db"];
        WizInfoDataBase* data = [[WizInfoDataBase alloc] initWithPath:db modelName:@"WizDataBaseModel"];
        [self testDocument:data];
    }
    [WizNotificationCenter removeObserver:self];
    UINavigationController* root = [[UINavigationController alloc] init];
    if ([WizGlobals WizDeviceIsPad])
    {
        WizPadLoginViewController* pad = [[WizPadLoginViewController alloc] init];
        [root pushViewController:pad animated:NO];
        [pad release];
    }
    else
    {
        WizIphoneLoginViewController* login = [[WizIphoneLoginViewController alloc] initWithNibName:@"WizIphoneLoginViewController" bundle:nil];
        [root pushViewController:login animated:NO];
        [login release];
    }
    window.rootViewController = root;
    [root release];
    [self.window makeKeyAndVisible];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self initRootNavigation];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {

}
- (void) accountProtect
{
    WizPasscodeViewController* check = [[WizPasscodeViewController alloc] init];
    check.checkType = WizcheckPasscodeTypeOfCheck;
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:check];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.window.rootViewController presentModalViewController:nav animated:NO];
    [check release];
    [nav release];
}
- (void)applicationWillEnterForeground:(UIApplication *)application 
{
    
}
- (void) applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [[WizAbstractCache shareCache] didReceivedMenoryWarning];
    [WizNotificationCenter postSimpleMessageWithName:MessageTypeOfMemeoryWarning];
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
    if ([[WizSettings defaultSettings] isPasscodeEnable]) {
        [self accountProtect];
    }
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}


#pragma mark -
#pragma mark Memory management

- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{

    NSString* defaultAccount = [[WizAccountManager defaultManager] activeAccountUserId];
    if (defaultAccount == nil || [defaultAccount isEqualToString:@""]) {
        return NO;
    }
    if (url != nil && [url isFileURL]) {
        NSString* filePath = [url path];
        NSString* fileName = [filePath fileName];
        NSString* tempFilePath =[[WizFileManager shareManager] attachmentTempDirectory];
        NSString* toFilePath = [tempFilePath stringByAppendingPathComponent:fileName];
        NSURL* toUrl = [NSURL fileURLWithPath:toFilePath];
        NSError* error = nil;
        if (![[NSFileManager defaultManager] copyItemAtURL:url toURL:toUrl error:&error]) {
            [WizGlobals reportError:error];
            return NO;
        }
        WizDocument* doc = [[WizDocument alloc] init];
        doc.title = fileName;
        NSMutableArray* arr = [NSMutableArray array];
        [arr addAttachmentBySourceFile:toFilePath];
        
        NSString* groupId = [[WizAccountManager defaultManager] activeAccountGroupKbguid];
        if (groupId == nil || [groupId isBlock]) {
            groupId = [[WizSettings defaultSettings] defaultGroupKbGuid];
        }
        WizDataBase* dataBase = [[WizDbManager shareDbManager] getWizDataBase:defaultAccount groupId:groupId];
        [doc saveWithData:nil attachments:arr toDataBase:dataBase];
        [doc release];
        return YES;
    }
    return NO;
}

@end

