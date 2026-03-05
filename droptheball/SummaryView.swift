//
//  SummaryView.swift
//  droptheball
//

import SwiftUI

struct SummaryView: View {
    @Bindable var manager: MatchManager
    
    private var assignedSlots: [TimeSlot] {
        manager.slots.filter { $0.courts != nil }
    }
    
    private var maxCourtCount: Int {
        assignedSlots.compactMap { $0.courts?.count }.max() ?? 0
    }
    
    private var hasSitters: Bool {
        assignedSlots.contains { ($0.sitters ?? []).count > 0 }
    }
    
    private let courtColors: [Color] = [
        .blue, .purple, .orange, .teal, .pink
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            headerRow
            
            ForEach(Array(assignedSlots.enumerated()), id: \.element.id) { index, slot in
                if index > 0 {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 1)
                }
                matchRow(slot: slot, matchNumber: index + 1, isEven: index % 2 == 0)
            }
        }
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.systemGray4), lineWidth: 0.5)
        )
    }
    
    // MARK: - Header
    
    private var headerRow: some View {
        HStack(spacing: 0) {
            Text("매치")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(.white)
                .frame(width: 62)
                .padding(.vertical, 10)
                .background(Color.black.opacity(0.75))
            
            ForEach(0..<max(maxCourtCount, 1), id: \.self) { i in
                Text("코트 \(i + 1)")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(courtColors[i % courtColors.count].opacity(0.75))
            }
            
            if hasSitters {
                Text("대기")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(.white)
                    .frame(width: 56)
                    .padding(.vertical, 10)
                    .background(Color.black)
            }
        }
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 14, topTrailingRadius: 14))
    }
    
    // MARK: - Match Row
    
    private func matchRow(slot: TimeSlot, matchNumber: Int, isEven: Bool) -> some View {
        let bgColor = isEven ? Color(.systemGray6).opacity(0.4) : Color.white
        
        return HStack(spacing: 0) {
            // Match number
            VStack(spacing: 2) {
                Text("매치\(matchNumber)")
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(.black)
                Text(slot.time)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.black.opacity(0.7))
            }
            .frame(width: 62)
            .padding(.vertical, 10)
            .background(bgColor)
            
            // Courts
            if let courts = slot.courts {
                ForEach(0..<max(maxCourtCount, 1), id: \.self) { i in
                    if i < courts.count {
                        courtCell(court: courts[i], colorIndex: i)
                            .background(bgColor)
                    } else {
                        Text("-")
                            .font(.system(size: 13))
                            .foregroundStyle(.quaternary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(bgColor)
                    }
                }
            }
            
            // Sitters
            if hasSitters {
                let sitters = slot.sitters ?? []
                VStack(spacing: 2) {
                    if sitters.isEmpty {
                        Text("-")
                            .font(.system(size: 13))
                            .foregroundStyle(.quaternary)
                    } else {
                        ForEach(sitters, id: \.self) { id in
                            Text(manager.playerName(for: id))
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.black.opacity(0.8))
                        }
                    }
                }
                .frame(width: 56)
                .padding(.vertical, 8)
                .background(bgColor)
            }
        }
    }
    
    // MARK: - Court Cell
    
    private func courtCell(court: Court, colorIndex: Int) -> some View {
        let color = courtColors[colorIndex % courtColors.count]
        return VStack(spacing: 3) {
            Text(court.team1.map { manager.playerName(for: $0) }.joined(separator: " · "))
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            
            Text("vs")
                .font(.system(size: 9, weight: .heavy))
                .foregroundStyle(Color(.systemGray4))
            
            Text(court.team2.map { manager.playerName(for: $0) }.joined(separator: " · "))
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
}
