import Foundation
import UIKit
import SQLite

public final class PopUpModalViewController: UIViewController {
    public var blobImageToDisplay: Blob!
    
    private lazy var closeButton: UIButton = {
        var config = UIButton.Configuration.borderedTinted()
        config.title = "Close"
        config.image = UIImage(systemName: "xmark")
        config.imagePadding = 6
        config.baseBackgroundColor = UIColor.black
        config.cornerStyle = .medium
        
        let button = UIButton(configuration: config)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(imageView)
        self.view.addSubview(closeButton) // Add the closeButton to the view hierarchy
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        imageView.image = PhotoData.resizeImage(imageBlob: self.blobImageToDisplay, targetSize: CGSize(width: self.view.bounds.width * 0.8, height: self.view.bounds.height * 0.8))

        NSLayoutConstraint.activate([
            self.imageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.imageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),

            // Position the closeButton
            self.closeButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.closeButton.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 16), // Adjust the constant as needed
        ])
    }

    
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
