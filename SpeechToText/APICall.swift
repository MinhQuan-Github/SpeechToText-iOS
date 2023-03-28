//
//  APICall.swift
//  SpeechToText
//
//  Created by Minh Quan on 28/03/2023.
//

import Alamofire
import ProgressHUD

func uploadFile(recordingData: Data, success: @escaping(String) -> ()) {
    ProgressHUD.animationType = .systemActivityIndicator
    ProgressHUD.show("Please wait...")
    let urlString = "http://116.110.243.209:5000/api/upload/"
    let headers: HTTPHeaders = [
        "Content-type": "multipart/form-data"
    ]
    Alamofire.upload(multipartFormData: { multipartFormData in
        multipartFormData.append(recordingData, withName: "file", fileName: "recording.m4a", mimeType: "audio/m4a")
    }, to: urlString, headers: headers, encodingCompletion: { result in
        switch result {
        case.success(let upload, _, _):
            print("ok")
            upload.responseJSON { response in
                let responseValue = response.result.value
                if responseValue != nil {
                    if responseValue is [String: Any] {
                        let data = responseValue as! [String: Any]
                        success(data["result"] as? String ?? "")
                    }
                }
                ProgressHUD.dismiss()
            }
        case .failure(let e):
            print(e.localizedDescription)
        }
    })
}
