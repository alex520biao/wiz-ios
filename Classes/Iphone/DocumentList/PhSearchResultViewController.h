//
//  PhSearchResultViewController.h
//  Wiz
//
//  Created by 朝 董 on 12-5-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizTableViewController.h"

@interface PhSearchResultViewController : WizTableViewController

{
    NSArray* resultArray;
}
@property (nonatomic, retain) NSArray* resultArray;
- (id) initWithResultArray:(NSArray*)array;
@end
