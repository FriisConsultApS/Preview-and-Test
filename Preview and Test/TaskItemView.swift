//
//  TaskItemView.swift
//  Preview and Test
//
//  Created by Per Friis on 08/10/2023.
//

import SwiftUI
import CoreBluetooth

struct TaskItemView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(DeviceController.self) private var deviceController

    @State var item: TaskItem
    @State private var showList = false
    @State private var sensor: (any SensorDeviceProtocol)?

    var body: some View {


        VStack(alignment: .leading) {
                Text("due")
                    .font(.caption2)
                Text(item.due.orDistanceFuture.formatted(date: .abbreviated, time: .omitted))


            Text("details")
                .font(.caption2)
            Text(item.details.orEmpty)

            Toggle(isOn: $item.isCompleted) {
                Text("Is completed")
            }
            .onChange(of: item.isCompleted) {
                guard $0 != $1 else { return }
                try? context.save()
            }
            Spacer()
            if let sensor {
                SensorTagView(sensorTag: sensor)
            }
            HStack {
                Button {
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
        .navigationTitle(item.name.orEmpty)
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
    let task = TaskItem.emergencyEvacuationDrill(in: .preview)
    return NavigationStack {
        TaskItemView(item: task)

    }
    .environment(\.managedObjectContext, .preview)
    .environment(DeviceController())
}
