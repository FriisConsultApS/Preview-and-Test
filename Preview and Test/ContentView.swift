//
//  ContentView.swift
//  Preview and Test
//
//  Created by Per Friis on 08/10/2023.
//

import SwiftUI
import SwiftData
import AuthenticationServices

struct ContentView: View {
    @Environment(\.modelContext) private var viewContext
    @Environment(CloudCoordinator.self) private var cloud

    @Query(sort: \Assignment.due) var tasks: [Assignment]
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(tasks) { item in
                        NavigationLink(value: item) {
                            AssignmentCellView(item: item)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                          
                if cloud.authenticationStatus == .unauthorized || cloud.authenticationStatus == .unknown {
                    SignInWithAppleButton(onRequest: swaRequest, onCompletion:swaResult)
                        .frame(maxHeight: 64)
                        .padding()
                } else if cloud.authenticationStatus == .updating {
                    ProgressView("Signing in With Apple")
                }
                
                
            }
            .navigationDestination(for: Assignment.self, destination: { assignment in
                AssignmentView(item: assignment)
            })
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("clear", systemImage: "trash", action: clearDatabase)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button("Add assignment", systemImage: "plus", action: addAssignments)
                }
            }
        }        
        .accessibilityIdentifier("taskList")
    }

    
    /// Prepare the Sign in With Apple request
    /// - Parameter request: the request setup
    private func swaRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = .none
    }
    
    /// Handle the response from Sign in With Apple
    /// - Parameter result: the result from the request
    private func swaResult(result: (Result<ASAuthorization,Error>)) {
        switch result {
        case .success(let authorization):
            cloud.signInWithApple(authorization)
        case .failure:
            break
        }
    }

    /// Clear all data in the database
    private func clearDatabase() {
        try? viewContext.delete(model: Assignment.self)
    }
    
    /// Load the files from the 3
    private func addAssignments() {
        withAnimation {
            do {
                let tasks = try [Assignment].load(filename: "assignments")
                 for task in tasks {
                    task.isCompleted = false
                    viewContext.insert(task)
                }
                try viewContext.save()
            } catch let error as NSError{
                print(error.description)
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                viewContext.delete(tasks[index])
            }
        }
    }
}

#Preview("Unauthorized") {
    ContentView()
        .modelContainer(for: Assignment.self, inMemory: true)
        .environment(CloudCoordinator.preview)
}

#Preview("Authorized") {
    ContentView()
        .modelContainer(for: Assignment.self, inMemory: true)
        .environment(CloudCoordinator.previewAuthorized)

}

#Preview("Updating") {
    ContentView()
        .modelContainer(for: Assignment.self, inMemory: true)
        .environment(CloudCoordinator.previewUpdating)

}

#Preview("With assignment") {
    do {
        let container = try ModelContainer(for: Assignment.self, configurations: .init(isStoredInMemoryOnly: true))
        let assignments = try [Assignment].load(filename: "assignments")
        for assignment in assignments {
            container.mainContext.insert(assignment)
        }
        return ContentView()
            .modelContainer(container)
            .environment(CloudCoordinator.previewAuthorized)
    } catch let error as NSError {
        print(error.description)
        print(error.userInfo)
        fatalError(error.description)
    }
}

