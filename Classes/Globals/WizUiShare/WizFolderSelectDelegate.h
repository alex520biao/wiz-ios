//
//  WizFolderSelectDelegate.h
//  Wiz
//
//  Created by 朝 董 on 12-5-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WizFolderSelectDelegate <NSObject>
- (NSString*) selectedFolderOld;
- (void) didSelectedFolderString:(NSString*)folderString;
@end
