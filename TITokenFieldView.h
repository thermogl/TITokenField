//
//  TITokenFieldView.h
//  TITokenFieldView
//
//  Created by Tom Irving on 16/02/2010.
//  Copyright 2010 Tom Irving. All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without modification,
//	are permitted provided that the following conditions are met:
//
//		1. Redistributions of source code must retain the above copyright notice, this list of
//		   conditions and the following disclaimer.
//
//		2. Redistributions in binary form must reproduce the above copyright notice, this list
//         of conditions and the following disclaimer in the documentation and/or other materials
//         provided with the distribution.
//
//	THIS SOFTWARE IS PROVIDED BY TOM IRVING "AS IS" AND ANY EXPRESS OR IMPLIED
//	WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//	FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL TOM IRVING OR
//	CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//	ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <UIKit/UIKit.h>

@class TITokenField, TIToken, TITokenFieldShadow;

//==========================================================
// - Delegate Methods
//==========================================================

@protocol TITokenFieldViewDelegate <UIScrollViewDelegate>
@optional
- (BOOL)tokenFieldShouldReturn:(TITokenField *)tokenField;

- (void)tokenField:(TITokenField *)tokenField didChangeToFrame:(CGRect)frame;
- (void)tokenFieldTextDidChange:(TITokenField *)tokenField;
- (void)tokenField:(TITokenField *)tokenField didFinishSearch:(NSArray *)matches;

- (UITableViewCell *)tokenField:(TITokenField *)tokenField resultsTableView:(UITableView *)tableView cellForObject:(id)object;
- (CGFloat)tokenField:(TITokenField *)tokenField resultsTableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@protocol TITokenDelegate <NSObject>
@optional
- (void)tokenGotFocus:(TIToken *)token;
- (void)tokenLostFocus:(TIToken *)token;
@end

//==========================================================
// - TITokenFieldView
//==========================================================

@interface TITokenFieldView : UIScrollView <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource> {
	
	BOOL showAlreadyTokenized;
	id <TITokenFieldViewDelegate> delegate;
	
	TITokenFieldShadow * textFieldShadow;
	UIView * separator;
	UITableView * resultsTable;
	UIView * contentView;
	
	NSArray * sourceArray;
	NSMutableArray * resultsArray;
	
	NSArray * tokenTitles;
	
	TITokenField * tokenField;
}

@property (nonatomic, assign) BOOL showAlreadyTokenized;
@property (nonatomic, assign) id <TITokenFieldViewDelegate> delegate;

@property (nonatomic, readonly) TITokenFieldShadow * textFieldShadow;
@property (nonatomic, readonly) UIView * separator;
@property (nonatomic, readonly) UITableView * resultsTable;
@property (nonatomic, readonly) UIView * contentView;

@property (nonatomic, copy) NSArray * sourceArray;
@property (nonatomic, readonly, retain) NSArray * tokenTitles;
@property (nonatomic, readonly) TITokenField * tokenField;

- (void)updateContentSize;
@end

//==========================================================
// - TITokenField
//==========================================================

@interface TITokenField : UITextField <TITokenDelegate> {

	NSMutableArray * tokensArray;
	CGPoint cursorLocation;
	int numberOfLines;
	
	UIButton * addButton;
	
	id addButtonTarget;
	SEL addButtonSelector;
}

@property (nonatomic, retain) NSMutableArray * tokensArray;
@property (nonatomic, readonly) int numberOfLines;
@property (nonatomic, retain) UIButton * addButton;
@property (nonatomic, assign) id addButtonTarget;
@property (nonatomic, assign) SEL addButtonSelector;

- (void)addToken:(NSString *)title;
- (void)removeToken:(TIToken *)token;

- (CGFloat)layoutTokens;

- (void)setAddButtonAction:(SEL)action target:(id)sender;
- (void)setPromptText:(NSString *)aText;

@end

//==========================================================
// - TIToken
//==========================================================

@interface TIToken : UIView {
	
	id <TITokenDelegate> delegate;
	BOOL highlighted;
	
	NSString * title;
	NSString * croppedTitle;
}

@property (nonatomic, getter=isHighlighted) BOOL highlighted;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * croppedTitle;
@property (nonatomic, assign) id <TITokenDelegate> delegate;

- (id)initWithTitle:(NSString *)aTitle;

@end
