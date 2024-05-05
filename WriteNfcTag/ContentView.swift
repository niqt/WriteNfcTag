//
//  ContentView.swift
//  WriteNfcTag
//
//  Created by Nicola De Filippo on 04/05/24.
//

import SwiftUI
import CoreNFC

struct ContentView: View {
    @State var nfcWriter = NFCWriter()
    @State var textToWrite = ""
    @State var urlToWrite = ""
    
    var body: some View {
        VStack(spacing: 10) {
            TextField("Text to write", text: $textToWrite)
            TextField("Url to write", text: $urlToWrite)
            Button("Write NFC") {
                nfcWriter.write(url: urlToWrite, text: textToWrite)
            }.padding()
        }.padding()
    }
}

#Preview {
    ContentView()
}
