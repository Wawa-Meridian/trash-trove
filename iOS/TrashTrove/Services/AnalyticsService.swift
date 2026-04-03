import Foundation
import os

// MARK: - Analytics Event Types

enum AnalyticsEvent: String, Codable {
    case screenView = "screen_view"
    case saleViewed = "sale_viewed"
    case saleCreated = "sale_created"
    case saleFavorited = "sale_favorited"
    case saleUnfavorited = "sale_unfavorited"
    case saleSearched = "sale_searched"
    case saleShared = "sale_shared"
    case contactSent = "contact_sent"
    case reportSent = "report_sent"
    case nearbySearched = "nearby_searched"
    case photoUploaded = "photo_uploaded"
    case appOpened = "app_opened"
    case appBackgrounded = "app_backgrounded"
}

// MARK: - Stored Event

struct StoredAnalyticsEvent: Codable {
    let id: UUID
    let event: AnalyticsEvent
    let properties: [String: String]
    let sessionId: String
    let timestamp: Date
}

// MARK: - AnalyticsService

final class AnalyticsService: @unchecked Sendable {

    static let shared = AnalyticsService()

    private let logger = Logger(subsystem: "app.trashtrove", category: "Analytics")
    private let storageKey = "trashtrove_analytics_events"
    private let sessionKey = "trashtrove_current_session"
    private let maxStoredEvents = 1000

    private let queue = DispatchQueue(label: "app.trashtrove.analytics", qos: .utility)
    private var eventBuffer: [StoredAnalyticsEvent] = []

    // Session tracking
    private(set) var sessionId: String
    private(set) var sessionStartTime: Date

    private init() {
        sessionId = UUID().uuidString
        sessionStartTime = Date()
        loadBufferedEvents()
        logger.info("Analytics initialized. Session: \(self.sessionId)")
    }

    // MARK: - Public API

    /// Track a generic event with optional properties.
    func track(_ event: AnalyticsEvent, properties: [String: String] = [:]) {
        let storedEvent = StoredAnalyticsEvent(
            id: UUID(),
            event: event,
            properties: properties,
            sessionId: sessionId,
            timestamp: Date()
        )

        queue.async { [weak self] in
            self?.appendEvent(storedEvent)
        }

        logger.debug("Tracked: \(event.rawValue) \(properties.description)")
    }

    /// Track a screen view.
    func trackScreenView(_ screenName: String) {
        track(.screenView, properties: ["screen": screenName])
    }

    /// Alias for `trackScreenView` used by views.
    func trackScreen(_ screenName: String) {
        trackScreenView(screenName)
    }

    /// Track viewing a specific sale.
    func trackSaleViewed(saleId: UUID, title: String) {
        track(.saleViewed, properties: [
            "sale_id": saleId.uuidString,
            "title": title,
        ])
    }

    /// Track a search query.
    func trackSearch(query: String, resultCount: Int) {
        track(.saleSearched, properties: [
            "query": query,
            "result_count": String(resultCount),
        ])
    }

    /// Track favoriting or unfavoriting a sale.
    func trackFavoriteToggle(saleId: UUID, isFavorite: Bool) {
        let event: AnalyticsEvent = isFavorite ? .saleFavorited : .saleUnfavorited
        track(event, properties: ["sale_id": saleId.uuidString])
    }

    /// Track sale creation.
    func trackSaleCreated(saleId: UUID) {
        track(.saleCreated, properties: ["sale_id": saleId.uuidString])
    }

    /// Track sharing a sale.
    func trackSaleShared(saleId: UUID) {
        track(.saleShared, properties: ["sale_id": saleId.uuidString])
    }

    /// Track sending a contact message.
    func trackContactSent(saleId: UUID) {
        track(.contactSent, properties: ["sale_id": saleId.uuidString])
    }

    /// Track sending a report.
    func trackReportSent(saleId: UUID, reason: String) {
        track(.reportSent, properties: [
            "sale_id": saleId.uuidString,
            "reason": reason,
        ])
    }

    /// Track a nearby search.
    func trackNearbySearch(lat: Double, lng: Double, radiusMiles: Int) {
        track(.nearbySearched, properties: [
            "lat": String(format: "%.4f", lat),
            "lng": String(format: "%.4f", lng),
            "radius": String(radiusMiles),
        ])
    }

    /// Track a photo upload.
    func trackPhotoUploaded() {
        track(.photoUploaded)
    }

    /// Track app lifecycle.
    func trackAppOpened() {
        startNewSession()
        track(.appOpened)
    }

    func trackAppBackgrounded() {
        track(.appBackgrounded)
    }

    // MARK: - Session Management

    /// Starts a new session with a fresh ID.
    func startNewSession() {
        sessionId = UUID().uuidString
        sessionStartTime = Date()
        logger.info("New session started: \(self.sessionId)")
    }

    /// Returns the duration of the current session in seconds.
    var sessionDuration: TimeInterval {
        Date().timeIntervalSince(sessionStartTime)
    }

    // MARK: - Export / Flush

    /// Convenience method to flush events (discards them).
    func flush() {
        _ = exportAndFlush()
    }

    /// Returns all stored events and clears the buffer.
    /// Intended for future integration with an analytics backend.
    func exportAndFlush() -> [StoredAnalyticsEvent] {
        var events: [StoredAnalyticsEvent] = []
        queue.sync {
            events = self.eventBuffer
            self.eventBuffer.removeAll()
            self.persistEvents()
        }
        logger.info("Exported and flushed \(events.count) events")
        return events
    }

    /// Returns the current count of buffered events.
    var pendingEventCount: Int {
        queue.sync { eventBuffer.count }
    }

    /// Returns all stored events without clearing them.
    func peekEvents() -> [StoredAnalyticsEvent] {
        queue.sync { eventBuffer }
    }

    // MARK: - Private Helpers

    private func appendEvent(_ event: StoredAnalyticsEvent) {
        eventBuffer.append(event)

        // Trim oldest events if we exceed the cap
        if eventBuffer.count > maxStoredEvents {
            eventBuffer.removeFirst(eventBuffer.count - maxStoredEvents)
        }

        persistEvents()
    }

    private func persistEvents() {
        do {
            let data = try JSONEncoder().encode(eventBuffer)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            logger.error("Failed to persist analytics events: \(error.localizedDescription)")
        }
    }

    private func loadBufferedEvents() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            eventBuffer = try JSONDecoder().decode([StoredAnalyticsEvent].self, from: data)
            logger.info("Loaded \(self.eventBuffer.count) buffered analytics events")
        } catch {
            logger.error("Failed to load analytics events: \(error.localizedDescription)")
            eventBuffer = []
        }
    }
}
