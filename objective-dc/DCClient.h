//
//  DCClient.h
//  DailycredExample
//
//  Created by Hank Stoever on 12/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCUser.h"
#import "DCURL.h"

@interface DCClient : NSObject

extern NSString* const kAuthEndpoint;
extern NSString* const kGatewayEndpoint;
extern NSString* const kConnectEndpoint;
extern NSString* const kAccessTokenEndpoint;
extern NSString* const kMeJsonEndpoint;
extern NSString* const kCurrentUserKey;
extern NSString* const kSigninEndpoint;
extern NSString* const kSignupEndpoint;

@property (strong) NSString *clientId;
@property (strong) NSString *clientSecret;
@property (strong) NSString *redirectUri;
@property (strong) NSString *baseUri;
@property (strong) NSArray *identityProviders;

+(DCClient*) initWithClientId:(NSString*) clientId andClientSecret:(NSString*)clientSecret withRedirectUri:(NSString *)redirectUri;

-(void) authorize;

-(void) authorizeWithIdentityProvider:(NSString *)identityProvider;

-(void) authenticateWithCallbackUrl:(NSString *) callback;

-(void) connectUser:(DCUser *)user withIdentityProvider:(NSString *)identityProvider;

-(NSString *)getAccessTokenFromCode:(NSString *)code;

-(NSDictionary *)getUserJsonFromAccessToken:(NSString *)accessToken;

-(DCUser *)signinUserWithLogin:(NSString *)login andPassword:(NSString *)password andError:(NSError **)error;

-(DCUser *)signupOrSigninUserWithLogin:(NSString *)login andPassword:(NSString *) password andError:(NSError **)error;

-(DCURL *)getAuthURLFromEndpoint:(NSString *)endpoint;
-(DCURL *)getURLFromEndpoint:(NSString *)endpoint;

+(DCClient *)sharedClient;
+(DCUser *)getCurrentUser;
+(void)setCurrentUser:(DCUser *)user;
+(void)logout;


@end
