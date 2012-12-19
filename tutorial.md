#Creating an iOS app with Dailycred for user accounts

#####[Dailycred](https://www.dailycred.com/) is the fastest and most powerful way to get user accounts set up on your app. Your users will be able to login with an email and password or with a social provider like Facebook or Google.

This tutorial will teach you how to use Dailycred in your iOS application to allow your users to login and display their account information.

### Getting Started

###### Create a Dailycred Account

To follow this tutorial, you will need a free account from [Dailycred](https://www.dailycred.com/). When signing up, simply add `callback` to your approved domains.

![Sign Up](https://raw.github.com/dailycred/objective-dc/master/docs/signup_dc.png)

###### Create a new Xcode project

Open Xcode (or [download](https://itunes.apple.com/us/app/xcode/id497799835?ls=1&mt=12) if you need to) and select **File > New > New Project**. For this tutorial, we will be making a **Single View Application** (even though we will be adding more views later on).

![Page Based](https://raw.github.com/dailycred/objective-dc/master/docs/single_page.png)

Set your **Product Name** and **Company Identifier** to whatever you want, and save the project somewhere.

![Product Name](https://raw.github.com/dailycred/objective-dc/master/docs/product_name.png)



###### Install the Dailycred Library

Follow the [configuring your target](https://github.com/dailycred/objective-dc#installation) instructions for getting the objective-c library installed in Xcode.

###### Setup a custom URL Scheme

Follow the [custom URL scheme instructions](https://github.com/dailycred/objective-dc#custom-url-scheme) for setting up a custom URL scheme (like *myapp://*) to be used in your OAuth callback URL. This will allow you to open your app from a browser, and this step is required to work with Dailycred.

### Building the App

###### Setup the App Delegate

Open your `AppDelegate.m` file. At the top of the file, below the line that says `#import ViewController.h`, insert a line to import the Dailycred client class.

![App Delegate](https://raw.github.com/dailycred/objective-dc/master/docs/app_delegate_1.png)

Head over to your [dailycred settings page](https://www.dailycred.com/admin/settings) and grab your **app's client id** and your **account secret**. Then in the method `application didFinishLaunchingWithOptions` method, add the following line to setup your API keys. Insert your API keys and replace **YOUR-SCHEME** with the custom URL scheme you setup earlier.
	
	[DCClient initWithClientId:@"YOUR-CLIENT-ID" 	andClientSecret:@"YOUR-CLIENT-SECRET" 
	withRedirectUri:@"YOUR-SCHEME://callback"];
	
![App Delegate](https://raw.github.com/dailycred/objective-dc/master/docs/client_init.png)

Your Dailycred client is configured, and we will now setup the first view for signing in.

###### The login view

Open the file `ViewController.xib`. Drag a **Round Rect Button** into the view and give it some text. Open the *Assistant Editor* by choosing the middle *editor* button in the top right, which should expose `ViewController.h`. Hold the control key and click and drag from the rounded rectangle button to the window for `ViewController.h`. Choose **action** as the connection type and call the Name `signupButtonPressed`.

Now go to the file `ViewController.m` and you should see that a new method was created called `- (IBAction)signinButtonPressed:(id)sender`. First add a line to `#import "DCClient.h"`. Then simply add one line to the `signinButtonPressed` method that calls `authorize`.

	- (IBAction)signinButtonPressed:(id)sender {
    	[[DCClient sharedClient] authorize];
	} 
	
Calling `[DCClient sharedClient]` returns an instance of *DCClient* with your API keys already configured. This was setup in your app delegate. Calling the `authorize` method sends your user to *https://www.dailycred.com/oauth/gateway*, which is a page where a user can choose how to sign in. If you provide other API keys for signing in with Facebook or another provider on your [Dailycred identity providers settings page](https://www.dailycred.com/admin/settings/identity-providers), your user will be presented with a form to sign in with either email or any of the identity providers you have specified.