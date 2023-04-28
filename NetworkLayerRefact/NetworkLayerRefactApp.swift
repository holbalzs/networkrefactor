//
//  NetworkLayerRefactApp.swift
//  NetworkLayerRefact
//

import SwiftUI

@main
struct NetworkLayerRefactApp: App {
    @StateObject var loginState = AppLoginState()
    
    var body: some Scene {
        WindowGroup {
            switch loginState.state {
            case .none, .expired:
                LoginView(
                    loginState: loginState,
                    loginViewModel: LoginViewModel(networkManager: loginState.serviceRoot.networkManager)
                )
            case .validRefresh, .validAccess:
                OtherView(loginState: loginState)
                /*LoaderStartView(loaderViewModel: LoaderStartViewModel(state: loginState.state, socket: loginState.serviceRoot.socketService))
                    .environmentObject(loginState)*/
            case .loggedIn:
                DashboardView(viewModel: DashboardViewModel(networkManager: loginState.serviceRoot.networkManager))
                /*ContentView(
                    propertyLayout: PropertyLayoutSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height).layout,
                    dashboardViewModel: DashboardViewModel(networkManager: NetworkManager(), socketService: loginState.serviceRoot.socketService), serviceRoot: loginState.serviceRoot, appRouter: appRouter)
                    .statusBar(hidden: true)
                    .environmentObject(loginState)*/
            case .profileFinished:
                EmptyView()
            }
        }
    }
}

class ServiceRoot/*: ObservableObject*/ {
    let auth = Authenticator()
    
    lazy var networkManager: NetworkManager = {
        let manager = NetworkManager(auth: auth)
        return manager
    }()
    
//    lazy var socketService: StompSocketService = {
//        let socket = StompSocketService(auth: auth)
//        return socket
//    }()
}

class AppLoginState: ObservableObject {
    @Published var state: TokenState = .none
    let serviceRoot: ServiceRoot

    init() {
        serviceRoot = ServiceRoot()
        serviceRoot.auth.reLogin = relogin
        self.state = serviceRoot.auth.getTokenState()
    }
    
    func logout() {
        serviceRoot.auth.logoutFrom {
            NotificationCenter.default.post(name: NSNotification.Name("disconecctionFromChat"), object: nil, userInfo: nil)
            self.state = .none
        }
    }
    
    func getAccessToken() -> String? {
        return serviceRoot.auth.getAccessToken()
    }
    
    private func relogin() {
        DispatchQueue.main.async {            
            self.state = .none
        }
    }
}


