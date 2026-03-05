//
//  SlotCardView.swift
//  droptheball
//

import SwiftUI

struct SlotCardView: View {
    let slot: TimeSlot
    let slotIndex: Int
    @Bindable var manager: MatchManager
    
    private var availableCount: Int {
        manager.availablePlayers(forSlotTime: slot.time).count
    }
    
    private let courtColors: [Color] = [
        .blue, .purple, .orange, .teal, .pink
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("매치 \(slotIndex + 1)")
                    .font(.system(size: 16, weight: .bold))
                
                Text(slot.time)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                
                Text("\(availableCount)명")
                    .font(.system(size: 11, weight: .medium))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2)
                    .background(Color(.systemGray6))
                    .foregroundStyle(.secondary)
                    .clipShape(Capsule())
                
                Spacer()
                
                Button(slot.courts != nil ? "재배정" : "배정") {
                    manager.generateSlot(index: slotIndex)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.mini)
                .tint(.green)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(.systemGray6).opacity(0.4))
            
            Divider()
            
            // Body
            if let courts = slot.courts {
                VStack(spacing: 8) {
                    ForEach(Array(courts.enumerated()), id: \.offset) { courtIndex, court in
                        courtRow(court: court, courtIndex: courtIndex)
                    }
                    if let sitters = slot.sitters, !sitters.isEmpty {
                        HStack(spacing: 4) {
                            Text("대기")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.black)
                            ForEach(sitters, id: \.self) { id in
                                Text(manager.playerName(for: id))
                                    .font(.system(size: 12, weight: .medium))
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 3)
                                    .background(Color(.systemGray5))
                                    .foregroundStyle(.primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(12)
            } else {
                HStack {
                    Text("배정 버튼을 눌러주세요")
                        .font(.system(size: 13))
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
        }
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray5), lineWidth: 0.5)
        )
    }
    
    private func courtRow(court: Court, courtIndex: Int) -> some View {
        let color = courtColors[courtIndex % courtColors.count]
        return HStack(spacing: 5) {
            // Court label with color
            Text("코트\(courtIndex + 1)")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(color.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 4))
            
            // Team 1
            HStack(spacing: 2) {
                ForEach(court.team1, id: \.self) { id in
                    Text(manager.playerName(for: id))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(color)
                        .lineLimit(1)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity)
                        .background(color.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
            }
            
            Text("vs")
                .font(.system(size: 10, weight: .black))
                .foregroundStyle(.secondary)
            
            // Team 2
            HStack(spacing: 2) {
                ForEach(court.team2, id: \.self) { id in
                    Text(manager.playerName(for: id))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(color)
                        .lineLimit(1)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity)
                        .background(color.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
            }
        }
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 6
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }
    
    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
        
        return (CGSize(width: maxWidth, height: y + rowHeight), positions)
    }
}
