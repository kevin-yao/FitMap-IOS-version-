//
//  FITSecondViewController.m
//  FitMap
//
//  Created by Kangping Yao on 7/20/14.
//  Copyright (c) 2014 CMU. All rights reserved.
//

#import "FITExerciseTrackViewController.h"

@interface FITExerciseTrackViewController ()

@end

@implementation FITExerciseTrackViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"TrackingPage" ofType:@"html" inDirectory:nil];
    NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    //    self.webView.scalesPageToFit = YES;
    [self.trackingWebView loadHTMLString:htmlString baseURL:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
