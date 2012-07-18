//
//  WizGetAbstractOperation.m
//  Wiz
//
//  Created by wiz on 12-7-17.
//
//

#import "WizGetAbstractOperation.h"
#import "WizDbManager.h"
#import "WizAccountManager.h"

@interface WizGetAbstractOperation ()
{
    NSString* documentGuid;
}
@end

@implementation WizGetAbstractOperation
@synthesize storeDelegate;

- (void) dealloc
{
    [documentGuid release];
    storeDelegate = nil;
    [super dealloc];
}

- (id) initWithGuid:(NSString*)guid  storeDelegate:(id<WizAbstractStoreDelegate>)sDelegate
{
    self = [super init];
    if (self) {
        documentGuid = [guid copy];
        storeDelegate = sDelegate;
    }
    return self;
}
- (void) main
{
    if (nil == documentGuid || nil == storeDelegate) {
        return;
    }
    WizAccountManager* accountManager = [WizAccountManager defaultManager];
    NSString* activeAccountUserId = [accountManager activeAccountUserId];
    if (activeAccountUserId == nil) {
        return;
    }
    id<WizAbstractDbDelegate> dataBase = [[WizDbManager shareDbManager] getWizTempDataBase:activeAccountUserId];
    WizAbstract* abstract = [dataBase abstractOfDocument:documentGuid];
    [self.storeDelegate storeDocumentAbstract:documentGuid abstract:abstract];
}
@end
