//
//  PhotoCategory.h
//  townWizard-ios
//
//  Created by Vilimets Anton on 10/2/12.
//
//

#import <Foundation/Foundation.h>

@interface PhotoCategory : NSObject
{
    NSString *categoryId;
    NSString *thumb;
    NSString *name;
    NSNumber *numPhotos;
}
@property (nonatomic, retain) NSString *categoryId;
@property (nonatomic, retain) NSString *thumb;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *numPhotos;

+ (RKObjectMapping *)objectMapping;

@end