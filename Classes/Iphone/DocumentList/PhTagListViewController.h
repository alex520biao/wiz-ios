//
//  PhTagListViewController.h
//  Wiz
//
//  Created by 朝 董 on 12-5-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizTableViewController.h"

@interface PhTagListViewController : WizTableViewController
{
    NSString* tagGuid;
}
@property (nonatomic, retain) NSString* tagGuid;
- (id) initWithTagGuid:(NSString*)guid;
@end
