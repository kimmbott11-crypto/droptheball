//
//  MatchManager.swift
//  droptheball
//

import SwiftUI

@Observable
class MatchManager {
    // Configurable time range
    var startHour: Int = 19
    var startMinute: Int = 0
    var endHour: Int = 22
    var endMinute: Int = 0
    
    // Configurable court count
    var selectedCourtCount: Int = 3
    
    var players: [Player] = []
    var slots: [TimeSlot] = []
    var nextId: Int = 1
    var toastMessage: String?
    
    // Generated time options based on config
    var slotTimes: [String] {
        var times: [String] = []
        var h = startHour
        var m = startMinute
        let endTotal = endHour * 60 + endMinute
        while h * 60 + m + 30 <= endTotal {
            times.append(String(format: "%02d:%02d", h, m))
            m += 30
            if m >= 60 { m -= 60; h += 1 }
        }
        return times
    }
    
    var arriveOptions: [String] {
        slotTimes
    }
    
    var departOptions: [String] {
        var times: [String] = []
        var h = startHour
        var m = startMinute + 30
        if m >= 60 { m -= 60; h += 1 }
        let endTotal = endHour * 60 + endMinute
        while h * 60 + m <= endTotal {
            times.append(String(format: "%02d:%02d", h, m))
            m += 30
            if m >= 60 { m -= 60; h += 1 }
        }
        return times
    }
    
    static let hourOptions = Array(6...23)
    static let minuteOptions = [0, 30]
    
    var presentPlayers: [Player] {
        players.filter { $0.isPresent }
    }
    
    var presentCount: Int {
        presentPlayers.count
    }
    
    init() {
        loadState()
    }
    
    // MARK: - Time Config
    
    func updateTimeRange() {
        rebuildSlots()
        // Fix player times that are out of range
        let arrive = arriveOptions
        let depart = departOptions
        for i in players.indices {
            if !arrive.contains(players[i].arriveTime) {
                players[i].arriveTime = arrive.first ?? "19:00"
            }
            if !depart.contains(players[i].departTime) {
                players[i].departTime = depart.last ?? "22:00"
            }
        }
        saveState()
    }
    
    func rebuildSlots() {
        let times = slotTimes
        slots = times.enumerated().map { TimeSlot(id: $0.offset, time: $0.element, courts: nil, sitters: nil) }
    }
    
    // MARK: - Time Utilities
    
    func toMinutes(_ time: String) -> Int {
        let parts = time.split(separator: ":").compactMap { Int($0) }
        guard parts.count == 2 else { return 0 }
        return parts[0] * 60 + parts[1]
    }
    
    func isAvailable(player: Player, forSlotTime slotTime: String) -> Bool {
        guard player.isPresent else { return false }
        let arrive = toMinutes(player.arriveTime)
        let depart = toMinutes(player.departTime)
        let slotStart = toMinutes(slotTime)
        let slotEnd = slotStart + 30
        return arrive <= slotStart && depart >= slotEnd
    }
    
    func availablePlayers(forSlotTime slotTime: String) -> [Player] {
        players.filter { isAvailable(player: $0, forSlotTime: slotTime) }
    }
    
    func playerName(for id: Int) -> String {
        players.first { $0.id == id }?.name ?? "?"
    }
    
    // MARK: - Player Management
    
    func addPlayer(name: String, arrive: String, depart: String) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        guard !players.contains(where: { $0.name == trimmed }) else {
            showToast("같은 이름이 있어요!")
            return
        }
        let player = Player(
            id: nextId,
            name: trimmed,
            isPresent: true,
            arriveTime: arrive,
            departTime: depart,
            playCount: 0,
            satOutLast: false
        )
        nextId += 1
        players.append(player)
        saveState()
    }
    
    func togglePresent(id: Int) {
        guard let idx = players.firstIndex(where: { $0.id == id }) else { return }
        players[idx].isPresent.toggle()
        saveState()
    }
    
    func removePlayer(id: Int) {
        players.removeAll { $0.id == id }
        for i in slots.indices {
            if var courts = slots[i].courts {
                for j in courts.indices {
                    courts[j].team1.removeAll { $0 == id }
                    courts[j].team2.removeAll { $0 == id }
                }
                slots[i].courts = courts
            }
            slots[i].sitters?.removeAll { $0 == id }
        }
        saveState()
    }
    
    func updateArriveTime(id: Int, time: String) {
        guard let idx = players.firstIndex(where: { $0.id == id }) else { return }
        players[idx].arriveTime = time
        if toMinutes(players[idx].departTime) <= toMinutes(time) {
            if let nextDepart = departOptions.first(where: { toMinutes($0) > toMinutes(time) }) {
                players[idx].departTime = nextDepart
            } else if let last = departOptions.last {
                players[idx].departTime = last
            }
        }
        saveState()
    }
    
    func updateDepartTime(id: Int, time: String) {
        guard let idx = players.firstIndex(where: { $0.id == id }) else { return }
        if toMinutes(time) <= toMinutes(players[idx].arriveTime) {
            showToast("퇴장이 도착보다 빠를 수 없어요")
            return
        }
        players[idx].departTime = time
        saveState()
    }
    
    // MARK: - Match Generation
    
    private func mixedArrange(_ playerList: [Player]) -> [Player] {
        let sorted = playerList.sorted { $0.playCount < $1.playCount }
        var result: [Player] = []
        var lo = 0, hi = sorted.count - 1
        while lo <= hi {
            if lo == hi {
                result.append(sorted[lo])
                lo += 1
            } else {
                result.append(sorted[lo])
                result.append(sorted[hi])
                lo += 1
                hi -= 1
            }
        }
        var output: [Player] = []
        for i in stride(from: 0, to: result.count, by: 4) {
            var group = Array(result[i..<min(i + 4, result.count)])
            group.shuffle()
            output.append(contentsOf: group)
        }
        return output
    }
    
    func generateSlot(index: Int) {
        guard index < slots.count else { return }
        let slot = slots[index]
        let available = availablePlayers(forSlotTime: slot.time)
        guard available.count >= 2 else {
            showToast("\(slot.time)에 가능한 인원이 부족해요 (\(available.count)명)")
            return
        }
        
        let sorted = available.sorted { a, b in
            if a.satOutLast && !b.satOutLast { return true }
            if !a.satOutLast && b.satOutLast { return false }
            return a.playCount < b.playCount
        }
        
        // Doubles courts first, then singles if remainder >= 2
        let doublesCourts = min(selectedCourtCount, available.count / 4)
        let remainder = available.count - doublesCourts * 4
        let singlesCount = (doublesCourts < selectedCourtCount && remainder >= 2) ? 1 : 0
        let numPlaying = doublesCourts * 4 + singlesCount * 2
        
        let playing = Array(sorted.prefix(numPlaying))
        let sitters = Array(sorted.dropFirst(numPlaying))
        
        let playingIds = Set(playing.map { $0.id })
        for p in available {
            if let idx = players.firstIndex(where: { $0.id == p.id }) {
                players[idx].satOutLast = !playingIds.contains(p.id)
            }
        }
        
        let arranged = mixedArrange(playing)
        var courts: [Court] = []
        for i in 0..<doublesCourts {
            courts.append(Court(
                team1: [arranged[i * 4].id, arranged[i * 4 + 1].id],
                team2: [arranged[i * 4 + 2].id, arranged[i * 4 + 3].id]
            ))
        }
        if singlesCount > 0 {
            let base = doublesCourts * 4
            courts.append(Court(
                team1: [arranged[base].id],
                team2: [arranged[base + 1].id]
            ))
        }
        
        slots[index].courts = courts
        slots[index].sitters = sitters.map { $0.id }
        saveState()
        showToast("\(slot.time) 배정 완료")
    }
    
    func generateAllSlots() {
        guard presentPlayers.count >= 2 else {
            showToast("최소 2명이 출석해야 해요")
            return
        }
        for i in players.indices {
            players[i].satOutLast = false
        }
        var gen = 0
        for i in slots.indices {
            internalGenerate(index: i)
            gen += 1
        }
        saveState()
        showToast("\(gen)개 매치 전체 배정 완료!")
    }
    
    private func internalGenerate(index: Int) {
        let slot = slots[index]
        let available = availablePlayers(forSlotTime: slot.time)
        guard available.count >= 2 else { return }
        
        let sorted = available.sorted { a, b in
            if a.satOutLast && !b.satOutLast { return true }
            if !a.satOutLast && b.satOutLast { return false }
            return a.playCount < b.playCount
        }
        
        let doublesCourts = min(selectedCourtCount, available.count / 4)
        let remainder = available.count - doublesCourts * 4
        let singlesCount = (doublesCourts < selectedCourtCount && remainder >= 2) ? 1 : 0
        let numPlaying = doublesCourts * 4 + singlesCount * 2
        
        let playing = Array(sorted.prefix(numPlaying))
        let sitters = Array(sorted.dropFirst(numPlaying))
        
        let playingIds = Set(playing.map { $0.id })
        for p in available {
            if let idx = players.firstIndex(where: { $0.id == p.id }) {
                players[idx].satOutLast = !playingIds.contains(p.id)
            }
        }
        for p in playing {
            if let idx = players.firstIndex(where: { $0.id == p.id }) {
                players[idx].playCount += 1
            }
        }
        
        let arranged = mixedArrange(playing)
        var courts: [Court] = []
        for i in 0..<doublesCourts {
            courts.append(Court(
                team1: [arranged[i * 4].id, arranged[i * 4 + 1].id],
                team2: [arranged[i * 4 + 2].id, arranged[i * 4 + 3].id]
            ))
        }
        if singlesCount > 0 {
            let base = doublesCourts * 4
            courts.append(Court(
                team1: [arranged[base].id],
                team2: [arranged[base + 1].id]
            ))
        }
        
        slots[index].courts = courts
        slots[index].sitters = sitters.map { $0.id }
    }
    
    // MARK: - Reset
    
    func resetAll() {
        players = []
        nextId = 1
        rebuildSlots()
        saveState()
        showToast("초기화 완료!")
    }
    
    // MARK: - Toast
    
    func showToast(_ message: String) {
        toastMessage = message
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2.5))
            if toastMessage == message {
                toastMessage = nil
            }
        }
    }
    
    // MARK: - Persistence
    
    private var saveURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("tennis_match_v2.json")
    }
    
    func saveState() {
        let state = SavedState(
            players: players,
            slots: slots,
            nextId: nextId,
            startHour: startHour,
            startMinute: startMinute,
            endHour: endHour,
            endMinute: endMinute,
            selectedCourtCount: selectedCourtCount
        )
        if let data = try? JSONEncoder().encode(state) {
            try? data.write(to: saveURL)
        }
    }
    
    func loadState() {
        if let data = try? Data(contentsOf: saveURL),
           let state = try? JSONDecoder().decode(SavedState.self, from: data) {
            players = state.players
            slots = state.slots
            nextId = state.nextId
            startHour = state.startHour
            startMinute = state.startMinute
            endHour = state.endHour
            endMinute = state.endMinute
            selectedCourtCount = state.selectedCourtCount
            // Ensure slots match current time config
            let times = slotTimes
            if slots.count != times.count || !zip(slots, times).allSatisfy({ $0.0.time == $0.1 }) {
                rebuildSlots()
            }
        } else {
            rebuildSlots()
        }
    }
}

struct SavedState: Codable {
    let players: [Player]
    let slots: [TimeSlot]
    let nextId: Int
    let startHour: Int
    let startMinute: Int
    let endHour: Int
    let endMinute: Int
    let selectedCourtCount: Int
}
