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

import Foundation
import CoreLocation

public struct GeoGroupModel: Equatable {
    
    /// Geo hash. Useful for URLs etc.
    public let geoHash: String
    /// Coordinate of the group.
    public let location: CLLocationCoordinate2D
    /// Number of vAtoms in the group.
    public let count: Int

}

// MARK: - GeoGroupModel Codable

extension GeoGroupModel: Codable {
    
    enum CodingKeys: String, CodingKey {
        case geoHash   = "key"
        case longitude = "lon"
        case latitude  = "lat"
        case count     = "count"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        geoHash = try container.decode(String.self, forKey: .geoHash)
        count = try container.decode(Int.self, forKey: .count)
        let lon = try container.decode(Double.self, forKey: .longitude)
        let lat = try container.decode(Double.self, forKey: .latitude)
        location = CLLocationCoordinate2DMake(lat, lon)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(geoHash, forKey: .geoHash)
        try container.encode(count, forKey: .count)
        try container.encode(location.latitude, forKey: .latitude)
        try container.encode(location.longitude, forKey: .longitude)
    }
    
}

// MARK: - CLLocationCoordinate2D Equatable

extension CLLocationCoordinate2D: Equatable {}

public func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}
