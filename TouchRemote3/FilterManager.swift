//
//  FilterManager.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 9/25/24.
//

import Foundation

class FilterManager {
    
    var filterView = FilterView()
    var allResponse: [Response] = []
    var rootResponse = ResponseParent([])
    var pendingResp = defaultDoubleArray
    var activeResponse = Response()
    
    var filters: [EQFilterPrtc] = []
    var activeFilter: EQFilterPrtc = Peak()
    
    var norm: [XYZPosition] = []
    var bind: [XYZPosition] = []
    
    func initialize(storage: [OneBand], norm: [XYZPosition]) {
        for (i, band) in storage.enumerated() {
            let tmpBind = band.position
            let tmpNorm = norm[i]
            let response = Response()
            let filter = EQFilterClass.typeDict[band.type]!()
            self.norm.append(tmpNorm)
            self.bind.append(tmpBind)
            allResponse.append(response)
            filters.append(filter)
            filter.initialize(response, tmpNorm, tmpBind)
        }
        rootResponse = ResponseParent(allResponse)
        setRootResponse()
    }
    
    func setFilterView(view: FilterView) {
        self.filterView = view
        filterView.initialize(rootResponse)
    }
    
    
    
    
    func touchesBegan(at index: Int) {
        activeFilter = filters[index]
        responseWillUpdate(at: index)
        filterView.setActiveIndex(index, allResponse[index])
    }
    
    func touchesMoved(_ position: XYPosition) {
        activeFilter.setBindX(position.x)
        activeFilter.setBindY(position.y)
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
    
    private func responseWillUpdate(at index: Int) {
        activeResponse = allResponse[index]
        pendingResp = rootResponse.dB - activeResponse.dB
    }
    private func responseUpdated() {
        rootResponse.dB = pendingResp + activeResponse.dB
    }
    
    
    

    
    func set(normX: Double, at index: Int) {
        touchesBegan(at: index)
        activeFilter.setNormX(normX)
        activeFilter.updateResponse()
        responseUpdated()
        filterView.responseDidUpdate()
    }
    func set(normY: Double, at index: Int) {
        touchesBegan(at: index)
        activeFilter.setNormY(normY)
        activeFilter.updateResponse()
        responseUpdated()
        filterView.responseDidUpdate()
    }
    func set(normZ: Double, at index: Int) {
        touchesBegan(at: index)
        activeFilter.setNormZ(normZ)
        activeFilter.updateResponse()
        responseUpdated()
        filterView.responseDidUpdate()
    }
    func set(band: XYZPosition, at index: Int) {
        touchesBegan(at: index)
        activeFilter.setNormX(band.x)
        activeFilter.setNormY(band.y)
        activeFilter.setNormZ(band.z)
        activeFilter.updateResponse()
        responseUpdated()
        filterView.responseDidUpdate()
    }
    
    
    
    
    
    
    func filterTypeChanged(at index: Int, type: FilterType) {
        touchesBegan(at: index)
        let filter = EQFilterClass.typeDict[type]!()
        filter.initialize(allResponse[index], norm[index], bind[index])
        filters[index] = filter
        responseUpdated()
        filterView.responseDidUpdate()
    }
    
    func handleOnOff(at index: Int, isOn: Bool) {
        if !isOn {
            rootResponse.dB = rootResponse.dB - allResponse[index].dB
        } else {
            rootResponse.dB = rootResponse.dB + allResponse[index].dB
        }
        filterView.masterGraphUpdate()
    }
    
    
    
    private func setRootResponse() {
        let tmp = Response()
        for response in self.allResponse {
            tmp.dB = tmp.dB + response.dB
        }
        rootResponse.dB = tmp.dB
    }
}
