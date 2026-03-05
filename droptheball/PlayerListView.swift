//
//  PlayerListView.swift
//  droptheball
//

import SwiftUI

struct PlayerListView: View {
    @Bindable var manager: MatchManager
    @State private var newPlayerName = ""
    @State private var newArriveTime = ""
    @State private var newDepartTime = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Add player section
            addPlayerSection
            
            Divider()
            
            // Player list
            if manager.players.isEmpty {
                ContentUnavailableView {
                    Label("플레이어 없음", systemImage: "person.2")
                } description: {
                    Text("위에서 이름과 시간을 입력하고 추가하세요")
                }
                .frame(maxHeight: .infinity)
            } else {
                List {
                    ForEach(manager.players) { player in
                        PlayerRow(player: player, manager: manager)
                            .listRowInsets(EdgeInsets(top: 3, leading: 12, bottom: 3, trailing: 12))
                    }
                    .onDelete { indexSet in
                        for i in indexSet {
                            manager.removePlayer(id: manager.players[i].id)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .onAppear {
            if newArriveTime.isEmpty {
                newArriveTime = manager.arriveOptions.first ?? "19:00"
            }
            if newDepartTime.isEmpty {
                newDepartTime = manager.departOptions.last ?? "22:00"
            }
        }
    }
    
    private var addPlayerSection: some View {
        VStack(spacing: 8) {
            // Row 1: name + add button
            HStack(spacing: 6) {
                TextField("이름", text: $newPlayerName)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 15))
                    .frame(maxWidth: .infinity)
                    .onSubmit { addPlayer() }
                
                // Time pickers as styled text
                Text(newArriveTime)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay {
                        Picker("", selection: $newArriveTime) {
                            ForEach(manager.arriveOptions, id: \.self) { t in
                                Text(t).tag(t)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .opacity(0.02)
                    }
                
                Text("~")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.secondary)
                
                Text(newDepartTime)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay {
                        Picker("", selection: $newDepartTime) {
                            ForEach(manager.departOptions, id: \.self) { t in
                                Text(t).tag(t)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .opacity(0.02)
                    }
                
                Button(action: addPlayer) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.green)
                }
                .buttonStyle(.plain)
            }
            
            // Info line
            HStack {
                Text("\(manager.presentCount)명 출석")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.green)
                Spacer()
                Text("탭: 출석 토글 · 스와이프: 삭제")
                    .font(.system(size: 10))
                    .foregroundStyle(.quaternary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
    
    private func addPlayer() {
        manager.addPlayer(name: newPlayerName, arrive: newArriveTime, depart: newDepartTime)
        newPlayerName = ""
    }
}

struct PlayerRow: View {
    let player: Player
    @Bindable var manager: MatchManager
    
    var body: some View {
        HStack(spacing: 4) {
            // Presence dot
            Circle()
                .fill(player.isPresent ? Color.green : Color(.systemGray4))
                .frame(width: 8, height: 8)
            
            // Name - compact
            Text(player.name)
                .font(.system(size: 14, weight: .medium))
                .lineLimit(1)
                .frame(maxWidth: 60, alignment: .leading)
            
            Spacer(minLength: 0)
            
            // Time display as text buttons
            Text(player.arriveTime)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.blue)
                .overlay {
                    Picker("", selection: Binding(
                        get: { player.arriveTime },
                        set: { manager.updateArriveTime(id: player.id, time: $0) }
                    )) {
                        ForEach(manager.arriveOptions, id: \.self) { t in
                            Text(t).tag(t)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .opacity(0.02)
                }
            
            Text("-")
                .font(.system(size: 12))
                .foregroundStyle(.quaternary)
            
            Text(player.departTime)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.blue)
                .overlay {
                    Picker("", selection: Binding(
                        get: { player.departTime },
                        set: { manager.updateDepartTime(id: player.id, time: $0) }
                    )) {
                        ForEach(manager.departOptions, id: \.self) { t in
                            Text(t).tag(t)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .opacity(0.02)
                }
            
            // Play count
            Text("\(player.playCount)회")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(player.isPresent ? .green : .secondary)
                .frame(width: 30, alignment: .trailing)
        }
        .opacity(player.isPresent ? 1 : 0.45)
        .contentShape(Rectangle())
        .onTapGesture {
            manager.togglePresent(id: player.id)
        }
    }
}
