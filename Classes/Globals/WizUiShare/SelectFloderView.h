//
//  SelectFloderView.h
//  Wiz
//
//  Created by dong zhao on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SelectFloderView : UITableViewController {
    NSMutableArray* allFloders;
    NSMutableArray*       selectedFloder;
    NSString*       accountUserID;
    NSIndexPath*    lastIndexPath;
    NSMutableString*       selectedFloderString;
}
@property (nonatomic, retain) NSMutableArray* allFloders;
@property (nonatomic, retain) NSMutableArray* selectedFloder;
@property (nonatomic, retain) NSString*       accountUserID;
@property (nonatomic, retain) NSIndexPath*    lastIndexPath;
@property (nonatomic, retain) NSMutableString*       selectedFloderString;
@end
