//
//  Phrases.swift
//  PartyGame
//
//  Created by Lorenzo Fortes on 10/09/25.
//

import Foundation

enum PhrasesCategories: String, CaseIterable {
    case color = "Color"
    case feeling = "Feeling"
    case opinion = "Opinion"
    case size = "Size"
    case sound = "Sound"
    case action = "Action"
    case smell = "Smell"
    case random = "Random"
}

struct Phrase: Identifiable, Equatable, Hashable {
    let id = UUID()
    var text: String
    let category: PhrasesCategories
}

enum Phrases {
    static let all: [Phrase] = [
        // MARK: Colors
        Phrase(text: String(localized: "something red"), category: .color),
        Phrase(text: String(localized: "something yellow"), category: .color),
        Phrase(text: String(localized: "weird color"), category: .color),
        Phrase(text: String(localized: "something blue"), category: .color),
        Phrase(text: String(localized: "something black"), category: .color),
        Phrase(text: String(localized: "something green"), category: .color),
        Phrase(text: String(localized: "something brown"), category: .color),
        Phrase(text: String(localized: "something pink"), category: .color),
        Phrase(text: String(localized: "something shiny"), category: .color),
        Phrase(text: String(localized: "something transparent"), category: .color),
        Phrase(text: String(localized: "something colorful"), category: .color),
        Phrase(text: String(localized: "something bright"), category: .color),
        Phrase(text: String(localized: "something dark"), category: .color),
        Phrase(text: String(localized: "a color that hurts the eyes"), category: .color),
        Phrase(text: String(localized: "something that should glow in the dark"), category: .color),

        // MARK: Feelings
        Phrase(text: String(localized: "I hate this"), category: .feeling),
        Phrase(text: String(localized: "I can't live without this"), category: .feeling),
        Phrase(text: String(localized: "I love this"), category: .feeling),
        Phrase(text: String(localized: "this makes me happy"), category: .feeling),
        Phrase(text: String(localized: "I'm scared of this"), category: .feeling),
        Phrase(text: String(localized: "makes me laugh"), category: .feeling),
        Phrase(text: String(localized: "brings me peace"), category: .feeling),
        Phrase(text: String(localized: "I miss this"), category: .feeling),
        Phrase(text: String(localized: "this gives me nostalgia"), category: .feeling),
        Phrase(text: String(localized: "this reminds me of school"), category: .feeling),
        Phrase(text: String(localized: "this makes me hungry"), category: .feeling),
        Phrase(text: String(localized: "this gives me second-hand embarrassment"), category: .feeling),
        Phrase(text: String(localized: "this changed my life"), category: .feeling),
        Phrase(text: String(localized: "something that would taste terrible"), category: .feeling),
        Phrase(text: String(localized: "looks like it’s tired"), category: .feeling),
        Phrase(text: String(localized: "a taste of summer"), category: .feeling),
        Phrase(text: String(localized: "reminds me of a sad song"), category: .feeling),
        Phrase(text: String(localized: "a christmas memory"), category: .feeling),
        Phrase(text: String(localized: "a birthday memory"), category: .feeling),
        Phrase(text: String(localized: "a holiday memory"), category: .feeling),
        Phrase(text: String(localized: "the coolest vacation "), category: .feeling),
        Phrase(text: String(localized: "a joyful trip"), category: .feeling),
        Phrase(text: String(localized: "something that can ruin my day"), category: .feeling),
        Phrase(text: String(localized: "this feels like home"), category: .feeling),
        Phrase(text: String(localized: "a moment in family"), category: .feeling),
        Phrase(text: String(localized: "a day I didn't want to end"), category: .feeling),
        Phrase(text: String(localized: "a moment that felt like a movie"), category: .feeling),

        // MARK: Opinions
        Phrase(text: String(localized: "looks like a face"), category: .opinion),
        Phrase(text: String(localized: "something useless"), category: .opinion),
        Phrase(text: String(localized: "nice texture"), category: .opinion),
        Phrase(text: String(localized: "something cute"), category: .opinion),
        Phrase(text: String(localized: "something geometric"), category: .opinion),
        Phrase(text: String(localized: "this is beautiful"), category: .opinion),
        Phrase(text: String(localized: "looks expensive but isn’t"), category: .opinion),
        Phrase(text: String(localized: "something that’s definitely broken"), category: .opinion),
        Phrase(text: String(localized: "looks like something my grandma owns"), category: .opinion),
        Phrase(text: String(localized: "an object that only exists to annoy people"), category: .opinion),
        Phrase(text: String(localized: "something that deserves applause"), category: .opinion),
        Phrase(text: String(localized: "something i’d never tell anyone I own"), category: .opinion),
        Phrase(text: String(localized: "a look for the fashion magazines"), category: .opinion),
        Phrase(text: String(localized: "i want this as a gift"), category: .opinion),
        Phrase(text: String(localized: "something i'd gift a friend"), category: .opinion),
        Phrase(text: String(localized: "something i'd tattoo on my skin"), category: .opinion),
        Phrase(text: String(localized: "I would live in here"), category: .opinion),

        // MARK: Size
        Phrase(text: String(localized: "something tiny"), category: .size),
        Phrase(text: String(localized: "something huge"), category: .size),
        Phrase(text: String(localized: "something that doesn’t fit in a pocket"), category: .size),
        Phrase(text: String(localized: "something that should be smaller"), category: .size),
        Phrase(text: String(localized: "something perfectly round"), category: .size),
        Phrase(text: String(localized: "something that looks heavy but isn’t"), category: .size),

        // MARK: Sound
        Phrase(text: String(localized: "something that should sound like a duck"), category: .sound),
        Phrase(text: String(localized: "something that would make an annoying noise"), category: .sound),
        Phrase(text: String(localized: "something suspiciously silent"), category: .sound),
        Phrase(text: String(localized: "something that should yell 'surprise!'"), category: .sound),

        // MARK: Actions
        Phrase(text: String(localized: "something I want to squeeze"), category: .action),
        Phrase(text: String(localized: "something I would run away from"), category: .action),
        Phrase(text: String(localized: "something I want to kick"), category: .action),
        Phrase(text: String(localized: "something that should move but doesn’t"), category: .action),
        Phrase(text: String(localized: "something I'd trade for $"), category: .action),

        // MARK: Smell
        Phrase(text: String(localized: "something that must stink"), category: .smell),
        Phrase(text: String(localized: "something that smells like childhood"), category: .smell),
        Phrase(text: String(localized: "something that should smell like pizza"), category: .smell),
        Phrase(text: String(localized: "something that smells like holiday"), category: .smell),

        // MARK: Random / Funny
        Phrase(text: String(localized: "something that looks like a Pokémon"), category: .random),
        Phrase(text: String(localized: "something that looks hungover"), category: .random),
        Phrase(text: String(localized: "something that should be on the Moon"), category: .random),
        Phrase(text: String(localized: "something that looks alive"), category: .random),
        Phrase(text: String(localized: "something I’d adopt as a pet"), category: .random),
        Phrase(text: String(localized: "something that should have a mustache"), category: .random),
        Phrase(text: String(localized: "something that looks like it’s judging you"), category: .random),
        Phrase(text: String(localized: "something that belongs in a museum"), category: .random),
        Phrase(text: String(localized: "has cartoon villain energy"), category: .random),
        Phrase(text: String(localized: "a family secret"), category: .random),
        Phrase(text: String(localized: "a secret place to go"), category: .random),
        Phrase(text: String(localized: "a funny pet"), category: .random),
        Phrase(text: String(localized: "a moment in nature"), category: .random),
    ]
}
