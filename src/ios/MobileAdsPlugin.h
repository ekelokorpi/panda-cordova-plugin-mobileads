#import <Cordova/CDVPlugin.h>

@import GoogleMobileAds;

@interface MobileAdsPlugin : CDVPlugin

@property(nonatomic, strong) GADInterstitial *interstitial;
@property(nonatomic, strong) CDVInvokedUrlCommand *interstitialCommand;
@property(nonatomic, strong) CDVInvokedUrlCommand *rewardedCommand;
@property(nonatomic, strong) CDVInvokedUrlCommand *bannerCommand;
@property(nonatomic, strong) NSString *rewardType;
@property(nonatomic, strong) NSString *rewardAmount;
@property(nonatomic, strong) GADBannerView *bannerView;
@property(nonatomic, strong) NSString *bannerPosition;

- (void)initialize:(CDVInvokedUrlCommand*)command;
- (void)loadInterstitial:(CDVInvokedUrlCommand*)command;
- (void)showInterstitial:(CDVInvokedUrlCommand*)command;
- (void)loadRewardedVideoAd:(CDVInvokedUrlCommand*)command;
- (void)showRewardedVideoAd:(CDVInvokedUrlCommand*)command;
- (void)showBanner:(CDVInvokedUrlCommand*)command;
- (void)hideBanner:(CDVInvokedUrlCommand*)command;

@end
