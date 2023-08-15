import Foundation
import UIKit
import SQLite

public class TableViewComponent {
    
    public static let tableCellHeight: CGFloat = 56
    public static let imageViewCornerRadius: CGFloat = 4
    public static let cellFontSize: CGFloat = 18
    public static let headerHeight: CGFloat = 30
    public static let headerBorderHeight: CGFloat = 2
    public static let paddingImageCell: CGFloat = 8
    public static let headerBorderColor: CGColor = UIColor.systemGray2.cgColor
    public static let headerTextColor: UIColor = UIColor.systemBlue
    public static let headerLeftMargin: CGFloat = 16
    public static let stackViewSpacing: CGFloat = 16
    public static let stackViewAxis: NSLayoutConstraint.Axis = .vertical
    
    public static let detailsComponentMargin: CGFloat = 24
    public static let defaultLabelPadding = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
    
    public static func createHeaderForTable(tableView: UITableView, headerName: String) -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: headerHeight))
        
        let borderLayer = CALayer()
        borderLayer.frame = CGRect(x: 0, y: headerView.frame.height - headerBorderHeight, width: headerView.frame.width, height: headerBorderHeight)
        borderLayer.backgroundColor = headerBorderColor
        headerView.layer.addSublayer(borderLayer)
        
        let mainLabel = UILabel(frame: CGRect(x: headerLeftMargin, y: 0, width: tableView.frame.width - headerLeftMargin * 2, height: headerHeight))
        mainLabel.layer.borderColor = headerBorderColor
        mainLabel.textColor = headerTextColor
        mainLabel.font = UIFont.boldSystemFont(ofSize: cellFontSize)
        mainLabel.text = headerName
        
        headerView.addSubview(mainLabel)
        return headerView
    }
    
    public static func createImageView(photoInCell: Blob) -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = imageViewCornerRadius
        imageView.clipsToBounds = true
        
        let photo = PhotoData.blobToUIImage(photoBlob: photoInCell)
        let targetPhotoSize = CGSize(width: tableCellHeight - paddingImageCell, height: tableCellHeight - paddingImageCell)
        imageView.image = PhotoData.resizeImage(image: photo, targetSize: targetPhotoSize)
        
        return imageView
    }
}
