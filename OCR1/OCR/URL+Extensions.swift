//
//  URL+Extensions.swift
//  OCR
//
//  Created by dexiong on 2024/5/8.
//

import Foundation

enum DirectoryHint {
    /// Specifies that the `URL` does reference a directory
    case isDirectory
    /// Specifies that the `URL` does **not** reference a directory
    case notDirectory
    /// Specifies that `URL` should check with the file system to determine whether it references a directory
    case checkFileSystem
    /// Specifies that `URL` should infer whether is references a directory based on whether it has a trialing slash
    case inferFromPath
}

extension URL: CompatibleValue {}
extension CompatibleWrapper where Base == URL {
    /// appending
    /// - Parameter path: String
    /// - Returns: URL
    internal func appending(pathComponent: String, directoryHint: DirectoryHint) -> URL {
        switch directoryHint {
        case .isDirectory:
            if #available(iOS 16.0, *) {
                return base.appending(path: pathComponent, directoryHint: .isDirectory)
            } else {
                return base.appendingPathComponent(pathComponent, isDirectory: true)
            }
        case .notDirectory:
            if #available(iOS 16.0, *) {
                return base.appending(path: pathComponent, directoryHint: .notDirectory)
            } else {
                return base.appendingPathComponent(pathComponent, isDirectory: false)
            }
        case .checkFileSystem:
            if #available(iOS 16.0, *) {
                return base.appending(path: pathComponent, directoryHint: .checkFileSystem)
            } else {
                return base.appendingPathComponent(pathComponent)
            }
        case .inferFromPath:
            if #available(iOS 16.0, *) {
                return base.appending(path: pathComponent, directoryHint: .inferFromPath)
            } else {
                return base.appendingPathComponent(pathComponent)
            }
        }
    }
}
