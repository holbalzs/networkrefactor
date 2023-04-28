//
//  UrlWrapper.swift
//  PADDTDR
//
//  Created by Czigány Tamás on 15/12/2022.
//

import Foundation

struct UrlWrapper: Codable {

    var url: String?

    init(url: String? = nil) {
        self.url = url
    }
}
