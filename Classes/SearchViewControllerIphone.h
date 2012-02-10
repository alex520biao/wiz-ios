//
//  SearchViewControllerIphone.h
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SearchHistoryView;
@interface SearchViewControllerIphone : UIViewController <UISearchBarDelegate, UISearchDisplayDelegate>
{
    UISearchBar* searchBar;
    UISwitch*    localSearchSwitch;
    UILabel*    localSearchSwitchString;
    UIImageView*     localsearchView;
    NSString*   accountUserId;
    NSString*   accountUserPassword;
    UIAlertView* waitAlertView;
    NSString* currentKeyWords;
    SearchHistoryView* historyView;
}
@property (nonatomic, retain)  UISearchBar* searchBar;
@property (nonatomic, retain) UISwitch*    localSearchSwitch;
@property (nonatomic, retain)  UILabel*    localSearchSwitchString;
@property (nonatomic, retain)  UIImageView*      localsearchView;
@property (nonatomic, retain) UIAlertView* waitAlertView;
@property (nonatomic, retain) NSString*   accountUserId;
@property (nonatomic, retain) NSString*   accountUserPassword;
@property (nonatomic, retain) NSString* currentKeyWords;
@property (nonatomic, retain) SearchHistoryView* historyView;
@end