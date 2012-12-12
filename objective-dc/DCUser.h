//
//  DCUser.h
//  DailycredExample
//
//  Created by Hank Stoever on 12/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCUser : NSObject

@property (strong) NSString *uuid;
@property (strong) NSString *email;
@property (strong) NSString *display;
@property (strong) NSString *picture;
@property (strong) NSDictionary *identities;
@property (strong) NSDictionary *accessTokens;
@property (strong) NSDictionary *json;

-(DCUser *)initWithAccessToken:(NSString *)accessToken;
-(BOOL)hasIdentity:(NSString *)provider;
-(NSDictionary *)getIdentityForProvider:(NSString *)provider;
-(NSString *)getAccessTokenForProvider:(NSString *)provider;

-(void)encodeWithCoder:(NSCoder *)encoder;
- (id)initWithCoder:(NSCoder *)decoder;
@end
