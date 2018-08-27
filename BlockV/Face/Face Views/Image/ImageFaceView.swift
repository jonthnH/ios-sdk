//
//  BlockV AG. Copyright (c) 2018, all rights reserved.
//
//  Licensed under the BlockV SDK License (the "License"); you may not use this file or
//  the BlockV SDK except in compliance with the License accompanying it. Unless
//  required by applicable law or agreed to in writing, the BlockV SDK distributed under
//  the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
//  ANY KIND, either express or implied. See the License for the specific language
//  governing permissions and limitations under the License.
//

import UIKit
import FLAnimatedImage

/// Native Image face view
class ImageFaceView: FaceView {
    
    // MARK: - Face View Protocol
    
    class var displayURL: String { return "native://image" }
    
    // MARK: - Initialization
    
    required init(vatomPack: VatomPackModel, faceModel: FaceModel) {
        super.init(vatomPack: vatomPack, faceModel: faceModel)
        
        try? self.extractConfig()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Face Config
    
    enum Scale: String {
        case fit, fill
    }
    
    private var scale: Scale?
    private var imageName: String?
    
    /// Validates the face has a suitable config section.
    ///
    /// Throws an error if the face does not meet the config specification.
    private func extractConfig() throws {
        // extract scale
        if let scaleString = self.faceModel.properties.config?["scale"]?.stringValue {
            self.scale = Scale(rawValue: scaleString)
        }
        // extract image name
        if let imageNameString = self.faceModel.properties.config?["name"]?.stringValue {
            self.imageName = imageNameString
        }
    }
    
    // MARK: - View Lifecylce
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateContentMode()
    }
    
    /// Update the content mode of the image view.
    ///
    /// Inspects the face config first and uses the scale if available. If no face config is found, a simple heuristic
    /// is used to choose the best content mode.
    private func updateContentMode() {
        
        guard let image = imageView.image else { return }
        
        // check face config
        if let scale = self.scale {
            switch scale {
            case .fill: imageView.contentMode = .scaleAspectFill
            case .fit: imageView.contentMode = .scaleAspectFit
            }
            // no face config supplied (try and do the right thing)
        } else if self.faceModel.properties.constraints.viewMode == "card" {
            imageView.contentMode = .scaleAspectFill
        } else if image.size.width > imageView.bounds.size.width || image.size.height > imageView.bounds.size.height {
            imageView.contentMode = .scaleAspectFit
        } else {
            imageView.contentMode = .center
        }
        
    }
    
    // MARK: - Face View Lifecycle
    
    var timer: Timer?
    
    func load(completion: @escaping (Error?) -> Void) {
        print(#function)
        
        // Download resource
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
            self.backgroundColor = .red
            completion(nil)
        }
        
    }
    
    func vatomUpdated(_ vatomPack: VatomPackModel) {
        print(#function)
    }
    
    func unload() {
        print(#function)
    }
    
    // MARK: - Prototype
    
    ///FIXME: This must become
    func doResourceStuff() {
        
    }
    
    // FIXME: This should be of type FLAnimatedImageView
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.frame = self.bounds
        imageView.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
        imageView.clipsToBounds = true
        return imageView
    }()
    
}
