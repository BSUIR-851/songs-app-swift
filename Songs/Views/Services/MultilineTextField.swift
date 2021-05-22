//
//  MultiLineTextField.swift
//  Songs
//
//  Created by Yura Morozov on 15.05.21.
//

import SwiftUI

struct MultilineTextField: View {
    
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(Color(UIColor.placeholderText))
                    .padding(.top, 8)
            }
            TextEditor(text: $text).padding(.leading, -4)
        }
    }
}

//struct MultilineTextField_Previews: PreviewProvider {
//    static var previews: some View {
//        MultilineTextField()
//    }
//}
