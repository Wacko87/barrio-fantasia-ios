import Foundation
import SwiftUI
import TipKit

public struct VotingDeadlineTip: Tip {
    public var title: Text {
        Text("Plazo de Votación 24h")
    }

    public var message: Text? {
        Text("Tienes 24 horas desde que finaliza el partido para puntuar a tus compañeros y elegir al MVP. Votar a tiempo evita la penalización de -2 pts en Fantasy.")
    }

    public var image: Image? {
        Image(systemName: "clock.badge.checkmark")
    }
}
