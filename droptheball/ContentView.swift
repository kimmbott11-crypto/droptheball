//
//  ContentView.swift
//  droptheball
//
//  Created by 김용덕 on 3/5/26.
//

import SwiftUI

struct ContentView: View {
    @State private var manager = MatchManager()
    @State private var showPlayers = false
    @State private var showSettings = false
    @State private var showSummary = false
    @State private var showResetAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Config bar
                    configBar
                    
                    // Match slots
                    VStack(spacing: 10) {
                        ForEach(Array(manager.slots.enumerated()), id: \.element.id) { index, slot in
                            SlotCardView(slot: slot, slotIndex: index, manager: manager)
                        }
                    }
                    
                    
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color.white)
            .navigationTitle("Drop the Ball")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 14))
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 14) {
                        Button(action: { showPlayers = true }) {
                            HStack(spacing: 3) {
                                Image(systemName: "person.2")
                                    .font(.system(size: 13))
                                Text("\(manager.presentCount)")
                                    .font(.system(size: 12, weight: .bold))
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showPlayers) {
                NavigationStack {
                    PlayerListView(manager: manager)
                        .navigationTitle("플레이어 관리")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("닫기") { showPlayers = false }
                            }
                        }
                }
            }
            .sheet(isPresented: $showSettings) {
                settingsSheet
            }
            .sheet(isPresented: $showSummary) {
                NavigationStack {
                    summarySheet
                        .navigationTitle("전체 배정표")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("닫기") { showSummary = false }
                            }
                        }
                }
            }
            .overlay(alignment: .bottom) {
                if let message = manager.toastMessage {
                    Text(message)
                        .font(.system(size: 14, weight: .semibold))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 11)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                        .padding(.bottom, 20)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: manager.toastMessage)
            .alert("세션 초기화", isPresented: $showResetAlert) {
                Button("취소", role: .cancel) { }
                Button("초기화", role: .destructive) {
                    manager.resetAll()
                }
            } message: {
                Text("모든 배정 및 통계가 삭제됩니다.")
            }
        }
        .tint(.green)
    }
    
    // MARK: - Config Bar
    
    private var configBar: some View {
        HStack(spacing: 10) {
            Button(action: { manager.generateAllSlots() }) {
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 11))
                    Text("전체 배정")
                        .font(.system(size: 13, weight: .semibold))
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            .tint(.green)
            
            Button(action: { showSummary = true }) {
                HStack(spacing: 4) {
                    Image(systemName: "tablecells")
                        .font(.system(size: 11))
                    Text("배정표 보기")
                        .font(.system(size: 13, weight: .semibold))
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            
            Spacer()
            
            Button(action: { showResetAlert = true }) {
                Image(systemName: "trash")
                    .font(.system(size: 13))
                    .foregroundStyle(.red.opacity(0.6))
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Settings Sheet
    
    private var settingsSheet: some View {
        NavigationStack {
            Form {
                Section("게임 시간") {
                    HStack {
                        Text("시작")
                        Spacer()
                        Picker("시", selection: $manager.startHour) {
                            ForEach(MatchManager.hourOptions, id: \.self) { h in
                                Text("\(h)시").tag(h)
                            }
                        }
                        .pickerStyle(.menu)
                        Picker("분", selection: $manager.startMinute) {
                            ForEach(MatchManager.minuteOptions, id: \.self) { m in
                                Text(String(format: "%02d분", m)).tag(m)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    HStack {
                        Text("종료")
                        Spacer()
                        Picker("시", selection: $manager.endHour) {
                            ForEach(MatchManager.hourOptions, id: \.self) { h in
                                Text("\(h)시").tag(h)
                            }
                        }
                        .pickerStyle(.menu)
                        Picker("분", selection: $manager.endMinute) {
                            ForEach(MatchManager.minuteOptions, id: \.self) { m in
                                Text(String(format: "%02d분", m)).tag(m)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    Text("총 \(manager.slotTimes.count)개 매치 (30분씩)")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                
                Section("코트 수") {
                    Picker("코트 수", selection: $manager.selectedCourtCount) {
                        ForEach(1...5, id: \.self) { n in
                            Text("\(n)개").tag(n)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("적용") {
                        manager.updateTimeRange()
                        showSettings = false
                    }
                    .fontWeight(.semibold)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") { showSettings = false }
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    // MARK: - Summary Sheet
    
    private var summarySheet: some View {
        Group {
            if manager.slots.contains(where: { $0.courts != nil }) {
                ScrollView {
                    SummaryView(manager: manager)
                        .padding(16)
                }
                .background(Color(.systemGroupedBackground))
            } else {
                ContentUnavailableView {
                    Label("배정 없음", systemImage: "tablecells")
                } description: {
                    Text("먼저 매치를 배정해주세요")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
