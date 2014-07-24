//
//  DSTemplateRecipientsResponse.m
//  DocuSign iOS SDK
//
//  Created by Ergin Dervisoglu on 7/21/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "DSTemplateRecipientsResponse.h"

#import "DSEnvelopeSigner.h"
#import "DSEnvelopeInPersonSigner.h"

@implementation DSTemplateRecipientsResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ NSStringFromSelector(@selector(recipientCount)) : @"recipientCount" };
}

+ (NSValueTransformer *)signersJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[DSEnvelopeSigner class]];
}

+ (NSValueTransformer *)inPersonSignersJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[DSEnvelopeInPersonSigner class]];
}

- (NSArray *)allSigners {
    return [self.signers arrayByAddingObjectsFromArray:self.inPersonSigners];
}

@end
