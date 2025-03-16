//
//  Response.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 9/11/24.
//

import Foundation

// 원래는 더블 배열로 하면 되는데,
// 이상한 욕심에 트리를 구현하고자 클래스로 선언해보았습니다.
class Response {
    weak var parent: ResponseChildDelegate?
    var dB = defaultDoubleArray
    func didUpdate() {
        parent?.childDidUpdate()
    }
}

protocol ResponseChildDelegate: ResponseParent {
    func childDidUpdate()
}

class ResponseParent: Response, ResponseChildDelegate {
    func childDidUpdate() {
        self.dB = child1.dB + child2.dB
        parent?.childDidUpdate()
    }
    
    var child1: Response
    var child2: Response
    
    init(_ array: [Response]) {
        let count = array.count
        if count == 0 {
            child1 = Response()
            child2 = Response()
        }
        else if count == 2 {
            child1 = array[0]
            child2 = array[1]
        } else {
            let half = count/2
            child1 = ResponseParent(Array(array[0..<half]))
            child2 = ResponseParent(Array(array[half..<count]))
        }
        super.init()
        child1.parent = self
        child2.parent = self
    }
}

// 요거 쓰나..?
class ResponseManager {
    var allResponse: [Response] = []
    var pending = defaultDoubleArray
    var rootResponse = ResponseParent([])
    var activeResponse = Response()
    
    init(allResponse: [Response]) {
        self.allResponse = allResponse
        self.rootResponse = ResponseParent(allResponse)
    }
    
    func changeWillBegin(at index: Int) {
        activeResponse = allResponse[index]
        pending = rootResponse.dB - activeResponse.dB
    }
    
    func responseDidUpdate() {
        rootResponse.dB = pending + activeResponse.dB
    }
    
}
