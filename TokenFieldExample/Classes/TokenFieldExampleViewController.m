//
//  TokenFieldExampleViewController.m
//  TokenFieldExample
//
//  Created by Tom Irving on 29/01/2011.
//  Copyright 2011 Tom Irving. All rights reserved.
//

#import "TokenFieldExampleViewController.h"
#import "Names.h"

@interface TokenFieldExampleViewController (Private)
- (void)resizeViews;
@end

@implementation TokenFieldExampleViewController

- (void)viewDidLoad {
	
	[self.view setBackgroundColor:[UIColor whiteColor]];
	[self.navigationItem setTitle:@"TITokenFieldView"];
	
	tokenFieldView = [[TITokenFieldView alloc] initWithFrame:self.view.bounds];
	[tokenFieldView setDelegate:self];
	[tokenFieldView setSourceArray:[Names listOfNames]];
	[tokenFieldView.tokenField setAddButtonAction:@selector(showContactsPicker) target:self];
	
	messageView = [[UITextView alloc] initWithFrame:tokenFieldView.contentView.bounds];
	[messageView setScrollEnabled:NO];
	[messageView setAutoresizingMask:UIViewAutoresizingNone];
	[messageView setDelegate:self];
	[messageView setFont:[UIFont systemFontOfSize:15]];
	[messageView setText:@"Some message. The whole view resizes as you type, not just the text view."];
	[tokenFieldView.contentView addSubview:messageView];
	[messageView release];
	
	[self.view addSubview:tokenFieldView];
	[tokenFieldView release];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	
	// You can call this on either the view on the field.
	// They both do the same thing.
	[tokenFieldView becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[UIView animateWithDuration:duration animations:^{[self resizeViews];}]; // Make it pretty.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[self resizeViews];
}

- (void)showContactsPicker {
	
	// Show some kind of contacts picker in here.
	// For now, it's a good chance to show how to add tokens.
	[tokenFieldView.tokenField addToken:@"New Name"];
	
	// You can access token titles with 'tokenFieldView.tokenTitles'.
	// Eg, NSLog(@"%@", tokenFieldView.tokenTitles);
}

- (void)keyboardWillShow:(NSNotification *)notification {
	
	CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	
	// Wouldn't it be fantastic if, when in landscape mode, width was actually width and not height?
	keyboardHeight = keyboardRect.size.height > keyboardRect.size.width ? keyboardRect.size.width : keyboardRect.size.height;
	
	[self resizeViews];
}

- (void)keyboardWillHide:(NSNotification *)notification {
	keyboardHeight = 0;
	[self resizeViews];
}

- (void)resizeViews {
	
	CGRect newFrame = tokenFieldView.frame;
	newFrame.size.width = self.view.bounds.size.width;
	newFrame.size.height = self.view.bounds.size.height - keyboardHeight;
	[tokenFieldView setFrame:newFrame];
	[messageView setFrame:tokenFieldView.contentView.bounds];
}

- (void)tokenField:(TITokenField *)tokenField didChangeToFrame:(CGRect)frame {
	[self textViewDidChange:messageView];
}

- (void)textViewDidChange:(UITextView *)textView {
	
	CGFloat fontHeight = (textView.font.ascender - textView.font.descender) + 1;
	CGFloat originHeight = tokenFieldView.frame.size.height - tokenFieldView.tokenField.frame.size.height;
	CGFloat newHeight = textView.contentSize.height + fontHeight;
	
	CGRect newTextFrame = textView.frame;
	newTextFrame.size = textView.contentSize;
	newTextFrame.size.height = newHeight;
	
	CGRect newFrame = tokenFieldView.contentView.frame;
	newFrame.size.height = newHeight;
	
	if (newHeight < originHeight){
		newTextFrame.size.height = originHeight;
		newFrame.size.height = originHeight;
	}
		
	[tokenFieldView.contentView setFrame:newFrame];
	[textView setFrame:newTextFrame];
	[tokenFieldView updateContentSize];
}

@end
