//
//  DatePickerTextField.swift
//  What?fle
//
//  Created by 이정환 on 8/24/24.
//

import UIKit

final class DatePickerTextField: TextFieldWithUnderline {
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ko_KR")
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return datePicker
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        inputView = datePicker // datePicker를 텍스트 필드의 inputView로 설정
        self.addDoneButtonOnKeyboard()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        inputView = datePicker
        addDoneButtonOnKeyboard()
    }

    @objc private func dateChanged(_ sender: UIDatePicker) {
        self.attributedText = NSAttributedString.makeAttributedString(
            text: sender.date.formattedYYMMDDWithDot,
            font: .body14MD,
            textColor: .textDefault,
            lineHeight: 20
        )
    }
}
