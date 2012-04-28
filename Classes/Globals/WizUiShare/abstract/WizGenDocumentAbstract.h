//
//  WizGenDocumentAbstract.h
//  Wiz
//
//  Created by 朝 董 on 12-4-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol WizGenDocumentAbstractDelegate <NSObject>
- (NSString*) popNeedGenAbstrctDocument;
- (void) didGenDocumentAbstract:(NSString*)documentGuid  abstractData:(WizAbstract*)abs;
@end
@interface WizGenDocumentAbstract : NSOperation
{
    BOOL isChangedUser;
}
@property (atomic) BOOL isChangedUser;
- (id) initWithDelegate:(id<WizGenDocumentAbstractDelegate>)delegate_;
@end
