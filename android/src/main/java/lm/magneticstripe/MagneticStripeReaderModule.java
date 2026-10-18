/*
 * Copyright 2020 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package lm.magneticstripe;

import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableNativeMap;

import lm.magneticstripe.utils.MagneticStripeConverter;
import lm.magneticstripe.utils.MagneticStripeTypeConversion;
import us.fatehi.magnetictrack.bankcard.BankCardMagneticTrack;

public class MagneticStripeReaderModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;

    public MagneticStripeReaderModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "MagneticStripeReader";
    }

    @ReactMethod
    public void readBankCardData(String rawData, int tc, Callback callback) {
        try {
            BankCardMagneticTrack cardMagneticTrack = BankCardMagneticTrack.from(rawData);
            if (MagneticStripeTypeConversion.valueOfNumber(tc) == MagneticStripeTypeConversion.TRACK) {
                callback.invoke(MagneticStripeConverter.convertBankCardMagneticTrackToMap(cardMagneticTrack));
            } else {
                callback.invoke(MagneticStripeConverter.convertBankCardToMap(cardMagneticTrack.toBankCard()));
            }
        } catch (Exception exception) {
            WritableNativeMap result = new WritableNativeMap();
            result.putBoolean("success", false);
            result.putString("message", exception.getMessage() == null ? "Unable to parse card data" : exception.getMessage());
            callback.invoke(result);
        }
    }
}
