// MARK: - Attribution: https://refactoring.guru/design-patterns/memento/swift/example#example-0

import Foundation

/*
 Originator
 
 Definition: original object that initiates a change in its own state.
 
 Roles:
    - defines a public API for saving its state into a <<Memento>> (to be consumed by caretaker)
    - defines a public API for restoring its state from a <<Memento>> (to be consumed by caretaker)
    - has internal mutable state that may change over time
*/

class Originator {
    
    private var _someMutableState: String {
        didSet {
            print("\(Self.self)._someMutableState changed from \(oldValue) to \(_someMutableState)")
        }
    }
    
    private static let prefixLength = 5
    
    
    // MARK: - Init
    
    init(_ mutableState: String = "initial_state") {
        self._someMutableState = mutableState
    }
    
    // MARK: - Public API
    
    func doSomethingThatChangesMyInternalState() {
        let newValue = makeNewState()
        print("\(Self.self).\(#function):")
        self._someMutableState = newValue
    }
    
    // MARK: - Public API to be consumed by Caretaker object
    
    func getCurrentMemento() -> Memento {
        return ConcreteStringMemento(_someMutableState)
    }
    
    func restore(fromMemento memento: Memento) {
        guard let restoredValue = (memento as? ConcreteStringMemento)?.value else { return }
        print("\(Self.self).\(#function):")
        self._someMutableState = restoredValue
    }

    // MARK: - Helpers
    
    private func makeNewState() -> String {
        return String(UUID().uuidString.prefix(Self.prefixLength))
    }
    
}

/*
 Memento
 
 Definition: Simplified representation of an object's snapshotted state
 
 Roles:
    - contains metadata (date, or optionally name) of the object's state
    - DOES NOT expose explicit state from Originator
*/

protocol Memento {
    var date: Date { get }
}

class ConcreteStringMemento: Memento, CustomStringConvertible {
    let date: Date
    let value: String
    
    init(_ value: String) {
        self.value = value
        self.date = Date()
    }
    
    // MARK: - CustomStringConvertible
    
    var description: String {
        return " \(Self.self) with state \(value) | savedAt: \(date.description.suffix(14).prefix(8))"
    }

}

/*
 CareTaker
 
 Definition: facilities Originator and
 
 Roles:
    - (may) contain an internal record of Mementos
    - defines a simplied consumable API for interacting with the Originator (directly consumes API from Originator)
        - ex. undo(), backup()
        - alternatively, it can be a cache like UserDefaults or Keychain
*/


class CareTaker {
    
    private let originator: Originator
    private var records: [Memento]
    
    // MARK - Init
    
    init(originator: Originator, records: [Memento] = []) {
        self.originator = originator
        self.records = records
    }

    
    // MARK: - Public API
    
    func showSavedHistory()  {
        print("\n\(Self.self).\(#function): \n")
        records.forEach { print($0) }
        print("")
    }
        
    func undo() {
        guard !records.isEmpty else {
            print("\(Self.self).\(#function): unable to undo, as records are empty")
            return
        }
        
        let thelastRecordAfterRemovingLast = records.removeLast()
        
        originator.restore(fromMemento: thelastRecordAfterRemovingLast)
        print("\(Self.self).\(#function): saving \(thelastRecordAfterRemovingLast)")
    }
        
    // saves current originator snapshot into records
    func backup() {
        let currentMemento = originator.getCurrentMemento()
        print("\(Self.self).\(#function): saving \(currentMemento)")
        records.append(currentMemento)
    }
}

// MARK: - Helpers

func makeSUT() -> (Originator, CareTaker) {
    let originator = Originator()
    let caretaker = CareTaker(originator: originator)
    return (originator, caretaker)
}

let (originator, caretaker) = makeSUT()
originator.doSomethingThatChangesMyInternalState()
caretaker.backup()
originator.doSomethingThatChangesMyInternalState()
caretaker.backup()
caretaker.backup()
caretaker.showSavedHistory()
caretaker.undo()
caretaker.undo()
caretaker.undo()
caretaker.undo()
caretaker.undo()
