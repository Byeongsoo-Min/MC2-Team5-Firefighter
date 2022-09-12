//
//  DetailIngAPI.swift
//  Manito
//
//  Created by Mingwan Choi on 2022/09/04.
//

import Foundation

struct DetailIngAPI: DetailStartingProtocol {
    private let apiService: APIService
    private let environment: APIEnvironment
    
    init(apiService: APIService, environment: APIEnvironment) {
        self.apiService = apiService
        self.environment = environment
    }
    
    func requestStartingRoomInfo(roomId: String) async throws -> Room? {
        let request = DetailIngEndPoint
            .requestStartingRoomInfo(roomId: roomId)
            .createRequest(environment: environment)
        return try await apiService.request(request)
    }
    
    func requestWithFriends(roomId: String) async throws -> FriendList? {
        let request = DetailIngEndPoint
            .requestWithFriend(roomId: roomId)
            .createRequest(environment: environment)
        return try await apiService.request(request)
    }
}