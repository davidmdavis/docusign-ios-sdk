//
//  DSEnvelopeCustomFieldsResponse.m
//  
//
//  Created by Deyton Sehn on 7/31/15.
//
//

#import "DSEnvelopeCustomFieldsResponse.h"
#import "DSListCustomField.h"
#import "DSTextCustomField.h"

@implementation DSEnvelopeCustomFieldsResponse

+ (NSValueTransformer *)textCustomFieldsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[DSTextCustomField class]];
}

+ (NSValueTransformer *)listCustomFieldsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[DSListCustomField class]];
}

@end
