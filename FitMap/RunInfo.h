//
//  RunInfo.h
//  FitMap
//
//  Created by Kangping Yao on 7/24/14.
//  Copyright (c) 2014 CMU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RunInfo : NSManagedObject

@property (nonatomic, retain) NSDate * alarmTime;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * startingAddress;
@property (nonatomic, retain) NSString * destination;
@property (nonatomic, retain) NSNumber * completed;
@property (nonatomic, retain) NSNumber * calorie;
@property (nonatomic, retain) NSNumber * distance;

@end
