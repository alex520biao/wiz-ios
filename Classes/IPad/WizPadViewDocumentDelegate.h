//
//  WizPadViewDocumentDelegate.h
//  Wiz
//
//  Created by 朝 董 on 12-5-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizUiTypeIndex.h"
@protocol WizPadViewDocumentDelegate <NSObject>
- (void) checkDocument:(NSInteger)type  keyWords:(NSString*)keyWords  selectedDocument:(WizDocument*)document;
@end
