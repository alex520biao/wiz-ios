//
//  WizEditorBaseViewController.h
//  Wiz
//
//  Created by wiz on 12-7-2.
//
//

#import <UIKit/UIKit.h>
#import "UIWebView+WizEditor.h"
@class WizDocument;
@protocol WizEditorSourceDelegate <NSObject>
- (NSString*) editorSourcePath:(NSString*)path;
@end

@interface WizEditorBaseViewController : UIViewController
{
    WizDocument* docEdit;
    id<WizEditorSourceDelegate> sourceDelegate;
    //
    UIWebView* editorWebView;
    //
}
@property (nonatomic, retain) WizDocument* docEdit;
@property (nonatomic, assign) id<WizEditorSourceDelegate> sourceDelegate;
//
- (id) initWithWizDocument:(WizDocument*)doc;
//
- (BOOL) canRecord;
- (BOOL) startRecord;
- (BOOL) stopRecord;
- (BOOL) canSnapPhotos;
- (UIImagePickerController*) selectPhoto:(id<UIImagePickerControllerDelegate, UINavigationControllerDelegate>) parentController;
- (UIImagePickerController*) snapPhoto:(id<UIImagePickerControllerDelegate, UINavigationControllerDelegate>)parentController;
//
- (void) willAddAudioDone:(NSString*)audioPath;
- (void) willAddPhotoDone:(NSString*)photoPath;
//
@end
