//
//  SwiftCodables.swift
//  Biq
//
//  Created by Kyle Jessup on 2017-12-05.
//

import Foundation

public typealias UserId = UUID
public typealias DeviceURN = String
public typealias Id = UUID

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

public enum ObsDatabase {
	public struct BiqObservation: Codable {
		public let id: Int
		public var deviceId: DeviceURN { return bixid }
		public let bixid: DeviceURN
		public let obstime: Double
		// I don't know why they are stored in the db as milliseconds and as a Double
		public var obsTimeSeconds: Double { return obstime / 1000 }
		public let charging: Int
		public let firmware: String
		public let battery: Double
		public let temp: Double
		public let light: Int
		public let humidity: Int
		public let accelx: Int
		public let accely: Int
		public let accelz: Int
		public init(id i: Int,
					deviceId d: DeviceURN,
					obstime: Double,
					charging: Int,
					firmware: String,
					battery: Double,
					temp: Double,
					light: Int,
					humidity: Int,
					accelx: Int,
					accely: Int,
					accelz: Int) {
			id = i
			bixid = d
			self.obstime = obstime
			self.charging = charging
			self.firmware = firmware
			self.battery = battery
			self.temp = temp
			self.light = light
			self.humidity = humidity
			self.accelx = accelx
			self.accely = accely
			self.accelz = accelz
		}
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
		
		groupMemberships = nil
		accessPermissions = nil
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
	public let groupId: Id
	public let deviceId: DeviceURN
	public init(groupId g: Id,
				deviceId d: DeviceURN) {
		groupId = g
		deviceId = d
	}
}

public struct BiqDeviceAccessPermission: Codable {
	public let userId: UserId
	public let deviceId: DeviceURN
	public let flags: Int? 
	public init(userId u: UserId,
				deviceId d: DeviceURN,
				flags f: Int = 0) {
		userId = u
		deviceId = d
		flags = f
	}
}

public enum BiqDeviceLimitType: UInt8, Codable {
	case tempHigh, tempLow
	case movementLevel
	case batteryLevel
}

public struct BiqDeviceLimit: Codable {
	public let userId: UserId
	public let deviceId: DeviceURN
	public let limitType: UInt8
	public let limitValue: Float
	public var type: BiqDeviceLimitType? { return BiqDeviceLimitType(rawValue: limitType) }
	
	public init(userId u: UserId, deviceId d: DeviceURN, limitType t: BiqDeviceLimitType, limitValue v: Float) {
		userId = u
		deviceId = d
		limitType = t.rawValue
		limitValue = v
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
	public init() {}
}

public enum AuthAPI {
	public struct TokenAcquiredResponse: Codable {
		public let token: String
		public let account: Account?
		public init(token: String, account: Account?) {
			self.token = token
			self.account = account
		}
	}

	public struct RegisterRequest: Codable {
		public let email: String
		public let password: String
		public init(email e: String, password p: String) {
			email = e
			password = p
		}
	}
	public typealias LoginRequest = RegisterRequest
	
	public struct AddMobileDeviceRequest: Codable {
		public let deviceId: String
		public let deviceType: String
		public init(deviceId: String, deviceType: String) {
			self.deviceId = deviceId
			self.deviceType = deviceType
		}
	}
	
	public struct PasswordResetRequest: Codable {
		public let address: String
		public let deviceId: String?
		public init(address: String, deviceId: String?) {
			self.address = address
			self.deviceId = deviceId
		}
	}
	
	public struct PasswordResetCompleteRequest: Codable {
		public let address: String
		public let password: String
		public let authToken: String
		public init(address: String, password: String, authToken: String) {
			self.address = address
			self.password = password
			self.authToken = authToken
		}
	}
}

public typealias TokenAcquiredResponse = AuthAPI.TokenAcquiredResponse

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
	public struct GenericDeviceRequest: Codable {
		public let deviceId: DeviceURN
		public init(deviceId d: DeviceURN) {
			deviceId = d
		}
	}
	
	public typealias RegisterRequest = GenericDeviceRequest
	public typealias ShareRequest = GenericDeviceRequest
	public typealias LimitsRequest = GenericDeviceRequest
	
	public struct UpdateRequest: Codable {
		public let deviceId: DeviceURN
		public let name: String?
		public let flags: Int?
		public var deviceFlags: BiqDeviceFlag? {
			if let f = flags {
				return BiqDeviceFlag(rawValue: f)
			}
			return nil
		}
		public init(deviceId g: DeviceURN, name n: String? = nil, flags f: BiqDeviceFlag? = nil) {
			deviceId = g
			name = n
			flags = f?.rawValue
		}
	}
	
	public struct DeviceLimit: Codable {
		public let limitType: BiqDeviceLimitType
		public let limitValue: Float?
		public init(limitType t: BiqDeviceLimitType, limitValue v: Float?) {
			limitType = t
			limitValue = v
		}
	}
	
	public struct UpdateLimitsRequest: Codable {
		public let deviceId: DeviceURN
		public let limits: [DeviceLimit]
		public init(deviceId g: DeviceURN, limits l: [DeviceLimit]) {
			deviceId = g
			limits = l
		}
	}
	
	public typealias DeviceLimitsResponse = UpdateLimitsRequest
	
	public struct ListDevicesResponseItem: Codable {
		public let device: BiqDevice
		public let lastObservation: ObsDatabase.BiqObservation?
		public let shareCount: Int?
		public let limits: [DeviceLimit]?
		public init(device d: BiqDevice, shareCount s: Int, lastObservation o: ObsDatabase.BiqObservation?, limits l: [DeviceLimit]) {
			device = d
			shareCount = s
			lastObservation = o
			limits = l
		}
	}
	public struct ObsRequest: Codable {
		public enum Interval: Int, Codable {
			case all,
				live, // 12 hours
				day, month, year
		}
		public let deviceId: DeviceURN
		public let interval: Int // fix - enums with associated + codable
		public init(deviceId d: DeviceURN, interval i: Interval) {
			deviceId = d
			interval = i.rawValue
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

// SAuth - Auth 2

public struct TokenClaim: Codable {
	enum CodingKeys: String, CodingKey {
		case issuer = "iss", subject = "sub", expiration = "exp",
		issuedAt = "iat", accountId = "accountId",
		oauthProvider = "oauthProvider", oauthAccessToken = "oauthAccessToken"
	}
	public let issuer: String?
	public let subject: String?
	public let expiration: Int?
	public let issuedAt: Int?
	public let accountId: UUID?
	public let oauthProvider: String?
	public let oauthAccessToken: String?
	public init(issuer: String? = nil,
				subject: String? = nil,
				expiration: Int? = nil,
				issuedAt: Int? = nil,
				accountId: UUID? = nil,
				oauthProvider: String? = nil,
				oauthAccessToken: String? = nil) {
		self.issuer = issuer
		self.subject = subject
		self.expiration = expiration
		self.issuedAt = issuedAt
		self.accountId = accountId
		self.oauthProvider = oauthProvider
		self.oauthAccessToken = oauthAccessToken
	}
	
}

public struct AccountPublicMeta: Codable {
	public let fullName: String?
	public init(fullName: String? = nil) {
		self.fullName = fullName
	}
}

public struct Account: Codable {
	public let id: UUID
	public let flags: UInt
	public let createdAt: Int
	public let meta: AccountPublicMeta?
	public init(id: UUID,
				flags: UInt,
				createdAt: Int,
				meta: AccountPublicMeta? = nil) {
		self.id = id
		self.flags = flags
		self.createdAt = createdAt
		self.meta = meta
	}
}

public struct Alias: Codable {
	public let address: String
	public let account: UUID
	public let priority: Int
	public let flags: UInt
	public let pwSalt: String?
	public let pwHash: String?
	public init(address: String,
				account: UUID,
				priority: Int,
				flags: UInt,
				pwSalt: String?,
				pwHash: String?) {
		self.address = address
		self.account = account
		self.priority = priority
		self.flags = flags
		self.pwSalt = pwSalt
		self.pwHash = pwHash
	}
}

public struct AliasBrief: Codable {
	public let address: String
	public let account: UUID
	public let priority: Int
	public let flags: UInt
	public init(address: String,
				account: UUID,
				priority: Int,
				flags: UInt) {
		self.address = address
		self.account = account
		self.priority = priority
		self.flags = flags
	}
}






