//
//  RecipeInfoViewController.swift
//  Delicious
//
//  Created by HoaPQ on 7/31/20.
//  Copyright © 2020 sun. All rights reserved.
//

import MBSegmentControl
import SnapKit

final class RecipeInfoViewController: UIViewController, BindableType {

    // MARK: - IBOutlets
    @IBOutlet private weak var tableView: HeaderTableView!
    @IBOutlet private weak var navigationBackground: UIView!
    @IBOutlet private weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var headerTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var refreshControl: RefreshControl!
    @IBOutlet private weak var favoriteButton: UIBarButtonItem!
    @IBOutlet private weak var headerView: RecipeHeaderView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var addToShoppingButton: UIButton!
    @IBOutlet private weak var shoppingViewBottomConstraint: NSLayoutConstraint!

    private lazy var segmentControl = MBSegmentControl().then {
        var settings = MBSegmentStripSettings()
        settings.stripRange = .segment

        $0.selectedIndex = 0
        $0.backgroundColor = .white
        $0.style = .strip(settings)
        $0.segments = segmentTexts.map { TextSegment(text: $0) }
    }

    // MARK: - Properties

    var viewModel: RecipeInfoViewModel!
    private let segmentTexts = ["Nutritions", "Ingredients", "Instructions"]
    private let navigationBarHeight: CGFloat = (Helpers.statusBarSize?.height ?? 0) + Constant.segmentHeight
    private var headerHeight: CGFloat = .zero

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configNavigationBar()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.do {
            $0.setBackgroundImage(nil, for: .default)
        }
    }

    deinit {
        logDeinit()
    }

    // MARK: - Methods

    private func configView() {
        headerHeight = headerHeightConstraint.constant + navigationBarHeight
        headerTopConstraint.constant = -navigationBarHeight
        headerHeightConstraint.constant = headerHeight
        tableView.do {
            $0.register(cellType: NutritionTBCell.self)
            $0.register(cellType: IngredientTBCell.self)
            $0.register(cellType: StepTBCell.self)
            $0.tableHeaderView?.frame = CGRect(x: 0,
                                               y: 0,
                                               width: $0.width,
                                               height: headerHeight - navigationBarHeight + Constant.segmentHeight)
            $0.tableFooterView = UIView(frame: CGRect(x: 0,
                                                      y: 0,
                                                      width: tableView.width,
                                                      height: .leastNonzeroMagnitude))
            $0.contentInset = UIEdgeInsets(top: navigationBarHeight,
                                           left: 0,
                                           bottom: 0,
                                           right: 0)
            $0.rx
                .setDelegate(self)
                .disposed(by: rx.disposeBag)
        }
        refreshControl.do {
            $0.setMaxHeightOfRefreshControl = headerHeight
            $0.scrollView = tableView
        }

        view.do {
            $0.bringSubviewToFront(navigationBackground)
            $0.addSubview(segmentControl)
        }
        segmentControl.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(headerView.snp.bottom)
            $0.height.equalTo(Constant.segmentHeight)
        }

        addToShoppingButton.do {
            $0.applyCornerRadius()
            $0.applyShadowWithColor(color: .black,
                                    opacity: Constant.shadowOpacity,
                                    radius: Constant.shadowRadius)
        }
    }

    private func configNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }

    func bindViewModel() {
        let input = RecipeInfoViewModel.Input()
        let output = viewModel.transform(input)
    }
}

// MARK: - Binders
extension RecipeInfoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let base = -navigationBarHeight
        if offset < base {
            headerTopConstraint.constant = offset
            headerHeightConstraint.constant = headerHeight + abs(base - offset)
        } else {
            let navBarOffset = navigationBarHeight + offset
            let imageBottom = base + headerHeight
            headerTopConstraint.constant = base + max(navBarOffset - imageBottom, 0)
            headerHeightConstraint.constant = headerHeight
        }
        let alpha = offset / (headerHeight - navigationBarHeight * 2)
        navigationBackground.alpha = min(alpha, 1)
    }
}

// MARK: - StoryboardSceneBased
extension RecipeInfoViewController: StoryboardSceneBased {
    static var sceneStoryboard = StoryBoards.recipeInfo
}
