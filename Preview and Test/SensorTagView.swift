//
//  SensorTagView.swift
//  Preview and Test
//
//  Created by Per Friis on 09/10/2023.
//

import SwiftUI
import Charts

struct SensorTagView: View {
    var sensorTag: any SensorTagProtocol
    @State private var luxOverTime: [ValueOverTime] = []
    @State private var temperatureOverTime: [ValueOverTime] = []
    @State private var humidityOverTime: [ValueOverTime] = []
    @State private var pressureOverTime: [ValueOverTime] = []
    @State private var gyroscope: SIMD3<Double> = .zero


    var body: some View {
        VStack {
            Text(sensorTag.name)
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
            Text(sensorTag.battery.formatted(.percent))
            sensorTag.buttons.image
                .imageScale(.large)
                .font(.largeTitle)
                .frame(maxWidth: .infinity)

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

                ForEach(temperatureOverTime, id:\.timeStamp) { temperature in
                    BarMark(x: .value("timestamp", temperature.timeStamp),
                            y: .value("°c", temperature.value))
                }

            }
            Image(systemName: "cube")
                .imageScale(.large)
                .font(.largeTitle)
                .rotation3DEffect(.degrees(gyroscope.x),axis: (x:1.0, y: 0.0, z: 0.0))
                .rotation3DEffect(.degrees(gyroscope.y),axis: (x:0.0, y: 1.0, z: 0.0))
                .rotation3DEffect(.degrees(gyroscope.z),axis: (x:0.0, y: 0.0, z: 1.0))


        }
        .task {
            Task {
                for await lux in sensorTag.lux {
                    withAnimation {
                        luxOverTime.append(.init(timeStamp: .now, value: lux))
                        if luxOverTime.count  > 100 {
                            luxOverTime.removeFirst()
                        }

                    }
                }
            }
            Task {
                for await gyroscope in sensorTag.gyroscope {
                    withAnimation {
                        self.gyroscope = gyroscope
                    }
                }
            }

            Task {
                for await temperature in sensorTag.irTemperature {
                    withAnimation {
                        self.temperatureOverTime.append(.init(timeStamp: .now, value: temperature))
                        if temperatureOverTime.count > 100 {
                            temperatureOverTime.removeFirst()
                        }
                    }
                }
            }

            Task {
                for await humidity in sensorTag.humidity {
                    withAnimation {
                        self.humidityOverTime.append(.init(timeStamp: .now, value: humidity))
                        if humidityOverTime.count > 100 {
                            humidityOverTime.removeFirst()
                        }
                    }
                }
            }

            Task {
                for await pressure in sensorTag.pressur {
                    self.pressureOverTime.append(.init(timeStamp: .now, value: pressure))
                    if pressureOverTime.count > 100 {
                        pressureOverTime.removeFirst()
                    }
                }
            }
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
