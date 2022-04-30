//
//  ContentView.swift
//  Meow
//
//  Created by Stanford Stevens on 4/30/22.
//

import SwiftUI

struct MeowView: View {
    @ObservedObject var viewModel: MeowViewModel
    
    init(with viewModel: MeowViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Button("Meow", action: viewModel.displayImage)
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static let viewModel = MeowViewModel()

    static var previews: some View {
        MeowView(with: viewModel)
    }
}
