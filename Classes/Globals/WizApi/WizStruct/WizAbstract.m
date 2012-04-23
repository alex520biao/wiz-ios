//
//  WizAbstract.m
//  Wiz
//
//  Created by 朝 董 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizAbstract.h"
#import "WizDbManager.h"

@implementation WizAbstract
@synthesize image;
@synthesize text;
+ (WizAbstract*) abstractFromDb:(NSString*)guid
{
    WizDbManager* share = [WizDbManager shareDbManager];
    return [share abstractOfDocument:guid];
}
@end
