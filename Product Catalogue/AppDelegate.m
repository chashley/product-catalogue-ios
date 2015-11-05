//
//  AppDelegate.m
//  Product Catalogue
//
//  Created by Boris Bügling on 10/12/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <Keys/ProductCatalogueKeys.h>
#import <ContentfulStyle/UIFont+Contentful.h>

#import "AppDelegate.h"
#import "Constants.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)app didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self writeKeysToUserDefaults];

    [[UINavigationBar appearance] setTitleTextAttributes:@{ NSFontAttributeName: UIFont.titleBarFont,NSForegroundColorAttributeName: UIColor.blackColor }];
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSFontAttributeName: UIFont.tabTitleFont } forState:UIControlStateNormal];

    self.window.backgroundColor = UIColor.whiteColor;
    return YES;
}

-(BOOL)application:(UIApplication *)application
           openURL:(NSURL *)url
 sourceApplication:(NSString *)sourceApplication
        annotation:(id)annotation {
    NSURLComponents* components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];

    if (![components.scheme isEqualToString:@"contentful-catalogue"]) {
        return NO;
    }

    if (![components.host isEqualToString:@"open"]) {
        return NO;
    }

    if (![components.path hasPrefix:@"/space"]) {
        return NO;
    }

    NSString* spaceKey = components.path.lastPathComponent;
    NSString* accessToken = nil;

    for (NSString* parameter in [components.query componentsSeparatedByString:@"&"]) {
        NSArray* components = [parameter componentsSeparatedByString:@"="];

        if (components.count != 2) {
            return NO;
        }

        if ([[components firstObject] isEqualToString:@"access_token"]) {
            accessToken = [components lastObject];
        }
    }

    if (!accessToken) {
        return NO;
    }

    [[NSUserDefaults standardUserDefaults] setValue:accessToken forKey:ACCESS_TOKEN];
    [[NSUserDefaults standardUserDefaults] setValue:spaceKey forKey:SPACE_KEY];

    [[NSNotificationCenter defaultCenter] postNotificationName:CDASpaceChangedNotification
                                                        object:nil
                                                      userInfo:@{ CDASpaceIdentifierKey: spaceKey,
                                                                  CDAAccessTokenKey: accessToken }];

    return YES;
}

-(void)writeKeysToUserDefaults {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    ProductcatalogueKeys* keys = [ProductcatalogueKeys new];

    if (![defaults stringForKey:SPACE_KEY]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", nil) message:FIRST_LAUNCH_MESSAGE delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];

        [defaults setValue:keys.productCatalogueSpaceId forKey:SPACE_KEY];
    }

    if (![defaults stringForKey:ACCESS_TOKEN]) {
        [defaults setValue:keys.productCatalogueAccesToken forKey:ACCESS_TOKEN];
    }
}

@end
