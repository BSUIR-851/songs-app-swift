//
//  SettingsView.swift
//  Songs
//
//  Created by Yura Morozov on 15.05.21.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var session: Session
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("role")) {
                    if session.getSongsUser()?.isAdmin == true {
                        Text("admin_role")
                    } else {
                        Text("user_role")
                    }
                }
                Section(header: Text("language")) {
                    Picker("language", selection: $session.settings.localization) {
                        Text("sys_lang")
                            .tag(LocaleSettings.system)
                        Text("en_lang")
                            .tag(LocaleSettings.en)
                        Text("ru_lang")
                            .tag(LocaleSettings.ru)
                    }
                    .pickerStyle(WheelPickerStyle())
                    .labelsHidden()
                    
                }
                
                Section(header: Text("font_size")) {
                    Slider(value: $session.settings.fontSize, in: CGFloat(Constants.startFontSizeRange)...CGFloat(Constants.endFontSizeRange))
                    HStack {
                        Text("font_size")
                        Text(": \(session.settings.fontSize, specifier: "%.2f")")
                    }
                }
                
                Section(header: Text("font")) {
                    Picker("font", selection: $session.settings.fontName) {
                        ForEach(UIFont.familyNames.sorted(), id: \.self) { family in
                            ForEach(UIFont.fontNames(forFamilyName: family), id: \.self) { name in
                                Text(name)
                                    .font(.custom(name, size: session.settings.fontSize))
                            }
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .labelsHidden()
                }
                
                Section(header: Text("general")) {
                    Section {
                        Button(action: {
                            session.destroy()
                        }) {
                            Text("log_out")
                        }
                    }
                }
            }
            .navigationBarTitle("settings", displayMode: .inline)
        }
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
