//
//  WizGetAbstractOperation.h
//  Wiz
//
//  Created by wiz on 12-7-17.
//
//

#import <Foundation/Foundation.h>
#import "WizAbstractStoreDelegate.h"
@interface WizGetAbstractOperation : NSOperation
{
    id<WizAbstractStoreDelegate> storeDelegate;
}
@property (atomic, assign) id<WizAbstractStoreDelegate> storeDelegate;
- (id) initWithGuid:(NSString*)guid  storeDelegate:(id<WizAbstractStoreDelegate>)sDelegate;
@end
