//
//  DSTemplateRecipientsResponse.h
//  DocuSign iOS SDK
//
//  Created by Ergin Dervisoglu on 7/21/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "DSRestAPIResponseModel.h"

@interface DSTemplateRecipientsResponse : DSRestAPIResponseModel

@property (nonatomic) NSArray   *signers; // DSEnvelopeSigner
@property (nonatomic) NSArray   *inPersonSigners; // DSEnvelopeInPersonSigner
@property (nonatomic) NSInteger  recipientCount;

- (NSArray *)allSigners; // DSEnvelopeRecipients

@end
