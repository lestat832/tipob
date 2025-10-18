import SwiftUI

// Simple extension using native SwiftUI onTapGesture
// This avoids the gesture conflicts that occur when using .gesture(DragGesture)
extension View {
    func detectTaps(onTap: @escaping (GestureType) -> Void) -> some View {
        self.onTapGesture {
            onTap(.tap)
        }
    }
}
