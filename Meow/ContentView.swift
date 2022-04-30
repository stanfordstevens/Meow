//
//  ContentView.swift
//  Meow
//
//  Created by Stanford Stevens on 4/30/22.
//

import SwiftUI

class MeowViewModel: ObservableObject {
    
}

struct MeowView: View {
    @ObservedObject var viewModel: MeowViewModel
    
    init(with viewModel: MeowViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Text("Hello, world!")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static let viewModel = MeowViewModel()

    static var previews: some View {
        MeowView(with: viewModel)
    }
}
