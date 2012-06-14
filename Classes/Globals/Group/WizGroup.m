//
//  WizGroup.m
//  Wiz
//
//  Created by 朝 董 on 12-6-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizGroup.h"
#import <Foundation/Foundation.h>
#import "NSDate+WizTools.h"


@implementation WizGroup

@dynamic accountUserId;
@dynamic dateCreated;
@dynamic dateModified;
@dynamic dateRoleCreated;
@dynamic kbguid;
@dynamic kbId;
@dynamic kbName;
@dynamic kbNote;
@dynamic kbSeo;
@dynamic kbType;
@dynamic ownerName;
@dynamic roleNote;
@dynamic serverUrl;
@dynamic userGroup;
@dynamic orderIndex;

- (void) getDataFromDic:(NSDictionary*)dic
{
    self.kbguid = [dic valueForKey:KeyOfKbKbguid];
    NSString* name = [dic valueForKey:KeyOfKbName];
    
    if (!name) {
        name = NSLocalizedString(@"My Data", nil);
    }
    self.kbName = name;
    NSString* type = [dic valueForKey:KeyOfKbType];
    if (!type) {
        type = KeyOfKbTypePrivate;
    }
    NSNumber* right = [dic valueForKey:KeyOfKbRight];
    if (!right)
    {
        self.userGroup = [NSNumber numberWithInt:WizGroupUserRightAll];
    }
    else
    {
        self.userGroup = [NSNumber numberWithInt:[right intValue]];
    }
   self.kbType = type;
}
@end
