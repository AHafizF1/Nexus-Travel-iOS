import Foundation
import Testing
@testable import NexusTravel

struct HTTPTransportTests {
    @Test(arguments: [200, 201, 401, 404, 409, 410, 422, 500])
    func returnsEveryHTTPStatusForRepositoryMapping(_ status: Int) async throws {
        let loader = StubHTTPDataLoader(outcome: .http(status, Data("body".utf8)))
        let output = try await HTTPTransport(loader: loader).send(HTTPRequest(target: .mobile("test")))
        #expect(output.statusCode == status)
        #expect(output.data == Data("body".utf8))
    }

    @Test func classifiesTimeoutAndConnectivity() async {
        await #expect(throws: HTTPTransportError.timedOut) {
            try await HTTPTransport(loader: StubHTTPDataLoader(outcome: .urlError(.timedOut)))
                .send(HTTPRequest(target: .mobile("test")))
        }
        await #expect(throws: HTTPTransportError.networkUnavailable) {
            try await HTTPTransport(loader: StubHTTPDataLoader(outcome: .urlError(.notConnectedToInternet)))
                .send(HTTPRequest(target: .mobile("test")))
        }
    }

    @Test func cancellationRemainsCancellation() async {
        await #expect(throws: CancellationError.self) {
            try await HTTPTransport(loader: StubHTTPDataLoader(outcome: .urlError(.cancelled)))
                .send(HTTPRequest(target: .mobile("test")))
        }
    }

    @Test func rejectsNonHTTPResponse() async throws {
        await #expect(throws: HTTPTransportError.nonHTTPResponse) {
            try await HTTPTransport(loader: StubHTTPDataLoader(outcome: .nonHTTP))
                .send(HTTPRequest(target: .mobile("test")))
        }
    }

    @Test func preservesUnknownErrors() async {
        await #expect(throws: StubError.self) {
            try await HTTPTransport(loader: StubHTTPDataLoader(outcome: .unknown))
                .send(HTTPRequest(target: .mobile("test")))
        }
    }
}

private struct StubHTTPDataLoader: HTTPDataLoading {
    let outcome: StubOutcome

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        let url = request.url ?? AppConfiguration.productionOrigin
        switch outcome {
        case let .http(status, data):
            guard let response = HTTPURLResponse(url: url, statusCode: status,
                                                 httpVersion: nil, headerFields: ["X-Test": "yes"]) else {
                throw HTTPTransportError.nonHTTPResponse
            }
            return (data, response)
        case let .urlError(code): throw URLError(code)
        case .nonHTTP:
            return (Data(), URLResponse(url: url, mimeType: nil, expectedContentLength: 0,
                                        textEncodingName: nil))
        case .unknown: throw StubError()
        }
    }
}

private enum StubOutcome: Sendable {
    case http(Int, Data)
    case urlError(URLError.Code)
    case nonHTTP
    case unknown
}

private struct StubError: Error, Sendable {}
