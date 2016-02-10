
//
//  HistoView.swift
//  SocialMaxx
//
//  Created by bill donner on 1/16/16.
//  Copyright © 2016 SocialMax. All rights reserved.
//

import Foundation

// hacked from the apple book - matrix is a simple linear array
struct Matrix {
    let rows: Int, columns: Int
    var grid: [Double]
    init(rows: Int=7, columns: Int=24) {
        self.rows = rows
        self.columns = columns
        grid = Array(count: rows * columns, repeatedValue: 0.0)
    }
    func indexIsValidForRow(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    subscript(row: Int, column: Int) -> Double {
        get {
            assert(indexIsValidForRow(row, column: column), "Index out of range")
            return grid[(row * columns) + column]
        }
        set {
            assert(indexIsValidForRow(row, column: column), "Index out of range")
            grid[(row * columns) + column] = newValue
        }
    }
}
struct QuintMatrix { // a matrix that has been quantized into buckets with 5 values
    
    var matrix : Matrix
    var maxv:Int
    var gs : Int
    
    init(m:Matrix) {
        func computeQuintiles(m:Matrix)->(Matrix,Int,Int) {
            var res = Matrix(rows:m.rows,columns:m.columns)
            var maxval = 0
            var grandsum  = 0
            
            func translateToQuintileByScaling(a:Double) -> Double { // 0 - 4   for 5 buckets
                let b = a / Double(maxval+1)// 0..<1.0
                let c = trunc(b * 5.0)
                assert(c <= 4)
                return Double(c)
            }
            // frist figure grandsum and max
            let _ = m.grid.map {
                let v = $0
                grandsum += Int(v)
                if Int(v) > maxval {
                    maxval = Int(v) }
            }
            
            for row in 0..<m.rows {
                for col in 0..<m.columns {
                    let v = m[row,col]
                    res[row,col] = translateToQuintileByScaling(v)
                }
            }
            return (res,grandsum,maxval)
        }
        let (a,b,c) = computeQuintiles(m)
        self.maxv = c
        self.gs = b
        self.matrix = a
    }
}
struct AlphaMatrix { // a matrix that has normalized all values 0..1 to be useful as alpha values for rgb
    
    var matrix : Matrix
    var maxv:Double
    var gs : Double
    
    init(m:Matrix) {
        func computeAlphas(m:Matrix)->(Matrix,Double,Double) {
            var res = Matrix(rows:m.rows,columns:m.columns)
            var maxval = 0.0
            var grandsum  = 0.0
            
            func translateToAlphasByScaling(a:Double) -> Double { // 0 - 4   for 5 buckets
                return Double(a/maxval)
            }
            // frist figure grandsum and max
            let _ = m.grid.map {
                let v = $0
                grandsum += v
                if v > maxval {
                    maxval = v }
            }
            
            for row in 0..<m.rows {
                for col in 0..<m.columns {
                    let v = m[row,col]
                    res[row,col] = translateToAlphasByScaling(v)
                }
            }
            return (res,grandsum,maxval)
        }
        let (a,b,c) = computeAlphas(m)
        self.maxv = c
        self.gs = b
        self.matrix = a
    }
}


