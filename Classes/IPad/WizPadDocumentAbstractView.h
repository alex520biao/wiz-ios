//
//  WizPadDocumentAbstractView.h
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WizPadDocumentAbstractViewSelectedDelegate <NSObject>
- (void) didSelectedDocument:(WizDocument*)doc;
@end
@interface WizPadDocumentAbstractView : UIView
{
    WizDocument* doc;
    id <WizPadDocumentAbstractViewSelectedDelegate> selectedDelegate;
}
@property (assign) id <WizPadDocumentAbstractViewSelectedDelegate> selectedDelegate;
@property (nonatomic, retain) WizDocument* doc;
@end
