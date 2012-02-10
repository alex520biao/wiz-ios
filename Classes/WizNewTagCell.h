//
//  WizNewTagCell.h
//  Wiz
//
//  Created by wiz on 12-2-3.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WizNewTagCell : UITableViewCell
{
    UITextField* textField;
}
@property (nonatomic, retain) UITextField* textField;
- (void) setTextFieldText:(NSString*)str;
@end
