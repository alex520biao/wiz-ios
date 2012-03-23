//
//  WizNotification.m
//  Wiz
//
//  Created by wiz on 12-3-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizNotification.h"
#import "WizGlobalData.h"

@implementation WizSyncMessage
@synthesize methodName;
@synthesize total;
@synthesize current;
- (id) initWithNotification:(NSNotification *)nc
{
    self = [super init];
    if (self) {
        @try {
            NSDictionary* userInfo = [nc userInfo];
            self.methodName = [userInfo objectForKey:MessageTypeSyncMethodName];
            self.total = [userInfo objectForKey:MessageTypeSyncProcessTotal];
            self.current = [userInfo objectForKey:MessageTypeSyncProcessCurrent];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
        
    }
    return self;
}

@end

@interface WizNotificationCenter()
+ (NSNotificationCenter*) shareNotificationCenter;
+ (void) addObserverWithKey:(id)observer selector:(SEL)selector name:(NSString *)name;
+ (id) getMessgeInfoForKey:(NSString*)key   notification:(NSNotification*)nc;
+ (void) postMessageWithName:(NSString*)messageName userInfoObject:(id)infoObject userInfoKey:(NSString*)infoKey;
+ (void) removeObserverWithKey:(id) observer name:(NSString*)name;
@end

@interface WizNotificationCenter(wizapi)

@end

@implementation WizNotificationCenter
static  NSNotificationCenter* shareNotificationCenter;
+ (NSNotificationCenter*) shareNotificationCenter
{
    if (shareNotificationCenter == nil) {
        shareNotificationCenter = [[NSNotificationCenter alloc] init];
    }
    return shareNotificationCenter;
}
+ (void) addObserverWithKey:(id)observer selector:(SEL)selector name:(NSString *)name
{
    NSNotificationCenter* nc = [WizNotificationCenter shareNotificationCenter];
    
    [nc addObserver:observer selector:selector name:name object:nil];
}
+ (void) removeObserver:(id) observer
{
    NSNotificationCenter* nc = [WizNotificationCenter shareNotificationCenter];
    [nc removeObserver:observer];
}
+ (void) removeObserverWithKey:(id) observer name:(NSString*)name
{
    NSNotificationCenter* nc = [WizNotificationCenter shareNotificationCenter];
    [nc removeObserver:observer name:name object:nil];
}
+ (void) postMessageWithName:(NSString*)messageName userInfoObject:(id)infoObject userInfoKey:(NSString*)infoKey
{
    NSNotificationCenter* nc = [WizNotificationCenter shareNotificationCenter];
    if (infoKey == nil || infoObject == nil) {
        [nc postNotificationName:messageName object:nil userInfo:nil];
    }
    else {
        [nc postNotificationName:messageName object:nil userInfo:[NSDictionary dictionaryWithObject:infoObject forKey:infoKey]];
    }
}
+ (id) getMessgeInfoForKey:(NSString*)key   notification:(NSNotification*)nc
{
    NSDictionary* userInfo = [nc userInfo];
    return [userInfo objectForKey:key];
}
+ (void) addObserverForSyncProceess:(id)observer     selector:(SEL)selector
{
    [WizNotificationCenter addObserverWithKey:observer selector:selector name:WizGlobalSyncProcessInfo];
}
+ (void) removeObserverForSyncProceess:(id) observer
{
    [WizNotificationCenter removeObserverWithKey:observer name:WizGlobalSyncProcessInfo];
}
+ (void) postWizGlobalSyncProcessInfo:(NSString*)typeOfMessage  infoData:(id)infoData
{
    NSString* messageType = [WizGlobalSyncProcessInfo stringByAppendingString:typeOfMessage];
    [WizNotificationCenter postMessageWithName:messageType userInfoObject:infoData userInfoKey:WizGlobalSyncProcessInfo];
}
+ (void) postWizGlobalSyncProcessInfoWithData:(NSString*)methodName     total:(NSInteger)total  current:(NSInteger)current
{
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:methodName forKey:MessageTypeSyncMethodName];
    [userInfo setObject:[NSNumber numberWithInt:total] forKey:MessageTypeSyncProcessTotal];
    [userInfo setObject:[NSNumber numberWithInt:current] forKey:MessageTypeSyncProcessCurrent];
    [WizNotificationCenter postWizGlobalSyncProcessInfo:methodName infoData:userInfo];
}

+(void) postSyncLoginBegin
{
    [WizNotificationCenter postWizGlobalSyncProcessInfoWithData:MessageTypeSyncLogin total:1 current:0];
}

+(void) postSyncLoginEnd
{
    [WizNotificationCenter postWizGlobalSyncProcessInfoWithData:MessageTypeSyncLogin total:1 current:1];
}

+(void) postSyncLogoutBegin
{
    [WizNotificationCenter postWizGlobalSyncProcessInfoWithData:MessageTypeSyncLogOut total:1 current:0];
}

+(void) postSyncLogoutEnd
{
    [WizNotificationCenter postWizGlobalSyncProcessInfoWithData:MessageTypeSyncLogOut total:1 current:0];
}

+(void) postSyncGetTagsListBegin:(int)beginVersion requsetCount:(int) requestCount
{
    [WizNotificationCenter postWizGlobalSyncProcessInfoWithData:MessageTypeSyncDownloadTags total:beginVersion+requestCount current:beginVersion];
}

+ (void) postSyncGetTagsListEnd:(int) lastVersion
{
    [WizNotificationCenter postWizGlobalSyncProcessInfoWithData:MessageTypeSyncDownloadTags total:lastVersion current:lastVersion];
}

+ (void) postSyncUploadTagListBegin
{
    [WizNotificationCenter postWizGlobalSyncProcessInfoWithData:MessageTypeSyncUploadTags total:1 current:0];
}

+(void) postSyncUploadTagListEnd
{
    [WizNotificationCenter postWizGlobalSyncProcessInfoWithData:MessageTypeSyncUploadTags total:1 current:1];
}
//get gategory
+(void) postSyncGetAllCategoriesBegin
{
    [WizNotificationCenter postWizGlobalSyncProcessInfoWithData:MessageTypeSyncSyncFolders total:1 current:0];
}

+(void) postSyncGetAllCategoriesEnd
{
    [WizNotificationCenter postWizGlobalSyncProcessInfoWithData:MessageTypeSyncSyncFolders total:1 current:1];
}
//attachments list
+(void) postSyncGetAttachmentListBegin:(int)beginVersion requsetCount:(int) requestCount
{
    [WizNotificationCenter postWizGlobalSyncProcessInfoWithData:MessageTypeSyncDownloadTags total:beginVersion+requestCount current:beginVersion];
}

+ (void) postSyncGetAttachmentListEnd:(int) lastVersion
{
    [WizNotificationCenter postWizGlobalSyncProcessInfoWithData:MessageTypeSyncDownloadTags total:lastVersion current:lastVersion];
}
+ (void) postSyncUploadAttachmentInfoBegin
{
    [WizNotificationCenter postWizGlobalSyncProcessInfoWithData:MessageTypeSyncUploadAttachmentInfo total:1 current:0];
}

+(void) postSyncUploadAttachmentInfoEnd
{
    [WizNotificationCenter postWizGlobalSyncProcessInfoWithData:MessageTypeSyncUploadAttachmentInfo total:1 current:1];
}

+(void) postSyncGetDocumentListBegin:(int)beginVersion requsetCount:(int) requestCount
{
    [WizNotificationCenter postWizGlobalSyncProcessInfoWithData:MessageTypeSyncDocumentList total:beginVersion+requestCount current:beginVersion];
}

+ (void) postSyncGetDocumentListEnd:(int) lastVersion
{
    [WizNotificationCenter postWizGlobalSyncProcessInfoWithData:MessageTypeSyncDocumentList total:lastVersion current:lastVersion];
}
+ (void) postSyncUploadDocumentInfoBegin
{
    [WizNotificationCenter postWizGlobalSyncProcessInfoWithData:MessageTypeSyncUploadDocumentInfo total:1 current:0];
}

+(void) postSyncUploadDocumentInfoEnd
{
    [WizNotificationCenter postWizGlobalSyncProcessInfoWithData:MessageTypeSyncUploadDocumentInfo total:1 current:1];
}
+ (void) postSyncDownloadDeletedListBegin
{
    [WizNotificationCenter postWizGlobalSyncProcessInfoWithData:MessageTypeSyncUploadDeletedList total:1 current:0];
}
+ (void) postSyncDownloadDeletedListEnd
{
    [WizNotificationCenter postWizGlobalSyncProcessInfoWithData:MessageTypeSyncUploadDeletedList total:1 current:1];
}
+ (void) postSyncUploadDeletedListBegin
{
    [WizNotificationCenter postWizGlobalSyncProcessInfoWithData:MessageTypeSyncDownloadDeletedList total:1 current:0];
}

+(void) postSyncUploadDeletedListEnd
{
    [WizNotificationCenter postWizGlobalSyncProcessInfoWithData:MessageTypeSyncDownloadDeletedList total:1 current:1];
}

+ (void) postSyncGetDocumentByCategoryBegin
{
    [WizNotificationCenter postWizGlobalSyncProcessInfoWithData:MessageTypeSyncGetDocumentListByFolder total:1 current:0];
}

+(void) postSyncGetDocumentByCategoryEnd
{
    [WizNotificationCenter postWizGlobalSyncProcessInfoWithData:MessageTypeSyncGetDocumentListByFolder total:1 current:1];
}

+ (void) postSyncGetDocumentByTagBegin
{
    [WizNotificationCenter postWizGlobalSyncProcessInfoWithData:MessageTypeSyncGetDocumentListByTag total:1 current:0];
}

+(void) postSyncGetDocumentByTagEnd
{
    [WizNotificationCenter postWizGlobalSyncProcessInfoWithData:MessageTypeSyncGetDocumentListByTag total:1 current:1];
}

+ (void) postSyncGetDocumentByKeyBegin
{
   [WizNotificationCenter postWizGlobalSyncProcessInfoWithData:MessageTypeSyncGetDocumentListByKey total:1 current:0];
}

+(void) postSyncGetDocumentByKeyEnd
{
    [WizNotificationCenter postWizGlobalSyncProcessInfoWithData:MessageTypeSyncGetDocumentListByKey total:1 current:1];
}

+ (NSString*) combinationSyncName:(NSString*)methodname  guid:(NSString*)guid
{
    return [methodname stringByAppendingFormat:@"@%@",guid];
}
+ (void) postSyncDownloadDocument:(NSString*)guid current:(int)current  total:(int)total
{
    [WizNotificationCenter postWizGlobalSyncProcessInfoWithData:[WizNotificationCenter combinationSyncName:MessageTypeSyncDownloadDocument guid:guid] total:total current:current];
}
+ (void) postSyncDownloadAttachment:(NSString*)guid current:(int)current  total:(int)total
{
    [WizNotificationCenter postWizGlobalSyncProcessInfoWithData:[WizNotificationCenter combinationSyncName:MessageTypeSyncDownloadAttachment guid:guid] total:total current:current];
}
+ (void) postSyncUploadDocument:(NSString*)guid current:(int)current  total:(int)total
{
    [WizNotificationCenter postWizGlobalSyncProcessInfoWithData:[WizNotificationCenter combinationSyncName:MessageTypeSyncUploadDocument guid:guid] total:total current:current];
}
+ (void) postSyncUploadAttachment:(NSString*)guid current:(int)current  total:(int)total
{
    [WizNotificationCenter postWizGlobalSyncProcessInfoWithData:[WizNotificationCenter combinationSyncName:MessageTypeSyncUploadAttachment guid:guid] total:total current:current];
}
+ (WizSyncMessage*) getSyncMessage:(NSNotification *)nc
{
    return [[[WizSyncMessage alloc] initWithNotification:nc] autorelease];
}
+ (void) addObserverForDownloadAttachment:(id)observer selector:(SEL)selector attachmentGUID:(NSString *)guid
{
    [WizNotificationCenter addObserverWithKey:observer selector:selector name:[WizNotificationCenter combinationSyncName:MessageTypeSyncDownloadAttachment guid:guid]];
}

+ (void) addObserverForDownloadDocument:(id)observer selector:(SEL)selector documentGUID:(NSString *)guid
{
    [WizNotificationCenter addObserverWithKey:observer selector:selector name:[WizNotificationCenter combinationSyncName:MessageTypeSyncDownloadDocument guid:guid]];
}
+ (void) removeObserverForDownloadDocument:(id)observer selector:(SEL)selector documentGUID:(NSString *)guid
{
    [WizNotificationCenter removeObserverWithKey:observer name:[WizNotificationCenter combinationSyncName:MessageTypeSyncDownloadDocument guid:guid]];
}
+ (void) removeObserverForDownloadAttachment:(id)observer selector:(SEL)selector attachmentGUID:(NSString *)guid
{
    [WizNotificationCenter removeObserverWithKey:observer name:[WizNotificationCenter combinationSyncName:MessageTypeSyncDownloadAttachment guid:guid]];
}

+ (void) addObserverForXmlRpcError:(id) observer  selector:(SEL)selector
{
    [WizNotificationCenter add
}
@end


