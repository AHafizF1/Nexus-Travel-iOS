import Foundation
import Testing
@testable import NexusTravel

struct HTTPRequestTests {
    @Test func buildsConfiguredTargetsWithoutDuplicatingPrefixes() throws {
        #expect(try AppConfiguration.url(for: .mobile("flights/search")).absoluteString == "https://api.travelwithnexus.com/api/v1/mobile/flights/search")
        #expect(try AppConfiguration.url(for: .root("api/auth/sign-in/email")).absoluteString == "https://api.travelwithnexus.com/api/auth/sign-in/email")
        #expect(try AppConfiguration.url(for: .root(AppConfiguration.healthPath)).absoluteString == "https://api.travelwithnexus.com/api/v1/health")
        let signed = try #require(URL(string: "https://uploads.example.com/passport?id=1"))
        #expect(try AppConfiguration.url(for: .absolute(signed)) == signed)
    }

    @Test func rejectsTraversalAndUnsupportedAbsoluteSchemes() throws {
        #expect(throws: HTTPTransportError.invalidRequest) { try AppConfiguration.url(for: .mobile("../admin")) }
        let file = try #require(URL(string: "file:///tmp/passport"))
        #expect(throws: HTTPTransportError.invalidRequest) { try AppConfiguration.url(for: .absolute(file)) }
    }

    @Test func buildsJSONBearerRequestAndProtectsAuthorization() throws {
        let body = Data("{}".utf8)
        let request = try HTTPRequest(target: .mobile("flights/search"), method: .post,
            headers: ["X-Test": "yes", "Authorization": "Wrong"], body: body,
            authorization: .bearer("secret"), timeout: 12).urlRequest()
        #expect(request.httpMethod == "POST")
        #expect(request.httpBody == body)
        #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer secret")
        #expect(request.timeoutInterval == 12)
    }

    @Test func absoluteUploadPreservesRequiredHeadersWithoutBearer() throws {
        let url = try #require(URL(string: "https://uploads.example.com/object"))
        let request = try HTTPRequest(target: .absolute(url), method: .put,
            headers: ["Content-Type": "image/jpeg", "x-required": "value", "Authorization": "Wrong"],
            body: Data([1]), authorization: .none).urlRequest()
        #expect(request.value(forHTTPHeaderField: "x-required") == "value")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "image/jpeg")
        #expect(request.value(forHTTPHeaderField: "Authorization") == nil)
    }

    @Test func rejectsBlankBearerAndInvalidTimeout() {
        #expect(throws: HTTPTransportError.invalidRequest) {
            try HTTPRequest(target: .mobile("trips"), authorization: .bearer("  ")).urlRequest()
        }
        #expect(throws: HTTPTransportError.invalidRequest) {
            try HTTPRequest(target: .mobile("trips"), timeout: 0).urlRequest()
        }
    }
}
