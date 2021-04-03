//
//  fileManager.swift
//  twak
//
//  Created by Archana on 02/04/21.
//

import Foundation
class FilePathManager: NSObject {
    /// product image directory path
    static let ProfileImg = "/ProfileImg"
    /**
     create the app directory for given path if its present returns the whole path to access file
     - Parameter directory: directory path
     - Precondition: it will returns empty string if file not found
     - Returns: path of directory
     */
    static func createAppDirectory(forDirectory directory: String ) -> String {
        let fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] as String
        let dirPath = (paths as NSString).appendingPathComponent("/twak")
        if !fileManager.fileExists(atPath: dirPath) {
            do {
                try fileManager.createDirectory(atPath: dirPath as String, withIntermediateDirectories: false, attributes: nil)
            } catch {
                return ""
            }
        }
        let subdirPath = (dirPath as NSString).appendingPathComponent(directory)
        if !fileManager.fileExists(atPath: subdirPath) {
            do {
                try fileManager.createDirectory(atPath: subdirPath as String, withIntermediateDirectories: false, attributes: nil)
                return subdirPath as String
            } catch {
                return ""
            }
        } else {
            return subdirPath as String
        }
    }
    static func getcatchDirectory() -> URL{
        let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return cachesURL.appendingPathComponent("MediaDownloadCache")
    }
    /**
     check is the file present in app directory
     - Parameter fileName: name of file
     - Precondition: it will returns empty string if file not found
     - Returns: path for file
     */
    static func checkFileIsPresent(_ fileName: String) -> String? {
        let dirPath = createAppDirectory(forDirectory: ProfileImg)
        if !dirPath.isEmpty {
            let subdirPath = (dirPath as NSString).appendingPathComponent(fileName)
            if FileManager.default.fileExists(atPath: subdirPath) {
                return subdirPath
            }
        }
        return nil
    }
    /**
     creates destination url for the file
     - Parameter PKey: file name
     - Returns: path url
     */
    static func destinationURL(forId PKey: String) -> URL {
        return URL(fileURLWithPath: (createAppDirectory(forDirectory: ProfileImg))).appendingPathComponent(PKey)
    }
    /**
     move file from url to the app directory
     - Parameter fileName: name of file
     fromUrl: temp url of file
     - Returns: returns true if file moved to app directory successfully
     */
    static func moveFile(_ fileName: String, fromUrl: URL) -> Bool {
        do {
            try FileManager.default.moveItem(at: fromUrl, to: destinationURL(forId: fileName))
            return true
        } catch {
            print(error)
            return false
        }
    }
    /**
     delete the file from app directory
     - Parameter fileName: name of file to be delete
     */
    static func deleteFile(_ fileName: String) {
        do {
            try FileManager.default.removeItem(at: destinationURL(forId: fileName))
        } catch {
        }
    }
    ///deltes all product images stored in app directory
    static func deleteProfileImages() {
        do {
            try FileManager.default.removeItem(atPath: createAppDirectory(forDirectory: ProfileImg))
        } catch let error as NSError {
            print("FileManager : deleteProductImages error \(error.localizedDescription)")
        } catch {
        }
    }
    
}
