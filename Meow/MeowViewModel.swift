//
//  MeowViewModel.swift
//  Meow
//
//  Created by Stanford Stevens on 4/30/22.
//

import Foundation
import PhotosUI
import Vision

class MeowViewModel: ObservableObject {
    static let catLowerBound = 10
    
    @Published var image: UIImage?
    @Published var catImages: [UIImage] = []
    
    var progress: Double { Double(catImages.count) / Double(MeowViewModel.catLowerBound) }
    var shouldShowProgressView: Bool { catImages.count < MeowViewModel.catLowerBound }
    
    func meowPressed() {
        displayImage()
    }
    
    func viewAppeared() {
        getPhotoPermissions { [weak self] accessGranted in
            guard let self = self,
                  accessGranted else { return }
            self.fetchImages()
        }
    }
    
    func displayImage() {
        self.image = catImages.randomElement()
    }
    
    func fetchImages() {
        guard shouldShowProgressView else { return }

        let fetchOptions = PHFetchOptions()
        let assets = PHAsset.fetchAssets(with: fetchOptions)
        let targetSize = CGSize(width: UIScreen.main.bounds.size.width,
                                height: UIScreen.main.bounds.size.height / 2)

        assets.enumerateObjects { asset, index, pointer in
            PHImageManager.default().requestImage(for: asset,
                                                     targetSize: targetSize,
                                                     contentMode: .aspectFill,
                                                     options: .none) { image, metadata in
                guard let image = image,
                      let cgImage = image.cgImage else { return }
                
                let requestHandler = VNImageRequestHandler(cgImage: cgImage)
                let request = VNRecognizeAnimalsRequest()
                try? requestHandler.perform([request])
                
                guard let results = request.results else { return }
                
                for result in results where result.confidence > 0.8 {
                    let animals = result.labels
                    for animal in animals where animal.identifier == "Cat" {
                        DispatchQueue.main.async {
                            self.catImages.append(image)
                        }
                    }
                }
            }
        }
    }
    
    func getPhotoPermissions(with handler: @escaping (Bool) -> Void) {
        guard PHPhotoLibrary.authorizationStatus() != .authorized else {
            handler(true)
            return
        }
        
        PHPhotoLibrary.requestAuthorization { status in
            handler(status == .authorized)
        }
    }
}
