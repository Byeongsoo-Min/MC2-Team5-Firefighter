//
//  MainAPI.swift
//  Manito
//
//  Created by COBY_PRO on 2022/09/01.
//

import Foundation

struct MainAPI: MainProtocol {
    private let apiService: APIService
    
    init(apiService: APIService) {
        self.apiService = apiService
    }

    func fetchCommonMission() async throws -> DailyMission? {
        let request = MainEndPoint
            .fetchCommonMission
            .createRequest()
        return try await apiService.request(request)
    }
    
    func fetchManittoList() async throws -> ParticipatingRooms? {
        let request = MainEndPoint
            .fetchManittoList
            .createRequest()
        return try await apiService.request(request)
    }
}
