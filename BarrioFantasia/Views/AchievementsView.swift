import SwiftUI
import SwiftData

public struct AchievementsView: View {
    @Query private var achievements: [Achievement]

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Summary
                    achievementsHeader

                    // Badges Grid
                    LazyVStack(spacing: 14) {
                        ForEach(achievements) { achievement in
                            achievementCard(achievement)
                        }
                    }
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Logros & Retos")
        }
    }

    private var achievementsHeader: some View {
        let unlockedCount = achievements.filter { $0.isUnlocked }.count
        return HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("VITRINA DE TROFEOS")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(red: 0.89, green: 0.11, blue: 0.15))

                Text("\(unlockedCount) de \(achievements.count) Desbloqueados")
                    .font(.title2)
                    .fontWeight(.black)

                Text("Completa retos para ganar insignias y prestigio en la pandilla")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 5)
                    .frame(width: 54, height: 54)

                Circle()
                    .trim(from: 0, to: achievements.isEmpty ? 0 : Double(unlockedCount) / Double(achievements.count))
                    .stroke(Color(red: 0.89, green: 0.11, blue: 0.15), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 54, height: 54)

                Text("\(achievements.isEmpty ? 0 : Int((Double(unlockedCount) / Double(achievements.count)) * 100))%")
                    .font(.caption2)
                    .fontWeight(.black)
            }
        }
        .padding(18)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func achievementCard(_ ach: Achievement) -> some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(ach.isUnlocked ? Color.yellow.opacity(0.2) : Color(uiColor: .systemFill))
                    .frame(width: 50, height: 50)

                Image(systemName: ach.iconName)
                    .font(.title3)
                    .foregroundStyle(ach.isUnlocked ? Color.orange : Color.secondary)
            }

            // Info & Progress
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(ach.title)
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                    if ach.isUnlocked {
                        Text("COMPLETADO")
                            .font(.system(size: 9, weight: .black))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.15))
                            .foregroundStyle(.green)
                            .clipShape(Capsule())
                    }
                }

                Text(ach.details)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                // Progress Bar
                VStack(spacing: 2) {
                    ProgressView(value: ach.progressPercent)
                        .tint(ach.isUnlocked ? Color.green : Color(red: 0.89, green: 0.11, blue: 0.15))

                    HStack {
                        Spacer()
                        Text("\(Int(ach.currentProgress)) / \(Int(ach.targetProgress))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
