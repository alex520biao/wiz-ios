//
//  WizCommonEditorViewControllerM5.m
//  Wiz
//
//  Created by wiz on 12-7-10.
//
//

#import "WizCommonEditorViewControllerM5.h"

@interface WizCommonEditorViewControllerM5 ()

@end

@implementation WizCommonEditorViewControllerM5

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    [webView prapareForEdit];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (id) initWithWizDocument:(WizDocument *)doc
{
    self = [super initWithWizDocument:doc];
    if (self) {
        self.urlRequest = [NSURLRequest requestWithURL:[self buildEditorEnviromentMoreThan5]];
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
