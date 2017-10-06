//
//  DSTileMesh.m
//  Dogstar Engine (unified version)
//
//  Created by Richard Henry on 01/01/2011.
//  Copyright 2011 Dogstar Diversions. http://www.dogstar.mobi
//

#import "DSTileMesh.h"
#import "DSShader.h"
#import "DSDrawContext.h"
#import "DSCGPointExt.h"
#import "DSMaths.h"

// Mask bits for flipping and rotation
const unsigned int kDSTileSetFlipMaskX  = 0x80000000; // 1 bit
const unsigned int kDSTileSetFlipMaskY  = 0x40000000; // 1 bit

// Mask for tile number (28 bit)
const unsigned int kDSTileSetTileMask = ~(kDSTileSetFlipMaskX | kDSTileSetFlipMaskY);


#pragma mark Tile sets

@implementation DSRegularTileSet

- (instancetype)init {
	
	if ((self = [super init])) {
		
		tileSize = (CGSize) { 1.0f, 1.0f };
        tileInset = (CGPoint) { 0.0f, 0.0f };
        tileModulo = 1;
	}
	
	return self;
}

- (CGRect)rectValueForTag:(unsigned int)tileNumber {
	
    CGPoint tileOffset = (CGPoint) { tileSize.width, tileSize.height };
    
    tileOffset.x *= tileNumber % tileModulo;
    tileOffset.y *= tileNumber / tileModulo;

    return CGRectInset(CGRectMake(tileOffset.x, tileOffset.y, tileOffset.x + tileSize.width, tileOffset.y + tileSize.height), tileInset.x, tileInset.y);
}

#pragma mark Properties

@synthesize tileSize;
@synthesize tileInset;
@synthesize tileModulo;

@end


@implementation DSFlippableTileSet

- (CGRect)rectValueForTag:(unsigned int)tileNumber {
	
    // Get the raw coordinates
	CGRect              coords = [super rectValueForTag:(tileNumber & kDSTileSetTileMask)];
	
    // Do we need to flip the rectangle?
    if (tileNumber & kDSTileSetFlipMaskX) {
        
        float flipMin = coords.origin.x;
        
        coords.origin.x = coords.size.width;
        coords.size.width = flipMin;
    }
    
    if (tileNumber & kDSTileSetFlipMaskY) {
        
        float flipMin = coords.origin.y;
        
        coords.origin.y = coords.size.height;
        coords.size.height = flipMin;
    }
    
	return coords;
}

@end

#pragma mark - Tile set data sources

@implementation DSRegularTileMapDataSource

- (instancetype)initWithRepeatingTileNumber:(unsigned int)tn {
	
	if ((self = [super init])) {
        
        repeatingTile = tn;
	}
	
	return self;
}

- (unsigned int)tileNumberForPosX:(int)x posY:(int)y {
	
    //static unsigned choices[] = { 1, 2, 3, 8, 9, 11, 12, 13, 14, 15 };
    
	//return (!x && !y) ? 18 : 22;
	//return (!x && !y) ? 18 : 19;
	//return (!x && !y) ? 66 | kDSTileSetFlipMaskY | kDSTileSetFlipMaskX : 66;
	//return choices[rand() % 10];
    //return 0;
    
    return repeatingTile;
}

@end

@implementation DSAxisTileMapDataSource

@synthesize subDivision;

- (instancetype)initWithBackgroundTileNumber:(unsigned int)bg axisTileNumber:(unsigned int)ax {
	
	if ((self = [super init])) {
        
        bgTile = bg;
        axisTile = ax;
        
        subDivision = 0;
	}
	
	return self;
}

- (unsigned int)tileNumberForPosX:(int)x posY:(int)y {
    
    if (subDivision)
        return ((!(abs(x) % subDivision)) || (!(abs(y) % subDivision))) ? axisTile : bgTile;
    else
        return (!x || !y) ? axisTile : bgTile;
}

@end

#pragma mark - Tile meshes

struct DSVertex {
	
	GLfloat			x, y;				// Position - offset 0
	GLfloat         s, t;				// Texture coordinates - offset 8
};


@implementation DSTileMesh

- (instancetype)initWithWidth:(unsigned)w height:(unsigned)h {
	
	if ((self = [super init])) {
		
		_mode = GL_STATIC_DRAW;
		
		meshWidth = w;
		meshHeight = h;
		
        self.tileSize = (CGSize) { 1.0f, 1.0f };
        
		vertexSize = sizeof(struct DSVertex);
		meshSize = meshWidth * meshHeight;
	}
	
	return self;
}

- (void)dealloc {
	
	self.tileSet = nil;
	self.dataSource = nil;
}

#pragma mark Initialisation

- (void)describeVerticesInContext:(DSDrawContext *)context {

    int            stride = vertexSize;

    // VAO vertex position (always at location 0)
    GLint attributeLocation = [context.shader getAttributeLocation:@"position"];
    glEnableVertexAttribArray(attributeLocation);
    glVertexAttribPointer(attributeLocation, 2, GL_FLOAT, GL_FALSE, stride, 0);

    // VAO vertex texture coordinates set 0
    attributeLocation = [context.shader getAttributeLocation:@"tc_0"];
    if (attributeLocation > 0) {
        glEnableVertexAttribArray(attributeLocation);
        glVertexAttribPointer(attributeLocation, 2, GL_FLOAT, GL_FALSE, stride, glVBOBufferOffset(8));
    }
}

#pragma mark Drawing

- (void)drawVerticesInContext:(DSDrawContext *)context {

    // Draw the indexed vertices
	glDrawElements(GL_TRIANGLES, 6 * meshSize, GL_UNSIGNED_SHORT, NULL);
}

- (long)vertexBufferSize {
	
	return 4 * meshSize * vertexSize;
}

- (void)fillVertexBuffer:(void *)vboBuffer {
	
	struct DSVertex *vertices = vboBuffer;
	
	// Fill the vertex buffer with interleaved data
	for (unsigned y = 0; y < meshHeight; y++) {
		
		for (unsigned x = 0; x < meshWidth; x++) {
			
			// Vertex positions
			float		x0 = x * tileSize.width;
			float		x1 = x0 + tileSize.width;
			float		y0 = y * tileSize.height;
			float		y1 = y0 + tileSize.height;
			
			// Tile texture coordinates
			CGRect tc = [tileSet rectValueForTag:[dataSource tileNumberForPosX:x posY:y]];
			
			// Vertex 0
			vertices->x = x0;
			vertices->y = y0;
			vertices->s = tc.origin.x;
			vertices->t = tc.origin.y;
			vertices++;
			
			// Vertex 1
			vertices->x = x1;
			vertices->y = y0;
			vertices->s = tc.size.width;
			vertices->t = tc.origin.y;
			vertices++;
			
			// Vertex 2
			vertices->x = x1;
			vertices->y = y1;
			vertices->s = tc.size.width;
			vertices->t = tc.size.height;
			vertices++;
			
			// Vertex 3
			vertices->x = x0;
			vertices->y = y1;
			vertices->s = tc.origin.x;
			vertices->t = tc.size.height;
			vertices++;
		}
	}
}

- (long)indexBufferSize {
	
	return 6 * meshSize * sizeof(GLushort);
}

- (void)fillIndexBuffer:(void *)iboBuffer {
	
	GLushort			*indices = iboBuffer;
	
	// Fill index buffer
	for (unsigned long i = 0, index = 0; i < meshSize; i++) {
		
		GLushort start = i * 4;
		
		// Triangle 0
		indices[index++] = start;
		indices[index++] = start + 2;
		indices[index++] = start + 3;
		
		// Triangle 1
		indices[index++] = start;
		indices[index++] = start + 1;
		indices[index++] = start + 2;
	}
}

#pragma mark Properties

// Tile properties
@synthesize tileSize;
@synthesize tileSet;
@synthesize dataSource;

@end

#pragma mark Scrolling tile mesh

@implementation DSScrollingTileMesh {

    // Mesh midpoint for vertex positioning calculations
    CGPoint             midPoint;

}

- (instancetype)initWithWidth:(unsigned)w height:(unsigned)h {
	
	if ((self = [super initWithWidth:w height:h])) {

		self.mode = GL_DYNAMIC_DRAW;

        self.transformMatrix = GLKMatrix4Identity;
	}
	
	return self;
}

- (void)drawVerticesInContext:(DSDrawContext *)context {

	// Save context transform and compute smooth scrolling component of transform
	GLKMatrix4 oldTransform = context.transformMatrix;

    // Extract the smooth translation portion of the current transform
    GLKVector3 smoothTranslation = DSMatrix4GetTranslate(_transformMatrix);

    // Set the smooth translation RJH TODO ehat about the rotation? Is this really a modulo?
    GLKMatrix4 smoothTransform = GLKMatrix4MakeTranslation(fmodf(smoothTranslation.x, tileSize.width), fmodf(smoothTranslation.y, tileSize.height), 0);

	// Set transform matrix for smooth scrolling
	context.transformMatrix = smoothTransform;
	
    // Draw the indexed vertices
	glDrawElements(GL_TRIANGLES, 6 * meshSize, GL_UNSIGNED_SHORT, NULL);

	// Restore context transform
	context.transformMatrix = oldTransform;
}

- (void)fillVertexBuffer:(void *)vboBuffer {
	
	struct DSVertex *vertices = vboBuffer;
	
	// Compute rough scrolling component of transform
	GLKMatrix4 transform = _transformMatrix;
	GLKVector3 roughTransform = DSMatrix4GetTranslate(transform);
	
	int roughX = -((int)roughTransform.x / (int)tileSize.width) - meshWidth / 2;
	int roughY = -((int)roughTransform.y / (int)tileSize.height) - meshHeight / 2;
	
	// Fill the vertex buffer with interleaved data
	for (unsigned y = 0; y < meshHeight; y++) {
		
		for (unsigned x = 0; x < meshWidth; x++) {
			
			// Vertex positions
			float		x0 = x * tileSize.width - midPoint.x;
			float		x1 = x0 + tileSize.width;
			float		y0 = y * tileSize.height - midPoint.y;
			float		y1 = y0 + tileSize.height;
			
			// Tile texture coordinates
			CGRect tc = [tileSet rectValueForTag:[dataSource tileNumberForPosX:roughX + x posY:roughY + y]];
			
			// Vertex 0
			vertices->x = x0;
			vertices->y = y0;
			vertices->s = tc.origin.x;
			vertices->t = tc.origin.y;
			vertices++;
			
			// Vertex 1
			vertices->x = x1;
			vertices->y = y0;
			vertices->s = tc.size.width;
			vertices->t = tc.origin.y;
			vertices++;
			
			// Vertex 2
			vertices->x = x1;
			vertices->y = y1;
			vertices->s = tc.size.width;
			vertices->t = tc.size.height;
			vertices++;
			
			// Vertex 3
			vertices->x = x0;
			vertices->y = y1;
			vertices->s = tc.origin.x;
			vertices->t = tc.size.height;
			vertices++;
		}
	}
}

#pragma mark Properties

@dynamic tileSize;

- (CGSize)tileSize { return tileSize; }

- (void)setTileSize:(CGSize)ts {
	
    tileSize = ts;
    
	midPoint.x = meshWidth * tileSize.width * 0.5f;
	midPoint.y = meshHeight * tileSize.height * 0.5f;
}

@end
