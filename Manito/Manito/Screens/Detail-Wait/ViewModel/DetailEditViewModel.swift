//
//  DetailEditViewModel.swift
//  Manito
//
//  Created by Mingwan Choi on 10/31/23.
//

import Combine
import Foundation

final class DetailEditViewModel: BaseViewModelType {
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let changeButtonDidTap: AnyPublisher<CreatedRoomInfoRequestDTO, Never>
    }
    struct Output {
        let roomInfo: AnyPublisher<RoomInfo, Never>
        let passStartDate: AnyPublisher<Bool, Never>
        let overMember: AnyPublisher<Bool, Never>
        let changeSuccess: AnyPublisher<Int, Error>
    }
    
    let usecase: DetailEditUsecase
    private var cancellable = Set<AnyCancellable>()
    
    init(usecase: DetailEditUsecase) {
        let roomInfo = usecase.roomInformation.roomInformation
        let dto = CreatedRoomInfoRequestDTO(title: roomInfo.title,
                                            capacity: roomInfo.capacity,
                                            startDate: roomInfo.startDate,
                                            endDate: roomInfo.endDate)
        self.usecase = usecase
    }
    
    // MARK: - func
    
    func transform(from input: Input) -> Output {
        let roomInfoOutput = input.viewDidLoad
            .compactMap { [weak self] _ in
                self?.usecase.roomInformation
            }
            .eraseToAnyPublisher()
        
        let isPastPublisher = input.changeButtonDidTap
            .compactMap { [weak self] dto in
                self?.validStartDatePast(startDate: dto.startDate)
            }
            .eraseToAnyPublisher()
        
        let isMemberOverPublisher = input.changeButtonDidTap
            .compactMap { [weak self] dto in
                self?.validMemberCountOver(capacity: dto.capacity)
            }
            .eraseToAnyPublisher()
        
        let changeRoomOutput = input.changeButtonDidTap
            .filter { [weak self] dto in
                guard let self else { return false }
                return self.validMemberCountOver(capacity: dto.capacity) }
            .filter { [weak self] dto in
                guard let self else { return false }
                return self.validStartDatePast(startDate: dto.startDate) }
            .asyncMap { [weak self] dto in
                try await self?.changeRoomInformation(roomDto: dto)
            }
            .compactMap { $0 }
            .eraseToAnyPublisher()
        
        return Output(
            roomInfo: roomInfoOutput,
            passStartDate: isPastPublisher,
            overMember: isMemberOverPublisher,
            changeSuccess: changeRoomOutput)
    }
    
    private func validStartDatePast(startDate: String) -> Bool {
        guard let startDate = startDate.toDefaultDate else { return false }
        let isPast = startDate.isPast
        return !isPast
    }
    
    private func validMemberCountOver(capacity: Int) -> Bool {
        let isUnderOverMember = self.usecase.roomInformation.participants.count <= capacity
        return isUnderOverMember
    }
    
    private func changeRoomInformation(roomDto: CreatedRoomInfoRequestDTO) async throws -> Int {
        let statusCode = try await self.usecase.changeRoomInformation(roomDto: roomDto)
        return statusCode
    }
}
