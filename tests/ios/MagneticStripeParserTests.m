#import <Foundation/Foundation.h>
#import "MagneticStripeParser.h"

static void Assert(BOOL condition, NSString *message)
{
    if (!condition) {
        NSLog(@"FAIL: %@", message);
        exit(1);
    }
}

int main(void)
{
    @autoreleasepool {
        NSString *track1 = @"%B5350290149345177^FATEHI/SUALEH^16042010000000000000000000000000000567001000?";
        NSString *track2 = @";5350290149345177=16042010000056700100?";
        NSDictionary *tracks = [MagneticStripeParser parseRawData:[track1 stringByAppendingString:track2] type:1];
        Assert([tracks[@"success"] boolValue], @"combined track data should parse");
        Assert([tracks[@"TRACK1"][@"name"] isEqualToString:@"Sualeh Fatehi"], @"track 1 name should be normalized");
        Assert([tracks[@"TRACK1"][@"expirationDate"] isEqualToString:@"2016-04"], @"track 1 expiration should parse");
        Assert([tracks[@"TRACK2"][@"rawData"] isEqualToString:track2], @"track 2 should use its own raw data");
        Assert(tracks[@"TRACK1"][@"serviceCode"] == nil, @"internal fields should not leak into track output");

        NSDictionary *card = [MagneticStripeParser parseRawData:track1 type:2];
        Assert([card[@"cardBrand"] isEqualToString:@"MasterCard"], @"MasterCard brand should be detected");
        Assert([card[@"passesLuhnCheck"] boolValue], @"valid PAN should pass Luhn");
        Assert([card[@"isPrimaryAccountNumberValid"] boolValue], @"valid PAN should be accepted");
        Assert([card[@"serviceCode1"][@"code"] integerValue] == 2, @"service code should parse");
        Assert([card[@"serviceCode3"][@"description"] containsString:@"None"], @"service code description should parse");

        NSDictionary *track2Only = [MagneticStripeParser parseRawData:track2 type:1];
        Assert([track2Only[@"success"] boolValue], @"track 2 should parse without track 1");
        Assert([track2Only[@"TRACK2"][@"primaryAccountNumber:"] isEqualToString:@"5350290149345177"], @"track 2 PAN should parse");

        NSDictionary *invalid = [MagneticStripeParser parseRawData:@"not card data" type:2];
        Assert(![invalid[@"success"] boolValue], @"invalid data should fail without throwing");
        Assert([invalid[@"message"] isEqualToString:@"No data found"], @"invalid data should return the public error");

        NSLog(@"All MagneticStripeParser tests passed");
    }
    return 0;
}
