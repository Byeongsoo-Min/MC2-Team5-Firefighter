//
//  LetterViewController.swift
//  Manito
//
//  Created by SHIN YOON AH on 2022/06/09.
//

import Combine
import UIKit

final class LetterViewController: BaseViewController {

    enum Section: CaseIterable {
        case main
    }

    // MARK: - ui component

    private let letterView: LetterView = LetterView()

    private var dataSource: UICollectionViewDiffableDataSource<Section, Message>!
    private var snapShot: NSDiffableDataSourceSnapshot<Section, Message>!

    // MARK: - property

    private let segmentValueSubject: PassthroughSubject<Int, Never> = PassthroughSubject()
    private let reportSubject: PassthroughSubject<String, Never> = PassthroughSubject()
    private let refreshSubject: PassthroughSubject<Void, Never> = PassthroughSubject()

    private var cancelBag: Set<AnyCancellable> = Set()

    private let viewModel: any ViewModelType

    // MARK: - init
    
    init(viewModel: any ViewModelType) {
        self.viewModel = viewModel
        super.init()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - life cycle

    override func loadView() {
        self.view = self.letterView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureDataSource()
        self.bindViewModel()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.letterView.removeGuideView()
    }

    // MARK: - override

    override func configureUI() {
        super.configureUI()
        self.letterView.configureNavigationBar(of: self)
    }

    // MARK: - func - bind

    private func bindViewModel() {
        let output = self.transformedOutput()
        self.bindOutputToViewModel(output)
    }

    private func transformedOutput() -> LetterViewModel.Output? {
        guard let viewModel = self.viewModel as? LetterViewModel else { return nil }
        let input = LetterViewModel.Input(
            viewDidLoad: self.viewDidLoadPublisher,
            segmentControlValueChanged: self.segmentValueSubject,
            refresh: self.refreshSubject,
            sendLetterButtonDidTap: self.letterView.sendLetterButton.tapPublisher,
            reportButtonDidTap: self.reportSubject
        )

        return viewModel.transform(from: input)
    }

    private func bindOutputToViewModel(_ output: LetterViewModel.Output?) {
        guard let output = output else { return }

        output.messages
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(_):
                    self?.showErrorAlert()
                case .finished: return
                }
            }, receiveValue: { [weak self] items in
                self?.reloadMessageList(items)
                // TODO: - view layout update(데이터 없으면 empty 멘트)
            })
            .store(in: &self.cancelBag)

        output.messageDetails
            .sink(receiveValue: { [weak self] details in
                guard let self = self else { return }
                let viewController = CreateLetterViewController(manitteeId: details.manitteeId,
                                                                roomId: details.roomId,
                                                                mission: details.mission,
                                                                missionId: details.missionId)
                let navigationController = UINavigationController(rootViewController: viewController)
                viewController.configureDelegation(self)
                self.present(navigationController, animated: true)
            })
            .store(in: &self.cancelBag)

        output.reportDetails
            .sink(receiveValue: { [weak self] details in
                self?.sendReportMail(userNickname: details.nickname, content: details.content)
            })
            .store(in: &self.cancelBag)

        Publishers.CombineLatest(output.roomState, output.index)
            .map { (state: $0, index: $1) }
            .sink(receiveValue: { [weak self] result in
                switch (result.state, result.index) {
                case (.processing, 0):
                    self?.letterView.showBottomArea()
                default:
                    self?.letterView.hideBottomArea()
                }
                // TODO: - cell report 보이게 안보이게
                // TODO: - Empty Label Text
            })
            .store(in: &self.cancelBag)
    }

    private func bindCell(_ cell: LetterCollectionViewCell, with item: Message) {
        cell.reportButtonTapPublisher
            .sink(receiveValue: { [weak self] _ in
                if let content = item.content {
                    self?.reportSubject.send(content)
                } else {
                    self?.reportSubject.send("쪽지 내용 없음")
                }
            })
            .store(in: &self.cancelBag)

        cell.imageViewTapGesturePublisher
            .sink(receiveValue: { [weak self] _ in
                guard let imageUrl = item.imageUrl else { return }
                let viewController = LetterImageViewController(imageUrl: imageUrl)
                viewController.modalPresentationStyle = .fullScreen
                viewController.modalTransitionStyle = .crossDissolve
                self?.present(viewController, animated: true)
            })
            .store(in: &self.cancelBag)
    }

    private func bindHeaderView(_ headerView: LetterHeaderView) {
        headerView.segmentedControlTapPublisher
            .sink(receiveValue: { [weak self] value in
                self?.segmentValueSubject.send(value)
            })
            .store(in: &self.cancelBag)
    }
}

// MARK: - DataSource
extension LetterViewController {
    private func configureDataSource() {
        self.dataSource = self.letterCollectionViewDataSource()
        self.dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            return self?.dataSourceSupplementaryView(collectionView: collectionView,
                                                     kind: kind,
                                                     indexPath: indexPath)
        }

        self.configureSnapshot()
    }

    private func letterCollectionViewDataSource() -> UICollectionViewDiffableDataSource<Section, Message> {
        let letterCellRegistration = UICollectionView.CellRegistration<LetterCollectionViewCell, Message> {
            [weak self] cell, indexPath, item in
            // TODO: - canReport안에 boolean 값!!
            cell.configureCell((mission: item.mission,
                                date: item.date,
                                content: item.content,
                                imageURL: item.imageUrl,
                                isTodayLetter: item.isToday,
                                canReport: true))
            self?.bindCell(cell, with: item)
        }

        return UICollectionViewDiffableDataSource(
            collectionView: self.letterView.listCollectionView,
            cellProvider: { collectionView, indexPath, item in
                return collectionView.dequeueConfiguredReusableCell(
                    using: letterCellRegistration,
                    for: indexPath,
                    item: item
                )
            }
        )
    }

    private func dataSourceSupplementaryView(collectionView: UICollectionView,
                                             kind: String,
                                             indexPath: IndexPath) -> UICollectionReusableView? {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: LetterHeaderView.className,
                for: indexPath
            ) as? LetterHeaderView else { return UICollectionReusableView() }

            self.bindHeaderView(headerView)

            return headerView
        default:
            return nil
        }
    }
}

// MARK: - Snapshot
extension LetterViewController {
    private func configureSnapshot() {
        self.snapShot = NSDiffableDataSourceSnapshot<Section, Message>()
        self.snapShot.appendSections([.main])
        self.dataSource.apply(self.snapShot, animatingDifferences: true)
    }

    private func reloadMessageList(_ items: [Message]) {
        let previousMessageData = self.snapShot.itemIdentifiers(inSection: .main)
        self.snapShot.deleteItems(previousMessageData)
        self.snapShot.appendItems(items, toSection: .main)
        self.dataSource.apply(self.snapShot, animatingDifferences: true)
    }
}

// MARK: - Helper
extension LetterViewController {
    private func showErrorAlert() {
        self.makeAlert(title: TextLiteral.letterViewControllerErrorTitle,
                       message: TextLiteral.letterViewControllerErrorDescription)
    }
}

// MARK: - CreateLetterViewControllerDelegate
extension LetterViewController: CreateLetterViewControllerDelegate {
    func refreshLetterData() {
        self.refreshSubject.send(())
    }
}
