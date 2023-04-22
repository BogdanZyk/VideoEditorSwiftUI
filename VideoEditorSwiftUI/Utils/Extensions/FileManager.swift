//
//  FileManager.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 20.04.2023.
//

import Foundation
import UIKit

extension FileManager{
    
    
    func createImagePath(with id: String) -> URL?{
        guard let url = self.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(id).jpg") else { return nil}
        return url
    }
    
    func createVideoPath(with name: String) -> URL?{
        guard let url = self.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(name) else { return nil}
        return url
    }
    
    func retrieveImage(with id: String) -> UIImage?{
        guard let url = createImagePath(with: id) else { return nil }
        do{
            let imageData = try Data(contentsOf: url)
            return UIImage(data: imageData)
        }catch{
            print("Error retrieve image", error.localizedDescription)
            return nil
        }
    }
    
    func saveImage(with id: String, image: UIImage){
        guard let url = createImagePath(with: id) else { return }
        if let data = image.jpegData(compressionQuality: 0.9){
            do{
               try data.write(to: url)
                print("success saved \(url)")
            }catch{
                print("Error to save image", error.localizedDescription)
            }
        }
    }
    
    func deleteImage(with id: String){
        guard let url = createImagePath(with: id) else { return }
        removefileExists(for: url)
    }
    
    func deleteVideo(with name: String){
        guard let url = createVideoPath(with: name) else { return }
        if fileExists(atPath: url.path){
            do{
                try removeItem(at: url)
            }catch{
                print("Error to remove item", error.localizedDescription)
            }
        }
    }
    
    func removefileExists(for url: URL){
        if fileExists(atPath: url.path){
            do{
                try removeItem(at: url)
            }catch{
                print("Error to remove item", error.localizedDescription)
            }
        }
    }
}
