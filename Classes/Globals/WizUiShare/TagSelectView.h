//
//  TagSelectView.h
//  Wiz
//
//  Created by dong zhao on 11-11-14.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WizDocument;

@interface TagSelectView : UITableViewController <UISearchBarDelegate>{
    NSMutableArray* select;
    NSMutableArray* tags;
    NSMutableArray* tagsSearch;
    NSMutableArray* tagsWillAdd;
    NSString*       accountUserId;
    UISearchBar*    searchBar;
    UISearchDisplayController* search;
    int             selectCount;
    BOOL            isNewTag;
    NSMutableString* documentTagsGUID;
    
}
@property (nonatomic, retain) NSMutableArray*               select;
@property (nonatomic, retain) NSMutableArray*               tags;
@property (nonatomic, retain) NSString*                     accountUserId;
@property (nonatomic, retain) UISearchBar*                  searchBar;
@property (nonatomic, retain) UISearchDisplayController*    search;
@property (nonatomic, retain) NSMutableArray*               tagsSearch;
@property (nonatomic, retain) NSMutableArray*               tagsWillAdd;
@property (nonatomic, retain) NSMutableString*              documentTagsGUID;
@property int selectCount;
@property (assign) BOOL isNewTag;

@end
