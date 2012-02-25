//
//  PickerViewController2.h
//  Wiz
//
//  Created by dong zhao on 11-11-25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RecentDcoumentListView;
@class FoldersViewControllerNew;
@class TagsListTreeControllerNew;
@interface PickerViewController : UITabBarController <UINavigationControllerDelegate> {
    NSString* accountUserId; 
}
@property (nonatomic, retain)  NSString* accountUserId;
- (id) initWithUserID:(NSString*) accountUserID;
-(void) newNote;

@end
