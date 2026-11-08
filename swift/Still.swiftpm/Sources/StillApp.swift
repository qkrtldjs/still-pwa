import SwiftUI

struct Thought: Identifiable, Codable { var id = UUID(); var title: String; var detail: String }

@MainActor final class ThoughtStore: ObservableObject {
 @Published var items: [Thought] = [] { didSet { persist() } }
 init() { if let d = UserDefaults.standard.data(forKey: "still.items"), let v = try? JSONDecoder().decode([Thought].self, from: d) { items = v } }
 func persist() { if let d = try? JSONEncoder().encode(items) { UserDefaults.standard.set(d, forKey: "still.items") } }
}

@main struct StillApp: App { @StateObject private var store = ThoughtStore(); var body: some Scene { WindowGroup { ContentView().environmentObject(store).tint(.primary) } } }

struct ContentView: View {
 @EnvironmentObject var store: ThoughtStore
 @State private var showingEditor = false
 @State private var title = ""
 @State private var detail = ""
 @State private var selection = 0
 var body: some View {
  NavigationStack {
   VStack(spacing: 0) {
    Picker("View", selection: $selection) { Text("Mind").tag(0); Text("Library").tag(1) }.pickerStyle(.segmented).padding()
    if selection == 0 { MindView(thoughts: store.items) } else { List(store.items) { item in VStack(alignment: .leading, spacing: 6) { Text(item.title).font(.headline); Text(item.detail).font(.subheadline).foregroundStyle(.secondary) } } }
   }
   .navigationTitle("still.")
   .toolbar { Button { showingEditor = true } label: { Image(systemName: "plus") } }
   .sheet(isPresented: $showingEditor) { NavigationStack { Form { TextField("Title", text: $title); TextField("Thought or link", text: $detail, axis: .vertical).lineLimit(4...8) }.navigationTitle("New Thought").toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { showingEditor = false } }; ToolbarItem(placement: .confirmationAction) { Button("Save") { let t = title.trimmingCharacters(in: .whitespacesAndNewlines); guard !t.isEmpty else { return }; store.items.append(Thought(title: t, detail: detail)); title = ""; detail = ""; showingEditor = false } } } } }
  }
 }
}

struct MindView: View {
 let thoughts: [Thought]
 @State private var offsets: [UUID: CGSize] = [:]
 var body: some View {
  GeometryReader { geo in
   TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
    let t = timeline.date.timeIntervalSinceReferenceDate
    ZStack {
     Canvas { context, size in
      let points = thoughts.enumerated().map { i, thought -> CGPoint in
       let a = Double(i) * 2.39996
       let radius = 55.0 * sqrt(Double(i) + 1)
       let offset = offsets[thought.id] ?? .zero
       return CGPoint(x: size.width/2 + cos(a)*radius + offset.width + sin(t/2.5+Double(i))*2, y: size.height/2 + sin(a)*radius + offset.height + cos(t/2.8+Double(i))*2)
      }
      for i in points.indices { for j in points.indices where j > i {
       let lhs = Set((thoughts[i].title + " " + thoughts[i].detail).lowercased().split(separator: " ").map(String.init))
       let rhs = Set((thoughts[j].title + " " + thoughts[j].detail).lowercased().split(separator: " ").map(String.init))
       if !lhs.isDisjoint(with: rhs) { var p = Path(); p.move(to: points[i]); p.addLine(to: points[j]); context.stroke(p, with: .color(.primary.opacity(0.15)), lineWidth: 1) }
      } }
     }
     ForEach(Array(thoughts.enumerated()), id: \.element.id) { i, thought in
      let angle = Double(i)*2.39996
      let radius = 55.0*sqrt(Double(i)+1)
      Text(thought.title).font(.caption).lineLimit(1).frame(width: 92,height: 92).background(Circle().stroke(.primary.opacity(0.25),lineWidth: 1)).offset(x: cos(angle)*radius + (offsets[thought.id]?.width ?? 0) + sin(t/2.5+Double(i))*2, y: sin(angle)*radius + (offsets[thought.id]?.height ?? 0) + cos(t/2.8+Double(i))*2).gesture(DragGesture().onChanged { v in offsets[thought.id] = v.translation })
     }
    }.frame(maxWidth: .infinity,maxHeight: .infinity)
   }
  }
 }
}
