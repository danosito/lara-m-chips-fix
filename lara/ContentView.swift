//
//  ContentView.swift
//  lara
//
//  Created by ruter on 23.03.26.
//

import SwiftUI
import Combine

final class ExploitViewModel: ObservableObject {
    @Published var logs: [String] = []
    @Published var running: Bool = false
    @Published var safeMode: Bool = true

    private let exploit = kexploit()

    func start() {
        guard !running else { return }
        running = exploit.run(callback: { [weak self] message in
            DispatchQueue.main.async {
                self?.logs.append(message)
                self?.running = self?.exploit.isRunning() ?? false
            }
        }, safeMode: safeMode)
    }

    func findOffsets() {
        guard !running else { return }
        running = exploit.findOffsets(callback: { [weak self] message in
            DispatchQueue.main.async {
                self?.logs.append(message)
                self?.running = self?.exploit.isRunning() ?? false
            }
        }, safeMode: safeMode)
    }

    func stop() {
        exploit.stop()
        running = false
    }

    func clear() {
        logs.removeAll()
    }
}

struct ContentView: View {
    @StateObject private var vm = ExploitViewModel()

    var body: some View {
        NavigationStack {
            List {
                Toggle("Safe Mode", isOn: $vm.safeMode)
                    .disabled(vm.running)

                Button("Find Offsets") {
                    vm.findOffsets()
                }
                .disabled(vm.running)

                Button(vm.running ? "Running..." : "Run Darksword") {
                    vm.start()
                }
                .disabled(vm.running)
                
                Button("Stop") {
                    vm.stop()
                }
                .disabled(!vm.running)
                
                Button("Clear Logs") {
                    vm.clear()
                }
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(Array(vm.logs.enumerated()), id: \.offset) { _, line in
                            Text(line)
                                .font(.system(.footnote, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .selectionDisabled(false)
                    }
                }
            }
            .navigationTitle("lara")
        }
    }
}
