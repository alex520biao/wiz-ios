//
//  WizDocumentFactory.m
//  Wiz
//
//  Created by 朝 董 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizDocumentFactory.h"
#import "WizDbManager.h"
@implementation WizDocumentFactory
+ (NSArray*) recentDocuments
{
    WizDbManager* share = [WizDbManager shareDbManager];
    return [share recentDocuments];
}
+ (NSArray*) documentsByTag: (NSString*)tagGUID
{
    WizDbManager* share = [WizDbManager shareDbManager];
    return [share documentsByTag:tagGUID];
}
+ (NSArray*) documentsByKey: (NSString*)keywords
{
    WizDbManager* share = [WizDbManager shareDbManager];
    return [share documentsByKey:keywords];
}
+ (NSArray*) documentsByLocation: (NSString*)parentLocation
{
    WizDbManager* share = [WizDbManager shareDbManager];
    return [share documentsByLocation:parentLocation];
}
+ (NSArray*) documentForUpload
{
    WizDbManager* share = [WizDbManager shareDbManager];
    return [share documentForUpload];
}
+ (WizDocument*) documentFromGuid:(NSString*)guid
{
    WizDbManager* share = [WizDbManager shareDbManager];
    return [share documentFromGUID:guid];
}
@end
