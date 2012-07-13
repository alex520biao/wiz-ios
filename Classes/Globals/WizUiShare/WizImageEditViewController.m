//
//  WizImageEditViewController.m
//  Wiz
//
//  Created by wiz on 12-7-12.
//
//

#import "WizImageEditViewController.h"

@interface WizImageEditViewController ()
{
    UIScrollView* scrollView;
    UIImageView* imageView;
}
@end

@implementation WizImageEditViewController
@synthesize sourcePath;
- (void) dealloc
{
    editDelegate = nil;
    [sourcePath release];
    [scrollView release];
    [imageView release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        scrollView = [[UIScrollView alloc] init];
        imageView = [[UIImageView alloc] init];
        [scrollView addSubview:imageView];
    }
    return self;
}
- (void) deleteCurrentImage
{
    [self.editDelegate editorImageDone];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    scrollView.frame = self.view.frame;
    imageView.frame = self.view.frame;
    [self.view addSubview:scrollView];
    
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Delete", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(deleteCurrentImage)];
    self.navigationItem.rightBarButtonItem = item;
    [item release];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    imageView.image = [UIImage imageWithContentsOfFile:self.sourcePath];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
