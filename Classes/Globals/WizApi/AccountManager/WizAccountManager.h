//
//  WizAccountManager.h
//  Wiz
//
//  Created by 朝 董 on 12-4-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WizAccountManager : NSObject

-(id) init;
-(void)dealloc;
+  (NSArray*) accountsUserIdArray;
+ (void) logoutAccount:(NSString*)userId;
+(NSString*) settingsFileName;
+(WizSettings *) sharedSettings;
+(id) readSettings: (NSString*)key;
+(void) writeSettings: (NSString*)key value:(id)value;

+(NSArray*) accounts;
+(NSString*) accountUserIdAtIndex: (NSArray*)accounts index:(int)index;
+(NSString*) accountPasswordAtIndex: (NSArray*)accounts index:(int)index;
+(NSString*) accountPasswordByUserId: (NSString *)userID;
+(void) setAccounts: (NSArray*)accounts;
+(void) addAccount: (NSString*)userId password:(NSString*)password;
+(void) changeAccountPassword: (NSString*)userId password:(NSString*)password;
+(void) removeAccount: (NSString*)userId;
+(int) findAccount: (NSString*)userId;
+(void) setDefalutAccount:(NSString*)accountUserId;
+(NSString*) defaultAccountUserId;
+ (NSString*) accountProtectPassword;
+ (void) setAccountProtectPassword:(NSString*)password;

@end
