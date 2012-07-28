//
//  WizEditorHTMLMutableArray.m
//  Wiz
//
//  Created by wiz on 12-7-13.
//
//

#import "WizEditorHTMLMutableArray.h"

@implementation WizWebEditAttachment
@synthesize sourcePath;
@synthesize editType;

- (void) dealloc
{
    [sourcePath release];
    [super dealloc];
}
@end


@implementation WizEditorHTMLMutableArray
- (void) addWizEditAttachment:(NSString *)sourcePath editType:(WizWebEditAttachmentType)type
{
    WizWebEditAttachment* attach = [[WizWebEditAttachment alloc] init];
    attach.sourcePath = sourcePath;
    attach.editType = type;
    [self addObject:attach];
    [attach release];
}

- (void) actionWizWebEditDelete
{
    for (id each in self) {
        if (![each isKindOfClass:[WizWebEditAttachment class]]) {
            continue;
        }
        WizWebEditAttachment* attach = (WizWebEditAttachment*)each;
        if (WizWebEditAttachmentTypeDelete == attach.editType) {
        
        }
    }
}

@end
