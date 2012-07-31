//
//  WizRefreshToken.m
//  Wiz
//
//  Created by 朝 董 on 12-4-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizRefreshToken.h"
#import "WizNotification.h"
#import "WizGlobalData.h"
#import "WizSettings.h"
#import "WizAccountManager.h"
#import "WizFileManager.h"

@implementation WizRefreshToken
@synthesize refreshDelegate;
- (void) dealloc
{
    refreshDelegate = nil;
    [super dealloc];
}
- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        for (UIView* each in [alertView subviews]) {
            if ([each isKindOfClass:[UITextField class]]) {
                NSString* password = ((UITextField*)each).text;
                WizAccountManager* accountManager = [WizAccountManager defaultManager];
                NSString* userId = [accountManager activeAccountUserId];
                [accountManager changeAccountPassword:userId password:password];
                [self start];
            }
        }
    }
    else
    {
        [self.apiManagerDelegate didApiSyncError:self error:[WizGlobalError cancelFixPasswordError]];
    }
}
- (void) onError:(id)retObject
{
    busy = NO;
    NSError* error = (NSError*)retObject;
    NSLog(@"refresh token error %@",retObject);
    if (error.code == CodeOfTokenUnActiveError && [error.domain isEqualToString:WizErrorDomain]) {
        
        UIAlertView* prompt = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Invalid password!", nil)
                                            message:@"\n\n" 
                                           delegate:nil 
                                  cancelButtonTitle:WizStrCancel 
                                  otherButtonTitles:WizStrOK, nil];
        prompt.tag = 10001;
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(27.0, 60.0, 230.0, 25.0)]; 
        textField.secureTextEntry = YES;
        [textField setBackgroundColor:[UIColor whiteColor]];
        [textField setPlaceholder:WizStrPassword];
        [prompt addSubview:textField];
        [textField release];
        [prompt setTransform:CGAffineTransformMakeTranslation(0.0, -100.0)];
        prompt.delegate = self;
        [prompt show];
        return;
    }
    [super onError:retObject];
}
- (BOOL) start
{
    if (self.busy) {
        return NO;
    }
    busy = YES;
    NSString* accountUserId = [[WizAccountManager defaultManager] activeAccountUserId];
    NSString* password  = [[WizAccountManager defaultManager] accountPasswordByUserId:accountUserId];
    NSLog(@"%@",password);
    return [self callClientLogin:accountUserId accountPassword:password];
}
-(void) onClientLogin: (id)retObject
{
    busy = NO;
	if ([retObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary* userInfo = retObject;
        NSNumber* userPoints = [userInfo objectForKey:@"user_points"];
        NSNumber* userLevel = [userInfo objectForKey:@"user_level"];
        NSString* userLevelName = [userInfo objectForKey:@"user_level_name"];
        NSString* userType = [userInfo objectForKey:@"user_type"];
        NSDictionary* userData = [userInfo objectForKey:@"user"];
        NSString* userEmail = [userData objectForKey:@"email"];
        NSLog(@"userEmail is %@",userEmail);
        if (![[userEmail lowercaseString] isEqualToString:[[WizAccountManager defaultManager]activeAccountUserId]]) {
            [self.apiManagerDelegate didApiSyncDone:self];
            return;
        }
        WizSettings* defalutSettings = [WizSettings defaultSettings];
        [defalutSettings setUserPoints:[userPoints longLongValue]];
        [defalutSettings setUserLevel:[userLevel longLongValue]];
        [defalutSettings setUserLevelName:userLevelName];
        [defalutSettings setUserType:userType];
        [self.refreshDelegate didRefreshToken:retObject];
        NSString* _token = [userInfo valueForKey:@"token"];
        NSURL* urlAPI = [[NSURL alloc] initWithString:[userInfo valueForKey:@"kapi_url"]];
        self.token = _token;
        self.apiURL = urlAPI;
        [urlAPI release];
    }
    
}
- (void) cancel
{
    [super cancel];
    self.refreshDelegate = nil;
}
@end
