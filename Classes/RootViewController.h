//
//  RootViewController.h
//  iPad
//
//  Created by Wei Shijun on 5/19/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface RootViewController : UITableViewController {
	UISplitViewController *splitViewController;
    DetailViewController *detailViewController;
	//
	NSString* accountUserId;
	NSArray* locations;
	NSArray* tags;
	//
	UIBarButtonItem* accountsButton;
	UIBarButtonItem* syncButton;
	UIBarButtonItem* activeButton;
	//
}
@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;
@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;

@property (nonatomic, retain) NSString* accountUserId;
@property (nonatomic, retain) NSArray* locations;
@property (nonatomic, retain) NSArray* tags;

@property (nonatomic, retain) UIBarButtonItem* accountsButton;
@property (nonatomic, retain) UIBarButtonItem* syncButton;
@property (nonatomic, retain) UIBarButtonItem* activeButton;


-(void) setAccount:(NSString*)userId;

- (IBAction) onManageAccounts: (id)sender;
- (IBAction) onSyncAll: (id)sender;



-(void) onSyncBegin;
-(void) onSyncEnd;



@end
