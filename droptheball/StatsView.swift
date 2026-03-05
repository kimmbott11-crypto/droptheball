//
//  StatsView.swift
//  droptheball
//

import SwiftUI

struct StatsView: View {
    @Bindable var manager: MatchManager
    
    private var sortedPlayers: [Player] {
        manager.players.sorted { $0.playCount > $1.playCount }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("통계")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.secondary)
            
            if manager.players.isEmpty {
                Text("플레이어를 추가하면 통계가 표시됩니다")
                    .font(.system(size: 13))
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 12)
            } else {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 120), spacing: 6)
                ], spacing: 6) {
                    ForEach(sortedPlayers) { player in
                        HStack {
                            Text(player.name)
                                .font(.system(size: 13, weight: .medium))
                                .lineLimit(1)
                            Spacer()
                            Text("\(player.playCount)회")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(.green)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray5), lineWidth: 0.5)
                        )
                    }
                }
            }
        }
    }
}
