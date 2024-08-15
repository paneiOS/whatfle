//
//  UIColor+Resources.swift
//  What?fle
//
//  Created by 이정환 on 2/22/24.
//

import UIKit

// MARK: - Design Color

extension UIColor {

    // MARK: - ColorType

    enum ColorType: String {

        // MARK: - core

        case background = "F6F8FB"
        case primary = "FFC93F"
        case primaryDisabled = "C4C4CD"
        case p100 = "FFFBD3"
        case p400 = "FF9110"
        case secondary = "335384"
        case warning = "FC544E"
        case approve = "2F8BF7"

        // MARK: - grayScale

        case white = "FFFFFF"
        case g100 = "E5E6EE"
        case g200 = "C9CBD8"
        case g300 = "B3B3C6"
        case g400 = "9999B8"
        case g500 = "7D7D99"
        case g600 = "64657F"
        case g700 = "494A69"
        case g800 = "383850"
        case g900 = "252536"
        case black = "16161F"
    }

    static func typeToColor(type: ColorType) -> UIColor {
        return UIColor(hexCode: type.rawValue)
    }

    // MARK: - DimmedType

    enum DimmedType: Double {
        case dimmed20 = 0.2
        case dimmed50 = 0.5
    }

    static func alphaToColor(alpha: DimmedType) -> UIColor {
        return .init(red: 0, green: 0, blue: 0, alpha: alpha.rawValue)
    }
}

// MARK: - Core Color

extension UIColor {
    enum Core {
        static var background: UIColor {
            return .typeToColor(type: .background)
        }

        static var primary: UIColor {
            return .typeToColor(type: .primary)
        }

        static var primaryDisabled: UIColor {
            return .typeToColor(type: .primaryDisabled)
        }

        static var p100: UIColor {
            return .typeToColor(type: .p100)
        }

        static var p400: UIColor {
            return .typeToColor(type: .p400)
        }

        static var secondary: UIColor {
            return .typeToColor(type: .secondary)
        }

        static var warning: UIColor {
            return .typeToColor(type: .warning)
        }

        static var approve: UIColor {
            return .typeToColor(type: .approve)
        }

        static var dimmed20: UIColor {
            return .alphaToColor(alpha: .dimmed20)
        }

        static var dimmed50: UIColor {
            return .alphaToColor(alpha: .dimmed50)
        }
    }
}

// MARK: - Text&Line Color

extension UIColor {
    static var textDefault: UIColor {
        return .GrayScale.black
    }

    static var textLight: UIColor {
        return .GrayScale.g600
    }

    static var textExtralight: UIColor {
        return .GrayScale.g300
    }

    static var lineDefault: UIColor {
        return .GrayScale.g200
    }

    static var lineLight: UIColor {
        return .GrayScale.g100
    }

    static var lineExtralight: UIColor {
        return .Core.background
    }
}

// MARK: - GrayScale Color

extension UIColor {
    enum GrayScale {
        static var white: UIColor {
            return .typeToColor(type: .white)
        }

        static var g100: UIColor {
            return .typeToColor(type: .g100)
        }

        static var g200: UIColor {
            return .typeToColor(type: .g200)
        }

        static var g300: UIColor {
            return .typeToColor(type: .g300)
        }

        static var g400: UIColor {
            return .typeToColor(type: .g400)
        }

        static var g500: UIColor {
            return .typeToColor(type: .g500)
        }

        static var g600: UIColor {
            return .typeToColor(type: .g600)
        }

        static var g700: UIColor {
            return .typeToColor(type: .g700)
        }

        static var g800: UIColor {
            return .typeToColor(type: .g800)
        }

        static var g900: UIColor {
            return .typeToColor(type: .g900)
        }

        static var black: UIColor {
            return .typeToColor(type: .black)
        }
    }
}

// MARK: - Gradient Color

extension CAGradientLayer {
    enum GradientType: Int, CaseIterable {
        case firstGradient = 0
        case secondGradient
        case thirdGradient
    }

    static func createGradient(type: GradientType) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        switch type {
        case .firstGradient:
            gradientLayer.colors = [
                UIColor(red: 255/255, green: 236/255, blue: 63/255, alpha: 1).cgColor,
                UIColor(red: 255/255, green: 191/255, blue: 94/255, alpha: 1).cgColor
            ]
            gradientLayer.locations = [0.0, 1.0]
        case .secondGradient:
            gradientLayer.colors = [
                UIColor(red: 255/255, green: 145/255, blue: 16/255, alpha: 0.1).cgColor,
                UIColor(red: 255/255, green: 145/255, blue: 16/255, alpha: 0).cgColor
            ]
            gradientLayer.locations = [0.0, 1.0]
        case .thirdGradient:
            gradientLayer.colors = [
                UIColor(red: 255/255, green: 145/255, blue: 16/255, alpha: 0.2).cgColor,
                UIColor(red: 255/255, green: 145/255, blue: 16/255, alpha: 0).cgColor
            ]
            gradientLayer.locations = [0.0, 1.0]
        }
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        return gradientLayer
    }
}
