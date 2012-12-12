#Objective-DC

#### Objective-DC is an objective-c library for using Dailycred for user authentication in your iOS apps.

This library is very new, so there may be bugs. Please report a bug by creating an issue in this repository or email `support@dailycred.com`.

To get started, first clone this repository in your app's file directory:

    cd your_app_directory
    git clone git://github.com/dailycred/objective-dc.git

Open XCode, right click on your main project file in the navigation window and click `Add Files to your_app_name`. Choose the `objective-dc.xcodeproj` file that you just downloaded.

Now that you've added the project to your app, there are a few settings you need to configure.

## Configuring Your Target

###### Many of the instructions for this section were copied from the wonderful [RestKit](https://github.com/RestKit/RestKit) library.

Now that your project is aware of Objective-DC, you need to configure a few settings and add some required Frameworks to your project's build configuration. Click on the top-most item in the Project Navigator to open the Project and Targets configuration pane. 

Then click on the **Build Settings** item and input "other linker flags" into the search text box in the top right of the main editing pane. Double click on the build Setting titled **Other Linker Flags**. A panel will pop open prompting you to input the Linker Flags you wish to add. Input **-ObjC -all_load** and hit Done.
```
NOTE: Try removing the -all_load flag if you are receiving runtime errors related to selectors not being found, even though you followed all the steps faithfully.
```
![Add Linker Flag](https://github.com/RestKit/RestKit/raw/master/Docs/Images/Installation/03_Add_Linker_Flag.png)

After configuring the Linker Flag, clear the text from the search box and input "_header search path_". Double click on the build setting titled **Header Search Paths**. A panel will pop open prompting you to input the Header Search Path you wish to add. Input **"$(BUILT_PRODUCTS_DIR)/../../Headers"**. Be sure to include the surrounding quotes (-- they are important!) and hit Done.
![Add Header Search Path](https://github.com/RestKit/RestKit/raw/development/Docs/Images/Installation/03_Add_Header_Search_Path.png)

Now click on the **Build Phases** tab and click the disclosure triangle next to the item titled **Target Dependencies**. A sheet will pop open asking you to select the target you want to add a dependency on. Click **Objective-DC** and hit the **Add** button.
![Add Target Dependency](https://github.com/RestKit/RestKit/raw/master/Docs/Images/Installation/04_Add_Target_Dependency.png)
![Select RestKit Target](https://github.com/RestKit/RestKit/raw/master/Docs/Images/Installation/05_Select_RestKit_Target.png)

Once the Target Dependency has been configured, you now need to link the Objective-DC static libraries and the required Frameworks into your target. Click the disclosure triangle next to the item labeled **Link Binary With Libraries** and click the plus button:
![Add Libraries](https://github.com/RestKit/RestKit/raw/master/Docs/Images/Installation/06_Add_Libraries.png)

Select the Objective-DC static library.

You are all set for using Objective-DC in your application. To make sure everything is working, open a file and insert `#import "DCClient.h"` at the top of the file. If no error is seen, everything should be working well.

## Usage

You will need to setup a custom **http scheme** to open your application from a browser. View [these instructions] to see how to setup a custom url scheme for your app.

At the very beginning of your application, configure the Dailycred Client with your `client_id`,`client_secret`, and optionally your `redirect_uri`.

    DCClient *dailycred = [DCClient initWithClientId:@"YOUR_CLIENT_ID" andClientSecret:@"YOUR_CLIENT_SECRET" withRedirectUri:@"myapp://localhost"];

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
    //user.email;
    //user.display;
    //user.picture;
    //user.accessTokens;
    //user.identities;
    //user.json; //returns a dictionary of the json response from https://www.dailycred.com/graph/me.json

You can log out the current user:

    [DCClient logout];