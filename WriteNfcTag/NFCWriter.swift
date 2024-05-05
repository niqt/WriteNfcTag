//
//  NFCWriter.swift
//  WriteNfcTag
//
//  Created by Nicola De Filippo on 04/05/24.
//

import Foundation
import CoreNFC

@Observable
public class NFCWriter: NSObject, NFCNDEFReaderSessionDelegate {
    var startAlert = "Hold your iPhone near the tag."
    var session: NFCNDEFReaderSession?
    var urlToWrite = "https://www.nicoladefilippo.com"
    var textToWrite = "Hello World"
    
    public func write(url: String, text: String) {
        guard NFCNDEFReaderSession.readingAvailable else {
            print("Error")
            return
        }
        self.urlToWrite = url
        self.textToWrite = text
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session?.alertMessage = self.startAlert
        session?.begin()
    }
    
    public func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        // Read logic
    }
    
    public func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {

        guard tags.count == 1 else {
            session.invalidate(errorMessage: "Cannot Write More Than One Tag in NFC")
            return
        }
        let currentTag = tags.first!
        
        session.connect(to: currentTag) { error in
            
            guard error == nil else {
                session.invalidate(errorMessage: "cound not connect to NFC card")
                return
            }
            
            currentTag.queryNDEFStatus { status, capacity, error in
                
                guard error == nil else {
                    session.invalidate(errorMessage: "Write error")
                    return
                }
                
                switch status {
                    case .notSupported: 
                        session.invalidate(errorMessage: "Not Suported")
                    case .readOnly:
                        session.invalidate(errorMessage: "ReadOnly")
                    case .readWrite:
                    
                        let textPayload = NFCNDEFPayload.wellKnownTypeTextPayload(
                            string: self.textToWrite,
                            locale: Locale.init(identifier: "en")
                        )!
                        
                        let uriPayload = NFCNDEFPayload.wellKnownTypeURIPayload(
                            url: URL(string: self.urlToWrite)!
                        )!
                        
                        let messge = NFCNDEFMessage.init(
                            records: [
                                uriPayload,
                                textPayload
                            ]
                        )
                        currentTag.writeNDEF(messge) { error in
                            
                            if error != nil {
                                session.invalidate(errorMessage: "Fail to write nfc card")
                            } else {
                                session.alertMessage = "Successfully writtern"
                                session.invalidate()
                            }
                        }
                    
                    @unknown default:
                        session.invalidate(errorMessage: "unknown error")
                }
            }
        }
    }
    
    public func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
    }
    
    public func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("Session did invalidate with error: \(error)")
        self.session = nil
    }
}


