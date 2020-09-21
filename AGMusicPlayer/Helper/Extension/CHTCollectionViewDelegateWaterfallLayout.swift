import Foundation
import UIKit
private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

private func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

@objc public protocol CHTCollectionViewDelegateWaterfallLayout: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                                       heightForHeaderInSection section: Int) -> CGFloat
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                                       heightForFooterInSection section: Int) -> CGFloat
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                                       insetForSectionAtIndex section: Int) -> UIEdgeInsets
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                                       minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat
    
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                                       columnCountForSection section: Int) -> Int
}

public enum CHTCollectionViewWaterfallLayoutItemRenderDirection: Int {
    case chtCollectionViewWaterfallLayoutItemRenderDirectionShortestFirst
    case chtCollectionViewWaterfallLayoutItemRenderDirectionLeftToRight
    case chtCollectionViewWaterfallLayoutItemRenderDirectionRightToLeft
}

public let CHTCollectionElementKindSectionHeader = "CHTCollectionElementKindSectionHeader"
public let CHTCollectionElementKindSectionFooter = "CHTCollectionElementKindSectionFooter"
public class CHTCollectionViewWaterfallLayout: UICollectionViewLayout {
    public var columnCount: Int {
        didSet {
            invalidateLayout()
        } }
    
    public var minimumColumnSpacing: CGFloat {
        didSet {
            invalidateLayout()
        } }
    
    public var minimumInteritemSpacing: CGFloat {
        didSet {
            invalidateLayout()
        } }
    
    public var headerHeight: CGFloat {
        didSet {
            invalidateLayout()
        } }
    
    public var footerHeight: CGFloat {
        didSet {
            invalidateLayout()
        } }
    
    public var sectionInset: UIEdgeInsets {
        didSet {
            invalidateLayout()
        } }
    
    public var itemRenderDirection: CHTCollectionViewWaterfallLayoutItemRenderDirection {
        didSet {
            invalidateLayout()
        }
    }
    
    //    private property and method above.
    public weak var delegate: CHTCollectionViewDelegateWaterfallLayout? {
        return collectionView!.delegate as? CHTCollectionViewDelegateWaterfallLayout
    }
    
    public var columnHeights: [[CGFloat]]
    public var sectionItemAttributes: [[UICollectionViewLayoutAttributes]]
    public var allItemAttributes: [UICollectionViewLayoutAttributes]
    public var headersAttributes: [Int: UICollectionViewLayoutAttributes]
    public var footersAttributes: [Int: UICollectionViewLayoutAttributes]
    public var unionRects: [NSValue]
    public let unionSize = 20
    
    public override init() {
        headerHeight = 0.0
        footerHeight = 0.0
        columnCount = 2
        minimumInteritemSpacing = 10
        minimumColumnSpacing = 10
        sectionInset = UIEdgeInsets.zero
        itemRenderDirection =
            CHTCollectionViewWaterfallLayoutItemRenderDirection.chtCollectionViewWaterfallLayoutItemRenderDirectionShortestFirst
        
        headersAttributes = [:]
        footersAttributes = [:]
        unionRects = []
        columnHeights = []
        allItemAttributes = []
        sectionItemAttributes = []
        
        super.init()
    }
    
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func columnCountForSection(_ section: Int) -> Int {
        if let columnCount = self.delegate?.collectionView?(self.collectionView!, layout: self, columnCountForSection: section) {
            return columnCount
        } else {
            return columnCount
        }
    }
    
    public func itemWidthInSectionAtIndex(_ section: Int) -> CGFloat {
        var insets: UIEdgeInsets
        if let sectionInsets = self.delegate?.collectionView?(self.collectionView!, layout: self, insetForSectionAtIndex: section) {
            insets = sectionInsets
        } else {
            insets = sectionInset
        }
        let width: CGFloat = collectionView!.bounds.size.width - insets.left - insets.right
        let columnCount = columnCountForSection(section)
        let spaceColumCount: CGFloat = CGFloat(columnCount - 1)
        return floor((width - (spaceColumCount * minimumColumnSpacing)) / CGFloat(columnCount))
    }
    
    public override func prepare() {
        super.prepare()
        
        let numberOfSections = collectionView!.numberOfSections
        if numberOfSections == 0 {
            return
        }
        
        headersAttributes = [:]
        footersAttributes = [:]
        unionRects = []
        columnHeights = []
        allItemAttributes = []
        sectionItemAttributes = []
        
        for section in 0 ..< numberOfSections {
            let columnCount = columnCountForSection(section)
            var sectionColumnHeights: [CGFloat] = []
            for idx in 0 ..< columnCount {
                sectionColumnHeights.append(CGFloat(idx))
            }
            columnHeights.append(sectionColumnHeights)
        }
        
        var top: CGFloat = 0.0
        var attributes = UICollectionViewLayoutAttributes()
        
        for section in 0 ..< numberOfSections {
            /*
             * 1. Get section-specific metrics (minimumInteritemSpacing, sectionInset)
             */
            var minimumInteritemSpacing: CGFloat
            if let miniumSpaceing = self.delegate?.collectionView?(self.collectionView!, layout: self, minimumInteritemSpacingForSectionAtIndex: section) {
                minimumInteritemSpacing = miniumSpaceing
            } else {
                minimumInteritemSpacing = minimumColumnSpacing
            }
            
            var sectionInsets: UIEdgeInsets
            if let insets = self.delegate?.collectionView?(self.collectionView!, layout: self, insetForSectionAtIndex: section) {
                sectionInsets = insets
            } else {
                sectionInsets = sectionInset
            }
            
            let width = collectionView!.bounds.size.width - sectionInsets.left - sectionInsets.right
            let columnCount = columnCountForSection(section)
            let spaceColumCount = CGFloat(columnCount - 1)
            let itemWidth = floor((width - (spaceColumCount * minimumColumnSpacing)) / CGFloat(columnCount))
            
            /*
             * 2. Section header
             */
            var heightHeader: CGFloat
            if let height = self.delegate?.collectionView?(self.collectionView!, layout: self, heightForHeaderInSection: section) {
                heightHeader = height
            } else {
                heightHeader = headerHeight
            }
            
            if heightHeader > 0 {
                attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: CHTCollectionElementKindSectionHeader, with: IndexPath(row: 0, section: section))
                attributes.frame = CGRect(x: 0, y: top, width: collectionView!.bounds.size.width, height: heightHeader)
                headersAttributes[section] = attributes
                allItemAttributes.append(attributes)
                
                top = attributes.frame.maxY
            }
            top += sectionInsets.top
            for idx in 0 ..< columnCount {
                columnHeights[section][idx] = top
            }
            
            /*
             * 3. Section items
             */
            let itemCount = collectionView!.numberOfItems(inSection: section)
            var itemAttributes: [UICollectionViewLayoutAttributes] = []
            
            // Item will be put into shortest column.
            for idx in 0 ..< itemCount {
                let indexPath = IndexPath(item: idx, section: section)
                
                let columnIndex = nextColumnIndexForItem(idx, section: section)
                let xOffset = sectionInsets.left + (itemWidth + minimumColumnSpacing) * CGFloat(columnIndex)
                
                let yOffset = ((columnHeights[section] as AnyObject).object(at: columnIndex) as AnyObject).doubleValue
                let itemSize = delegate?.collectionView(collectionView!, layout: self, sizeForItemAtIndexPath: indexPath)
                var itemHeight: CGFloat = 0.0
                if itemSize?.height > 0 && itemSize?.width > 0 {
                    itemHeight = floor(itemSize!.height * itemWidth / itemSize!.width)
                }
                
                attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(x: xOffset, y: CGFloat(yOffset!), width: itemWidth, height: itemHeight)
                itemAttributes.append(attributes)
                allItemAttributes.append(attributes)
                
                columnHeights[section][columnIndex] = attributes.frame.maxY + minimumInteritemSpacing
            }
            sectionItemAttributes.append(itemAttributes)
            
            /*
             * 4. Section footer
             */
            var footerHeight: CGFloat = 0.0
            let columnIndex = longestColumnIndexInSection(section)
            top = columnHeights[section][columnIndex] - minimumInteritemSpacing + sectionInsets.bottom
            
            if let height = self.delegate?.collectionView?(self.collectionView!, layout: self, heightForFooterInSection: section) {
                footerHeight = height
            } else {
                footerHeight = self.footerHeight
            }
            
            if footerHeight > 0 {
                attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: CHTCollectionElementKindSectionFooter, with: IndexPath(item: 0, section: section))
                attributes.frame = CGRect(x: 0, y: top, width: collectionView!.bounds.size.width, height: footerHeight)
                footersAttributes[section] = attributes
                allItemAttributes.append(attributes)
                top = attributes.frame.maxY
            }
            
            for idx in 0 ..< columnCount {
                columnHeights[section][idx] = top
            }
        }
        
        var idx = 0
        let itemCounts = allItemAttributes.count
        while idx < itemCounts {
            let rect1 = allItemAttributes[idx].frame
            idx = min(idx + unionSize, itemCounts) - 1
            let rect2 = allItemAttributes[idx].frame
            unionRects.append(NSValue(cgRect: rect1.union(rect2)))
            idx += 1
        }
    }
    
    public override var collectionViewContentSize: CGSize {
        let numberOfSections = collectionView!.numberOfSections
        if numberOfSections == 0 {
            return CGSize.zero
        }
        
        var contentSize = collectionView!.bounds.size as CGSize
        
        if columnHeights.count > 0 {
            if let height = self.columnHeights[columnHeights.count - 1].first {
                contentSize.height = height
                return contentSize
            }
        }
        return CGSize.zero
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if (indexPath as NSIndexPath).section >= sectionItemAttributes.count {
            return nil
        }
        let list = sectionItemAttributes[indexPath.section]
        if (indexPath as NSIndexPath).item >= list.count {
            return nil
        }
        return list[indexPath.item]
    }
    
    public override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
        var attribute: UICollectionViewLayoutAttributes?
        if elementKind == CHTCollectionElementKindSectionHeader {
            attribute = headersAttributes[indexPath.section]
        } else if elementKind == CHTCollectionElementKindSectionFooter {
            attribute = footersAttributes[indexPath.section]
        }
        guard let returnAttribute = attribute else {
            return UICollectionViewLayoutAttributes()
        }
        return returnAttribute
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var begin = 0, end = unionRects.count
        var attrs: [UICollectionViewLayoutAttributes] = []
        
        for i in 0 ..< end {
            let unionRect = unionRects[i]
            if rect.intersects(unionRect.cgRectValue) {
                begin = i * unionSize
                break
            }
        }
        for i in (0 ..< unionRects.count).reversed() {
            let unionRect = unionRects[i]
            if rect.intersects(unionRect.cgRectValue) {
                end = min((i + 1) * unionSize, allItemAttributes.count)
                break
            }
        }
        for i in begin ..< end {
            let attr = allItemAttributes[i]
            if rect.intersects(attr.frame) {
                attrs.append(attr)
            }
        }
        
        return attrs
    }
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let oldBounds = collectionView!.bounds
        if newBounds.width != oldBounds.width {
            return true
        }
        return false
    }
    
    /**
     *  Find the shortest column.
     *
     *  @return index for the shortest column
     */
    public func shortestColumnIndexInSection(_ section: Int) -> Int {
        var index = 0
        var shorestHeight = CGFloat.greatestFiniteMagnitude
        for (idx, height) in columnHeights[section].enumerated() {
            if height < shorestHeight {
                shorestHeight = height
                index = idx
            }
        }
        return index
    }
    
    /**
     *  Find the longest column.
     *
     *  @return index for the longest column
     */
    
    public func longestColumnIndexInSection(_ section: Int) -> Int {
        var index = 0
        var longestHeight: CGFloat = 0.0
        
        for (idx, height) in columnHeights[section].enumerated() {
            if height > longestHeight {
                longestHeight = height
                index = idx
            }
        }
        return index
    }
    
    /**
     *  Find the index for the next column.
     *
     *  @return index for the next column
     */
    public func nextColumnIndexForItem(_ item: Int, section: Int) -> Int {
        var index = 0
        let columnCount = columnCountForSection(section)
        switch itemRenderDirection {
        case .chtCollectionViewWaterfallLayoutItemRenderDirectionShortestFirst:
            index = shortestColumnIndexInSection(section)
        case .chtCollectionViewWaterfallLayoutItemRenderDirectionLeftToRight:
            index = (item % columnCount)
        case .chtCollectionViewWaterfallLayoutItemRenderDirectionRightToLeft:
            index = (columnCount - 1) - (item % columnCount)
        }
        return index
    }
}
