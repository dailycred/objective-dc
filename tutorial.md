#Creating an iOS app with Dailycred for user accounts

#####[Dailycred](https://www.dailycred.com/) is the fastest and most powerful way to get user accounts set up on your app. Your users will be able to login with an email and password or with a social provider like Facebook or Google.

This tutorial will teach you how to use Dailycred in your iOS application to allow your users to login and display their account information.

### Getting Started

###### Create a Dailycred Account

To follow this tutorial, you will need a free account from [Dailycred](https://www.dailycred.com/). When signing up, simply add `localhost` to your approved domains.

![Sign Up](https://raw.github.com/dailycred/objective-dc/master/docs/signup_dc.png)

###### Create a new Xcode project

Open Xcode (or [download](https://itunes.apple.com/us/app/xcode/id497799835?ls=1&mt=12) if you need to) and select **File > New > New Project**. For this tutorial, we will be making a **Single View Application** (even though we will be adding more views later on).

![Page Based](https://raw.github.com/dailycred/objective-dc/master/docs/single_view.png)

Set your **Product Name** and **Company Identifier** to whatever you want, and save the project somewhere.

![Product Name](https://raw.github.com/dailycred/objective-dc/master/docs/product_name.png)



###### Install the Dailycred Library

Follow the [installation](https://github.com/dailycred/objective-dc#installation) instructions for getting the objective-c library installed in Xcode.

###### Setup a custom URL Scheme

Follow the [custom URL scheme instructions](https://github.com/dailycred/objective-dc#custom-url-scheme) for setting up a custom URL scheme (like *myapp://*) to be used in your OAuth callback URL. This will allow you to open your app from a browser, and this step is required to work with Dailycred.

### Building the App

###### Setup the App Delegate

Open your `AppDelegate.m` file. At the top of the file, below the line that says `#import ViewController.h`, insert a line to import the Dailycred client class.

![App Delegate](https://raw.github.com/dailycred/objective-dc/master/docs/app_delegate_1.png)

Head over to your [dailycred settings page](https://www.dailycred.com/admin/settings) and grab your app's **client id** and your **account secret**. Then in the method `application didFinishLaunchingWithOptions` method, add the following line to setup your API keys. Insert your API keys and replace **YOUR-SCHEME** with the custom URL scheme you setup earlier.
	
	[DCClient initWithClientId:@"YOUR-CLIENT-ID" 	andClientSecret:@"YOUR-CLIENT-SECRET" 
	withRedirectUri:@"YOUR-SCHEME://callback"];
	
![App Delegate](https://raw.github.com/dailycred/objective-dc/master/docs/client_init.png)

Your Dailycred client is configured, and we will now setup the first view for signing in.

###### The login view

Open the file `ViewController.xib`. Drag a **Round Rect Button** into the view and give it some text. Open the *Assistant Editor* by choosing the middle *editor* button in the top right, which should expose `ViewController.h`. Hold the control key and click and drag from the rounded rectangle button to the window for `ViewController.h`. Choose **action** as the connection type and call the Name `signinButtonPressed`.

![Signup Button](https://raw.github.com/dailycred/objective-dc/master/docs/signin_button_connect.png)

Now go to the file `ViewController.m` and you should see that a new method was created called `- (IBAction)signinButtonPressed:(id)sender`. First add a line at the top with `#import "DCClient.h"`. Then simply add one line to the `signinButtonPressed` method that calls `authorize`.

	- (IBAction)signinButtonPressed:(id)sender {
    	[[DCClient sharedClient] authorize];
	} 
	
Calling `[DCClient sharedClient]` returns an instance of *DCClient* with your API keys already configured. This was setup in your app delegate. Calling the `authorize` method sends your user to *https://www.dailycred.com/oauth/gateway*, which is a page where a user can choose how to sign in. If you provide other API keys for signing in with Facebook or another provider on your [Dailycred identity providers settings page](https://www.dailycred.com/admin/settings/identity-providers), your user will be presented with a form to sign in with either email or any of the identity providers you have specified. Otherwise, they will see a form to sign up or sign in with an email and password.

![Gateway Auth](https://raw.github.com/dailycred/objective-dc/master/docs/auth_gateway.png)
![Email Auth](https://raw.github.com/dailycred/objective-dc/master/docs/auth_email.png)

At this point, you are free to sign up for your app! If you configured your URL scheme properly, the app should have been re-opened after authenticating. However, nothing happens when the app is opened again. We have to respond the app being opened with a custom URL.

######Authenticate

To do this, implement the function `- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url` in `AppDelegate.m`. In the function, call `authenticateWithCallbackUrl` on the shared client like so:

	- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
	{   
	    [[DCClient sharedClient] authenticateWithCallbackUrl:[url absoluteString]];
	    DCUser *user = [DCClient getCurrentUser];
	    NSLog(@"current user is: %@", user);
	    return YES;
	}
	
When you call `authenticateWithCallbackURL`, the client parses the callback URL and goes through the whole OAuth flow. It also serializes a `DCUser` instance in `NSUserDefaults` so that you can access the current user at any point in your application by calling `[DCClient getCurrentUser]`. 

######User View Controller

We will now create a new view controller for displaying the user's information. In Xcode, choose **File > New > File**. Select the *Cocoa Touch* subsection on the left and choose **Objective-C class**. Name the class *UserViewController* or something similar and make sure it subclasses *UIViewController*. Also make sure that the option *With XIB for User Interface* is checked.
	
![User View Controller](https://raw.github.com/dailycred/objective-dc/master/docs/user_view_controller.png)

Now open the newly created file `UserViewController.xib`. Drag a *Label* onto the view wherever you please. This will show the user's `display` property. Once again show the assistant editor in Xcode by clicking the option in the top right or by hitting **option-command-return**. Hold the control key and drag from the label to `UserViewController.h`. Choose **Outlet** for the connection type and name it **displayField**.

![Display Field](https://raw.github.com/dailycred/objective-dc/master/docs/display_field.png)

Open `UserViewController.m` and add `#import "DCClient.h"`. In the `viewDidLoad` method, add a few lines to populate the `displayField` that we just set up:

	- (void)viewDidLoad
	{
	    [super viewDidLoad];
	    
	    DCUser *user = [DCClient getCurrentUser];
	    if (user != nil){
	        [displayField setText: user.display];
	    }
	    
	    // Do any additional setup after loading the view from its nib.
	}


We now can use this basic view to display the user's data when they return from our app after logging in. Open `AppDelegate.h` and add a property for the new `userViewController`. The file should then look like this: 

	#import <UIKit/UIKit.h>

	@class ViewController;
	@class UserViewController;
	
	@interface AppDelegate : UIResponder <UIApplicationDelegate>
	
	@property (strong, nonatomic) UIWindow *window;
	
	@property (strong, nonatomic) ViewController *viewController;
	@property (strong, nonatomic) UserViewController *userViewController;
	
	@end

Open `AppDelegate.m` and add `#import "UserViewController.h"` at the top. Add a line below your `@implementation` declaration to synthesize your *userViewController* by inserting `@synthesize userViewController = _userViewController;`. In the method `didFinishLoadingWithOptions` add a line to instantiate your *userViewController*.

    self.userViewController = [[UserViewController alloc] initWithNibName:@"UserViewController" bundle:nil];
    
The top part of your `AppDelegate.m` file should now look like this:

	#import "AppDelegate.h"
	
	#import "ViewController.h"
	#import "UserViewController.h"
	#import "DCClient.h"
	
	@implementation AppDelegate
	
	@synthesize window = _window;
	@synthesize viewController = _viewController;
	@synthesize userViewController = _userViewController;
	
	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
	{
	    [DCClient initWithClientId:@"YOUR-CLIENT-ID" andClientSecret:@"YOUR-CLIENT-SECRET" withRedirectUri:@"YOUR-SCHEME://localhost"];
	    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	    // Override point for customization after application launch.
	    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
	    self.userViewController = [[UserViewController alloc] initWithNibName:@"UserViewController" bundle:nil];
	    self.window.rootViewController = self.viewController;
	    [self.window makeKeyAndVisible];
	    return YES;
	}
	
We now need to go back to where we handle the callback URL and tell our app to open *userViewController* after authenticating. We still need to make sure that the current user isn't *nil* after authenticating, as it may have an error or the user may have cancelled authentication. Add a few lines to the `application handleOpenURL` method to look like this:

	- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
	{   
	    [[DCClient sharedClient] authenticateWithCallbackUrl:[url absoluteString]];
	    DCUser *user = [DCClient getCurrentUser];
	    if (user != nil){
	        self.window.rootViewController = self.userViewController;
	    } else {
	        self.window.rootViewController = self.viewController;
	    }
	    [self.window makeKeyAndVisible];
	    NSLog(@"current user is: %@", user);
	    return YES;
	}
	
Now run your app again and authenticate. After authenticating, you should see *userViewController*, and the *displayField* text should display your email or name or username, depending on how you authenticated.

####### Remembering the user

Since the user is automatically serialized, you can check whether a user was already logged in when the app is opened. We can edit our `application didFinishLaunchingWithOptions` method to check for whether the current user is *nil* and display the appropriate view controller. 

	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
	{
	    [DCClient initWithClientId:@"YOUR-CLIENT-ID" andClientSecret:@"YOUR-CLIENT-SECRET" withRedirectUri:@"YOUR-SCHEME://localhost"];
	    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	    // Override point for customization after application launch.
	    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
	    self.userViewController = [[UserViewController alloc] initWithNibName:@"UserViewController" bundle:nil];
	    
	    if ([DCClient getCurrentUser] != nil){
	        self.window.rootViewController = self.userViewController;
	    } else {
	        self.window.rootViewController = self.viewController;
	    }
	    
	    [self.window makeKeyAndVisible];
	    return YES;
	}
	
######Logging out

We need a way for our user to logout of the application. Add a button to `UserViewController.xib` which will be used for logging out. With the assistant editor open, hold *control* and click on the button and drag to `UserViewController.h`. Add an **outlet** connection called **logoutButtonPressed**.

![Logout Button](https://raw.github.com/dailycred/objective-dc/master/docs/logout_button.png)

Open `UserViewController.m` and implement the **logoutButtonPressed** method. This will call `[DCClient logout]`, which removes the *current user* from `NSUserDefaults`. You also need to open the `ViewController` view so the user can sign in again. First add `#import "ViewController.h"` to the top of the file, and then implement **logoutButtonPressed** like so:

	- (IBAction)logoutButtonPressed:(id)sender {
	    [DCClient logout];
	    ViewController *vc = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
	    [[UIApplication sharedApplication].delegate window].rootViewController = vc;
	    [[[UIApplication sharedApplication].delegate window] makeKeyAndVisible];
	}
	
## Congratulations!

You've setup an iPhone app that has a fully functional user account system. Although the app isn't very pretty at this point, you can use this code as a starting point to build a real application. 

### Next steps

You can do so much more with *objective-dc* then we have covered here. Here are some examples

* Build your own login forms and use `-(DCUser *)signupOrSigninUserWithLogin:(NSString *)login andPassword:(NSString *) password andError:(NSError **)error;` so the user never has to leave your app to sign in with an email and password.

* Display more of the user's information:

		DCUser *user = [DCClient getCurrentUser];
	    NSLog(@"email: %@",user.email);
	    NSLog(@"display: %@",user.display);
	    NSLog(@"picture url: %@",user.picture);
	    NSLog(@"access tokens: %@",user.accessTokens);
	    NSLog(@"identities: %@",user.identities);
	    NSLog(@"json response: %@",user.json); //returns a dictionary of the json response from https://www.dailycred.com/graph/me.json
	    
	For example, this code could display information from facebook if the user connected with facebook.
	
		DCUser *user = [DCClient getCurrentUser];
		NSDictionary *facebook = [user.identities objectForKey:@"facebook"];
		if (facebook != nil){
			NSString *facebookLink = [facebook objectForKey:@"link"];
			NSLog("link to user's facebook: %@", facebookLink); // http://www.facebook.com/username
		}
		
	Or with GitHub:
	
		NSDictionary *github = [user.identities objectForKey:@"github"];
		if (github != nil){
			NSNumber *followers = [github objectForKey:@"followers"];
			NSNumber *publicRepos = [github objectForKey:@"public_repos"];
		}

* Implement custom buttons to signin with a specific identity provider:

		//sends the user directly to twitter for signin
		[[DCClient sharedClient] authorizeWithIdentityProvider:@"twitter"];
		
* Connect an existing user with another identity provider to get more social information:

		DCUser *user = [DCClient getCurrentUser];
		[[DCClient sharedClient] connectUser:user withIdentityProvider:@"google"];



