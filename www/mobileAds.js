module.exports = {
    initialize: function(appId, success, error) {
        cordova.exec(success, error, 'MobileAdsPlugin', 'initialize', [appId]);
    },

    loadInterstitial: function(adUnitId, success, error) {
        cordova.exec(success, error, 'MobileAdsPlugin', 'loadInterstitial', [adUnitId]);
    },

    showInterstitial: function(success, error) {
        cordova.exec(success, error, 'MobileAdsPlugin', 'showInterstitial', []);
    },

    loadRewardedVideoAd: function(adUnitId, success, error) {
        cordova.exec(success, error, 'MobileAdsPlugin', 'loadRewardedVideoAd', [adUnitId]);
    },

    showRewardedVideoAd: function(success, error) {
        cordova.exec(success, error, 'MobileAdsPlugin', 'showRewardedVideoAd', []);
    },

    showBanner: function(adUnitId, options, success, error) {
        options = options || {};
        options.position = options.position || 'BOTTOM';
        options.size = options.size || 'SMART_BANNER';
        cordova.exec(success, error, 'MobileAdsPlugin', 'showBanner', [adUnitId, options.size, options.position]);
    },

    hideBanner: function(success, error) {
        cordova.exec(success, error, 'MobileAdsPlugin', 'hideBanner', []);
    }
};
