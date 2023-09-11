//
// Route.swift
//

// swiftlint:disable todo

import Foundation
import CoreGraphics

// MARK: RouteField

/// Describes the various fields found within a ``Route`` record or header.
///
/// `RouteField`s are generally members of `Set`s that enumerate
/// the fields found within a ``Route`` record or header. The following,
/// for example, returns the `Set` of route fields found within
/// the `myRoutes` feed header:
/// ```swift
///   let fields = myRoutes.headerFields
/// ```
///
/// Should you need it, use `rawValue` to obtain the GTFS route field name
/// associated with an `RouteField` value as a `String`:
/// ```swift
///   let gtfsField = RouteField.details.rawValue  //  Returns "route_desc"
/// ```
public enum RouteField: String, Hashable, KeyPathVending {
  /// Route ID field.
  case routeID = "route_id"
  /// Agency ID field.
  case agencyID = "agency_id"
  /// Route name field.
  case name = "route_long_name"
  /// Route short name field.
  case shortName = "route_short_name"
  /// Route details field.
  case details = "route_desc"
  /// Route type field.
  case type = "route_type"
  /// Route URL field.
  case url = "route_url"
  /// Route color field.
  case color = "route_color"
  /// Route text color field.
  case textColor = "route_text_color"
  /// Route sort order field.
  case sortOrder = "route_sort_order"
  /// Route pickup policy field.
  case pickupPolicy = "continuous_pickup"
  /// Route drop off policy field.
  case dropOffPolicy = "continuous_drop_off"
	/// Used when a nonstandard field is found within a GTFS feed.
	case nonstandard = "nonstandard"
	
  internal var path: AnyKeyPath {
    switch self {
    case .routeID: return \Route.routeID
    case .agencyID: return \Route.agencyID
    case .name: return \Route.name
    case .shortName: return \Route.shortName
    case .details: return \Route.details
    case .type: return \Route.type
    case .url: return \Route.url
    case .color: return \Route.color
    case .textColor: return \Route.textColor
    case .sortOrder: return \Route.sortOrder
    case .pickupPolicy: return \Route.pickupPolicy
    case .dropOffPolicy: return \Route.dropOffPolicy
		case .nonstandard: return \Route.nonstandard
    }
  }
}

// MARK: - RouteField

public enum RouteType: UInt, Hashable {
  case tram = 0
  case subway = 1
  case rail = 2
  case bus = 3
  case ferry = 4
  case cable = 5
  case aerial = 6
  case funicular = 7
  case trolleybus = 11
  case monorail = 12
}

public enum PickupDropOffPolicy: UInt, Hashable {
  case continuous = 0
  case none = 1
  case coordinateWithAgency = 2
  case coordinateWithDriver = 3
}

// MARK: - Route

/// A representation of a single Route record.
public struct Route: Hashable, Identifiable {
  public let id = UUID()
  public var routeID: TransitID = ""
  public var agencyID: TransitID?
  public var name: String?
  public var shortName: String?
  public var details: String?
  public var type: RouteType = .bus
  public var url: URL?
  public var color: CGColor?
  public var textColor: CGColor?
  public var sortOrder: UInt?
  public var pickupPolicy: PickupDropOffPolicy?
  public var dropOffPolicy: PickupDropOffPolicy?
	public var nonstandard: String? = nil

  public static let requiredFields: Set<RouteField>
    = [.routeID, .type]
  public static let conditionallyRequiredFields: Set<RouteField>
    = [.agencyID, .name, .shortName]
  public static let optionalFields: Set<RouteField>
    = [.details, .url, .color, .textColor, .sortOrder,
       .pickupPolicy, .dropOffPolicy]

  public init(
		routeID: TransitID = "Unidentified route",
		agencyID: TransitID? = nil,
		name: String? = nil,
		shortName: String? = nil,
		details: String? = nil,
		type: RouteType = .bus,
		url: URL? = nil,
		color: CGColor? = nil,
		textColor: CGColor? = nil,
		sortOrder: UInt? = nil,
		pickupPolicy: PickupDropOffPolicy? = nil,
		dropOffPolicy: PickupDropOffPolicy? = nil
	) {
    self.routeID = routeID
    self.agencyID = agencyID
    self.name = name
    self.shortName = shortName
    self.details = details
    self.type = type
    self.url = url
    self.color = color
    self.textColor = textColor
    self.sortOrder = sortOrder
    self.pickupPolicy = pickupPolicy
    self.dropOffPolicy = dropOffPolicy
  }

  public init(from record: String, using headers: [RouteField]) throws {
    do {
      let fields = try record.readRecord()
      if fields.count != headers.count {
        throw TransitError.headerRecordMismatch
      }
      for (index, header) in headers.enumerated() {
        let field = fields[index]
        switch header {
        case .routeID:
          try field.assignStringTo(&self, for: header)
        case .agencyID, .name, .shortName, .details:
          try field.assignOptionalStringTo(&self, for: header)
        case .sortOrder:
          try field.assignOptionalUIntTo(&self, for: header)
        case .url:
          try field.assignOptionalURLTo(&self, for: header)
        case .color, .textColor:
          try field.assignOptionalCGColorTo(&self, for: header)
        case .type:
          try field.assignRouteTypeTo(&self, for: header)
        case .pickupPolicy, .dropOffPolicy:
          try field.assignOptionalPickupDropOffPolicyTo(&self, for: header)
				case .nonstandard:
					continue
        }
      }
    } catch let error {
      throw error
    }
  }

  public static func routeTypeFrom(string: String) -> RouteType? {
    if let rawValue = UInt(string) {
      return RouteType(rawValue: rawValue)
    } else {
      return nil
    }
  }

  public static func pickupDropOffPolicyFrom(string: String)
		-> PickupDropOffPolicy? {
    if let rawValue = UInt(string) {
      return PickupDropOffPolicy(rawValue: rawValue)
    } else {
      return nil
    }
  }

  private static let requiredHeaders: Set =
    [RouteField.routeID, RouteField.type]

	public func hasRequiredFields() -> Bool {
		return true
	}

	public func hasConditionallyRequiredFields() -> Bool {
		return true
	}
}

extension Route: Equatable {
  public static func == (lhs: Route, rhs: Route) -> Bool {
    return
      lhs.routeID == rhs.routeID &&
      lhs.agencyID == rhs.agencyID && 
      lhs.name == rhs.name &&
      lhs.shortName == rhs.shortName &&
      lhs.details == rhs.details &&
      lhs.type == rhs.type &&
      lhs.url == rhs.url &&
      lhs.color == rhs.color &&
      lhs.textColor == rhs.textColor &&
      lhs.sortOrder == rhs.sortOrder &&
      lhs.pickupPolicy == rhs.pickupPolicy &&
      lhs.dropOffPolicy == rhs.dropOffPolicy
  }
}

extension Route: CustomStringConvertible {
  public var description: String {
    return "Route: \(self.routeID)"
  }
}

// MARK: - Routes

/// A representation of a complete Route dataset.
public struct Routes: Identifiable {
  public let id = UUID()
  public var headerFields = [RouteField]()
	public var routes: [Route] = []
	
	// TODO: Routes method to ensure that feed with mutiple agencies does not omit
	// TODO:   agencyIDs if routes refer to both agencies.
	// TODO: Routes method to ensure that either name or shortName provided for all
	// TODO:   routes.
	
  subscript(index: Int) -> Route {
    get {
      return routes[index]
    }
    set(newValue) {
      routes[index] = newValue
    }
  }

  mutating func add(_ route: Route) {
    self.routes.append(route)
  }

  mutating func remove(_ route: Route) {
  }

  init<S: Sequence>(_ sequence: S)
  where S.Iterator.Element == Route {
    for route in sequence {
      self.add(route)
    }
  }

  init(from url: URL) throws {
    do {
      let records = try String(contentsOf: url).splitRecords()

      if records.count <= 1 { return }
      let headerRecord = String(records[0])
      self.headerFields = try headerRecord.readHeader()

      self.routes.reserveCapacity(records.count - 1)
      for routeRecord in records[1 ..< records.count] {
        let route = try Route(from: String(routeRecord), using: headerFields)
				//print(route)
        self.add(route)
      }
    } catch let error {
      throw error
    }
  }
}

extension Routes: Sequence {

	public typealias Iterator = IndexingIterator<[Route]>

  public func makeIterator() -> Iterator {
    return routes.makeIterator()
  }

}
