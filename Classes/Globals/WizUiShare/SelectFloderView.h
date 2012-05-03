//
//  SelectFloderView.h
//  Wiz
//
//  Created by dong zhao on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol WizFolderSelectDelegate;
@interface SelectFloderView : UITableViewController <UISearchBarDelegate,UISearchDisplayDelegate>
{
    id<WizFolderSelectDelegate> selectDelegate;
}
@property (nonatomic, retain) id<WizFolderSelectDelegate> selectDelegate;
@end
