#Objective-DC

#### Objective-DC is an objective-c library for using Dailycred for user authentication in your iOS apps.

You can view a demo app using this library [here](https://github.com/dailycred/ios-example).

There is also a [tutorial](https://github.com/dailycred/objective-dc/blob/master/tutorial.md) that walks you through creating an app from scratch with Dailycred.

##Installation
###Download

To get started, first clone this repository in your app's file directory:

    cd your_app_directory
    git clone git://github.com/dailycred/objective-dc.git

Open XCode, right click on your main project file in the navigation window and click `Add Files to your_app_name`. Choose the `objective-dc.xcodeproj` file that you just downloaded.

![Add Files](https://raw.github.com/dailycred/objective-dc/master/docs/add_files.png)

Now that you've added the project to your app, there are a few settings you need to configure.

### Configuring Your Target

###### Some of the pictures for this section were copied from the wonderful [RestKit](https://github.com/RestKit/RestKit) library's documentation. If you are confused when you see "ReskKit" in the pictures, assume it will be "objective-dc".

Now that your project is aware of Objective-DC, you need to configure a few settings and add some required Frameworks to your project's build configuration. Click on the top-most item in the Project Navigator to open the Project and Targets configuration pane.

Then click on the **Build Settings** item and input "other linker flags" into the search text box in the top right of the main editing pane. Double click on the build Setting titled **Other Linker Flags**. A panel will pop open prompting you to input the Linker Flags you wish to add. Input **-ObjC -all_load** and hit Done.

NOTE: Try removing the -all_load flag if you are receiving runtime errors related to selectors not being found, even though you followed all the steps faithfully.

![Add Linker Flag](https://github.com/RestKit/RestKit/raw/master/Docs/Images/Installation/03_Add_Linker_Flag.png)

After configuring the Linker Flag, clear the text from the search box and input **header search path**. Double click on the build setting titled **Header Search Paths**. A panel will pop open prompting you to input the Header Search Path you wish to add. Input **"$(BUILT_PRODUCTS_DIR)/../../Headers"**. Be sure to include the surrounding quotes (-- they are important!) and hit Done.
![Add Header Search Path](https://raw.github.com/dailycred/objective-dc/master/docs/header_search_paths.png)

Now click on the **Build Phases** tab and click the disclosure triangle next to the item titled **Target Dependencies**. A sheet will pop open asking you to select the target you want to add a dependency on. Click **objective-dc** and hit the **Add** button.
![Add Target Dependency](https://github.com/RestKit/RestKit/raw/master/Docs/Images/Installation/04_Add_Target_Dependency.png)
![Select RestKit Target](https://raw.github.com/dailycred/objective-dc/master/docs/target_dependencies.png)

Once the Target Dependency has been configured, you now need to link the Objective-DC static libraries and the required Frameworks into your target. Click the disclosure triangle next to the item labeled **Link Binary With Libraries** and click the plus button:
![Add Libraries](https://raw.github.com/dailycred/objective-dc/master/docs/link_binary.png)

Select the Objective-DC static library.

You are all set for using Objective-DC in your application. <strong>To make sure everything is working, open a file and insert `#import "DCClient.h"` at the top of the file. Build the project with <code><span>&#8984; + b</span></code>. If no error is seen, everything should be working well.</strong>

If you are still experiencing difficulties, copying the header files from `objective-dc` to your main file tree may fix compilation errors. Open the `objective-dc.xcodeproj` folder and `objective-dc` subfolder in your project navigator. Select the 4 headers files (the ones that end in `.h`) and drag them into a folder called `Headers` in your main folder.

![Copy Headers](https://raw.github.com/dailycred/objective-dc/master/docs/copy_headers.png)


## Custom URL scheme

You will need to setup a custom URL scheme to open your application from a browser. This will allow you to use links like `myappcustomscheme://url` to open your app from a browser (when your app is installed on the same device).

Open the **info** tab in your target settings. Click the plus sign in the bottom right and select **Add URL Type**.
![Add URL Type](https://raw.github.com/dailycred/objective-dc/master/docs/add_url_type.png)

Configure your URL Type with your own unique url scheme and identifier. Choose something like **com.myappname** for the Identifier and **myappname** for the URL schemes.
![Configure URL Type](https://raw.github.com/dailycred/objective-dc/master/docs/url_type_settings.png)

You can now open your app from a link by using the URL scheme that you created. This will be used for redirecting your user back to your application after authenticating. Your `redirect_uri` must use this URL scheme with any domain (Dailycred currently requires a domain for `redirect_uri`). Make sure you approve whatever fake domain name you choose to use in your Dailycred settings. For example, if you choose to use **fakedomainname** with your custom URL scheme of **myappscheme**, your `redirect_uri` would be **myappscheme://fakedomainname**.

![Dailycred Settings](https://raw.github.com/dailycred/objective-dc/master/docs/dailycred_settings.png)

## Usage

If you've made it here, the rest is easy. At the very beginning of your application, configure the Dailycred Client with your `client_id`,`client_secret`, and optionally your `redirect_uri`.

    [DCClient initWithClientId:@"YOUR_CLIENT_ID" andClientSecret:@"YOUR_CLIENT_SECRET" withRedirectUri:@"myappscheme://fakedomainname"];

This sets up a singleton client that can be accessed at `[DCClient sharedClient]`. To send a user to be authenticated, simply call

    [[DCClient sharedClient] authorize];

This will send a user to `https://www.dailycred.com/oauth/gateway` with your proper API keys attached. To sign them in with a specific service, call:

    [[DCClient sharedClient] authorizeWithIdentityProvider:@"facebook"];

This will send the user to `https://www.dailycred.com/connect?identiy_provider=facebook`.

After successfully connecting, the user will be sent back to your app. Implement `handleOpenURL` in your `appDelegate` and tell the Dailycred client to authenticate.

    - (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
    {
        [[DCClient sharedClient] authenticateWithCallbackUrl:[url absoluteString]];
        NSLog(@"current user is: %@",[DCClient getCurrentUser]);

        //handle the new authenticated user

        return YES;
    }

The client will then go through the entire OAuth flow and retrieve the user's details. The client serializes the user object in `NSUserDefaults` so that you can access the current user even after the app is closed. You can get all sorts of information about the user:

    DCUser *user = [DCClient getCurrentUser];
    NSLog(@"email: %@",user.email);
    NSLog(@"display: %@",user.display);
    NSLog(@"picture url: %@",user.picture);
    NSLog(@"access tokens: %@",user.accessTokens);
    NSLog(@"identities: %@",user.identities);
    NSLog(@"json response: %@",user.json); //returns a dictionary of the json response from https://www.dailycred.com/graph/me.json

    // For example, this code could display information from facebook if the user connected with facebook.

    DCUser *user = [DCClient getCurrentUser];
    NSDictionary *facebook = [user.identities objectForKey:@"facebook"];
    if (facebook != nil){
        NSString *facebookLink = [facebook objectForKey:@"link"];
        NSLog("link to user's facebook: %@", facebookLink); // http://www.facebook.com/username
    }

    // Or with GitHub:

    NSDictionary *github = [user.identities objectForKey:@"github"];
    if (github != nil){
        NSNumber *followers = [github objectForKey:@"followers"];
        NSNumber *publicRepos = [github objectForKey:@"public_repos"];
    }


You can log out the current user:

    [DCClient logout];

You can also login or sign up a user with just an email and password:

    DCClient *dailycred = [DCClient sharedClient];
    DCUser *user = [dailycred signinUserWithLogin:@"fakelogin@example.com" andPassword:@"password" andError:&error];

    //this call will sign in or create a new user
    user = [dailycred signupOrSigninUserWithLogin:@"fakelogin@example.com" andPassword:@"password" andError:&error];

    //if signin or signup is successful, the user is persisted
    DCUser *sameUser = [DCClient getCurrentUser];

Connect an existing user with another identity provider to get more social information:

    DCUser *user = [DCClient getCurrentUser];
    [[DCClient sharedClient] connectUser:user withIdentityProvider:@"google"];

Allow your users to reset their password via email or with a "Change password" form in your app

    DCUser *user = [DCClient getCurrentUser];
    [[DCClient sharedClient] resetPasswordForUser:user andError:nil];

    [[DCClient sharedClient] changePasswordFrom:oldPassword to:newPassword forUser:user withError:&error];

Fire custom events see user activity on your Dailycred dashboard

    DCUser *user = [CClient getCurrentUser];
    [DCClient sharedClient] fireEventWithEventType:@"level completed" forUser:user withValue:@"temple of doom" andError:nil];

    // 'value' for event can be nil
    [DCClient sharedClient] fireEventWithEventType:@"finished onboarding" forUser:user withValue:nil andError:nil];

Tag users for performing special queries on your dailycred dashboard

    DCUser *user = [CClient getCurrentUser];
    [DCClient sharedClient] tagUserWithTag:@"expert" forUser:user andError:nil];

    [DCClient sharedClient] untagUserWithTag:@"expert" forUser:user andError:nil];


![](https://www.dailycred.com/dc.gif?client_id=dailycred&title=objc_repo "dailycred")