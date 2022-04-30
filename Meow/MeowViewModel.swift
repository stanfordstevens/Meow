//
//  MeowViewModel.swift
//  Meow
//
//  Created by Stanford Stevens on 4/30/22.
//

import Foundation
import PhotosUI

class MeowViewModel: ObservableObject {
    func displayImage() {
        getPhotoPermissions { accessGranted in
            guard accessGranted else { return }
            
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
