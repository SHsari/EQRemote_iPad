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
    
    func willBeChange(in index: Int) {
        activeFilter = filters[index]
        responseWillUpdate(at: index)
        filterView.setActiveIndex(index, allResponse[index])
    }
    
    func didChange() {
        responseUpdated()
        filterView.responseDidUpdate()
    }
    
    func touchesMoved(_ position: XYPosition) {
        activeFilter.setBindX(position.x)
        activeFilter.setBindY(position.y)
        activeFilter.updateResponse()
        responseUpdated()
        filterView.responseDidUpdate()
    }
    
    func sliderMoved(_ value: Double) {
        activeFilter.setBindZ(value)
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
        willBeChange(in: index)
        activeFilter.setNormX(normX)
        activeFilter.updateResponse()
        didChange()
    }
    func set(normY: Double, at index: Int) {
        willBeChange(in: index)
        activeFilter.setNormY(normY)
        activeFilter.updateResponse()
        didChange()
    }
    func set(normZ: Double, at index: Int) {
        willBeChange(in: index)
        activeFilter.setNormZ(normZ)
        activeFilter.updateResponse()
        didChange()
    }
    
    func set(bindX: Double, at index: Int) {
        willBeChange(in: index)
        activeFilter.setBindX(bindX)
        activeFilter.updateResponse()
        didChange()
    }
    func set(bindY: Double, at index: Int) {
        willBeChange(in: index)
        activeFilter.setBindY(bindY)
        activeFilter.updateResponse()
        responseUpdated()
        filterView.responseDidUpdate()
    }
    func set(bindZ: Double, at index: Int) {
        willBeChange(in: index)
        activeFilter.setBindZ(bindZ)
        activeFilter.updateResponse()
        didChange()
    }
    func setBind(xyz: XYZPosition, at index: Int) {
        willBeChange(in: index)
        activeFilter.setBindX(xyz.x)
        activeFilter.setBindY(xyz.y)
        activeFilter.setBindZ(xyz.z)
        activeFilter.updateResponse()
        didChange()
    }
    
    func setNorm(xyz: XYZPosition, at index: Int) {
        willBeChange(in: index)
        activeFilter.setNormX(xyz.x)
        activeFilter.setNormY(xyz.y)
        activeFilter.setNormZ(xyz.z)
        activeFilter.updateResponse()
        didChange()
    }
    func setBand(band: OneBand, at index: Int) {
        willBeChange(in: index)
        let filter = EQFilterClass.typeDict[band.type]!()
        filter.initialize(allResponse[index], norm[index], bind[index])
        filters[index] = filter
        let position = band.position
        filter.setBindX(position.x)
        filter.setBindY(position.y)
        filter.setBindZ(position.z)
        filter.updateResponse()
        didChange()
    }    
    
    func filterTypeChanged(at index: Int, type: FilterType) {
        willBeChange(in: index)
        let filter = EQFilterClass.typeDict[type]!()
        filter.initialize(allResponse[index], norm[index], bind[index])
        filters[index] = filter
        filter.updateResponse()
        didChange()
    }
    
    func handleOnOff(at index: Int, isOn: Bool) {
        if !isOn {
            rootResponse.dB = rootResponse.dB - allResponse[index].dB
        } else {
            rootResponse.dB = rootResponse.dB + allResponse[index].dB
        }
        filterView.masterGraphUpdate()
    }

    
    func setRootResponse() {
        let tmp = Response()
        for response in self.allResponse {
            tmp.dB = tmp.dB + response.dB
        }
        rootResponse.dB = tmp.dB
        filterView.masterGraphUpdate()
    }
}
