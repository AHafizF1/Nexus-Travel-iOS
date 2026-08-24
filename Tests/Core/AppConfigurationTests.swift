import Testing
@testable import NexusTravel

struct AppConfigurationTests {
    @Test func productionOriginMatchesDeploymentContract() {
        #expect(AppConfiguration.productionOrigin.absoluteString == "https://api.travelwithnexus.com")
    }

    @Test func mobileBasePathMatchesBackendDefault() {
        #expect(AppConfiguration.mobileBasePath == "/api/v1/mobile")
    }

    @Test func healthPathLivesOutsideMobilePrefix() {
        #expect(AppConfiguration.healthPath == "/api/v1/health")
    }
}
