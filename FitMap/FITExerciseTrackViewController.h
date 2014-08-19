//
//  FITSecondViewController.h
//  FitMap
//
//  Created by Kangping Yao on 7/20/14.
//  Copyright (c) 2014 CMU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FITExerciseTrackViewController : UIViewController <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *trackingWebView;
@property (weak, nonatomic) IBOutlet UILabel *calorieTittle;
@property (weak, nonatomic) IBOutlet UILabel *distanceTittle;

@end
