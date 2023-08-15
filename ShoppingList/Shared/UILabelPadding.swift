import UIKit

class UILabelPadding: UILabel {

    var labelPadding: UIEdgeInsets!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    
    init(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat, labelText: String){
        super.init(frame: .zero)
        super.text = labelText
        self.labelPadding = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        self.setupUILabel(labelText: labelText)
    }
    
    init(insets: UIEdgeInsets, labelText: String){
        super.init(frame: .zero)
        self.labelPadding = insets
        self.setupUILabel(labelText: labelText)
    }
    
    private func setupUILabel(labelText: String){
        super.translatesAutoresizingMaskIntoConstraints = false
        super.font = UIFont.systemFont(ofSize: 13)
        super.textColor = .black
        super.text = labelText
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: labelPadding))
    }

    override var intrinsicContentSize : CGSize {
        let superContentSize = super.intrinsicContentSize
        let width = superContentSize.width + labelPadding.left + labelPadding.right
        let heigth = superContentSize.height + labelPadding.top + labelPadding.bottom
        return CGSize(width: width, height: heigth)
    }
}


