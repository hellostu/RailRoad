//
//  RRMatrix2D.m
//  RailRoad
//
//  Created by Stuart Lynch on 09/02/2013.
//  Copyright (c) 2013 UEA. All rights reserved.
//

#import "RRMatrix2D.h"
#import <Accelerate/Accelerate.h>

@interface RRMatrix2D ()
{
    @private
    float *_data;
}

@end

@implementation RRMatrix2D

@synthesize rows;
@synthesize columns;
@dynamic bytes;
@dynamic numel;

-(float *)bytes
{
    return _data;
}

-(uint)numel
{
    return rows*columns;
}

//////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
//////////////////////////////////////////////////////////////////////////

- (id)copyWithZone:(NSZone *)zone
{
    RRMatrix2D *matrix = [[RRMatrix2D allocWithZone:zone] initWithBytes:self.bytes Rows:self.rows Columns:self.columns];
    return matrix;
}

-(id)initWithRows:(uint)r Columns:(uint)c
{
    self = [super init];
    if(self)
    {
        rows = r;
        columns = c;
        _data = malloc(rows*columns*sizeof(float));
        memset(_data, 0, rows*columns*sizeof(float));
    }
    return self;
}

+(id)matrixWithRows:(uint)r Columns:(uint)c
{
    RRMatrix2D *m = [[RRMatrix2D alloc] initWithRows:r Columns:c];
    return [m autorelease];
}

-(id)initWithBytes:(void *)b Rows:(uint)r Columns:(uint)c
{
    if( (self = [super init]) != nil )
    {
        rows = r;
        columns = c;
        _data = malloc(rows*columns*sizeof(float));
        memcpy(_data, b, rows*columns*sizeof(float));
    }
    return self;
}

+(id)matrixWithBytes:(void *)b Rows:(uint)r Columns:(uint)c
{
    RRMatrix2D *m = [[RRMatrix2D alloc] initWithBytes:b Rows:r Columns:c];
    return [m autorelease];
}

-(id)initIdenityWithSize:(uint)s
{
    self = [self initWithRows:s Columns:s];
    for(uint i=0; i<s; i++)
    {
        [self setValue:1 atRow:i Column:i];
    }
    return self;
}

+(id)identityWithSize:(uint)s
{
    RRMatrix2D *m = [[RRMatrix2D alloc] initIdenityWithSize:s];
    return [m autorelease];
}

-(void)dealloc
{
    free(_data);
    [super dealloc];
}

//////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Methods
//////////////////////////////////////////////////////////////////////////

-(void)setValue:(float)v atRow:(uint)i Column:(uint)j
{
    if(i>=rows || j>=columns)
    {
        NSException *e = [NSException exceptionWithName:@"Invalid Matrix Index"
                                                 reason:[NSString stringWithFormat: @"Tried to access [%d %d] in Matrix which has size [%d %d]", i, j, rows, columns]
                                               userInfo:nil];
        @throw e;
    }
    uint x  = (j*rows)+i;
    _data[x] = v;
    
}

-(float)valueAtRow:(uint)i Column:(uint)j
{
    if(i>=rows || j>=columns)
    {
        NSException *e = [NSException exceptionWithName:@"Invalid Matrix Index"
                                                 reason:[NSString stringWithFormat: @"Tried to access [%d %d] in Matrix which has size [%d %d]", i, j, rows, columns]
                                               userInfo:nil];
        @throw e;
    }
    uint x = (j*rows)+i;
    return _data[x];
}

-(void)setValue:(float)v atIndex:(uint)i
{
    if(i>=rows*columns)
    {
        NSException *e = [NSException exceptionWithName:@"Invalid Matrix Index"
                                                 reason:[NSString stringWithFormat: @"Tried to access element at index %d in Matrix which has %d elements.", i, rows*columns]
                                               userInfo:nil];
        @throw e;
    }
    _data[i] = v;
}

-(float)valueAtIndex:(uint)i
{
    if(i>=rows*columns)
    {
        NSException *e = [NSException exceptionWithName:@"Invalid Matrix Index"
                                                 reason:[NSString stringWithFormat: @"Tried to access element at index %d in Matrix which has %d elements.", i, rows*columns]
                                               userInfo:nil];
        @throw e;
    }
    return _data[i];
}

-(BOOL)sameSizeAs:(RRMatrix2D *)m
{
    if(rows==m.rows && columns==m.columns)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(void)print
{
    for(int i = 0; i < rows; i++ )
    {
        for(int j = 0; j < columns; j++ )
        {
            printf( " %6.2f", _data[i+j*rows] );
        }
        printf( "\n" );
    }
    printf( "\n" );
}

//////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Operations
//////////////////////////////////////////////////////////////////////////

-(RRMatrix2D *)add:(RRMatrix2D *)m
{
    if(![self sameSizeAs:m])
    {
        NSException *e = [NSException exceptionWithName:@"Invalid WPMatrix Operation"
                                                 reason:[NSString stringWithFormat: @"WPMatrix dimensions must match. \nDimensions of WPMatrix 1: [%d %d].\nDimensions of WPMatrix 2: [%d %d] ",rows, columns, m.rows, m.columns]
                                               userInfo:nil];
        @throw e;
    }
    RRMatrix2D *r = [RRMatrix2D matrixWithRows:[self rows] Columns:[self columns]];
    for(uint i=0; i<rows; i++)
    {
        for(uint j=0; j<columns; j++)
        {
            float a = [self valueAtRow:i Column:j];
            float b = [m    valueAtRow:i Column:j];
            [r setValue:a+b atRow:i Column:j];
        }
    }
    return r;
}

-(RRMatrix2D *)subtract:(RRMatrix2D *)m
{
    if(![self sameSizeAs:m])
    {
        NSException *e = [NSException exceptionWithName:@"Invalid WPMatrix Operation"
                                                 reason:[NSString stringWithFormat: @"WPMatrix dimensions must match. \nDimensions of WPMatrix 1: [%d %d].\nDimensions of WPMatrix 2: [%d %d] ",rows, columns, m.rows, m.columns]
                                               userInfo:nil];
        @throw e;
    }
    RRMatrix2D *r = [RRMatrix2D matrixWithRows:[self rows] Columns:[self columns]];
    for(uint i=0; i<rows; i++)
    {
        for(uint j=0; j<columns; j++)
        {
            float a = [self valueAtRow:i Column:j];
            float b = [m    valueAtRow:i Column:j];
            [r setValue:a-b atRow:i Column:j];
        }
    }
    return r;
}

-(RRMatrix2D *)multiply:(RRMatrix2D *)m
{
    if(self.columns != m.rows)
    {
        NSException *e = [NSException exceptionWithName:@"Invalid WPMatrix Multiply Operation"
                                                 reason:[NSString stringWithFormat: @"Inner WPMatrix dimensions must match. \nDimensions of WPMatrix 1: [%d %d].\nDimensions of WPMatrix 2: [%d %d] ",rows, columns, m.rows, m.columns]
                                               userInfo:nil];
        @throw e;
    }
    RRMatrix2D *r = [RRMatrix2D matrixWithRows:self.rows Columns:m.columns];
    
    for (uint i=0; i<self.rows; i++)
    {
        for (uint j=0; j<m.columns; j++)
        {
            float temp = 0;
            for (uint k=0; k<self.columns; k++)
            {
                temp = temp+[self valueAtRow:i Column:k]*[m valueAtRow:k Column:j];
            }
            [r setValue:temp atRow:i Column:j];
        }
    }
    return r;
}

-(RRMatrix2D *)addScalar:(float)s
{
    RRMatrix2D *r = [RRMatrix2D matrixWithRows:[self rows] Columns:[self columns]];
    for(uint i=0; i<rows; i++)
    {
        for(uint j=0; j<columns; j++)
        {
            float a = [self valueAtRow:i Column:j];
            [r setValue:a+s atRow:i Column:j];
        }
    }
    return r;
}

-(RRMatrix2D *)subtractScalar:(float)s
{
    RRMatrix2D *r = [RRMatrix2D matrixWithRows:[self rows] Columns:[self columns]];
    for(uint i=0; i<rows; i++)
    {
        for(uint j=0; j<columns; j++)
        {
            float a = [self valueAtRow:i Column:j];
            [r setValue:a-s atRow:i Column:j];
        }
    }
    return r;
}

-(RRMatrix2D *)multiplyScalar:(float)s
{
    RRMatrix2D *r = [RRMatrix2D matrixWithRows:[self rows] Columns:[self columns]];
    for(uint i=0; i<rows; i++)
    {
        for(uint j=0; j<columns; j++)
        {
            float a = [self valueAtRow:i Column:j];
            [r setValue:a*s atRow:i Column:j];
        }
    }
    return r;
}

-(RRMatrix2D *)raise:(float)s
{
    RRMatrix2D *r = [RRMatrix2D matrixWithRows:[self rows] Columns:[self columns]];
    for(uint i=0; i<rows; i++)
    {
        for(uint j=0; j<columns; j++)
        {
            float a = [self valueAtRow:i Column:j];
            [r setValue:pow(a,s) atRow:i Column:j];
        }
    }
    return r;
}

-(RRMatrix2D *)solve:(RRMatrix2D *)m
{
    if(rows!=columns)
    {
        NSException *e = [NSException exceptionWithName:@"Invalid WPMatrix"
                                                 reason:@"WPMatrix must be square to solve linear system of equations."
                                               userInfo:nil];
        @throw e;
    }
    else if(rows!=m.rows)
    {
        NSException *e = [NSException exceptionWithName:@"Invalid WPMatrix"
                                                 reason:@"A WPMatrix must have the same number of rows as b WPMatrix to solve linear system of equations. "
                                               userInfo:nil];
        @throw e;
    }
    __CLPK_integer rowsInt = (__CLPK_integer) rows;
    __CLPK_integer colsInt = (__CLPK_integer) m.columns;
    __CLPK_integer ipiv[rowsInt];
    
    float * A = malloc(rows*columns*sizeof(float));
    memcpy(A, _data, rows*columns*sizeof(float));
    float * b = malloc(m.rows*m.columns*sizeof(float));
    memcpy(b, m.bytes, m.rows*m.columns*sizeof(float));
    
    __CLPK_integer info;
    sgesv_(&rowsInt, &colsInt, A, &rowsInt, ipiv, b, &rowsInt, &info);
    RRMatrix2D *r = [RRMatrix2D matrixWithBytes:b Rows:rowsInt Columns:colsInt];
    
    free(A);
    free(b);
    
    
    
    
    return r;
}

-(RRMatrix2D *)transpose
{
    
    RRMatrix2D *r = [RRMatrix2D matrixWithRows:self.columns Columns:self.rows];
    for(uint i=0; i<self.rows; i++)
    {
        for(uint j=0; j<self.columns; j++)
        {
            [r setValue:[self valueAtRow:i Column:j] atRow:j Column:i];
        }
    }
    return r;
}

//////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Vector Operations
//////////////////////////////////////////////////////////////////////////

-(float)euclidSq:(RRMatrix2D *)m
{
    if(self.numel != m.numel)
    {
        NSException *e = [NSException exceptionWithName:@"Invalid WPMatrix"
                                                 reason:@"Matrices must have the same number of elements for euclidean distance."
                                               userInfo:nil];
        @throw e;
    }
    
    float sum = 0;
    for(uint i=0; i<self.numel; i++) {
        sum+=pow([self valueAtIndex:i]-[m valueAtIndex:i],2);
    }
    return sum;
}




@end
