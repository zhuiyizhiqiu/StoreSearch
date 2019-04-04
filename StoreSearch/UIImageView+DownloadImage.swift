//
//  UIImageView+DownloadImage.swift
//  StoreSearch
//
//  Created by 彭军涛 on 2019/4/3.
//  Copyright © 2019 彭军涛. All rights reserved.
//

import UIKit

extension UIImageView{
    func loadImage(url: URL) -> URLSessionDownloadTask{
        let session = URLSession.shared
        
        let downLoadTask = session.downloadTask(with: url) { [weak self] url, response, error in
            if error == nil,let url = url,let data = try? Data(contentsOf: url),let image = UIImage(data: data){
                DispatchQueue.main.async {
                    if let weakSelf = self{
                        weakSelf.image = image
                    }
                }
            }
        }
        downLoadTask.resume()
        return downLoadTask
    }
}
