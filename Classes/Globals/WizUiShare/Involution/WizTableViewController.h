//
//  WizTableViewController.h
//  Wiz
//
//  Created by wiz on 12-3-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WizNotification.h"
@interface NSString (WizTableViewControllerNSString)
- (NSComparisonResult) compareDate:(NSString*)str;
- (NSComparisonResult) compareFirstCharacter:(NSString*) str;
@end

@protocol WizTableViewControllerDataDelegate
- (void) reloadSourceData;
@end

@interface WizTableViewController : UITableViewController
{
    @public
    NSString* accountUserId;
    @private
    NSMutableArray* tableSourceArray;
    NSUInteger kOrderIndex;
}
@property(retain, nonatomic) NSString* accountUserId;
@property(retain, nonatomic) NSMutableArray* tableSourceArray;
@property NSUInteger kOrderIndex;
- (id) initWithAccountuserid:(NSString*)userId;
@end


