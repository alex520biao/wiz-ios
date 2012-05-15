//
//  WizSelectTagDelegate.h
//  Wiz
//
//  Created by 朝 董 on 12-5-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WizSelectTagDelegate <NSObject>
- (NSArray*) selectedTagsOld;
- (void) didSelectedTags:(NSArray*)tags;
@end
