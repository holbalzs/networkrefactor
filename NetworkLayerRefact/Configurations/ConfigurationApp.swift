//
//  Configuration.swift
//  PADDTDR
//
//  Created by Holló Balázs on 2022. 05. 29..
//

import Foundation

enum EnvironmentApp: String {
    case dev
    case local
}

enum ConfigurationApp {
    enum API {
        static var apiURL: String {
            return "https://tdrdev.rrsoftware.hu"
        }

        static var keyCloak: String {
            return "https://tdrdev.rrsoftware.hu"
        }

        static var socketURL: String {
            return "wss://tdrdev.rrsoftware.hu/ws"
        }
    }
}
