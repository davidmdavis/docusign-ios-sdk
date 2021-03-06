//
//  DSUserSignaturesResponse.h
//  DocuSign iOS SDK
//
//  Created by Deyton Sehn on 5/8/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "DSRestAPIResponseModel.h"

@interface DSUserSignaturesResponse : DSRestAPIResponseModel

@property (nonatomic) NSArray *userSignatures; // DSUserSignature

@end
