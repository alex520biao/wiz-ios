//
//  WizSettings.m
//  Wiz
//
//  Created by Wei Shijun on 3/8/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "WizSettings.h"
#import "WizGlobals.h"
#import "WizIndex.h"

static WizSettings* g_settings = nil;


NSString* SettingsFileName = @"settings.plist";
NSString* KeyOfAccounts = @"accounts";
NSString* KeyOfUserId = @"userId";
NSString* KeyOfPassword = @"password";
NSString* KeyOfDefaultUserId = @"defaultUserId";

static NSString* KeyOfProtectPassword = @"protectPassword";
@implementation WizSettings

-(id) init
{
	if (self = [super init])
	{
		NSString* filename = [WizSettings settingsFileName];
		//
		_dict = [NSMutableDictionary dictionaryWithContentsOfFile:filename];
        NSLog(@"%@",_dict);
		if (_dict == nil)
		{
			_dict = [[NSMutableDictionary alloc] init];
		}
		[_dict retain];
	}
	return self;
}
-(void)dealloc
{
	[_dict release];
	[super dealloc];
}

-(NSMutableDictionary *)dict
{
	return _dict;
}

+(NSString*) settingsFileName
{
	NSString* filename = [[WizGlobals documentsPath] stringByAppendingPathComponent:SettingsFileName];
	return filename;
}
+(WizSettings *) sharedSettings
{
	if (g_settings == nil)
	{
		g_settings = [[WizSettings alloc] init];
	}
	//
	return g_settings;
}

+(id) readSettings: (NSString*)key
{
	NSDictionary* dict = [[WizSettings sharedSettings] dict];
	return [dict objectForKey:key];
}

+(void) writeSettings: (NSString*)key value:(id)value
{
	NSMutableDictionary* dict = [[WizSettings sharedSettings] dict];
	[dict setValue:value forKey:key];
	//
	NSString* filename = [WizSettings settingsFileName];
	[dict writeToFile:filename atomically:YES];
}

+(NSArray*) accounts
{
	id ret = [WizSettings readSettings:KeyOfAccounts];
	if (ret == nil)
	{
		ret = [NSArray array];
	}
	//
	if ([ret isKindOfClass:[NSArray class]])
	{
		return ret;
	}
	return nil;
}
+(int) accountCount
{
	return [[WizSettings accounts] count];
}
+(NSString*) accountUserIdAtIndex: (NSArray*)accounts index: (int)index
{
	return [[accounts objectAtIndex:index] valueForKey:KeyOfUserId];
}
+(NSString*) accountPasswordAtIndex: (NSArray*)accounts index: (int)index
{
	return [[accounts objectAtIndex:index] valueForKey:KeyOfPassword];
}

+(NSString*) accountPasswordByUserId:(NSString *)userID
{
	int index = [WizSettings findAccount:userID];
	if (-1 == index)
		return nil;
	//
	NSArray* accounts = [WizSettings accounts];
	//
	return [WizSettings accountPasswordAtIndex:accounts index:index];
}
+(void) setAccounts: (NSArray*)accounts
{
	[WizSettings writeSettings:KeyOfAccounts value:accounts];
}

+(void) setDefalutAccount:(NSString*)accountUserId;
{
    [WizSettings writeSettings:KeyOfDefaultUserId value:accountUserId];
}
+ (void) setLastActiveTime
{
    NSDate* date = [NSDate date];
    [WizSettings writeSettings:WizNoteAppLastActiveTime value:date];
}
+ (NSDate*) lastActiveTime
{
    id activeTime = [WizSettings readSettings:WizNoteAppLastActiveTime];
    if (activeTime != nil && [activeTime isKindOfClass:[NSDate class]]) {
        return (NSDate*)activeTime;
    }
    else {
        return [NSDate date];
    }
}
+ (NSString*) defaultAccountUserId
{
    id userId = [WizSettings readSettings:KeyOfDefaultUserId];
    if (userId != nil && [userId isKindOfClass:[NSString class]]) {
        return (NSString*)userId;
    }
    else
    {
        return @"";
    }
    
}
+  (NSArray*) accountsUserIdArray
{
    NSArray* accounts= [WizSettings accounts];
    NSMutableArray* arr = [NSMutableArray array];
    for (NSDictionary* each in accounts) {
        NSString* userId = [each valueForKey:KeyOfUserId];
        if (userId != nil) {
            [arr addObject:userId];
        }
    }
    return arr;
}
+(void) addAccount: (NSString*)userId password:(NSString*)password
{
	if (-1 != [WizSettings findAccount:userId])
	{
		[WizSettings changeAccountPassword:userId password:password];
		return;
	}
	NSArray* exitsAccounts = [WizSettings accounts];
	//
    if (![WizGlobals checkPasswordIsEncrypt:password]) {
        password = [WizGlobals encryptPassword:password];
    }
    //
	NSDictionary* account = [NSDictionary dictionaryWithObjectsAndKeys:userId, KeyOfUserId, password, KeyOfPassword, nil];
	//
	NSMutableArray* newAccounts = [NSMutableArray arrayWithArray:exitsAccounts];
	[newAccounts addObject:account];
	//
	[WizSettings setAccounts:newAccounts];
}
+ (NSString*) accountProtectPassword
{
    id password = [WizSettings readSettings:KeyOfProtectPassword];
    if (password != nil && [password isKindOfClass:[NSString class]]) {
        return password;
    }
    else
    {
        return @"";
    }
}

+ (void) setAccountProtectPassword:(NSString*)password
{
    [WizSettings writeSettings:KeyOfProtectPassword value:password];
}

+(void) changeAccountPassword: (NSString*)userId password:(NSString*)password
{
	int index = [WizSettings findAccount:userId];
	if (-1 == index)
		return;
	//
	NSArray* exitsAccounts = [WizSettings accounts];
    //
    if (![WizGlobals checkPasswordIsEncrypt:password]) {
        password = [WizGlobals encryptPassword:password];
    }
	NSDictionary* account = [NSDictionary dictionaryWithObjectsAndKeys:userId, KeyOfUserId, password , KeyOfPassword, nil];
	//
	NSMutableArray* newAccounts = [NSMutableArray arrayWithArray:exitsAccounts];
	[newAccounts removeObjectAtIndex:index];
	[newAccounts insertObject:account atIndex:index];
	//
	[WizSettings setAccounts:newAccounts];
}
+ (void) logoutAccount:(NSString*)userId
{
    [WizSettings setDefalutAccount:@""];
}

+(void) removeAccount: (NSString*)userId
{
    int index = [WizSettings findAccount:userId];
	if (-1 == index)
		return;
	NSArray* exitsAccounts = [WizSettings accounts];
    NSString* defaultAccount = [WizSettings defaultAccountUserId];
    if ([defaultAccount isEqualToString:userId]) {
        [WizSettings setDefalutAccount:@""];
    }
	NSMutableArray* newAccounts = [NSMutableArray arrayWithArray:exitsAccounts];
	[newAccounts removeObjectAtIndex:index];
    [WizSettings setAccounts:newAccounts];
    [[NSFileManager defaultManager] removeItemAtPath:[WizIndex accountPath:userId]  error:nil];
}
+(int) findAccount: (NSString*)userId
{
	NSArray* accounts = [WizSettings accounts];
	for (int i = 0; i < [accounts count]; i++)
	{
		id object = [accounts objectAtIndex:i];
		
		if ([object isKindOfClass:[NSDictionary class]])
		{
			NSDictionary* account = object;
			//
			NSString* userIdExists = [account objectForKey:KeyOfUserId];
			if (userId != nil)
			{
				if (NSOrderedSame == [userIdExists compare:userId options: NSCaseInsensitiveSearch])
				{
					return i;
				}
			}
		}
	}
	//
	return -1;
}


@end
