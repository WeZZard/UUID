//
//  UUID.swift
//  UUID
//
//  Created by WeZZard on 4/2/16.
//
//

import Darwin


public struct UUID: Hashable, RandomAccessCollection,
    CustomStringConvertible,
    CustomDebugStringConvertible
{
    #if arch(arm64) || arch(x86_64)
    private var _buffer0: UInt64
    private var _buffer1: UInt64
    #else
    private var _buffer0: UInt32
    private var _buffer1: UInt32
    private var _buffer2: UInt32
    private var _buffer3: UInt32
    #endif
    
    /// Initializes a random `UUID`.
    ///
    public init() {
        _buffer0 = 0
        _buffer1 = 0
        #if !arch(arm64) && !arch(x86_64)
            _buffer2 = 0
            _buffer3 = 0
        #endif
        let buffer = withUnsafeMutablePointer(to: &self, {$0})
            .withMemoryRebound(to: UInt8.self, capacity: 16, {$0})
        uuid_generate_random(buffer)
    }
    
    /// Initializes a `UUID` from bytes, length of 16 bytes was assumed.
    public init(bytes: UnsafePointer<UInt8>) {
        #if arch(arm64) || arch(x86_64)
            let buffer = bytes.withMemoryRebound(
                to: UInt64.self, capacity: 2, {$0}
            )
        #else
            let buffer = bytes.withMemoryRebound(
                to: UInt32.self, capacity: 4, {$0}
            )
            _buffer2 = buffer[2]
            _buffer3 = buffer[3]
        #endif
        _buffer0 = buffer[0]
        _buffer1 = buffer[1]
    }
    
    /// Initializes a `UUID` from a value of `uuid_t`.
    public init(uuid: uuid_t) {
        precondition(
            MemoryLayout<UUID>.size == MemoryLayout<uuid_t>.size,
            "The memory layout of \(UUID.self) is different from those of \(uuid_t.self)."
        )
        var mutableUUID = uuid
        #if arch(arm64) || arch(x86_64)
            let buffer = withUnsafePointer(to: &mutableUUID, {$0})
                .withMemoryRebound(to: UInt64.self, capacity: 2, {$0})
        #else
            let buffer = withUnsafePointer(to: &mutableUUID, {$0})
                .withMemoryRebound(to: UInt32.self, capacity: 4, {$0})
            _buffer2 = buffer[2]
            _buffer3 = buffer[3]
        #endif
        _buffer0 = buffer[0]
        _buffer1 = buffer[1]
    }
    
    /// Initializes a UUID from a string such as
    /// “E621E1F8-C36C-495A-93FC-0C247A3E6E5F”.
    ///
    public init?(string: String) {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
        let codePoints = UnsafeMutablePointer<Int8>.allocate(capacity: 16)
        var index = 0
        
        defer {
            buffer.deallocate()
            codePoints.deallocate()
        }
        
        if transcode(
            string.utf16.makeIterator(),
            from: UTF16.self,
            to: UTF8.self,
            stoppingOnError: true,
            into: { if index < 16 { codePoints[index] = Int8($0); index += 1 } }
            )
        {
            let signal = uuid_parse(codePoints, buffer)
            switch signal {
            case 0:
                // Succeeded, do nothing.
                break
            case -1:
                // Failed, return nil.
                return nil
            default:
                // Undocumented error.
                fatalError("\(uuid_parse) returned \(signal), which is not documented.")
            }
        } else {
            return nil
        }
        
        self.init(bytes: buffer)
    }
    
    // MARK: Sequence
    public typealias Iterator = UUIDIterator
    
    public func makeIterator() -> UUIDIterator {
        return UUIDIterator(uuid: self)
    }
    
    // MARK: Collection
    public typealias Element = UInt8
    
    public typealias Index = Int
    
    public var startIndex: Index { return 0 }
    
    public var endIndex: Index { return 17 }
    
    public subscript(position: Index) -> Element {
        get {
            precondition(position < endIndex)
            #if arch(arm64) || arch(x86_64)
                // Little endian
                switch position {
                case 0:
                    return Element((_buffer0 & (0b11111111 << 0)) >> 0)
                case 1:
                    return Element((_buffer0 & (0b11111111 << 8)) >> 8)
                case 2:
                    return Element((_buffer0 & (0b11111111 << 16)) >> 16)
                case 3:
                    return Element((_buffer0 & (0b11111111 << 24)) >> 24)
                case 4:
                    return Element((_buffer0 & (0b11111111 << 32)) >> 32)
                case 5:
                    return Element((_buffer0 & (0b11111111 << 40)) >> 40)
                case 6:
                    return Element((_buffer0 & (0b11111111 << 48)) >> 48)
                case 7:
                    return Element((_buffer0 & (0b11111111 << 56)) >> 56)
                case 8:
                    return Element((_buffer1 & (0b11111111 << 0)) >> 0)
                case 9:
                    return Element((_buffer1 & (0b11111111 << 8)) >> 8)
                case 10:
                    return Element((_buffer1 & (0b11111111 << 16)) >> 16)
                case 11:
                    return Element((_buffer1 & (0b11111111 << 24)) >> 24)
                case 12:
                    return Element((_buffer1 & (0b11111111 << 32)) >> 32)
                case 13:
                    return Element((_buffer1 & (0b11111111 << 40)) >> 40)
                case 14:
                    return Element((_buffer1 & (0b11111111 << 48)) >> 48)
                case 15:
                    return Element((_buffer1 & (0b11111111 << 56)) >> 56)
                default:
                    fatalError("Invalid position: \(position)")
                }
            #else
                // Little endian
                switch position {
                case 0:
                    return Element((_buffer0 & (0b11111111 << 0)) >> 0)
                case 1:
                    return Element((_buffer0 & (0b11111111 << 8)) >> 8)
                case 2:
                    return Element((_buffer0 & (0b11111111 << 16)) >> 16)
                case 3:
                    return Element((_buffer0 & (0b11111111 << 24)) >> 24)
                case 4:
                    return Element((_buffer1 & (0b11111111 << 0)) >> 0)
                case 5:
                    return Element((_buffer1 & (0b11111111 << 8)) >> 8)
                case 6:
                    return Element((_buffer1 & (0b11111111 << 16)) >> 16)
                case 7:
                    return Element((_buffer1 & (0b11111111 << 24)) >> 24)
                case 8:
                    return Element((_buffer2 & (0b11111111 << 0)) >> 0)
                case 9:
                    return Element((_buffer2 & (0b11111111 << 8)) >> 8)
                case 10:
                    return Element((_buffer2 & (0b11111111 << 16)) >> 16)
                case 11:
                    return Element((_buffer2 & (0b11111111 << 24)) >> 24)
                case 12:
                    return Element((_buffer3 & (0b11111111 << 0)) >> 0)
                case 13:
                    return Element((_buffer3 & (0b11111111 << 8)) >> 8)
                case 14:
                    return Element((_buffer3 & (0b11111111 << 16)) >> 16)
                case 15:
                    return Element((_buffer3 & (0b11111111 << 24)) >> 24)
                default:
                    fatalError("Invalid position: \(position)")
                }
            #endif
        }
        mutating set {
            let buffer = withUnsafeMutablePointer(to: &self) {$0}
                .withMemoryRebound(to: UInt8.self, capacity: 16) {$0}
            buffer[position] = newValue
        }
    }
    
    public func index(after i: Index) -> Index { return i + 1 }
    
    // MARK: BidirectionalCollection
    public func index(before i: Int) -> Int { return i - 1 }
    
    // MARK: RandomAccessCollection
    
    // MARK: Hashable
    /// UUID returns the first "word-sized" data as the hash value.
    public var hashValue: Int {
        #if arch(arm64) || arch(x86_64)
            return Int(Int64(bitPattern: _buffer0))
        #else
            return Int(Int32(bitPattern: _buffer0))
        #endif
    }
    
    public static func == (lhs: UUID, rhs: UUID) -> Bool {
        #if arch(arm64) || arch(x86_64)
            return lhs._buffer0 == rhs._buffer0 && lhs._buffer1 == rhs._buffer1
        #else
            return lhs._buffer0 == rhs._buffer0 && lhs._buffer1 == rhs._buffer1
                && lhs._buffer2 == rhs._buffer2 && lhs._buffer3 == rhs._buffer3
        #endif
    }
    
    // MARK: CustomStringConvertible
    /// Returns a string like “E621E1F8-C36C-495A-93FC-0C247A3E6E5F”.
    public var description: String { return String(uuid: self) }
    
    // MARK: CustomDebugStringConvertible
    /// Returns debug description with internal storage content and a string 
    /// like “E621E1F8-C36C-495A-93FC-0C247A3E6E5F”.
    public var debugDescription: String {
        #if arch(arm64) || arch(x86_64)
            return "<\(type(of: self)); string = \(description) ; buffer0 = \(_buffer0) ; buffer1 = \(_buffer1)>"
        #else
            return "<\(type(of: self)); string = \(description) ; buffer0 = \(_buffer0) ; buffer1 = \(_buffer1); buffer2 = \(_buffer2) ; buffer3 = \(_buffer3)>"
        #endif
    }
}
