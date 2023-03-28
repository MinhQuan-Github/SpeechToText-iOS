//
//  ContentView.swift
//  SpeechToText
//
//  Created by Minh Quan on 25/03/2023.
//

import SwiftUI
import UIKit
import AVKit
import ProgressHUD

struct ContentView: View {
    var body: some View {
        Home()
            .preferredColorScheme(.dark)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Home : View {
    
    @State var record = false
    @State var session : AVAudioSession!
    @State var recorder : AVAudioRecorder!
    @State var alert = false
    @State var audios : [URL] = []
    @State var apiResult: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                List(self.audios,id: \.self){i in
                    VStack {
                        Button(action: {
                            do {
                                guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                                let recordingURL = documentsDirectory.appendingPathComponent(String(i.relativeString.split(separator: "/").last ?? ""))
                                let recordingData = try Data(contentsOf: recordingURL)
                                uploadFile(recordingData: recordingData) { result in
                                    self.apiResult = result
                                }
                            } catch {
                                print(error.localizedDescription)
                                ProgressHUD.dismiss()
                            }
                        }) {
                            Text(i.relativeString.split(separator: "/").last ?? "")
                        }
                    }
                }.padding()
                HStack {
                    Text("API Result:")
                    TextField("...", text: $apiResult)
                        .disabled(true)
                        .padding()
                        .foregroundColor(.white)
                }.padding(20)
                
                    
                Button(action: {
                    do {
                        if self.record {
                            ProgressHUD.dismiss()
                            self.recorder.stop()
                            self.record.toggle()
                            self.getAudios()
                            
                            return
                        }
                        ProgressHUD.animationType = .lineScaling
                        ProgressHUD.show("Recording...")
//                        ProgressHUD.show("Please waiting...", icon: .moon, delay: 2.0)
                        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        let filName = url.appendingPathComponent("myRcd\(self.audios.count + 1).m4a")
                        
                        let settings = [
                            AVFormatIDKey : Int(kAudioFormatMPEG4AAC),
                            AVSampleRateKey : 12000,
                            AVNumberOfChannelsKey : 1,
                            AVEncoderAudioQualityKey : AVAudioQuality.high.rawValue
                        ]
                        
                        self.recorder = try AVAudioRecorder(url: filName, settings: settings)
                        self.recorder.record()
                        self.record.toggle()
                    }
                    catch {
                        print(error.localizedDescription)
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 70, height: 70)
                        
                        if self.record{
                            
                            Circle()
                                .stroke(Color.white, lineWidth: 6)
                                .frame(width: 85, height: 85)
                        }
                    }
                }
                .padding(.vertical, 25)
            }
            .navigationBarTitle("Record Audio")
        }
        .alert(isPresented: self.$alert, content: {
            Alert(title: Text("Error"), message: Text("Enable Acess"))
        })
        .onAppear {
            do {
                self.session = AVAudioSession.sharedInstance()
                try self.session.setCategory(.playAndRecord)
                self.session.requestRecordPermission { (status) in
                    
                    if !status {
                        self.alert.toggle()
                    }
                    else {
                        self.getAudios()
                    }
                }
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func getAudios(){
        do {
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let result = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .producesRelativePathURLs)
            self.audios.removeAll()
            for i in result{
                self.audios.append(i.absoluteURL)
            }
            print(self.audios)
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func getTime() -> String {
        return "\(Date().timeIntervalSince1970)"
    }
}
