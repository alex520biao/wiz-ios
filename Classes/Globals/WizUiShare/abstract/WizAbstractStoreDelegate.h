//
//  WizAbstractStoreDelegate.h
//  Wiz
//
//  Created by wiz on 12-7-17.
//
//

#import <Foundation/Foundation.h>

@protocol WizAbstractStoreDelegate <NSObject>
- (void) storeDocumentAbstract:(NSString*)documentGuid  abstract:(WizAbstract*)abstract;
@end
