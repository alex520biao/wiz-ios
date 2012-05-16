//
//  WizPadListCell.h
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#define PADABSTRACTVELLHEIGTH 300
@interface WizPadListCell : UITableViewCell
{
    NSMutableArray* abstractArray;
}
@property (nonatomic, retain) NSMutableArray* abstractArray;
- (void) setDocuments:(NSArray*) arr;
@end
