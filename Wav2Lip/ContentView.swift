import SwiftUI

struct ContentView: View {
    @State private var videoURLForAudio: URL?
    @State private var videoURLForVideo: URL?
    @State private var showingVideoPickerForAudio = false
    @State private var showingVideoPickerForVideo = false
    @State private var audioProcessingStatus: ProcessingStatus?
    @State private var videoProcessingStatus: ProcessingStatus?
    
    enum ProcessingStatus {
        case success(String)
        case failure(String)
        case processing 
    }
    
    var body: some View {
        VStack {
            Group {
                if let videoURLForAudio = videoURLForAudio {
                    Text("Selected Audio Video: \(videoURLForAudio.lastPathComponent)")
                        .font(.headline)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    if audioProcessingStatus == nil {
                        styledButton(text: "Process Video for Audio", action: {
                            preprocessAndExtractAudio(from: videoURLForAudio)
                        })
                    } else {
                        statusMessage(audioProcessingStatus)
                    }
                } else {
                    styledButton(text: "Select Video for Audio", action: {
                        showingVideoPickerForAudio = true
                    })
                }
            }
            .padding(.bottom)
            
            Group {
                if let videoURLForVideo = videoURLForVideo {
                    Text("Selected Content Video: \(videoURLForVideo.lastPathComponent)")
                        .font(.headline)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    if videoProcessingStatus == nil {
                        styledButton(text: "Process Video for Video", action: {
                            preprocessVideo(from: videoURLForVideo)
                        })
                    } else {
                        statusMessage(videoProcessingStatus)
                    }
                } else if audioProcessingStatus?.isSuccess == true {
                    styledButton(text: "Select Video for Video", action: {
                        showingVideoPickerForVideo = true
                    })
                }
            }
        }
        .sheet(isPresented: $showingVideoPickerForAudio) {
            VideoPicker(selectedVideoURL: $videoURLForAudio)
        }
        .sheet(isPresented: $showingVideoPickerForVideo) {
            VideoPicker(selectedVideoURL: $videoURLForVideo)
        }
    }
    
    private func styledButton(text: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(text)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(10)
        }
        .padding(.horizontal)
    }
    
    private func statusMessage(_ status: ProcessingStatus?) -> some View {
        Group {
            switch status {
            case .success(let message):
                Text(message)
                    .foregroundColor(.green)
                    .padding()
            case .failure(let message):
                Text(message)
                    .foregroundColor(.red)
                    .padding()
            case .processing:
                HStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Text("Processing...")
                }
                .padding()
            case .none:
                EmptyView()
            }
        }
        .transition(.opacity)
        .animation(.default)
    }
    
    private var audioProcessingStatusMessage: String {
        switch audioProcessingStatus {
        case .success(let path):
            return "Audio processing successful: \(path)"
        case .failure(let message):
            return "Audio processing failed: \(message)"
        case .processing:
            return "Processing audio..."
        case .none:
            return ""
        }
    }
    
    private var videoProcessingStatusMessage: String {
        switch videoProcessingStatus {
        case .success(let path):
            return "Video processing successful: \(path)"
        case .failure(let message):
            return "Video processing failed: \(message)"
        case .processing:
            return "Processing video..."
        case .none:
            return ""
        }
    }
    
    private func preprocessAndExtractAudio(from videoURL: URL) {
        audioProcessingStatus = .processing
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let outputURL = documentDirectory.appendingPathComponent("extractedAudio.wav")
        
        AudioExtractor.extractAudioAsWAV(from: videoURL, outputURL: outputURL) { result in
            switch result {
            case .success(let url):
                self.audioProcessingStatus = .success(url.lastPathComponent)
            case .failure(let error):
                self.audioProcessingStatus = .failure(error.localizedDescription)
            }
        }
    }
    
    
    private func preprocessVideo(from videoURL: URL) {
        videoProcessingStatus = .processing
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let outputURL = documentDirectory.appendingPathComponent("convertedVideo2.mp4")
        
        VideoPreprocessor.convertMOVToMP4(sourceURL: videoURL, outputURL: outputURL) { result in
            switch result {
            case .success(let url):
                self.videoProcessingStatus = .success(url.lastPathComponent)
            case .failure(let error):
                self.videoProcessingStatus = .failure(error.localizedDescription)
            }
        }
    }
}

extension ContentView.ProcessingStatus {
    var isSuccess: Bool {
        if case .success = self {
            return true
        }
        return false
    }
}
