

#import <Foundation/Foundation.h>

@interface ExceptionCatcher : NSObject

+ (BOOL)catchException:(void(^)(void))tryBlock error:(__autoreleasing NSError **)error;

@end
