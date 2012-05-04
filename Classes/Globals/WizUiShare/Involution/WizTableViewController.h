//
//  WizTableViewController.h
//  Wiz
//
//  Created by wiz on 12-3-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WizNotification.h"
#import "WizSyncDescriptionDelegate.h"
@protocol WizTableDataDelegate <NSObject>
- (NSArray*) reloadAllDocument;
- (void) deleteDocument:(NSString*)documentGuid;
- (void) insertDocument:(WizDocument*)doc indexPath:(NSIndexPath*)indexPath;
@end

@protocol WizTableViewControllerDataDelegate
- (void) reloadSourceData;
@end
@interface WizTableViewController : UITableViewController <WizSyncDescriptionDelegate>
{
    id <WizTableDataDelegate> wizDataDelegate;
    @private
    NSMutableArray* tableSourceArray;
    NSUInteger kOrderIndex;
    NSMutableArray* needUpdateArray;
}
@property(retain, nonatomic) NSMutableArray* tableSourceArray;
@property(retain, nonatomic) id <WizTableDataDelegate> wizDataDelegate;
@property(retain, nonatomic) NSMutableArray* needUpdateArray;
@property NSUInteger kOrderIndex;
- (NSInteger) documentsCount;
@end


