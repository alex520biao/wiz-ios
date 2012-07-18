//
//  WizCheckAttachmentViewController.m
//  Wiz
//
//  Created by wiz on 12-7-18.
//
//

#import "WizCheckAttachmentViewController.h"

@interface WizCheckAttachmentViewController ()
{
    NSString* attachmentPath;
    UIWebView* webView;
}

@end

@implementation WizCheckAttachmentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        webView = [[UIWebView alloc] init];
    }
    return self;
}
- (void) dealloc
{
    if (attachmentPath) {
        [attachmentPath release];
    }
    attachmentPath = nil;
    [webView release];
    webView = nil;
    [super dealloc];
}
- (id) initWithAttachmentPath:(NSString*)path
{
    self = [super init];
    if (self) {
        if (path) {
            attachmentPath = [path copy];
        }
    }
    return self;
}
- (void) loadView
{
    self.view = webView;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSURL* url = [NSURL fileURLWithPath:attachmentPath];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    
    NSLog(@"file is %@",url);
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
