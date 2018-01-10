//
//  File.swift
//  BIQServer
//
//  Created by Kyle Jessup on 2017-12-05.
//

import Foundation

public typealias UserId = String
public typealias DeviceURN = String
public typealias Id = UUID

public let deviceURNPrefix = "urn:qbiq:"

public protocol IdHashable: Hashable {
	associatedtype IdType: Hashable
	var id: IdType { get }
}

extension IdHashable {
	public var hashValue: Int {
		return id.hashValue
	}
	public static func ==(lhs: Self, rhs: Self) -> Bool {
		return lhs.id == rhs.id
	}
}

public enum AuthDatabase {
	// we never create these
	// we never write to these
	public struct BiqUserSession: Codable {
		// userid is validated upstream in the handlers
		public var id: UserId { return userid ?? "" }
		public let token: String
		public let userid: UserId?
		public let created: Int
		public let updated: Int
		public let idle: Int
		public let data: String?
		public let ipaddress: String?
		public let useragent: String?
	}
	public struct BiqUser: Codable, IdHashable {
		public let id: UserId
		public let username: String
		public let email: String
		public let usertype: String
		public let detail: String
		public let deviceGroups: [BiqDeviceGroup]?
	}
	public struct BiqUserMeta: Codable {
		let fullName: String?
	}
}

public struct BiqDeviceFlag: OptionSet {
	public let rawValue: Int
	public init(rawValue r: Int) {
		rawValue = r
	}
	public static let locked = BiqDeviceFlag(rawValue: 1)
	public static let temperatureCapable = BiqDeviceFlag(rawValue: 1<<2)
	public static let movementCapable = BiqDeviceFlag(rawValue: 1<<3)
	public static let lightCapable = BiqDeviceFlag(rawValue: 1<<4)
}

public struct BiqDevice: Codable, IdHashable {
	public let id: DeviceURN
	public let name: String
	public let ownerId: UserId?
	public let flags: Int?
	public let latitude: Double?
	public let longitude: Double?
	
	public let observations: [BiqObservation]?
	public let groupMemberships: [BiqDeviceGroupMembership]?
	public let accessPermissions: [BiqDeviceAccessPermission]?
	
	public var deviceFlags: BiqDeviceFlag {
		return BiqDeviceFlag(rawValue: flags ?? 0)
	}
	public init(id i: DeviceURN,
				name n: String,
				ownerId o: UserId? = nil,
				flags f: BiqDeviceFlag? = nil,
				latitude la: Double? = nil,
				longitude lo: Double? = nil) {
		id = i
		name = n
		ownerId = o
		flags = f?.rawValue
		latitude = la
		longitude = lo
		
		observations = nil
		groupMemberships = nil
		accessPermissions = nil
	}
}

public struct BiqObservation: Codable {
	public let id: Id
	public let deviceId: DeviceURN
	public let date: Date
	public init(id i: Id,
				deviceId d: DeviceURN,
				date da: Date) {
		id = i
		deviceId = d
		date = da
	}
}

public struct BiqDeviceGroup: Codable, IdHashable {
	public let id: Id
	public let ownerId: UserId
	public let name: String
	public let devices: [BiqDevice]?
	
	public init(id i: Id,
				ownerId o: UserId,
				name n: String) {
		id = i
		ownerId = o
		name = n
		devices = nil
	}
}

public struct BiqDeviceGroupMembership: Codable {
	public let id: Id
	public let groupId: Id
	public let deviceId: DeviceURN
	public init(id i: Id,
				groupId g: Id,
				deviceId d: DeviceURN) {
		id = i
		groupId = g
		deviceId = d
	}
}

public struct BiqDeviceAccessPermission: Codable {
	public let id: Id
	public let userId: UserId
	public let deviceId: DeviceURN
	public init(id i: Id,
				userId u: UserId,
				deviceId d: DeviceURN) {
		id = i
		userId = u
		deviceId = d
	}
}

// Requests / Responses 

public struct HealthCheckResponse: Codable {
	public let health: String
	public init(health h: String) {
		health = h
	}
}

public struct EmptyReply: Codable {
	
}

public enum GroupAPI {
	public struct CreateRequest: Codable {
		public let name: String
		public init(name h: String) {
			name = h
		}
	}
	
	public struct DeleteRequest: Codable {
		public let groupId: Id
		public init(groupId h: Id) {
			groupId = h
		}
	}
	
	public struct UpdateRequest: Codable {
		public let groupId: Id
		public let name: String?
		public init(groupId g: Id, name n: String? = nil) {
			groupId = g
			name = n
		}
	}
	
	public struct ListDevicesRequest: Codable {
		public let groupId: Id
		public init(groupId h: Id) {
			groupId = h
		}
	}
	
	public struct AddDeviceRequest: Codable {
		public let groupId: Id
		public let deviceId: DeviceURN
		public init(groupId h: Id, deviceId d: DeviceURN) {
			groupId = h
			deviceId = d
		}
	}
}

public enum DeviceAPI {
	public struct RegisterRequest: Codable {
		public let deviceId: DeviceURN
		public init(deviceId d: DeviceURN) {
			deviceId = d
		}
	}
	
	public struct UpdateRequest: Codable {
		public let deviceId: DeviceURN
		public let name: String?
		public init(deviceId g: DeviceURN, name n: String? = nil) {
			deviceId = g
			name = n
		}
	}
}

public enum Observation {
	public enum Element: Int {
		case deviceId,
		firmwareVersion,
		batteryLevel,
		charging,
		temperature,
		lightLevel,
		relativeHumidity,
		relativeTemperature,
		acceleration // xyz
		
	}
}









