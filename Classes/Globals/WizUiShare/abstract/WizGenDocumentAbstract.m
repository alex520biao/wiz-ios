//
//  WizGenDocumentAbstract.m
//  Wiz
//
//  Created by 朝 董 on 12-4-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizGenDocumentAbstract.h"
#import "WizDbManager.h"
#import "WizAbstractData.h"
#import "WizFileManager.h"
#import "WizDecorate.h"
@interface WizGenDocumentAbstract()
{
    NSString* documentGuid;
    id<WizGenDocumentAbstractDelegate> delegate;
    WizDbManager* dbManager;
}
@property (nonatomic, retain) NSString* documentGuid;
@property (nonatomic, retain) id<WizGenDocumentAbstractDelegate> delegate;
@property (nonatomic, retain) WizDbManager* dbManager;
@end
@implementation WizGenDocumentAbstract
@synthesize documentGuid;
- (void) dealloc
{
    [delegate release];
    [documentGuid release];
    [dbManager release];
    [super dealloc];
}
- (id) initWithDegeate:(NSString*)documentGuid_ delegate:(id<WizGenDocumentAbstractDelegate>)delegate_
{
    self = [super init];
    if (self) {
        self.documentGuid = documentGuid_;
        self.delegate = delegate_;
        WizDbManager* db = [[WizDbManager alloc] init];
        [db openDb:[[WizFileManager shareManager] dbPath]];
        [db openTempDb:[[WizFileManager shareManager] tempDbPath]];
        self.dbManager = db;
        [db release];
    }
    return self;
}
- (void) start
{
    
    NSLog(@"%@",self.documentGuid);
    WizDocument* doc = [self.dbManager documentFromGUID:self.documentGuid];
    if (nil == doc) {
        return;
    }
    if(!doc.serverChanged)
    {
        [self.dbManager extractSummary:self.documentGuid];
    }
    WizAbstract*   abstract = [self.dbManager  abstractOfDocument:doc.guid];
    NSLog(@"((((((( %d %d ",[self.dbManager isOpen], [self.dbManager isTempDbOpen]);
    NSString* titleStr = doc.title;
    NSString* detailStr=@"";
    NSString* timeStr = @"";
    UIImage* abstractImage = nil;
    NSUInteger kOrderIndex = [self.dbManager userTablelistViewOption];
    if (kOrderIndex == kOrderCreatedDate || kOrderIndex == kOrderReverseCreatedDate) {
        timeStr = [doc.dateCreated  stringLocal];
    }
    else {
        timeStr = [doc.dateModified stringLocal];
    }
    NSLog(@"document abstract is %@",abstract.text);
    timeStr = [timeStr stringByAppendingFormat:@"\n"];
    detailStr = abstract.text;
    abstractImage = abstract.image;
    titleStr = [WizDecorate nameToDisplay:titleStr width:400];
    titleStr = [titleStr stringByAppendingFormat:@"\n"];
    NSMutableAttributedString* nameAtrStr = [[NSMutableAttributedString alloc] initWithString:titleStr attributes:[WizDecorate getNameAttributes]];
    NSAttributedString* timeAtrStr = [[NSAttributedString alloc] initWithString:timeStr attributes:[WizDecorate getTimeAttributes]];
    NSAttributedString* detailAtrStr = [[NSAttributedString alloc] initWithString:detailStr attributes:[WizDecorate getDetailAttributes]];
    [nameAtrStr appendAttributedString:timeAtrStr];
    [nameAtrStr appendAttributedString:detailAtrStr];
    WizAbstractData* absData = [[WizAbstractData alloc] init];
    absData.text = nameAtrStr;
    absData.image = abstractImage;
    [timeAtrStr release];
    [detailAtrStr release];
    [nameAtrStr release];
    [self.delegate didGenDocumentAbstract:self.documentGuid abstractData:[absData autorelease]];
}
@end
