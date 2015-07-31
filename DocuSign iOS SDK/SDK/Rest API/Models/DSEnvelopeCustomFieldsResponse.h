//
//  DSEnvelopeCustomFieldsResponse.h
//  
//
//  Created by Deyton Sehn on 7/31/15.
//
//

#import "DSRestAPIResponseModel.h"

@interface DSEnvelopeCustomFieldsResponse : DSRestAPIResponseModel

@property (nonatomic) NSArray *listCustomFields; // DSListCustomField
@property (nonatomic) NSArray *textCustomFields; // DSTextCustomField

@end
