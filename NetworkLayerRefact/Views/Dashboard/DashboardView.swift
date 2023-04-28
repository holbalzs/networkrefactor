//
//  DashboardView.swift
//  NetworkLayerRefact
//
//  Created by Holló Balázs on 2023. 04. 28..
//

import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.countries, id: \.countryCode) { country in
                    Text(country.countryCode)
                }
                
                ForEach(viewModel.languages, id: \.id) { language in
                    Text(language.languageCode)
                }
            }
            .onAppear {
                viewModel.loadingLanguages()
            }
        }
    }
}

