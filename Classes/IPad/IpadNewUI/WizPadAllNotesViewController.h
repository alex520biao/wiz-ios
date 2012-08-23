//
//  WizPadAllNotesViewController.h
//  Wiz
//
//  Created by wiz on 12-8-16.
//
//

#import <UIKit/UIKit.h>
#import "WizPadViewDocumentDelegate.h"
@protocol WizPadNewNoteTagAndFolderDelegate
- (NSString*) tagGuidForNewNote;
- (NSString*) folderForNewNote;
@end

@interface WizPadAllNotesViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, WizPadNewNoteTagAndFolderDelegate>
@property (nonatomic, retain) IBOutlet  UITableView* masterTableView;
@property (nonatomic, retain) IBOutlet  UITableView* detailTableView;
@property (nonatomic, assign) id<WizPadViewDocumentDelegate> checkDocuementDelegate;
@end
