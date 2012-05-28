//
//  SearchViewControllerIphone.h
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchHistoryView.h"
#import "WizSyncSearchDelegate.h"
@interface SearchViewControllerIphone : UIViewController <WizSyncSearchDelegate,UISearchBarDelegate, UISearchDisplayDelegate,WizSearchHistoryDelegate>

@end