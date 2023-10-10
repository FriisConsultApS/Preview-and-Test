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
    @State private var data: [LuxOverTime] = []
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
                ForEach(data, id: \.timeStamp) { item in
                    LineMark(x: .value("timestamp", item.timeStamp),
                             y: .value("lux", item.lux),
                             series: .value("Sensor", "Optical"))
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
                        data.append(.init(timeStamp: .now, lux: lux))
                        if data.count  > 100 {
                            data.removeFirst()
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
        }
    }
}

struct LuxOverTime {
    var timeStamp: Date
    var lux: Double
}

#Preview {
        SensorTagView(sensorTag: SensorTagPreview())
}
