//
//  UserInfo.h
//  FitMap
//
//  Created by Kangping Yao on 8/2/14.
//  Copyright (c) 2014 CMU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RunInfo;

@interface UserInfo : NSManagedObject

@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) NSSet *runInformation;
@end

@interface UserInfo (CoreDataGeneratedAccessors)

- (void)addRunInformationObject:(RunInfo *)value;
- (void)removeRunInformationObject:(RunInfo *)value;
- (void)addRunInformation:(NSSet *)values;
- (void)removeRunInformation:(NSSet *)values;

@end
