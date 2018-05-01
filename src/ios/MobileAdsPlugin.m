#import "MobileAdsPlugin.h"
#import <Cordova/CDVPlugin.h>

@import GoogleMobileAds;

@implementation MobileAdsPlugin

bool initialized = false;

- (void)initialize:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    NSString* appId = [command.arguments objectAtIndex:0];

    if (appId != nil && [appId length] > 0) {
        [GADMobileAds configureWithApplicationID:appId];
        initialized = true;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)loadInterstitial:(CDVInvokedUrlCommand*)command {
    NSString* adUnitId = [command.arguments objectAtIndex:0];

    if (initialized == true && adUnitId != nil && [adUnitId length] > 0 && self.interstitialCommand == nil) {
        self.interstitial = [[GADInterstitial alloc]
            initWithAdUnitID:adUnitId];

        self.interstitial.delegate = self;

        GADRequest *request = [GADRequest request];
        [self.interstitial loadRequest:request];
        self.interstitialCommand = command;
    } else {
        CDVPluginResult* pluginResult = nil;
        NSString *error = @"MobileAds not initialized or busy.";
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)showInterstitial:(CDVInvokedUrlCommand*)command {
    if (initialized == true && self.interstitial != nil && self.interstitial.isReady) {
        [self.interstitial presentFromRootViewController:self.viewController];
        self.interstitialCommand = command;
    } else {
        CDVPluginResult* pluginResult = nil;
        NSString *error = @"MobileAds not initialized or interstitial ad not ready.";
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)loadRewardedVideoAd:(CDVInvokedUrlCommand*)command {
    NSString* adUnitId = [command.arguments objectAtIndex:0];

    if (initialized == true && adUnitId != nil && [adUnitId length] > 0 && self.rewardedCommand == nil) {
        [[GADRewardBasedVideoAd sharedInstance] loadRequest:[GADRequest request]
            withAdUnitID:adUnitId];
        [GADRewardBasedVideoAd sharedInstance].delegate = self;
        self.rewardedCommand = command;
    } else {
        CDVPluginResult* pluginResult = nil;
        NSString *error = @"MobileAds not initialized or busy.";
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)showRewardedVideoAd:(CDVInvokedUrlCommand*)command {
    if (initialized == true && [[GADRewardBasedVideoAd sharedInstance] isReady]) {
        [[GADRewardBasedVideoAd sharedInstance] presentFromRootViewController:self.viewController];
        self.rewardedCommand = command;
    } else {
        CDVPluginResult* pluginResult = nil;
        NSString *error = @"MobileAds not initialized or rewarded video ad not ready.";
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)showBanner:(CDVInvokedUrlCommand*)command {
    NSString* adUnitId = [command.arguments objectAtIndex:0];
    NSString* size = [command.arguments objectAtIndex:1];
    NSString* position = [command.arguments objectAtIndex:2];

    if (initialized == true && adUnitId != nil && [adUnitId length] > 0 && self.bannerCommand == nil) {
        if ([size isEqualToString:@"BANNER"]) self.bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        else if ([size isEqualToString:@"LARGE_BANNER"]) self.bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeLargeBanner];
        else if ([size isEqualToString:@"MEDIUM_RECTANGLE"]) self.bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeMediumRectangle];
        else if ([size isEqualToString:@"FULL_BANNER"]) self.bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeFullBanner];
        else if ([size isEqualToString:@"LEADERBOARD"]) self.bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeLeaderboard];
        else self.bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];

        self.bannerPosition = position;
        self.bannerView.adUnitID = adUnitId;
        self.bannerView.rootViewController = self.viewController;
        self.bannerView.delegate = self;
        [self.bannerView loadRequest:[GADRequest request]];

        self.bannerCommand = command;
    } else {
        CDVPluginResult* pluginResult = nil;
        NSString *error = @"MobileAds not initialized or busy.";
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)hideBanner:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;

    if (initialized == true && self.bannerView != nil) {
        NSLog(@"Removing banner");
        [self.bannerView removeFromSuperview];

        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else {
        NSString *error = @"MobileAds or banner not initialized.";
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)addBannerViewToView:(UIView *)bannerView {
    bannerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.viewController.view addSubview:bannerView];

    if ([self.bannerPosition isEqualToString:@"TOP"]) {
        NSLog(@"Placing banner ad on top");
        [self.viewController.view addConstraints:@[
            [NSLayoutConstraint constraintWithItem:bannerView
                                       attribute:NSLayoutAttributeTop
                                       relatedBy:NSLayoutRelationEqual
                                          toItem:self.viewController.topLayoutGuide
                                       attribute:NSLayoutAttributeTop
                                      multiplier:1
                                        constant:0],

            [NSLayoutConstraint constraintWithItem:bannerView
                                       attribute:NSLayoutAttributeCenterX
                                       relatedBy:NSLayoutRelationEqual
                                          toItem:self.viewController.view
                                       attribute:NSLayoutAttributeCenterX
                                      multiplier:1
                                        constant:0]
                                        ]];
    }
    else {
        NSLog(@"Placing banner ad on bottom");
        [self.viewController.view addConstraints:@[
            [NSLayoutConstraint constraintWithItem:bannerView
                                       attribute:NSLayoutAttributeBottom
                                       relatedBy:NSLayoutRelationEqual
                                          toItem:self.viewController.bottomLayoutGuide
                                       attribute:NSLayoutAttributeTop
                                      multiplier:1
                                        constant:0],

            [NSLayoutConstraint constraintWithItem:bannerView
                                       attribute:NSLayoutAttributeCenterX
                                       relatedBy:NSLayoutRelationEqual
                                          toItem:self.viewController.view
                                       attribute:NSLayoutAttributeCenterX
                                      multiplier:1
                                        constant:0]
                                        ]];
    }

}

/// Tells the delegate an ad request succeeded.
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    NSLog(@"interstitialDidReceiveAd");

    if (self.interstitialCommand != nil) {
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.interstitialCommand.callbackId];
        self.interstitialCommand = nil;
    }
}

/// Tells the delegate an ad request failed.
- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"interstitial:didFailToReceiveAdWithError: %@", [error localizedDescription]);

    if (self.interstitialCommand != nil) {
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.interstitialCommand.callbackId];
        self.interstitialCommand = nil;
    }
}

/// Tells the delegate that an interstitial will be presented.
- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
    NSLog(@"interstitialWillPresentScreen");
}

/// Tells the delegate the interstitial is to be animated off the screen.
- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
    NSLog(@"interstitialWillDismissScreen");
}

/// Tells the delegate the interstitial had been animated off the screen.
- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
    NSLog(@"interstitialDidDismissScreen");

    if (self.interstitialCommand != nil) {
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.interstitialCommand.callbackId];
        self.interstitialCommand = nil;
    }
}

/// Tells the delegate that a user click will open another app
/// (such as the App Store), backgrounding the current app.
- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
    NSLog(@"interstitialWillLeaveApplication");
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
    didRewardUserWithReward:(GADAdReward *)reward {
  NSString *rewardMessage =
      [NSString stringWithFormat:@"Reward received with currency %@ , amount %lf",
          reward.type,
          [reward.amount doubleValue]];
    NSLog(rewardMessage);

    self.rewardType = reward.type;
    self.rewardAmount = reward.amount;
}

- (void)rewardBasedVideoAdDidReceiveAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad is received.");

    if (self.rewardedCommand != nil) {
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.rewardedCommand.callbackId];
        self.rewardedCommand = nil;
    }
}

- (void)rewardBasedVideoAdDidOpen:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Opened reward based video ad.");
}

- (void)rewardBasedVideoAdDidStartPlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad started playing.");
}

- (void)rewardBasedVideoAdDidCompletePlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad has completed.");
}

- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad is closed.");

    if (self.rewardedCommand != nil) {
        NSArray *keys = @[@"type",@"amount"];
        NSArray *objects = @[self.rewardType,self.rewardAmount];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects 
                                                               forKeys:keys];

        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dictionary];

        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.rewardedCommand.callbackId];
        self.rewardedCommand = nil;
    }
}

- (void)rewardBasedVideoAdWillLeaveApplication:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad will leave application.");
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd didFailToLoadWithError:(NSError *)error {
    NSLog(@"Reward based video ad failed to load.");

    if (self.rewardedCommand != nil) {
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.rewardedCommand.callbackId];
        self.rewardedCommand = nil;
    }
}

/// Tells the delegate an ad request loaded an ad.
- (void)adViewDidReceiveAd:(GADBannerView *)adView {
    NSLog(@"adViewDidReceiveAd");
    
    [self addBannerViewToView:self.bannerView];

    if (self.bannerCommand != nil) {
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.bannerCommand.callbackId];
        self.bannerCommand = nil;
    }
}

/// Tells the delegate an ad request failed.
- (void)adView:(GADBannerView *)adView didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"adView:didFailToReceiveAdWithError: %@", [error localizedDescription]);

    if (self.bannerCommand != nil) {
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.bannerCommand.callbackId];
        self.bannerCommand = nil;
    }
}

/// Tells the delegate that a full-screen view will be presented in response
/// to the user clicking on an ad.
- (void)adViewWillPresentScreen:(GADBannerView *)adView {
    NSLog(@"adViewWillPresentScreen");
}

/// Tells the delegate that the full-screen view will be dismissed.
- (void)adViewWillDismissScreen:(GADBannerView *)adView {
    NSLog(@"adViewWillDismissScreen");
}

/// Tells the delegate that the full-screen view has been dismissed.
- (void)adViewDidDismissScreen:(GADBannerView *)adView {
    NSLog(@"adViewDidDismissScreen");
}

/// Tells the delegate that a user click will open another app (such as
/// the App Store), backgrounding the current app.
- (void)adViewWillLeaveApplication:(GADBannerView *)adView {
    NSLog(@"adViewWillLeaveApplication");
}

@end
