//
//  WizAbstractCache.h
//  Wiz
//
//  Created by wiz on 12-8-3.
//
//

#import <Foundation/Foundation.h>

@interface WizAbstractCache : NSObject
+ (id) shareCache;
- (WizAbstract*)  documentAbstract:(WizDocument*)document  decorateView:(id)decorateView;
@end
