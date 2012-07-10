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
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString* requestString = [[request URL] absoluteString];
    NSArray* com = [requestString componentsSeparatedByString:@":"];
    if (com && [com count] >=3) {
        [textView resignFirstResponder];
        NSString* appName = [com objectAtIndex:0];
        NSString* cmd = [com objectAtIndex:1];
        NSString* text = [com objectAtIndex:2];
        if ([appName isEqualToString:@"wiznote"] && [cmd isEqualToString:@"changedText"]) {
            NSLog(@"text is %@ \n urldecodedString is %@",text,[text URLDecodedString]);
            textView.text = [text URLDecodedString];
            [textView becomeFirstResponder];
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
        [self buildEditorEnviromentLessThan5];
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
