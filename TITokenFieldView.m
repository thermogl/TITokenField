//
//  TITokenFieldView.m
//  TITokenFieldView
//
//  Created by Tom Irving on 16/02/2010.
//  Copyright 2010 Tom Irving. All rights reserved.
//

#import "TITokenFieldView.h"

//==========================================================
// - Private Additions
//==========================================================

@interface TITokenFieldView ()
@property (nonatomic, retain) NSArray * tokenTitles;
@end

@interface TITokenFieldView (Private)
- (void)processLeftoverText:(NSString *)text;
- (void)resultsForSubstring:(NSString *)substring;
- (void)tokenFieldResized:(TITokenField *)aTokenField;
@end

@interface TITokenField (Private)
- (void)updateHeight:(BOOL)scrollToTop;
- (void)scrollForEdit:(BOOL)shouldMove;
- (void)performButtonAction;
- (NSArray *)getTokenTitles;
@end

@interface UIView (Private)
- (void)setHeight:(CGFloat)height;
- (void)setWidth:(CGFloat)width;
- (void)setOriginY:(CGFloat)originY;
@end

//==========================================================
// - TITokenFieldShadow
//==========================================================

@interface TITokenFieldShadow : UIView
@end

//==========================================================
// - TITokenFieldView
//==========================================================

#pragma mark -
#pragma mark TITokenFieldView
#pragma mark -
@implementation TITokenFieldView

@synthesize showAlreadyTokenized;
@synthesize delegate;

@synthesize resultsTable;
@synthesize contentView;
@synthesize separator;
@synthesize textFieldShadow;

@synthesize sourceArray;
@synthesize tokenTitles;

@synthesize tokenField;

NSString * const kTextEmpty = @" "; // Just a space
NSString * const kTextHidden = @"`"; // This character isn't available on the iPhone (yet) so it's safe.

CGFloat const kShadowHeight = 10;
CGFloat const kTokenFieldHeight = 42;
CGFloat const kSeparatorHeight = 1;

#pragma mark Main Shit
- (id)initWithFrame:(CGRect)frame {
	
    if ((self = [super initWithFrame:frame])){
		
		[self setBackgroundColor:[UIColor clearColor]];
		[self setDelaysContentTouches:NO];
		[self setMultipleTouchEnabled:NO];
		[self setScrollEnabled:YES];
		
		showAlreadyTokenized = NO;
		
		resultsArray = [[NSMutableArray alloc] init];
		
		// This view (contentView) is created for convenience, because it resizes and moves with the rest of the subviews.
		contentView = [[UIView alloc] initWithFrame:CGRectMake(0, kTokenFieldHeight, self.frame.size.width, self.frame.size.height - kTokenFieldHeight)];
		[contentView setBackgroundColor:[UIColor clearColor]];
		[self addSubview:contentView];
		[self setContentSize:CGSizeMake(self.frame.size.width, self.contentView.frame.origin.y + self.contentView.frame.size.height + 2)];
		[contentView release];
		
		tokenField = [[TITokenField alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, kTokenFieldHeight)];
		[tokenField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
		[tokenField setBackgroundColor:[UIColor whiteColor]];
		[tokenField setDelegate:self];
		[self addSubview:tokenField];
		[tokenField release];
		
		separator = [[UIView alloc] initWithFrame:CGRectMake(0, kTokenFieldHeight, self.frame.size.width, kSeparatorHeight)];
		[separator setBackgroundColor:[UIColor colorWithWhite:0.7 alpha:1]];
		[self addSubview:separator];
		[separator release];
		
		resultsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, kTokenFieldHeight + 1, self.frame.size.width, 10)];
		[resultsTable setSeparatorColor:[UIColor colorWithWhite:0.85 alpha:1]];
		[resultsTable setBackgroundColor:[UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1]];
		[resultsTable setDelegate:self];
		[resultsTable setDataSource:self];
		[resultsTable setHidden:YES];
		[self addSubview:resultsTable];
		[resultsTable release];
		
		textFieldShadow = [[TITokenFieldShadow alloc] initWithFrame:CGRectMake(0, kTokenFieldHeight + 1, self.frame.size.width, kShadowHeight)];
		[textFieldShadow setHidden:YES];
		[self addSubview:textFieldShadow];
		[textFieldShadow release];
		
		[self bringSubviewToFront:separator];
		[self updateContentSize];
	}
	
    return self;
}

- (void)setFrame:(CGRect)aFrame {
	
	[super setFrame:aFrame];
	
	CGFloat width = aFrame.size.width;
	[tokenField setWidth:width];
	[textFieldShadow setWidth:width];
	[separator setWidth:width];
	[resultsTable setWidth:width];
	[contentView setWidth:width];
	[contentView setHeight:aFrame.size.height - kTokenFieldHeight];
	
	[tokenField updateHeight:YES];
	[self updateContentSize];
	
	[self layoutSubviews];
}

- (void)setContentOffset:(CGPoint)offset {
	
	[super setContentOffset:offset];
	[self layoutSubviews];
}

- (void)layoutSubviews {
	
	CGFloat relativeFieldHeight = tokenField.frame.size.height - self.contentOffset.y;
	[resultsTable setHeight:(self.frame.size.height - relativeFieldHeight)];
}

- (void)updateContentSize {
	
	// I add 1 here so it'll do that elastic scrolling thing.
	// As a user, I like to drag a view around just for the sake of it.
	// Hopefully other people get the same weird kick :)
	[self setContentSize:CGSizeMake(self.frame.size.width, self.contentView.frame.origin.y + self.contentView.frame.size.height + 1)];
}

- (BOOL)canBecomeFirstResponder {
	return YES;
}

- (BOOL)becomeFirstResponder {
	return [tokenField becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
	return [tokenField resignFirstResponder];
}

#pragma mark TableView Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ([delegate respondsToSelector:@selector(tokenField:resultsTableView:heightForRowAtIndexPath:)]){
		return [delegate tokenField:tokenField resultsTableView:tableView heightForRowAtIndexPath:indexPath];
	}
	
	return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	// Hide the UITableView and shadow, then resize if there are no matches.
	
	if ([delegate respondsToSelector:@selector(tokenField:didFinishSearch:)]){
		[delegate tokenField:tokenField didFinishSearch:resultsArray];
	}
	
	BOOL hideTable = !resultsArray.count;
	[resultsTable setHidden:hideTable];
	[textFieldShadow setHidden:hideTable];
	[tokenField scrollForEdit:!hideTable];
	
	UIColor * separatorColor = hideTable ? [UIColor colorWithWhite:0.7 alpha:1] : [UIColor colorWithRed:150/255 green:150/255 blue:150/255 alpha:0.4];
	[separator setBackgroundColor:separatorColor];
	
	return resultsArray.count;
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ([delegate respondsToSelector:@selector(tokenField:resultsTableView:cellForObject:)]){
		return [delegate tokenField:tokenField resultsTableView:tableView cellForObject:[resultsArray objectAtIndex:indexPath.row]];
	}
	
    static NSString *CellIdentifier = @"ResultsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	
	[cell.textLabel setText:[resultsArray objectAtIndex:indexPath.row]];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tokenField addToken:[resultsArray objectAtIndex:indexPath.row]];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark TextField Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	
	[resultsArray removeAllObjects];
	[resultsTable reloadData];
	
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	
	if (![textField.text isEqualToString:kTextEmpty] && ![textField.text isEqualToString:kTextHidden] && ![textField.text isEqualToString:@""]){
		
		NSArray * titles = [[NSArray alloc] initWithArray:tokenTitles];
		for (NSString * title in titles) [tokenField addToken:title];
		[titles release];
		
	}
	
	[tokenField setText:kTextEmpty];
    [resultsTable reloadData];
	
	[tokenField updateHeight:NO];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	[self processLeftoverText:textField.text];
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	
	NSArray * tokens = [[NSArray alloc] initWithArray:tokenField.tokensArray];
	for (TIToken * token in tokens) [token removeFromSuperview];
	[tokens release];
	
	[self setTokenTitles:[tokenField getTokenTitles]];
	
	NSString * untokenized = [tokenTitles componentsJoinedByString:@", "];
	CGSize untokSize = [untokenized sizeWithFont:[UIFont systemFontOfSize:14]];
	
	[tokenField.tokensArray removeAllObjects];
	[tokenField updateHeight:YES];
	
	if (untokSize.width > self.frame.size.width - 120){
		untokenized = [NSString stringWithFormat:@"%d recipients", tokenTitles.count];
	}
	
	[textField setText:untokenized];
	
	[textFieldShadow setHidden:YES];
	[resultsTable setHidden:YES];
	
}

- (void)textFieldDidChange:(UITextField *)textField {
	
	if ([textField.text isEqualToString:@""] || textField.text.length == 0){
		[textField setText:kTextEmpty];
	}
	
	[textFieldShadow setHidden:NO];
	[resultsTable setHidden:NO];
	
	[self resultsForSubstring:textField.text];
	
	if ([delegate respondsToSelector:@selector(tokenFieldTextDidChange:)]){
		[delegate tokenFieldTextDidChange:tokenField];
	}
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	
	if ([string isEqualToString:@""] && [textField.text isEqualToString:kTextEmpty] && tokenField.tokensArray.count){
		
		//When the backspace is pressed, we capture it, highlight the last token, and hide the cursor.
		
		TIToken * tok = [tokenField.tokensArray lastObject];
		[tok setHighlighted:YES];
		[tokenField setText:kTextHidden];
		[tokenField updateHeight:NO];
		
		return NO;
	}
	
	if ([textField.text isEqualToString:kTextHidden] && ![string isEqualToString:@""]){
		// When the text is hidden, we don't want the user to be able to type anything.
		return NO;
	}
	
	if ([textField.text	isEqualToString:kTextHidden] && [string isEqualToString:@""]){
		
		// When the user presses backspace and the text is hidden,
		// we find the highlighted token, and remove it.
		
		for (TIToken * tok in [NSArray arrayWithArray:tokenField.tokensArray]){
			if (tok.highlighted){
				[tokenField removeToken:tok];
				return NO;
			}
		}
	}
	
	if ([string isEqualToString:@","]){
		[self processLeftoverText:textField.text];
		return NO;
	}
	
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	[self processLeftoverText:textField.text];
	
	if ([delegate respondsToSelector:@selector(tokenFieldShouldReturn:)]){
		return [delegate tokenFieldShouldReturn:tokenField];
	}
	
	return YES;
}

- (void)processLeftoverText:(NSString *)text {
	
	if (![text isEqualToString:kTextEmpty] && ![text isEqualToString:kTextHidden] && 
		[[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] != 0){
		
		NSUInteger loc = [[text substringWithRange:NSMakeRange(0, 1)] isEqualToString:@" "] ? 1 : 0;
		[tokenField addToken:[text substringWithRange:NSMakeRange(loc, text.length - 1)]];
	}
}

- (void)tokenFieldResized:(TITokenField *)aTokenField {
	
	[self setContentSize:CGSizeMake(self.frame.size.width, self.contentView.frame.origin.y + self.contentView.frame.size.height + 2)];
	
	if ([delegate respondsToSelector:@selector(tokenField:didChangeToFrame:)]){
		[delegate tokenField:aTokenField didChangeToFrame:aTokenField.frame];
	}
}

#pragma mark Results Methods
- (void)resultsForSubstring:(NSString *)substring {
	
	// The brute force searching method.
	// Takes the input string and compares it against everything in the source array.
	// If the source is massive, this could take some time.
	// You could always subclass and override this if needed or do it on a background thread.
	// GCD would be great for that.
	
	[resultsArray removeAllObjects];
	[resultsTable reloadData];
	
	NSUInteger loc = [[substring substringWithRange:NSMakeRange(0, 1)] isEqualToString:@" "] ? 1 : 0;
	NSString * typedString = [[substring substringWithRange:NSMakeRange(loc, substring.length - 1)] lowercaseString];
	
	NSArray * source = [[NSArray alloc] initWithArray:sourceArray];
	
	for (NSString * sourceObject in source){
		
		NSString * query = [sourceObject lowercaseString];
		
		if ([query rangeOfString:typedString].location != NSNotFound){
			
			if (showAlreadyTokenized){
				if (![resultsArray containsObject:sourceObject]){
					[resultsArray addObject:sourceObject];
				}
			}
			else
			{
				BOOL shouldAdd = YES;
				
				NSArray * tokens = [[NSArray alloc] initWithArray:tokenField.tokensArray];
				
				for (TIToken * token in tokens){
					if ([[token.title lowercaseString] rangeOfString:query].location != NSNotFound){
						shouldAdd = NO;
						break;
					}
				}
				
				[tokens release];
				
				if (shouldAdd){
					if (![resultsArray containsObject:sourceObject]){
						[resultsArray addObject:sourceObject];
					}
				}
			}
		}
	}
	
	[source release];
	
	[resultsArray sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	[resultsTable reloadData];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<TITokenFieldView %p 'Token count: %d'>", self, tokenTitles.count];
}

- (void)dealloc {
	[self setDelegate:nil];
	[tokenTitles release];
	[resultsArray release];
	[sourceArray release];
	[super dealloc];
}

@end
#pragma mark -
#pragma mark TITokenField
#pragma mark -
//==========================================================
// - TITokenField
//==========================================================

@implementation TITokenField
@synthesize tokensArray;
@synthesize numberOfLines;
@synthesize addButton;
@synthesize addButtonSelector;
@synthesize addButtonTarget;

- (id)initWithFrame:(CGRect)frame {
	
    if ((self = [super initWithFrame:frame])){
		
		[self setBorderStyle:UITextBorderStyleNone];
		[self setTextColor:[UIColor blackColor]];
		[self setFont:[UIFont systemFontOfSize:14]];
		[self setBackgroundColor:[UIColor whiteColor]];
		[self setAutocorrectionType:UITextAutocorrectionTypeNo];
		[self setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[self setTextAlignment:UITextAlignmentLeft];
		[self setKeyboardType:UIKeyboardTypeDefault];
		[self setReturnKeyType:UIReturnKeyDefault];
		[self setClearsOnBeginEditing:NO];
		[self setLeftViewMode:UITextFieldViewModeNever];
		
		UIButton * button = [UIButton buttonWithType:UIButtonTypeContactAdd];
		
		CGRect newFrame = button.frame;
		newFrame.origin = CGPointMake(self.frame.size.width - button.frame.size.width - 6, 
									  self.frame.size.height + self.frame.origin.y - button.frame.size.height - 6);
		[button setFrame:newFrame];
		[button setUserInteractionEnabled:YES];
		[button setHidden:YES];
		[button addTarget:self action:@selector(performButtonAction) forControlEvents:UIControlEventTouchUpInside];
		[self setAddButton:button];
		[self addSubview:addButton];
		
		[self setAddButtonSelector:nil];
		[self setAddButtonTarget:nil];
		
		// We don't just set a leftside view
		// as it centers vertically on resize.
		// This is not something we want,
		// so instead, we add a subview.
		[self setPromptText:@"To:"];
		[self setText:kTextEmpty];
		
		tokensArray = [[NSMutableArray alloc] init];
    }
	
    return self;
}

#pragma mark Token Handlers
- (void)addToken:(NSString *)title {
	
	if (title){
		
		if (![self isFirstResponder]) [self becomeFirstResponder];
		
		TIToken * token = [[TIToken alloc] initWithTitle:title];
		[token setDelegate:self];
		
		[self addSubview:token];
		[tokensArray addObject:token];
		[token release];
		
		[self updateHeight:NO];
		[self setText:kTextEmpty];
	}
}

- (void)removeToken:(TIToken *)token {
	
	[token removeFromSuperview];
	[tokensArray removeObject:token];
	
	[self setText:kTextEmpty];
	[self updateHeight:NO];
}

- (void)tokenGotFocus:(TIToken *)token {
	
	NSArray * tokens = [[NSArray alloc] initWithArray:tokensArray];
	for (TIToken * tok in tokens){
		if (tok != token) [tok setHighlighted:NO];
	}
	
	[tokens release];
	
	if (![self isFirstResponder]) [self becomeFirstResponder];
	
	[self setText:kTextHidden];
}

- (CGFloat)layoutTokens {
	
	// Adapted from Joe Hewitt's Three20 layout method.
	
	CGFloat fontHeight = (self.font.ascender - self.font.descender) + 1;
	CGFloat lineHeight = fontHeight + 15;
	CGFloat topMargin = floor(fontHeight / 1.75);
	CGFloat leftMargin = [self viewWithTag:123] ? [self viewWithTag:123].frame.size.width + 12 : 8;
	CGFloat rightMargin = 16;
	CGFloat rightMarginWithButton = addButton.hidden ? 8 : 46;
	CGFloat initialPadding = 8;
	CGFloat tokenPadding = 4;
	
	numberOfLines = 1;
	cursorLocation.x = leftMargin;
	cursorLocation.y = topMargin - 1;
	
	NSArray * tokens = [[NSArray alloc] initWithArray:tokensArray];
	
	for (TIToken * token in tokens){
		
		CGFloat lineWidth = cursorLocation.x + token.frame.size.width + rightMargin;
		
		if (lineWidth >= self.frame.size.width){
			
			numberOfLines++;
			cursorLocation.x = leftMargin;
			
			if (numberOfLines > 1) cursorLocation.x = initialPadding;
			cursorLocation.y += lineHeight;
		}
		
		CGRect oldFrame = CGRectMake(token.frame.origin.x, token.frame.origin.y, token.frame.size.width, token.frame.size.height);
		CGRect newFrame = CGRectMake(cursorLocation.x, cursorLocation.y, token.frame.size.width, token.frame.size.height);
		
		if (!CGRectEqualToRect(oldFrame, newFrame)){
			
			[token setFrame:newFrame];
			[token setAlpha:0.6];
			
			[UIView animateWithDuration:0.3 animations:^{[token setAlpha:1];}];
		}
		
		cursorLocation.x += token.frame.size.width + tokenPadding;
		
	}
	
	[tokens release];
	
	CGFloat leftoverWidth = self.frame.size.width - (cursorLocation.x + rightMarginWithButton);
	
	if (leftoverWidth < 50){
		
		numberOfLines++;
		cursorLocation.x = leftMargin;
		
		if (numberOfLines > 1) cursorLocation.x = initialPadding;
		cursorLocation.y += lineHeight;
	}
	
	return cursorLocation.y + fontHeight + topMargin + 5;
}

#pragma mark View Handlers

typedef void (^AnimationBlock)();

- (void)updateHeight:(BOOL)scrollToTop {
	
	CGFloat previousHeight = self.frame.size.height;
	CGFloat newHeight = [self layoutTokens];
	
	TITokenFieldView * parentView = (TITokenFieldView *)self.superview;
	
	if (previousHeight && previousHeight != newHeight){
		
		// Animating this seems to invoke the triple-tap-delete-key-loop-problem-thing™
		// No idea why, but for now, obviously we won't animate this stuff.
		
		AnimationBlock animationBlock = ^{
			[parentView.separator setOriginY:newHeight];
			[parentView.textFieldShadow setOriginY:newHeight];
			[parentView.resultsTable setOriginY:newHeight + 1];
			[parentView.contentView setOriginY:newHeight];
			[self setHeight:newHeight];
		};
		
		if (previousHeight < newHeight){
			[UIView animateWithDuration:0.3 animations:^{animationBlock();}];
		}
		else
		{
			animationBlock();
		}
		
		[parentView tokenFieldResized:self];
	}
	
	[addButton setFrame:CGRectMake(self.frame.size.width - addButton.frame.size.width - 6, 
								   self.frame.size.height + self.frame.origin.y - addButton.frame.size.height - 6, 
								   addButton.frame.size.width, 
								   addButton.frame.size.height)];
	
	if (scrollToTop) [parentView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)scrollForEdit:(BOOL)shouldMove {
	
	TITokenFieldView * parentView = (TITokenFieldView *)self.superview;
	
	[parentView setScrollsToTop:!shouldMove];
	[parentView setScrollEnabled:!shouldMove];
	
	CGFloat offset = numberOfLines == 1 || !shouldMove ? 0 : (self.frame.size.height - kTokenFieldHeight) + 1;
	[parentView setContentOffset:CGPointMake(0, self.frame.origin.y + offset) animated:YES];
}

#pragma mark Other
- (NSArray *)getTokenTitles {
	
	NSMutableArray * titles = [[NSMutableArray alloc] init];
	
	NSArray * tokens = [[NSArray alloc] initWithArray:tokensArray];
	for (TIToken * token in tokens) [titles addObject:token.title];
	[tokens release];
	
	return [titles autorelease];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	UITouch * touch = [[event allTouches] anyObject];
	CGPoint loc = [touch locationInView:self];
	
	if (CGRectContainsPoint(addButton.frame, loc) && addButtonSelector && addButtonTarget){
		// Very hacky method to get the button to respond.
		[self performButtonAction];
	}
	
	NSArray * tokens = [[NSArray alloc] initWithArray:tokensArray];
	for (TIToken * token in tokens) [token setHighlighted:NO];
	[tokens release];
	
	if ([self.text isEqualToString:kTextHidden]) [self setText:kTextEmpty];
	
	[super touchesBegan:touches withEvent:event];
}

- (void)setPromptText:(NSString *)aText {
	
	[[self viewWithTag:123] removeFromSuperview];
	
	CGSize titleSize = [aText sizeWithFont:[UIFont systemFontOfSize:17]];
	UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(8, 11, titleSize.width , titleSize.height)];
	[label setTag:123];
	[label setText:aText];
	[label setFont:[UIFont systemFontOfSize:15]];
	[label setTextColor:[UIColor colorWithWhite:0.5 alpha:1]];
	[label sizeToFit];
	[self addSubview:label];
	[label release];
	
	[self layoutTokens];
}

- (void)setAddButtonAction:(SEL)action target:(id)sender {
	
	[self setAddButtonSelector:action];
	[self setAddButtonTarget:sender];
	
	// Add button only appears if you don't pass nil.
	// Add button will then hide if you do pass nil.
	[addButton setHidden:(!action || !sender)];
}

- (void)performButtonAction {
	
	if (!self.editing) [self becomeFirstResponder];	
	[addButtonTarget performSelector:addButtonSelector];
}

- (CGRect)textRectForBounds:(CGRect)bounds {
	
	if ([self.text isEqualToString:kTextHidden]) return CGRectMake(0, -20, 0, 0);
	
	CGRect frame = CGRectOffset(bounds, cursorLocation.x, cursorLocation.y + 3);
	frame.size.width -= cursorLocation.x + (addButton.hidden ? 0 : 24) + 8;
	return frame;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
	return [self textRectForBounds:bounds];
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
	return [self textRectForBounds:bounds];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<TITokenField %p 'Prompt: %@'>", self, ((UILabel *)[self viewWithTag:123]).text];
}

- (void)dealloc {
	[self setDelegate:nil];
	[addButton release];
	[tokensArray release];
    [super dealloc];
}
#pragma mark -
#pragma mark TIToken
#pragma mark -

@end

//==========================================================
// - TIToken
//==========================================================

#define kTokenTitleFont [UIFont systemFontOfSize:14]

@implementation TIToken
@synthesize highlighted;
@synthesize title;
@synthesize delegate;
@synthesize croppedTitle;
@synthesize tintColor;

- (id)initWithTitle:(NSString *)aTitle {
	
	if ((self = [super init])){
		
		title = [aTitle copy];
		croppedTitle = [(aTitle.length > 24 ? [[aTitle substringToIndex:24] stringByAppendingString:@"..."] : aTitle) copy];
		
		//tintColor = [[UIColor colorWithRed:0.867 green:0.906 blue:0.973 alpha:1] retain];
		//tintColor = [[UIColor colorWithRed:0.871 green:0.749 blue:0.573 alpha:1.000] retain];
		
		CGSize tokenSize = [croppedTitle sizeWithFont:kTokenTitleFont];
		
		//We lay the tokens out all at once, so it doesn't matter what the X,Y coords are.
		[self setFrame:CGRectMake(0, 0, tokenSize.width + 17, tokenSize.height + 8)];
		[self setBackgroundColor:[UIColor clearColor]];
		
		UILongPressGestureRecognizer * longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self 
																										   action:@selector(tokenWasPressed:)];
		[longPressRecognizer setMinimumPressDuration:0];
		[self addGestureRecognizer:longPressRecognizer];
		[longPressRecognizer release];
	}
	
	return self;
}

- (void)drawRect:(CGRect)rect {
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGSize titleSize = [croppedTitle sizeWithFont:kTokenTitleFont];
	
	CGRect bounds = CGRectMake(0, 0, titleSize.width + 17, titleSize.height + 5);
	CGRect textBounds = bounds;
	textBounds.origin.x = (bounds.size.width - titleSize.width) / 2;
	textBounds.origin.y += 4;
	
	CGFloat arcValue = (bounds.size.height / 2) + 1;
	
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	CGPoint endPoint = CGPointMake(1, self.bounds.size.height + 10);
	
	// Draw the outline.
	CGContextSaveGState(context);
	CGContextBeginPath(context);
	CGContextAddArc(context, arcValue, arcValue, arcValue, (M_PI / 2), (3 * M_PI / 2), NO);
	CGContextAddArc(context, bounds.size.width - arcValue, arcValue, arcValue, 3 * M_PI / 2, M_PI / 2, NO);
	CGContextClosePath(context);
	
	/*
	 CGFloat red = 1;
	 CGFloat green = 1;
	 CGFloat blue = 1;
	 CGFloat alpha = 1;
	 [tintColor getRed:&red green:&green blue:&blue alpha:&alpha];
	 */
	
	if (highlighted){
		//CGContextSetFillColor(context, (CGFloat[8]){red * 0.236, green * 0.407, blue * 1.028, alpha});
		//CGContextSetFillColor(context, (CGFloat[8]){red - 0.669, green - 0.537, blue + 0.027, alpha});
		CGContextSetFillColor(context, (CGFloat[8]){0.207, 0.369, 1, 1});
		CGContextFillPath(context);
		CGContextRestoreGState(context);
	}
	else
	{
		CGContextClip(context);
		CGFloat locations[2] = {0, 0.95};
		//CGFloat components[8] = {red*0.720, green*0.809, blue*1.028, alpha, red*0.529, green*0.563, blue*0.862, alpha};
		//CGFloat components[8] = {red - 0.245, green - 0.173, blue + 0.027, alpha, red - 0.413, green - 0.396, blue - 0.134, alpha};
		CGFloat components[8] = {0.631, 0.733, 1, 1, 0.463, 0.510, 0.839, 1};
		CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, components, locations, 2);
		CGContextDrawLinearGradient(context, gradient, CGPointZero, endPoint, 0);
		CGGradientRelease(gradient);
		CGContextRestoreGState(context);
	}
	
	// Draw the inner gradient.
	CGContextSaveGState(context);
	CGContextBeginPath(context);
	CGContextAddArc(context, arcValue, arcValue, (bounds.size.height / 2), (M_PI / 2) , (3 * M_PI / 2), NO);
	CGContextAddArc(context, bounds.size.width - arcValue, arcValue, arcValue - 1, (3 * M_PI / 2), (M_PI / 2), NO);
	CGContextClosePath(context);
	
	CGContextClip(context);
	
	CGFloat locations[2] = {0, highlighted ? 0.8 : 0.4};
	/*
	 CGFloat nonHighlightedComp[8] = {red, green, blue, alpha, red*0.841, green*0.892, blue*0.973, alpha};
	 CGFloat highlightedComp[8] = {red*0.417, green*0.615, blue*1.028, alpha, red*0.287, green*0.381, blue*1.028, alpha};
	 */
	/*
	 CGFloat highlightedComp[8] = {red - 0.511, green - 0.349, blue + 0.027, alpha, red - 0.625, green - 0.561, blue + 0.027, alpha};
	 CGFloat nonHighlightedComp[8] = {red, green, blue, alpha, red - 0.139, green - 0.098, blue - 0.028, alpha};
	 */
	CGFloat highlightedComp[8] = {0.365, 0.557, 1, 1, 0.251, 0.345, 1, 1};
	CGFloat nonHighlightedComp[8] = {0.867, 0.906, 0.973, 1, 0.737, 0.808, 0.945, 1};
	
	CGGradientRef gradient = CGGradientCreateWithColorComponents (colorspace, highlighted ? highlightedComp : nonHighlightedComp, locations, 2);
	CGContextDrawLinearGradient(context, gradient, CGPointZero, endPoint, 0);
	CGGradientRelease(gradient);
	CGColorSpaceRelease(colorspace);
	
	[(highlighted ? [UIColor whiteColor] : [UIColor blackColor]) set];
	[croppedTitle drawInRect:textBounds withFont:kTokenTitleFont];
	
	CGContextRestoreGState(context);
}

- (void)tokenWasPressed:(UIGestureRecognizer *)gestureRecognizer {
	
	if (gestureRecognizer.state == UIGestureRecognizerStateChanged || gestureRecognizer.state == UIGestureRecognizerStateBegan){
		
		highlighted = CGRectContainsPoint(self.bounds, [gestureRecognizer locationInView:self]);
		[self setNeedsDisplay];
	}
	
	if (gestureRecognizer.state == UIGestureRecognizerStateEnded) [self setHighlighted:highlighted];
}

- (void)setHighlighted:(BOOL)flag {
	
	if (highlighted != flag){
		highlighted = flag;
		[self setNeedsDisplay];
	}
	
	if (flag && [delegate respondsToSelector:@selector(tokenGotFocus:)]){
		[delegate tokenGotFocus:self];
	}
	
	if (!flag && [delegate respondsToSelector:@selector(tokenLostFocus:)]){
		[delegate tokenLostFocus:self];
	}
}

- (void)setTintColor:(UIColor *)newTintColor {
	
	if (!newTintColor) newTintColor = [UIColor colorWithRed:0.867 green:0.906 blue:0.973 alpha:1];
	
	[newTintColor retain];
	[tintColor release];
	tintColor = newTintColor;
	
	[self setNeedsDisplay];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<TIToken %p '%@'>", self, title];
}

- (void)dealloc {
	[self setDelegate:nil];
	[croppedTitle release];
	[title release];
	[tintColor release];
    [super dealloc];
}

@end
#pragma mark -
#pragma mark TITokenFieldShadow
#pragma mark -
//==========================================================
// - TITokenFieldShadow
//==========================================================

@implementation TITokenFieldShadow

- (id)initWithFrame:(CGRect)frame {
	
    if ((self = [super initWithFrame:frame])){
		[self setBackgroundColor:[UIColor clearColor]];
    }
	
    return self;
}


- (void)drawRect:(CGRect)rect {
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGFloat components[8] = {0, 0, 0, 0.23, 0, 0, 0, 0};
	
	CGColorSpaceRef space = CGBitmapContextGetColorSpace(context);
	CGGradientRef gradient = CGGradientCreateWithColorComponents(space, components, nil, 2);
	
	CGPoint finish = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height);
	CGContextDrawLinearGradient(context, gradient, rect.origin, finish, kCGGradientDrawsAfterEndLocation);
	
	CGGradientRelease(gradient);
}

@end

#pragma mark -
#pragma mark Private Additions
#pragma mark -
//==========================================================
// - Private Additions
//==========================================================

@implementation UIView (Private)

- (void)setHeight:(CGFloat)height {
	
	CGRect newFrame = self.frame;
	newFrame.size.height = height;
	[self setFrame:newFrame];
}

- (void)setWidth:(CGFloat)width {
	
	CGRect newFrame = self.frame;
	newFrame.size.width = width;
	[self setFrame:newFrame];
}

- (void)setOriginY:(CGFloat)originY {
	
	CGRect newFrame = self.frame;
	newFrame.origin.y = originY;
	[self setFrame:newFrame];
}

@end