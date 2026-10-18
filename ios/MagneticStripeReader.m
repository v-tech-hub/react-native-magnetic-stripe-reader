#import "MagneticStripeReader.h"
#import "MagneticStripeParser.h"

@implementation MagneticStripeReader

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(readBankCardData:(NSString *)rawData type:(nonnull NSNumber *)type callback:(RCTResponseSenderBlock)callback)
{
    callback(@[[MagneticStripeParser parseRawData:rawData type:type.integerValue]]);
}

@end
