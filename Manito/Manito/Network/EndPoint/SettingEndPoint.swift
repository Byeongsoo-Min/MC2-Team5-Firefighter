//
//  SettingEndPoint.swift
//  Manito
//
//  Created by Mingwan Choi on 2022/07/12.
//

import Foundation

enum SettingEndPoint: EndPointable {
    case editUserInfo(nickName: String)

    var requestTimeOut: Float {
        return 20
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .editUserInfo:
            return .put
        }
    }

    var requestBody: Data? {
        switch self {
        case .editUserInfo(let nickName):
            let body = ["nickName": nickName]
            return body.encode()
        }
    }

    func getURL(baseURL: String) -> String {
        switch self {
        case .editUserInfo(_):
            return "\(baseURL)/api/user"
        }
    }
}