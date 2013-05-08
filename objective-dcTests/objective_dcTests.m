//
//  objective_dcTests.m
//  objective-dcTests
//
//  Created by Hank Stoever on 12/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "objective_dcTests.h"
#import "DCClient.h"
#import "DCUser.h"
#import "DCURLParser.h"

@implementation objective_dcTests

- (void)setUp
{
    [super setUp];
    dailycred = [DCClient initWithClientId:@"7ea9b8d5-02c9-425b-87b2-b1855a37cba9" andClientSecret:@"33e355d1-9e39-465e-b8d6-fcc734ce6e37-ee05ae3d-9bbe-4996-b6fd-04fa0341fc7f" withRedirectUri:nil];
    badClient = [[DCClient alloc] initWithClientId:@"client-id" andClientSecret:@"client-secret" withRedirectUri:@"http://redirect-uri.com"];
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testInitSharedClient
{
    DCClient *testClient = [DCClient initWithClientId:@"client_id" andClientSecret:@"client_secret" withRedirectUri:@"myapp://url"];
    STAssertEquals(@"client_id", testClient.clientId, @"client_id should be set");
    STAssertEquals(@"client_secret", testClient.clientSecret,@"client_secret should be set");
    STAssertEquals(@"myapp://url", testClient.redirectUri,@"redirect_uri should be set");
    //make sure the shared client got set correctly too
    testClient = [DCClient sharedClient];
    STAssertEquals(@"client_id", testClient.clientId, @"client_id should be set");
    STAssertEquals(@"client_secret", testClient.clientSecret,@"client_secret should be set");
    STAssertEquals(@"myapp://url", testClient.redirectUri,@"redirect_uri should be set");
}

//To keep track of current user, DCClient serializes the user into NSUserDefaults
//This requires custom encoding, so lets test that all of the properties get passed along correctly
-(void)testUserPersistance{
    DCUser *user = [[DCUser alloc] init];
    user.email = @"test@2.com";
    user.display = @"testuser";
    user.picture = @"https://www.dailycred.com/woah";
    user.uuid = @"dc-id";
    NSDictionary *dummyDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"attribute",@"value", nil];
    user.identities = dummyDictionary;
    user.json = dummyDictionary;
    user.accessTokens = dummyDictionary;
    [DCClient setCurrentUser:user];
    user = [DCClient getCurrentUser];
    STAssertEquals(@"test@2.com", user.email,@"email should be persisted");
    STAssertEquals(@"testuser", user.display,@"display should be persisted");
    STAssertEquals(@"https://www.dailycred.com/woah", user.picture,@"picture should be persisted");
    STAssertEquals(@"dc-id", user.uuid,@"uuid should be persisted");
    STAssertEquals(dummyDictionary, user.accessTokens,@"access tokens should be persisted");
    STAssertEquals(dummyDictionary, user.json,@"json should be persisted");
    STAssertEquals(dummyDictionary, user.identities,@"identities should be persisted");
}

-(void)testURLUtils{
    DCClient *testDailycred = [DCClient initWithClientId:@"client_id" andClientSecret:@"client_secret" withRedirectUri:@"myapp://url"];
    DCURL *url = [testDailycred getURLFromEndpoint:kMeJsonEndpoint];
    STAssertEqualObjects(@"https://www.dailycred.com/graph/me.json",[url absoluteString],@"url should construct correctly");
    url = [testDailycred getAuthURLFromEndpoint:kConnectEndpoint];
    DCURLParser *parser = [[DCURLParser alloc] initWithURLString:[url absoluteString]];
    STAssertEqualObjects([parser valueForVariable:@"client_id"], @"client%5Fid",@"client_id should be set");
    STAssertEqualObjects([parser valueForVariable:@"redirect_uri"], @"myapp%3A%2F%2Furl",@"redirect_uri should be set");
}

-(void)testSignin{
    NSError *error = nil;
    DCUser *user = nil;
    
    //test failed login
    user = [dailycred signinUserWithLogin:@"fakelogin" andPassword:@"password" andError:&error];
    STAssertNotNil(error, @"error should be present");
    STAssertNil(user,@"user should be nil");
    NSString *attribute = [[error userInfo] objectForKey:@"attribute"];
    STAssertEqualObjects(attribute, @"form",@"attribute should be set correctly in form");
    STAssertNotNil(attribute,@"attribute should be present in error");
    
    //test successful login
    error = nil;
    user = [dailycred signinUserWithLogin:@"test@test.test" andPassword:@"password" andError:&error];
    STAssertNil(error,@"error should be nil");
    STAssertNotNil(user,@"user should not be nil");
    STAssertEqualObjects(user.email, @"test@test.test",@"email should be set");
    STAssertEqualObjects(user, [DCClient getCurrentUser],@"current user should be persisted");
    
    
    //test successful signup
    long time = [[NSDate date] timeIntervalSince1970];
    NSString *email = [NSString stringWithFormat:@"testemail%lu@test.test",time];
    user = [dailycred signupOrSigninUserWithLogin:email andPassword:@"password" andError:&error];
    STAssertNil(error,@"error should be nil");
    STAssertNotNil(user,@"user should not be nil");
    STAssertEqualObjects(user.email, email,@"email should be set");
    STAssertEqualObjects(user, [DCClient getCurrentUser],@"current user should be persisted");
}

-(void)testPasswordMethods {
    NSError *error = nil;
    
    long time = [[NSDate date] timeIntervalSince1970];
    NSString *email = [NSString stringWithFormat:@"testemail%lu@test.test",time];
    DCUser *user = [dailycred signupOrSigninUserWithLogin:email andPassword:@"password" andError:&error];
    
    //successful password reset
    error = nil;
    [dailycred resetPasswordForUser:user andError:&error];
    STAssertNil(error,@"password reset should be good");
    
    //try a bad password change
    error = nil;
    [dailycred changePasswordFrom:@"badpassword" to:@"newpassword" forUser:user withError:&error];
    STAssertNotNil(error, @"bad password reset should fail");
    
    //try a good pw change
    error = nil;
    [dailycred changePasswordFrom:@"password" to:@"newpassword" forUser:user withError:&error];
    STAssertNil(error,@"successful password reset should not error");
    
    //try to sign in with new password
    error = nil;
    user = [dailycred signupOrSigninUserWithLogin:email andPassword:@"newpassword" andError:&error];
    STAssertNil(error, @"user should be able to login with new password");
    
    //try to sign in with old password
    error = nil;
    user = [dailycred signupOrSigninUserWithLogin:email andPassword:@"password" andError:&error];
    STAssertNotNil(error, @"user should not be able to login with old password");
}

-(void)testFiringEvents{
    DCUser *user = [self getTestUser];
    NSError *error = nil;
    [dailycred fireEventWithEventType:@"button touched" forUser:user withValue:nil andError:&error];
    STAssertNil(error,@"error should not be nil");
    
    //test bad client
    error = nil;
    [badClient fireEventWithEventType:@"button+touched" forUser:user withValue:@"blah" andError:&error];
    STAssertNotNil(error,@"error should not be nil for failed event");
}

-(void)testTaggingUsers{
    DCUser *user = [self getTestUser];
    NSError *error = nil;
    [dailycred tagUserWithTag:@"awesome" forUser:user andError:&error];
    STAssertNil(error,@"tagging should work");
    
    error = nil;
    [dailycred untagUserWithTag:@"awesome" forUser:user andError:&error];
    STAssertNil(error,@"untagging should work");
    
    //test with a bad client
    error = nil;
    [badClient tagUserWithTag:@"woot" forUser:user andError:&error];
    STAssertNotNil(error,@"tagging with bad client shouldn't work");
    
    error = nil;
    [badClient untagUserWithTag:@"woot" forUser:user andError:&error];
    STAssertNotNil(error,@"untagging shouldnt work with a bad client");
}

-(void)testURLEncoding{
    DCURL *url = [dailycred getAuthURLFromEndpoint:kAccessTokenEndpoint];
    url = [url URLbyAppendingParameterWithKey:@"awesome" andValue:@"magic+email@gmail.com"];
    DCURLParser *parser = [[DCURLParser alloc] initWithURLString:[url absoluteString]];
    NSString *parameter = [parser valueForVariable:@"awesome"];
    STAssertFalse([parameter isEqualToString:@"magic+email@gmail.com"], @"parameter should be encoded");
}


-(DCUser *)getTestUser{
    return [dailycred signinUserWithLogin:@"test@test.test" andPassword:@"password" andError:nil];
}



@end
