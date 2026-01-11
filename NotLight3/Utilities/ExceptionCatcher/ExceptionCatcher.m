
#import "ExceptionCatcher.h"

@implementation ExceptionCatcher

// based on http://stackoverflow.com/a/36454808/341994

+ (BOOL)catchException:(void(^)(void))tryBlock error:(__autoreleasing NSError **)error {
    @try {
        tryBlock();
        return YES;
    }
    @catch (NSException *exception) {
        *error = [[NSError alloc] initWithDomain: exception.name code: 0 userInfo: exception.userInfo];
        return NO;
    }
}

@end
