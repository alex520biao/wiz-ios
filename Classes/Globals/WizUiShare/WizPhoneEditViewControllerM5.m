//
//  WizPhoneEditViewController.m
//  Wiz
//
//  Created by wiz on 12-7-2.
//
//

#import "WizPhoneEditViewControllerM5.h"
#import "UIBarButtonItem+WizTools.h"
#import "WizFileManager.h"

@interface WizPhoneEditViewControllerM5 ()
{
    UIToolbar* fontToolBar;
}
@end

@implementation WizPhoneEditViewControllerM5

- (void) dealloc
{
    [fontToolBar release];
    [super dealloc];
}
- (void) showFontTools:(NSNotification*)nc
{
    CGRect kbRect = [[[nc userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    fontToolBar.frame = CGRectMake(0.0,self.view.frame.size.height-kbRect.size.height-44, kbRect.size.width, 44);
}

- (void) hideFontTools:(NSNotification*)nc
{
    fontToolBar.frame = CGRectMake(-120, -120, 0, 0);
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showFontTools:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideFontTools:) name:UIKeyboardWillHideNotification object:nil];
        
        //
        fontToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(-50, -52, 0, 0)];
        UIBarButtonItem* italic = [[UIBarButtonItem alloc] initWithTitle:@"I" style:UIBarButtonItemStyleBordered target:editorWebView action:@selector(italic)];
        UIBarButtonItem* bold = [[UIBarButtonItem alloc] initWithTitle:@"B" style:UIBarButtonItemStyleBordered target:editorWebView action:@selector(bold)];
        UIBarButtonItem* underline = [[UIBarButtonItem alloc] initWithTitle:@"U" style:UIBarButtonItemStyleBordered target:editorWebView action:@selector(underline)];
        UIBarButtonItem* highLight = [[UIBarButtonItem alloc] initWithTitle:@"!" style:UIBarButtonItemStyleBordered target:editorWebView action:@selector(highlightText)];
        UIBarButtonItem* strikeThrough = [[UIBarButtonItem alloc] initWithTitle:@"S" style:UIBarButtonItemStyleBordered target:editorWebView action:@selector(strikeThrough)];
        UIBarButtonItem* fontSub = [[UIBarButtonItem alloc] initWithTitle:@"A-" style:UIBarButtonItemStyleBordered target:editorWebView action:@selector(fontSizeDown)];
        UIBarButtonItem* fonPlus = [[UIBarButtonItem alloc] initWithTitle:@"A+" style:UIBarButtonItemStyleBordered target:editorWebView action:@selector(fontSizeUp)];
        fontToolBar.items = [NSArray arrayWithObjects:italic,bold,underline, strikeThrough,highLight,fontSub,fonPlus, nil];
        [italic release];
        [bold release];
        [underline release];
        [highLight release];
        [strikeThrough release];
        [fonPlus release];
        [fontSub release];
    }
    return self;
}
- (void) doSelectPhoto
{
    UIImagePickerController*  selectPhoto = [self selectPhoto:nil];
    [self.navigationController presentModalViewController:selectPhoto animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //
    
    fontToolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:fontToolBar];
   
	// Do any additional setup after loading the view.
}
- (void) resumeLastEditong
{
    WizFileManager* fileManager = [WizFileManager shareManager];
    NSError* error = nil;
    if ([fileManager fileExistsAtPath:[self editingFilePath]]) {
        if (![fileManager removeItemAtPath:[self editingFilePath] error:&error]) {
            NSLog(@"resume delete file error %@",error);
        }
    }
    if (![fileManager copyItemAtPath:[self editingIndexFilePath] toPath:[self editingFilePath] error:&error]) {
        NSLog(@"resume copy file error %@",error);
    }
    self.docEdit = [[[WizDocument alloc] initFromDictionaryModel:[NSDictionary dictionaryWithContentsOfFile:[self editingDocumentModelFilePath]]] autorelease];
    self.urlRequest = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:[self editingFilePath]]];
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
