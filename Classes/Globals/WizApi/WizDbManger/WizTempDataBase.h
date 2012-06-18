//
//  WizTempDataBase.h
//  Wiz
//
//  Created by wiz on 12-6-17.
//
//

#import "WizDataBaseBase.h"
#import "WizAbstractDbDelegate.h"

@interface WizTempDataBase : WizDataBaseBase <WizAbstractDbDelegate>
- (BOOL) updateAbstract:(NSString*)text imageData:(NSData*)imageData guid:(NSString*)guid type:(NSString*)type kbguid:(NSString*)kbguid;
@end
