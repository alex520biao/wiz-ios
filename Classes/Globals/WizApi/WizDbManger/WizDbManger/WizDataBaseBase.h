//
//  WizDataBaseBase.h
//  Wiz
//
//  Created by wiz on 12-6-14.
//
//

#import <UIKit/UIKit.h>
#import "FMDataBase.h"
#import "FMDatabaseQueue.h"
@interface WizDataBaseBase : NSObject
{
    FMDatabaseQueue* queue;
    NSString* accountUserId;
    NSString* kbGuid;
}
@property (atomic, readonly) NSString* accountUserId;
@property (atomic, readonly) NSString* kbGuid;
@property (atomic, readonly) FMDatabaseQueue* queue;
- (WizDataBaseBase*) initWithPath:(NSString*)dbPath modelName:(NSString*)modelName;
- (WizDataBaseBase*) initWithAccountUserId:(NSString*)accountUserId_ kbGuid:(NSString*)kbGuid_    modelName:(NSString*)modelName;
@end
