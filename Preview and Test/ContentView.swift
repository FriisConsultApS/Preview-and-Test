//
//  ContentView.swift
//  Preview and Test
//
//  Created by Per Friis on 08/10/2023.
//

import SwiftUI
import CoreData
import AuthenticationServices

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(CloudCoordinator.self) private var cloudCoordinator

    @FetchRequest(
        sortDescriptors: TaskItem.defaultSort,
        animation: .default)
    private var items: FetchedResults<TaskItem>

    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        TaskItemView(item: item)
                    } label: {
                        TaskItemCell(item: item)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem {
                    switch cloudCoordinator.authenticationStatus {
                    case .unknown, .unauthorized:
                        SignInWithAppleButton { request in
                            request.requestedScopes = [.email, .fullName]
                        } onCompletion: { result in
                            switch result {
                            case .success(let authorization):
                                self.signIn(authorization)
                            case .failure:
                                break
                            }
                        }

                    case .updating:
                        ProgressView()


                    default:
                        EmptyView()

                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
        }
        .accessibilityIdentifier("taskList")
    }

    private func addItem() {
        withAnimation {
            do {
                let dtos = try [TaskItemDTO].load(filename: "tasks")
                for dto in dtos {
                    let taskItem = TaskItem(context: viewContext)
                    taskItem.dto =  dto
                    taskItem.isCompleted = false
                }
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func signIn(_ authorization: ASAuthorization) {
        cloudCoordinator.signInWithApple(authorization)
    }
}

#Preview("Unauthorized") {
    ContentView()
        .environment(\.managedObjectContext, .preview)
        .environment(CloudCoordinator.preview)
}

#Preview("Authorized") {
    ContentView()
        .environment(\.managedObjectContext, .preview)
        .environment(CloudCoordinator.previewAuthorized)

}

#Preview("Updating") {
    ContentView()
        .environment(\.managedObjectContext, .preview)
        .environment(CloudCoordinator.previewUpdating)

}
