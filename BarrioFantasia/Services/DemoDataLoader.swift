import Foundation
import SwiftData

@MainActor
public final class DemoDataLoader {
    public static func loadSampleDataIfNeeded(context: ModelContext) {
        let playerDescriptor = FetchDescriptor<Player>()
        let count = (try? context.fetchCount(playerDescriptor)) ?? 0
        guard count == 0 else { return }

        // 1. Jugadores iniciales
        let players = [
            Player(id: "p1", name: "Alex Ruiz", nickname: "El Mago", number: 10, position: .med, avatarUrl: nil, matchesPlayed: 14, goals: 9, assists: 11, mvpCount: 5, avgRating: 8.5, marketValue: 24_000_000, fantasyTeam: "Galácticos del Barrio"),
            Player(id: "p2", name: "Oscar V.", nickname: "Wacko", number: 7, position: .del, avatarUrl: nil, matchesPlayed: 14, goals: 14, assists: 6, mvpCount: 4, avgRating: 8.2, marketValue: 22_500_000, fantasyTeam: "F.C. Pandilla"),
            Player(id: "p3", name: "Dani Sanz", nickname: "El Muro", number: 1, position: .por, avatarUrl: nil, matchesPlayed: 13, goals: 0, assists: 1, mvpCount: 3, avgRating: 7.9, marketValue: 18_000_000, fantasyTeam: "Muro Defensivo"),
            Player(id: "p4", name: "Carlos López", nickname: "Roca", number: 4, position: .def, avatarUrl: nil, matchesPlayed: 14, goals: 2, assists: 3, mvpCount: 1, avgRating: 7.8, marketValue: 15_000_000, fantasyTeam: "F.C. Pandilla"),
            Player(id: "p5", name: "Javi Martín", nickname: "Pulmón", number: 8, position: .med, avatarUrl: nil, matchesPlayed: 12, goals: 4, assists: 7, mvpCount: 2, avgRating: 7.5, marketValue: 16_000_000, fantasyTeam: "Tiki-Taka F.C."),
            Player(id: "p6", name: "Sergio Peña", nickname: "Pistolero", number: 9, position: .del, avatarUrl: nil, matchesPlayed: 11, goals: 10, assists: 2, mvpCount: 2, avgRating: 7.7, marketValue: 17_500_000, fantasyTeam: "Galácticos del Barrio"),
            Player(id: "p7", name: "David Castro", nickname: "Candado", number: 5, position: .def, avatarUrl: nil, matchesPlayed: 13, goals: 1, assists: 2, mvpCount: 1, avgRating: 7.4, marketValue: 13_500_000, fantasyTeam: "Muro Defensivo"),
            Player(id: "p8", name: "Rubén Soler", nickname: "Brújula", number: 6, position: .med, avatarUrl: nil, matchesPlayed: 10, goals: 3, assists: 5, mvpCount: 1, avgRating: 7.6, marketValue: 14_000_000, fantasyTeam: "Tiki-Taka F.C."),
            Player(id: "p9", name: "Marcos Vega", nickname: "Veloz", number: 11, position: .del, avatarUrl: nil, matchesPlayed: 12, goals: 7, assists: 4, mvpCount: 1, avgRating: 7.4, marketValue: 15_000_000, fantasyTeam: "F.C. Pandilla"),
            Player(id: "p10", name: "Pablo Gil", nickname: "Gato", number: 3, position: .def, avatarUrl: nil, matchesPlayed: 9, goals: 0, assists: 1, mvpCount: 0, avgRating: 7.2, marketValue: 11_000_000, fantasyTeam: "Muro Defensivo")
        ]

        for p in players {
            context.insert(p)
        }

        // 2. Partidos
        let calendar = Calendar.current
        let today = Date()
        let matchPlayedAt = calendar.date(byAdding: .hour, value: -6, to: today) // 6 horas transcurridas (quedan 18h de votación)
        let futureDate = calendar.date(byAdding: .day, value: 3, to: today) ?? today
        let pastDate = calendar.date(byAdding: .day, value: -7, to: today) ?? today

        let match1 = Match(
            id: "m-j14",
            title: "Derbi de Otoño · Jornada 14",
            date: today,
            location: "Polideportivo Municipal Pista 1",
            format: .f7,
            status: .jugado,
            playedAt: matchPlayedAt,
            scoreTeamA: 5,
            scoreTeamB: 4,
            signedPlayerIds: ["p1", "p2", "p3", "p4", "p5", "p6", "p7", "p8", "p9", "p10"],
            teamAPlayerIds: ["p1", "p2", "p4", "p5", "p9"],
            teamBPlayerIds: ["p3", "p6", "p7", "p8", "p10"]
        )

        let match2 = Match(
            id: "m-j15",
            title: "Pachanga de Viernes · Jornada 15",
            date: futureDate,
            location: "Campo Barrio La Fantasía",
            format: .f7,
            status: .convocado,
            playedAt: nil,
            scoreTeamA: 0,
            scoreTeamB: 0,
            signedPlayerIds: ["p1", "p2", "p3", "p4", "p5", "p7"],
            teamAPlayerIds: [],
            teamBPlayerIds: []
        )

        let match3 = Match(
            id: "m-j13",
            title: "Clásico del Barrio · Jornada 13",
            date: pastDate,
            location: "Polideportivo Municipal Pista 2",
            format: .f7,
            status: .cerrado,
            playedAt: pastDate,
            scoreTeamA: 6,
            scoreTeamB: 3,
            signedPlayerIds: ["p1", "p2", "p3", "p4", "p5", "p6", "p7", "p8", "p9", "p10"],
            teamAPlayerIds: ["p2", "p3", "p6", "p8", "p9"],
            teamBPlayerIds: ["p1", "p4", "p5", "p7", "p10"]
        )

        context.insert(match1)
        context.insert(match2)
        context.insert(match3)

        // 3. Managers Fantasy
        let managers = [
            FantasyManager(id: "man1", teamName: "F.C. Pandilla", managerName: "Oscar", totalPoints: 482, weeklyPoints: 38, rank: 1, budget: 12_500_000, rosterPlayerIds: ["p2", "p4", "p9"], penalties: 0),
            FantasyManager(id: "man2", teamName: "Galácticos del Barrio", managerName: "Alex", totalPoints: 465, weeklyPoints: 42, rank: 2, budget: 8_000_000, rosterPlayerIds: ["p1", "p6"], penalties: 0),
            FantasyManager(id: "man3", teamName: "Muro Defensivo", managerName: "Dani", totalPoints: 438, weeklyPoints: 29, rank: 3, budget: 15_200_000, rosterPlayerIds: ["p3", "p7", "p10"], penalties: 0),
            FantasyManager(id: "man4", teamName: "Tiki-Taka F.C.", managerName: "Javi", totalPoints: 415, weeklyPoints: 31, rank: 4, budget: 19_000_000, rosterPlayerIds: ["p5", "p8"], penalties: -2)
        ]

        for m in managers {
            context.insert(m)
        }

        // 4. Logros
        let achievements = [
            Achievement(id: "ach1", title: "Pichichi de Oro", details: "Anota 15 o más goles en una sola temporada", iconName: "flame.fill", category: "Goles", isUnlocked: false, currentProgress: 14, targetProgress: 15),
            Achievement(id: "ach2", title: "El Muro Imbatible", details: "Mantén la portería a cero en 3 encuentros", iconName: "shield.checkered", category: "Defensa", isUnlocked: true, currentProgress: 3, targetProgress: 3),
            Achievement(id: "ach3", title: "Votante Ejemplar", details: "Envía tus valoraciones en menos de 24h durante 10 jornadas consecutivas", iconName: "star.bubble.fill", category: "Fair Play", isUnlocked: true, currentProgress: 10, targetProgress: 10),
            Achievement(id: "ach4", title: "MVP de la Pandilla", details: "Elegido mejor jugador del partido en 5 ocasiones", iconName: "trophy.fill", category: "Rendimiento", isUnlocked: false, currentProgress: 4, targetProgress: 5),
            Achievement(id: "ach5", title: "Centenario del Barrio", details: "Participa en 25 partidos oficiales", iconName: "figure.soccer", category: "Trayectoria", isUnlocked: false, currentProgress: 14, targetProgress: 25)
        ]

        for a in achievements {
            context.insert(a)
        }

        try? context.save()
    }
}
