//
//  WizGroup.h
//  Wiz
//
//  Created by 朝 董 on 12-6-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface WizGroup : NSManagedObject

@property (nonatomic, retain) NSString * accountUserId;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) NSDate * dateRoleCreated;
@property (nonatomic, retain) NSString * kbguid;
@property (nonatomic, retain) NSString * kbId;
@property (nonatomic, retain) NSString * kbName;
@property (nonatomic, retain) NSString * kbNote;
@property (nonatomic, retain) NSString * kbSeo;
@property (nonatomic, retain) NSString * kbType;
@property (nonatomic, retain) NSString * ownerName;
@property (nonatomic, retain) NSString * roleNote;
@property (nonatomic, retain) NSString * serverUrl;
@property (nonatomic, retain) NSNumber * userGroup;

@end
