//
//  WizSelectTagViewController.h
//  Wiz
//
//  Created by wiz on 12-2-3.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol WizSelectTagDelegate <NSObject>
- (NSArray*) selectedTagsOld;
- (void) didSelectedTags:(NSArray*)tags;
@end
@interface WizSelectTagViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate>
{
    id<WizSelectTagDelegate> selectDelegate;
}
@property (nonatomic, retain) id<WizSelectTagDelegate> selectDelegate;
@end
