//
//  DSTextCustomField.m
//  
//
//  Created by Deyton Sehn on 7/31/15.
//
//

#import "DSTextCustomField.h"
#import "NSValueTransformer+DS_CustomTransformers.h"

@implementation DSTextCustomField

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ @"fieldID" : @"fieldId" };
}

+ (NSValueTransformer *)requiredJSONTransformer {
    return [NSValueTransformer valueTransformerForName:DSBOOLValueTransformerName];
}

+ (NSValueTransformer *)showJSONTransformer {
    return [NSValueTransformer valueTransformerForName:DSBOOLValueTransformerName];
}

@end
