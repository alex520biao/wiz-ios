//
//  WizAccountManager.m
//  Wiz
//
//  Created by 朝 董 on 12-4-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizAccountManager.h"
#import "WizAccount.h"
#import "WizAccountDataBase.h"

#import "WizGlobalData.h"
#import "WizSyncManager.h"
#import "WizFileManager.h"
#import "WizDbManager.h"
#import "WizNotification.h"
#import "WizAbstractCache.h"
#import "WizAccountDataBase.h"


#define SettingsFileName            @"settings.plist"
#define KeyOfAccounts               @"accounts"
#define KeyOfUserId                 @"userId"
#define KeyOfPassword               @"password"
#define KeyOfDefaultUserId          @"defaultUserId"
#define KeyOfProtectPassword        @"protectPassword"
#define KeyOfKbguids                @"KeyOfKbguids"



//
@interface WizAccountManager()
{
    WizAccount* activeAccount_;
    WizGroup*  activeGroup;
    NSTimer* timer;
    WizAccountDataBase* dataBase;
}
@property (nonatomic, retain) NSTimer* timer;
@property (nonatomic, retain) WizAccount* activeAccount_;
@property (nonatomic, retain) WizAccountDataBase* dataBase;
<<<<<<< Updated upstream
@property (nonatomic, retain) WizGroup*  activeGroup;
=======
>>>>>>> Stashed changes
@end

@implementation WizAccountManager
@synthesize timer;
@synthesize activeAccount_;
@synthesize dataBase;
<<<<<<< Updated upstream
@synthesize activeGroup;
@dynamic  accountSettingsDataBase;
- (NSFetchedResultsController*) groupsFetchResultController
{
    return [self.dataBase allGroupsFectchRequest:self.activeAccount_.userId];
}
- (WizAccountDataBase<WizSettingsDbDelegate>*) accountSettingsDataBase
=======
-(NSString*) settingsFileName
>>>>>>> Stashed changes
{
    return self.dataBase;
}

-(id) init
{
	if (self = [super init])
	{
<<<<<<< Updated upstream
        dataBase = [[WizAccountDataBase alloc] init];
=======
		NSString* filename = [self settingsFileName];
		dict = [NSMutableDictionary dictionaryWithContentsOfFile:filename];
		if (dict == nil)
		{
			dict = [[NSMutableDictionary alloc] init];
		}
		[dict retain];
        dataBase = [[WizAccountDataBase alloc] init];
        [dataBase saveContext];
>>>>>>> Stashed changes
	}
	return self;
}
-(void)dealloc
{
	[super dealloc];
}

+(WizAccountManager *) defaultManager
{
	return [[WizGlobalData sharedData] defaultAccountManager];
}

- (WizAccount*) activeAccount
{
    return self.activeAccount_;
}

-(void) updateAccount: (NSString*)userId password:(NSString*)password
{
    password = [WizGlobals encryptPassword:password];
    [self.dataBase updateAccount:userId password:password];
    if (self.activeAccount_) {
        if ([self.activeAccount_.userId isEqualToString:userId]) {
            self.activeAccount_ = [self.dataBase accountFromDataBase:userId];
        }
    }
}


-(void) changeAccountPassword: (NSString*)userId password:(NSString*)password
{

}
- (NSString*) activeAccountPassword
{
    return self.activeAccount_.password;
}
- (NSString*) activeAccountUserId
{
    return self.activeAccount_.userId;
}
- (void) logoutAccount
{

}


-(void) removeAccount: (NSString*)userId
{

}

- (NSArray*) accounts
{
    NSMutableArray* array = [NSMutableArray array];
    NSArray* ex = [self.dataBase allAccounts];
    for (WizAccount* each in ex) {
        NSLog(@"each %@ %@ %@",each, each.userId, each.password);
        [array addObject:each.userId];
    }
    return array;
}


- (void) registerActiveAccount:(NSString *)accountUserId
{
    self.activeAccount_ = [self.dataBase accountFromDataBase:accountUserId];
    [self.dataBase setWizDefaultAccountUserId:self.activeAccount_.userId];
    [[WizSyncManager shareManager] refreshToken];
}
- (void) updateGroup:(NSDictionary *)dic
{
    [self.dataBase updateGroup:dic userId:self.activeAccount_.userId];
}

- (void) updateGroups:(NSArray*)groupArray
{
    [self.dataBase deleteAllGroups:self.activeAccount_.userId];
    for (NSDictionary* each in groupArray) {
        [self updateGroup:each];
    }
    [WizNotificationCenter postSimpleMessageWithName:MessageTypeOfRefreshGroupsData];
}
- (NSArray*) activeAccountGroups
{
   return  [self.dataBase allGroupByAccount:self.activeAccount_.userId];
}
- (NSString*) activeAccountGroupKbguid
{
    return self.activeGroup.kbguid;
}
- (void) registerActiveGroup:(WizGroup*)group
{
    [[WizSyncManager shareManager] registerAciveGroup:group.kbguid];
    self.activeGroup = group;
}
- (WizGroup*)activeAccountActiveGroup
{
    return self.activeGroup;
}

- (NSString*)defualtAccountUserId
{
    return [self.dataBase defaultAccountUserId];
}

@end
