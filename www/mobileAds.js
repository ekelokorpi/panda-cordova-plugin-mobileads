module.exports = {
    createBanner: function(param, success, error) {
        cordova.exec(success, error, 'MobileAds', 'createBanner', [param]);
    }
};
