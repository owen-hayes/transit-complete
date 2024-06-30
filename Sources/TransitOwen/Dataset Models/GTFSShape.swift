//
//  Shape.swift
//
//
//  Created by Owen Hayes on 6/4/24.
//

import Foundation
import CoreLocation

public enum ShapeField: String, Hashable, KeyPathVending {
    case shapeID = "shape_id"
    case pointLat = "shape_pt_lat"
    case pointLon = "shape_pt_lon"
    case pointSequence = "shape_pt_sequence"
    case distTraveled = "shape_dist_traveled"
    
    internal var path: AnyKeyPath {
        switch self {
        case .shapeID: return \GTFSShape.shapeID
        case .pointLat: return \GTFSShape.pointLat
        case .pointLon: return \GTFSShape.pointLon
        case .pointSequence: return \GTFSShape.pointSequence
        case .distTraveled: return \GTFSShape.distTraveled
        }
    }
}

public struct GTFSShape: Hashable, Identifiable {
    public let id = UUID()
    public var shapeID: TransitID = ""
    public var pointLat: CLLocationDegrees = 0.0
    public var pointLon: CLLocationDegrees = 0.0
    public var pointSequence: UInt = 0
    public var distTraveled: Double?
    
    public static let requiredFields: Set<ShapeField> = [.shapeID, .pointLat, .pointLon, .pointSequence]
    public static let optionalFields: Set<ShapeField> = [.distTraveled]
    
    public init(
        shapeID: TransitID = "",
        pointLat: CLLocationDegrees = 0.0,
        pointLon: CLLocationDegrees = 0.0,
        pointSequence: UInt = 0,
        distTraveled: Double? = nil
    ) {
        self.shapeID = shapeID
        self.pointLat = pointLat
        self.pointLon = pointLon
        self.pointSequence = pointSequence
        self.distTraveled = distTraveled
    }
    
    public init(from record: String, using headers: [ShapeField]) throws {
        let fields = try record.readRecord()
        if fields.count != headers.count {
            throw TransitError.headerRecordMismatch
        }
        for (index, header) in headers.enumerated() {
            let field = fields[index]
            switch header {
            case .shapeID:
                try field.assignStringTo(&self, for: header)
            case .pointLat:
                try field.assignCLLocationDegreesTo(&self, for: header)
            case .pointLon:
                try field.assignCLLocationDegreesTo(&self, for: header)
            case .pointSequence:
                try field.assignUIntTo(&self, for: header)
            case .distTraveled:
                try field.assignOptionalDoubleTo(&self, for: header)
            }
        }
    }
}

public struct GTFSShapes: Identifiable, Equatable {
    public let id = UUID()
    public var headerFields = [ShapeField]()
    public var shapes: [GTFSShape] = []
    
    subscript(index: Int) -> GTFSShape {
        get {
            return shapes[index]
        }
        set(newValue) {
            shapes[index] = newValue
        }
    }
    
    mutating func add(_ shape: GTFSShape) {
        self.shapes.append(shape)
    }
    
    init<S: Sequence>(_ sequence: S) where S.Iterator.Element == GTFSShape {
        for shape in sequence {
            self.add(shape)
        }
    }
    
    init(from url: URL) throws {
        do {
            let records = try String(contentsOf: url).splitRecords()
            if records.count <= 1 { return }
            let headerRecord = String(records[0])
            self.headerFields = try headerRecord.readHeader()
            self.shapes.reserveCapacity(records.count - 1)
            for shapeRecord in records[1..<records.count] {
                let shape = try GTFSShape(from: String(shapeRecord), using: headerFields)
                self.add(shape)
            }
        } catch {
            throw error
        }
    }
}

extension GTFSShapes: Sequence {
    public typealias Iterator = IndexingIterator<[GTFSShape]>
    public func makeIterator() -> Iterator {
        return shapes.makeIterator()
    }
}


