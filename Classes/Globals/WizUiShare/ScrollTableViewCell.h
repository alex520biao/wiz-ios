//
//  ScrollTableViewCell.h
//  Wiz
//
//  Created by dong zhao on 11-11-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WizAttachment;

@interface ScrollTableViewCell : UITableViewCell {
    WizAttachment* attach;
}
@property (nonatomic, retain) WizAttachment* attach;
@end
