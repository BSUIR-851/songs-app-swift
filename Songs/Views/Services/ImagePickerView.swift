//
//  ImagePickerView.swift
//  Songs
//
//  Created by Yura Morozov on 15.05.21.
//

import SwiftUI
import UIKit

struct ImagePickerView: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var imageNSURL: NSURL?
    
    func makeCoordinator() -> ImagePickerViewCoordinator {
        return ImagePickerViewCoordinator(imageNSURL: $imageNSURL, presentationMode: presentationMode)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = .photoLibrary
        pickerController.delegate = context.coordinator
        pickerController.mediaTypes = ["public.image"]
        return pickerController
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // Nothing to update here
    }

}

class ImagePickerViewCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @Binding var presentationMode: PresentationMode
    @Binding var imageNSURL: NSURL?
    
    init(imageNSURL: Binding<NSURL?>, presentationMode: Binding<PresentationMode>) {
        self._presentationMode = presentationMode
        self._imageNSURL = imageNSURL
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageNSURL = info[UIImagePickerController.InfoKey.imageURL] as? NSURL {
            self.imageNSURL = imageNSURL
        }
        $presentationMode.wrappedValue.dismiss()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        $presentationMode.wrappedValue.dismiss()
    }
    
}

//struct ImagePickerView_Previews: PreviewProvider {
//    static var previews: some View {
//        ImagePickerView()
//    }
//}
