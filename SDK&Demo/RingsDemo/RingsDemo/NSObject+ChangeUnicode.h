//
//  NSObject+ChangeUnicode.h
//  Nokelock
//
//  Created by mac on 2022/4/15.
//  Copyright © 2022 wu.xiong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (ChangeUnicode)

+(NSString *)stringByReplaceUnicode:(NSString *)string;

@end

@interface NSArray (LengUnicode)

@end

@interface NSDictionary (LengUnicode)

@end


NS_ASSUME_NONNULL_END
