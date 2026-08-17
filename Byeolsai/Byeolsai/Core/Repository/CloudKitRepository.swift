import CoreData
import Foundation

@objc(CDUserProfile)
final class CDUserProfile: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var displayName: String?
    @NSManaged var createdAt: Date?
    @NSManaged var currentShipID: String?
    @NSManaged var totalFocusSeconds: Int64
    @NSManaged var currentStreak: Int64
    @NSManaged var lastFocusDay: Date?
    @NSManaged var unlockedRegionIDs: String?
    @NSManaged var unlockedShipIDs: String?
}

@objc(CDFocusSession)
final class CDFocusSession: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var startAt: Date?
    @NSManaged var endAt: Date?
    @NSManaged var focusSeconds: Int64
    @NSManaged var mode: String?
    @NSManaged var destinationID: String?
    @NSManaged var valid: Bool
    @NSManaged var hasVideoLog: Bool
}

final class CloudKitRepository: FocusRepository {
    static let cloudContainerID = "iCloud.kr.arcseed.byeolsai"

    private static let model = makeModel()

    private let container: NSPersistentCloudKitContainer
    private let legacy: LocalJSONRepository?

    private var context: NSManagedObjectContext { container.viewContext }

    init(cloudSyncEnabled: Bool = true, storeURL: URL? = nil, migratingFrom legacy: LocalJSONRepository? = nil) {
        self.legacy = legacy
        container = NSPersistentCloudKitContainer(name: "Byeolsai", managedObjectModel: Self.model)

        let description = NSPersistentStoreDescription(url: storeURL ?? Self.defaultStoreURL)
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        if cloudSyncEnabled {
            description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: Self.cloudContainerID)
        }
        container.persistentStoreDescriptions = [description]

        var loadError: Error?
        container.loadPersistentStores { _, error in loadError = error }
        if loadError != nil && cloudSyncEnabled {
            description.cloudKitContainerOptions = nil
            container.loadPersistentStores { _, error in loadError = error }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    func prepare() async throws {
        guard let legacy else { return }
        let hasProfile = try context.count(for: profileRequest()) > 0
        let hasSessions = try context.count(for: sessionRequest()) > 0
        guard !hasProfile, !hasSessions else { return }
        guard let profile = try await legacy.loadProfile() else { return }

        apply(profile, to: CDUserProfile(context: context))
        for session in try await legacy.allSessions() {
            apply(session, to: CDFocusSession(context: context))
        }
        try context.save()
    }

    func loadProfile() async throws -> UserProfile? {
        try context.fetch(profileRequest()).first.flatMap(domainProfile)
    }

    func save(profile: UserProfile) async throws {
        let entity = try context.fetch(profileRequest()).first ?? CDUserProfile(context: context)
        apply(profile, to: entity)
        try context.save()
    }

    func save(session: FocusSession) async throws {
        apply(session, to: CDFocusSession(context: context))
        try context.save()
    }

    func allSessions() async throws -> [FocusSession] {
        try context.fetch(sessionRequest())
            .compactMap(domainSession)
            .sorted { $0.startAt < $1.startAt }
    }

    var remoteChanges: AsyncStream<Void> {
        let coordinator = container.persistentStoreCoordinator
        return AsyncStream { continuation in
            let token = NotificationCenter.default.addObserver(
                forName: .NSPersistentStoreRemoteChange,
                object: coordinator,
                queue: nil
            ) { _ in
                continuation.yield()
            }
            continuation.onTermination = { _ in
                NotificationCenter.default.removeObserver(token)
            }
        }
    }

    private func profileRequest() -> NSFetchRequest<CDUserProfile> {
        NSFetchRequest<CDUserProfile>(entityName: "CDUserProfile")
    }

    private func sessionRequest() -> NSFetchRequest<CDFocusSession> {
        NSFetchRequest<CDFocusSession>(entityName: "CDFocusSession")
    }

    private func apply(_ profile: UserProfile, to entity: CDUserProfile) {
        entity.id = profile.id
        entity.displayName = profile.displayName
        entity.createdAt = profile.createdAt
        entity.currentShipID = profile.currentShipID
        entity.totalFocusSeconds = Int64(profile.totalFocusSeconds)
        entity.currentStreak = Int64(profile.currentStreak)
        entity.lastFocusDay = profile.lastFocusDay
        entity.unlockedRegionIDs = profile.unlockedRegionIDs.joined(separator: ",")
        entity.unlockedShipIDs = profile.unlockedShipIDs.joined(separator: ",")
    }

    private func domainProfile(_ entity: CDUserProfile) -> UserProfile? {
        guard let id = entity.id, let createdAt = entity.createdAt else { return nil }
        return UserProfile(
            id: id,
            displayName: entity.displayName ?? "",
            createdAt: createdAt,
            currentShipID: entity.currentShipID ?? "",
            totalFocusSeconds: Int(entity.totalFocusSeconds),
            currentStreak: Int(entity.currentStreak),
            lastFocusDay: entity.lastFocusDay,
            unlockedRegionIDs: splitIDs(entity.unlockedRegionIDs),
            unlockedShipIDs: splitIDs(entity.unlockedShipIDs)
        )
    }

    private func apply(_ session: FocusSession, to entity: CDFocusSession) {
        entity.id = session.id
        entity.startAt = session.startAt
        entity.endAt = session.endAt
        entity.focusSeconds = Int64(session.focusSeconds)
        entity.mode = session.mode.rawValue
        entity.destinationID = session.destinationID
        entity.valid = session.valid
        entity.hasVideoLog = session.hasVideoLog
    }

    private func domainSession(_ entity: CDFocusSession) -> FocusSession? {
        guard let id = entity.id, let startAt = entity.startAt, let endAt = entity.endAt else { return nil }
        return FocusSession(
            id: id,
            startAt: startAt,
            endAt: endAt,
            focusSeconds: Int(entity.focusSeconds),
            mode: entity.mode.flatMap(SessionMode.init(rawValue:)) ?? .phoneDown,
            destinationID: entity.destinationID ?? "",
            valid: entity.valid,
            hasVideoLog: entity.hasVideoLog
        )
    }

    private func splitIDs(_ joined: String?) -> [String] {
        (joined ?? "").split(separator: ",").map(String.init)
    }

    private static var defaultStoreURL: URL {
        let base = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: SharedStore.appGroupID)
            ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let directory = base.appendingPathComponent("Database", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appendingPathComponent("Byeolsai.sqlite")
    }

    private static func makeModel() -> NSManagedObjectModel {
        let profile = NSEntityDescription()
        profile.name = "CDUserProfile"
        profile.managedObjectClassName = NSStringFromClass(CDUserProfile.self)
        profile.properties = [
            attribute("id", .UUIDAttributeType),
            attribute("displayName", .stringAttributeType),
            attribute("createdAt", .dateAttributeType),
            attribute("currentShipID", .stringAttributeType),
            attribute("totalFocusSeconds", .integer64AttributeType, defaultValue: 0),
            attribute("currentStreak", .integer64AttributeType, defaultValue: 0),
            attribute("lastFocusDay", .dateAttributeType),
            attribute("unlockedRegionIDs", .stringAttributeType),
            attribute("unlockedShipIDs", .stringAttributeType),
        ]

        let session = NSEntityDescription()
        session.name = "CDFocusSession"
        session.managedObjectClassName = NSStringFromClass(CDFocusSession.self)
        session.properties = [
            attribute("id", .UUIDAttributeType),
            attribute("startAt", .dateAttributeType),
            attribute("endAt", .dateAttributeType),
            attribute("focusSeconds", .integer64AttributeType, defaultValue: 0),
            attribute("mode", .stringAttributeType),
            attribute("destinationID", .stringAttributeType),
            attribute("valid", .booleanAttributeType, defaultValue: false),
            attribute("hasVideoLog", .booleanAttributeType, defaultValue: false),
        ]

        let model = NSManagedObjectModel()
        model.entities = [profile, session]
        return model
    }

    private static func attribute(_ name: String, _ type: NSAttributeType, defaultValue: Any? = nil) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = type
        attribute.isOptional = true
        attribute.defaultValue = defaultValue
        return attribute
    }
}
