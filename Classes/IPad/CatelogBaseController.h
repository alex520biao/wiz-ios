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
    NSAttributedString* abstract;
    NSString* keyWords;
}
@property (nonatomic, retain) NSString* count;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSAttributedString* abstract;
@property (nonatomic, retain)    NSString* keyWords;
@end
@interface CatelogBaseController : UITableViewController
{
    NSMutableArray* dataArray;
    UIInterfaceOrientation willToOrientation;
}
@property (nonatomic, retain) NSMutableArray* dataArray;
@property UIInterfaceOrientation willToOrientation;
- (void) reloadAllData;
- (void) didSelectedCatelog:(NSString*)keywords;
- (void) configureCellWithArray:(UITableViewCell*)cell  array:(NSArray*)array;
+ (NSDictionary*) paragrahAttributeDic;
@end
