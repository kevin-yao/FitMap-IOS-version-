//
//  TermOfUseViewController.m
//  FitMap
//
//  Created by Christina on 7/28/14.
//  Copyright (c) 2014 CMU. All rights reserved.
//

#import "FITTermOfUseViewController.h"

@interface FITTermOfUseViewController ()

@end

@implementation FITTermOfUseViewController

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
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"TermOfUsePage" ofType:@"html" inDirectory:nil];
    NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    //    self.webView.scalesPageToFit = YES;
    [self.termOfUseView loadHTMLString:htmlString baseURL:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
