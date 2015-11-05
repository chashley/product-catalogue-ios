//
//  ContentfulDataManager.m
//  Product Catalogue
//
//  Created by Boris Bügling on 18/12/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <ContentfulPersistence/CoreDataManager.h>
#import <ContentfulPersistence/CoreDataFetchDataSource.h>

#import "Asset.h"
#import "Brand.h"
#import "Constants.h"
#import "ContentfulDataManager.h"
#import "Product.h"
#import "ProductCategory.h"
#import "SyncInfo.h"

NSString* const BrandContentTypeId = @"brand";
NSString* const CategoryContentTypeId = @"category";
NSString* const ProductContentTypeId = @"product";

@interface ContentfulDataManager ()

@property (nonatomic, readonly) CoreDataManager* manager;

@end

@implementation ContentfulDataManager

@synthesize manager = _manager;

-(CDAClient *)client {
    return self.manager.client;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:CDASpaceChangedNotification
                                                  object:nil];
}

-(NSFetchedResultsController*)fetchedResultsControllerForContentTypeWithIdentifier:(NSString*)contentTypeIdentifier predicate:(NSString*)predicate sortDescriptors:(NSArray*)sortDescriptors {
    NSFetchRequest* fetchRequest = [self.manager fetchRequestForEntriesOfContentTypeWithIdentifier:contentTypeIdentifier matchingPredicate:predicate];
    [fetchRequest setSortDescriptors:sortDescriptors];

    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.manager.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(spaceChanged:)
                                                     name:CDASpaceChangedNotification
                                                   object:nil];
    }
    return self;
}

- (CoreDataManager *)manager {
    if (_manager) {
        return _manager;
    }

    CDAConfiguration* configuration = [CDAConfiguration defaultConfiguration];
    configuration.userAgent = @"Contentful Product Catalogue/1.0";

    _manager = [[CoreDataManager alloc] initWithClient:[[CDAClient alloc] initWithSpaceKey:[[NSUserDefaults standardUserDefaults] stringForKey:SPACE_KEY] accessToken:[[NSUserDefaults standardUserDefaults] stringForKey:ACCESS_TOKEN] configuration:configuration] dataModelName:@"Product Catalogue"];

    _manager.classForAssets = [Asset class];
    _manager.classForSpaces = [SyncInfo class];

    [_manager setClass:Brand.class forEntriesOfContentTypeWithIdentifier:BrandContentTypeId];
    [_manager setClass:Product.class forEntriesOfContentTypeWithIdentifier:ProductContentTypeId];
    [_manager setClass:ProductCategory.class forEntriesOfContentTypeWithIdentifier:CategoryContentTypeId];

    return _manager;
}

- (void)performSynchronizationWithSuccess:(void (^)())success failure:(CDARequestFailureBlock)failure {
    [self.manager performSynchronizationWithSuccess:success failure:failure];
}

- (void)spaceChanged:(NSNotification*)note {
    [self.manager deleteAll];

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:note.userInfo[CDAAccessTokenKey] forKey:ACCESS_TOKEN];
    [defaults setValue:note.userInfo[CDASpaceIdentifierKey] forKey:SPACE_KEY];

    UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
    keyWindow.rootViewController = [keyWindow.rootViewController.storyboard
                                    instantiateInitialViewController];
}

@end
