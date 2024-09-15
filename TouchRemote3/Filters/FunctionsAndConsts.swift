//
//  FunctionsAndConsts.swift
//  
//
//  Created by Seokhyun Song on 8/15/24.
//

import Foundation


let minLogFrequency = log10(20.0)
let maxLogFrequency = log10(20000.0)
let logFrequencyRange = maxLogFrequency - minLogFrequency
let maxdB = 18.0


let defaultDoubleArray = [Double](repeating: 0.0, count: graphResolution)

let pi2 = Double.pi * 2

let omega = (0..<graphResolution).map { i -> Double in
    let logFreq = minLogFrequency + logFrequencyRange * (Double(i) / Double(graphResolution - 1))
    return pow(10, logFreq) * pi2
}

let omega2 = omega^2

struct Calculate{
    static func frequency(_ normX: Double) -> Double {
        return pow(10,(minLogFrequency + normX * logFrequencyRange))
    }
    static func gain(_ normY: Double) -> Double{
        return normY * 2*maxdB - maxdB
    }
    static func passQ(_ normY: Double) -> Double { // only for PassFilters
        return pow(10, (normY*36-18)/20)
    }
    static func peakQ(_ normZ: Double) -> Double {
        return pow(10, normZ*2.50515 - 1)
    }
    static func shelfQ(_ normZ: Double) -> Double {
        return normZ * 3.6 + 0.4
    }
}


func magnitudeTodB(_ value: [Double]) -> [Double] {
    return value.map{ log10($0) * 20 }
}
func magnitudeComplex(_ real: [Double], _ imag: [Double]) -> [Double]{
    return zip(real, imag).map{ sqrt($0*$0 + $1*$1) }
}


func ^(lhs: [Double], rhs: [Double]) -> [Double] {
    guard lhs.count == rhs.count else {
        fatalError("Arrays do not have the same size")
    }
    return zip(lhs, rhs).map { pow($0, $1) }
}

func ^(lhs: [Double], rhs: Double) -> [Double] {
    return lhs.map { pow($0, rhs) }
}

func ^(lhs: Double, rhs: Double) -> Double {
    return pow(lhs, rhs) 
}



func *(lhs: [Double], rhs: [Double]) -> [Double] {
    guard lhs.count == rhs.count else {
        fatalError("Arrays do not have the same size")
    }
    return zip(lhs, rhs).map { $0 * $1 }
}

func *(lhs: [Double], rhs: Double) -> [Double] {
    return lhs.map { $0 * rhs }
}

func *(lhs: Double, rhs: [Double]) -> [Double] {
    return rhs.map { lhs * $0 }
}


func /(lhs: [Double], rhs: [Double]) -> [Double] {
    guard lhs.count == rhs.count else {
        fatalError("Arrays do not have the same size")
    }
    return zip(lhs, rhs).map { $0 / $1 }
}

func /(lhs: [Double], rhs: Double) -> [Double] {
    return lhs.map { $0 / rhs }
}

func /(lhs: Double, rhs: [Double]) -> [Double] {
    return rhs.map { lhs / $0 }
}


func +(lhs: [Double], rhs: [Double]) -> [Double] {
    guard lhs.count == rhs.count else {
        fatalError("Arrays do not have the same size")
    }
    return zip(lhs, rhs).map { $0 + $1 }
}

func +(lhs: Double, rhs: [Double]) -> [Double] {
    return rhs.map { lhs + $0 }
}

func +(lhs: [Double], rhs: Double) -> [Double] {
    return lhs.map { $0 + rhs }
}


func -(lhs: [Double], rhs: [Double]) -> [Double] {
    guard lhs.count == rhs.count else {
        fatalError("Arrays do not have the same size")
    }
    return zip(lhs, rhs).map { $0 - $1 }
}

func -(lhs: Double, rhs: [Double]) -> [Double] {
    return rhs.map { lhs - $0 }
}

func -(lhs: [Double], rhs: Double) -> [Double] {
    return lhs.map { $0 - rhs }
}


