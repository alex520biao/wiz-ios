//
//  WizPadAllNotesViewController.h
//  Wiz
//
//  Created by wiz on 12-8-16.
//
//

#import <UIKit/UIKit.h>

@interface WizPadAllNotesViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, retain) IBOutlet  UITableView* masterTableView;
@property (nonatomic, retain) IBOutlet  UITableView* detailTableView;
@end
