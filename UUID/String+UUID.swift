//
//  String+UUID.swift
//  UUID
//
//  Created on 19/10/2018.
//

import Darwin


extension String {
    public enum UUIDUnparseCasing: Int {
        case upper
        case lower
    }
    
    /// Creates a `String` from `UUID`
    ///
    /// - Parameter uuid: A value of `UUID`.
    ///
    /// - Parameter casing: Created `String`'s casing. Upper-case, lower-case or
    /// unspecified.
    ///
    public init(
        uuid: UUID,
        casing: UUIDUnparseCasing? = nil
        )
    {
        let strPtr = UnsafeMutablePointer<Int8>.allocate(capacity: 37)
        var mutalbeUUID = uuid
        let uuidBuffer = withUnsafePointer(to: &mutalbeUUID) {$0}
            .withMemoryRebound(to: UInt8.self, capacity: 16) {$0}
        switch casing {
        case .some(.lower):
            uuid_unparse_lower(uuidBuffer, strPtr)
        case .some(.upper):
            uuid_unparse_upper(uuidBuffer, strPtr)
        case .none:
            uuid_unparse(uuidBuffer, strPtr)
        }
        self = String(cString: strPtr)
        strPtr.deallocate()
    }
}
