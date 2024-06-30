//
//  Trip.swift
//

import Foundation

// MARK: TripField

/// All fields that may appear within a `Trip` record.
public enum TripField: String, Hashable, KeyPathVending {
  /// Route ID field.
  case routeID = "route_id"
  /// Service ID field.
  case serviceID = "service_id"
  /// Trip ID field.
  case tripID = "trip_id"
  /// Head sign field.
  case headSign = "trip_headsign"
  /// Short name field.
  case shortName = "trip_short_name"
  /// Direction ID field.
  case direction = "direction_id"
  /// Block ID field.
  case blockID = "block_id"
  /// Shape ID field.
  case shapeID = "shape_id"
  /// Is accessible field.
  case isAccessible = "wheelchair_accessible"
  /// Bikes allowed field.
  case bikesAllowed = "bikes_allowed"
  // case scheduledTripID = "schd_trip_id" // This is not in GTFS??
  // case dir = "direction" // This is not in GTFS??
	/// Used when a nonstandard field is found within a GTFS feed.
	case nonstandard = "nonstandard"
	
  internal var path: AnyKeyPath {
    switch self {
    case .routeID: return \Trip.routeID
    case .serviceID: return \Trip.serviceID
    case .tripID: return \Trip.tripID
    case .headSign: return \Trip.headSign
    case .shortName: return \Trip.shortName
    case .direction: return \Trip.direction
    case .blockID: return \Trip.blockID
    case .shapeID: return \Trip.shapeID
    case .isAccessible: return \Trip.isAccessible
    case .bikesAllowed: return \Trip.bikesAllowed
		// This is not in GTFS??
    // case .scheduledTripID: return \Trip.scheduledTripID
    // case .dir: return \Trip.dir
		case .nonstandard: return \Trip.nonstandard
    }
  }
}

// MARK: - Direction

/// - Tag: Direction
public enum Direction: UInt, Hashable {
  case inbound = 0
  case outbound = 1
}

// MARK: - Trip

/// A representation of a single Trip record.
public struct Trip: Hashable, Identifiable {
  public let id = UUID()
  public var routeID: TransitID = ""
  public var serviceID: TransitID = ""
  public var tripID: TransitID = ""
  public var headSign: String?
  public var shortName: String?
  public var direction: String? // Fix!
  public var blockID: TransitID?
  public var shapeID: TransitID?
  public var isAccessible: String? // Fix!
  public var bikesAllowed: String? // Fix!
  // public var scheduledTripID: TransitID? // This is not in GTFS??
  // public var dir: String? // This is not in GTFS??
	public var nonstandard: String? = nil
	
  public static let requiredFields: Set =
    [TripField.routeID, TripField.serviceID, TripField.tripID]

  public init(
		routeID: TransitID = "",
		serviceID: TransitID = "",
		tripID: TransitID = "",
		headSign: String? = nil,
		shortName: String? = nil,
		shapeID: String? = nil
	) {
    self.routeID = routeID
    self.serviceID = serviceID
    self.tripID = tripID
    self.headSign = headSign
    self.shortName = shortName
    self.shapeID = shapeID
  }

  public init(
		from record: String,
		using headers: [TripField]
	) throws {
    do {
      let fields = try record.readRecord()
      if fields.count != headers.count {
        throw TransitError.headerRecordMismatch
      }
      for (index, header) in headers.enumerated() {
        let field = fields[index]
        switch header {
        case .routeID, .serviceID, .tripID:
          try field.assignStringTo(&self, for: header)
        case .headSign, .shortName, .direction, .blockID, /*.dir,*/
             .shapeID, .isAccessible, .bikesAllowed /*, .scheduledTripID */:
          try field.assignOptionalStringTo(&self, for: header)
				case .nonstandard:
					continue
        }
      }
    } catch let error {
      throw error
    }
  }
}

extension Trip: Equatable {
  public static func == (lhs: Trip, rhs: Trip) -> Bool {
    return
      lhs.routeID == rhs.routeID &&
      lhs.serviceID == rhs.serviceID &&
      lhs.tripID == rhs.tripID &&
      lhs.headSign == rhs.headSign &&
      lhs.shortName == rhs.shortName &&
      lhs.shapeID == rhs.shapeID
  }
}

extension Trip: CustomStringConvertible {
  public var description: String {
    return "Trip: \(self.tripID)"
  }
}

// MARK: - Trips

/// - Tag: Trips
public struct Trips: Identifiable, Equatable {
  public let id = UUID()
  public var headerFields = [TripField]()
  fileprivate var trips = [Trip]()

  subscript(index: Int) -> Trip {
    get {
      return trips[index]
    }
    set(newValue) {
      trips[index] = newValue
    }
  }

  mutating func add(_ trip: Trip) {
    // TODO: Add to header fields supported by this collection
    self.trips.append(trip)
  }

  mutating func remove(_ trip: Trip) {
  }

  init<S: Sequence>(_ sequence: S)
  where S.Iterator.Element == Trip {
    for trip in sequence {
      self.add(trip)
    }
  }

  init(from url: URL) throws {
    do {
      let records = try String(contentsOf: url).splitRecords()

      if records.count < 1 { return }
      let headerRecord = String(records[0])
      self.headerFields = try headerRecord.readHeader()

      self.trips.reserveCapacity(records.count - 1)
      for tripRecord in records[1 ..< records.count] {
        let trip = try Trip(from: String(tripRecord), using: headerFields)
        self.add(trip)
      }
    } catch let error {
      throw error
    }
  }
}

extension Trips: Sequence {
  public typealias Iterator = IndexingIterator<[Trip]>

  public func makeIterator() -> Iterator {
    return trips.makeIterator()
  }
}
