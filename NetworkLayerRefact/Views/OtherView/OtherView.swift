//
//  OtherView.swift
//  NetworkLayerRefact
//
//

import SwiftUI

struct OtherView: View {
    @ObservedObject var loginState: AppLoginState

    init(loginState: AppLoginState) {
        self.loginState = loginState
    }
    
    var body: some View {
        Text(" ")
            .onAppear {
                loginState.state = .loggedIn
            }
    }
}
