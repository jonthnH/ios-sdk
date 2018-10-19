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

// swiftlint:disable trailing_whitespace

import Foundation
import Nuke

/// Native Layered face view
class LayeredImageFaceView: FaceView {
    class var displayURL: String { return "native://layered-image" }
	
	// Layer
	class Layer: UIImageView {
		/// Reference to the resource this layer displays.
		var resource: VatomResourceModel?
		/// Reference to the vAtom which this layer represents.
		var vatom: VatomModel!
	}

    // MARK: - Properties

    lazy var baseLayer: Layer = {
        let layer = Layer()
		layer.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
		layer.clipsToBounds = true
        return layer
    }()

    public private(set) var isLoaded: Bool = false
	
	var childVatoms: [VatomModel] = []
	var topLayers: [Layer] = []
	// Loop over the children the add a layer ontop of the base 
	//( check that the array keeps its index | is the order correct in other words )

    // MARK: - Config

    /// Face model face configuration specification.
    private struct Config {
        enum Scale: String {
            case fit, fill
        }

        // defaults
        var scale: Scale = .fit
        var imageName: String = "ActivatedImage"

        /// Initialize using face model.
        ///
        /// The config has a set of default values. If the face config section is present, those values are used in
        /// place of the default ones.
        ///
        /// ### Legacy Support
        /// The first resource name in the resources array (if present) is used in place of the activate image.
        init(_ faceModel: FaceModel) {
            // legacy: overwrite fallback if needed
            self.imageName ?= faceModel.properties.resources.first

            if let config = faceModel.properties.config {
                // assign iff not nil
                if let scaleString = config["scale"]?.stringValue {
                    self.scale ?= Config.Scale(rawValue: scaleString)
                }
                self.imageName ?= config["name"]?.stringValue
            }
        }
    }

    private let config: Config

    // MARK: - Init
    required init(vatom: VatomModel, faceModel: FaceModel) {
        // init face config
        self.config = Config(faceModel)
        super.init(vatom: vatom, faceModel: faceModel)

		baseLayer.frame = self.bounds
        self.addSubview(baseLayer)
		
		/*
		BLCOKv.
		*/
		self.vAtomStateChanged(isAdded: true)
		
		BLOCKv.socket.onVatomStateUpdate.subscribe(with: self) { (stateUpdateEvent) in
			
			guard let parentId = stateUpdateEvent.vatomProperties["vAtom::vAtomType"]?["parent_id"]?.stringValue else {
				return 
			}
			
			self.vAtomStateChanged(isAdded: parentId == "." ? false : true)
		} 
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) should not be called on Face Views. Please use VatomView.")
    }

	// MARK: - View Lifecylce

	override func layoutSubviews() {
		super.layoutSubviews()

		updateContentMode()
	}

	private func updateContentMode() {
		// check face config
		switch config.scale {
		case .fill: baseLayer.contentMode = .scaleAspectFill
		case .fit:  baseLayer.contentMode = .scaleAspectFit
		}
	}

    // MARK: - Face View Lifecycle

    /// Begin loading the face view's content.
    func load(completion: ((Error?) -> Void)?) {
		updateResources(completion: completion)
    }
	
    func vatomChanged(_ vatom: VatomModel) {
		self.vatom = vatom
		updateResources(completion: nil)
    }
	
    func unload() {
		self.baseLayer.image = nil
    }

	// MARK: - Resources

	private func updateResources(completion: ((Error?) -> Void)?) {

		// extract resource model
		guard let resourceModel = vatom.props.resources.first(where: { $0.name == config.imageName }) else {
			return
		}

		// encode url
		guard let encodeURL = try? BLOCKv.encodeURL(resourceModel.url) else {
			return
		}

		//FIXME: Where should this go?
		ImagePipeline.Configuration.isAnimatedImageDataEnabled = true

		//TODO: Should the size of the VatomView be factoring in and the image be resized?

		// load image (automatically handles reuse)
		Nuke.loadImage(with: encodeURL, into: self.baseLayer) { (_, error) in
			self.isLoaded = true
			completion?(error)
		}
	}
	
	// MARK: - Creation Layer
	
	private func createLayer(_ vatom: VatomModel) -> Layer {
		let layer  = Layer()
		layer.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
		layer.clipsToBounds = true
		
		layer.vatom = vatom
		
		// extract resource model
		guard let resourceModel = vatom.props.resources.first(where: { $0.name == config.imageName }) else {
			printBV(info: "could not find child vatom resource model")
			return layer
		}
		
		// encode url
		guard let encodeURL = try? BLOCKv.encodeURL(resourceModel.url) else {
			printBV(info: "could not encode child vatom resource")
			return layer
		}
		
		Nuke.loadImage(with: encodeURL, into: layer) { (_, _) in
			self.isLoaded = true
		}
		
		layer.frame = self.bounds
		self.baseLayer.addSubview(layer)
		self.topLayers.append(layer)
		
		return layer
	}
	
	private func removeLayers(_ layers: [Layer]) {
		
	}
	
	func vAtomStateChanged(isAdded: Bool) {
		printBV(info: "State changed")
		
		BLOCKv.getInventory(id: self.vatom.id) { (vatomModels, error) in
			
			guard error == nil else {
				printBV(info: "getInventory - \(error!.localizedDescription)")
				return
			}
			
			self.childVatoms = vatomModels
			
			var newLayers: [Layer] = []
			for childVatom in self.childVatoms {
				//investigate if the layer already exists
				var tempLayer: Layer!
				for layer in self.topLayers {
					if layer.vatom == self.vatom {
						tempLayer = layer
						break
					}
				}
				
				if tempLayer == nil {
					tempLayer = self.createLayer(childVatom)
				}
				
				newLayers.append(tempLayer)
			}
			
			var layersToRemove: [Layer] = []
			for layer in self.topLayers {
				// Check if added
				if newLayers.contains(where: { $0.vatom == layer.vatom }) {
					continue
				}
				
				layersToRemove.append(layer)
			}
			
			self.removeLayers(layersToRemove)
		}
	}
}
