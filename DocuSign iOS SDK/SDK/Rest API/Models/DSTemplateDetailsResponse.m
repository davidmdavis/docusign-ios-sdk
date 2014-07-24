//
//  DSTemplateDetailsResponse.m
//  DocuSign iOS SDK
//
//  Created by Ergin Dervisoglu on 7/20/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "DSTemplateDetailsResponse.h"

#import "NSValueTransformer+DS_CustomTransformers.h"

@implementation DSTemplateDetailsResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ NSStringFromSelector(@selector(templateDefinition)) : @"envelopeTemplateDefinition",
              NSStringFromSelector(@selector(emailSubject)) : @"emailSubject",
              NSStringFromSelector(@selector(emailBlurb)) : @"emailBlurb",
              NSStringFromSelector(@selector(signingLoc)) : @"signingLocation" };
}

+ (NSValueTransformer *)templateDefinitionJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[DSTemplateDefinition class]];
}
+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    if ([key isEqualToString:NSStringFromSelector(@selector(recipients))]) {
        return [MTLValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[DSTemplateRecipientsResponse class]];
    }
    return nil;
}

@end
