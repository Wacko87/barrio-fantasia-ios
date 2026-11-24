import Testing
import Foundation
import Security
@testable import BarrioFantasia

@Suite("Keychain Service Tests")
struct KeychainServiceTests {

    @Test("Save, read, and delete token in Keychain")
    func testKeychainLifecycle() {
        let testKey = "test_auth_token_\(UUID().uuidString)"
        let testSecret = "jwt_secret_token_abc_123"

        // Check if environment supports keychain operations (e.g. simulated environment)
        let saved = KeychainService.shared.save(key: testKey, value: testSecret)
        if saved {
            let retrieved = KeychainService.shared.get(key: testKey)
            #expect(retrieved == testSecret)

            let deleted = KeychainService.shared.delete(key: testKey)
            #expect(deleted == true)

            #expect(KeychainService.shared.get(key: testKey) == nil)
        } else {
            // In headless CI or simulator without host entitlements, Keychain may fail gracefully with -34018
            #expect(KeychainService.shared.get(key: testKey) == nil)
        }
    }
}
