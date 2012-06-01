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
@property (atomic, retain) WizAbstract* abstractData;
@property (atomic, retain) WizDocument* doc;
@property (atomic, assign) BOOL showDownloadIndicator;
- (void) prepareForAppear;
@end
