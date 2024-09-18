//
//  Response.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 9/11/24.
//

import Foundation

var allResponse: [Response] = [Response(), Response(), Response(), Response(), Response(), Response(), Response(), Response()]
var rootResponse = ResponseParent(allResponse)

protocol ResponseChildDelegate: Response {
    func childDidUpdate()
}

class Response {
    var parent: ResponseChildDelegate?
    var dB = defaultDoubleArray
    func responseDidUpdate() {
        parent?.childDidUpdate()
    }
}

class ResponseParent: Response, ResponseChildDelegate {
    var child1: Response
    var child2: Response

    func childDidUpdate() {
        self.dB = child1.dB + child2.dB
        parent?.childDidUpdate()
    }
    init(_ array: [Response]) {
        let count = array.count
        if count == 2 {
            child1 = array[0]
            child2 = array[1]
        } else {
            let midIndex = count/2
            child1 = ResponseParent(Array(array[0..<midIndex]))
            child2 = ResponseParent(Array(array[midIndex..<count]))
        }
        super.init()
        child1.parent = self
        child2.parent = self
    }
}
