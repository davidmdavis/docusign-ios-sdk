DocuSign iOS SDK Beta
=========================================

This **BETA** SDK is built on our public [REST API](https://www.docusign.com/p/RESTAPIGuide/RESTAPIGuide.htm) and provides a quick and easy way for developers to add DocuSign's world-class document signing experience to their native iOS apps.

Pre-requisites
----------

### DocuSign Developer account (Free)

You can create your free dev account at the [DocuSign DevCenter](https://www.docusign.com/developer-center) using this [registration from](https://www.docusign.com/developer-center/get-started). You will need the **Integrator Key** from your developer account in order to use the DocuSign iOS SDK.

### Useful Reading

See [Common Terms](https://www.docusign.com/developer-center/explore/common-terms) for an explantion of the basic components of the DocuSign platform.

Quickstart Guide
----------

### Add the SDK using CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C projects. It is distributed as a ruby gem and can be installed using:

```bash
$ gem install cocoapods # This may require sudo
```

Once you have CocoaPods installed, create a file called `podfile` in the root directory of your Xcode project, and add the following:

```ruby
platform :ios, '7.0'

pod 'DocuSign-iOS-SDK'
```

Then in the same directory as your podfile run

```bash
$ pod install
```

This will update or create a workspace that includes the DocuSign iOS SDK and all its dependencies combined with your project. `pod install` fetches the latest version of the SDK. After installation, you can update all your CocoaPods dependencies using `pod update`. For more options on how to manage dependencies see the official [CocoaPods guide](http://guides.cocoapods.org/using/the-podfile.html).

**NOTE:  From now on to run your project you must use the `.xcworkspace`, *NOT* the `.xcodeproj`**

### Import the Headers

Everything you need in order to use the DocuSign iOS SDK can be imported using the following:

```objective-c
#import <DocuSign-iOS-SDK/DocuSign-iOS-SDK.h>
```

### Authenticate with DocuSign

There are several authentication options, depending on how your workflow integrates with DocuSign.

#### Present a login view to your user

If the user has a DocuSign account, you can present a `DSLoginViewController` and receive an authenticated `DSSessionManager` instance.

First, present the `DSLoginViewController`:
```objective-c
DSLoginViewController *loginViewController = [[DSLoginViewController alloc] initWithIntegratorKey:@"<#IntegratorKey#>"
                                                                                   forEnvironment:DSRestAPIEnvironmentDemo
                                                                                            email:@"<#email#>" //This will pre-populate the UI
                                                                                         delegate:self];
UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
[self presentViewController:navController animated:YES completion:nil];
```

Then implement the `DSLoginViewControllerDelegate` methods:

```objective-c
- (void)loginViewController:(DSLoginViewController *)controller didLoginWithSessionManager:(DSSessionManager *)sessionManager {
    self.sessionManager = sessionManager;
    [self dismissViewControllerAnimated:YES completion:nil];
    // Make API calls!
}


- (void)loginViewControllerCancelled:(DSLoginViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

```


#### Authenticate programmatically

If your app is already integrated with DocuSign, you may have authenticated via some other means. We support two methods of programmatic authentication.

Using a DocuSign OAuth token:

```objective-c
self.sessionManager = [[DSSessionManager alloc] initWithIntegratorKey:@"<#IntegratorKey#>"
                                                       forEnvironment:DSRestAPIEnvironmentDemo
                                                            authToken:@"<#AuthToken#>"
                                                         authDelegate:self];
[self.sessionManager authenticate];
```

Using a username and password:

```objective-c
self.sessionManager = [[DSSessionManager alloc] initWithIntegratorKey:@"<#IntegratorKey#>"
                                                       forEnvironment:DSRestAPIEnvironmentDemo
                                                             username:@"<#email#>"
                                                             password:@"<#password#>"
                                                         authDelegate:self];
[self.sessionManager authenticate];
```

When the session manager gets authentication results, it will call back to the delegate specified in `authDelegate:`, after which you will be able to use the rest of the SDK's functionality. If the user belongs to more than one DocuSign account, these methods with authenticate with the default account. If you wish to choose a specifc account, implement the optional delegate method `-sessionManager:chooseAccountIDFromAvailableAccounts:completeAuthenticationHandler`.

### Sign a Document (`DSSigningViewController`)

#### Get an envelope to sign

If you have created an envelope elsewhere and you already have the `envelopeId` or `recipientId`, you can simply present a `DSSigningViewController`:

```objective-c
DSSigningViewController *signingViewController = [self.sessionManager signingViewControllerForRecipientWithID:@"<#recipientId#>"
                                                                                             inEnvelopeWithID:@"<#envelopeId#>"
                                                                                                     delegate:self];
UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:signingViewController];
[self presentViewController:navController animated:YES completion:nil];
```

If you have a file in that needs to be signed, create a DocuSign envelope and present a `DSSigningViewController`:

```objective-c
[self.sessionManager startCreateSelfSignEnvelopeTaskWithFileName:@"<#NewFileName#>" fileURL:<#LocalFileURL#> completionHandler:^(DSCreateEnvelopeResponse *response, NSError *error) {
    if (error) {
        // Handle the error
        return;
    }
    DSSigningViewController *signingViewController = [self.sessionManager signingViewControllerForRecipientWithID:nil
                                                                                                 inEnvelopeWithID:response.envelopeID
                                                                                                         delegate:self];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:signingViewController];
    [self presentViewController:navController animated:YES completion:nil];
}];
```

#### Implement `DSSigningViewControllerDelegate`

```objective-c
- (void)signingViewController:(DSSigningViewController *)signingViewController completedWithStatus:(DSSigningCompletedStatus)status {
    [self dismissViewControllerAnimated:YES completion:^{
        switch (status) {
            case DSSigningCompletedStatusSigned: {
                // Handle signed envelope
                break;
            }
            case DSSigningCompletedStatusDeferred:
                // Handle deferred envelope
                break;
            case DSSigningCompletedStatusDeclined:
                // Handle declined envelope
                break;
        }
    }];
}


- (void)signingViewController:(DSSigningViewController *)signingViewController failedWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:^{
        // handle error
    }];
}
```

License
----------

The DocuSign iOS SDK is licensed under the [DOCUSIGN Mobile iOS SDK LICENSE](LICENSE).
