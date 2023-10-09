//
//  TaskItemCell.swift
//  Preview and Test
//
//  Created by Per Friis on 08/10/2023.
//

import SwiftUI

struct TaskItemCell: View {
    var item: TaskItem

    var body: some View {
        Group {

            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("title")
                            .font(.caption2)
                        Text(item.name.orEmpty)
                            .font(.title)
                    }
                    Spacer()

                    VStack(alignment: .leading) {
                        Text("due")
                            .font(.caption2)
                        Text(item.due.orDistanceFuture.formatted(date: .abbreviated, time: .omitted))
                    }


                }
                Text("details")
                    .font(.caption2)
                Text(item.details.orEmpty)
                    .lineLimit(3)
            }
        }
        .strikethrough(item.isCompleted, color: .blue)
    }
}

#Preview {
    let water = TaskItem.checkWaterSupply(in: PersistenceController.preview.container.viewContext)
    let task2 = TaskItem.conductSoilAnalysis(in: .preview)
    return List {
        TaskItemCell(item: water)
        TaskItemCell(item: task2)
    }

}
