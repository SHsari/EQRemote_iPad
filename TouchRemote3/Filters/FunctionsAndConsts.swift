//
//  FunctionsAndConsts.swift
//  
//
//  Created by Seokhyun Song on 8/15/24.
//

import Foundation

// 그래프 계산을 위한 각종 상수값
// 또 Double 배열 연산을 용이하게 해주는 Override 함수들 정의입니다.

// 주파수 범위입니다.
// 로그 취해주어야 사람이 인지하는 방식과 선형적인 관계를 갖고 표시됩니다.
// 세상 모든 소리주파수 표현 방식이죵
let minLogFrequency = log10(20.0)
let maxLogFrequency = log10(20000.0)
let logFrequencyRange = maxLogFrequency - minLogFrequency
// gain의 레인지는 -18~+18입니다.
let maxdB = 18.0
let dBRange = maxdB * 2

//필터 타입별로 Q값의 레인지가 다릅니다.
let logPeakQMax = log10(32.0)
let logPeakQmin = log10(0.1)
let logPeakQRange = logPeakQMax - logPeakQmin
let shelfQmin = 0.4
let shelfQRange = 3.6

// 0으로 꽉찬 배열
let defaultDoubleArray = [Double](repeating: 0.0, count: graphResolution)
// 원주율 두배값.
let pi2 = Double.pi * 2

// 전달함수 중간 계산에 필요한 상수값입니다.
// 주파수별로 값이 달라지기 때문에 2048개의 더블 배열로 상수를 저장합니다.
let omega = (0..<graphResolution).map { i -> Double in
    let logFreq = minLogFrequency + logFrequencyRange * (Double(i) / Double(graphResolution - 1))
    return pow(10, logFreq) * pi2
}
// 역시 실시간 응답 계산을 빠르게 하기 위한 omega^2 값을 상수로 선언.
let omega2 = omega^2

// 화면의 위치에서 X, Y값을 0~1사이의 값으로 노멀라이즈 하여 반환합니다.
// 이 노멀라이즈 된 값을 실제 주파수, 게인, Q 값으로 변경해주는 간단한 계산함수입니다.
struct Calculate{
    static func frequency(_ normX: Double) -> Double {
        return pow(10,(minLogFrequency + normX * logFrequencyRange))
    }
    static func gain(_ normY: Double) -> Double{
        return normY * dBRange - maxdB
    }
    static func passQ(_ normY: Double) -> Double { // only for PassFilters
        return pow(10, (normY*dBRange-maxdB)/20)
    }
    static func peakQ(_ normZ: Double) -> Double {
        return pow(10, normZ*logPeakQRange + logPeakQmin)
    }
    static func shelfQ(_ normZ: Double) -> Double {
        return normZ * shelfQRange + shelfQmin
    }
    
    static func normX(_ freq: Double) -> Double {
        return (log10(freq) - minLogFrequency) / logFrequencyRange
    }
    static func normYwith(gain: Double) -> Double {
        return (gain + maxdB) / dBRange
    }
    
    static func normZwith(peakQ: Double) -> Double {
        return (log10(peakQ) - logPeakQmin) / logPeakQRange
    }
    static func normYwith(passQ: Double) -> Double {
        return (log10(passQ)*20 + maxdB) / dBRange
    }
    static func normZwith(shelfQ: Double) -> Double {
        return (shelfQ - shelfQmin) / shelfQRange
    }
}

// 뭐지 이거
struct Quantize{
    static func frequency(origin: Double) {
        
    }
}

// 주파수별로 계산된 필터의 이득값을 로그스케일인 dB로 바꿔주는 함수입니다.
func magnitudeTodB(_ value: [Double]) -> [Double] {
    return value.map{ log10($0) * 20 }
}
// 복소수의 크기를 계산하여 주파수별로 이득값을 계산해주는 함수.
func magnitudeComplex(_ real: [Double], _ imag: [Double]) -> [Double]{
    return zip(real, imag).map{ sqrt($0*$0 + $1*$1) }
}

// 아래는 간단히 double 배열의 계산을 편하게 하기 위한 함수들입니다.
// GPT가 거의 써줬죠 뭐.
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


