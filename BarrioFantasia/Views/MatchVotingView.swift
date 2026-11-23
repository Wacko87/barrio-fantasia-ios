import SwiftUI
import SwiftData

public struct MatchVotingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: VotingViewModel

    public init(match: Match, allPlayers: [Player]) {
        _viewModel = State(initialValue: VotingViewModel(match: match, allPlayers: allPlayers))
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Banner
                    votingRuleHeader

                    // Drafts List
                    ForEach($viewModel.drafts) { $draft in
                        playerVotingCard(draft: $draft)
                    }
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Votación 24h")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                submitBottomBar
            }
            .alert("¡Votaciones Enviadas!", isPresented: $viewModel.submissionComplete) {
                Button("Entendido") {
                    dismiss()
                }
            } message: {
                Text("Tus notas y elección de MVP han quedado registradas correctamente.")
            }
        }
    }

    private var votingRuleHeader: some View {
        HStack(spacing: 12) {
            Image(systemName: "info.circle.fill")
                .font(.title2)
                .foregroundStyle(Color(red: 0.89, green: 0.11, blue: 0.15))
            VStack(alignment: .leading, spacing: 2) {
                Text("Califica a tus compañeros")
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text("Asigna una nota de 1.0 a 10.0 y selecciona al jugador MVP del encuentro.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(14)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func playerVotingCard(draft: Binding<PlayerVoteDraft>) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            // Player info & MVP toggle
            HStack {
                Text("#\(draft.wrappedValue.player.number)")
                    .font(.caption)
                    .fontWeight(.black)
                    .frame(width: 32, height: 32)
                    .background(draft.wrappedValue.player.position.badgeColor.opacity(0.15))
                    .foregroundStyle(draft.wrappedValue.player.position.badgeColor)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(draft.wrappedValue.player.displayName)
                        .font(.headline)
                        .fontWeight(.bold)
                    Text(draft.wrappedValue.player.position.title)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    viewModel.setMvp(playerId: draft.wrappedValue.player.id)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: draft.wrappedValue.isMvp ? "star.fill" : "star")
                        Text("MVP")
                            .font(.caption2)
                            .fontWeight(.black)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(draft.wrappedValue.isMvp ? Color.yellow : Color(uiColor: .systemFill))
                    .foregroundStyle(draft.wrappedValue.isMvp ? Color.black : Color.secondary)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(draft.wrappedValue.isMvp ? "Jugador marcado como MVP del partido" : "Marcar a \(draft.wrappedValue.player.displayName) como MVP")
            }

            // Slider with score value
            VStack(spacing: 6) {
                HStack {
                    Text("Nota:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(String(format: "%.1f", draft.wrappedValue.score))
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(scoreColor(draft.wrappedValue.score))
                }

                Slider(
                    value: draft.score,
                    in: 1.0...10.0,
                    step: 0.5
                ) {
                    Text("Puntuación")
                }
                .tint(scoreColor(draft.wrappedValue.score))
                .accessibilityValue("\(String(format: "%.1f", draft.wrappedValue.score)) puntos")
            }

            // Optional remark
            TextField("Comentario opcional...", text: draft.notes)
                .font(.caption)
                .padding(8)
                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var submitBottomBar: some View {
        VStack {
            Button {
                viewModel.submitVotes(context: modelContext)
            } label: {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                    Text("Confirmar y Enviar Votaciones")
                }
                .font(.headline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(red: 0.89, green: 0.11, blue: 0.15))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isSubmitting)
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 6)
        }
        .background(.ultraThinMaterial)
    }

    private func scoreColor(_ score: Double) -> Color {
        if score >= 8.0 {
            return Color.green
        } else if score >= 6.0 {
            return Color.blue
        } else if score >= 5.0 {
            return Color.orange
        } else {
            return Color.red
        }
    }
}
