package io.panda2.cordova;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdView;

public class MobileAds extends CordovaPlugin {
    private AdView mAdView;

    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("createBanner")) {
            String message = args.getString(0);
            this.createBanner(message, callbackContext);
            return true;
        }
        return false;
    }

    private void createBanner(String message, CallbackContext callbackContext) {
        AdView adView = new AdView(this.cordova.getActivity().getApplicationContext());
        adView.setAdSize(AdSize.BANNER);
        adView.setAdUnitId("ca-app-pub-3940256099942544/6300978111");

        AdRequest adRequest = new AdRequest.Builder().build();
        adView.loadAd(adRequest);
    }
}
