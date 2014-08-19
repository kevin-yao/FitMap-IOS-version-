//
//  UserInformation.m
//  FitMap
//  Singleton instance used to provide user information in different views
//  Created by Christina on 7/28/14.
//  Copyright (c) 2014 CMU. All rights reserved.
//

#import "UserInformation.h"

@implementation UserInformation

static UserInformation * userInformationInstance;

+(UserInformation *) getInstance{
    if (userInformationInstance == nil) {
        userInformationInstance = [[super alloc] init];
    }
    return userInformationInstance;
}
-(void) setUsername: (NSString*) parameter{
    username = parameter;
}
-(NSString*) getUsername {
    return username;
}

-(void) setPassword: (NSString*) parameter{
    password = parameter;
}
-(NSString*) getPassword {
    return password;
}

-(void) setWeight: (NSNumber*) parameter {
    weight = parameter;
}
-(NSNumber*) getWeight {
    return weight;
}


@end
