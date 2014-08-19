//
//  UserInformation.h
//  FitMap
//
//  Created by Christina on 7/28/14.
//  Copyright (c) 2014 CMU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInformation : NSObject {
    NSString * username;
    NSString * password;
    NSNumber * weight;
}

+(UserInformation *) getInstance;

-(void) setUsername: (NSString*) parameter;
-(NSString*) getUsername;

-(void) setPassword: (NSString*) parameter;
-(NSString*) getPassword;

-(void) setWeight: (NSNumber*) parameter;
-(NSNumber*) getWeight;


@end
