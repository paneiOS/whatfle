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

    enum ColorType {

        // MARK: - core

        case background
        case primary
        case primaryDisabled
        case p100
        case p400
        case secondary
        case warning
        case approve

        // MARK: - grayScale

        case white
        case g100
        case g200
        case g300
        case g400
        case g500
        case g600
        case g700
        case g800
        case g900
        case black
        
        var color: UIColor {
            switch self {
            case .background:
                return #colorLiteral(red: 0.9647058824, green: 0.9725490196, blue: 0.9843137255, alpha: 1) // F6F8FB
            case .primary:
                return #colorLiteral(red: 1.0, green: 0.7882352941, blue: 0.2470588235, alpha: 1) // FFC93F
            case .primaryDisabled:
                return #colorLiteral(red: 0.768627451, green: 0.768627451, blue: 0.8039215686, alpha: 1) // C4C4CD
            case .p100:
                return #colorLiteral(red: 1.0, green: 0.9843137255, blue: 0.8274509804, alpha: 1) // FFFBD3
            case .p400:
                return #colorLiteral(red: 1.0, green: 0.568627451, blue: 0.06274509804, alpha: 1) // FF9110
            case .secondary:
                return #colorLiteral(red: 0.2, green: 0.3254901961, blue: 0.5176470588, alpha: 1) // 335384
            case .warning:
                return #colorLiteral(red: 0.9882352941, green: 0.3294117647, blue: 0.3058823529, alpha: 1) // FC544E
            case .approve:
                return #colorLiteral(red: 0.1843137255, green: 0.5450980392, blue: 0.968627451, alpha: 1) // 2F8BF7
            case .white:
                return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) // FFFFFF
            case .g100:
                return #colorLiteral(red: 0.8980392157, green: 0.9019607843, blue: 0.9333333333, alpha: 1) // E5E6EE
            case .g200:
                return #colorLiteral(red: 0.7882352941, green: 0.7960784314, blue: 0.8470588235, alpha: 1) // C9CBD8
            case .g300:
                return #colorLiteral(red: 0.7019607843, green: 0.7019607843, blue: 0.7764705882, alpha: 1) // B3B3C6
            case .g400:
                return #colorLiteral(red: 0.6, green: 0.6, blue: 0.7215686275, alpha: 1) // 9999B8
            case .g500:
                return #colorLiteral(red: 0.4901960784, green: 0.4901960784, blue: 0.6, alpha: 1) // 7D7D99
            case .g600:
                return #colorLiteral(red: 0.3921568627, green: 0.3960784314, blue: 0.4980392157, alpha: 1) // 64657F
            case .g700:
                return #colorLiteral(red: 0.2862745098, green: 0.2901960784, blue: 0.4117647059, alpha: 1) // 494A69
            case .g800:
                return #colorLiteral(red: 0.2196078431, green: 0.2196078431, blue: 0.3137254902, alpha: 1) // 383850
            case .g900:
                return #colorLiteral(red: 0.1450980392, green: 0.1450980392, blue: 0.2117647059, alpha: 1) // 252536
            case .black:
                return #colorLiteral(red: 0.0862745098, green: 0.0862745098, blue: 0.1215686275, alpha: 1) // 16161F
            }
        }
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
            return .ColorType.background.color
        }

        static var primary: UIColor {
            return .ColorType.primary.color
        }

        static var primaryDisabled: UIColor {
            return .ColorType.primaryDisabled.color
        }

        static var p100: UIColor {
            return .ColorType.p100.color
        }

        static var p400: UIColor {
            return .ColorType.p400.color
        }

        static var secondary: UIColor {
            return .ColorType.secondary.color
        }

        static var warning: UIColor {
            return .ColorType.warning.color
        }

        static var approve: UIColor {
            return .ColorType.approve.color
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
            return .ColorType.white.color
        }

        static var g100: UIColor {
            return .ColorType.g100.color
        }

        static var g200: UIColor {
            return .ColorType.g200.color
        }

        static var g300: UIColor {
            return .ColorType.g300.color
        }

        static var g400: UIColor {
            return .ColorType.g400.color
        }

        static var g500: UIColor {
            return .ColorType.g500.color
        }

        static var g600: UIColor {
            return .ColorType.g600.color
        }

        static var g700: UIColor {
            return .ColorType.g700.color
        }

        static var g800: UIColor {
            return .ColorType.g800.color
        }

        static var g900: UIColor {
            return .ColorType.g900.color
        }

        static var black: UIColor {
            return .ColorType.black.color
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
