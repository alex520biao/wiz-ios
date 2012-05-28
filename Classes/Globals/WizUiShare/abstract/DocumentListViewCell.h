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
extern int CELLHEIGHTWITHABSTRACT;
extern int CELLHEIGHTWITHOUTABSTRACT;
@class WizDocument;
@interface DocumentListViewCell : UITableViewCell
{
    WizDocument* doc;
    WizAbstract* abstractData;
    BOOL showDownloadIndicator;
}
@property (nonatomic, retain) WizAbstract* abstractData;
@property (nonatomic, retain) WizDocument* doc;
@property (nonatomic, assign) BOOL showDownloadIndicator;
- (void) prepareForAppear;
@end
