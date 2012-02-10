//
//  WizPadDocumentListController.h
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DocumentListViewControllerBaseNew.h"
@interface WizRange :NSObject
{
    NSUInteger start;
    NSUInteger end;
}
@property  NSUInteger start;
@property NSUInteger end;
@end
@interface WizPadDocumentListController : DocumentListViewControllerBaseNew <WizDocumentListMethod>
{
    int listType;
    UIInterfaceOrientation tableOrientation;
}
@property int listType;
@property UIInterfaceOrientation tableOrientation;
@end
