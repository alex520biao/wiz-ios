//
//  SearchViewControllerIphone.h
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchHistoryView.h"
@class SearchHistoryView;
@interface SearchViewControllerIphone : UIViewController <UISearchBarDelegate, UISearchDisplayDelegate,WizSearchHistoryDelegate>

@end