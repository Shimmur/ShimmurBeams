//
//  SMBBeamCreatorTileEntity.m
//  ShimmurBeams
//
//  Created by Benjamin Maer on 8/4/17.
//  Copyright © 2017 Shimmur. All rights reserved.
//

#define kSMBBeamCreatorTileEntity__beamCreator_drawing_useSVG (kSMBEnvironment__SMBBeamCreatorTileEntity_beamCreator_drawing_useSVG && 0)

#import "SMBBeamCreatorTileEntity.h"
#import "SMBBeamEntity.h"
#import "SMBGameBoardTile.h"
#import "SMBGameBoard.h"
#import "CoreGraphics+SMBRotation.h"
#import "SMBGameBoardTile__directions_to_CoreGraphics_SMBRotation__orientations_utilities.h"
#import "SMBSVGDrawableObject.h"
#import "SMBSVGDrawableObject+SMBSpace.h"
#import "SMBBlockDrawableObject+SMBDefaultBlockDrawings.h"

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

#import <ResplendentUtilities/RUConditionalReturn.h>
#import <ResplendentUtilities/UIView+RUUtility.h>
#import <ResplendentUtilities/NSMutableArray+RUAddObjectIfNotNil.h>
#import <ResplendentUtilities/RUConstants.h>





static void* kSMBBeamCreatorTileEntity__KVOContext = &kSMBBeamCreatorTileEntity__KVOContext;





@interface SMBBeamCreatorTileEntity ()

#pragma mark - gameBoardTile
-(BOOL)SMBBeamCreatorTileEntity_gameBoardTile_requiresKVO;
-(void)SMBBeamCreatorTileEntity_gameBoardTile_setKVORegistered:(BOOL)registered;
-(void)gameBoardTile:(nullable SMBGameBoardTile* const)gameBoardTile
		  beamEntity:(nullable SMBBeamEntity* const)beamEntity
gameBoard_gameBoardEntity_update:(BOOL)add;

#pragma mark - beamEntity
@property (nonatomic, strong, nullable) SMBBeamEntity* beamEntity;
-(void)beamEntity_update;
-(nullable SMBBeamEntity*)beamEntity_create;

#pragma mark - powerIndicator
-(nullable CGColorRef)powerIndicator_colorRef_appropriate;

#pragma mark - ship_drawableObject
@property (nonatomic, readonly, strong, nullable) SMBDrawableObject* ship_drawableObject;

@end





@implementation SMBBeamCreatorTileEntity

#pragma mark - NSObject
-(void)dealloc
{
	[self SMBBeamCreatorTileEntity_gameBoardTile_setKVORegistered:NO];
}

-(instancetype)init
{
	if (self = [super init])
	{
#if !(kSMBBeamCreatorTileEntity__beamCreator_drawing_useSVG)
		__weak typeof(self) const self_weak = self;
#endif

		_ship_drawableObject =
#if kSMBBeamCreatorTileEntity__beamCreator_drawing_useSVG
		[SMBSVGDrawableObject smb_space_spaceship_SVG];
#else
		[SMBBlockDrawableObject smb_defaultBlockDrawing_beamCreatorTileEntity_drawableObject_with_powerIndicatorColorRefBlock:
		 ^CGColorRef _Nullable{
			 return [self_weak powerIndicator_colorRef_appropriate];
		 }];
#endif
		[self subDrawableObjects_add:self.ship_drawableObject];

		[self setBeamEnterDirections_blocked:SMBGameBoardTile__directions_all()];
	}

	return self;
}

-(nonnull NSString*)description
{
	NSMutableArray<NSString*>* const description_lines = [NSMutableArray<NSString*> array];
	[description_lines ru_addObjectIfNotNil:[super description]];
	[description_lines ru_addObjectIfNotNil:RUStringWithFormat(@"self.beamEntity %@",self.beamEntity)];
	[description_lines ru_addObjectIfNotNil:RUStringWithFormat(@"self.beamDirection %li",(signed long)self.beamDirection)];

	return [description_lines componentsJoinedByString:@"\n"];
}

#pragma mark - SMBDrawableObject: subDrawableObjects
-(void)subDrawableObject:(nonnull __kindof SMBDrawableObject*)subDrawableObject
			draw_in_rect:(CGRect)rect
{
	CGContextRef const context = UIGraphicsGetCurrentContext();

	CoreGraphics_SMBRotation__rotateCTM(context, rect, CoreGraphics_SMBRotation__orientation_for_direction(self.beamDirection));

	[super subDrawableObject:subDrawableObject draw_in_rect:rect];
}

#pragma mark - SMBGameBoardTileEntity: gameBoardTile
-(void)setGameBoardTile:(nullable SMBGameBoardTile*)gameBoardTile
{
	[self SMBBeamCreatorTileEntity_gameBoardTile_setKVORegistered:NO];

	SMBGameBoardTile* const gameBoardTile_old = self.gameBoardTile;
	[super setGameBoardTile:gameBoardTile];

	[self gameBoardTile:gameBoardTile_old
			 beamEntity:self.beamEntity
gameBoard_gameBoardEntity_update:NO];

	[self SMBBeamCreatorTileEntity_gameBoardTile_setKVORegistered:YES];

	[self gameBoardTile:gameBoardTile
			 beamEntity:self.beamEntity
gameBoard_gameBoardEntity_update:YES];

	kRUConditionalReturn(gameBoardTile_old == self.gameBoardTile, NO);

	[self beamEntity_update];
}

#pragma mark - gameBoardTile
-(BOOL)SMBBeamCreatorTileEntity_gameBoardTile_requiresKVO
{
	return self.requiresExternalPowerForBeam;
}

-(void)SMBBeamCreatorTileEntity_gameBoardTile_setKVORegistered:(BOOL)registered
{
	kRUConditionalReturn([self SMBBeamCreatorTileEntity_gameBoardTile_requiresKVO] == false, NO);

	typeof(self.gameBoardTile) const gameBoardTile = self.gameBoardTile;
	kRUConditionalReturn(gameBoardTile == nil, NO);

	NSMutableArray<NSString*>* const propertiesToObserve = [NSMutableArray<NSString*> array];
	[propertiesToObserve addObject:[SMBGameBoardTile_PropertiesForKVO isPowered]];

	[propertiesToObserve enumerateObjectsUsingBlock:^(NSString * _Nonnull propertyToObserve, NSUInteger idx, BOOL * _Nonnull stop) {
		if (registered)
		{
			[gameBoardTile addObserver:self
							forKeyPath:propertyToObserve
							   options:(0)
							   context:&kSMBBeamCreatorTileEntity__KVOContext];
		}
		else
		{
			[gameBoardTile removeObserver:self
							   forKeyPath:propertyToObserve
								  context:&kSMBBeamCreatorTileEntity__KVOContext];
		}
	}];
}

-(void)gameBoardTile:(nullable SMBGameBoardTile* const)gameBoardTile
		  beamEntity:(nullable SMBBeamEntity* const)beamEntity
gameBoard_gameBoardEntity_update:(BOOL)add
{
	kRUConditionalReturn(gameBoardTile == nil, NO);

//	SMBBeamEntity* const beamEntity = self.beamEntity;
	kRUConditionalReturn(beamEntity == nil, NO);

//	SMBGameBoardTile* const gameBoardTile = self.gameBoardTile;
//	kRUConditionalReturn(gameBoardTile == nil, NO);

	SMBGameBoard* const gameBoard = gameBoardTile.gameBoard;
	kRUConditionalReturn((add == YES)
						 &&
						 gameBoard == nil, YES);

	kRUConditionalReturn(add == (beamEntity.gameBoard != nil), NO);

	if (add)
	{
		[gameBoard gameBoardEntity_add:beamEntity];
	}
	else
	{
		[gameBoard gameBoardEntity_remove:beamEntity];
	}
}

#pragma mark - KVO
-(void)observeValueForKeyPath:(nullable NSString*)keyPath ofObject:(nullable id)object change:(nullable NSDictionary*)change context:(nullable void*)context
{
	if (context == kSMBBeamCreatorTileEntity__KVOContext)
	{
		if (object == self.gameBoardTile)
		{
			if ([keyPath isEqualToString:[SMBGameBoardTile_PropertiesForKVO isPowered]])
			{
				NSAssert([self SMBBeamCreatorTileEntity_gameBoardTile_requiresKVO], @"should require KVO is changing");
				[self beamEntity_update];
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

#pragma mark - beamEntity
-(void)setBeamEntity:(nullable SMBBeamEntity* const)beamEntity
{
	kRUConditionalReturn(self.beamEntity == beamEntity, NO);

	SMBBeamEntity* const beamEntity_old = self.beamEntity;
	_beamEntity = beamEntity;

	[self gameBoardTile:self.gameBoardTile
			 beamEntity:beamEntity_old
gameBoard_gameBoardEntity_update:NO];

	[self gameBoardTile:self.gameBoardTile
			 beamEntity:beamEntity
gameBoard_gameBoardEntity_update:YES];

	[self setNeedsRedraw];
}

-(void)beamEntity_update
{
	[self setBeamEntity:[self beamEntity_create]];
}

-(nullable SMBBeamEntity*)beamEntity_create
{
	SMBGameBoardTile* const gameBoardTile = self.gameBoardTile;
	kRUConditionalReturn_ReturnValueNil(gameBoardTile == nil, NO);

	kRUConditionalReturn_ReturnValueNil((self.requiresExternalPowerForBeam == YES)
										&&
										(gameBoardTile.isPowered == false), NO);

	return [[SMBBeamEntity alloc] init_with_gameBoardTilePosition:gameBoardTile.gameBoardTilePosition];
}

#pragma mark - beamDirection
-(void)setBeamDirection:(SMBGameBoardTile__direction)beamDirection
{
	kRUConditionalReturn(self.beamDirection == beamDirection, NO);

	_beamDirection = beamDirection;

	[self beamEntity_update];
}

#pragma mark - requiresExternalPowerForBeam
-(void)setRequiresExternalPowerForBeam:(BOOL)requiresExternalPowerForBeam
{
	kRUConditionalReturn(self.requiresExternalPowerForBeam == requiresExternalPowerForBeam, NO);

	[self SMBBeamCreatorTileEntity_gameBoardTile_setKVORegistered:NO];

	_requiresExternalPowerForBeam = requiresExternalPowerForBeam;

	[self SMBBeamCreatorTileEntity_gameBoardTile_setKVORegistered:YES];

	[self beamEntity_update];
}

#pragma mark - SMBBeamBlockerTileEntity
-(BOOL)beamEnterDirection_isBlocked:(SMBGameBoardTile__direction)beamEnterDirection
{
	return YES;
}

#pragma mark - SMBBeamBlockerTileEntity
@synthesize beamEnterDirections_blocked = _beamEnterDirections_blocked;

#pragma mark - powerIndicator
-(nullable CGColorRef)powerIndicator_colorRef_appropriate
{
	kRUConditionalReturn_ReturnValueNil(self.requiresExternalPowerForBeam == NO, NO);

	return
	(self.beamEntity
	 ?
	 [UIColor greenColor]
	 :
	 [UIColor redColor]
	 ).CGColor;
}

@end
