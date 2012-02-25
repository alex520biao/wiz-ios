//
//  CatelogBaseController.h
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface WizPadCatelogData : NSObject
{
    NSString* count;
    NSString* name;
    NSMutableAttributedString* abstract;
    NSString* keyWords;
}
@property (nonatomic, retain) NSString* count;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSMutableAttributedString* abstract;
@property (nonatomic, retain)    NSString* keyWords;
@end
@interface CatelogBaseController : UITableViewController
{
    NSMutableArray* landscapeContentArray;
    NSMutableArray* portraitContentArray;
    NSString* accountUserId;
    UIInterfaceOrientation willToOrientation;
}
@property (nonatomic, retain) NSMutableArray* landscapeContentArray;
@property (nonatomic, retain) NSMutableArray* portraitContentArray;
@property (nonatomic ,retain)    NSString* accountUserId;
@property UIInterfaceOrientation willToOrientation;
- (void) reloadAllData;
- (NSArray*) arrayToLoanscapeCellArray:(NSArray*)source;
- (NSArray*) arrayToPotraitCellArraty:(NSArray*)source;
- (void) didSelectedCatelog:(NSString*)keywords;
@end
