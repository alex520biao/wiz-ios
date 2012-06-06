//
//  WizGroup.h
//  Wiz
//
//  Created by 朝 董 on 12-6-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizObject.h"
typedef NSInteger WizKbguidType;
enum  {
    WizKbguidPrivateType = 0,
    WizKbguidGroupType = 1
};
@interface WizGroup : WizObject
{
    WizKbguidType   type;
    UIImage*        abstractImage;
    NSString*       abstractText;
}
@property (atomic) WizKbguidType   type;
@property (atomic, retain) UIImage*       abstractImage;
@property (atomic, retain) NSString*       abstractText;
- (NSDictionary*) dictionaryWithGropuData;
- (WizGroup*)groupFromDicionary:(NSDictionary*)dic;
- (BOOL) isEqualToDictionary:(NSDictionary*)dic;
@end
