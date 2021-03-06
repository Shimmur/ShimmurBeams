//
//  SMBDoorTileEntity.m
//  ShimmurBeams
//
//  Created by Benjamin Maer on 8/28/17.
//  Copyright © 2017 Shimmur. All rights reserved.
//

#import "SMBDoorTileEntity.h"
#import "SMBGameBoardTile.h"

#import <ResplendentUtilities/RUConditionalReturn.h>





static void* kSMBDoorTileEntity__KVOContext = &kSMBDoorTileEntity__KVOContext;





@interface SMBDoorTileEntity ()

#pragma mark - doorIsOpen
@property (nonatomic, assign) BOOL doorIsOpen;
-(void)doorIsOpen_update;
-(BOOL)doorIsOpen_appropriate;

#pragma mark - gameBoardTile
-(void)SMBDoorTileEntity_gameBoardTile_setKVORegistered:(BOOL)registered;

#pragma mark - beamEnterDirections_blocked
-(void)beamEnterDirections_blocked_update;
-(SMBGameBoardTile__direction)beamEnterDirections_blocked_appropriate;

@end





@implementation SMBDoorTileEntity

#pragma mark - NSObject
-(void)dealloc
{
	[self SMBDoorTileEntity_gameBoardTile_setKVORegistered:NO];
}

-(instancetype)init
{
	if (self = [super init])
	{
		[self doorIsOpen_update];
		[self beamEnterDirections_blocked_update];
	}

	return self;
}

#pragma mark - SMBGameBoardGeneralEntity: draw
-(void)draw_in_rect:(CGRect)rect
{
	[super draw_in_rect:rect];

	CGFloat const padding_fromEdge_horizontal = CGRectGetWidth(rect) / 5.0f;
	CGFloat const padding_fromTop = CGRectGetWidth(rect) / 4.0f;

	CGContextRef const context = UIGraphicsGetCurrentContext();

	CGContextSaveGState(context);

	CGContextSetFillColorWithColor(context, [UIColor darkGrayColor].CGColor);

	if (self.doorIsOpen)
	{
		CGFloat const padding_from_spine_ratio = 10.0f;
		CGFloat const padding_horizontal_from_spine = CGRectGetWidth(rect) / padding_from_spine_ratio;
		CGFloat const padding_vertical_from_spine = CGRectGetHeight(rect) / padding_from_spine_ratio;

		CGFloat const inset_top = (CGRectGetHeight(rect) / 2.0f) + padding_vertical_from_spine;
		CGFloat const inset_horizontal_from_furtherSide = (CGRectGetHeight(rect) / 2.0f) + padding_horizontal_from_spine;
		CGContextFillRect(context,
						  UIEdgeInsetsInsetRect(rect,
												(UIEdgeInsets){
													.left	= padding_fromEdge_horizontal,
													.right	= inset_horizontal_from_furtherSide,
													.top	= inset_top,
												}));

		CGContextFillRect(context,
						  UIEdgeInsetsInsetRect(rect,
												(UIEdgeInsets){
													.left	= inset_horizontal_from_furtherSide,
													.right	= padding_fromEdge_horizontal,
													.top	= inset_top,
												}));
	}
	else
	{
		CGContextFillRect(context,
						  UIEdgeInsetsInsetRect(rect,
												(UIEdgeInsets){
													.left	= padding_fromEdge_horizontal,
													.right	= padding_fromEdge_horizontal,
													.top	= padding_fromTop,
												}));
	}

	CGContextRestoreGState(context);
}

#pragma mark - SMBBeamBlockerTileEntity
@synthesize beamEnterDirections_blocked = _beamEnterDirections_blocked;

#pragma mark - beamEnterDirections_blocked
-(void)beamEnterDirections_blocked_update
{
	[self setBeamEnterDirections_blocked:[self beamEnterDirections_blocked_appropriate]];
}

-(SMBGameBoardTile__direction)beamEnterDirections_blocked_appropriate
{
	SMBGameBoardTile__direction const beamEnterDirections_blocked_default = SMBGameBoardTile__directions_all();
	SMBGameBoardTile* const gameBoardTile = self.gameBoardTile;
	kRUConditionalReturn_ReturnValue(gameBoardTile == nil, NO, beamEnterDirections_blocked_default);
	kRUConditionalReturn_ReturnValue(gameBoardTile.isPowered_notByBeam == false, NO, beamEnterDirections_blocked_default);

	return SMBGameBoardTile__direction_none;
}

#pragma mark - SMBGameBoardTileEntity: gameBoardTile
-(void)setGameBoardTile:(nullable SMBGameBoardTile*)gameBoardTile
{
	[self SMBDoorTileEntity_gameBoardTile_setKVORegistered:NO];
	
	[super setGameBoardTile:gameBoardTile];
	
	[self SMBDoorTileEntity_gameBoardTile_setKVORegistered:YES];
}

#pragma mark - doorIsOpen
-(void)setDoorIsOpen:(BOOL)doorIsOpen
{
	kRUConditionalReturn(self.doorIsOpen == doorIsOpen, NO);

	_doorIsOpen = doorIsOpen;

	[self beamEnterDirections_blocked_update];
	[self setNeedsRedraw];
}

-(void)doorIsOpen_update
{
	[self setDoorIsOpen:[self doorIsOpen_appropriate]];
}

-(BOOL)doorIsOpen_appropriate
{
	BOOL const doorIsOpen_default = NO;

	SMBGameBoardTile* const gameBoardTile = self.gameBoardTile;
	kRUConditionalReturn_ReturnValue(gameBoardTile == nil, NO, doorIsOpen_default);
	kRUConditionalReturn_ReturnValue(gameBoardTile.isPowered_notByBeam == false, NO, doorIsOpen_default);

	return YES;
}

#pragma mark - gameBoardTile
-(void)SMBDoorTileEntity_gameBoardTile_setKVORegistered:(BOOL)registered
{
	typeof(self.gameBoardTile) const gameBoardTile = self.gameBoardTile;
	kRUConditionalReturn(gameBoardTile == nil, NO);
	
	NSMutableArray<NSString*>* const propertiesToObserve = [NSMutableArray<NSString*> array];
	[propertiesToObserve addObject:[SMBGameBoardTile_PropertiesForKVO isPowered_notByBeam]];
	
	[propertiesToObserve enumerateObjectsUsingBlock:^(NSString * _Nonnull propertyToObserve, NSUInteger idx, BOOL * _Nonnull stop) {
		if (registered)
		{
			[gameBoardTile addObserver:self
							forKeyPath:propertyToObserve
							   options:(NSKeyValueObservingOptionInitial)
							   context:&kSMBDoorTileEntity__KVOContext];
		}
		else
		{
			[gameBoardTile removeObserver:self
							   forKeyPath:propertyToObserve
								  context:&kSMBDoorTileEntity__KVOContext];
		}
	}];
}

#pragma mark - KVO
-(void)observeValueForKeyPath:(nullable NSString*)keyPath ofObject:(nullable id)object change:(nullable NSDictionary*)change context:(nullable void*)context
{
	if (context == kSMBDoorTileEntity__KVOContext)
	{
		if (object == self.gameBoardTile)
		{
			if ([keyPath isEqualToString:[SMBGameBoardTile_PropertiesForKVO isPowered_notByBeam]])
			{
				[self doorIsOpen_update];
			}
			else
			{
				NSAssert(false, @"unhandled keyPath %@",keyPath);
			}
		}
		else
		{
			NSAssert(false, @"unhandled object %@",object);
		}
	}
	else
	{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

@end
