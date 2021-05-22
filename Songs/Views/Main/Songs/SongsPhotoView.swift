//
//  SongsImageView.swift
//  Songs
//
//  Created by Yura Morozov on 15.05.21.
//

import SwiftUI
import URLImage

struct SongsPhotoView: View {
    
    let url: URL?
    let size: CGFloat
    
    init(_ urlString: String?, _ size: CGFloat) {
        if let photoURLString = urlString,
           let photoURL = URL(string: photoURLString) {
            url = photoURL
        } else {
            if urlString != nil {
                print("Unable to process SongsPhotoView urlString")
            }
            url = nil
        }
        
        self.size = size
    }
    
    var placeholderPhoto: some View {
        Image(systemName: "applelogo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .scaleEffect(0.5)
            .frame(width: size, height: size)
    }
    
    var body: some View {
        if let url = url {
            URLImage(url: url,
                     empty: {
                        placeholderPhoto
                     },
                     inProgress: { _ in
                        placeholderPhoto
                     },
                     failure: { _, _ in
                        placeholderPhoto
                     },
                     content: { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size, height: size)
                            .clipShape(Circle())
                     }
            )
        } else {
            placeholderPhoto
        }
    }
}

struct SongsPhotoView_Previews: PreviewProvider {
    static var previews: some View {
        SongsPhotoView(nil, 50)
    }
}
