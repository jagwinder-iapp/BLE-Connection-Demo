//
//  ContentView.swift
//  BLE Connection
//
//  Created by iapp on 22/04/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var bluetoothManager = BluetoothManager()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("ESP32 Relay Control")
                .font(.largeTitle)
                .padding()
            
            if bluetoothManager.isConnected {
                Text("Connected to ESP32")
                    .foregroundColor(.green)
                    .bold()
            } else {
                Text("Scanning for ESP32...")
                    .foregroundColor(.red)
                    .bold()
            }
            
            HStack {
                Button(action: {
                    let impactMed = UIImpactFeedbackGenerator(style: .heavy)
                        impactMed.impactOccurred()
                    bluetoothManager.sendCommand("ON")
                }) {
                    Text("Turn ON")
                        .font(.title)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                Button(action: {
                    let impactMed = UIImpactFeedbackGenerator(style: .heavy)
                        impactMed.impactOccurred()
                    bluetoothManager.sendCommand("OFF")
                }) {
                    Text("Turn OFF")
                        .font(.title)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .onAppear {
            bluetoothManager.startScanning()
        }
    }
}

#Preview {
    ContentView()
}
