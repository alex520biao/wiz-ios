//
//  DetailViewController.h
//  iPad
//
//  Created by Wei Shijun on 5/19/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WizDocument;
@class RootViewController;

enum {
	documentsNone = -1,
	documentsRecent = 0,
	documentsFolder = 1,
	documentsSearchResult = 2,
	documentsTag = 3
};


@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate> {
    
    UIPopoverController *popoverController;
    UIToolbar *toolbar;
	UITableView* tableView;
	RootViewController* rootController;
    
	NSMutableArray* documents;
	
	UIAlertView* waitAlertView;
	WizDocument* currentDocument;
	//
	NSString* syncDocumentsXmlRpcMethod;
	//
	NSString* accountUserId;
	int documentsType;
	NSString* documentsTypeData;
}

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) RootViewController* rootController;

@property (nonatomic, retain) NSMutableArray* documents;
@property (nonatomic, retain) UIAlertView* waitAlertView;
@property (nonatomic, retain) WizDocument* currentDocument;

@property (nonatomic, retain) NSString* accountUserId;
@property (nonatomic) int documentsType;
@property (nonatomic, retain) NSString* documentsTypeData;

-(void) listDocuments:(NSString*)userId docType:(int)docType typeData:(NSString*)typeData docs:(NSArray*)docs;
-(void) clearData;

-(NSString*) getSyncDocumentsXmlRpcMethod;

-(IBAction) onRefreshDocuments:(id)sender;
-(IBAction) onNewNote:(id)sender;
-(IBAction) onSearch:(id)sender;

- (void) onNewDocument: (NSNotification*)nc;
@end
