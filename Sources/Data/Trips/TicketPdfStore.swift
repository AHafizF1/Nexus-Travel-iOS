import Foundation

struct TicketPdfStore: Sendable {
    let directory: URL
    init(directory: URL? = nil) {
        self.directory = directory ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appending(path: "Tickets", directoryHint: .isDirectory)
    }
    func store(id: String, data: Data) throws -> URL {
        guard data.starts(with: Data("%PDF".utf8)) else { throw CocoaError(.fileReadCorruptFile) }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let safeID = id.map { $0.isLetter || $0.isNumber || $0 == "-" ? $0 : "-" }
        let url = directory.appending(path: String(safeID) + ".pdf")
        try data.write(to: url, options: .atomic)
        return url
    }
}
