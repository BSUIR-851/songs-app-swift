//
//  VideoPickerView.swift
//  Songs
//
//  Created by Yura Morozov on 15.05.21.
//

import SwiftUI
import UIKit

struct VideoPickerView: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var videoNSURL: NSURL?
    
    func makeCoordinator() -> VideoPickerViewCoordinator {
        return VideoPickerViewCoordinator(videoNSURL: $videoNSURL, presentationMode: presentationMode)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = .photoLibrary
        pickerController.delegate = context.coordinator
        pickerController.mediaTypes = ["public.movie"]
        return pickerController
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // Nothing to update here
    }

}

class VideoPickerViewCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @Binding var presentationMode: PresentationMode
    @Binding var videoNSURL: NSURL?
    
    init(videoNSURL: Binding<NSURL?>, presentationMode: Binding<PresentationMode>) {
        self._presentationMode = presentationMode
        self._videoNSURL = videoNSURL
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let videoNSURL = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL {
            self.videoNSURL = videoNSURL
        }
        $presentationMode.wrappedValue.dismiss()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        $presentationMode.wrappedValue.dismiss()
    }
    
}

//struct VideoPickerView_Previews: PreviewProvider {
//    static var previews: some View {
//        VideoPickerView()
//    }
//}
