//
//  WizSelectTagViewController.h
//  Wiz
//
//  Created by wiz on 12-2-3.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WizSelectTagViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate>
{
    @private
    NSMutableArray* tags;
    UISearchBar* searchBar;
    UISearchDisplayController* searchDisplayController;
    NSMutableArray* searchedTags;
    BOOL isNewTag;
    @public
    NSString* accountUserId;
    NSArray*  initSelectedTags;
}
@property (nonatomic, retain) NSMutableArray* tags;
@property (nonatomic, retain)UISearchBar* searchBar;
@property (nonatomic, retain)UISearchDisplayController* searchDisplayController;
@property (nonatomic, retain)NSString* accountUserId;
@property (nonatomic, retain)  NSArray*  initSelectedTags;
@property (nonatomic, retain) NSMutableArray* searchedTags;
@property BOOL isNewTag;
@end
