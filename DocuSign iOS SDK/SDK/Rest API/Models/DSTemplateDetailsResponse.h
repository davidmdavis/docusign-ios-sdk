//
//  DSTemplateDetailsResponse.h
//  DocuSign iOS SDK
//
//  Created by Ergin Dervisoglu on 7/20/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "DSRestAPIResponseModel.h"
#import "DSTemplateDefinition.h"
#import "DSTemplateRecipientsResponse.h"

@interface DSTemplateDetailsResponse : DSRestAPIResponseModel

@property (nonatomic) DSTemplateDefinition *templateDefinition;

@property (nonatomic) NSString *emailBlurb;
@property (nonatomic) NSString *emailSubject;
@property (nonatomic) NSString *signingLoc;

@property (nonatomic) DSTemplateRecipientsResponse *recipients;

@end