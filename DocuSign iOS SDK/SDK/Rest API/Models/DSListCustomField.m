//
//  DSListCustomField.m
//  
//
//  Created by Deyton Sehn on 7/31/15.
//
//

#import "DSListCustomField.h"
#import "NSValueTransformer+DS_CustomTransformers.h"

@implementation DSListCustomField

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
