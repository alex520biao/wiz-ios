//
//  SelectFloderView.h
//  Wiz
//
//  Created by dong zhao on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SelectFloderView : UITableViewController <UISearchBarDelegate,UISearchDisplayDelegate>{
    NSMutableArray* allFloders;
    NSMutableArray*       selectedFloder;
    NSString*       accountUserID;
    NSMutableString*       selectedFloderString;
    
    UISearchBar* searchBar;
    UISearchDisplayController* searchDisplayController;
    NSArray* searchedFolder;
}
@property (nonatomic, retain) NSMutableArray* allFloders;
@property (nonatomic, retain) NSMutableArray* selectedFloder;
@property (nonatomic, retain) NSString*       accountUserID;
@property (nonatomic, retain) NSMutableString*       selectedFloderString;
@property (nonatomic, retain) UISearchBar* searchBar;
@property (nonatomic, retain) UISearchDisplayController* searchDisplayController;
@property (nonatomic, retain) NSArray* searchedFolder;
@end
