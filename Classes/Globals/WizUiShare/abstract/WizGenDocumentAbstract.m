//
//  WizGenDocumentAbstract.m
//  Wiz
//
//  Created by 朝 董 on 12-4-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizGenDocumentAbstract.h"
#import "WizDbManager.h"
#import "WizFileManager.h"
#import "WizDecorate.h"
@interface WizGenDocumentAbstract()
{
    id<WizGenDocumentAbstractDelegate> delegate;
    WizDbManager* dbManager;
}
@property (nonatomic, retain) id<WizGenDocumentAbstractDelegate> delegate;
@property (nonatomic, retain) WizDbManager* dbManager;
@end
@implementation WizGenDocumentAbstract
@synthesize dbManager;
@synthesize delegate;
@synthesize isChangedUser;
- (void) dealloc
{
    [delegate release];
    [dbManager release];
    [super dealloc];
}
- (id) initWithDelegate:(id<WizGenDocumentAbstractDelegate>)delegate_
{
    self = [super init];
    if (self) {
        self.delegate = delegate_;
        WizDbManager* db = [[WizDbManager alloc] init];
        self.dbManager = db;
        [db release];
        self.isChangedUser = YES;
    }
    return self;
}
- (void) checkDb
{
    if (self.isChangedUser) {
        [self.dbManager closeTempDb];
        [self.dbManager openTempDb:[[WizFileManager shareManager] tempDbPath]];
        self.isChangedUser = NO;
    }
}
- (void) start
{
    [self checkDb];
    NSString* documentGuid = [self.delegate popNeedGenAbstrctDocument];
    if (nil != documentGuid) {
        WizAbstract* abstract = nil;
        abstract = [self.dbManager  abstractOfDocument:documentGuid];
        [self.delegate didGenDocumentAbstract:documentGuid abstractData:abstract];
    }
    else {
        sleep(1000);
    }
}
@end
