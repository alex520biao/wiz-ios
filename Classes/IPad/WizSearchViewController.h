//
//  WizSearchViewController.h
//  Wiz
//
//  Created by wiz on 12-2-7.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WizSearchViewController : UITableViewController <UISearchBarDelegate,UISearchDisplayDelegate>
{
    UISearchBar* searchBar;
    UISearchDisplayController* searchDisplayController;
}
@property (nonatomic, retain) UISearchDisplayController* searchDisplayController;
@property (nonatomic, retain) UISearchBar* searchBar;
@end
