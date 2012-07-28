//
//  WizSyncDescriptionDelegate.h
//  Wiz
//
//  Created by 朝 董 on 12-4-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WizSyncDescriptionDelegate <NSObject>

- (void) didChangedSyncDescription:(NSString*)description;

@end

