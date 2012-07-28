//
//  PhFolderListViewController.h
//  Wiz
//
//  Created by 朝 董 on 12-5-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizTableViewController.h"

@interface PhFolderListViewController : WizTableViewController
{
    NSString* folder;
}
@property (nonatomic, retain) NSString* folder;
- (id) initWithFolder:(NSString*)folder_;
@end
