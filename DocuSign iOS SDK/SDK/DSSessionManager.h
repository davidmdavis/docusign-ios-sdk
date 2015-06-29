//
//  DSSessionManager.h
//  DocuSign iOS SDK
//
//  Created by Arlo Armstrong on 4/22/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DSRestAPIEnvironment.h"

#import "DSSigningViewControllerDelegate.h"

#import "DSSignaturePart.h"

#import "DSLogicalEnvelopeGroup.h"

@import UIKit;

extern NSString * const DSSessionManagerErrorDomain;

extern NSString * const DSSessionManagerErrorUserInfoKeyStatusCode;
extern NSString * const DSSessionManagerErrorUserInfoKeyErrorCodeString;
extern NSString * const DSSessionManagerErrorUserInfoKeyErrorMessage;

typedef NS_ENUM(NSInteger, DSSessionManagerErrorCode) {
    DSSessionManagerErrorCodeHTTPStatus = -1,
    DSSessionManagerErrorCodeUnknown = 0,
    DSSessionManagerErrorCodeUserAuthenticationFailed = 1,
    DSSessionManagerErrorCodeUnsupportedTemplateRecipient = 2
};

extern NSString * const DSSessionManagerNotificationTaskStarted;
extern NSString * const DSSessionManagerNotificationTaskFinished;

extern NSString * const DSSessionManagerNotificationUserInfoKeyData;
extern NSString * const DSSessionManagerNotificationUserInfoKeyDestinationURL;
extern NSString * const DSSessionManagerNotificationUserInfoKeyError;


@class DSSessionManager, DSSigningViewController, DSNetworkLogger;

@class DSLoginInformationResponse, DSLoginAccount;
@class DSCreateEnvelopeResponse;
@class DSEnvelopesListResponse;
@class DSEnvelopeDetailsResponse, DSTemplateDetailsResponse, DSEnvelopeRecipientsResponse;
@class DSUserSignaturesResponse, DSUserSignature;


@protocol DSSessionManagerAuthenticationDelegate <NSObject>

@required
/**
 *  Called after the -authenticate method completes successfully.
 *
 *  @param sessionManager the DSSessionManager which has successfully authenticated
 *  @param account        the DSLoginAccount which has been authenticated
 */
- (void)sessionManager:(DSSessionManager *)sessionManager authenticationSucceededWithAccount:(DSLoginAccount *)account;

/**
 *  Called after the -authenticate method fails.
 *
 *  @param sessionManager the DSSessionManager which failed to authenticate
 *  @param error          an NSError describing why the authentication failed
 */
- (void)sessionManager:(DSSessionManager *)sessionManager authenticationFailedWithError:(NSError *)error;

@optional
/**
 *  Called after a successful authentication and passed an array of DSLoginAccount. Call the completeAuthenticationHandler passing in the accountID of the selected account to finish authentication. Until this block is called the sessionManager will not be authenticated. If not implemented the default account will be selected.
 *
 *  @param sessionManager                the DSSessionManager which has successfully authenticated
 *  @param accounts                      an array of DSLoginAccount
 *  @param completeAuthenticationHandler call this block with the selected accountID to complete authentication
 */
- (void)sessionManager:(DSSessionManager *)sessionManager chooseAccountIDFromAvailableAccounts:(NSArray *)accounts completeAuthenticationHandler:(void (^)(NSString *accountID))completeAuthenticationHandler;

@end


@interface DSSessionManager : NSObject


/**
 *  The baseURL of the currently authenticated user or the default baseURL if not yet authenticated. E.g. https://demo.docusign.net/restapi/v2/ or https://www.docusign.net/restapi/v2/
 */
@property (nonatomic, readonly) NSURL *baseURL;


/**
 *  The account information of the authenticated user.
 */
@property (nonatomic, readonly) DSLoginAccount *account;


/**
 *  The OAuth token for the authenticated user
 */
@property (nonatomic, readonly) NSString *authToken;



/**
 *  Preferred initializer. Returns a DSSessionManager ready to authenticate the user with the given token.
 *
 *  @param integratorKey Identifies the application accessing the DocuSign API. See https://www.docusign.com/developer-center/quick-start/first-api-call
 *  @param environment   The DocuSign environment for which the integrator key is valid e.g. demo or production
 *  @param authToken     An oauth2 token with which to authenticate the DocuSign user. See https://www.docusign.com/p/RESTAPIGuide/RESTAPIGuide.htm#OAuth2/OAuth2%20Authentication%20Support%20in%20DocuSign%20REST%20API.htm
 *
 *  @return A newly initialized DSSessionManager object.
 */
- (instancetype)initWithIntegratorKey:(NSString *)integratorKey forEnvironment:(DSRestAPIEnvironment)environment authToken:(NSString *)authToken authDelegate:(id<DSSessionManagerAuthenticationDelegate>)authDelegate;


/**
 *  Returns a DSSessionManager ready to authenticate with the given user credentials.
 *
 *  @param integratorKey Identifies the application accessing the DocuSign API. See https://www.docusign.com/developer-center/quick-start/first-api-call
 *  @param environment   The DocuSign environment for which the integrator key is valid e.g. demo or production
 *  @param username      The email or userID (GUID) of the DocuSign user.
 *  @param password      The plaintext password or apiPassword of the DocuSign user.
 *
 *  @return A newly initialized DSSessionManager object.
 */
- (instancetype)initWithIntegratorKey:(NSString *)integratorKey forEnvironment:(DSRestAPIEnvironment)environment username:(NSString *)username password:(NSString *)password authDelegate:(id<DSSessionManagerAuthenticationDelegate>)authDelegate;


#pragma mark - Authentication

/**
 *  The object to be notified when authentication succeds, fails, or finds multiple user accounts.
 */
@property (nonatomic, weak) id<DSSessionManagerAuthenticationDelegate> authenticationDelegate;

/**
 *  Returns YES if the user has been successfully authenticated, NO otherwise.
 */
@property (nonatomic, readonly, getter = isAuthenticated) BOOL authenticated;


/**
 *  Must be invoked before making additional requests via the SDK.
 */
- (void)authenticate;


#pragma mark - Network Tasks

/**
 *  All pending in progress API requests will be cancelled and the associated callbacks will not be not be fired. The sessionManager can still be used for subsequent requests. Note: to cancel individual requests maintain a reference to the specific NSURLSessionTask object.
 */
- (void)cancelAllTasks;


/**
 *  Retrives login information for a given set of user credentials.
 *
 *  @return A newly initialized NSURLSessionDataTask object.
 */
- (NSURLSessionDataTask *)startLoginInformationTaskWithCompletionHandler:(void (^)(DSLoginInformationResponse *response, NSError *error))completionHandler;


/**
 *  Generates a signing URL for an embedded recipient using the recipientID, userID, clientUserID and envelopeID that are passed in.  The returnURL
 *  parameter is used to re-direct the signer to a given URL once they are finished signing.
 *
 *  @param recipientID  The recipientID of the recipient that is passed in.
 *  @param userID       The userID of the recipient that is passed in.
 *  @param clientUserID The clientUserID of the recipient (required for embedded signers)
 *  @param envelopeID   The envelopeID of the envelope the recipient will be signing.
 *  @param returnURL    The URL to return the signer to once signing is complete.
 *
 *  @return A newly initialized NSURLSessionDataTask object.
 */
- (NSURLSessionDataTask *)startSigningURLTaskForRecipientWithID:(NSString *)recipientID
                                                         userID:(NSString *)userID
                                                   clientUserID:(NSString *)clientUserID
                                               inEnvelopeWithID:(NSString *)envelopeID
                                                      returnURL:(NSURL *)returnURL
                                              completionHandler:(void (^)(NSString *signingURLString, NSError *error))completionHandler;


/**
 *  Creates a new envelope from a local document and initiates an embedded signing session on that envelope for the authenticated
 *  DSSessionManager user.  (Note: this function can be altered to request signatures for alternate/additional recipients.)
 *
 *  @param fileName     Name of the local file (document) for which the signature request will be made on.
 *  @param fileURL      Location (full path) of the file for which the signature request will be made on.
 *
 *  @return A newly initialized NSURLSessionDataTask object.
 */
- (NSURLSessionDataTask *)startCreateSelfSignEnvelopeTaskWithFileName:(NSString *)fileName
                                                              fileURL:(NSURL *)fileURL
                                                    completionHandler:(void (^)(DSCreateEnvelopeResponse *response, NSError *error))completionHandler;


/**
 *  Sends a signature request from a server template to the recipients passed in.
 *
 *  @param templateId   A valid templateId copied from an existing server template in your account.
 *  @param recipients   An array of DSEnvelopeRecipients.  Currently signers and in-person signer recipient types are supported.
 *  @param emailSubject Subject of the signing request email. Pass nil for default template subject.
 *
 *  @return A newly initialized NSURLSessionDataTask object.
 */
- (NSURLSessionDataTask *)startSendEnvelopeFromTemplateTaskWithTemplateId:(NSString *)templateId
                                                               recipients:(NSArray *)recipients
                                                             emailSubject:(NSString *)emailSubject
                                                        completionHandler:(void (^)(DSCreateEnvelopeResponse *response, NSError *error))completionHandler;


/**
 *  Lists (retrieves) envelopes for a given search folder.  (I.E. See what envelopes are awaiting your signature)
 *
 *  @param logicalGroup         Enum (DSLogicalEnvelopeGroup) used to specify which account folder to search.
 *  @param range                Numerical range used to limit number of envelopes retrieved.
 *  @param fromDate             Search filter starting date.
 *  @param toDate               Search filter ending date.
 *  @param includeRecipients    Flag (BOOL) for including recipients information in response or not.
 *
 *  @return A newly initialized NSURLSessionDataTask object.
 */
- (NSURLSessionDataTask *)startEnvelopesListTaskWithLogicalGrouping:(DSLogicalEnvelopeGroup)logicalGroup
                                                              range:(NSRange)range
                                                           fromDate:(NSDate *)fromDate
                                                             toDate:(NSDate *)toDate
                                                  includeRecipients:(BOOL)includeRecipients
                                                  completionHandler:(void (^)(DSEnvelopesListResponse *response, NSError *error))completionHandler;


/**
 *  Retrieves envelope information for an existing envelope.
 *
 *  @param envelopeID   The envelopeId of an existing envelope.
 *
 *  @return A newly initialized NSURLSessionDataTask object.
 */
- (NSURLSessionDataTask *)startEnvelopeDetailsTaskForEnvelopeWithID:(NSString *)envelopeID
                                                  completionHandler:(void (^)(DSEnvelopeDetailsResponse *response, NSError *error))completionHandler;


/**
 *  Retrieves template information for an existing account template.
 *
 *  @param templateID   The templateId of an existing account template.
 *
 *  @return A newly initialized NSURLSessionDataTask object.
 */
- (NSURLSessionDataTask *)startTemplateDetailsTaskForTemplateWithID:(NSString *)templateID
                                                  completionHandler:(void (^)(DSTemplateDetailsResponse *response, NSError *error))completionHandler;


/**
 *  Retrieves recipients information for an existing envelope.
 *
 *  @param envelopeID   The envelopeId of the envelope for which you want to retrieve recipients information.
 *
 *  @return A newly initialized NSURLSessionDataTask object.
 */
- (NSURLSessionDataTask *)startEnvelopeRecipientsTaskForEnvelopeWithID:(NSString *)envelopeID
                                                     completionHandler:(void (^)(DSEnvelopeRecipientsResponse *response, NSError *error))completionHandler;


/**
 *  Download completed envelope document(s) for a given envelope.
 *
 *  @param envelopeID           The envelopeId of the envelope for which you want to download the completed document(s) from.
 *  @param destinationFileURL   The location (full path) for where you want the downloaded document(s) to go.
 *
 *  @return A newly initialized NSURLSessionDataTask object.
 */
- (NSURLSessionDownloadTask *)startDownloadCompletedDocumentTaskForEnvelopeWithID:(NSString *)envelopeID
                                                               destinationFileURL:(NSURL *)destinationFileURL
                                                                completionHandler:(void (^)(NSError *error))completionHandler;


/**
 *  Sets the signature (or initials) image for an accountless signer.  (Note: supported image formats for this file are: gif, png, jpeg, and bmp.
 *  The file size must be less than 200K.)
 *
 *  @param recipientID      The recipientId for whom we want to set the signature or initials image.
 *  @param envelopeID       The envelopeId for the envelope this recipient belongs to.
 *  @param image            The image file of the new signature (or initials).
 *  @param signaturePart    Used to indicate if the signature or initials image is being set.
 *
 *  @return A newly initialized NSURLSessionDataTask object.
 */
- (NSURLSessionDataTask *)startRecipientSignatureCreateTaskForRecipientID:(NSString *)recipientID
                                                         inEnvelopeWithID:(NSString *)envelopeID
                                                                    image:(UIImage *)image
                                                            signaturePart:(DSSignaturePart)signaturePart
                                                        completionHandler:(void (^)(NSError *error))completionHandler;


/**
 *  Retrieve's signature information for an accountless signer.
 *
 *  @param recipientID  The recipientId of the recipient we will retrieve signature info for.
 *  @param envelopeID   The envelopeId of the envelope the recipient belongs to.
 *
 *  @return A newly initialized NSURLSessionDataTask object.
 */
- (NSURLSessionDataTask *)startRecipientSignatureDetailsTaskForRecipientID:(NSString *)recipientID
                                                          inEnvelopeWithID:(NSString *)envelopeID
                                                         completionHandler:(void (^)(DSUserSignature *response, NSError *error))completionHandler;


/**
 *  Returns a list of signature definitions for the authenticated DSSessionManager user.
 *
 *  @return A newly initialized NSURLSessionDataTask object.
 */
- (NSURLSessionDataTask *)startSignaturesTaskWithCompletionHandler:(void (^)(DSUserSignaturesResponse *response, NSError *error))completionHandler;


/**
 *  Removes the signature information for the authenticated DSSessionManager user.
 *
 *  @param signatureID  The signatureId of the signature we want to close (remove) for the authenticated user.
 *
 *  @return A newly initialized NSURLSessionDataTask object.
 */
- (NSURLSessionDataTask *)startSignatureDeleteTaskForSignatureWithID:(NSString *)signatureID
                                                   completionHandler:(void (^)(NSError *error))completionHandler;


#pragma mark - Signing


/**
 *  Instantiate a new signing session for a given envelope recipient.  (Note: Similar to the |startCreateSelfSignEnvelopeTaskWithFileName| function
 *  except does not create a new envelope but rather is used for signing an existing envelope).
 *
 *  @param recipientID  The valid recipientId of the recipient who will be signing the envelope.
 *  @param envelopeID   The envelopeId of an existing envelope that has been sent but not completed. 
 *  @param delegate     A delegate for once the signing has completed.
 *
 *  @return A newly initialized NSURLSessionDataTask object.
 */
- (DSSigningViewController *)signingViewControllerForRecipientWithID:(NSString *)recipientID inEnvelopeWithID:(NSString *)envelopeID delegate:(id<DSSigningViewControllerDelegate>)delegate;


#pragma mark - Logging


@property (nonatomic, readonly) DSNetworkLogger *logger;


@end
