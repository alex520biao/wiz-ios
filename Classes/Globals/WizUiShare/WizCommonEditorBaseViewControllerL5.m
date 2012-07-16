//
//  WizCommonEditorBaseViewController.m
//  Wiz
//
//  Created by wiz on 12-7-4.
//
//

#import "WizCommonEditorBaseViewController.h"
#import "NSString+WizString.h"
#import <QuartzCore/QuartzCore.h>


@interface WizCommonEditorBaseViewController () <UITextViewDelegate>
{
    UITextView* textView;
    UIView* additionView;
    
    UIButton* hideTextViewButton;
    UIButton* voiceInputBUtton;
}
@end

@implementation WizCommonEditorBaseViewController
- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [textView release];
    [super dealloc];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [webView prapareForEditLessThan5];
}

- (void) editorImageDone
{
    [editorWebView deleteImage];
    [[NSFileManager defaultManager] removeItemAtPath:self.currentDeleteImagePath error:nil];
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString* requestString = [[request URL] absoluteString];
    NSArray* array = [webView decodeJsCmd:requestString];
    
    if (array && [array count] >=2) {
        NSString* cmd = [array objectAtIndex:0];
        NSString* content = [array objectAtIndex:1];
        if ([cmd isEqualToString:WizNotCmdChangedText]) {
            textView.text =content;
            [textView becomeFirstResponder];
        }
        else if ([cmd isEqualToString:WizNotCmdChangedImage])
        {
            static NSString* fileBom =@"file:///";
            NSInteger indexOfFileBom = [content indexOf:fileBom];
            if (NSNotFound != indexOfFileBom) {
                NSString* path = [content substringFromIndex:indexOfFileBom+fileBom.length];
                [self willDeleteImage:path];
                self.currentDeleteImagePath = path;
            }
        }
    }
    if ([[[[request URL] absoluteString] fileName] isEqualToString:[[[self.urlRequest URL] absoluteString] fileName]])
    {
        return YES;
    }
    return NO;
}

- (void) showEditor:(NSNotification*)nc
{
    CGRect kbRect = [[[nc userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self.view addSubview:textView];
    additionView.frame = CGRectMake(kbRect.size.width-80 , kbRect.origin.y-145, 80, 40);
    additionView.backgroundColor = [UIColor lightGrayColor];
    textView.backgroundColor = [UIColor lightGrayColor];
    textView.frame = CGRectMake(0.0,kbRect.origin.y-107, kbRect.size.width, 44);
    
    [self.view bringSubviewToFront:textView];
}


- (void) hideEditor:(NSNotification*)nc
{
    additionView.frame = CGRectMake(-90, -90, 0, 0);
}
- (void) textViewDidEndEditing:(UITextView *)textView
{
    [editorWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"endFix('%@')",[textView.text toHtml]]];
    textView.frame = CGRectMake(0.0, 0.0, 0.0, 0.0);
}
- (void) hideAddition
{
    [textView resignFirstResponder];
}
- (void) buildAddtionView
{
     additionView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 80, 40)];
    hideTextViewButton = [[UIButton alloc] initWithFrame:CGRectMake(40, 0.0, 40, 40)];
    [hideTextViewButton addTarget:self action:@selector(hideAddition) forControlEvents:UIControlEventTouchUpInside];
    [hideTextViewButton setTitle:@"H" forState:UIControlStateNormal];
    [additionView addSubview:hideTextViewButton];
}
- (void) buildTextView
{
    textView = [[UITextView alloc] init];
    textView.delegate = self;
    
    CALayer* layer = textView.layer;
    layer.borderColor = [UIColor brownColor].CGColor;
    layer.borderWidth = 0.5f;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOffset = CGSizeMake(2, 2);
    layer.cornerRadius = 3;
    
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self buildTextView];
        [self buildAddtionView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showEditor:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideEditor:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:textView];
    [self.view addSubview:additionView];
	// Do any additional setup after loading the view.

}


- (id) initWithWizDocument:(WizDocument *)doc
{
    self = [super initWithWizDocument:doc];
    if (self) {
        self.urlRequest = [NSURLRequest requestWithURL:[self buildEditorEnviromentLessThan5]];
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
