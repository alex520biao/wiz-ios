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
#import "WizAttachment.h"
#import "WizTag.h"
#import "WizTempDataBase.h"

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
//
//- (void) testDate
//{
//    static NSDateFormatter* formatter= nil;
//    if (!formatter) {
//        formatter = [[NSDateFormatter alloc] init];
//        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    }
//    NSDate* date = [NSDate date];
//    
//    NSString* dateString = [formatter stringFromDate:date];
//    
//    NSDate* date2 = [formatter dateFromString:dateString];
//    
//    int64_t interval = [date timeIntervalSinceReferenceDate];
//    NSLog(@"%lld",interval);
//    NSDate* date3 = [NSDate dateWithTimeIntervalSinceReferenceDate:interval];
//    
//    NSLog(@"%@ %@ %f %f",date, date2, [date timeIntervalSinceDate:date2],[date timeIntervalSinceDate:date3]);
//}
//
//- (void) testVersion:(WizInfoDataBase*)data
//{
//    [data setDocumentVersion:43];
//    NSLog(@"data documentVersion %lld",[data documentVersion]);
//    int version = 50;
//    [data setDocumentVersion:version];
//    if ([data documentVersion] == version) {
//        NSLog(@"pass document");
//    }
//    [data setAttachmentVersion:version];
//    if ([data attachmentVersion] == version) {
//        NSLog(@"pass attachmentVersion");
//    }
//    [data setTagVersion:version];
//    if ([data tagVersion] == version) {
//        NSLog(@"pass tagVersion");
//    }
//    [data setDeletedGUIDVersion:version];
//    if ([data deletedGUIDVersion] == version) {
//        NSLog(@"pass deletedGUIDVersion");
//    }
//    version = 56;
//    
//    [data setDocumentVersion:version];
//    if ([data documentVersion] == version) {
//        NSLog(@"pass update document");
//    }
//    [data setAttachmentVersion:version];
//    if ([data attachmentVersion] == version) {
//        NSLog(@"pass update attachmentVersion");
//    }
//    [data setTagVersion:version];
//    if ([data tagVersion] == version) {
//        NSLog(@"pass update  tagVersion");
//    }
//    [data setDeletedGUIDVersion:version];
//    if ([data deletedGUIDVersion] == version) {
//        NSLog(@"pass update  deletedGUIDVersion");
//    }
//
//}
//- (BOOL) isIDEqueToID:(id)data1  data2:(id)data2
//{
//    if ([data1 isKindOfClass:[NSString class]]) {
//       return [data1 isEqualToString:data2];
//    }
//    
//    else if ([data1 isKindOfClass:[NSNumber class]])
//    {
//        return [data1 isEqualToNumber:data2];
//    }
//    else if ([data1 isKindOfClass:[NSDate class]])
//    {
//        return [data1 isEqualToDate:data2];
//    }
//    return NO;
//}
//
//- (BOOL) testData:(id)data  updateData:(id)updatedata  type:(NSString*)key  inDataBase:(WizInfoDataBase*)dataBase;
//{
//    NSString* guid = [WizGlobals genGUID];
//    NSMutableDictionary* doc = [NSMutableDictionary dictionaryWithObject:data forKey:key];
//    [doc setObject:guid forKey:DataTypeUpdateDocumentGUID];
//    [dataBase updateDocument:doc];
//    WizDocument* document = [dataBase documentFromGUID:guid];
//    NSDictionary* insertDoc = [document dataBaseModelData];
//    id insertData = [insertDoc valueForKey:key];
//    if ([self isIDEqueToID:data data2:insertData]) {
//        NSLog(@"pass insert %@",key);
//    }
//    else
//    {
//        NSLog(@"not pass insert %@",key);
//    }
//    //update
//    [doc setObject:updatedata forKey:key];
//    [dataBase updateDocument:doc];
//    WizDocument* document1 = [dataBase documentFromGUID:guid];
//    NSDictionary* insertDoc1 = [document1 dataBaseModelData];
//    id insertData1= [insertDoc1 valueForKey:key];
//    if ([self isIDEqueToID:updatedata data2:insertData1]) {
//        NSLog(@"pass update %@",key);
//    }
//    else
//    {
//        NSLog(@"not pass update %@",key);
//    }
//    return NO;
//}
//
//- (BOOL) testArray:(NSArray*)array string:(NSString*)str
//{
//    if (array && [array count]) {
//        NSLog(@"pass %@ and has %d objects",str,[array count]);
//        return YES;
//    }
//    else{
//        NSLog(@"not pass %@",str);
//        return NO;
//    }
//}
//- (BOOL) testAttachmentData:(id)data  updateData:(id)updatedata  type:(NSString*)key  inDataBase:(WizInfoDataBase*)dataBase;
//{
//    NSString* guid = [WizGlobals genGUID];
//    NSString* documentGuid = @"8c9d8bd1-e9bd-4284-8f60-8341e8966f7f";
//    NSMutableDictionary* doc = [NSMutableDictionary dictionaryWithObject:data forKey:key];
//    [doc setObject:documentGuid forKey:DataTypeUpdateAttachmentDocumentGuid];
//    [doc setObject:guid forKey:DataTypeUpdateAttachmentGuid];
//    [dataBase updateAttachment:doc];
//    WizAttachment* attachment = [dataBase attachmentFromGUID:guid];
//    NSDictionary* insertDoc = [attachment dataBaseModelData];
//    id insertData = [insertDoc valueForKey:key];
//    if ([self isIDEqueToID:data data2:insertData]) {
//        NSLog(@"pass insert %@",key);
//    }
//    else
//    {
//        NSLog(@"%@\n%@",doc,insertData);
//        NSLog(@"not pass insert %@",key);
//    }
//    //update
//    [doc setObject:updatedata forKey:key];
//    [dataBase updateAttachment:doc];
//    WizAttachment* attachment1 = [dataBase attachmentFromGUID:guid];
//    NSDictionary* insertDoc1 = [attachment1 dataBaseModelData];
//    id insertData1= [insertDoc1 valueForKey:key];
//    if ([self isIDEqueToID:updatedata data2:insertData1]) {
//        NSLog(@"pass update %@",key);
//    }
//    else
//    {
//        NSLog(@"not pass update %@",key);
//    }
//    return NO;
//}
//
//- (BOOL) testTagData:(id)data  updateData:(id)updatedata  type:(NSString*)key  inDataBase:(WizInfoDataBase*)dataBase
//{
//    NSString* guid = [WizGlobals genGUID];
//    NSMutableDictionary* doc = [NSMutableDictionary dictionaryWithObject:data forKey:key];
//    [doc setObject:guid forKey:DataTypeUpdateTagGuid];
//    [dataBase updateTag:doc];
//    WizTag* attachment = [dataBase tagFromGuid:guid];
//    NSDictionary* insertDoc = [attachment dataBaseModelData];
//    id insertData = [insertDoc valueForKey:key];
//    if ([self isIDEqueToID:data data2:insertData]) {
//        NSLog(@"pass insert %@",key);
//    }
//    else
//    {
//        NSLog(@"%@\n%@",doc,insertData);
//        NSLog(@"not pass insert %@",key);
//    }
//    //update
//    [doc setObject:updatedata forKey:key];
//    [dataBase updateTag:doc];
//    WizTag* attachment1 = [dataBase tagFromGuid:guid];
//    NSDictionary* insertDoc1 = [attachment1 dataBaseModelData];
//    id insertData1= [insertDoc1 valueForKey:key];
//    if ([self isIDEqueToID:updatedata data2:insertData1]) {
//        NSLog(@"pass update %@",key);
//    }
//    else
//    {
//        NSLog(@"not pass update %@",key);
//    }
//    return NO;
//}
//
//- (void) testDocument:(WizInfoDataBase*)data
//{
//    
//    NSString* initString = @"aaaaaaaa";
//    NSString* updateString = @"pppppppp";
//    
//    [self testData:initString updateData:updateString type:DataTypeUpdateDocumentTitle inDataBase:data];
//    [self testData:initString updateData:updateString type:DataTypeUpdateDocumentLocation inDataBase:data];
//    [self testData:initString updateData:updateString type:DataTypeUpdateDocumentTagGuids inDataBase:data];
//    [self testData:initString updateData:updateString type:DataTypeUpdateDocumentDataMd5 inDataBase:data];
//    [self testData:initString updateData:updateString type:DataTypeUpdateDocumentGPS_COUNTRY inDataBase:data];
//    [self testData:initString updateData:updateString type:DataTypeUpdateDocumentFileType inDataBase:data];
//    [self testData:initString updateData:updateString type:DataTypeUpdateDocumentType inDataBase:data];
//    [self testData:initString updateData:updateString type:DataTypeUpdateDocumentGPS_ADDRESS inDataBase:data];
//    [self testData:initString updateData:updateString type:DataTypeUpdateDocumentGPS_DESCRIPTION inDataBase:data];
//    [self testData:initString updateData:updateString type:DataTypeUpdateDocumentUrl inDataBase:data];
//    [self testData:initString updateData:updateString type:DataTypeUpdateDocumentGPS_LEVEL1 inDataBase:data];
//    [self testData:initString updateData:updateString type:DataTypeUpdateDocumentGPS_LEVEL2 inDataBase:data];
//    [self testData:initString updateData:updateString type:DataTypeUpdateDocumentGPS_LEVEL3 inDataBase:data];
//
//    NSNumber* initBoolNumber = [NSNumber numberWithInt:0];
//    NSNumber* updateBollNumder = [NSNumber numberWithInt:1];
//    NSNumber* bigNumber = [NSNumber numberWithInt:56];
//    [self testData:initBoolNumber updateData:bigNumber type:DataTypeUpdateDocumentAttachmentCount inDataBase:data];
//    [self testData:initBoolNumber updateData:updateBollNumder type:DataTypeUpdateDocumentProtected inDataBase:data];
//    [self testData:initBoolNumber updateData:updateBollNumder type:DataTypeUpdateDocumentServerChanged inDataBase:data];
//    [self testData:initBoolNumber updateData:updateBollNumder type:DataTypeUpdateDocumentLocalchanged inDataBase:data];
//    [self testData:initBoolNumber updateData:bigNumber type:DataTypeUpdateDocumentREADCOUNT inDataBase:data];
//    
//    
//    NSNumber* realNumber = [NSNumber numberWithFloat:21.3];
//    NSNumber* updataRealNumber = [NSNumber numberWithFloat:96.2];
//    
//    [self testData:realNumber updateData:updataRealNumber type:DataTypeUpdateDocumentGPS_DOP inDataBase:data];
//    [self testData:realNumber updateData:updataRealNumber type:DataTypeUpdateDocumentGPS_LONGTITUDE inDataBase:data];
//    [self testData:realNumber updateData:updataRealNumber type:DataTypeUpdateDocumentGPS_ALTITUDE inDataBase:data];
//    [self testData:realNumber updateData:updataRealNumber type:DataTypeUpdateDocumentGPS_LATITUDE inDataBase:data];
//    
//    NSDate* date1 = [[NSDate dateWithDaysBeforeNow:10] dateIgnoreMillisecond];
//    NSDate* updateData = [[NSDate date] dateIgnoreMillisecond];
//    [self testData:date1 updateData:updateData type:DataTypeUpdateDocumentDateModified inDataBase:data];
//    [self testData:date1 updateData:updateData type:DataTypeUpdateDocumentDateCreated inDataBase:data];
//    
//    
//    
//    [self testArray:[data documentsByKey:updateString] string:@"documentsByKey"];
//    [self testArray:[data documentsByLocation:updateString] string:@"documentsByLocation"];
//    [self testArray:[data documentsByTag:updateString] string:@"documentsByTag"];
//    [self testArray:[data recentDocuments] string:@"recentDocuments"];
//    [self testArray:[data documentsForCache:100] string:@"documentsForCache"];
//    [self testArray:[data documentForUpload] string:@"documentForUpload"];
//    
//    if ([data documentForClearCacheNext]) {
//        NSLog(@"pass documentForClearCacheNext");
//    }
//    else
//    {
//        NSLog(@"pass not documentForClearCacheNext");
//    }
//    [self testAttachmentData:initString updateData:updateString type:DataTypeUpdateAttachmentDataMd5 inDataBase:data];
//    [self testAttachmentData:initString updateData:updateString type:DataTypeUpdateAttachmentDescription inDataBase:data];
//    [self testAttachmentData:initString updateData:updateString type:DataTypeUpdateAttachmentTitle inDataBase:data];
//    [self testAttachmentData:initBoolNumber updateData:updateBollNumder type:DataTypeUpdateAttachmentLocalChanged inDataBase:data];
//    [self testAttachmentData:initBoolNumber updateData:updateBollNumder type:DataTypeUpdateAttachmentServerChanged inDataBase:data];
//    [self testAttachmentData:date1 updateData:updateData type:DataTypeUpdateAttachmentDateModified inDataBase:data];
//    
//    [self testArray:[data attachmentsByDocumentGUID:@"8c9d8bd1-e9bd-4284-8f60-8341e8966f7f"] string:@"attachmentsByDocumentGUID"];
//
//
//    [self testTagData:initString updateData:updateString type:DataTypeUpdateTagParentGuid inDataBase:data];
//    [self testTagData:initString updateData:updateString type:DataTypeUpdateTagTitle inDataBase:data];
//    [self testTagData:initString updateData:updateString type:DataTypeUpdateTagDescription inDataBase:data];
//    [self testTagData:initBoolNumber updateData:updateBollNumder type:DataTypeUpdateTagLocalchanged inDataBase:data];
//    [self testTagData:date1 updateData:updateData type:DataTypeUpdateTagDtInfoModifed inDataBase:data];
//
//    [self testArray:[data allTagsForTree] string:@"allLocationsForTree"];
//    [self testArray:[data tagsForUpload] string:@"tagsForUpload"];
//    NSLog(@"tag abstract %@",[ data tagAbstractString:@"1"]);
//    
//    [data addDeletedGUIDRecord:[WizGlobals genGUID] type:@"documentGuid"];
//    [self testArray:[data deletedGUIDsForUpload] string:@"deletedGUIDsForUpload"];
//    
//    NSArray* locationArray = [NSArray arrayWithObjects:@"asdfasdf",@"dfsdf", nil];
//    [data clearDeletedGUIDs];
//    [data updateLocations:locationArray];
//    NSLog(@"%@",[data allLocationsForTree]);
//    
//    
//}
//
//
//- (void) testAbstract
//{
//    NSString* db = [[WizFileManager documentsPath] stringByAppendingPathComponent:@"temp.db"];
//    WizTempDataBase* temp = [[WizTempDataBase alloc] initWithPath:db modelName:@"WizAbstractDataBaseModel"];
//    UIImage* image = [UIImage imageNamed:@"icon_excel_img"];
//    [temp updateAbstract:@"xxxx" imageData:[image compressedData] guid:@"xxx" type:@"ddd" kbguid:@"xxxx"];
//    
//    WizAbstract* abst = [temp abstractOfDocument:@"xxx"];
//    NSLog(@"%@ %@",abst.text, abst.image);
//}
- (void) testSettingsDataBase
{
    [[WizDbManager shareDbManager] getWizSettingsDataBase];
    [[WizSyncManager shareManager] refreshToken];
}

- (void) initRootNavigation
{
    
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
        doc.kbGuid = groupId;
        doc.accountUserId = [[WizAccountManager defaultManager] activeAccountUserId];
        [doc saveWithData:nil attachments:arr ];
        [doc release];
        return YES;
    }
    return NO;
}

@end

