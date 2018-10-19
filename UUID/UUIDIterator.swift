//
//  UUIDIterator.swift
//  UUID
//
//  Created on 19/10/2018.
//


public struct UUIDIterator: IteratorProtocol {
    private let _uuid: UUID
    private var _index: UUID.Index
    
    public typealias Element = UInt8
    
    public init(uuid: UUID) {
        _uuid = uuid
        _index = 0
    }
    
    public mutating func next() -> Element? {
        if _index == _uuid.endIndex {
            return nil
        } else {
            defer {
                _index += 1
            }
            return _uuid[_index]
        }
    }
}
