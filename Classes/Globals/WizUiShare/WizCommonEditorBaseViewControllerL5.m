//
//  WizCommonEditorBaseViewControllerL5.m
//  Wiz
//
//  Created by wiz on 12-7-4.
//
//

#import "WizCommonEditorBaseViewControllerL5.h"
#import "NSString+WizString.h"
#import <QuartzCore/QuartzCore.h>

enum WizEditorFirstResponser {
     WizEditorFirstResponserTitleTextFile= 1,
    WizEditorFirstResponserChangeTextView = 2
    };

@interface WizCommonEditorBaseViewControllerL5 () <UITextViewDelegate>
{
    UITextView* changeTextView;
    UIView* additionView;
    
    UIButton* hideTextViewButton;
    
    NSString* currentEditString;
    NSRange currentEditStringRange;
    
    
    enum WizEditorFirstResponser firstResponserInputView;
}
@property (nonatomic, retain) NSString* currentEditString;
@property (nonatomic, retain) UITextView* changeTextView;
@end

@implementation WizCommonEditorBaseViewControllerL5
@synthesize currentEditString;
@synthesize changeTextView;
- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.changeTextView = nil;
    [currentEditString release];
    [super dealloc];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [webView prapareForEditLessThan5];
}
- (void) prepareForVoiceRecognitionStart
{
    if (self.changeTextView) {
        [self.changeTextView resignFirstResponder];
    }
    [titleTextField resignFirstResponder];
}
- (void) didVoiceRecognitionEnd:(NSString *)string
{
    if (string == nil) {
        return;
    }
    NSLog(@"get rec string is %@",string);
    switch (firstResponserInputView) {
        case WizEditorFirstResponserChangeTextView:
        {
            NSMutableString* edit;
            if (self.currentEditString != nil) {
                edit = [NSMutableString stringWithString:self.currentEditString];
            }
            if (edit == nil) {
                edit = [NSMutableString string];
            }
            if (currentEditStringRange.location != NSNotFound && nil!= string) {
                @try {
                    if (currentEditStringRange.length >0)
                    {
                        [edit replaceCharactersInRange:currentEditStringRange withString:string];
                    }
                    else
                    {
                        [edit insertString:string atIndex:currentEditStringRange.location];
                    }
                }
                @catch (NSException *exception)
                {
                    if ([exception isKindOfClass:[NSRangeException class]])
                    {
                        [edit insertString:string atIndex:currentEditStringRange.location];
                    }
                }
                @finally
                {
                    [edit insertString:string atIndex:0];
                }
            }
            [self changeText:edit];
        }
            break;
        case WizEditorFirstResponserTitleTextFile:
        {
            titleTextField.text = [titleTextField.text stringByAppendingString:string];
            [titleTextField becomeFirstResponder];
        }
        default:
            break;
    }
}
- (void) editorImageDone
{
    [editorWebView deleteImage];
    [[NSFileManager defaultManager] removeItemAtPath:self.currentDeleteImagePath error:nil];
}

- (void) changeText:(NSString*)text
{
    [self buildTextView];
    self.changeTextView.text =text;
    self.currentEditString = text;
    [self.changeTextView becomeFirstResponder];
} 

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString* requestString = [[request URL] absoluteString];
    NSArray* array = [webView decodeJsCmd:requestString];
    if (array && [array count] >=2) {
        NSString* cmd = [array objectAtIndex:0];
        NSString* content = [array objectAtIndex:1];
        if ([cmd isEqualToString:WizNotCmdChangedText]) {
            [self changeText:[content fromHtml]];
        }
        else if ([cmd isEqualToString:WizNotCmdChangedImage])
        {
            static NSString* fileBom =@"file:///";
            NSInteger indexOfFileBom = [content indexOf:fileBom];
            if (NSNotFound != indexOfFileBom) {
                NSString* path = [content substringFromIndex:indexOfFileBom+fileBom.length];
                [self fixWebInsideImage:path];
                self.currentDeleteImagePath = path;
            }
            else
            {
                [self fixWebHttpInsideImage];
            }
        }
    }
    if ([[[[request URL] absoluteString] fileName] isEqualToString:[[[self.urlRequest URL] absoluteString] fileName]])
    {
        return YES;
    }
    return NO;
}
- (void) prepareForSave
{
    if (self.changeTextView) {
        [self.changeTextView resignFirstResponder];
    }
}
- (void) showEditor:(NSNotification*)nc
{
    CGRect kbRect = [[[nc userInfo] objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue];
    if (![titleTextField isFirstResponder]) {
        if ([WizGlobals WizDeviceIsPad]) {
            additionView.frame = CGRectMake(self.view.frame.size.width-80 , self.view.frame.size.height - kbRect.size.height-190, 80, 40);
            self.changeTextView.frame = CGRectMake(0.0,self.view.frame.size.height - kbRect.size.height - 150, [[UIScreen mainScreen] bounds].size.width, 154);
            [self resizeBackgrouScrollViewStartY:[self isRecording]?40:0 height:self.view.frame.size.height - kbRect.size.height];
        }
       else
       {
           additionView.frame = CGRectMake(self.view.frame.size.width-80 , self.view.frame.size.height - kbRect.size.height-80, 80, 40);
           self.changeTextView.frame = CGRectMake(0.0,self.view.frame.size.height - kbRect.size.height - 40, [[UIScreen mainScreen] bounds].size.width, 44);
           [self resizeBackgrouScrollViewStartY:[self isRecording]?40:0 height:self.view.frame.size.height - kbRect.size.height-40];
       }
        [self.view bringSubviewToFront:self.changeTextView];
        firstResponserInputView = WizEditorFirstResponserChangeTextView;
    }
    else
    {
        firstResponserInputView = WizEditorFirstResponserTitleTextFile;
        additionView.frame = CGRectMake(kbRect.size.width-80 , self.view.frame.size.height - kbRect.size.height- 40, 80, 40);
        [self resizeBackgrouScrollViewStartY:[self isRecording]?40:0 height:self.view.frame.size.height - kbRect.size.height];
    }
}

- (void) hideEditor:(NSNotification*)nc
{
    additionView.frame = CGRectMake(-90, -90, 0, 0);
    if (self.changeTextView) {
       self.changeTextView.frame = CGRectMake(-90, -90, 0, 0); 
    }
    [self resizeBackgrouScrollViewStartY:[self isRecording]?40:0 height:self.view.frame.size.height];
}
- (void) textViewDidEndEditing:(UITextView *)textView_
{
    [editorWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"endFix('%@')",[textView_.text nToHtmlBr]]];
    CGRect additionFrame = additionView.frame;
    additionView.frame = CGRectMake(additionFrame.origin.x, additionFrame.origin.y + 40, additionFrame.size.width, additionFrame.size.height);
    textView_.frame = CGRectMake(0.0, 0.0, 0.0, 0.0);
    [textView_ resignFirstResponder];
    firstResponserInputView = WizEditorFirstResponserChangeTextView;
}
- (void) hideAddition
{
    if (self.changeTextView) {
        [self.changeTextView resignFirstResponder];
    }
    [titleTextField resignFirstResponder];
}
- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    firstResponserInputView = WizEditorFirstResponserTitleTextFile;
}


- (void) buildAddtionView
{
     additionView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, 0.0)];
    hideTextViewButton = [[UIButton alloc] initWithFrame:CGRectMake(40, 0.0, 40, 40)];
    [hideTextViewButton addTarget:self action:@selector(hideAddition) forControlEvents:UIControlEventTouchUpInside];
    [hideTextViewButton setImage:[UIImage imageNamed:@"keyHidden"] forState:UIControlStateNormal];
    [additionView addSubview:hideTextViewButton];
}
- (void) buildTextView
{
    if (self.changeTextView) {
        [self.changeTextView removeFromSuperview];
    }
    self.changeTextView = nil;
    self.changeTextView = [[[UITextView alloc] init] autorelease];
    self.changeTextView.delegate = self;
    self.changeTextView.backgroundColor = [UIColor colorWithRed:215.0/255 green:215.0/255 blue:215.0/255 alpha:1.0];
    self.changeTextView.font = [UIFont systemFontOfSize:16];
    CALayer* layer = self.changeTextView.layer;
    layer.borderColor = [UIColor brownColor].CGColor;
    layer.borderWidth = 0.5f;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOffset = CGSizeMake(2, 2);
    layer.cornerRadius = 3;
    self.changeTextView.textColor = [UIColor blackColor];
    self.changeTextView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.changeTextView];
    
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        [self buildTextView];
        [self buildAddtionView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showEditor:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideEditor:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}
- (void) textViewDidChangeSelection:(UITextView *)textView_
{
    currentEditStringRange = textView_.selectedRange;
}
- (void)viewDidLoad
{
    self.urlRequest = [NSURLRequest requestWithURL:[self buildEditorEnviromentLessThan5]];
    [super viewDidLoad];

    additionView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:additionView];
    

}


+ (BOOL) canEditingDocumentwithEditorL5:(WizDocument*)doc
{
    return YES;
}
- (id) initWithWizDocument:(WizDocument *)doc
{
    self = [super initWithWizDocument:doc];
    if (self) {
    }
    return self;
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
