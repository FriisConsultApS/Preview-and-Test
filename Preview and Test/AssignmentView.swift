//
//  AssignmentView.swift
//  Preview and Test
//
//  Created by Per Friis on 08/10/2023.
//

import SwiftUI
import CoreBluetooth
import SwiftData

struct AssignmentView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(DeviceController.self) private var deviceController
    
    @Bindable var item: Assignment
    
    @State private var showList = false
    @State private var sensor: (any SensorDeviceProtocol)?
    
    var body: some View {
        
        ZStack {
            VStack {
                VStack(alignment: .leading) {
                    Text("due")
                        .font(.caption2)
                    Text(item.due.formatted(date: .abbreviated, time: .omitted))
                    
                    Text("details")
                        .font(.caption2)
                    Text(item.details)
                    
                    Toggle(isOn: $item.isCompleted) {
                        Text("completed")
                    }
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                Spacer()
                if let sensor {
                    SensorTagView(sensorTag: sensor)
                }
                HStack {
                    Button {
                        print(item.json.string)
                        deviceController.startBLE()
                        showList = true
                    } label: {
                        Text("use SensorTag")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(sensor != nil)
                    
                    Spacer()
                    
                    Button {
                        deviceController.disconnect()
                        sensor = nil
                    } label: {
                        Text("disconnect")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(sensor == nil)
                }
                .sheet(isPresented: $showList) {
                    List {
                        ForEach(deviceController.peripherals) { peripheral in
                            Button {
                                connect(peripheral)
                            } label: {
                                Text(peripheral.name.orEmpty)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .background {
            item.image
        }
        .navigationTitle(item.name)
        
    }
    
    func connect(_ peripheral: CBPeripheral) {
        Task {
            do {
                self.sensor = try await deviceController.connect(peripheral)
                self.showList = false
            } catch {
                print(error as NSError)
            }
        }
    }
}

#Preview {
    NavigationStack {
        AssignmentView(item: .checkWaterSupply)
    }
    .modelContainer(for: Assignment.self, inMemory: true)
    .environment(DeviceController())
}
