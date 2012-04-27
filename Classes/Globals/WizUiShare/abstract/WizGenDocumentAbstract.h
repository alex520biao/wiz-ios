//
//  WizGenDocumentAbstract.h
//  Wiz
//
//  Created by 朝 董 on 12-4-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WizAbstractData;
@protocol WizGenDocumentAbstractDelegate <NSObject>
- (void) didGenDocumentAbstract:(NSString*)documentGuid  abstractData:(WizAbstractData*)abs;
@end
@interface WizGenDocumentAbstract : NSOperation
- (id) initWithDegeate:(NSString*)documentGuid_ delegate:(id<WizGenDocumentAbstractDelegate>)delegate_;
@end
