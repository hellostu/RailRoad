//
//  RRMatrix2D.h
//  RailRoad
//
//  ==== LICENCE ====
//
// This file is part of RailRoad.
// 
// RailRoad is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// RailRoad is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with RailRoad.  If not, see <http://www.gnu.org/licenses/>.
//
//  Created by Stuart Lynch on 09/02/2013.
//  Copyright (c) 2013 UEA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A class to represent a matrix. It contains many useful methods for matrix manipulation. 
 @author Stuart Lynch stuart.lynch@uea.ac.uk
 */

@interface RRMatrix2D : NSObject <NSCopying>

/**
 The number of rows the matrix has. 
 */
@property(readonly) uint rows;

/**
 The number of columns the matrix has. 
 */
@property(readonly) uint columns;

/**
 The total number of elements the matrix has. 
 */
@property(readonly) uint numel;

/**
 An array of bytes, containing the matrix contents. 
 */
@property(readonly) float * bytes;


/**
 Initialize an empty matrix. 
 @param r The number of rows.
 @param c The number of columns.
 @returns A new instance of RRMatrix2D
 */
-(id)initWithRows:(uint)r Columns:(uint)c;

/**
 Static Initialization of an empty matrix.
 @param r The number of rows.
 @param c The number of columns.
 @returns A new instance of RRMatrix2D
 */
+(id)matrixWithRows:(uint)r Columns:(uint)c;

/**
 Initialize a matrix with the contents of an array of floats.
 @param bytes The raw data to initialize a matrix with (array of floats). 
 @param r The number of rows.
 @param c The number of columns.
 @returns A new instance of RRMatrix2D
 */
-(id)initWithBytes:(void *)b Rows:(uint)r Columns:(uint)c;

/**
Static Initialization of a matrix with the contents of an array of floats.
 @param bytes The raw data to initialize a matrix with (array of floats).
 @param r The number of rows.
 @param c The number of columns.
 @returns A new instance of RRMatrix2D
 */
+(id)matrixWithBytes:(void *)b Rows:(uint)r Columns:(uint)c;

/**
 Initialize a square identity matrix.
 @param s The size of the square matrix.
 @returns A new instance of RRMatrix2D
 */
-(id)initIdenityWithSize:(uint)s;

/**
 Static Initialization of a square identity matrix.
 @param s The size of the square matrix.
 @returns A new instance of RRMatrix2D
 */
+(id)identityWithSize:(uint)s;

/**
 Assign a new value to the location at the given row and column.
 @param v The new value to be assigned.
 @param i Row to assign new value.
 @param j Column to assign new value. 
 */
-(void)setValue:(float)v atRow:(uint)i Column:(uint)j;

/**
 Get the value at the location specified by the given row and column. 
 @param i Row.
 @param j Column.
 @returns The value at the given location. 
 */
-(float)valueAtRow:(uint)i Column:(uint)j;

/**
 Set a value at the single index in the array representing the matrix. 
 @param v The new value to be assigned.
 @param i The index.
 */
-(void)setValue:(float)v atIndex:(uint)i;

/**
 Get a value at the single index in the array representing the matrix.
 @param i The index.
 @returns The value at the specified index.
 */
-(float)valueAtIndex:(uint)i;

/**
 Element by element addition of this matrix and another matrix. 
 @param m The matrix to add to this one. Must be the same dimensions.
 @returns A new matrix of this matrix plus the matrix m.
 */
-(RRMatrix2D *)add:(RRMatrix2D *)m;

/**
 Element by element subtraction of this matrix and another matrix.
 @param m The matrix to minus from this one. Must be the same dimensions.
 @returns A new matrix of this matrix minus the matrix m.
 */
-(RRMatrix2D *)subtract:(RRMatrix2D *)m;

/**
 Matrix muiltiplcation of this matrix and another matrix. The inner dimensions must match.
 @param m The matrix to multiply by. 
 @returns A new matrix containing the result of the multiplication. 
 */
-(RRMatrix2D *)multiply:(RRMatrix2D *)m;

/**
 Add a single scalar to every element of this matrix.
 @param s The scalar to add. 
 @returns A new matrix containing the result of the addition.
 */
-(RRMatrix2D *)addScalar:(float)s;

/**
 Subtract a single scalar from every element of this matrix.
 @param s The scalar to minus.
 @returns A new matrix containing the result of the subtraction.
 */
-(RRMatrix2D *)subtractScalar:(float)s;

/**
 Multiply every element in this matrix by the given scalar. 
 @param s The scalar to multiply by. 
 @returns A new matrix containing the result of the multiplication.
 */
-(RRMatrix2D *)multiplyScalar:(float)s;

/**
 Raise each element in this matrix to the power of the given scalar.
 @param s The scalar to raise by.
 @returns A new matrix containing the result of the raising.
 */
-(RRMatrix2D *)raise:(float)s;

/**
 Solve `Ax=b`. Assuming this matrix `A` has dimensions `n x m` and the input matrix has dimensions `v x w` then the output matrix will be of the dimension `m x v`.
 @param m The matrix `b` to solve for `x` in `Ax=b`. 
 @returns The solution to `Ax=b`.
 */
-(RRMatrix2D *)solve:(RRMatrix2D *)m;

/**
 The transpose of this matrix.
 @returns The transpose of this matrix. 
 */
-(RRMatrix2D *)transpose;

/**
 The sum of squared euclidean distances between two matrices.
 @param m The matrix to compare against.
 @returns The sum of squared euclidean distances.
 */
-(float)euclidSq:(RRMatrix2D *)m;

/**
 Print the contents of this matrix to the concole. 
 */
-(void)print;


@end
