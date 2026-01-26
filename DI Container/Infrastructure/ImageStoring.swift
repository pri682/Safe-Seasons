//
//  ImageStoring.swift
//  SafeSeasons
//
//  SRP: image persistence only. DIP: depend on this protocol, not FileManager.
//

import Foundation
import UIKit

protocol ImageStoring: AnyObject {
    func saveImage(_ image: UIImage, forId id: UUID) -> Bool
    func loadImageURL(forId id: UUID) -> URL?
}
