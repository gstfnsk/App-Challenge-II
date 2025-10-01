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
        Phrase(text: "Something red", category: .color),
        Phrase(text: "Something yellow", category: .color),
        Phrase(text: "Weird color", category: .color),
        Phrase(text: "Something blue", category: .color),
        Phrase(text: "Something black", category: .color),
        Phrase(text: "Something green", category: .color),
        Phrase(text: "Something brown", category: .color),
        Phrase(text: "Something pink", category: .color),
        Phrase(text: "Something shiny", category: .color),
        Phrase(text: "Something transparent", category: .color),
        Phrase(text: "Something colorful", category: .color),
        Phrase(text: "Something bright", category: .color),
        Phrase(text: "Something dark", category: .color),
        Phrase(text: "A color that hurts the eyes", category: .color),
        Phrase(text: "Something that should glow in the dark", category: .color),

        // MARK: Feelings
        Phrase(text: "I hate this", category: .feeling),
        Phrase(text: "I can't live without this", category: .feeling),
        Phrase(text: "I love this", category: .feeling),
        Phrase(text: "This makes me happy", category: .feeling),
        Phrase(text: "I'm scared of this", category: .feeling),
        Phrase(text: "Makes me laugh", category: .feeling),
        Phrase(text: "Brings me peace", category: .feeling),
        Phrase(text: "I miss this", category: .feeling),
        Phrase(text: "This gives me nostalgia", category: .feeling),
        Phrase(text: "This reminds me of school", category: .feeling),
        Phrase(text: "This makes me hungry", category: .feeling),
        Phrase(text: "That is my favortite food", category: .feeling),
        Phrase(text: "On fridays this is my pastime", category: .feeling),
        Phrase(text: "My least favorite hobby", category: .feeling),
        Phrase(text: "Makes me cry everytime", category: .feeling),
        Phrase(text: "This gives me second-hand embarrassment", category: .feeling),
        Phrase(text: "A memory from a life I never lived", category: .feeling),
        Phrase(text: "The look of a dream that makes no sense at all", category: .feeling),
        Phrase(text: "The perfect definition of \"opression\"", category: .feeling),
        Phrase(text: "The perfect definition of \"freedom\"", category: .feeling),
        Phrase(text: "My spirit animal, without a doubt", category: .feeling),

        // MARK: Opinions
        Phrase(text: "Looks like a face", category: .opinion),
        Phrase(text: "Looks like a clown", category: .opinion),
        Phrase(text: "Something useless", category: .opinion),
        Phrase(text: "Nice texture", category: .opinion),
        Phrase(text: "Something cute", category: .opinion),
        Phrase(text: "Something geometric", category: .opinion),
        Phrase(text: "This is beautiful", category: .opinion),
        Phrase(text: "Looks expensive but isn’t", category: .opinion),
        Phrase(text: "Something that’s definitely broken", category: .opinion),
        Phrase(text: "Looks like something my grandma owns", category: .opinion),
        Phrase(text: "An object that only exists to annoy people", category: .opinion),
        Phrase(text: "Something unusual", category: .opinion),
        Phrase(text: "This is so 90s", category: .opinion),
        
        // MARK: Size
        Phrase(text: "Something tiny", category: .size),
        Phrase(text: "Something huge", category: .size),
        Phrase(text: "Something that doesn’t fit in a pocket", category: .size),
        Phrase(text: "Something that should be smaller", category: .size),
        Phrase(text: "Something perfectly round", category: .size),
        Phrase(text: "Something that looks heavy but isn’t", category: .size),

        // MARK: Sound
        Phrase(text: "Something that should sound like a duck", category: .sound),
        Phrase(text: "Something that would make an annoying noise", category: .sound),
        Phrase(text: "Something suspiciously silent", category: .sound),
        Phrase(text: "Something that should yell 'surprise!'", category: .sound),

        // MARK: Actions
        Phrase(text: "Something I want to squeeze", category: .action),
        Phrase(text: "Something I would run away from", category: .action),
        Phrase(text: "Something I want to kick", category: .action),
        Phrase(text: "Something that should move but doesn’t", category: .action),

        // MARK: Smell
        Phrase(text: "Something that must stink", category: .smell),
        Phrase(text: "Something that smells like childhood", category: .smell),
        Phrase(text: "Something that should smell like pizza", category: .smell),
        Phrase(text: "Something that smells like holiday", category: .smell),

        // MARK: Random / Funny
        Phrase(text: "Something that looks like a Pokémon", category: .random),
        Phrase(text: "Something that looks hungover", category: .random),
        Phrase(text: "Something that should be on the Moon", category: .random),
        Phrase(text: "Something that looks alive", category: .random),
        Phrase(text: "Something I’d adopt as a pet", category: .random),
        Phrase(text: "Something that should have a mustache", category: .random),
        Phrase(text: "Something that looks like it’s judging you", category: .random),
        Phrase(text: "My last brain cell trying to function", category: .random),
        Phrase(text: "My mom looks exactly like this", category: .opinion),
    ]
}
