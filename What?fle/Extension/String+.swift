//
//  String+.swift
//  What?fle
//
//  Created by 이정환 on 3/29/24.
//

import UIKit

extension NSAttributedString {
    static func makeAttributedString(
        text: String,
        font: UIFont,
        textColor: UIColor,
        lineHeight: CGFloat,
        lineSpacing: CGFloat = 0.0,
        lineBreakMode: NSLineBreakMode = .byTruncatingTail,
        alignment: NSTextAlignment = .left,
        additionalAttributes: [(text: String, attribute: [NSAttributedString.Key: Any])]? = nil
    ) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = alignment
        paragraphStyle.lineBreakMode = lineBreakMode
        let baseAttributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .font: font,
            .foregroundColor: textColor,
            .baselineOffset: (lineHeight - font.lineHeight) / 2
        ]

        if let additionalAttributes {
            let attributedString = NSMutableAttributedString(string: text, attributes: baseAttributes)
            for additionalAttribute in additionalAttributes {
                let range = (text as NSString).range(of: additionalAttribute.text)
                attributedString.addAttributes(additionalAttribute.attribute, range: range)
            }
            return attributedString
        }
        return NSAttributedString(string: text, attributes: baseAttributes)
    }

    func height(containerWidth: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: containerWidth, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        let paragraphStyle = self.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle
        let lineHeight = paragraphStyle?.minimumLineHeight ?? boundingBox.height
        let numberOfLines = ceil(boundingBox.height / lineHeight)
        return numberOfLines * lineHeight
    }

    func width(containerHeight: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: containerHeight)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        return ceil(boundingBox.width)
    }
}

extension String {
    func replaceHyphensWithDots() -> String {
        return self.replacingOccurrences(of: "-", with: ".")
    }

    func isValidLength(to min: Int, from max: Int) -> Bool {
        return self.count >= min && self.count <= max
    }

    func isValidRegistTag() -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", "^[가-힣ㄱ-ㅎㅏ-ㅣa-zA-Z0-9]*$").evaluate(with: self)
    }

    func toFormattedDateString(fromFormat: String = "yy.MM.dd", toFormat: String = "yyyy-MM-dd") -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromFormat
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        guard let date = dateFormatter.date(from: self) else {
            return nil
        }
        dateFormatter.dateFormat = toFormat
        return dateFormatter.string(from: date)
    }
}
