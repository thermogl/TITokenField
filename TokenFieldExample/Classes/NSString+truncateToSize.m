//
//  NSString+FitRect.m
//  MyContentView
//
//  Created by chen neng on 13-8-16.
//
//

#import "NSString+truncateToSize.h"

@implementation NSString (truncateToSize)
 /* (NSString *)truncateToSize: withFont: lineBreakMode: */
- (NSString *)truncateToSize: (CGSize)size withFont: (UIFont *)font lineBreakMode: (UILineBreakMode)lineBreakMode {
    return [self truncateToSize: size withFont: font lineBreakMode: lineBreakMode withStartingAnchor: nil withEndingAnchor: nil];
}
 /* (NSString *)truncateToSize: withFont: lineBreakMode: withAnchor: */
- (NSString *)truncateToSize: (CGSize)size withFont: (UIFont *)font lineBreakMode: (UILineBreakMode)lineBreakMode withAnchor: (NSString *)anchor {
    return [self truncateToSize: size withFont: font lineBreakMode: lineBreakMode withStartingAnchor: anchor withEndingAnchor: anchor];
}
/* (NSString *)truncateToSize: withFont: lineBreakMode: withStartingAnchor: withEndingAnchor: */
- (NSString *)truncateToSize: (CGSize)size withFont: (UIFont *)font lineBreakMode: (UILineBreakMode)lineBreakMode withStartingAnchor: (NSString *)startingAnchor withEndingAnchor: (NSString *)endingAnchor {
    if( !( lineBreakMode & ( UILineBreakModeHeadTruncation | UILineBreakModeMiddleTruncation | UILineBreakModeTailTruncation ) ) )
        return self;
    if( [self sizeWithFont: font].width <= size.width )
        return self;
    
    NSString *ellipsis = @"…";
    
    // Note that this code will find the first occurrence of any given anchor,
    // so be careful when choosing anchor characters/strings...
    NSInteger start;
    if( startingAnchor ) {
        // Exact character-by-character equivalence,case-sensitively
        start = [self rangeOfString: startingAnchor options: NSLiteralSearch].location;
        if( NSNotFound == start ) {// If not found
            if( [startingAnchor isEqualToString: endingAnchor] )
                return [self truncateToSize: size withFont: font lineBreakMode: lineBreakMode];
            else
                return [self truncateToSize: size withFont: font lineBreakMode: lineBreakMode withAnchor: endingAnchor];
        }
    } else {
        start = 0;
    }
    
    NSUInteger end;
    if( endingAnchor ) {
        end = [self rangeOfString: endingAnchor options: NSLiteralSearch range: NSMakeRange( start + 1, [self length] - start - 1 )].location;
        if( NSNotFound == end ) {// If not found
            if( [startingAnchor isEqualToString: endingAnchor] )
                // Shouldn't ever occur, since filtered out in block above...
                return [self truncateToSize: size withFont: font lineBreakMode: lineBreakMode];
            else
                return [self truncateToSize: size withFont: font lineBreakMode: lineBreakMode withAnchor: startingAnchor];
        }
    } else {
        end = [self length];
    }
    
    NSUInteger targetLength = end - start;
    if( [[self substringWithRange: NSMakeRange( start, targetLength )] sizeWithFont: font].width < [ellipsis sizeWithFont: font].width )
        if( startingAnchor || endingAnchor ){
            return [self truncateToSize: size withFont: font lineBreakMode: lineBreakMode];
        }
    
    NSMutableString *truncatedString = [[NSMutableString alloc] initWithString: self];
    /* To void an "enumeration not handled in switch" warning arising,add a default clause statement or use :
     #pragma clang diagnostic push
     #pragma clang diagnostic ignored "-Wswitch"
     ...<switch statment>...
     #pragma clang diagnostic pop
     */
    switch(lineBreakMode){
        case UILineBreakModeHeadTruncation:
            // Avoid anchor...
            if( startingAnchor )
                start++;
            while( targetLength > [ellipsis length] + 1 && [truncatedString sizeWithFont: font].width > size.width) {
                // Replace our ellipsis and one additional following character with our ellipsis
                NSRange range = NSMakeRange( start, [ellipsis length] + 1 );
                [truncatedString replaceCharactersInRange: range withString: ellipsis];
                targetLength--;
            }
            break;
            
        case UILineBreakModeMiddleTruncation:
        {
            NSUInteger leftEnd = start + ( targetLength / 2 );
            NSUInteger rightStart = leftEnd + 1;
            
            if( leftEnd + 1 <= rightStart - 1 )
                break;
            
            // leftPre and rightPost consist of any characters before and beyond
            // any specified anchor(s).
            // left and right are the two halves of the string to be truncated - although
            // the initial split is still performed based upon the length of the
            // (sub)string to be truncated, so we could still make a bad initial split given
            // a short string with predominantly narrow characters on one side and wide
            // characters on the other.
            NSString *leftPre = @"";
            if( startingAnchor )
                leftPre = [truncatedString substringWithRange: NSMakeRange( 0,  start + 1 )];
            NSMutableString *left = [NSMutableString stringWithString: [truncatedString substringWithRange: NSMakeRange( ( startingAnchor ? start + 1 : start ), leftEnd - start )]];
            NSMutableString *right = [NSMutableString stringWithString: [truncatedString substringWithRange: NSMakeRange( rightStart, end - rightStart )]];
            NSString *rightPost = @"";
            if( endingAnchor )
                rightPost = [truncatedString substringWithRange: NSMakeRange( end, [truncatedString length] - end )];
            
            /* DLog( @"pre '%@', left '%@', right '%@', post '%@'", leftPre, left, right, rightPost ); */
            // Reassemble substrings
            [truncatedString setString: [NSString stringWithFormat: @"%@%@%@%@%@", leftPre, left, ellipsis, right, rightPost]];
            
            while( leftEnd > start + 1 && rightStart < end + 1 && [truncatedString sizeWithFont: font].width > size.width) {
                CGFloat leftLength = [left sizeWithFont: font].width;
                CGFloat rightLength = [right sizeWithFont: font].width;
                
                // Shorten string of longest width
                if( leftLength > rightLength ) {
                    [left deleteCharactersInRange: NSMakeRange( [left length] - 1, 1 )];
                    leftEnd--;
                } else { /* ( leftLength < = rightLength ) */
                    [right deleteCharactersInRange: NSMakeRange( 0, 1 )];
                    rightStart++;
                }
                
                /* DLog( @"pre '%@', left '%@', right'%@', post '%@'", leftPre, left, right, rightPost ); */
                [truncatedString setString: [NSString stringWithFormat: @"%@%@%@%@%@", leftPre, left, ellipsis, right, rightPost]];
            }
        }
            break;
            
        case UILineBreakModeTailTruncation:
            while( targetLength > [ellipsis length] + 1 && [truncatedString sizeWithFont: font].width > size.width) {
                // Remove last character
                NSRange range = NSMakeRange( --end, 1);
                [truncatedString deleteCharactersInRange: range];
                // Replace original last-but-one (now last) character with our ellipsis...
                range = NSMakeRange( end - [ellipsis length], [ellipsis length] );
                [truncatedString replaceCharactersInRange: range withString: ellipsis];
                targetLength--;
            }
            break;
        default:
            break;
    }
    
    NSString *result = [NSString stringWithString: truncatedString];
    return result;
}
- (NSString *)truncateWordsToFit:(CGSize)fitSize
                       withInset:(CGFloat)inset
                       usingFont:(UIFont *)font
                    wordSplitter:(NSString*)splitter
{
    NSString *result = [self copy];
    CGSize maxSize = CGSizeMake(fitSize.width  - (inset * 2), FLT_MAX);
    CGSize size = [result sizeWithFont:font
                     constrainedToSize:maxSize
                         lineBreakMode:UILineBreakModeWordWrap];
    NSRange range;
    
    if (fitSize.height < size.height)
        while (fitSize.height < size.height) {
            
            range = [result rangeOfString:splitter
                                  options:NSBackwardsSearch];
            
            if (range.location != NSNotFound && range.location > 0 ) {
                result = [result substringToIndex:range.location];
            } else {
                result = [result substringToIndex:result.length - 1];
            }
            
            size = [result sizeWithFont:font
                      constrainedToSize:maxSize
                          lineBreakMode:UILineBreakModeWordWrap];
        }
    
    return result;
}
@end