#import "MagneticStripeParser.h"

@implementation MagneticStripeParser

+ (NSDictionary<NSString *,id> *)parseRawData:(NSString *)rawData type:(NSInteger)type
{
    NSDictionary *track1 = [self track1InString:rawData ?: @""];
    NSDictionary *track2 = [self track2InString:rawData ?: @""];

    // Android treats every value other than 2 as TRACK.
    if (type != 2) {
        NSMutableDictionary *result = [@{ @"success": @NO, @"message": @"No data found" } mutableCopy];
        if (track1 != nil) {
            NSMutableDictionary *publicTrack1 = [track1 mutableCopy];
            [publicTrack1 removeObjectForKey:@"serviceCode"];
            result[@"TRACK1"] = publicTrack1;
        }
        if (track2 != nil) {
            NSMutableDictionary *publicTrack2 = [track2 mutableCopy];
            [publicTrack2 removeObjectForKey:@"serviceCode"];
            result[@"TRACK2"] = publicTrack2;
        }
        if (track1 != nil || track2 != nil) {
            result[@"success"] = @YES;
            result[@"message"] = @"ok";
        }
        return result;
    }

    NSDictionary *preferredTrack = track1 ?: track2;
    if (preferredTrack == nil) {
        return @{ @"success": @NO, @"message": @"No data found" };
    }

    NSString *pan = preferredTrack[@"primaryAccountNumber:"];
    NSMutableDictionary *result = [@{
        @"success": @YES,
        @"message": @"ok",
        @"rawAccountNumber": pan,
        @"primaryAccountNumber": pan,
        @"majorIndustryIdentifier": [self majorIndustryIdentifierForPAN:pan],
        @"issuerIdentificationNumber": [self issuerIdentificationNumberForPAN:pan],
        @"cardBrand": [self cardBrandForPAN:pan],
        @"lastFourDigits": [self lastFourDigitsForPAN:pan],
        @"passesLuhnCheck": @([self passesLuhnCheck:pan]),
        @"isPrimaryAccountNumberValid": @([self isValidPAN:pan])
    } mutableCopy];

    NSString *expirationDate = preferredTrack[@"expirationDate"];
    if (expirationDate != nil) {
        result[@"expirationDate"] = expirationDate;
        result[@"isExpired"] = @([self isExpired:expirationDate]);
    }
    NSString *name = preferredTrack[@"name"];
    if (name.length > 0) {
        result[@"name"] = name;
    }

    NSString *serviceCode = preferredTrack[@"serviceCode"];
    if (serviceCode.length == 3) {
        result[@"serviceCode1"] = [self serviceCodePart:1 digit:[serviceCode characterAtIndex:0] - '0'];
        result[@"serviceCode2"] = [self serviceCodePart:2 digit:[serviceCode characterAtIndex:1] - '0'];
        result[@"serviceCode3"] = [self serviceCodePart:3 digit:[serviceCode characterAtIndex:2] - '0'];
    }
    return result;
}

+ (nullable NSDictionary *)track1InString:(NSString *)rawData
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"%B([0-9]{1,19})\\^([^\\^]*)\\^([0-9]{2})([0-9]{2})([0-9]{3})([^?]*)\\?" options:0 error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:rawData options:0 range:NSMakeRange(0, rawData.length)];
    if (match == nil) {
        return nil;
    }

    NSString *(^part)(NSUInteger) = ^NSString *(NSUInteger index) {
        return [rawData substringWithRange:[match rangeAtIndex:index]];
    };
    NSString *pan = part(1);
    NSString *year = part(3);
    NSString *month = part(4);
    if (![self isValidMonth:month]) {
        return nil;
    }

    NSMutableDictionary *track = [@{
        @"rawData": [rawData substringWithRange:match.range],
        @"primaryAccountNumber:": pan,
        @"expirationDate": [NSString stringWithFormat:@"20%@-%@", year, month],
        @"discretionaryData": part(6),
        @"serviceCode": part(5)
    } mutableCopy];
    NSString *name = [self normalizedName:part(2)];
    if (name.length > 0) {
        track[@"name"] = name;
    }
    return track;
}

+ (nullable NSDictionary *)track2InString:(NSString *)rawData
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@";([0-9]{1,19})=([0-9]{2})([0-9]{2})([0-9]{3})([^?]*)\\?" options:0 error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:rawData options:0 range:NSMakeRange(0, rawData.length)];
    if (match == nil) {
        return nil;
    }

    NSString *(^part)(NSUInteger) = ^NSString *(NSUInteger index) {
        return [rawData substringWithRange:[match rangeAtIndex:index]];
    };
    NSString *month = part(3);
    if (![self isValidMonth:month]) {
        return nil;
    }
    return @{
        @"rawData": [rawData substringWithRange:match.range],
        @"primaryAccountNumber:": part(1),
        @"expirationDate": [NSString stringWithFormat:@"20%@-%@", part(2), month],
        @"discretionaryData": part(5),
        @"serviceCode": part(4)
    };
}

+ (BOOL)isValidMonth:(NSString *)month
{
    NSInteger value = month.integerValue;
    return value >= 1 && value <= 12;
}

+ (NSString *)normalizedName:(NSString *)rawName
{
    NSArray<NSString *> *components = [rawName componentsSeparatedByString:@"/"];
    NSString *surname = components.count > 0 ? components[0] : @"";
    NSString *givenNames = components.count > 1 ? components[1] : @"";
    NSString *combined = givenNames.length > 0
        ? [NSString stringWithFormat:@"%@ %@", givenNames, surname]
        : surname;
    combined = [[combined stringByReplacingOccurrencesOfString:@"_" withString:@" "]
                 stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    return combined.capitalizedString;
}

+ (BOOL)passesLuhnCheck:(NSString *)pan
{
    if (pan.length == 0) {
        return NO;
    }
    NSInteger sum = 0;
    BOOL doubleDigit = NO;
    for (NSInteger index = (NSInteger)pan.length - 1; index >= 0; index--) {
        unichar character = [pan characterAtIndex:(NSUInteger)index];
        if (character < '0' || character > '9') {
            return NO;
        }
        NSInteger digit = character - '0';
        if (doubleDigit) {
            digit *= 2;
            if (digit > 9) {
                digit -= 9;
            }
        }
        sum += digit;
        doubleDigit = !doubleDigit;
    }
    return sum % 10 == 0;
}

+ (BOOL)isValidPAN:(NSString *)pan
{
    NSMutableIndexSet *validLengths = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(13, 4)];
    [validLengths addIndex:19];
    return [validLengths containsIndex:pan.length]
        && [self passesLuhnCheck:pan]
        && ![[self cardBrandForPAN:pan] isEqualToString:@"Unknown"];
}

+ (NSString *)majorIndustryIdentifierForPAN:(NSString *)pan
{
    if (pan.length == 0) {
        return @"unknown";
    }
    unichar first = [pan characterAtIndex:0];
    return first >= '0' && first <= '9'
        ? [NSString stringWithFormat:@"mii_%C", first]
        : @"unknown";
}

+ (NSString *)cardBrandForPAN:(NSString *)pan
{
    if ([self string:pan matchesPattern:@"^4[0-9]{6,}$"]) {
        return @"Visa";
    }
    if ([self string:pan matchesPattern:@"^5[1-5][0-9]{5,}$|^(222[1-9]|2[3-6][0-9][0-9]|27[0-1][0-9]|2720)[0-9]{12}$"]) {
        return @"MasterCard";
    }
    if ([self string:pan matchesPattern:@"^3[47][0-9]{5,}$"]) {
        return @"AmericanExpress";
    }
    if ([self string:pan matchesPattern:@"^3(?:0[0-5]|[68][0-9])[0-9]{4,}$"]) {
        return @"DinersClub";
    }
    if ([self string:pan matchesPattern:@"^6(?:011|5[0-9]{2})[0-9]{3,}$"]) {
        return @"Discover";
    }
    if ([self string:pan matchesPattern:@"^(?:2131|1800|35[0-9]{3})[0-9]{3,}$"]) {
        return @"JCB";
    }
    return @"Unknown";
}

+ (BOOL)string:(NSString *)string matchesPattern:(NSString *)pattern
{
    NSRange range = [string rangeOfString:pattern options:NSRegularExpressionSearch];
    return range.location != NSNotFound && NSEqualRanges(range, NSMakeRange(0, string.length));
}

+ (NSString *)issuerIdentificationNumberForPAN:(NSString *)pan
{
    NSString *issuer = pan.length > 6 ? [pan substringToIndex:6] : pan;
    return [issuer stringByPaddingToLength:6 withString:@"0" startingAtIndex:0];
}

+ (NSString *)lastFourDigitsForPAN:(NSString *)pan
{
    NSString *lastFour = pan.length > 4 ? [pan substringFromIndex:pan.length - 4] : pan;
    if (lastFour.length >= 4) {
        return lastFour;
    }
    return [[@"0000" substringToIndex:4 - lastFour.length] stringByAppendingString:lastFour];
}

+ (BOOL)isExpired:(NSString *)expirationDate
{
    NSArray<NSString *> *parts = [expirationDate componentsSeparatedByString:@"-"];
    if (parts.count != 2) {
        return NO;
    }
    NSInteger year = parts[0].integerValue;
    NSInteger month = parts[1].integerValue;
    NSDateComponents *now = [NSCalendar.currentCalendar components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:NSDate.date];
    return year < now.year || (year == now.year && month < now.month);
}

+ (NSDictionary *)serviceCodePart:(NSInteger)part digit:(NSInteger)digit
{
    NSDictionary<NSNumber *, NSString *> *descriptions;
    NSString *unknownDescription;
    if (part == 1) {
        descriptions = @{
            @1: @"Interchange: International interchange. Technology: None.",
            @2: @"Interchange: International interchange. Technology: Integrated circuit card.",
            @5: @"Interchange: National interchange. Technology: None.",
            @6: @"Interchange: National interchange. Technology: Integrated circuit card.",
            @7: @"Interchange: Private. Technology: None.",
            @9: @"Interchange: Test. Technology: Test."
        };
        unknownDescription = @"Interchange: Unknown. Technology: .";
    } else if (part == 2) {
        descriptions = @{
            @0: @"Authorization Processing: Normal.",
            @2: @"Authorization Processing: By issuer.",
            @4: @"Authorization Processing: By issuer unless explicit bilateral agreeement applies."
        };
        unknownDescription = @"Authorization Processing: Unknown.";
    } else {
        descriptions = @{
            @0: @"Allowed Services: No restrictions. PIN Requirements: PIN required.",
            @1: @"Allowed Services: No restrictions. PIN Requirements: None.",
            @2: @"Allowed Services: Goods and services only. PIN Requirements: None.",
            @3: @"Allowed Services: ATM only. PIN Requirements: PIN required.",
            @4: @"Allowed Services: Cash only. PIN Requirements: None.",
            @5: @"Allowed Services: Goods and services only. PIN Requirements: PIN required.",
            @6: @"Allowed Services: No restrictions. PIN Requirements: Prompt for PIN if PED present.",
            @7: @"Allowed Services: Goods and services only. PIN Requirements: Prompt for PIN if PED present."
        };
        unknownDescription = @"Allowed Services: Unknown. PIN Requirements: .";
    }
    NSString *description = descriptions[@(digit)];
    return @{
        @"code": description == nil ? @(-1) : @(digit),
        @"description": description ?: unknownDescription
    };
}

@end
