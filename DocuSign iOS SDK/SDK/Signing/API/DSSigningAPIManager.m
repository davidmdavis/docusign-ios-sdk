//
//  DSSigningAPIManager.m
//  DocuSignIt
//
//  Created by Stephen Parish on 12/12/13.
//  Copyright (c) 2013 DocuSign, Inc. All rights reserved.
//

#import "DSSigningAPIManager.h"

#import <CoreLocation/CoreLocation.h>

#import <Mantle/Mantle.h>

#import "DSSigningAPIDeclineOptions.h"
#import "DSSigningAPIDeclineSigning.h"
#import "DSSigningAPICanFinishChanged.h"
#import "DSSigningAPIConsumerDisclosure.h"
#import "DSSigningAPIAdoptSignatureTabDetails.h"
#import "DSSigningAPIAddCCRecipients.h"
#import "DSSigningCompletedStatus.h"

#import "NSURL+DS_QueryDictionary.h"

@import WebKit;

static NSString * const DS_SIGNING_API = @"DSSigning";
static NSString * const DS_SIGNING_STARTED_HANDLER = @"DSSigningStartedHandler";
static NSString * const DS_SIGNING_MESSAGE_HANDLER = @"DSSigningMessageHandler";
static NSString * const DS_SIGNING_API_TABS[] = {
    @"null",
    @"'SignHere'",
    @"'InitialHere'",
    @"'FullName'",
    @"'DateSigned'",
    @"'TextMultiline'",
    @"'Checkbox'",
    @"'Company'",
    @"'Title'"
};

@interface DSSigningAPIManager() <CLLocationManagerDelegate, WKScriptMessageHandler, WKNavigationDelegate>

@property (nonatomic) NSURL *messageURL;

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) BOOL awaitingFirstMessage;

@end

@implementation DSSigningAPIManager

@dynamic ready;

#pragma mark - Lifecycle

- (instancetype)initWithViewFrame:(CGRect)frame messageURL:(NSURL *)messageURL andDelegate:(id<DSSigningAPIDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _messageURL = messageURL;
        
        // relay signing api messages to us
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        [config.userContentController addScriptMessageHandler:self name:DS_SIGNING_MESSAGE_HANDLER];
        [config.userContentController addScriptMessageHandler:self name:DS_SIGNING_STARTED_HANDLER];
        
        // add script to init signing api on page load finish
        NSString *signingApiInitJs = [NSString stringWithFormat:
                                      @"DSSigning.init({"
                                      @"    sendMessage: function(id, data) {"
                                      @"        webkit.messageHandlers.%@.postMessage({"
                                      @"                                                  id: id,"
                                      @"                                                  data: data,"
                                      @"                                              });"
                                      @"    },"
                                      @"    suppress: {"
                                      @"        addCCRecipientsDialog: false"
                                      @"    }"
                                      @"});"
                                      @"webkit.messageHandlers.%@.postMessage('started');",
                                      DS_SIGNING_MESSAGE_HANDLER,
                                      DS_SIGNING_STARTED_HANDLER];
        [config.userContentController addUserScript:[[WKUserScript alloc] initWithSource:signingApiInitJs
                                                                           injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                                        forMainFrameOnly:YES]];
        
        _webView = [[WKWebView alloc] initWithFrame:frame configuration:config];
        _webView.navigationDelegate = self;
    }
    return self;
}

- (void)startSigningWithURL:(NSURL *)url {
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)dealloc {
    [self stopMonitoringLocation];
}

- (BOOL)isReady {
    return !self.awaitingFirstMessage;
}

#pragma mark - WKNavigationDelegate (formerly UIWebViewDelegate)

// replaces UIWebViewDelegate webView:shouldStartLoadWithRequest:navigationType
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSDictionary *queryParameters = [navigationAction.request.URL ds_queryDictionary];
    NSString *event = queryParameters[@"event"];
    if ([event length] > 0) {
        [self handleEvent:event];
        decisionHandler(WKNavigationActionPolicyCancel);
    } else if ([navigationAction.request.URL.absoluteString rangeOfString:@"SessionTimeout"].location != NSNotFound) {
        [self.delegate signingDidTimeout:self];
        decisionHandler(WKNavigationActionPolicyCancel);
    } else if ([self.delegate respondsToSelector:@selector(webView:decidePolicyForNavigationAction:decisionHandler:)]) {
        return [self.delegate webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

// replaces UIWebViewDelegate webViewDidStartLoad
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    if ([self.delegate respondsToSelector:@selector(webView:didStartProvisionalNavigation:)]) {
        [self.delegate webView:webView didStartProvisionalNavigation:navigation];
    }
}

// replaces UIWebViewDelegate webViewDidFinishLoad
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if ([self.delegate respondsToSelector:@selector(webView:didFinishNavigation:)]) {
        [self.delegate webView:webView didFinishNavigation:navigation];
    }
}

// replaces UIWebViewDelegate webView:didFailLoadWithError
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(webView:didFailProvisionalNavigation:withError:)]) {
        [self.delegate webView:webView didFailProvisionalNavigation:navigation withError:error];
    }
}

#pragma mark - JavaScript and URL Handling

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:DS_SIGNING_MESSAGE_HANDLER]) {
        NSLog(@"%@", message.body);
        [self handleMessage:(NSString *)message.body[@"id"] data:(NSDictionary *)message.body[@"data"]];
    } else if ([message.name isEqualToString:DS_SIGNING_STARTED_HANDLER]) {
        self.awaitingFirstMessage = YES;
    }
}

- (void)handleMessage:(NSString *)messageId data:(NSDictionary *)data {
    NSDictionary *jsonDictionary = data;
    
    // handle message is sometimes enters here from another thread
    // make sure all delegate calls here are passed back in the main
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.awaitingFirstMessage) {
            self.awaitingFirstMessage = NO;
            [self.delegate signingIsReady:self];
            
            // get decline options to initialize self.canDecline
            [self declineOptions:nil];
            
            [self isFreeformEnabled:^(BOOL freeform) {
                self.isFreeform = freeform;
            }];
        }
        
        if (jsonDictionary) {
            if ([messageId isEqualToString:@"acceptConsumerDisclosureRequested"]) {
                [self consumerDisclosure:^(DSSigningAPIConsumerDisclosure *disclosure) {
                    [self.delegate signing:self didRequestConsumerDisclosureConsent:disclosure]; // TODO: for some reason the disclosure I get has all blank properties, the string is just {}
                }];
            } else if ([messageId isEqualToString:@"canFinishChanged"]) {
                self.canFinish = [data[@"canFinish"] boolValue];
                [self.delegate signing:self canFinishChanged:self.canFinish];
            } else if ([messageId isEqualToString:@"adoptSignatureRequested"]) {
                DSSigningAPIAdoptSignatureTabDetails *details = [MTLJSONAdapter modelOfClass:[DSSigningAPIAdoptSignatureTabDetails class]
                                                                          fromJSONDictionary:jsonDictionary[@"tab"]
                                                                                       error:nil];
                [self.delegate signing:self didRequestSignature:details];
            } else if ([messageId isEqualToString:@"geoLocationRequested"]) {
                [self startMonitoringLocation];
                [self locationManager:self.locationManager didUpdateLocations:[[NSArray alloc] initWithObjects:self.locationManager.location, nil]];
            } else if ([messageId isEqualToString:@"applyFormFieldsRequested"]) {
                [self.delegate signingFoundFormFields:self];
            } else if ([messageId isEqualToString:@"inPersonSignerEmailRequested"]) {
                [self evaluateSigningApiMethod:[NSString stringWithFormat:@"DSSigning.setInPersonSignerEmail('%@')", self.inPersonSignerEmail ?: @""]];
            } else if ([messageId isEqualToString:@"declineRequested"]) {
                [self.delegate signing:self didRequestDecline:[MTLJSONAdapter modelOfClass:[DSSigningAPIDeclineOptions class]
                                                                        fromJSONDictionary:jsonDictionary
                                                                                     error:nil]];
            } else if ([messageId isEqualToString:@"addCCRecipientsRequested"]) {
                [self.delegate signing:self didRequestCarbonCopies:[MTLJSONAdapter modelOfClass:[DSSigningAPIAddCCRecipients class]
                                                                             fromJSONDictionary:jsonDictionary
                                                                                          error:nil]];
            } else if ([messageId isEqualToString:@"error"]) {
                [self.delegate signing:self didFailWithErrorMessage:jsonDictionary[@"value"]];
            }
        }
    });
}

- (void)handleEvent:(NSString *)event {
    if ([event isEqualToString:@"cancel"]) {
        [self.delegate signingDidCancel:self];
    } else if ([event isEqualToString:@"decline"]) {
        [self.delegate signingDidDecline:self];
    } else if ([event isEqualToString:@"exception"]) {
        [self.delegate signing:self didFailWithErrorMessage:@"An error occurred."];
    } else if ([event isEqualToString:@"fax_pending"]) {
        [self.delegate signing:self didFailWithErrorMessage:@"Recipient has fax pending. Unsupported."];
    } else if ([event isEqualToString:@"id_check_failed"]) {
        [self.delegate signing:self didFailWithErrorMessage:@"ID check failed."];
    } else if ([event isEqualToString:@"session_timeout"]) {
        [self.delegate signingDidTimeout:self];
    } else if ([event isEqualToString:@"signing_complete"]) {
        [self.delegate signingDidComplete:self];
    } else if ([event isEqualToString:@"ttl_expired"]) {
        [self.delegate signingDidTimeout:self];
    } else if ([event isEqualToString:@"viewing_complete"]) {
        [self.delegate signingDidViewEnvelope:self];
    } else if ([event isEqualToString:@"access_code_failed"]) {
        [self.delegate signing:self didFailWithErrorMessage:@"Access code failed."];
    } else {
        [self.delegate signing:self didFailWithErrorMessage:@"Unknown redirect received."];
    }
}

#pragma mark - Signing API Helpers

- (void)evaluateSigningApiMethod:(NSString *)method {
    [self evaluateSigningApiMethod:method completion:nil];
}

- (void)evaluateSigningApiMethod:(NSString *)method completion:(void (^)(id, NSError *))completion {
    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"%@.%@", DS_SIGNING_API, method] completionHandler:completion];
}

#pragma mark - Signing Lifecycle

- (void)saveSigning {
    [self evaluateSigningApiMethod:@"save()"];
}

- (void)cancelSigning {
    [self evaluateSigningApiMethod:@"exit()"];
}

- (void)finishSigning:(void (^)(BOOL finished))completion {
    [self evaluateSigningApiMethod:@"finish()" completion:^(id result, NSError *err) {
        if (completion) {
            completion([result[@"finished"] boolValue]);
        }
    }];
}

#pragma mark - Carbon Copy Recipients

- (void)carbonCopyRecipientAddingOptions:(void (^)(DSSigningAPIAddCCRecipients *options))completion {
    [self evaluateSigningApiMethod:@"getAddCCRecipientsOptions()" completion:^(id result, NSError *err) {
        if (completion) {
            completion([MTLJSONAdapter modelOfClass:[DSSigningAPIAddCCRecipients class]
                                 fromJSONDictionary:(NSDictionary *)result
                                              error:nil]);
        }
    }];
}

- (void)addCarbonCopyRecipients:(DSSigningAPIAddCCRecipients *)carbonCopyRecipients {
    [self evaluateSigningApiMethod:[NSString stringWithFormat:@"addCCRecipients(%@)",
                                    [MTLJSONAdapter JSONDictionaryFromModel:carbonCopyRecipients]]];
}

#pragma mark - Consumer Disclosure

- (void)consumerDisclosure:(void (^)(DSSigningAPIConsumerDisclosure *disclosure))completion {
    [self evaluateSigningApiMethod:@"getAddCCRecipientsOptions()" completion:^(id result, NSError *err) {
        if (completion) {
            completion([MTLJSONAdapter modelOfClass:[DSSigningAPIConsumerDisclosure class]
                                 fromJSONDictionary:(NSDictionary *)result
                                              error:nil]);
        }
    }];
}

- (void)acceptConsumerDisclosure {
    [self evaluateSigningApiMethod:@"setConsumerDisclosureAccepted(true)"];
}

#pragma mark - Decline

- (void)declineOptions:(void (^)(DSSigningAPIDeclineOptions *options))completion {
    [self evaluateSigningApiMethod:@"getDeclineOptions()" completion:^(id result, NSError *err) {
        NSDictionary *dict = (NSDictionary *)result;
        self.canDecline = [dict count] > 0;
        if (completion) {
            if (self.canDecline) {
                completion([MTLJSONAdapter modelOfClass:[DSSigningAPIDeclineOptions class]
                                     fromJSONDictionary:dict
                                                  error:nil]);
            } else {
                completion(nil);
            }
        }
    }];
}

- (void)declineSigningWithDetails:(DSSigningAPIDeclineSigning *)details {
    [self evaluateSigningApiMethod:[NSString stringWithFormat:@"decline(%@)", [MTLJSONAdapter JSONDictionaryFromModel:details]]];
}

#pragma mark - Signature

- (void)adoptSignature:(NSString *)signatureImageId {
    [self evaluateSigningApiMethod:[NSString stringWithFormat:@"adoptSignature({signatureGuid:'%@'});", signatureImageId]];
}

- (void)adoptInitials:(NSString *)initialsImageId {
    [self evaluateSigningApiMethod:[NSString stringWithFormat:@"adoptSignature({initialsGuid:'%@'});", initialsImageId]];
}

- (void)cancelAdoptSignatureOrInitials {
    [self evaluateSigningApiMethod:@"adoptSignature();"];
}

#pragma mark - Navigate Document

- (void)autoNavigate {
    [self evaluateSigningApiMethod:@"autoNavigate()"];
}

- (void)scrollToNextPage {
    [self evaluateSigningApiMethod:@"navigateToNextPage()"];
}

- (void)scrollToPreviousPage {
    [self evaluateSigningApiMethod:@"navigateToPreviousPage()"];
}

- (void)scrollToPage:(NSInteger)page {
    [self evaluateSigningApiMethod:[NSString stringWithFormat:@"setCurrentPage(%ld)", (long)page]];
}

- (void)pageCount:(void (^)(NSUInteger count))completion {
    [self evaluateSigningApiMethod:@"getPageCount()" completion:^(id result, NSError *err) {
        if (completion) {
            completion([[result stringValue] integerValue]);
        }
    }];
}

- (void)currentPageNumber:(void (^)(NSUInteger page))completion {
    [self evaluateSigningApiMethod:@"getCurrentPage()" completion:^(id result, NSError *err) {
        if (completion) {
            completion([[result stringValue] integerValue]);
        }
    }];
}

#pragma mark - Page Rotation

- (void)rotatePageLeft {
    [self evaluateSigningApiMethod:@"rotatePage('left')"];
}

- (void)rotatePageRight {
    [self evaluateSigningApiMethod:@"rotatePage('right')"];
}

#pragma mark - Hosted Signing

#pragma mark - Tags

- (void)setSelectedFreeformTab:(DSSigningAPITab)selectedFreeformTab {
    NSString *tabType = DS_SIGNING_API_TABS[selectedFreeformTab];
    [self evaluateSigningApiMethod:[NSString stringWithFormat:@"setSelectedFreeformTabType(%@)", tabType]];
    _selectedFreeformTab = selectedFreeformTab;
}

- (void)isFreeformEnabled:(void (^)(BOOL freeform))completion {
    [self evaluateSigningApiMethod:@"isFreeformEnabled()" completion:^(id result, NSError *err) {
        if (completion) {
            completion([[result stringValue] boolValue]);
        }
    }];
}

- (void)currentSignatureTabDetails:(void (^)(DSSigningAPIAdoptSignatureTabDetails *details))completion {
    [self evaluateSigningApiMethod:@"getAddCCRecipientsOptions()" completion:^(id result, NSError *err) {
        if (completion) {
            completion([MTLJSONAdapter modelOfClass:[DSSigningAPIAdoptSignatureTabDetails class]
                                 fromJSONDictionary:(NSDictionary *)result
                                              error:nil]);
        }
    }];
}

- (void)applyFormFields:(BOOL)apply {
    [self evaluateSigningApiMethod:[NSString stringWithFormat:@"applyFormFields(%@)", apply ? @"true" : @"false"]];
}

#pragma mark - CLLocationManagerDelegate

- (void)startMonitoringLocation {
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager significantLocationChangeMonitoringAvailable]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self.locationManager startMonitoringSignificantLocationChanges];
    }
}

- (void)stopMonitoringLocation {
    [self.locationManager stopMonitoringSignificantLocationChanges];
    self.locationManager.delegate = nil;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocation = [locations lastObject];
    if (newLocation.horizontalAccuracy < 0) {
        return; // do not send invalid location data
    }
    NSString *position = [NSString stringWithFormat:@"{coords:{accuracy:%f,altitude:%@,altitudeAccuracy:%@,heading:%@,latitude:%f,longitude:%f,speed:%@}}", // docs incorrect, see SIGN-2817
                          newLocation.horizontalAccuracy,
                          (newLocation.verticalAccuracy < 0)   ? @"null" : [NSString stringWithFormat:@"%f", newLocation.altitude],
                          (newLocation.verticalAccuracy < 0)   ? @"null" : [NSString stringWithFormat:@"%f", newLocation.verticalAccuracy],
                          (newLocation.course < 0)             ? @"null" : [NSString stringWithFormat:@"%f", newLocation.course],
                          newLocation.coordinate.latitude,
                          newLocation.coordinate.longitude,
                          (newLocation.speed < 0)              ? @"null" : [NSString stringWithFormat:@"%f", newLocation.speed]];
    [self evaluateSigningApiMethod:[NSString stringWithFormat:@"setGeoLocation(%@);", position]];
}

@end
