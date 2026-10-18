#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MagneticStripeParser : NSObject

+ (NSDictionary<NSString *, id> *)parseRawData:(NSString *)rawData type:(NSInteger)type;

@end

NS_ASSUME_NONNULL_END
