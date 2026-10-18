#import <Foundation/Foundation.h>

@protocol RCTBridgeModule <NSObject>
@end

typedef void (^RCTResponseSenderBlock)(NSArray *response);

#define RCT_EXPORT_MODULE() \
    + (NSString *)moduleName { return @"MagneticStripeReader"; }

#define RCT_EXPORT_METHOD(method) - (void)method
