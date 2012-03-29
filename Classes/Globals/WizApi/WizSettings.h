//
//  WizSettings.h
//  Wiz
//
//  Created by Wei Shijun on 3/8/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <Foundation/Foundation.h>



extern NSString* SettingsFileName;
extern NSString* KeyOfAccounts;
extern NSString* KeyOfUserId;
extern NSString* KeyOfPassword;
#define WizNoteAppLastActiveTime @"WizNoteAppLastActiveTime"

@interface WizSettings : NSObject {
@private
	NSMutableDictionary* _dict;
}

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
//2012-2-29
+ (void) setLastActiveTime;
+ (NSDate*) lastActiveTime;
@end
