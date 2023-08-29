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
    private var service: MockDetailWaitService!
    private var cancellable: Set<AnyCancellable>!
    private var output: DetailWaitViewModel.Output!
    
    override func setUp() {
        super.setUp()
        self.service = MockDetailWaitService()
        self.viewModel = DetailWaitViewModel(roomIndex: 0, detailWaitService: self.service)
        self.cancellable = Set<AnyCancellable>()
        self.viewModel.setRoomInformation(room: RoomInfo.testRoom)
    }
    
    override func tearDown() {
        super.tearDown()
        self.viewModel = nil
        self.cancellable = nil
    }
    
    func testMakeRoomInformation() {
        // given
        let checkRoom = RoomInfo.testRoom
        self.viewModel.setRoomInformation(room: checkRoom)
        
        // then
        let testRoom = self.viewModel.makeRoomInformation()
        
        // when
        XCTAssertEqual(checkRoom, testRoom)
    }
    
    func testTransferInvitationCode() {
        // given
        let checkCode = "ABCDEF"
        var testCode = ""
        let testCodeCopyButtonDidTapSubject = PassthroughSubject<Void, Never>()
        let input = DetailWaitViewModel.Input(codeCopyButtonDidTap: testCodeCopyButtonDidTapSubject.eraseToAnyPublisher())
        let output = self.viewModel.transform(input)
        
        // when
        output.code
            .sink { code in
                testCode = code
            }
            .store(in: &self.cancellable)
        testCodeCopyButtonDidTapSubject.send(())
        
        // then
        XCTAssertEqual(checkCode, testCode)
    }
    
    func testTransferRoomInformation() {
        // given
        let checkRoom = mockRoom
        let expectation = XCTestExpectation(description: "roomInformation test")
        var testRoom = RoomInfo.emptyRoom
        let testViewDidLoadSubject = PassthroughSubject<Void, Never>()
        let input = DetailWaitViewModel.Input(viewDidLoad: testViewDidLoadSubject.eraseToAnyPublisher())
        let output = self.viewModel.transform(input)

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
                testRoom = room
                expectation.fulfill()
            })
            .store(in: &self.cancellable)
        testViewDidLoadSubject.send(())

        // then
        wait(for: [expectation], timeout: 5)
        XCTAssertEqual(checkRoom, testRoom)
    }
    
    func testTranferStartButton() {
        // given
        let checkNickname = "테스트마니띠"
        let expectation = XCTestExpectation(description: "startButton test")
        var testNickname = ""
        let testStartButtonDidTapSubject = PassthroughSubject<Void, Never>()
        let input = DetailWaitViewModel.Input(startButtonDidTap: testStartButtonDidTapSubject.eraseToAnyPublisher())
        let output = self.viewModel.transform(input)

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
                testNickname = nickname
                expectation.fulfill()
            })
            .store(in: &self.cancellable)
        testStartButtonDidTapSubject.send(())

        // then
        wait(for: [expectation], timeout: 5)
        XCTAssertEqual(checkNickname, testNickname)
    }
    
    func testTransferEditRoom() {
        // given
        let checkRoom = RoomInfo.testRoom
        let checkMode: DetailEditView.EditMode = .information
        let expectation = XCTestExpectation(description: "editButton test")
        var testRoom = RoomInfo.emptyRoom
        var testMode: DetailEditView.EditMode = .date
        let testEditMenuButtonDidTapSubject = PassthroughSubject<Void, Never>()
        let input = DetailWaitViewModel.Input(editMenuButtonDidTap: testEditMenuButtonDidTapSubject.eraseToAnyPublisher())
        let output = self.viewModel.transform(input)

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
                testRoom = room
                testMode = mode
                expectation.fulfill()
            })
            .store(in: &self.cancellable)
        testEditMenuButtonDidTapSubject.send(())

        // then
        wait(for: [expectation], timeout: 5)
        XCTAssertEqual(checkRoom, testRoom)
        XCTAssertEqual(checkMode, testMode)
    }
    
    func testTransferDeleteRoom() {
        // given
        let expectation = XCTestExpectation(description: "deleteButton test")
        var testBool = false
        let testDeleteMenuButtonDidTapSubject = PassthroughSubject<Void, Never>()
        let input = DetailWaitViewModel.Input(deleteMenuButtonDidTap: testDeleteMenuButtonDidTapSubject.eraseToAnyPublisher())
        let output = self.viewModel.transform(input)

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
                expectation.fulfill()
            })
            .store(in: &self.cancellable)
        testDeleteMenuButtonDidTapSubject.send(())

        // then
        wait(for: [expectation], timeout: 5)
        XCTAssertTrue(testBool)
    }
    
    func testTransferLeaveRoom() {
        // given
        let expectation = XCTestExpectation(description: "leaveButton test")
        var testBool = false
        let testLeaveMenuButtonDidTapSubject = PassthroughSubject<Void, Never>()
        let input = DetailWaitViewModel.Input(leaveMenuButtonDidTap: testLeaveMenuButtonDidTapSubject.eraseToAnyPublisher())
        let output = self.viewModel.transform(input)
        
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
                expectation.fulfill()
            })
            .store(in: &self.cancellable)
        testLeaveMenuButtonDidTapSubject.send(())

        // then
        wait(for: [expectation], timeout: 5)
        XCTAssertTrue(testBool)
    }
    
    func testTransferChnageButtonDidTap() {
        // given
        let checkRoom = mockRoom
        let expectation = XCTestExpectation(description: "changeButton test")
        var testRoom = RoomInfo.emptyRoom
        let testChangeButtonDidTapSubject = PassthroughSubject<Void, Never>()
        let input = DetailWaitViewModel.Input(changeButtonDidTap: testChangeButtonDidTapSubject.eraseToAnyPublisher())
        let _ = self.viewModel.transform(input)

        // when
        testChangeButtonDidTapSubject.send(())

        // then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            testRoom = self.viewModel.makeRoomInformation()
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
        XCTAssertEqual(checkRoom, testRoom)
    }
    
    func testTransferViewDidLoad() {
        // given
        let checkRoom = mockRoom
        let expectation = XCTestExpectation(description: "viewDidLoad test")
        var testRoom = RoomInfo.emptyRoom
        let testViewDidLoadSubject = PassthroughSubject<Void, Never>()
        let input = DetailWaitViewModel.Input(viewDidLoad: testViewDidLoadSubject.eraseToAnyPublisher())
        let _ = self.viewModel.transform(input)

        // when
        testViewDidLoadSubject.send()

        // then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            testRoom = self.viewModel.makeRoomInformation()
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
        XCTAssertEqual(checkRoom, testRoom)
    }
}

extension DetailWaitViewModelTest {
    var mockRoom: RoomInfo {
        return RoomInfo(
            roomInformation: RoomListItem(id: 10, title: "목타이틀", state: "", participatingCount: 10, capacity: 10, startDate: "", endDate: ""),
            participants: ParticipantList.testParticipantList,
            manittee: UserInfoDTO.testUserManitto,
            manitto: UserInfoDTO.testUserManitto,
            invitation: InvitationCodeDTO.testInvitationCodeDTO,
            didViewRoulette: false,
            mission: IndividualMissionDTO.testIndividualMissionDTO,
            admin: false,
            messages: MessageInfo.testMessageInfo)
    }
}

final class MockDetailWaitService: DetailWaitServicable {
    // FIXME: - network mocking 만들어야함.
    func fetchWaitingRoomInfo(roomId: String) async throws -> Manito.RoomInfoDTO {
        let room = RoomInfoDTO(
            roomInformation: RoomListItemDTO(id: 10, title: "목타이틀", state: "", participatingCount: 10, capacity: 10, startDate: "", endDate: ""),
            participants: ParticipantListDTO(count: 5, members: UserInfoDTO.testUserList),
            manittee: UserInfoDTO.testUserManitto,
            manitto: UserInfoDTO.testUserManitto,
            invitation: InvitationCodeDTO.testInvitationCodeDTO,
            didViewRoulette: false,
            mission: IndividualMissionDTO.testIndividualMissionDTO,
            admin: false,
            messages: MessageInfo.testMessageInfo)
        return room
    }
    
    func patchStartManitto(roomId: String) async throws -> Manito.UserInfoDTO {
        return UserInfoDTO.testUserManittee
    }
    
    func deleteRoom(roomId: String) async throws -> Int {
        return 200
    }
    
    func deleteLeaveRoom(roomId: String) async throws -> Int {
        return 200
    }
}
