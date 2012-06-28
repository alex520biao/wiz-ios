//
//  WizFastViewController.m
//  FastWiz
//
//  Created by wiz on 12-6-28.
//
//

#import "WizFastViewController.h"
@interface WizFastViewController ()

@end

@implementation WizFastViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void) automicSaveDocument
{
    NSString* documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString* documentFileName = [documentPath stringByAppendingPathComponent:@"index.html"];
    NSString* body = self.bodyTextView.text;
    NSLog(@"body %@",body);
    if (body) {
        NSError* error = nil;
        if(![body writeToFile:documentFileName atomically:YES encoding:NSUTF16StringEncoding error:&error])
        {
            NSLog(@"%@",error);
        }
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.bodyTextView becomeFirstResponder];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    static NSTimer* saveTimer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        saveTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(automicSaveDocument) userInfo:nil repeats:YES];
        [saveTimer fire];
    });
}
@end
