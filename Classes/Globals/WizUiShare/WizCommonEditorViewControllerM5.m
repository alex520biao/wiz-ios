//
//  WizCommonEditorViewControllerM5.m
//  Wiz
//
//  Created by wiz on 12-7-10.
//
//

#import "WizCommonEditorViewControllerM5.h"
#import "WizFileManager.h"
@interface WizCommonEditorViewControllerM5 ()
{
   
}
@end

@implementation WizCommonEditorViewControllerM5

- (void) dealloc
{
    [fontToolBar release];
    [super dealloc];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

        
        //
        fontToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(-50, -52, 0, 0)];
        UIBarButtonItem* italic = [[UIBarButtonItem alloc] initWithTitle:@"I" style:UIBarButtonItemStyleBordered target:editorWebView action:@selector(italic)];
        UIBarButtonItem* bold = [[UIBarButtonItem alloc] initWithTitle:@"B" style:UIBarButtonItemStyleBordered target:editorWebView action:@selector(bold)];
        UIBarButtonItem* underline = [[UIBarButtonItem alloc] initWithTitle:@"U" style:UIBarButtonItemStyleBordered target:editorWebView action:@selector(underline)];
        UIBarButtonItem* highLight = [[UIBarButtonItem alloc] initWithTitle:@"!" style:UIBarButtonItemStyleBordered target:editorWebView action:@selector(highlightText)];
        UIBarButtonItem* strikeThrough = [[UIBarButtonItem alloc] initWithTitle:@"S" style:UIBarButtonItemStyleBordered target:editorWebView action:@selector(strikeThrough)];
        UIBarButtonItem* fontSub = [[UIBarButtonItem alloc] initWithTitle:@"A-" style:UIBarButtonItemStyleBordered target:editorWebView action:@selector(fontSizeDown)];
        UIBarButtonItem* fonPlus = [[UIBarButtonItem alloc] initWithTitle:@"A+" style:UIBarButtonItemStyleBordered target:editorWebView action:@selector(fontSizeUp)];
        UIBarButtonItem* flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        fontToolBar.items = [NSArray arrayWithObjects:italic,flexItem ,bold,flexItem ,underline, flexItem ,strikeThrough,flexItem ,highLight,flexItem ,fontSub,flexItem ,fonPlus, nil];
        [italic release];
        [bold release];
        [underline release];
        [highLight release];
        [strikeThrough release];
        [fonPlus release];
        [fontSub release];
        [flexItem release];


    }
    return self;
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString* requestString = [[request URL] absoluteString];
    NSArray* array = [webView decodeJsCmd:requestString];
    if (array && [array count] >=2) {
        NSString* cmd = [array objectAtIndex:0];
        NSString* content = [array objectAtIndex:1];
        if ([cmd isEqualToString:WizNotCmdChangedImage])
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
                
            }
        }
    }
    if ([[[[request URL] absoluteString] fileName] isEqualToString:[[[self.urlRequest URL] absoluteString] fileName]])
    {
        return YES;
    }
    return NO;
}
- (void) resumeLastEditong
{
    WizFileManager* fileManager = [WizFileManager shareManager];
    NSError* error = nil;
    if ([fileManager fileExistsAtPath:[WizEditorBaseViewController editingFilePath]]) {
        if (![fileManager removeItemAtPath:[WizEditorBaseViewController editingFilePath] error:&error]) {
            NSLog(@"resume delete file error %@",error);
        }
    }
    if (![fileManager copyItemAtPath:[WizEditorBaseViewController editingIndexFilePath] toPath:[WizEditorBaseViewController editingFilePath] error:&error]) {
        NSLog(@"resume copy file error %@",error);
    }
    self.docEdit = [[[WizDocument alloc] initFromDictionaryModel:[NSDictionary dictionaryWithContentsOfFile:[WizEditorBaseViewController editingDocumentModelFilePath]]] autorelease];
    self.urlRequest = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:[WizEditorBaseViewController editingFilePath]]];
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
