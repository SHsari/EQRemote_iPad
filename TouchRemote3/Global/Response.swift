//
//  Response.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 9/11/24.
//

import Foundation

var allResponses: [Response] = [Response(), Response(), Response(), Response(), Response(), Response(), Response(), Response()]
var combinedResponse = Response()

protocol ResponseParent: Response{
    func childDidUpdate()
}
protocol ResponseChild: Response{
    var dB: [Double] {get}
    func setTree(_ array: [Response], _ parent: Response?)
}

class Response: ResponseParent, ResponseChild {
    var dB = defaultDoubleArray
    weak var parent: ResponseParent?
    private var child1: ResponseChild?
    private var child2: ResponseChild?
    
    init(dB: [Double] = defaultDoubleArray) {
        self.dB = dB
    }
    func setResponseDefault() {
        dB = defaultDoubleArray
        parent?.childDidUpdate()
    }
    func leafDidUpdate() {
        parent?.childDidUpdate()
    }
    func childDidUpdate() {
        dB = child1! + child2!
        parent?.childDidUpdate()
    }
    
    func setTree(_ array: [Response], _ parent: Response?) {
        if let parent = parent {
            self.parent = parent
        }
        let arraySize = array.count
        if arraySize == 2 {
            child1 = array[0]
            child1?.parent = self
            child2 = array[1]
            child2?.parent = self
        } else {
            let midPoint = arraySize/2
            child1 = Response()
            child2 = Response()
            child1!.setTree(Array(array[0..<midPoint]), self)
            child2!.setTree(Array(array[midPoint..<arraySize]), self)
        }
    }
    static func +(lhs: Response, rhs: Response) -> [Double]{
        return zip(lhs.dB, rhs.dB).map { $0 + $1 }
    }
}

