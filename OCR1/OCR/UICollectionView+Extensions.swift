//
//  UICollectionView+Extensions.swift
//  OCR
//
//  Created by dexiong on 2024/5/10.
//

import Foundation
import UIKit

extension CompatibleWrapper where Base == UICollectionView {
    
    /// indexPaths
    internal var indexPaths: [IndexPath] {
        var indexPaths: [IndexPath] = []
        for section in 0..<base.numberOfSections {
            for row in 0..<base.numberOfItems(inSection: section) {
                indexPaths.append(.init(row: row, section: section))
            }
        }
        return indexPaths
    }
    
    /// selectAllItems
    /// - Parameter animated: animated
    internal func selectAllItems(_ animated: Bool) {
        let visiables = base.indexPathsForVisibleItems
        let unvisiables = indexPaths.subtracting(visiables)
        visiables.forEach {
            base.selectItem(at: $0, animated: animated, scrollPosition: [])
        }
        UIView.performWithoutAnimation {
            unvisiables.forEach {
                base.selectItem(at: $0, animated: animated, scrollPosition: [])
            }
        }
    }
    
    /// deselectAllItems
    /// - Parameter animated: Bool
    internal func deselectAllItems(_ animated: Bool) {
        let visiables = base.indexPathsForVisibleItems
        let unvisiables = indexPaths.subtracting(visiables)
        visiables.forEach {
            base.deselectItem(at: $0, animated: animated)
            
        }
        UIView.performWithoutAnimation {
            unvisiables.forEach {
                base.deselectItem(at: $0, animated: animated)
            }
        }
    }
}
