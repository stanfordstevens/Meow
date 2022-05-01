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

    func displayImage() {
        getPhotoPermissions { [weak self] accessGranted in
            guard let self = self,
                  accessGranted else { return }
            self.fetchImages()
        }
    }
    
    func fetchImages() {
//        let fetchOptions = PHFetchOptions()
//        let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
//        fetchResult.enumerateObjects { asset, index, pointer in
//            self.assetManager.requestImage(for: asset,
//                                           targetSize: CGSize(width: 150, height: 100),
//                                           contentMode: .aspectFit,
//                                           options: .none) { image, metadata in
//                    if let uiImage = image, let cgImage = uiImage.cgImage {
//                        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
//                        let request = VNClassifyImageRequest()
//                        try? requestHandler.perform([request])
//                        let results = request.results as! [VNClassificationObservation]
//                        // Filter the 1303 classification results, and use them in your app
//                        // in my case, fullfill promise with a wrapper object
//                        promise(.success(ClassifiedImage(imageIdentifier: asset.localIdentifier,
//                                        classifications: results.filter { $0.hasMinimumPrecision(0.9, forRecall: 0.0) }.map{
//                                            ($0.identifier, nil)
//                                            })))
//                    }
//
//                }
//        }
        let fetchOptions = PHFetchOptions()
        let assets = PHAsset.fetchAssets(with: fetchOptions)
        var catImages: [UIImage] = []
        
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
                
                guard let results = request.results, results.contains(where: { $0.labels.count > 0 }) else { return }
                catImages.append(image)

//                let request = VNClassifyImageRequest()
//                try? requestHandler.perform([request])
            }
        }
        
        DispatchQueue.main.async {
            self.image = catImages.randomElement()
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
