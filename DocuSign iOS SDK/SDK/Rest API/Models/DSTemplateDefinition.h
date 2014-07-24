//
//  DSTemplateDefinition.h
//  DocuSign iOS SDK
//
//  Created by Ergin Dervisoglu on 7/21/14.
//  Copyright (c) 2014 DocuSign Inc. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface DSTemplateDefinition : MTLModel <MTLJSONSerializing>

@property (nonatomic) NSString *templateID;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *shared;

@end