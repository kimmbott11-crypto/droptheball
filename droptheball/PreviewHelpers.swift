//
//  PreviewHelpers.swift
//  droptheball
//

import SwiftUI

extension MatchManager {
    static var preview: MatchManager {
        let m = MatchManager()
        m.players = [
            Player(id: 1, name: "김철수", isPresent: true, arriveTime: "19:00", departTime: "22:00", playCount: 0, satOutLast: false),
            Player(id: 2, name: "이영희", isPresent: true, arriveTime: "19:00", departTime: "22:00", playCount: 0, satOutLast: false),
            Player(id: 3, name: "박민수", isPresent: true, arriveTime: "19:00", departTime: "22:00", playCount: 0, satOutLast: false),
            Player(id: 4, name: "정소연", isPresent: true, arriveTime: "19:00", departTime: "22:00", playCount: 0, satOutLast: false),
            Player(id: 5, name: "최준호", isPresent: true, arriveTime: "19:00", departTime: "21:00", playCount: 0, satOutLast: false),
            Player(id: 6, name: "한지민", isPresent: true, arriveTime: "19:00", departTime: "22:00", playCount: 0, satOutLast: false),
            Player(id: 7, name: "윤서준", isPresent: true, arriveTime: "19:30", departTime: "22:00", playCount: 0, satOutLast: false),
            Player(id: 8, name: "강미래", isPresent: true, arriveTime: "19:00", departTime: "22:00", playCount: 0, satOutLast: false),
            Player(id: 9, name: "조현우", isPresent: true, arriveTime: "20:00", departTime: "22:00", playCount: 0, satOutLast: false),
            Player(id: 10, name: "송다은", isPresent: true, arriveTime: "19:00", departTime: "21:00", playCount: 0, satOutLast: false),
        ]
        m.nextId = 11
        m.selectedCourtCount = 2
        m.rebuildSlots()
        m.generateAllSlots()
        return m
    }
}

#Preview("Slot with data") {
    ScrollView {
        VStack(spacing: 10) {
            let m = MatchManager.preview
            ForEach(Array(m.slots.prefix(2).enumerated()), id: \.element.id) { i, slot in
                SlotCardView(slot: slot, slotIndex: i, manager: m)
            }
        }
        .padding()
    }
}

#Preview("Summary") {
    let m = MatchManager.preview
    NavigationStack {
        ScrollView {
            SummaryView(manager: m)
                .padding()
        }
    }
}

#Preview("Players") {
    NavigationStack {
        PlayerListView(manager: MatchManager.preview)
            .navigationTitle("플레이어 관리")
            .navigationBarTitleDisplayMode(.inline)
    }
}
