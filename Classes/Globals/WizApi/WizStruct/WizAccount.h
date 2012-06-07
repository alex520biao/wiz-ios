//
//  WizAccount.h
//  Wiz
//
//  Created by 朝 董 on 12-6-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WizAccount : NSObject
{
    NSString* userId;
    NSString* password;
    NSArray* groups;
}
@property (atomic, retain) NSString* userId;
@property (atomic, retain) NSString* password;
@property (atomic, retain) NSArray* groups;
- (WizAccount*) initWithUserId:(NSString*)userId_  password:(NSString*)password_  kgguids:(NSArray*)kbguids_;
- (WizAccount*) initAccountFromDic:(NSDictionary*)dic;
- (NSDictionary*) accountDictionaryData;
- (BOOL) isEqualToAccountDictionaryData:(NSDictionary*)data;
- (void) updateWizGroup:(WizGroup*)group;
- (BOOL) registerActiveKbguid:(WizGroup *)kb;
- (WizGroup*) activeGroup;

@end
