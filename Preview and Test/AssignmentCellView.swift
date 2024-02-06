//
//  AssignmentCellView.swift
//  Preview and Test
//
//  Created by Per Friis on 08/10/2023.
//

import SwiftUI
import SwiftData

struct AssignmentCellView: View {
   var item: Assignment

    var body: some View {
        Group {

            VStack(alignment: .leading) {
                HStack {
                    item.image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 64, height: 64)
                        .mask(RoundedRectangle(cornerRadius: 8))
                        
                    VStack(alignment: .leading) {
                        Text("title")
                            .font(.caption2)
                        Text(item.name)
                            .font(.title)
                            .minimumScaleFactor(0.4)
                            .lineLimit(2)
                    }
                }

                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading) {
                        Text("details")
                            .font(.caption2)
                        Text(item.details)
                            .lineLimit(3)
                    }
                    VStack(alignment: .trailing) {
                        Text("due")
                            .font(.caption2)
                        Text(item.due.formatted(date: .abbreviated, time: .omitted))
                    }
                }
            }
            
        }
        .strikethrough(item.isCompleted, color: .blue)
    }
}

#Preview("Assignment") {
    do {
        let assignments = try [Assignment].load(filename: "assignments")
        return List {
            ForEach(assignments) { assignment in
                AssignmentCellView(item: assignment)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Image(.base2))
           
    } catch let error as NSError {
        fatalError(error.description)
    }
}

