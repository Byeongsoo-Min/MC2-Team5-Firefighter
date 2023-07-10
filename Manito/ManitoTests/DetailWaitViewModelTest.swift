//
//  DetailWaitViewModelTest.swift
//  ManitoTests
//
//  Created by Mingwan Choi on 2023/06/06.
//

import Combine
import XCTest
@testable import Manito


final class DetailWaitViewModelTest: XCTestCase {
    private var viewModel: DetailWaitViewModel!
    private var cancellable: Set<AnyCancellable>!
    private var testViewDidLoadSubject: PassthroughSubject<Void, Never>!
    private var testCodeCopyButtonDidTapSubject: PassthroughSubject<Void, Never>!
    private var testStartButtonDidTapSubject: PassthroughSubject<Void, Never>!
    private var testEditMenuButtonDidTapSubject: PassthroughSubject<Void, Never>!
    private var testDeleteMenuButtonDidTapSubject: PassthroughSubject<Void, Never>!
    private var testLeaveMenuButtonDidTapSubject: PassthroughSubject<Void, Never>!
    private var testChangeButtonDidTapSubject: PassthroughSubject<Void, Never>!
    private var output: DetailWaitViewModel.Output!
    
    override func setUp() {
        super.setUp()
        self.viewModel = DetailWaitViewModel(roomIndex: 0, detailWaitService: MockDetailWaitService())
        self.cancellable = Set<AnyCancellable>()
        self.testViewDidLoadSubject = PassthroughSubject<Void, Never>()
        self.testCodeCopyButtonDidTapSubject = PassthroughSubject<Void, Never>()
        self.testStartButtonDidTapSubject = PassthroughSubject<Void, Never>()
        self.testEditMenuButtonDidTapSubject = PassthroughSubject<Void, Never>()
        self.testDeleteMenuButtonDidTapSubject = PassthroughSubject<Void, Never>()
        self.testLeaveMenuButtonDidTapSubject = PassthroughSubject<Void, Never>()
        self.testChangeButtonDidTapSubject = PassthroughSubject<Void, Never>()
        let input = DetailWaitViewModel.Input(
            viewDidLoad: testViewDidLoadSubject.eraseToAnyPublisher(),
            codeCopyButtonDidTap: testCodeCopyButtonDidTapSubject.eraseToAnyPublisher(),
            startButtonDidTap: testStartButtonDidTapSubject.eraseToAnyPublisher(),
            editMenuButtonDidTap: testEditMenuButtonDidTapSubject.eraseToAnyPublisher(),
            deleteMenuButtonDidTap: testDeleteMenuButtonDidTapSubject.eraseToAnyPublisher(),
            leaveMenuButtonDidTap: testLeaveMenuButtonDidTapSubject.eraseToAnyPublisher(),
            changeButtonDidTap: testChangeButtonDidTapSubject.eraseToAnyPublisher())
        self.output = self.viewModel.transform(input)
        self.viewModel.setRoomInformation(room: Room.testRoom)
    }
    
    override func tearDown() {
        self.viewModel = nil
        self.cancellable = nil
        self.testViewDidLoadSubject = nil
        self.testCodeCopyButtonDidTapSubject = nil
        self.testStartButtonDidTapSubject = nil
        self.testEditMenuButtonDidTapSubject = nil
        self.testDeleteMenuButtonDidTapSubject = nil
        self.testLeaveMenuButtonDidTapSubject = nil
        self.testChangeButtonDidTapSubject = nil
    }
    
    func testMakeRoomInformation() {
        // given
        let testRoom = Room.testRoom
        self.viewModel.setRoomInformation(room: testRoom)
        
        // then
        let room = self.viewModel.makeRoomInformation()
        
        // when
        XCTAssertEqual(testRoom, room)
    }
    
    func testTransferInvitationCode() {
        // given
        let checkCode = "ABCDEF"
        // when
        output.code
            .sink { code in
                XCTAssertEqual(code, checkCode)
            }
            .store(in: &self.cancellable)
        // then
        testCodeCopyButtonDidTapSubject.send(())
    }
    
    func testTransferRoomInformation() {
        // given
        let testTitle = "목타이틀"
        let exception = XCTestExpectation(description: "async test")
        var checkTitle = ""
        // when
        output.roomInformation
            .sink(receiveCompletion: { result in
                switch result {
                case .failure:
                    break
                case .finished:
                    break
                }
            }, receiveValue: { room in
                guard let title = room.roomInformation?.title else { return }
                checkTitle = title
                exception.fulfill()
            })
            .store(in: &self.cancellable)
        // then
        self.testViewDidLoadSubject.send(())
        wait(for: [exception], timeout: 2)
        XCTAssertEqual(checkTitle, testTitle)
    }
    
    func testTranferStartButton() {
        // given
        let testManittee = "테스트마니띠"
        let exception = XCTestExpectation(description: "startButton test")
        var checkNickname = ""
        // when
        output.manitteeNickname
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    break
                case .failure:
                    XCTFail("fail")
                }
            }, receiveValue: { nickname in
                checkNickname = nickname
                exception.fulfill()
            })
            .store(in: &self.cancellable)
        // then
        self.testStartButtonDidTapSubject.send(())
        wait(for: [exception], timeout: 2)
        XCTAssertEqual(testManittee, checkNickname)
    }
    
    func testTransferEditRoom() {
        // given
        let exception = XCTestExpectation(description: "editButton test")
        var checkRoom = Room.emptyRoom
        var checkMode: DetailEditView.EditMode = .date
        // when
        output.editRoomInformation
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    break
                case .failure:
                    XCTFail("fail")
                }
            }, receiveValue: { (room, mode) in
                checkRoom = room
                checkMode = mode
                exception.fulfill()
            })
            .store(in: &self.cancellable)
        // then
        self.testEditMenuButtonDidTapSubject.send(())
        wait(for: [exception], timeout: 2)
        XCTAssertEqual(checkMode, .information)
        XCTAssertEqual(checkRoom, Room.testRoom)
    }
    
    func testTransferDeleteRoom() {
        // given
        let exception = XCTestExpectation(description: "deleteButton test")
        var testBool = false
        // when
        output.deleteRoom
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    break
                case .failure:
                    XCTFail("fail")
                }
            }, receiveValue: { _ in
                testBool = true
                exception.fulfill()
            })
            .store(in: &self.cancellable)
        // then
        self.testDeleteMenuButtonDidTapSubject.send(())
        wait(for: [exception], timeout: 2)
        XCTAssertTrue(testBool)
    }
    
    func testTransferLeaveRoom() {
        // given
        let exception = XCTestExpectation(description: "leaveButton test")
        var testBool = false
        // when
        output.leaveRoom
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    break
                case .failure:
                    XCTFail("fail")
                }
            }, receiveValue: { _ in
                testBool = true
                exception.fulfill()
            })
            .store(in: &self.cancellable)
        // then
        self.testLeaveMenuButtonDidTapSubject.send(())
        wait(for: [exception], timeout: 2)
        XCTAssertTrue(testBool)
    }
}

final class MockDetailWaitService: DetailWaitServicable {
    // FIXME: - network mocking 만들어야함.
    func fetchWaitingRoomInfo(roomId: String) async throws -> Manito.Room {
        let room = Room(roomInformation: RoomInfo(id: 10, capacity: 10, title: "목타이틀", startDate: "", endDate: "", state: ""),
                        participants: Participants.testParticipants,
                        manittee: Manittee.testManittee,
                        manitto: Manitto.testManitto,
                        invitation: Invitation.testInvitation,
                        mission: Mission.testMission,
                        admin: true,
                        messages: Message1.testMessage)
        return room
    }
    
    func patchStartManitto(roomId: String) async throws -> Manito.Manittee {
        return Manittee.testManittee
    }
    
    func deleteRoom(roomId: String) async throws -> Int {
        return 200
    }
    
    func deleteLeaveRoom(roomId: String) async throws -> Int {
        return 200
    }
}
