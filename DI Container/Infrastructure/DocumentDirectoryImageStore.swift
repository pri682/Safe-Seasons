//
//  DocumentDirectoryImageStore.swift
//  SafeSeasons
//
//  SRP: file-based image storage in Documents. Single responsibility.
//

import Foundation
import UIKit

final class DocumentDirectoryImageStore: ImageStoring {
    private let fileManager: FileManager
    private let quality: CGFloat = 0.8

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    private var baseURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func saveImage(_ image: UIImage, forId id: UUID) -> Bool {
        guard let data = image.jpegData(compressionQuality: quality) else { return false }
        let url = baseURL.appendingPathComponent("\(id.uuidString).jpg")
        do {
            try data.write(to: url)
            return true
        } catch {
            return false
        }
    }

    func loadImageURL(forId id: UUID) -> URL? {
        let url = baseURL.appendingPathComponent("\(id.uuidString).jpg")
        return fileManager.fileExists(atPath: url.path) ? url : nil
    }
}
