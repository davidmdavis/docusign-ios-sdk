//
//  DSTemplateDefinition.m
//  DocuSign iOS SDK
//
//  Created by Ergin Dervisoglu on 7/21/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import "DSTemplateDefinition.h"

#import "NSValueTransformer+DS_CustomTransformers.h"

@implementation DSTemplateDefinition

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ NSStringFromSelector(@selector(templateID)) : @"templateId",
              NSStringFromSelector(@selector(name)) : @"name",
              NSStringFromSelector(@selector(shared)) : @"shared" };
}

@end