//
//  WizEditorHTMLMutableArray.h
//  Wiz
//
//  Created by wiz on 12-7-13.
//
//

#import <Foundation/Foundation.h>

enum WizWebEditAttachmentType
{
    WizWebEditAttachmentTypeDelete = 0,
    WizWebEditAttachmentTypeChange = 1
};

typedef NSInteger WizWebEditAttachmentType;
@interface WizWebEditAttachment : NSObject
{
    NSString* sourcePath;
    WizWebEditAttachmentType editType;
}
@property (nonatomic, retain) NSString* sourcePath;
@property (nonatomic, assign) WizWebEditAttachmentType editType;
@end



@interface WizEditorHTMLMutableArray : NSMutableArray
- (void) addWizEditAttachment:(NSString*)sourcePath  editType:(WizWebEditAttachmentType)type;
@end
