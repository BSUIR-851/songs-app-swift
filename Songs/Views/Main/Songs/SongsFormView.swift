//
//  SongsFormView.swift
//  Songs
//
//  Created by Yura Morozov on 15.05.21.
//

import SwiftUI
import URLImage
import AVKit


enum SongsFormViewSheet: Identifiable {
    case image, video, map
    
    var id: Int {
        hashValue
    }
}

struct SongsFormView: View {
    
    @EnvironmentObject var session: Session
    
    @Binding var isPresented: Bool
    
    @State var activeSheet: SongsFormViewSheet? = nil
    
    @State var progress: Bool = false
    
    @State var name: String
    @State var author: String
    @State var description: String
    @State var year: Int
    
    @State var photoNsUrl: NSURL?
    @State var videoNsUrl: NSURL?
    
    @State var releaseNote: String
    @State var releaseLatitude: Double?
    @State var releaseLongitude: Double?
    
    let assetToEdit: SongsAsset?
    let additionalOnDeleteAction: (() -> Void)?
    
    // Init as creator
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        self.assetToEdit = nil
        self.additionalOnDeleteAction = nil
        
        self._name = State(initialValue: "")
        self._author = State(initialValue: "")
        self._description = State(initialValue: "")
        self._year = State(initialValue: 2021)
        self._photoNsUrl = State(initialValue: nil)
        self._videoNsUrl = State(initialValue: nil)
        
        self._releaseNote = State(initialValue: "")
        self._releaseLatitude = State(initialValue: nil)
        self._releaseLongitude = State(initialValue: nil)
    }
    
    // Init as editor
    init(assetToEdit: SongsAsset, onDelete: @escaping () -> Void, isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        self.assetToEdit = assetToEdit
        self.additionalOnDeleteAction = onDelete
        
        self._name = State(initialValue: assetToEdit.name)
        self._author = State(initialValue: assetToEdit.author)
        self._description = State(initialValue: assetToEdit.description)
        self._year = State(initialValue: assetToEdit.year)
        
        if let photoFileData = assetToEdit.photoFileData {
            self._photoNsUrl = State(initialValue: NSURL(string: photoFileData.downloadURL))
        } else {
            self._photoNsUrl = State(initialValue: nil)
        }
        
        if let videoFileData = assetToEdit.videoFileData {
            self._videoNsUrl = State(initialValue: NSURL(string: videoFileData.downloadURL))
        } else {
            self._videoNsUrl = State(initialValue: nil)
        }
        
        if let releaseData = assetToEdit.release {
            self._releaseNote = State(initialValue: releaseData.note)
            self._releaseLatitude = State(initialValue: releaseData.latitude)
            self._releaseLongitude = State(initialValue: releaseData.longitude)
        } else {
            self._releaseNote = State(initialValue: "")
            self._releaseLatitude = State(initialValue: nil)
            self._releaseLongitude = State(initialValue: nil)
        }
    }
    
    func validateEditedAsset() -> Bool {
        if (
            name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                author.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ) {
            return false
        }
        
        return true
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Form {
                    Section(header: Text("photo")) {
                        Button {
                            activeSheet = .image
                        } label: {
                            HStack {
                                Text("select")
                                Spacer()
                                
                                if let photoURL = photoNsUrl?.absoluteURL {
                                    URLImage(url: photoURL) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 60, height: 60)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.secondary, lineWidth: 2))
                                            .padding(.all, 10)
                                    }
                                }
                            }
                        }
                        
                        if photoNsUrl != nil {
                            Button {
                                withAnimation {
                                    photoNsUrl = nil
                                }
                            } label: {
                                HStack {
                                    Text("remove")
                                    Spacer()
                                }
                                .foregroundColor(.red)
                            }
                        }
                    }
                    
                    Section(header: Text("general").padding(.top)) {
                        TextField("name", text: $name)
                            .disableAutocorrection(true)
                        TextField("author", text: $author)
                            .disableAutocorrection(true)
                        TextField("description", text: $description)
                        Picker("Year", selection: $year) {
                            ForEach(Constants.startYearRange...Constants.endYearRange, id:\.self) { i in
                                Text(String(i))
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                    }
            
                    Section(header: Text("video")) {
                        Button {
                            activeSheet = .video
                        } label: {
                            HStack {
                                Text("select")
                                Spacer()
                            }
                        }
                        
                        if let url = videoNsUrl?.absoluteURL {
                            let videoPlayer: AVPlayer = AVPlayer(url: url)
                            
                            VideoPlayer(player: videoPlayer)
                                .aspectRatio(16.0/9.0, contentMode: .fit)
                            
                            Button {
                                videoPlayer.pause()
                                videoPlayer.replaceCurrentItem(with: nil)
                                
                                withAnimation {
                                    videoNsUrl = nil
                                }
                            } label: {
                                HStack {
                                    Text("remove")
                                    Spacer()
                                }
                                .foregroundColor(.red)
                            }
                        }
                    }
                    
                    Section(header: Text("release")) {
                        Button {
                            activeSheet = .map
                        } label: {
                            HStack {
                                Text("pick_location")
                                Spacer()
                            }
                        }
                        
                        if let releaseLatitude = releaseLatitude,
                           let releaseLongitude = releaseLongitude {
                            HStack {
                                Text("latitude")
                                Spacer()
                                Text(String(releaseLatitude))
                            }
                            .foregroundColor(.secondary)
                            
                            HStack {
                                Text("longitude")
                                Spacer()
                                Text(String(releaseLongitude))
                            }
                            .foregroundColor(.secondary)
                            
                            TextField("note", text: $releaseNote)
                            
                            Button {
                                withAnimation {
                                    self.releaseNote = ""
                                    self.releaseLatitude = nil
                                    self.releaseLongitude = nil
                                }
                            } label: {
                                HStack {
                                    Text("remove")
                                    Spacer()
                                }
                                .foregroundColor(.red)
                            }
                        }
                    }
                    
                    if let assetToEdit = assetToEdit {
                        Section {
                            Button {
                                withAnimation {
                                    progress = true
                                }
                                
                                print("Deleting \(assetToEdit)")
                                
                                session.deleteRemoteAsset(asset: assetToEdit) { (error) in
                                    progress = false
                                    
                                    if error == nil {
                                        additionalOnDeleteAction?()
                                        isPresented.toggle()
                                    }
                                }
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("delete")
                                    Spacer()
                                }
                            }
                            .foregroundColor(.red)
                        }
                    }
                }
                .navigationBarTitle(assetToEdit != nil ? "edit_song" : "new_song", displayMode: .inline)
                .sheet(item: $activeSheet) { item in
                    switch item {
                    case .image:
                        ImagePickerView(imageNSURL: $photoNsUrl)
                    case .video:
                        VideoPickerView(videoNSURL: $videoNsUrl)
                    case .map:
                        GoogleMapsLocationPickerView(latitude: $releaseLatitude, longitude: $releaseLongitude)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("back") {
                            isPresented.toggle()
                        }
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button("save") {
                            withAnimation {
                                progress = true
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                let release: SongsMapRelease?
                                if let releaseLatitude = releaseLatitude,
                                   let releaseLongitude = releaseLongitude {
                                    release = SongsMapRelease(note: releaseNote, latitude: releaseLatitude, longitude: releaseLongitude)
                                } else {
                                    release = nil
                                }
                                
                                let asset = SongsAsset(
                                    id: assetToEdit?.id ?? UUID().uuidString,
                                    name: name,
                                    author: author,
                                    description: description,
                                    year: year,
                                    photoFileData: assetToEdit?.photoFileData,
                                    videoFileData: assetToEdit?.videoFileData,
                                    release: release
                                )
                                
                                session.updateRemoteAsset(asset: asset, photoNSURL: photoNsUrl, videoNSURL: videoNsUrl) { (error) in
                                    progress = false
                                    
                                    if error == nil {
                                        isPresented.toggle()
                                    }
                                }
                            }
                        }
                        .disabled(!validateEditedAsset())
                    }
                }
                
                if progress {
                    ProgressView()
                }
            }
        }
        .allowsHitTesting(!progress)
    }
}


//struct SongsFormView_Previews: PreviewProvider {
//    static var previews: some View {
//        SongsFormView()
//    }
//}
