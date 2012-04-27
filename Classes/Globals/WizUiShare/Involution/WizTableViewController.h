//
//  WizTableViewController.h
//  Wiz
//
//  Created by wiz on 12-3-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WizNotification.h"
@protocol WizTableDataDelegate <NSObject>
- (NSArray*) reloadAllDocument;
- (void) deleteDocument:(NSString*)documentGuid;
- (void) insertDocument:(WizDocument*)doc indexPath:(NSIndexPath*)indexPath;
@end

@protocol WizTableViewControllerDataDelegate
- (void) reloadSourceData;
@end
@interface WizTableViewController : UITableViewController
{
    id <WizTableDataDelegate> wizDataDelegate;
    @private
    NSMutableArray* tableSourceArray;
    NSUInteger kOrderIndex;
}
@property(retain, nonatomic) NSMutableArray* tableSourceArray;
@property(retain, nonatomic) id <WizTableDataDelegate> wizDataDelegate;
@property NSUInteger kOrderIndex;
- (NSInteger) documentsCount;
@end


