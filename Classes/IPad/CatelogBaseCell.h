//
//  CatelogBaseCell.h
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#define PADABSTRACTVELLHEIGTH 300
@interface CatelogBaseCell : UITableViewCell
{
    NSString* accountUserId;

    id owner;
}
@property (nonatomic, retain) NSArray* abstractViewArray;
@property (nonatomic, retain) NSString* accountUserId;
@property (nonatomic, retain) id owner;
- (void) setContent:(NSArray*) arr;
@end
