//
//  DetailViewController.h
//  WIz
//
//  Created by 朝 董 on 12-3-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (copy, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
