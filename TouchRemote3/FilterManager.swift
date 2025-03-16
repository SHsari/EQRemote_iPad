//
//  FilterManager.swift
//  TouchRemote3
//
//  Created by Seokhyun Song on 9/25/24.
//

import Foundation
// Model에 해당합니다.
// 밴드가 8개, 각 밴드별로 타입을 설정할 수 있고,
// 타입에 맞는 EQFilter를 상속하는 클래스를 불러와서
// 그래프를 그리는 연산을 진행합니다.
class FilterManager {
    // 파라미터 업데이트에 따른 그래프 연산을 끝났으면, FilterView에게 알려야 합니다.
    var filterView = FilterView()
    // 그래프(주파수 응답 그래프라서 Response 입니다)
    var allResponse: [Response] = []
    // 1개 밴드를 변경할 시에 필요한 덧셈연산을 줄이기 위해 Tree형으로 구현(했었습니다.)
    var rootResponse = ResponseParent([])
    // 현재는 Tree를 이용한 덧셈연산이 아닌,
    // 파라미터 변경 시작시 변경되는 밴드의 그래프를 빼놓고 변경된 값을 더해주는 식으로 진행합니다.
    // 아무리 생각해도 비효율 적인 것 같네요.
    var pendingResp = defaultDoubleArray
    // 변경진행중인 그래프
    var activeResponse = Response()
    
    var filters: [EQFilterPrtc] = []
    var activeFilter: EQFilterPrtc = Peak()
    
    // 파라미터 기본값을 담은 배열입니다 mainVC에도 설명이 있습니다.
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
    
    // 특정 밴드에 변화가 시작되는 경우
    func willBeChange(in index: Int) {
        activeFilter = filters[index]
        responseWillUpdate(at: index)
        filterView.setActiveIndex(index, allResponse[index])
    }
    
    // 수시로 업데이트
    func didChange() {
        responseUpdated()
        filterView.responseDidUpdate()
    }
    
    // 특정밴드의 X, y값 업데이트 시
    func touchesMoved(_ position: XYPosition) {
        activeFilter.setBindX(position.x)
        activeFilter.setBindY(position.y)
        activeFilter.updateResponse()
        responseUpdated()
        filterView.responseDidUpdate()
    }
    
    // 특정 밴드의 Q값 업데이트 시
    func sliderMoved(_ value: Double) {
        activeFilter.setBindZ(value)
        activeFilter.updateResponse()
        responseUpdated()
        filterView.responseDidUpdate()
    }
    
    //
    private func responseWillUpdate(at index: Int) {
        activeResponse = allResponse[index]
        pendingResp = rootResponse.dB - activeResponse.dB
    }
    private func responseUpdated() {
        rootResponse.dB = pendingResp + activeResponse.dB
    }

    
    // 파라미터 개별 업데이트입니다.
    // norm과 bind 값은
    // norm은 0~1로 노멀라이즈 된 값.
    // bind는 실제 파라미터로 환산한 값입니다.
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
    
    // 특정 밴드의; 필터타입이 변경되었을 때 호출되는 함수
    func filterTypeChanged(at index: Int, type: FilterType) {
        willBeChange(in: index)
        let filter = EQFilterClass.typeDict[type]!()
        filter.initialize(allResponse[index], norm[index], bind[index])
        filters[index] = filter
        filter.updateResponse()
        didChange()
    }
    
    // on/off 스위치가 토글되었을 때 그래프에 반영하는 함수
    func handleOnOff(at index: Int, isOn: Bool) {
        if !isOn {
            rootResponse.dB = rootResponse.dB - allResponse[index].dB
        } else {
            rootResponse.dB = rootResponse.dB + allResponse[index].dB
        }
        filterView.masterGraphUpdate()
    }

    // 뭐였지 트리썼을때 사용한 함수인가.
    func setRootResponse() {
        let tmp = Response()
        for response in self.allResponse {
            tmp.dB = tmp.dB + response.dB
        }
        rootResponse.dB = tmp.dB
        filterView.masterGraphUpdate()
    }
}
