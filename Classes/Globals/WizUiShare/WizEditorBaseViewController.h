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
    NSURLRequest* urlRequest;
    
    NSString* currentDeleteImagePath;
}
@property (nonatomic, retain) WizDocument* docEdit;
@property (nonatomic, assign) id<WizEditorSourceDelegate> sourceDelegate;
@property (nonatomic, retain) NSURLRequest* urlRequest;
@property (nonatomic, retain)  NSString* currentDeleteImagePath;
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


//
- (NSURL*) buildEditorEnviromentLessThan5;
- (NSURL*) buildEditorEnviromentMoreThan5;
//
- (void) willDeleteImage:(NSString*)sourcePath;
//
- (void) resumeLastEditong;
@end
