//
//  SensorTagView.swift
//  Preview and Test
//
//  Created by Per Friis on 09/10/2023.
//

import SwiftUI

struct SensorTagView: View {
    var sensorTag: any SensorTagProtocol

    var body: some View {
        VStack {
            Text(sensorTag.name)
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
            Text(sensorTag.battery.formatted(.percent))
            sensorTag.buttons.image
                .imageScale(.large)
                .font(.largeTitle)
                .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
        SensorTagView(sensorTag: SensorTagPreview())
}
