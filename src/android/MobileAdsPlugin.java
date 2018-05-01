package io.panda2.cordova;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.google.android.gms.ads.InterstitialAd;
import com.google.android.gms.ads.MobileAds;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdView;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.reward.RewardedVideoAd;
import com.google.android.gms.ads.reward.RewardedVideoAdListener;
import com.google.android.gms.ads.reward.RewardItem;

import android.provider.Settings;
import android.widget.RelativeLayout;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;

public class MobileAdsPlugin extends CordovaPlugin {
    private boolean initialized = false;
    private InterstitialAd mInterstitialAd;
    private RewardedVideoAd mRewardedVideoAd;
    private RelativeLayout mAdViewLayer;
    private AdView mAdView;

    public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {
        if (action.equals("initialize")) {
            String appId = args.getString(0);

            MobileAds.initialize(this.webView.getContext(), appId);

            initialized = true;
            callbackContext.success("");
            return true;
        }
        else if (initialized == false) {
            callbackContext.error("MobileAds not initialized");
            return true;
        }
        else if (action.equals("loadInterstitial")) {
            final String adUnitId = args.getString(0);

            this.cordova.getActivity().runOnUiThread(new Runnable() {
                public void run() {
                    loadInterstitial(adUnitId, callbackContext);
                }
            });
            
            return true;
        }
        else if (action.equals("showInterstitial")) {
            this.cordova.getActivity().runOnUiThread(new Runnable() {
                public void run() {
                    showInterstitial(callbackContext);
                }
            });

            return true;
        }
        else if (action.equals("loadRewardedVideoAd")) {
            final String adUnitId = args.getString(0);

            this.cordova.getActivity().runOnUiThread(new Runnable() {
                public void run() {
                    loadRewardedVideoAd(adUnitId, callbackContext);
                }
            });
            
            return true;
        }
        else if (action.equals("showRewardedVideoAd")) {
            this.cordova.getActivity().runOnUiThread(new Runnable() {
                public void run() {
                    showRewardedVideoAd(callbackContext);
                }
            });

            return true;
        }
        else if (action.equals("showBanner")) {
            final String adUnitId = args.getString(0);
            final String size = args.getString(1);
            final String position = args.getString(2);

            this.cordova.getActivity().runOnUiThread(new Runnable() {
                public void run() {
                    showBanner(adUnitId, size, position, callbackContext);
                }
            });

            return true;
        }
        else if (action.equals("hideBanner")) {
            this.cordova.getActivity().runOnUiThread(new Runnable() {
                public void run() {
                    hideBanner(callbackContext);
                }
            });
            
            return true;
        }
        return false;
    }

    private void loadRewardedVideoAd(String adUnitId, final CallbackContext callbackContext) {
        mRewardedVideoAd = MobileAds.getRewardedVideoAdInstance(this.webView.getContext());
        mRewardedVideoAd.setRewardedVideoAdListener(new RewardedVideoAdListener() {
            @Override
            public void onRewarded(RewardItem reward) {
            }

            @Override
            public void onRewardedVideoAdLoaded() {
                callbackContext.success("");
            }

            @Override
            public void onRewardedVideoAdFailedToLoad(int errorCode) {
                callbackContext.error("ERROR_UNKNOWN");
            }

            @Override
            public void onRewardedVideoCompleted() {
            }

            @Override
            public void onRewardedVideoAdLeftApplication() {
            }

            @Override
            public void onRewardedVideoStarted() {
            }

            @Override
            public void onRewardedVideoAdClosed() {
            }

            @Override
            public void onRewardedVideoAdOpened() {
            }
        });

        mRewardedVideoAd.loadAd(adUnitId, new AdRequest.Builder().build());
    }

    private void showRewardedVideoAd(final CallbackContext callbackContext) {
        if (mRewardedVideoAd.isLoaded()) {
            mRewardedVideoAd.setRewardedVideoAdListener(new RewardedVideoAdListener() {
                String type = "";
                int amount = 0;

                @Override
                public void onRewarded(RewardItem reward) {
                    type = reward.getType();
                    amount = reward.getAmount();
                }

                @Override
                public void onRewardedVideoAdClosed() {
                    JSONObject obj = new JSONObject();

                    try {
                        obj.put("type", type);
                        obj.put("amount", amount);
                    } catch (JSONException e) {

                    }

                    callbackContext.success(obj);
                }

                @Override
                public void onRewardedVideoAdLoaded() {
                }

                @Override
                public void onRewardedVideoAdLeftApplication() {
                }

                @Override
                public void onRewardedVideoCompleted() {
                }

                @Override
                public void onRewardedVideoAdFailedToLoad(int errorCode) {
                }

                @Override
                public void onRewardedVideoStarted() {
                }

                @Override
                public void onRewardedVideoAdOpened() {
                }
            });
            mRewardedVideoAd.show();
        } else {
            callbackContext.error("Rewarded video ad not loaded");
        }
    }

    private void loadInterstitial(String adUnitId, final CallbackContext callbackContext) {
        mInterstitialAd = new InterstitialAd(this.webView.getContext());
        mInterstitialAd.setAdUnitId(adUnitId);
        mInterstitialAd.setAdListener(new AdListener() {
            @Override
            public void onAdLoaded() {
                callbackContext.success("");
            }

            @Override
            public void onAdFailedToLoad(int errorCode) {
                if (errorCode == AdRequest.ERROR_CODE_INTERNAL_ERROR) {
                    callbackContext.error("ERROR_CODE_INTERNAL_ERROR");
                }
                else if (errorCode == AdRequest.ERROR_CODE_INVALID_REQUEST) {
                    callbackContext.error("ERROR_CODE_INVALID_REQUEST");
                }
                else if (errorCode == AdRequest.ERROR_CODE_NETWORK_ERROR) {
                    callbackContext.error("ERROR_CODE_NETWORK_ERROR");
                }
                else if (errorCode == AdRequest.ERROR_CODE_NO_FILL) {
                    callbackContext.error("ERROR_CODE_NO_FILL");
                }
                else {
                    callbackContext.error("ERROR_UNKNOWN");
                }
            }
        });
        mInterstitialAd.loadAd(new AdRequest.Builder().build());
    }

    private void showInterstitial(final CallbackContext callbackContext) {
        if (mInterstitialAd.isLoaded()) {
            mInterstitialAd.setAdListener(new AdListener() {
                @Override
                public void onAdClosed() {
                    callbackContext.success("");
                }
            });
            mInterstitialAd.show();
        } else {
            callbackContext.error("The interstitial wasn't loaded yet.");
        }
    }

    private void showBanner(String adUnitId, String size, String position, final CallbackContext callbackContext) {
        mAdView = new AdView(this.cordova.getActivity());
        if (size.equals("BANNER")) mAdView.setAdSize(AdSize.BANNER);
        else if (size.equals("LARGE_BANNER")) mAdView.setAdSize(AdSize.LARGE_BANNER);
        else if (size.equals("MEDIUM_RECTANGLE")) mAdView.setAdSize(AdSize.MEDIUM_RECTANGLE);
        else if (size.equals("FULL_BANNER")) mAdView.setAdSize(AdSize.FULL_BANNER);
        else if (size.equals("LEADERBOARD")) mAdView.setAdSize(AdSize.LEADERBOARD);
        else mAdView.setAdSize(AdSize.SMART_BANNER);
        mAdView.setAdUnitId(adUnitId);

        AdRequest adRequest = new AdRequest.Builder().build();
        mAdView.loadAd(adRequest);

        mAdViewLayer = new RelativeLayout(this.webView.getContext());
        RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT);
        if (position.equals("TOP")) layoutParams.addRule(RelativeLayout.ALIGN_PARENT_TOP);
        else layoutParams.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
        mAdViewLayer.addView(mAdView, layoutParams);

        ViewGroup.LayoutParams outerLayout = new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT);
        this.cordova.getActivity().addContentView(mAdViewLayer, outerLayout);
        callbackContext.success("");
    }

    private void hideBanner(final CallbackContext callbackContext) {
        if (mAdViewLayer != null) {
            if (mAdViewLayer.getParent() != null) {
                ((ViewGroup) mAdViewLayer.getParent()).removeView(mAdViewLayer);
            }
            mAdViewLayer.removeView(mAdView);
            mAdViewLayer.setVisibility(View.GONE);

            mAdViewLayer = null;
            mAdView = null;

            callbackContext.success("");
        }
        else {
            callbackContext.error("Banner not found");
        }
    }
}
