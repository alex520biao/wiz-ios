//
//  WizDocumentEdit.h
//  Wiz
//
//  Created by 朝 董 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol WizDocumentEditDelegate <NSObject>
- (NSString*) documentBody;
- (NSArray*) documentPictures;
- (NSArray*) documentAudios;
@end

@interface WizDocumentEdit : WizDocument
{
    id<WizDocumentEditDelegate> editDelegate;
}
@property (nonatomic, retain) id<WizDocumentEditDelegate> editDelegate;
- (BOOL) saveWithData;
- (BOOL) saveInfo;
- (BOOL) deleteTag:(NSString*)tagGuid;
@end
