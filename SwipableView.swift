class ContactsDetailView: UIView {

    // MARK: - Properties
    weak var delegate: ContactsDetailViewDelegate?
    var currentHeight: CGFloat = 0
    let dismissableHeight: CGFloat = 100
    let schedule = Constants.MAIN_UI_SCHEDULER
    let backgroundSchedule = Constants.BACKGROUND_SCHEDULER
    var maxHeight: CGFloat = 500
    var defaultHeight: CGFloat = 360

    // MARK: - UI
    private var closeBtn: UIButton = UIButton()
    private var fullNameBtn: UIButton = UIButton()
    private var companyNameLbl: StatusLabel = StatusLabel()
    private var phoneNumberView: PhoneDetailView = PhoneDetailView()
    private var mobileNumberView: PhoneDetailView = PhoneDetailView()
    private var lineView: UIView = UIView()
    private var sendMailBtn: ContactDetailButtonWithRightIcon = ContactDetailButtonWithRightIcon(
        label: L10n.ButtonTitle.contactDetailSendEmail,
        iconImage: nil
    )
    private var createQuotationBtn: ContactDetailButtonWithRightIcon = ContactDetailButtonWithRightIcon(
        label: L10n.ButtonTitle.contactDetailCreateAndSendAQuote,
        iconImage: nil
    )
    private var createInvoiceBtn: ContactDetailButtonWithRightIcon = ContactDetailButtonWithRightIcon(
        label: L10n.ButtonTitle.contactDetailInvoiceCreationTransmission,
        iconImage: nil
    )

    init() {
        super.init(frame: .zero)
        setUpView()
        setUpBindings()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    deinit { deinitializeLog() }

    override func layoutSubviews() {
        super.layoutSubviews()
        let radius: CGFloat = 15
        roundCorners(corners: [.topLeft, .topRight], radius: radius)
    }

    func setContactDetail(withName name: String,
                          companyName: String,
                          phone: String,
                          mobile: String) {
        fullNameBtn.setTitle(name, for: .normal)
        companyNameLbl.text = companyName
        phoneNumberView.phoneBtn.setTitle(phone, for: .normal)
        mobileNumberView.phoneBtn.setTitle(mobile, for: .normal)

        var newCurrentHeight: CGFloat = 460
        let nameHeight: CGFloat = 25
        let companyNameHeight: CGFloat = 17
        let phoneHeight: CGFloat = 35
        let mobileHeight: CGFloat = 35

        if name.isEmpty {
            newCurrentHeight -= nameHeight
        }

        if companyName.isEmpty {
            newCurrentHeight -= companyNameHeight
        }

        if phone.isEmpty {
            newCurrentHeight -= phoneHeight
        }

        phoneNumberView.snp.updateConstraints { make in
            let height = phone.isEmpty ? 0 : phoneHeight
            phoneNumberView.isHidden = height == 0
            make.height.equalTo(height)
        }

        if mobile.isEmpty {
            newCurrentHeight -= mobileHeight
        }

        mobileNumberView.snp.updateConstraints { make in
            let height = mobile.isEmpty ? 0 : mobileHeight
            mobileNumberView.isHidden = height == 0
            make.height.equalTo(height)
        }

        currentHeight = newCurrentHeight
        defaultHeight = newCurrentHeight
        maxHeight = newCurrentHeight

        updateContainerHeight(newCurrentHeight)
        superview?.layoutIfNeeded()
    }
    
    func setUpView() {
        backgroundColor = Asset.Colors.bgSettings.color
        setUpCloseButton()
        setUpFullNameButton()
        setUpCompanyNameLabel()
        setUpPhoneNumberView()
        setUpMobileNumberView()
        setUpPseudoLine()
        setUpSendMailView()
        setUpCreateQuoteView()
        setUpCreateInvoiceView()
    }

    private func setUpCloseButton() {
        closeBtn.backgroundColor = .white
        closeBtn.setImage(Asset.Images.swipableArrowDown.image, for: .normal)
        closeBtn.backgroundColor = .clear

        addSubview(closeBtn)

        closeBtn.snp.makeConstraints { make in
            let buttonHeight = 25
            let buttonWidth = 40
            let buttonTop = 10
            make.height.width.equalTo(buttonHeight)
            make.width.equalTo(buttonWidth)
            make.top.equalToSuperview().offset(buttonTop)
            make.centerX.equalToSuperview()
        }
    }

    private func setUpFullNameButton() {
        fullNameBtn.titleLabel?.font = .sfProText(ofSize: 17)
        fullNameBtn.setTitleColor(Asset.Colors.titleColor.color, for: .normal)
        fullNameBtn.titleLabel?.lineBreakMode = .byTruncatingTail

        addSubview(fullNameBtn)

        fullNameBtn.snp.makeConstraints { make in
            let left = 27
            let height = 20
            let top = 10
            let width = 40
            make.top.equalTo(closeBtn.snp.bottom).offset(top)
            make.left.equalToSuperview().inset(left)
            make.right.lessThanOrEqualToSuperview().offset(-left)
            make.height.greaterThanOrEqualTo(height)
            make.width.greaterThanOrEqualTo(width)
        }
    }

    private func setUpCompanyNameLabel() {
        companyNameLbl.textColor = Asset.Colors.descColor.color
        companyNameLbl.font = .hiraginoSans(ofSize: 14)
        companyNameLbl.padding = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)

        addSubview(companyNameLbl)

        companyNameLbl.snp.makeConstraints { make in
            let topOffset = 3
            let leftRightInset = 27
            make.top.equalTo(fullNameBtn.snp.bottom).offset(topOffset)
            make.left.right.equalToSuperview().inset(leftRightInset)
        }
    }

    private func setUpPhoneNumberView() {
        phoneNumberView.phoneLbl.text = L10n.ContactsDetailView.phoneNumberLabel

        addSubview(phoneNumberView)

        phoneNumberView.snp.makeConstraints { make in
            let topOffset = 10
            let leftRightOffset = 23
            let height = 35
            make.top.equalTo(companyNameLbl.snp.bottom).offset(topOffset)
            make.left.equalToSuperview().offset(leftRightOffset)
            make.right.lessThanOrEqualToSuperview().inset(leftRightOffset)
            make.height.equalTo(height)
        }
    }

    private func setUpMobileNumberView() {
        mobileNumberView.phoneLbl.text = L10n.ContactsDetailView.cellphoneNumberLabel

        addSubview(mobileNumberView)

        mobileNumberView.snp.makeConstraints { make in
            let topOffset = 5
            let leftRightOffset = 23
            let height = 35
            make.top.equalTo(phoneNumberView.snp.bottom).offset(topOffset)
            make.left.equalToSuperview().offset(leftRightOffset)
            make.right.lessThanOrEqualToSuperview().inset(leftRightOffset)
            make.height.equalTo(height)
        }
    }

    private func setUpPseudoLine() {
        lineView.backgroundColor = Asset.Colors.descColor.color

        addSubview(lineView)

        lineView.snp.makeConstraints { make in
            let height = 0.5
            let topOffset = 10
            make.height.equalTo(height)
            make.top.equalTo(mobileNumberView.snp.bottom).offset(topOffset)
            make.left.right.equalToSuperview()
        }
    }

    private func setUpSendMailView() {
        addSubview(sendMailBtn)

        sendMailBtn.snp.makeConstraints { make in
            let height = 52
            let topOffset = 25
            let leftRightInset = 16
            make.height.equalTo(height)
            make.top.equalTo(lineView.snp.bottom).offset(topOffset)
            make.left.right.equalToSuperview().inset(leftRightInset)
        }
    }

    private func setUpCreateQuoteView() {
        addSubview(createQuotationBtn)

        createQuotationBtn.snp.makeConstraints { make in
            let height = 52
            let topOffset = 8
            let leftRightOffset = 16
            make.height.equalTo(height)
            make.top.equalTo(sendMailBtn.snp.bottom).offset(topOffset)
            make.left.right.equalToSuperview().inset(leftRightOffset)
        }
    }

    private func setUpCreateInvoiceView() {
        addSubview(createInvoiceBtn)

        createInvoiceBtn.snp.makeConstraints { make in
            let height = 52
            let topOffset = 8
            let leftRightOffset = 16
            make.height.equalTo(height)
            make.top.equalTo(createQuotationBtn.snp.bottom).offset(topOffset)
            make.left.right.equalToSuperview().inset(leftRightOffset)
        }
    }
}

extension ContactsDetailView {
    func setUpBindings() {
        setUpPanGestureOnParentView()

        fullNameBtn.reactive
            .controlEvents(.touchUpInside)
            .throttle(Constants.THROTTLE_INTERVAL, on: backgroundSchedule)
            .observe(on: schedule)
            .observeValues { [weak self] _ in
                self?.slideDown { [weak self] () in
                    guard let self = self else { return }
                    self.delegate?.didTapNameButton(self)
                }
            }

        closeBtn.reactive.controlEvents(.touchUpInside)
            .throttle(Constants.THROTTLE_INTERVAL, on: backgroundSchedule)
            .observe(on: schedule)
            .observeValues { [weak self] _ in
                self?.dismissView()
            }

        sendMailBtn.reactive.controlEvents(.touchUpInside)
            .throttle(Constants.THROTTLE_INTERVAL, on: backgroundSchedule)
            .observe(on: schedule)
            .observeValues { [weak self] _ in
                guard let self = self else { return }
                self.delegate?.sendMailBtnDidTap(self)
            }

        createQuotationBtn.reactive.controlEvents(.touchUpInside)
            .throttle(Constants.THROTTLE_INTERVAL, on: backgroundSchedule)
            .observe(on: schedule)
            .observeValues { [weak self] _ in
                self?.slideDown { [weak self] () in
                    guard let self = self else { return }
                    self.delegate?.createQuotationBtnDidTap(self)
                }
            }

        createInvoiceBtn.reactive.controlEvents(.touchUpInside)
            .throttle(Constants.THROTTLE_INTERVAL, on: backgroundSchedule)
            .observe(on: schedule)
            .observeValues { [weak self] _ in
                self?.slideDown { [weak self] () in
                    guard let self = self else { return }
                    self.delegate?.createInvoiceBtnDidTap(self)
                }
            }

        phoneNumberView.phoneBtn.reactive
            .controlEvents(.touchUpInside)
            .observeValues { [weak self] _ in
                guard let self = self else { return }
                self.delegate?.phoneNumberDidTap(self)
            }

        mobileNumberView.phoneBtn.reactive
            .controlEvents(.touchUpInside)
            .observeValues { [weak self] _ in
                guard let self = self else { return }
                self.delegate?.mobileNumberDidTap(self)
            }
    }
}

extension ContactsDetailView {
    func setUpPanGestureOnParentView() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction(_:)))
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        addGestureRecognizer(panGesture)
    }

    func slideUp() {
        UIView.animate(withDuration: 0.3) { [weak self] () in
            guard let self = self else { return }
            self.alpha = 1
            self.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(0)
            }
            self.superview?.layoutIfNeeded()
            self.currentHeight = self.defaultHeight
        }
    }

    func dismissView() {
        slideDown { [weak self] () in
            guard let self = self else { return }
            self.delegate?.dismiss(self)
        }
    }

    func slideDown(with completion: @escaping (() -> Void)) {
        let height = currentHeight
        UIView.animate(withDuration: 0.3) { [weak self] () in
            self?.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(-height)
            }
            self?.superview?.layoutIfNeeded()
        } completion: { _ in
            completion()
        }
    }

    @objc private func panGestureRecognizerAction(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self)
        let isDraggingDown = translation.y > 0
        let newHeight = currentHeight - translation.y

        switch sender.state {
        case .changed:
            if newHeight < maxHeight {
                updateContainerHeight(newHeight)
            }
            break
        case .ended:
            if newHeight < dismissableHeight {
                dismissView()
            }
            else if newHeight < defaultHeight {
                animateContainerHeight(defaultHeight)
            }
            else if newHeight < maxHeight && isDraggingDown {
                animateContainerHeight(defaultHeight)
            }
            else if newHeight > defaultHeight && !isDraggingDown {
                animateContainerHeight(maxHeight)
            }
            break
        default: break
        }
    }

    private func animateContainerHeight(_ height: CGFloat) {
        UIView.animate(withDuration: 0.3) { [weak self] () in
            guard let self = self else { return }
            self.alpha = 1
            self.updateContainerHeight(height)
            self.currentHeight = height
        }
    }

    private func updateContainerHeight(_ height: CGFloat) {
        snp.updateConstraints { make in
            make.height.equalTo(height)
        }
        superview?.layoutIfNeeded()
    }
}

private class PhoneDetailView: UIView {
    var phoneLbl = UILabel()
    var phoneBtn = UIButton()

    init() {
        super.init(frame: .zero)
        setUpView()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    deinit { deinitializeLog() }

    private func setUpView() {
        setUpPhoneLabel()
        setUpPhoneButton()
    }

    private func setUpPhoneLabel() {
        phoneLbl.textColor = Asset.Colors.titleColor.color
        phoneLbl.font = .boldSystemFont(ofSize: 16)

        addSubview(phoneLbl)

        phoneLbl.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.bottom.top.greaterThanOrEqualToSuperview().inset(8)
        }
    }

    private func setUpPhoneButton() {
        phoneBtn.setTitleColor(.pictonBlue, for: .normal)
        phoneBtn.backgroundColor = .clear
        phoneBtn.setFont(.boldSystemFont(ofSize: 16))

        addSubview(phoneBtn)

        phoneBtn.snp.makeConstraints { make in
            let leftOffset = 10
            make.left.lessThanOrEqualTo(phoneLbl.snp.right).offset(leftOffset)
            make.top.bottom.right.equalToSuperview()
        }
    }
}


protocol CustomSwipableViewDelegate: AnyObject {
    func dismiss(_ source: CustomSwipableView)
}

class CustomSwipableView: UIView {

    // MARK: - Properties
    weak var delegate: CustomSwipableViewDelegate?
    internal var currentHeight: CGFloat = 0
    internal let dismissableHeight: CGFloat
    internal let schedule = Constants.MAIN_UI_SCHEDULER
    internal let backgroundSchedule = Constants.BACKGROUND_SCHEDULER
    internal let maxHeight: CGFloat
    internal var defaultHeight: CGFloat
    internal var contentView: UIView

    // MARK: - UI
    private var closeBtn: UIButton = UIButton()

    init(contentView: UIView, height: CGFloat) {
        self.contentView = contentView
        maxHeight = height
        defaultHeight = height
        dismissableHeight = height * 0.6
        super.init(frame: .zero)
        setUpView()
        setUpBindings()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    deinit { deinitializeLog() }

    override func layoutSubviews() {
        super.layoutSubviews()
        let radius: CGFloat = 15
        roundCorners(corners: [.topLeft, .topRight], radius: radius)
    }

    /**
     To dismiss view by tapping using different view.
     */
    func setUpCloseViewGestureOnView(_ view: UIView) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissContactDetailView))
        tapGesture.numberOfTapsRequired = 1
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGesture)
    }

    @objc
    private func dismissContactDetailView() {
        dismissView()
    }
}

extension CustomSwipableView {
    func setUpView() {
        backgroundColor = Asset.Colors.bgSettings.color
        setUpCloseButton()
        setUpContentView()
    }

    private func setUpCloseButton() {
        closeBtn.backgroundColor = .white
        closeBtn.setImage(Asset.Images.swipableArrowDown.image, for: .normal)
        closeBtn.backgroundColor = .clear

        addSubview(closeBtn)

        closeBtn.snp.makeConstraints { make in
            let buttonHeight = 25, buttonWidth = 40, buttonTop = 10
            make.height.width.equalTo(buttonHeight)
            make.width.equalTo(buttonWidth)
            make.top.equalToSuperview().offset(buttonTop)
            make.centerX.equalToSuperview()
        }
    }

    private func setUpContentView() {
        addSubview(contentView)

        contentView.snp.makeConstraints { make in
            let top = 10
            make.top.equalTo(closeBtn.snp.bottom).offset(top)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

extension CustomSwipableView {
    func setUpBindings() {

        setUpPanGestureOnParentView()

        closeBtn.reactive.controlEvents(.touchUpInside)
            .throttle(Constants.THROTTLE_INTERVAL, on: backgroundSchedule)
            .observe(on: schedule)
            .observeValues { [weak self] _ in
                self?.dismissView()
            }
    }

    private func setUpPanGestureOnParentView() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction(_:)))
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        addGestureRecognizer(panGesture)
    }
}

extension CustomSwipableView {

    func slideUp() {
        UIView.animate(withDuration: 0.3) { [weak self] () in
            guard let self = self else { return }
            self.alpha = 1
            self.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(0)
            }
            self.superview?.layoutIfNeeded()
            self.currentHeight = self.defaultHeight
        }
    }

    func dismissView() {
        slideDown { [weak self] () in
            guard let self = self else { return }
            self.endEditing(true)
            self.delegate?.dismiss(self)
        }
    }

    func slideDown(with completion: @escaping (() -> Void)) {
        let height = maxHeight
        UIView.animate(withDuration: 0.3) { [weak self] () in
            self?.snp.updateConstraints { make in
                make.height.equalTo(height)
                make.bottom.equalToSuperview().inset(-height)
            }
            self?.superview?.layoutIfNeeded()
        } completion: { _ in
            completion()
        }
    }

    @objc private func panGestureRecognizerAction(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self)
        let isDraggingDown = translation.y > 0
        let newHeight = currentHeight - translation.y

        switch sender.state {
        case .changed:
            if newHeight < maxHeight {
                updateContainerHeight(newHeight)
            }
            break
        case .ended:
            if newHeight < dismissableHeight {
                dismissView()
            }
            else if newHeight < defaultHeight {
                animateContainerHeight(defaultHeight)
            }
            else if newHeight < maxHeight && isDraggingDown {
                animateContainerHeight(defaultHeight)
            }
            else if newHeight > defaultHeight && !isDraggingDown {
                animateContainerHeight(maxHeight)
            }
            break
        default: break
        }
    }

    private func animateContainerHeight(_ height: CGFloat) {
        UIView.animate(withDuration: 0.3) { [weak self] () in
            guard let self = self else { return }
            self.alpha = 1
            self.updateContainerHeight(height)
            self.currentHeight = height
        }
    }

    private func updateContainerHeight(_ height: CGFloat) {
        snp.updateConstraints { make in
            make.height.equalTo(height)
        }
        superview?.layoutIfNeeded()
    }
}
