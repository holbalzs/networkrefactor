//
//  NetworkLayerRefactTests.swift
//  NetworkLayerRefactTests
//
//  Created by Holló Balázs on 2023. 05. 02..
//

import XCTest
@testable import NetworkLayerRefact

final class NetworkLayerRefactTests: XCTestCase {

    func testExample() throws {
        let auth = Authenticator()
        let manager = NetworkManager(auth: auth)
        //manager.performAuthenticatedRequest(<#T##request: URLRequest##URLRequest#>, decodingType: <#T##Decodable.Protocol#>)
    }

}
