import Testing
@testable import NotLight3
import AppKit
import WaitWhile

private struct ResultsViewControllerTests {
    let subject = ResultsViewController()
    let processor = MockProcessor<ResultsAction, ResultsState, Void>()
    let datasource = MockResultsDatasource()

    init() {
        subject.processor = processor
        subject.datasource = datasource
    }

    @Test("nibName: is correct")
    func nibName() {
        #expect(subject.nibName == "Results")
    }

    @Test("initialization: sets up the datasource and table view")
    func initialization() throws {
        let subject = ResultsViewController()
        let processor = MockProcessor<ResultsAction, ResultsState, Void>()
        subject.processor = processor
        subject.loadViewIfNeeded()
        let datasource = try #require(subject.datasource as? ResultsDatasource)
        #expect(subject.tableView != nil)
        #expect(datasource.processor === subject.processor)
        #expect(datasource.tableView === subject.tableView)
    }

    @Test("viewDidLoad: sends processor initialData")
    func viewDidLoad() async {
        subject.loadViewIfNeeded()
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.initialData])
    }

    @Test("viewWillAppear: sets window's minSize")
    func viewWillAppear() {
        let window = NSWindow()
        subject.loadViewIfNeeded()
        window.contentView = subject.view
        subject.viewWillAppear()
        #expect(window.minSize == CGSize(width: 1000, height: 500))
    }

    @Test("present: presents to the datasource")
    func present() async {
        let state = ResultsState(results: [.init(displayName: "name", path: "path")])
        await subject.present(state)
        #expect(datasource.statePresented == state)
    }

    @Test("doClose: sends processor close")
    func close() async {
        subject.doClose(self)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.close])
    }
}
