//
//  WizPadListCell.h
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WizPadDocumentAbstractView.h"
#define PADABSTRACTVELLHEIGTH 300

@protocol WizPadCellSelectedDocumentDelegate <NSObject>
- (void) didPadCellDidSelectedDocument:(WizDocument*)doc;
@end

@interface WizPadListCell : UITableViewCell <WizPadDocumentAbstractViewSelectedDelegate>
{
    NSArray* documents;
    id <WizPadCellSelectedDocumentDelegate> selectedDelegate;
}
@property (assign) id <WizPadCellSelectedDocumentDelegate> selectedDelegate;
@property (nonatomic, retain) NSArray* documents;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier  detailViewSize:(CGSize)detailSize;
- (void) updateDoc;
@end
