//
//  DSTileMesh.h
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSVertexBuffer.h"

// Mask bits for flipping and rotation
extern const unsigned int kDSTileSetFlipMaskX;
extern const unsigned int kDSTileSetFlipMaskY;

// Mask for tile number (28 bit)
extern const unsigned int kDSTileSetTileMask;


#pragma mark Tile sets

//
//  protocol DSTileSetDatasource
//
//  Classes adopting this protocol should return a 3D vector value
//  relevant to the integer tag provided.
//

@protocol DSTileSetDatasource <NSObject>

- (CGRect)rectValueForTag:(unsigned int)index;

@end


//
//  interface DSRegularTileSet
//
//  A tile set that contains regular sized tiles.
//  The size and spacing of the tiles here should be consistent throughout the set.
//

@interface DSRegularTileSet : NSObject <DSTileSetDatasource> {
	
@private
    CGSize              tileSize;
    CGPoint             tileInset;
    unsigned int        tileModulo;
}

@property(nonatomic) CGSize tileSize;
@property(nonatomic) CGPoint tileInset;
@property(nonatomic) unsigned int tileModulo;

@end


//
//  interface DSFlippableTileSet
//
//  A tile set that contains regular sized tiles.
//  The size and spacing of the tiles here should be consistent throughout the set.
//

@interface DSFlippableTileSet : DSRegularTileSet {
}

@end

#pragma mark - Tile maps

//
//  protocol DSTileMapDatasource
//
//  Classes adopting this protocol should return an unsigned integer value
//  relevant to the 2D coordinates provided.
//  
//  For use with DSTileMesh
//

@protocol DSTileMapDatasource <NSObject>

- (unsigned int)tileNumberForPosX:(int)x posY:(int)y;

@end


//
//  interface DSAxisTileMapDataSource
//
//  TODO: document this
//

@interface DSAxisTileMapDataSource : NSObject <DSTileMapDatasource> {
    
    unsigned int        bgTile, axisTile;
    unsigned int        subDivision;
}

- (instancetype)initWithBackgroundTileNumber:(unsigned int)bg axisTileNumber:(unsigned int)ax;

@property(nonatomic) unsigned int subDivision;

@end


//
//  interface DSRegularTileMapDataSource
//
//  TODO: document this
//

@interface DSRegularTileMapDataSource : NSObject <DSTileMapDatasource> {
    
    unsigned int        repeatingTile;
}

- (instancetype)initWithRepeatingTileNumber:(unsigned int)tn;

@end

#pragma mark - Tile meshes

//
//  interface DSTileMesh
//
//  Generates a mesh from the tile map
//

@interface DSTileMesh : NSObject <DSVertexSource> {

    // Tile mesh helpers
    NSObject <DSTileSetDatasource>      *tileSet;
    NSObject <DSTileMapDatasource>      *dataSource;

	// Provided from initialisation parameters
	unsigned                            meshWidth;				// Number of quads in the mesh horizontally
	unsigned                            meshHeight;				// Number of quads in the mesh vertically
	
	// Tile set values
	CGSize                              tileSize;				// Size of one quad in the mesh

	// Vertex source values
	unsigned                            vertexSize;				// Size of one vertex (bytes)
	unsigned                            meshSize;				// Size of mesh
}

- (instancetype)initWithWidth:(unsigned)w height:(unsigned)h;

// Tile specification
@property(nonatomic) CGSize tileSize;
@property(nonatomic, strong) NSObject <DSTileSetDatasource> *tileSet;
@property(nonatomic, strong) NSObject <DSTileMapDatasource> *dataSource;

// Mesh specification
@property(nonatomic) unsigned mode;
@property(nonatomic, readonly) long vertexBufferSize;
@property(nonatomic, readonly) long indexBufferSize;

@end


//
//  interface DSScrollingTileMesh
//
//  Generates a mesh from the tile map
//

@interface DSScrollingTileMesh : DSTileMesh

// Mesh values
@property(nonatomic) GLKMatrix4 transformMatrix;

@end
