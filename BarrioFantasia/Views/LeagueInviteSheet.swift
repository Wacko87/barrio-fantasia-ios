import SwiftUI

public struct LeagueInviteSheet: View {
    @Environment(\.dismiss) private var dismiss
    private let code = InviteCodeService.shared.currentLeagueCode
    @State private var copied: Bool = false

    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 6) {
                    Text("Invitar a Compañeros")
                        .font(.title2)
                        .fontWeight(.black)
                    Text("Pídeles que escaneen este código QR o introduce el código de pandilla en su app.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 10)

                // QR Code Card
                if let qrImage = InviteCodeService.shared.generateQRCodeImage(from: "barriofantasia://join?code=\(code)") {
                    Image(uiImage: qrImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .padding(16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
                }

                // Code Display with Copy Button
                VStack(spacing: 8) {
                    Text("CÓDIGO DE LA PANDILLA")
                        .font(.caption2)
                        .fontWeight(.heavy)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 12) {
                        Text(code)
                            .font(.system(size: 28, weight: .black, design: .monospaced))
                            .foregroundStyle(Color(red: 0.89, green: 0.11, blue: 0.15))

                        Button {
                            UIPasteboard.general.string = code
                            withAnimation { copied = true }
                            HapticManager.shared.notification(.success)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation { copied = false }
                            }
                        } label: {
                            Image(systemName: copied ? "checkmark.circle.fill" : "doc.on.doc.fill")
                                .font(.title3)
                                .foregroundStyle(copied ? Color.green : Color.primary)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Copiar código de invitación")
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(Capsule())
                }

                Spacer()

                // Share Button
                let shareText = "⚽ ¡Únete a nuestra liga de fútbol en Barrio de Fantasía! Descarga la app e introduce el código: \(code)"
                ShareLink(item: shareText) {
                    HStack {
                        Image(systemName: "square.and.arrow.up.fill")
                        Text("Compartir por WhatsApp o Mensajes")
                    }
                    .font(.headline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(red: 0.89, green: 0.11, blue: 0.15))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
            .padding()
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}
