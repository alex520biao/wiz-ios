//
//  WizGroup.h
//  Wiz
//
//  Created by 朝 董 on 12-6-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#define KeyOfKbKbguid               @"kb_guid"
#define KeyOfKbType                 @"kb_type"
#define KeyOfKbImage                @"KeyOfKbImage"
#define KeyOfKbAbstractString       @"KeyOfKbAbstractString"
#define KeyOfKbName                 @"kb_name"


#define KeyOfKbTypePrivate          @"private"
#define KeyOfKbTypeGroup            @"group"
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
@property (nonatomic, retain) NSNumber * orderIndex;
- (void) getDataFromDic:(NSDictionary*)dic;
@end
