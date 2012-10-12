//
//  RequestHelper.h
//  townWizard-ios
//
//  Created by admin on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Partner;
@class Section;
@class PhotoCategory;

@interface RequestHelper : NSObject

+ (NSString *) md5:(NSString *) input;
+ (NSString *)xaccessTokenFromPartner:(Partner *)partner;
+ (RKObjectManager *)defaultObjectManager;

+ (void)partnersWithQuery:(NSString *)query
                   offset:(NSInteger)offset
              andDelegate:(id <RKObjectLoaderDelegate>)delegate;

+ (void)partnerWithId:(NSString *)partnerId
          andDelegate:(id <RKObjectLoaderDelegate>)delegate;

+ (void)sectionsWithPartner:(Partner *)partner
                andDelegate:(id <RKObjectLoaderDelegate>)delegate;

+ (void)categoriesWithPartner:(Partner *)partner
                   andSection:(Section *)section
                  andDelegate:(id <RKObjectLoaderDelegate>)delegate;

+ (void)photosWithPartner:(Partner *)partner section:(Section *)section fromCategory:(PhotoCategory *)category andDelegate:(id <RKObjectLoaderDelegate>)delegate;

+ (void)videosWithPartner:(Partner *)partner
               andSection:(Section *)section
              andDelegate:(id <RKObjectLoaderDelegate>)delegate;

+ (void)modelsListWithMapping:(RKObjectMapping *)objectMapping
                  fromPartner:(Partner *)partner
                   andSection:(Section *)section
                 withDelegate:(id <RKObjectLoaderDelegate>)delegate;

@end
