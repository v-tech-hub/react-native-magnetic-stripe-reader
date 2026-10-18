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
package lm.magneticstripe.utils;

import com.facebook.react.bridge.WritableNativeMap;

import us.fatehi.creditcardnumber.BankCard;
import us.fatehi.creditcardnumber.ServiceCode;
import us.fatehi.magnetictrack.bankcard.BankCardMagneticTrack;
/**
 * Utility class for converting one type of {@link BankCardMagneticTrack} to another
 *
 * @author Phu Le
 * @date 2020-10-01
 */
public class MagneticStripeConverter {
    /**
     * Converts a BankCardMagneticTrack to a WritableNativeMap
     * @param cardMagneticTrack the object to use
     * @return a {@link WritableNativeMap} that can be used later
     */
    public static WritableNativeMap convertBankCardMagneticTrackToMap(BankCardMagneticTrack cardMagneticTrack){
        try{
            WritableNativeMap map = new WritableNativeMap();
            map.putBoolean("success",false);
            map.putString("message","No data found");
            if(cardMagneticTrack.getTrack1().hasRawData()){
                map.putBoolean("success",true);
                map.putString("message","ok");
                WritableNativeMap track1 = new WritableNativeMap();
                track1.putString("rawData",cardMagneticTrack.getTrack1().getRawData());
                track1.putString("primaryAccountNumber:",cardMagneticTrack.getTrack1().getAccountNumber().getAccountNumber());
                track1.putString("expirationDate",cardMagneticTrack.getTrack1().getExpirationDate().getExpirationDate().toString());
                track1.putString("name",cardMagneticTrack.getTrack1().getName().getFullName());
                track1.putString("discretionaryData",cardMagneticTrack.getTrack1().getDiscretionaryData());
                map.putMap("TRACK1",track1);
            }
            if(cardMagneticTrack.getTrack2().hasRawData()){
                map.putBoolean("success",true);
                map.putString("message","ok");
                WritableNativeMap track2 = new WritableNativeMap();
                track2.putString("rawData",cardMagneticTrack.getTrack2().getRawData());
                track2.putString("primaryAccountNumber:",cardMagneticTrack.getTrack2().getAccountNumber().getAccountNumber());
                track2.putString("expirationDate",cardMagneticTrack.getTrack2().getExpirationDate().getExpirationDate().toString());
                track2.putString("discretionaryData",cardMagneticTrack.getTrack2().getDiscretionaryData());
                map.putMap("TRACK2",track2);
            }
            if(cardMagneticTrack.getTrack3().hasRawData()){
                map.putBoolean("success",true);
                map.putString("message","ok");
                WritableNativeMap track3 = new WritableNativeMap();
                track3.putString("rawData",cardMagneticTrack.getTrack3().getRawData());
                track3.putString("discretionaryData",cardMagneticTrack.getTrack3().getDiscretionaryData());
                map.putMap("TRACK3",track3);
            }
            return map;
        }catch(Exception e){
            String error = e.getMessage();
            WritableNativeMap map = new WritableNativeMap();
            map.putBoolean("success",false);
            map.putString("message",error);
            return map;
        }
    }
    /**
     * Converts a BankCard to a WritableNativeMap
     * @param bankCard the object to use
     * @return a {@link WritableNativeMap} that can be used later
     */
    public static WritableNativeMap convertBankCardToMap(BankCard bankCard){
        try{
            WritableNativeMap map = new WritableNativeMap();
            map.putBoolean("success",false);
            map.putString("message","No data found");
            if (bankCard.hasPrimaryAccountNumber()) {
                map.putBoolean("success",true);
                map.putString("message","ok");
                map.putString("rawAccountNumber",bankCard.getAccountNumber());
                map.putString("primaryAccountNumber",bankCard.getPrimaryAccountNumber().getAccountNumber());
                map.putString("majorIndustryIdentifier",bankCard.getPrimaryAccountNumber().getMajorIndustryIdentifier().name());
                map.putString("issuerIdentificationNumber",bankCard.getPrimaryAccountNumber().getIssuerIdentificationNumber());
                map.putString("cardBrand",bankCard.getPrimaryAccountNumber().getCardBrand().name());
                map.putString("lastFourDigits",bankCard.getPrimaryAccountNumber().getLastFourDigits());
                map.putBoolean("passesLuhnCheck",bankCard.getPrimaryAccountNumber().passesLuhnCheck());
                map.putBoolean("isPrimaryAccountNumberValid",bankCard.getPrimaryAccountNumber().isPrimaryAccountNumberValid());
            }
            if (bankCard.hasExpirationDate()) {
                map.putString("expirationDate",bankCard.getExpirationDate().getExpirationDate().toString());
                map.putBoolean("isExpired",bankCard.isExpired());
            }
            if (bankCard.hasName()) {
                map.putString("name",bankCard.getCardHolderName());
            }
            if (bankCard.hasServiceCode()) {
                ServiceCode serviceCode = bankCard.getServiceCode();
                WritableNativeMap sc1 = new WritableNativeMap();
                sc1.putInt("code",serviceCode.getServiceCode1().getValue());
                sc1.putString("description",serviceCode.getServiceCode1().getDescription());
                map.putMap("serviceCode1",sc1);

                WritableNativeMap sc2 = new WritableNativeMap();
                sc2.putInt("code",serviceCode.getServiceCode2().getValue());
                sc2.putString("description",serviceCode.getServiceCode2().getDescription());
                map.putMap("serviceCode2",sc2);

                WritableNativeMap sc3 = new WritableNativeMap();
                sc3.putInt("code",serviceCode.getServiceCode3().getValue());
                sc3.putString("description",serviceCode.getServiceCode3().getDescription());
                map.putMap("serviceCode3",sc3);

            }
            return map;
        }catch(Exception e){
            String error = e.getMessage();
            WritableNativeMap map = new WritableNativeMap();
            map.putBoolean("success",false);
            map.putString("message",error);
            return map;
        }
    }
}
