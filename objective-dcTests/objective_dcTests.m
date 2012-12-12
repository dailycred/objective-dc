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
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testInitSharedClient
{
    DCClient *dailycred = [DCClient initWithClientId:@"client_id" andClientSecret:@"client_secret" withRedirectUri:@"myapp://url"];
    STAssertEquals(@"client_id", dailycred.clientId, @"client_id should be set");
    STAssertEquals(@"client_secret", dailycred.clientSecret,@"client_secret should be set");
    STAssertEquals(@"myapp://url", dailycred.redirectUri,@"redirect_uri should be set");
    //make sure the shared client got set correctly too
    dailycred = [DCClient sharedClient];
    STAssertEquals(@"client_id", dailycred.clientId, @"client_id should be set");
    STAssertEquals(@"client_secret", dailycred.clientSecret,@"client_secret should be set");
    STAssertEquals(@"myapp://url", dailycred.redirectUri,@"redirect_uri should be set");
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
    DCClient *dailycred = [DCClient initWithClientId:@"client_id" andClientSecret:@"client_secret" withRedirectUri:@"myapp://url"];
    DCURL *url = [dailycred getURLFromEndpoint:kMeJsonEndpoint];
    STAssertEqualObjects(@"https://www.dailycred.com/graph/me.json",[url absoluteString],@"url should construct correctly");
    url = [dailycred getAuthURLFromEndpoint:kConnectEndpoint];
    DCURLParser *parser = [[DCURLParser alloc] initWithURLString:[url absoluteString]];
    STAssertEqualObjects([parser valueForVariable:@"client_id"], @"client_id",@"client_id should be set");
    STAssertEqualObjects([parser valueForVariable:@"redirect_uri"], @"myapp://url",@"redirect_uri should be set");
}

@end
