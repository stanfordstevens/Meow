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
    @Published var image: UIImage?
    @Published var shouldShowProgressView = true
    
    private var catImages: [UIImage] = []
    
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
        let fetchOptions = PHFetchOptions()
        let assets = PHAsset.fetchAssets(with: fetchOptions)
        catImages = []
        
        assets.enumerateObjects { asset, index, pointer in
            PHImageManager.default().requestImage(for: asset,
                                                     targetSize: CGSize(width: 450, height: 300),
                                                     contentMode: .aspectFit,
                                                     options: .none) { image, metadata in
                guard let image = image,
                        let cgImage = image.cgImage else { return }

                let requestHandler = VNImageRequestHandler(cgImage: cgImage)
                let request = VNRecognizeAnimalsRequest()
                try? requestHandler.perform([request])
                print("---------Image Processed----------")

                guard let results = request.results, results.contains(where: { $0.labels.count > 0 }) else { return }

                self.catImages.append(image)
                DispatchQueue.main.async {
                    self.shouldShowProgressView = false
                }
                print("---------ANIMAL FOUND----------")
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
