//
//  LoginView.swift
//  PADDTDR
//
//  Created by Holló Balázs on 2022. 07. 03..
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @ObservedObject var loginState: AppLoginState
    @State private var showSafari: Bool = false
    @StateObject private var loginViewModel: LoginViewModel
    @State private var showAppleLoginButton: Bool = false

    init(loginState: AppLoginState, loginViewModel: LoginViewModel) {
        self.loginState = loginState
        self._loginViewModel = StateObject(wrappedValue: loginViewModel)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    Button(action: {
                        showSafari.toggle()
                    }) {
                        Text("Alternative login for developers")
                    }
                    .fullScreenCover(isPresented: $showSafari, content: {
                        SFSafariViewWrapper(url: loginViewModel.startLoginFlow())
                            .statusBarHidden(true)
                    })
                    .onOpenURL { url in
                        print(url)
                        loginViewModel.exchangeCodeForToken(url)
                    }
                    .onChange(of: loginViewModel.isSuccessLogin, perform: { newStateValue in
                        withAnimation {
                            if newStateValue {
                                loginState.state = .loggedIn//.validAccess
                            }
                        }
                    })
                }
            }
            .padding(60)
        }
        .ignoresSafeArea()
    }
    
}
