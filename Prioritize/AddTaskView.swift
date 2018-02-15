//
//  AddTaskView.swift
//  Prioritize
//
//  Created by Mikołaj Stępniewski on 23.09.2017.
//  Copyright © 2017 Mikołaj Stępniewski. All rights reserved.
//

import UIKit



class AddTaskView: UIView, TMCustomViewProtocol {
    //MARK: Variables
    private var titleTextField:UITextField = {
        let textField = UITextField()
        textField.font = UIFont(name: "Helvetica-Bold", size: 23)
        
        textField.attributedPlaceholder = NSAttributedString(string: "Set title", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.3)])
        textField.textColor = .white
        
        textField.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        textField.autocorrectionType = .no
        textField.textAlignment = .center
        
        return textField
    }()
    
    private var titleLabel:UILabel = {
       let label = UILabel()
        label.font = UIFont(name: "Helvetica-Bold", size: 13)
        label.textColor = .white
        label.text = "Task title"
        label.textAlignment = .center
        label.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        return label
    }()
    
    fileprivate var descriptionTextView:UITextView = {
        let textView = UITextView()
        textView.font = UIFont(name: "Helvetica-Bold", size: 13)
        textView.textColor = .white
        textView.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        textView.autocorrectionType = .no
        textView.text = "Set description"
        textView.textColor = UIColor.white.withAlphaComponent(0.3)
        textView.textAlignment = .center
        return textView
    }()
    
    private var descriptionLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica-Bold", size: 13)
        label.textColor = .white
        label.text = "Task description"
        label.textAlignment = .center
        label.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        return label
    }()
    
    private var segmentedControl:UISegmentedControl = {
        let items = ["Info", "Deadline", "Work time", "Color"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(respondToSegmentChange(sender:)), for: .valueChanged)
        
        return control
    }()
    
    //MARK: - Deadline Views
    private var deadlineDatePicker:UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.timeZone = NSTimeZone.local
        picker.addTarget(self, action: #selector(deadlinePickerValueChanged(sender:)), for: .valueChanged)
        picker.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        return picker
    }()
    
    private var deadlineLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica-Bold", size: 13)
        label.textColor = .white
        label.text = "Pick date"
        label.textAlignment = .center
        label.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        return label
    }()
    
    //MARK: - Work Time Views
    private var workTimeDatePicker:UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .countDownTimer
        picker.addTarget(self, action: #selector(workTimePickerValueChanged(sender:)), for: .valueChanged)
        picker.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        return picker
    }()
    
    private lazy var workTimeDaysPicker:UIPickerView = {
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        picker.selectRow(0, inComponent: 0, animated: true)
        picker.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        picker.showsSelectionIndicator = true
        return picker
    }()
    
    private var workTimeLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica-Bold", size: 13)
        label.textColor = .white
        label.text = "Set how long it is going to take"
        label.textAlignment = .center
        label.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        return label
    }()
    
    private var daysFixedLabel:UILabel = {
        let label = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: 60, height: 32)))
        label.text = "days"

        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    

    var currentView:CurrenView!
    fileprivate var hours = 150
 
    
    enum CurrenView {
        case info, deadline, workTime, color
    }
    
    override func awakeFromNib() {
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setUpInfoSegment()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func deadlinePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        deadlineLabel.text = "Deadline:  \(dateFormatter.string(from: sender.date))"
    }
    
    @objc func workTimePickerValueChanged(sender:UIDatePicker) {
        
    }
    

    
    private func setupViews() {
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        addSubview(segmentedControl)
        
        segmentedControl.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        segmentedControl.topAnchor.constraint(equalTo: self.topAnchor, constant: 40).isActive = true
        segmentedControl.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        segmentedControl.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        
        segmentedControl.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
    }
    
    
    @objc func respondToSegmentChange(sender:UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            if currentView != .info {
                hideSegment()
                setUpInfoSegment()
            }
            break
        case 1:
            if currentView != .deadline {
                hideSegment()
                setUpTimeSegment()
            }
            break
        case 2:
            if currentView != .workTime {
                hideSegment()
                setUpWorkTimeSegment()
            }
            break
        case 3:
            if currentView != .color {
                hideSegment()
                currentView = .color
            }
            break
        default:
            break
        }
        layoutIfNeeded()
    }
    
    //MARK: - ℹ️
    func setUpInfoSegment() {
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleTextField)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(descriptionTextView)
        
        //MARK: - Title Label
        let titleLabelConstraints:[NSLayoutConstraint] = [
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            titleLabel.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            titleLabel.heightAnchor.constraint(equalToConstant: 30)
        ]
        NSLayoutConstraint.activate(titleLabelConstraints)
        
        //MARK: - Title Text Field
        let titleTextFieldConstraints:[NSLayoutConstraint] = [
            titleTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            titleTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            titleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0),
            titleTextField.heightAnchor.constraint(equalToConstant: 40)
        ]
        NSLayoutConstraint.activate(titleTextFieldConstraints)
        
        //MARK: - Description Label
        let descriptionLabelConstraints:[NSLayoutConstraint] = [
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            descriptionLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 30)
        
        ]
        NSLayoutConstraint.activate(descriptionLabelConstraints)
        
        //MARK: - Description Text View
        let descriptionTextViewConstraints:[NSLayoutConstraint] = [
            descriptionTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant:0),
            descriptionTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            descriptionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 0),
            descriptionTextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        ]
        NSLayoutConstraint.activate(descriptionTextViewConstraints)
        
        
        descriptionTextView.delegate = self
        currentView = .info
    }
    
    //MARK: - ☠️⏱ Deadline
    func setUpTimeSegment() {
        deadlineDatePicker.translatesAutoresizingMaskIntoConstraints = false
        deadlineLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(deadlineDatePicker)
        addSubview(deadlineLabel)
        
        //MARK: - Description Text View
        let deadlineLabelConstraints:[NSLayoutConstraint] = [
            deadlineLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            deadlineLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            deadlineLabel.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            deadlineLabel.heightAnchor.constraint(equalToConstant: 30),
        ]
        NSLayoutConstraint.activate(deadlineLabelConstraints)
        
        //MARK: - Description Text View
        let deadlineDatePickerConstraints:[NSLayoutConstraint] = [
            deadlineDatePicker.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            deadlineDatePicker.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            deadlineDatePicker.topAnchor.constraint(equalTo: deadlineLabel.bottomAnchor, constant: 0),
            deadlineDatePicker.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        NSLayoutConstraint.activate(deadlineDatePickerConstraints)
        
        
        currentView = .deadline
    }
    
    //MARK: - 💼⏱ Work Time
    func setUpWorkTimeSegment() {
        workTimeDatePicker.translatesAutoresizingMaskIntoConstraints = false
        workTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        workTimeDaysPicker.translatesAutoresizingMaskIntoConstraints = false
        addSubview(workTimeDatePicker)
        addSubview(workTimeLabel)
        addSubview(workTimeDaysPicker)
        
        //MARK: - Description Text View
        let deadlineLabelConstraints:[NSLayoutConstraint] = [
            workTimeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            workTimeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            workTimeLabel.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            workTimeLabel.heightAnchor.constraint(equalToConstant: 30)
        ]
        NSLayoutConstraint.activate(deadlineLabelConstraints)
        
        //MARK: - Description Text View
        let deadlineDatePickerConstraints:[NSLayoutConstraint] = [
            workTimeDatePicker.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 150),
            workTimeDatePicker.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            workTimeDatePicker.topAnchor.constraint(equalTo: workTimeLabel.bottomAnchor, constant: 0),
            workTimeDatePicker.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        NSLayoutConstraint.activate(deadlineDatePickerConstraints)
        
        //MARK: - Description Text View
        let workTimeDaysPickerConstraints:[NSLayoutConstraint] = [
            workTimeDaysPicker.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            workTimeDaysPicker.trailingAnchor.constraint(equalTo: workTimeDatePicker.leadingAnchor, constant: 0),
            workTimeDaysPicker.topAnchor.constraint(equalTo: workTimeLabel.bottomAnchor, constant: 0),
            workTimeDaysPicker.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        NSLayoutConstraint.activate(workTimeDaysPickerConstraints)
        
        layoutIfNeeded()
        
        let fixedLabelPosX = workTimeDaysPicker.frame.origin.x + workTimeDaysPicker.frame.width/2 + 45
        let fixedLabelPosY = workTimeDaysPicker.frame.origin.y + workTimeDaysPicker.frame.height/2 + 1.5
        
        let fixedLabelPos = CGPoint(x: fixedLabelPosX, y: fixedLabelPosY)
        
        daysFixedLabel.center = fixedLabelPos
        addSubview(daysFixedLabel)
        
        
        currentView = .workTime
    }
    
    func setUpColorSegment() {
        /// To make Color Palette look normal (no vibrant blur effect), Palette View must
        /// be added to Blur Effect Content View (CV), not Vibrant Effect CV (which is
        /// our superview here).
        ///                       VibrantCV   Vibrant    BlurCV
        let blurViewContentView = superview?.superview?.superview
        
        //MARK: - TODO
    }
    
    func hideSegment() {
        switch currentView {
        case .info:
            titleTextField.removeFromSuperview()
            titleLabel.removeFromSuperview()
            descriptionTextView.removeFromSuperview()
            descriptionLabel.removeFromSuperview()
            break
        case .deadline:
            deadlineDatePicker.removeFromSuperview()
            deadlineLabel.removeFromSuperview()
            break
        case .workTime:
            workTimeLabel.removeFromSuperview()
            workTimeDatePicker.removeFromSuperview()
            workTimeDaysPicker.removeFromSuperview()
            daysFixedLabel.removeFromSuperview()
            break
        case .color:
            break
        default:
            break
        }
    }

    func getOutput() -> Dictionary<String, Any> {
        var params = Dictionary<String, Any>()
        params["title"] = self.titleTextField.text
        params["description"] = self.descriptionTextView.text
        params["deadline"] = self.deadlineDatePicker.date
        params["workTime"] = self.workTimeDatePicker.countDownDuration
        
        
        return params
    }
}


//MARK: - ⚡️ Extensions

extension AddTaskView:UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text != "" {
            textView.textColor = .white
            textView.font = UIFont(name: "Helvetica", size: 13)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Set description" {
            textView.text = nil
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.textColor = UIColor.white.withAlphaComponent(0.3)
            textView.text = "Set description"
            textView.font = UIFont(name: "Helvetica-Bold", size: 13)
        }
    }
}

extension AddTaskView:UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return hours
    }
}

extension AddTaskView:UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.right
        style.tailIndent = 53
        return NSAttributedString(string: String(row), attributes: [ NSAttributedStringKey.paragraphStyle: style])
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 106
    }
}
