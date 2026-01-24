import Testing
@testable import NotLight3
import AppKit
import WaitWhile

private struct SearchKeysViewControllerTests {
    let subject = SearchKeysViewController()
    let processor = MockProcessor<SearchKeysAction, SearchKeysState, Void>()
    let datasource = MockSearchKeysDatasource()

    init() {
        subject.processor = processor
        subject.datasource = datasource
    }

    @Test("nibName: is correct")
    func nibName() {
        #expect(subject.nibName == "SearchKeys")
    }

    @Test("initialization: sets up the datasource and table view")
    func initialization() throws {
        let subject = SearchKeysViewController()
        let processor = MockProcessor<SearchKeysAction, SearchKeysState, Void>()
        subject.processor = processor
        subject.loadViewIfNeeded()
        let datasource = try #require(subject.datasource as? SearchKeysDatasource)
        #expect(subject.tableView != nil)
        #expect(datasource.processor === subject.processor)
        #expect(datasource.tableView === subject.tableView)
    }

    @Test("viewDidLoad: sets things up, sends processor initialData")
    func viewDidLoad() async {
        subject.loadViewIfNeeded()
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.initialData])
    }
}
