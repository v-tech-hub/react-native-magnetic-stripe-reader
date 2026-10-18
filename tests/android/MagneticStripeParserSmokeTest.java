import us.fatehi.creditcardnumber.BankCard;
import us.fatehi.magnetictrack.bankcard.BankCardMagneticTrack;

public final class MagneticStripeParserSmokeTest {
    private static void check(boolean condition, String message) {
        if (!condition) {
            throw new AssertionError(message);
        }
    }

    public static void main(String[] args) {
        String track1 = "%B5350290149345177^FATEHI/SUALEH^16042010000000000000000000000000000567001000?";
        String track2 = ";5350290149345177=16042010000056700100?";

        BankCardMagneticTrack combined = BankCardMagneticTrack.from(track1 + track2);
        check(combined.getTrack1().hasRawData(), "track 1 should parse");
        check(combined.getTrack2().hasRawData(), "track 2 should parse");
        check(track2.equals(combined.getTrack2().getRawData()), "track 2 should retain its own raw data");
        check("5350290149345177".equals(combined.getTrack2().getAccountNumber().getAccountNumber()), "track 2 PAN should parse");

        BankCard combinedCard = combined.toBankCard();
        check("Sualeh Fatehi".equals(combinedCard.getCardHolderName()), "cardholder name should normalize");
        check("2016-04".equals(combinedCard.getExpirationDate().getExpirationDate().toString()), "expiration should normalize");
        check("MasterCard".equals(combinedCard.getPrimaryAccountNumber().getCardBrand().name()), "brand should match the iOS output");
        check("mii_5".equals(combinedCard.getPrimaryAccountNumber().getMajorIndustryIdentifier().name()), "MII should match the iOS output");
        check("Authorization Processing: Normal.".equals(combinedCard.getServiceCode().getServiceCode2().getDescription()), "service description should match the iOS output");

        BankCard track2OnlyCard = BankCardMagneticTrack.from(track2).toBankCard();
        check(track2OnlyCard.hasPrimaryAccountNumber(), "track 2-only card should parse");
        check(track2OnlyCard.getPrimaryAccountNumber().passesLuhnCheck(), "valid PAN should pass Luhn");

        System.out.println("All Android magnetic track parser smoke tests passed");
    }
}
