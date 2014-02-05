//
//  NSString+FitRect.h
//  MyContentView
//
//  Created by chen neng on 13-8-16.
//
//

#import <Foundation/Foundation.h>

//
//  NSString-truncateToSize
//  Fast Fonts
//
//  Created by Stuart Shelton on 28/03/2010.
//  Copyright 2010 Stuart Shelton. All rights reserved.
//

@interface NSString (truncateToSize)

- (NSString *)truncateToSize: (CGSize)size withFont: (UIFont *)font lineBreakMode: (UILineBreakMode)lineBreakMode;
- (NSString *)truncateToSize: (CGSize)size withFont: (UIFont *)font lineBreakMode: (UILineBreakMode)lineBreakMode withAnchor: (NSString *)anchor;
- (NSString *)truncateToSize: (CGSize)size withFont: (UIFont *)font lineBreakMode: (UILineBreakMode)lineBreakMode withStartingAnchor: (NSString *)startingAnchor withEndingAnchor: (NSString *)endingAnchor;
- (NSString *)truncateWordsToFit:(CGSize)fitSize
                       withInset:(CGFloat)inset
                       usingFont:(UIFont *)font
                    wordSplitter:(NSString*)splitter;
@end

