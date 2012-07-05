//
//  WizCommonEditorBaseViewController.m
//  Wiz
//
//  Created by wiz on 12-7-4.
//
//

#import "WizCommonEditorBaseViewController.h"

@interface WizCommonEditorBaseViewController ()

@end

@implementation WizCommonEditorBaseViewController

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
//    NSString* jquery = [[NSBundle mainBundle] pathForResource:@"jquery" ofType:@"js"];
//    NSString* string = [NSString stringWithContentsOfFile:jquery usedEncoding:nil error:nil];
//    [webView stringByEvaluatingJavaScriptFromString:string];
//    [webView stringByEvaluatingJavaScriptFromString:@"$(function() { $('font').click(function(e) {c = e.target; var url='testapp:'+'ddd'+':'+'dddd';document.location = url ;return false;	});     });"];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString* requestString = [[request URL] absoluteString];
    
    NSArray* com = [requestString componentsSeparatedByString:@":"];
    for (NSString* each in com) {
        NSLog(@"%@",com);
    }
    return YES;
    
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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
