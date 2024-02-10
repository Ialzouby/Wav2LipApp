//
//  videopreprocessor.swift
//  Wav2Lip
//
//  Created by Issam Alzouby on 2/9/24.
//

import Foundation
import AVFoundation

class VideoPreprocessor {
    static func convertMOVToMP4(sourceURL: URL, outputURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let asset = AVURLAsset(url: sourceURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
            completion(.failure(NSError(domain: "VideoPreprocessor", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not create AVAssetExportSession"])))
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true
        
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                completion(.success(outputURL))
            case .failed:
                if let error = exportSession.error {
                    completion(.failure(error))
                } else {
                    completion(.failure(NSError(domain: "VideoPreprocessor", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unknown failure"])))
                }
            case .cancelled:
                completion(.failure(NSError(domain: "VideoPreprocessor", code: 2, userInfo: [NSLocalizedDescriptionKey: "Export cancelled"])))
            default:
                break
            }
        }
    }
}


// Assuming you have a URL to a .mov file and an output URL for the .mp4 file
//let sourceURL: URL = ... // Your source .mov URL
//let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//let outputURL = documentsDirectory.appendingPathComponent("output.mp4")

//VideoPreprocessor.convertMOVToMP4(sourceURL: sourceURL, outputURL: outputURL) { result in
  //  DispatchQueue.main.async {
    //    switch result {
     //   case .success(let url):
      //      print("Video converted successfully: \(url)")
        // Update your UI or proceed with the next step here
      //  case .failure(let error):
      //      print("Video conversion failed: \(error.localizedDescription)")
            // Handle error
   //     }
 //   }
//}

