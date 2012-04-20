//
//  DocumentListViewCell.h
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-31.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#define PadPortraitCellHeight 300
#define PadPortraitCellWidth 190
@class TTTAttributedLabel;
extern int CELLHEIGHTWITHABSTRACT;
extern int CELLHEIGHTWITHOUTABSTRACT;
@class WizDocument;
@interface DocumentListViewCell : UITableViewCell
{
    TTTAttributedLabel* abstractLabel;
    UIImageView* abstractImageView;
    WizDocument* doc;
    BOOL hasAbstract;
    UIInterfaceOrientation interfaceOrientation;
    UIActivityIndicatorView* downloadIndicator;
}
@property (nonatomic, retain) TTTAttributedLabel* abstractLabel;
@property (nonatomic, retain) UIImageView* abstractImageView;
@property (nonatomic, retain) WizDocument* doc;
@property (nonatomic, retain) UIActivityIndicatorView* downloadIndicator;
@property (assign)  BOOL hasAbstract;
@property UIInterfaceOrientation interfaceOrientation;
- (void) prepareForAppear;
@end
