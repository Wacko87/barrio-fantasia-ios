import SwiftUI
import Charts

public struct MatchScorePoint: Identifiable {
    public var id: String
    public var matchTitle: String
    public var score: Double

    public init(id: String, matchTitle: String, score: Double) {
        self.id = id
        self.matchTitle = matchTitle
        self.score = score
    }
}

public struct RatingHistoryChart: View {
    let scores: [MatchScorePoint]
    let averageRating: Double

    public init(scores: [MatchScorePoint], averageRating: Double) {
        self.scores = scores
        self.averageRating = averageRating
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Evolución de Rendimiento")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("Notas asignadas por compañeros en las últimas jornadas")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text(String(format: "%.1f Media", averageRating))
                        .font(.caption)
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(uiColor: .systemFill))
                .clipShape(Capsule())
            }

            // Swift Chart
            Chart {
                // Rule mark for average
                RuleMark(y: .value("Media", averageRating))
                    .foregroundStyle(Color.orange.opacity(0.7))
                    .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                    .annotation(position: .top, alignment: .trailing) {
                        Text("Media: \(String(format: "%.1f", averageRating))")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Color.orange)
                            .padding(2)
                    }

                // Line Plot
                ForEach(scores) { point in
                    LineMark(
                        x: .value("Jornada", point.matchTitle),
                        y: .value("Nota", point.score)
                    )
                    .foregroundStyle(Color(red: 0.89, green: 0.11, blue: 0.15))
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Jornada", point.matchTitle),
                        y: .value("Nota", point.score)
                    )
                    .foregroundStyle(Color(red: 0.89, green: 0.11, blue: 0.15))
                    .symbol(Circle())
                    .symbolSize(36)
                }
            }
            .chartYScale(domain: 4...10)
            .chartYAxis {
                AxisMarks(values: [4, 6, 8, 10]) { value in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            .frame(height: 180)
            .padding(.top, 6)
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
