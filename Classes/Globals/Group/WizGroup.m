//
//  WizGroup.m
//  Wiz
//
//  Created by 朝 董 on 12-6-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizGroup.h"
<<<<<<< Updated upstream
#import <Foundation/Foundation.h>
#import "NSDate+WizTools.h"
=======
>>>>>>> Stashed changes


@implementation WizGroup

<<<<<<< Updated upstream
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

- (NSInteger) getCurrentUserRight
{
    return [self.userGroup integerValue];
}
- (BOOL) canEditCurrentDocument
{
    NSInteger right = [self.userGroup integerValue];
    if (right <= 100 ) {
        return YES;
    }
    return NO;
}
- (BOOL) canEditDocument
{
    NSInteger right = [self.userGroup integerValue];
    if (right <= 50 ) {
        return YES;
    }
    return NO;
}
- (BOOL) canEditTag
{
    NSInteger right = [self.userGroup integerValue];
    if (right <= 10 ) {
        return YES;
    }
    return NO;
}
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
=======
@dynamic dateCreated;
@dynamic userGroup;
@dynamic serverUrl;
@dynamic roleNote;
@dynamic ownerName;
@dynamic kbType;
@dynamic kbSeo;
@dynamic kbNote;
@dynamic kbName;
@dynamic kbId;
@dynamic kbguid;
@dynamic dateRoleCreated;
@dynamic dateModified;
@dynamic accountUserId;

>>>>>>> Stashed changes
@end
