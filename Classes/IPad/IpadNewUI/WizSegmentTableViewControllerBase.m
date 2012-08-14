//
//  WizSegmentTableViewControllerBase.m
//  Wiz
//
//  Created by wiz on 12-8-14.
//
//

#import "WizSegmentTableViewControllerBase.h"

@interface WizSegmentTableViewControllerBase ()

@end

@implementation WizSegmentTableViewControllerBase

@synthesize orientationDelegate;

- (void) dealloc
{
    orientationDelegate = nil;
    [super dealloc];
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
}
- (UIInterfaceOrientation) interfaceOrientation
{
    return [self.orientationDelegate parentSegmentInterfaceOrientation];
}

@end
