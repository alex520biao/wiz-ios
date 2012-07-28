//
//  WizMapViewController.m
//  Wiz
//
//  Created by 朝 董 on 12-5-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizMapViewController.h"
#import <MapKit/MapKit.h>
@interface WizMapViewController ()
{
    MKMapView* mapView;
}
@end

@implementation WizMapViewController
@synthesize doc;
- (void) dealloc
{
    [doc release];
    doc = nil;
    [mapView release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        mapView = [[MKMapView alloc] init];
    }
    return self;
}

- (void) loadView
{
    self.view = mapView;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CLLocationCoordinate2D theCoordinate;
    NSLog(@"%f %f",self.doc.gpsLongtitude,self.doc.gpsLatitude);
    
    theCoordinate.latitude=self.doc.gpsLatitude;
    theCoordinate.longitude=self.doc.gpsLongtitude;
    MKCoordinateSpan theSpan;
    theSpan.latitudeDelta=0.1;
    theSpan.longitudeDelta=0.1;

    MKCoordinateRegion theRegion;
    theRegion.center=theCoordinate;
    theRegion.span=theSpan;
    [mapView setMapType:MKMapTypeStandard];
    mapView.showsUserLocation = YES;
    [mapView setRegion:theRegion];
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
