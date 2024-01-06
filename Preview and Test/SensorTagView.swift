//
//  SensorTagView.swift
//  Preview and Test
//
//  Created by Per Friis on 09/10/2023.
//

import SwiftUI
import Charts

struct SensorTagView: View {
    var sensorTag: any SensorDeviceProtocol
    @State private var batteryState: BatteryStatus = .na
    @State private var button:  DeviceButtons = .all
    @State private var luxOverTime: [ValueOverTime] = []
    @State private var pressureOverTime: [ValueOverTime] = []
    @State private var humidityOverTime: [ValueOverTime] = []
    @State private var gyroscope: SIMD3<Double> = .zero
    @State private var update: Date = .distantPast
    
    @State private var showDetails:  Bool = false
    
    
    var body: some View {
        VStack {
            Text(sensorTag.name)
                .font(.title)
            DisclosureGroup( isExpanded: $showDetails) {
                VStack {
                    Text(sensorTag.name)
                    Text(sensorTag.modelNumber)
                    Text(sensorTag.serialNumber)
                    HStack {
                        Text(sensorTag.softwareRevision)
                        Text(sensorTag.firmwareRevision)
                    }
                    Text(sensorTag.hardwareRevision)
                    
                }
                .border(.yellow)
            } label: {
                
                Image(systemName: "i.circle")
                    .frame(maxWidth: .infinity)
            }
            
            HStack {
                Text(batteryState.value.formatted(.percent))
                batteryState.image
            }
            
            button.image
                .imageScale(.large)
                .font(.largeTitle)
                .frame(maxWidth: .infinity)
                .animation(.easeIn, value: button.rawValue)
            
            
            Chart {
                ForEach(luxOverTime, id: \.timeStamp) { item in
                    LineMark(x: .value("timestamp", item.timeStamp),
                             y: .value("lux", item.value),
                             series: .value("Sensor", "Optical"))
                }
                
                ForEach(humidityOverTime, id: \.timeStamp) { humidity in
                    LineMark(x:.value("timestamp", humidity.timeStamp),
                             y: .value("humidity", humidity.value))
                }
                
                ForEach(pressureOverTime, id:\.timeStamp) { temperature in
                    BarMark(x: .value("timestamp", temperature.timeStamp),
                            y: .value("°c", temperature.value))
                }
                
            }
            .animation(.default, value: update)
            
            ARViewContainer(rotation: SIMD3<Float>(x: Float(gyroscope.x), y: Float(gyroscope.y), z: Float(gyroscope.z)))
                
            
//            Image(systemName: "cube")
//                .imageScale(.large)
//                .font(.largeTitle)
//                .rotation3DEffect(.degrees(gyroscope.x),axis: (x:1.0, y: 0.0, z: 0.0))
//                .rotation3DEffect(.degrees(gyroscope.y),axis: (x:0.0, y: 1.0, z: 0.0))
//                .rotation3DEffect(.degrees(gyroscope.z),axis: (x:0.0, y: 0.0, z: 1.0))
//                .animation(.default, value: gyroscope)
            
            
        }
        .task {
            Task {
                for await lux in sensorTag.lux {
                    luxOverTime.append(.init(timeStamp: .now, value: lux / 100))
                    self.update = .now
                    if luxOverTime.count  > 100 {
                        luxOverTime.removeFirst()
                    }
                }
            }
            
            Task {
                for await gyroscope in sensorTag.gyroscope { self.gyroscope = gyroscope  }
            }
            
            
            Task {
                for await humidity in sensorTag.humidity {
                    self.update = .now
                    self.humidityOverTime.append(.init(timeStamp: .now, value: humidity * 100))
                    if humidityOverTime.count > 100 {
                        humidityOverTime.removeFirst()
                    }
                }
            }
            
            Task {
                for await pressure in sensorTag.barometic {
                    self.pressureOverTime.append(.init(timeStamp: .now, value: pressure))
                    self.update = .now
                    if pressureOverTime.count > 100 {
                        pressureOverTime.removeFirst()
                    }
                }
            }
            
            Task { for await batteryState in sensorTag.battery { self.batteryState = batteryState } }
            
            Task { for await button in sensorTag.buttons { self.button = button }}
        }
    }
}

struct ValueOverTime {
    var timeStamp: Date
    var value: Double
}

#Preview {
    SensorTagView(sensorTag: SensorTagPreview())
}
