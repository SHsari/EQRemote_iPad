//
//  FilterManager.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 9/25/24.
//

import Foundation

class FilterManager {
    
    var filterView = FilterView()
    var responses: [Response] = []
    var rootResponse = Response()
    var pendingResponse = Response()
    var activeResponse = Response()
    
    var filters: [EQFilterPrtc] = []
    var activeFilter: EQFilterPrtc = Peak()
    
    var norm: [XYZPosition] = []
    var bind: [XYZPosition] = []
    
    func initialize(storage: [OneBand], bind: [XYZPosition]) {
        for (i, band) in storage.enumerated() {
            let tmpBind = bind[i]
            let tmpNorm = band.position
            let response = Response()
            let filter = EQFilterClass.typeDict[band.type]!()
            self.norm.append(tmpNorm)
            self.bind.append(tmpBind)
            responses.append(response)
            filters.append(filter)
            filter.initialize(response, tmpNorm, tmpBind)
        }
        setRootResponse()
    }
    
    func setFilterView(view: FilterView) {
        self.filterView = view
        filterView.initialize(rootResponse)
    }
    
    func changesBegan(_ index: Int) {
        activeFilter = filters[index]
        activeResponse = responses[index]
        pendingResponse.dB = rootResponse.dB - activeResponse.dB
        filterView.setActiveIndex(index, responses[index])
    }
    
    func touchesMoved(_ position: XYPosition) {
        activeFilter.setNormX(position.x)
        activeFilter.setNormY(position.y)
        activeFilter.updateResponse()
        responseUpdated()
        filterView.responseDidUpdate()
    }
    
    func sliderMoved(_ value: Double) {
        activeFilter.setNormZ(value)
        activeFilter.updateResponse()
        responseUpdated()
        filterView.responseDidUpdate()
    }
    
    func handleOnOff(at index: Int, isOn: Bool) {
        let response = responses[index]
        filterView.setActiveIndex(index, response)
        if !isOn {
            rootResponse.dB = rootResponse.dB - response.dB
        }
        else {
            rootResponse.dB = rootResponse.dB + response.dB
        }
        filterView.responseDidUpdate()
    }
    
    func filterTypeChanged(at index: Int, type: FilterType) {
        changesBegan(index)
        let filter = EQFilterClass.typeDict[type]!()
        filter.initialize(responses[index], norm[index], bind[index])
        filters[index] = filter
        responseUpdated()
        filterView.responseDidUpdate()
    }
    
    private func responseUpdated() {
        rootResponse.dB = pendingResponse.dB + activeResponse.dB
    }
    
    private func setRootResponse() {
        let tmp = Response()
        for response in self.responses {
            tmp.dB = tmp.dB + response.dB
        }
        rootResponse.dB = tmp.dB
    }
}
