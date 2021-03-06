//
//  SMBLevelEditorCreationViewController.m
//  ShimmurBeams
//
//  Created by Benjamin Maer on 11/16/17.
//  Copyright © 2017 Shimmur. All rights reserved.
//

#import "SMBLevelEditorCreationViewController.h"
#import "SMBGenericLabelTableViewCell.h"
#import "SMBGenericTextFieldTableViewCell.h"
#import "SMBGenericButtonTableViewCell.h"
#import "SMBGameLevelGeneratorViewController.h"
#import "SMBGameLevelGenerator.h"
#import "SMBGameLevel+SMBLevelEditor.h"

#import <ResplendentUtilities/RUConditionalReturn.h>
#import <ResplendentUtilities/NSString+RUMacros.h>
#import <ResplendentUtilities/NSMutableDictionary+RUUtil.h>
#import <ResplendentUtilities/RUClassOrNilUtil.h>

#import <RTSMTableSectionManager/RTSMTableSectionManager.h>

#import <RUTextSize/RUAttributesDictionaryBuilder.h>
#import <RUTextSize/NSAttributedString+RUTextSize.h>
#import <RUTextSize/NSString+RUTextSize.h>
#import <RUTextSize/UITextField+RUAttributesDictionaryBuilder.h>





typedef NS_ENUM(NSInteger, SMBLevelEditorCreationViewController__tableSection) {
	SMBLevelEditorCreationViewController__tableSection_columns_header,
	SMBLevelEditorCreationViewController__tableSection_columns,
	SMBLevelEditorCreationViewController__tableSection_rows_header,
	SMBLevelEditorCreationViewController__tableSection_rows,

	SMBLevelEditorCreationViewController__tableSection_next,

	SMBLevelEditorCreationViewController__tableSection__first	= SMBLevelEditorCreationViewController__tableSection_columns_header,
	SMBLevelEditorCreationViewController__tableSection__last	= SMBLevelEditorCreationViewController__tableSection_next,
};





@interface SMBLevelEditorCreationViewController () <UITableViewDataSource, UITableViewDelegate, RTSMTableSectionManager_SectionDelegate, SMBGenericButtonTableViewCell_genericButtonDelegate, SMBGenericTextFieldTableViewCell_textChangeDelegate>

#pragma mark - tableSectionManager
@property (nonatomic, readonly, strong, nonnull) RTSMTableSectionManager* tableSectionManager;

#pragma mark - Dirty Values
@property (nonatomic, readonly) NSMutableDictionary<NSNumber*,id>* __nonnull dirtyValues;
-(BOOL)validateDirtyValue:(id)dirtyValue for_tableSection:(SMBLevelEditorCreationViewController__tableSection)tableSection;
-(void)setDirtyValue:(nullable id)dirtyValue for_tableSection:(SMBLevelEditorCreationViewController__tableSection)tableSection;
-(nullable id)getDirtyValue_for_tableSection:(SMBLevelEditorCreationViewController__tableSection)tableSection;
-(void)updateForDirtyValueChange_for_tableSection:(SMBLevelEditorCreationViewController__tableSection)tableSection;

#pragma mark - tableView
@property (nonatomic, readonly, strong, nullable) UITableView* tableView;
-(CGRect)tableView_frame;

#pragma mark - tableViewCell_GenericLabel
-(nonnull SMBGenericLabelTableViewCell*)tableViewCell_GenericLabel_with_attributedText:(nonnull NSAttributedString*)attributedText
																			textInsets:(UIEdgeInsets)textInsets;

#pragma mark - genericTextFieldTableViewCell
-(nonnull SMBGenericTextFieldTableViewCell*)genericTextFieldTableViewCell_with_text:(nullable NSString*)text
											  textField_attributesDictionaryBuilder:(nonnull RUAttributesDictionaryBuilder*)textField_attributesDictionaryBuilder
														  placeholderAttributedText:(nullable NSAttributedString*)placeholderAttributedText
																		 textInsets:(UIEdgeInsets)textInsets;

#pragma mark - genericButtonTableViewCell
-(nullable SMBGenericButtonTableViewCell*)genericButtonTableViewCell_with_attributedText:(nonnull NSAttributedString*)attributedText
																			  textInsets:(UIEdgeInsets)textInsets;

#pragma mark - tableViewCell
-(nullable NSAttributedString*)tableViewCell_attributedText_for_tableSection:(SMBLevelEditorCreationViewController__tableSection)tableSection;
-(nullable NSString*)tableViewCell_text_for_tableSection:(SMBLevelEditorCreationViewController__tableSection)tableSection;
-(nullable RUAttributesDictionaryBuilder*)tableViewCell_text_attributesDictionaryBuilder_for_tableSection:(SMBLevelEditorCreationViewController__tableSection)tableSection;
-(nullable UIFont*)tableViewCell_text_font_for_tableSection:(SMBLevelEditorCreationViewController__tableSection)tableSection;
-(nullable UIColor*)tableViewCell_text_color_for_tableSection:(SMBLevelEditorCreationViewController__tableSection)tableSection;

-(nullable NSAttributedString*)tableViewCell_placeholder_attributedText_for_tableSection:(SMBLevelEditorCreationViewController__tableSection)tableSection;
-(nullable NSString*)tableViewCell_placeholder_text_for_tableSection:(SMBLevelEditorCreationViewController__tableSection)tableSection;
-(nullable RUAttributesDictionaryBuilder*)tableViewCell_placeholder_text_attributesDictionaryBuilder_for_tableSection:(SMBLevelEditorCreationViewController__tableSection)tableSection;

-(UIEdgeInsets)tableViewCell_insets_for_tableSection:(SMBLevelEditorCreationViewController__tableSection)tableSection;

#pragma mark - nextButton
-(nullable NSString*)nextButton_errorMessage;

#pragma mark - gameLevelGeneratorViewController
-(void)gameLevelGeneratorViewController_push_attempt;

@end





@implementation SMBLevelEditorCreationViewController

#pragma mark - UIViewController
-(void)viewDidLoad
{
	[super viewDidLoad];

	[self.view setBackgroundColor:[UIColor whiteColor]];

	_tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
	[self.tableView setBackgroundColor:[UIColor clearColor]];
	[self.tableView setDataSource:self];
	[self.tableView setDelegate:self];
	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	[self.view addSubview:self.tableView];
}

-(void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];

	[self.tableView setFrame:[self tableView_frame]];
}

#pragma mark - tableSectionRangeManager
@synthesize tableSectionManager = _tableSectionManager;
-(nonnull RTSMTableSectionManager*)tableSectionManager
{
	if (_tableSectionManager == nil)
	{
		_tableSectionManager =
		[[RTSMTableSectionManager alloc] initWithFirstSection:SMBLevelEditorCreationViewController__tableSection__first
												  lastSection:SMBLevelEditorCreationViewController__tableSection__last];
		[_tableSectionManager setSectionDelegate:self];
	}

	return _tableSectionManager;
}

#pragma mark - RTSMTableSectionManager_SectionDelegate
-(BOOL)tableSectionManager:(nonnull RTSMTableSectionManager*)tableSectionManager sectionIsAvailable:(NSInteger)section
{
	return YES;
}

#pragma mark - Dirty Values
@synthesize dirtyValues = _dirtyValues;
-(NSMutableDictionary<NSNumber *,id> *)dirtyValues
{
	if (_dirtyValues == nil)
	{
		_dirtyValues = [NSMutableDictionary dictionary];
	}
	
	return _dirtyValues;
}

-(void)setDirtyValue:(nullable id)dirtyValue for_tableSection:(SMBLevelEditorCreationViewController__tableSection)tableSection
{
	kRUConditionalReturn([self validateDirtyValue:dirtyValue for_tableSection:tableSection] == false, YES);
	
	[self.dirtyValues setObjectOrRemoveIfNil:dirtyValue forKey:@(tableSection)];
	
	[self updateForDirtyValueChange_for_tableSection:tableSection];
}

-(BOOL)validateDirtyValue:(id)dirtyValue for_tableSection:(SMBLevelEditorCreationViewController__tableSection)tableSection
{
	if (dirtyValue)
	{
		switch (tableSection)
		{
			case SMBLevelEditorCreationViewController__tableSection_columns_header:
			case SMBLevelEditorCreationViewController__tableSection_rows_header:
			case SMBLevelEditorCreationViewController__tableSection_next:
				NSAssert(false, @"unhandled tableSection %li",(long)tableSection);
				break;
				
			case SMBLevelEditorCreationViewController__tableSection_columns:
			case SMBLevelEditorCreationViewController__tableSection_rows:
				return (kRUStringOrNil(dirtyValue) != nil);
				break;
		}
	}

	return YES;
}

-(nullable id)getDirtyValue_for_tableSection:(SMBLevelEditorCreationViewController__tableSection)tableSection
{
	id dirtyValue = [self.dirtyValues objectForKey:@(tableSection)];
	
	kRUConditionalReturn_ReturnValueNil([self validateDirtyValue:dirtyValue for_tableSection:tableSection] == false, YES);
	
	return dirtyValue;
}

-(void)updateForDirtyValueChange_for_tableSection:(SMBLevelEditorCreationViewController__tableSection)tableSection
{
	[self.view setNeedsLayout];
	
	switch (tableSection)
	{
		case SMBLevelEditorCreationViewController__tableSection_columns:
		case SMBLevelEditorCreationViewController__tableSection_rows:
		{
			NSInteger const indexPathSection = [self.tableSectionManager indexPathSectionForSection:SMBLevelEditorCreationViewController__tableSection_next];
			kRUConditionalReturn(indexPathSection == NSNotFound, YES);

			[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPathSection] withRowAnimation:UITableViewRowAnimationNone];
		}
			break;
			
		default:
			break;
	}
}

#pragma mark - tableView
-(CGRect)tableView_frame
{
	return self.view.bounds;
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(nonnull UITableView*)tableView
{
	return [self.tableSectionManager numberOfSectionsAvailable];
}

-(NSInteger)tableView:(nonnull UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

-(nonnull UITableViewCell*)tableView:(nonnull UITableView*)tableView cellForRowAtIndexPath:(nonnull NSIndexPath*)indexPath
{
	SMBLevelEditorCreationViewController__tableSection const tableSection = [self.tableSectionManager sectionForIndexPathSection:indexPath.section];
	switch (tableSection)
	{
		case SMBLevelEditorCreationViewController__tableSection_columns_header:
		case SMBLevelEditorCreationViewController__tableSection_rows_header:
			return
			[self tableViewCell_GenericLabel_with_attributedText:[self tableViewCell_attributedText_for_tableSection:tableSection]
													  textInsets:[self tableViewCell_insets_for_tableSection:tableSection]];
			break;

		case SMBLevelEditorCreationViewController__tableSection_columns:
		case SMBLevelEditorCreationViewController__tableSection_rows:
			return [self genericTextFieldTableViewCell_with_text:[self tableViewCell_text_for_tableSection:tableSection]
						   textField_attributesDictionaryBuilder:[self tableViewCell_text_attributesDictionaryBuilder_for_tableSection:tableSection]
									   placeholderAttributedText:[self tableViewCell_placeholder_attributedText_for_tableSection:tableSection]
													  textInsets:[self tableViewCell_insets_for_tableSection:tableSection]];
			break;

		case SMBLevelEditorCreationViewController__tableSection_next:
			return [self genericButtonTableViewCell_with_attributedText:[self tableViewCell_attributedText_for_tableSection:tableSection]
															 textInsets:[self tableViewCell_insets_for_tableSection:tableSection]];
			break;
	}

	NSAssert(false, @"unhandled tableSection %li",(long)tableSection);
	return [UITableViewCell new];
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(nonnull UITableView*)tableView heightForRowAtIndexPath:(nonnull NSIndexPath*)indexPath
{
	SMBLevelEditorCreationViewController__tableSection const tableSection = [self.tableSectionManager sectionForIndexPathSection:indexPath.section];
	switch (tableSection)
	{
		case SMBLevelEditorCreationViewController__tableSection_columns_header:
		case SMBLevelEditorCreationViewController__tableSection_rows_header:
		{
			NSAttributedString* const attributedText = [self tableViewCell_attributedText_for_tableSection:tableSection];
			kRUConditionalReturn_ReturnValue(attributedText == nil, YES, 0.0f);

			return ceil([attributedText ru_textSizeWithBoundingWidth:CGFLOAT_MAX].height);
		}
			break;

		case SMBLevelEditorCreationViewController__tableSection_columns:
		case SMBLevelEditorCreationViewController__tableSection_rows:
		{
			NSMutableDictionary<NSString*, RUAttributesDictionaryBuilder*>* const text_to_attributesDictionaryBuilder =
			[NSMutableDictionary<NSString*, RUAttributesDictionaryBuilder*> dictionary];

			[text_to_attributesDictionaryBuilder setObjectOrRemoveIfNil:[self tableViewCell_text_attributesDictionaryBuilder_for_tableSection:tableSection]
																 forKey:([self tableViewCell_text_for_tableSection:tableSection] ?: @"")];

			NSString* const placeholderText = [self tableViewCell_placeholder_text_for_tableSection:tableSection];
			NSAssert(placeholderText != nil, @"shouldn't be");
			if (placeholderText)
			{
				[text_to_attributesDictionaryBuilder setObjectOrRemoveIfNil:[self tableViewCell_placeholder_text_attributesDictionaryBuilder_for_tableSection:tableSection]
																	 forKey:placeholderText];
			}

			kRUConditionalReturn_ReturnValue(text_to_attributesDictionaryBuilder.count == 0, YES, 0.0f);

			__block CGFloat height_max = 0.0f;
			[text_to_attributesDictionaryBuilder enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull text, RUAttributesDictionaryBuilder * _Nonnull attributesDictionaryBuilder, BOOL * _Nonnull stop) {
				CGFloat const textHeight = [text ruTextSizeWithBoundingWidth:CGFLOAT_MAX
																  attributes:[attributesDictionaryBuilder attributesDictionary_generate]].height;
				if (textHeight > height_max)
				{
					height_max = textHeight;
				}
			}];

			return ceil(height_max);
		}
			break;

		case SMBLevelEditorCreationViewController__tableSection_next:
			return 30.0f;
			break;
	}

	NSAssert(false, @"unhandled tableSection %li",(long)tableSection);
	return 0.0f;
}

-(CGFloat)tableView:(nonnull UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
	SMBLevelEditorCreationViewController__tableSection const tableSection = [self.tableSectionManager sectionForIndexPathSection:section];
	switch (tableSection)
	{
		case SMBLevelEditorCreationViewController__tableSection_columns_header:
		case SMBLevelEditorCreationViewController__tableSection_rows_header:
			return 10.0f;
			break;

		case SMBLevelEditorCreationViewController__tableSection_columns:
		case SMBLevelEditorCreationViewController__tableSection_rows:
			return 0.0f;
			break;

		case SMBLevelEditorCreationViewController__tableSection_next:
			return 20.0f;
			break;
	}

	NSAssert(false, @"unhandled tableSection %li",(long)tableSection);
	return 0.0f;
}

-(nullable UIView*)tableView:(nonnull UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView* const view = [UIView new];
	[view setBackgroundColor:[UIColor clearColor]];
	return view;
}

-(void)tableView:(nonnull UITableView*)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath*)indexPath
{
	SMBLevelEditorCreationViewController__tableSection const tableSection = [self.tableSectionManager sectionForIndexPathSection:indexPath.section];
	switch (tableSection)
	{
		case SMBLevelEditorCreationViewController__tableSection_columns_header:
		case SMBLevelEditorCreationViewController__tableSection_columns:
		case SMBLevelEditorCreationViewController__tableSection_rows_header:
		case SMBLevelEditorCreationViewController__tableSection_rows:
			break;

		case SMBLevelEditorCreationViewController__tableSection_next:
			[self gameLevelGeneratorViewController_push_attempt];
			break;
	}
}

#pragma mark - tableViewCell_GenericLabel
-(nonnull SMBGenericLabelTableViewCell*)tableViewCell_GenericLabel_with_attributedText:(nonnull NSAttributedString*)attributedText
																			textInsets:(UIEdgeInsets)textInsets
{
	kRUDefineNSStringConstant(cellDequeIdentifier__SMBGenericLabelTableViewCell);
	SMBGenericLabelTableViewCell* const tableViewCell_GenericLabel =
	(
	 [self.tableView dequeueReusableCellWithIdentifier:cellDequeIdentifier__SMBGenericLabelTableViewCell]
	 ?:
	 [[SMBGenericLabelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										 reuseIdentifier:cellDequeIdentifier__SMBGenericLabelTableViewCell]
	 );

	[tableViewCell_GenericLabel setSelectionStyle:UITableViewCellSelectionStyleNone];
	[tableViewCell_GenericLabel setBackgroundColor:[UIColor clearColor]];
	[tableViewCell_GenericLabel.contentView setBackgroundColor:[UIColor clearColor]];

	[tableViewCell_GenericLabel.genericLabel setAttributedText:attributedText];
	[tableViewCell_GenericLabel.genericLabel setBackgroundColor:[UIColor clearColor]];
	[tableViewCell_GenericLabel setGenericLabel_frame_insets:textInsets];

	return tableViewCell_GenericLabel;
}

#pragma mark - genericTextFieldTableViewCell
-(nonnull SMBGenericTextFieldTableViewCell*)genericTextFieldTableViewCell_with_text:(nullable NSString*)text
											  textField_attributesDictionaryBuilder:(nonnull RUAttributesDictionaryBuilder*)textField_attributesDictionaryBuilder
														  placeholderAttributedText:(nullable NSAttributedString*)placeholderAttributedText
																		 textInsets:(UIEdgeInsets)textInsets
{
	kRUDefineNSStringConstant(cellDequeIdentifier__SMBGenericTextFieldTableViewCell);
	SMBGenericTextFieldTableViewCell* const genericTextFieldTableViewCell =
	(
	 [self.tableView dequeueReusableCellWithIdentifier:cellDequeIdentifier__SMBGenericTextFieldTableViewCell]
	 ?:
	 [[SMBGenericTextFieldTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
											 reuseIdentifier:cellDequeIdentifier__SMBGenericTextFieldTableViewCell]
	 );

	[genericTextFieldTableViewCell setSelectionStyle:UITableViewCellSelectionStyleNone];
	[genericTextFieldTableViewCell setBackgroundColor:[UIColor clearColor]];
	[genericTextFieldTableViewCell.contentView setBackgroundColor:[UIColor clearColor]];

	[genericTextFieldTableViewCell.textField ru_absorb_attributesDictionaryBuilder:textField_attributesDictionaryBuilder];

	[genericTextFieldTableViewCell.textField setAttributedPlaceholder:placeholderAttributedText];
	[genericTextFieldTableViewCell.textField setBackgroundColor:[UIColor clearColor]];
	[genericTextFieldTableViewCell.textField setKeyboardType:UIKeyboardTypeNumberPad];
	[genericTextFieldTableViewCell setTextFieldFrameInsets:textInsets];

	[genericTextFieldTableViewCell setTextChangeDelegate:self];

	return genericTextFieldTableViewCell;
}

#pragma mark - genericButtonTableViewCell
-(nullable SMBGenericButtonTableViewCell*)genericButtonTableViewCell_with_attributedText:(nonnull NSAttributedString*)attributedText
																			  textInsets:(UIEdgeInsets)textInsets
{
	kRUDefineNSStringConstant(cellIdentifier_SMBGenericButtonTableViewCell);
	SMBGenericButtonTableViewCell* const genericButtonTableViewCell =
	([self.tableView dequeueReusableCellWithIdentifier:cellIdentifier_SMBGenericButtonTableViewCell]
	 ?:
	 [[SMBGenericButtonTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier_SMBGenericButtonTableViewCell]
	 );
	
	[genericButtonTableViewCell setSelectionStyle:UITableViewCellSelectionStyleNone];
	[genericButtonTableViewCell setBackgroundColor:[UIColor clearColor]];
	[genericButtonTableViewCell.contentView setBackgroundColor:[UIColor clearColor]];
	
	[genericButtonTableViewCell setFullBoundsCustomView_edgeInsets:textInsets];
	
	[genericButtonTableViewCell setGenericButtonDelegate:self];
	[genericButtonTableViewCell.genericButton setBackgroundColor:[UIColor clearColor]];
	[genericButtonTableViewCell.genericButton setAttributedTitle:attributedText forState:UIControlStateNormal];
	[genericButtonTableViewCell.genericButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
	[genericButtonTableViewCell.genericButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
	
	return genericButtonTableViewCell;
}

#pragma mark - tableViewCell
-(nullable NSAttributedString*)tableViewCell_attributedText_for_tableSection:(SMBLevelEditorCreationViewController__tableSection)tableSection
{
	NSString* const tableViewCell_text = [self tableViewCell_text_for_tableSection:tableSection];
	kRUConditionalReturn_ReturnValueNil(tableViewCell_text == nil, YES);

	RUAttributesDictionaryBuilder* const tableViewCell_text_attributesDictionaryBuilder = [self tableViewCell_text_attributesDictionaryBuilder_for_tableSection:tableSection];
	kRUConditionalReturn_ReturnValueNil(tableViewCell_text_attributesDictionaryBuilder == nil, YES);

	NSDictionary<NSString*,id>* const attributesDictionary = [tableViewCell_text_attributesDictionaryBuilder attributesDictionary_generate];
	kRUConditionalReturn_ReturnValueNil(attributesDictionary == nil, YES);

	return
	[[NSAttributedString alloc] initWithString:tableViewCell_text
									attributes:attributesDictionary];
}

-(nullable NSString*)tableViewCell_text_for_tableSection:(SMBLevelEditorCreationViewController__tableSection)tableSection
{
	switch (tableSection)
	{
		case SMBLevelEditorCreationViewController__tableSection_columns_header:
			return @"Columns";
			break;

		case SMBLevelEditorCreationViewController__tableSection_columns:
		case SMBLevelEditorCreationViewController__tableSection_rows:
		{
			id const dirtyValue = [self getDirtyValue_for_tableSection:tableSection];
			kRUConditionalReturn_ReturnValueNil(dirtyValue == nil, NO);

			NSString* const dirtyValue_string = kRUStringOrNil(dirtyValue);
			kRUConditionalReturn_ReturnValueNil(dirtyValue_string == nil, YES);
			kRUConditionalReturn_ReturnValueNil(dirtyValue_string.length == 0, NO);

			return dirtyValue_string;
		}
			break;

		case SMBLevelEditorCreationViewController__tableSection_rows_header:
			return @"Rows";
			break;

		case SMBLevelEditorCreationViewController__tableSection_next:
			return @"Next";
			break;
	}

	NSAssert(false, @"unhandled tableSection %li",(long)tableSection);
	return nil;
}

-(nullable RUAttributesDictionaryBuilder*)tableViewCell_text_attributesDictionaryBuilder_for_tableSection:(SMBLevelEditorCreationViewController__tableSection)tableSection
{
	RUAttributesDictionaryBuilder* const attributesDictionaryBuilder = [RUAttributesDictionaryBuilder new];

	[attributesDictionaryBuilder setFont:[self tableViewCell_text_font_for_tableSection:tableSection]];
	[attributesDictionaryBuilder setTextColor:[self tableViewCell_text_color_for_tableSection:tableSection]];
	[attributesDictionaryBuilder setTextAlignment:NSTextAlignmentCenter];

	return attributesDictionaryBuilder;
}

-(nullable UIFont*)tableViewCell_text_font_for_tableSection:(SMBLevelEditorCreationViewController__tableSection)tableSection
{
	switch (tableSection)
	{
		case SMBLevelEditorCreationViewController__tableSection_columns_header:
		case SMBLevelEditorCreationViewController__tableSection_columns:
		case SMBLevelEditorCreationViewController__tableSection_rows_header:
		case SMBLevelEditorCreationViewController__tableSection_rows:
			return [UIFont systemFontOfSize:12.0f];
			break;

		case SMBLevelEditorCreationViewController__tableSection_next:
			return [UIFont systemFontOfSize:24.0f];
			break;
	}

	NSAssert(false, @"unhandled tableSection %li",(long)tableSection);
	return nil;
}

-(nullable UIColor*)tableViewCell_text_color_for_tableSection:(SMBLevelEditorCreationViewController__tableSection)tableSection
{
	switch (tableSection)
	{
		case SMBLevelEditorCreationViewController__tableSection_columns_header:
		case SMBLevelEditorCreationViewController__tableSection_columns:
		case SMBLevelEditorCreationViewController__tableSection_rows_header:
		case SMBLevelEditorCreationViewController__tableSection_rows:
		case SMBLevelEditorCreationViewController__tableSection_next:
			return [UIColor darkTextColor];
			break;
	}

	NSAssert(false, @"unhandled tableSection %li",(long)tableSection);
	return nil;
}

-(nullable NSAttributedString*)tableViewCell_placeholder_attributedText_for_tableSection:(SMBLevelEditorCreationViewController__tableSection)tableSection
{
	NSString* const tableViewCell_placeholder_text = [self tableViewCell_placeholder_text_for_tableSection:tableSection];
	kRUConditionalReturn_ReturnValueNil(tableViewCell_placeholder_text == nil, YES);

	RUAttributesDictionaryBuilder* const tableViewCell_placeholder_text_attributesDictionaryBuilder = [self tableViewCell_placeholder_text_attributesDictionaryBuilder_for_tableSection:tableSection];
	kRUConditionalReturn_ReturnValueNil(tableViewCell_placeholder_text_attributesDictionaryBuilder == nil, YES);

	NSDictionary<NSString*,id>* const attributesDictionary = [tableViewCell_placeholder_text_attributesDictionaryBuilder attributesDictionary_generate];
	kRUConditionalReturn_ReturnValueNil(attributesDictionary == nil, YES);

	return
	[[NSAttributedString alloc] initWithString:tableViewCell_placeholder_text
									attributes:attributesDictionary];
}

-(nullable NSString*)tableViewCell_placeholder_text_for_tableSection:(SMBLevelEditorCreationViewController__tableSection)tableSection
{
	switch (tableSection)
	{
		case SMBLevelEditorCreationViewController__tableSection_columns_header:
		case SMBLevelEditorCreationViewController__tableSection_rows_header:
		case SMBLevelEditorCreationViewController__tableSection_next:
			break;

		case SMBLevelEditorCreationViewController__tableSection_columns:
		case SMBLevelEditorCreationViewController__tableSection_rows:
			return @"Enter an integer.";
			break;
	}

	NSAssert(false, @"unhandled tableSection %li",(long)tableSection);
	return nil;
}

-(nullable RUAttributesDictionaryBuilder*)tableViewCell_placeholder_text_attributesDictionaryBuilder_for_tableSection:(SMBLevelEditorCreationViewController__tableSection)tableSection
{
	RUAttributesDictionaryBuilder* const attributesDictionaryBuilder = [RUAttributesDictionaryBuilder new];

	[attributesDictionaryBuilder setFont:[UIFont systemFontOfSize:12.0f weight:UIFontWeightLight]];
	[attributesDictionaryBuilder setTextColor:[self tableViewCell_text_color_for_tableSection:tableSection]];
	[attributesDictionaryBuilder setTextAlignment:NSTextAlignmentLeft];

	return attributesDictionaryBuilder;
}

-(UIEdgeInsets)tableViewCell_insets_for_tableSection:(SMBLevelEditorCreationViewController__tableSection)tableSection
{
	CGFloat const padding_horizontal = 12.0f;
	return (UIEdgeInsets){
		.left	= padding_horizontal,
		.right	= padding_horizontal,
	};
}

#pragma mark - SMBGenericButtonTableViewCell_genericButtonDelegate
-(void)genericButtonTableViewCell_didTouchUpInsideButton:(nonnull SMBGenericButtonTableViewCell*)genericButtonTableViewCell
{
	kRUConditionalReturn(genericButtonTableViewCell == nil, YES);
	
	NSIndexPath* const indexPath = [self.tableView indexPathForCell:genericButtonTableViewCell];
	kRUConditionalReturn(indexPath == nil, YES);
	
	SMBLevelEditorCreationViewController__tableSection const tableSection = [self.tableSectionManager sectionForIndexPathSection:indexPath.section];
	switch (tableSection)
	{
		case SMBLevelEditorCreationViewController__tableSection_next:
			[self gameLevelGeneratorViewController_push_attempt];
			break;

		default:
			NSAssert(false, @"unhandled tableSection %li",(long)tableSection);
			break;
	}
}

#pragma mark - nextButton
-(nullable NSString*)nextButton_errorMessage
{
	id const columns = [self getDirtyValue_for_tableSection:SMBLevelEditorCreationViewController__tableSection_columns];
	kRUConditionalReturn_ReturnValue(columns == nil, NO, @"You must enter an amount of columns.")

	NSString* const columns_string = kRUStringOrNil(columns);
	kRUConditionalReturn_ReturnValue(columns_string == nil, YES, @"Something is wrong with your columns input");

	NSNumber* const columns_number = @(columns_string.integerValue);
	kRUConditionalReturn_ReturnValue(columns_number.integerValue < 1, NO, @"You must enter at least one column.")

	id const rows = [self getDirtyValue_for_tableSection:SMBLevelEditorCreationViewController__tableSection_rows];
	kRUConditionalReturn_ReturnValue(rows == nil, NO, @"You must enter an amount of rows.")
	
	NSString* const rows_string = kRUStringOrNil(rows);
	kRUConditionalReturn_ReturnValue(rows_string == nil, YES, @"Something is wrong with your rows input");
	
	NSNumber* const rows_number = @(rows_string.integerValue);
	kRUConditionalReturn_ReturnValue(rows_number.integerValue < 1, NO, @"You must enter at least one row.")

	return nil;
}

#pragma mark - gameLevelGeneratorViewController
-(void)gameLevelGeneratorViewController_push_attempt
{
	NSString* const nextButton_errorMessage = [self nextButton_errorMessage];
	if (nextButton_errorMessage != nil)
	{
		UIAlertController* const alertController =
		[UIAlertController alertControllerWithTitle:@"Oops!"
											message:nextButton_errorMessage
									 preferredStyle:UIAlertControllerStyleAlert];

		[alertController addAction:
		 [UIAlertAction actionWithTitle:@"Okay"
								  style:UIAlertActionStyleCancel
								handler:nil]];

		[self presentViewController:alertController animated:YES completion:nil];

		return;
	}

	id const columns = [self getDirtyValue_for_tableSection:SMBLevelEditorCreationViewController__tableSection_columns];
	kRUConditionalReturn(columns == nil, YES);

	NSString* const columns_string = kRUStringOrNil(columns);
	kRUConditionalReturn(columns_string == nil, YES);

	NSNumber* const columns_number = @(columns_string.integerValue);
	kRUConditionalReturn(columns_number == nil, YES);

	id const rows = [self getDirtyValue_for_tableSection:SMBLevelEditorCreationViewController__tableSection_rows];
	kRUConditionalReturn(rows == nil, YES);

	NSString* const rows_string = kRUStringOrNil(rows);
	kRUConditionalReturn(rows_string == nil, YES);

	NSNumber* const rows_number = @(rows_string.integerValue);
	kRUConditionalReturn(rows_number == nil, YES);

	SMBGameLevelGeneratorViewController* const gameLevelGeneratorViewController = [SMBGameLevelGeneratorViewController new];
	[gameLevelGeneratorViewController setGameLevelGenerator:
	 [[SMBGameLevelGenerator alloc] init_with_generateLevelBlock:^SMBGameLevel * _Nonnull{
		return [SMBGameLevel smb_levelEditor_with_numberOfColumns:columns_number.integerValue
													 numberOfRows:rows_number.integerValue];
	}
															name:@"Level Editor"]];

	[self.navigationController pushViewController:gameLevelGeneratorViewController animated:YES];
}

#pragma mark - SMBGenericTextFieldTableViewCell_textChangeDelegate
-(void)genericTextFieldTableViewCell:(nonnull SMBGenericTextFieldTableViewCell*)genericTextFieldTableViewCell
					   textDidChange:(nonnull NSString*)text
{
	kRUConditionalReturn(genericTextFieldTableViewCell == nil, YES);
	
	NSIndexPath* const indexPath = [self.tableView indexPathForRowAtPoint:genericTextFieldTableViewCell.center];
	kRUConditionalReturn(indexPath == nil, YES);
	
	[self setDirtyValue:text
	   for_tableSection:[self.tableSectionManager sectionForIndexPathSection:indexPath.section]];
}

@end
