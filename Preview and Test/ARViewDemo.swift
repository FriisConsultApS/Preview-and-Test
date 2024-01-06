//
//  ARViewDemo.swift
//  Preview and Test
//
//  Created by Per Friis on 06/01/2024.
//

import SwiftUI
import RealityKit

struct ARViewDemo: View {
    var body: some View {
        ARViewContainer(rotation: .zero)
    }
}


struct ARViewContainer: UIViewRepresentable {
    typealias UIViewType = ARView
    
    var rotation: SIMD3<Float>
    
    
    func makeUIView(context: Context) -> ARView {
        let arview = ARView(frame: .zero)
        //arview.cameraMode = .nonAR
        let sphere = MeshResource.generateBox(size: 0.05, cornerRadius: 0.001)
        
        let material = SimpleMaterial(color: .purple, isMetallic: true)
        let entity = ModelEntity(mesh: sphere, materials: [material])
        let anchor = AnchorEntity(world: rotation)
        anchor.addChild(entity)
        arview.scene.addAnchor(anchor)
        entity.name = .square
        return arview
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
        guard let entity = uiView.scene.findEntity(named: .square) else {
            return
        }
        
        entity.transform.rotation = simd_quatf(angle: 1, axis: rotation)
    }
}

fileprivate extension String {
    static let square = "square"
}

#Preview {
    ARViewDemo()
}
