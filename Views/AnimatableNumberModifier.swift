import SwiftUI

struct AnimatableNumberModifier: AnimatableModifier {
    var animatableData: Double
    
    init(value: Double) {
        self.animatableData = value
    }
    
    func body(content: Content) -> some View {
        Text(String(Int(animatableData)))
    }
}

extension View {
    func animatableNumber(value: Double) -> some View {
        self.modifier(AnimatableNumberModifier(value: value))
    }
}
