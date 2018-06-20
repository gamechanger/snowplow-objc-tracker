//
//  SPUtilities.swift
//  Snowplow
//
//  Created by Alex Young on 6/20/18.
//  Copyright © 2018 Snowplow Analytics. All rights reserved.
//

import Foundation
import CoreTelephony
import UserNotifications

@objc final class SPUtilities: NSObject {

    @objc static var getTimezone: String {
        return NSTimeZone.system.identifier
    }
    @objc static var getLanguage: String {
        return NSLocale.preferredLanguages.first ?? " No preferred language"
    }
    @objc static var getPlatform: String {
        return "mob"
    }
    @objc static var getEventId: String {
        return UUID().uuidString
    }
    @objc static var getOpenIdfa: String? {
        #if !SNOWPLOW_NO_OPENIDFA
            if #available(iOS 9.0, *) {
                return OpenIDFA.sameDayOpenIDFA()
            }
        #endif
        return nil
    }
    @objc static var getAppleIdfa: String? {
        return nil // TODO
    }
    @objc static var getAppleIdfv: String? {
        #if !SNOWPLOW_NO_IDV
            return UIDevice.current.identifierForVendor?.uuidString
        #else
            return nil
        #endif
    }
    @objc static var getCarrierName: String? {
        return CTTelephonyNetworkInfo().subscriberCellularProvider?.carrierName
    }
    @objc static var getNetworkType: String {
        return "" // FIXME ReachabilitySwift
    }
    @objc static var getNetworkTechnology: String? {
        return CTTelephonyNetworkInfo().currentRadioAccessTechnology
    }
    @objc static var getTransactionId: Int {
        return Int(arc4random() % (999999 - 100000+1) + 100000)
    }
    @objc static var getTimestamp: NSNumber {
        return NSNumber(value: Date().timeIntervalSince1970 * 1000)
    }
    @objc static var getResolution: String {
        let resolution = UIScreen.main.bounds.size * UIScreen.main.scale
        return String(format: "%.0fx%.0f", resolution.width, resolution.height)
    }
    @objc static var getViewPort: String {
        return self.getResolution
    }
    @objc static var getDeviceVendor: String {
        return "Apple Inc."
    }
    @objc static var getDeviceModel: String {
        return UIDevice.current.model
    }
    @objc static var getOSVersion: String {
        return UIDevice.current.systemVersion
    }
    @objc static var getOSType: String {
        return "ios"
    }
    @objc static var getAppId: String? {
        return Bundle.main.bundleIdentifier
    }
    @objc(urlEncodeString:)
    static func urlEncode(string: String?) -> String? {
        return string?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    }

    @objc(urlEncodeDictionary:)
    static func urlEncode(dictionary: [String:String]?) -> String {
        guard let dictionary = dictionary else {
            return ""
        }
        return dictionary.compactMap {
            if let key = self.urlEncode(string: $0.key),
               let value = self.urlEncode(string: $0.value) {
                return String(format: "%@=%@", key, value)
            }
            return nil
        }.joined(separator: "&")
    }
    @objc static func getByteSize(withString str: String) -> Int {
        return str.lengthOfBytes(using: .utf8)
    }
    @objc static var isOnline: Bool {
        return true // FIXME ReachabilitySwift
    }
    @objc(checkArgument:withMessage:)
    static func check(argument: Bool, withMessage message: String) {
        guard argument else {
            NSException.raise(
                NSExceptionName("IllegalArgumentException"),
                format: "%@",
                arguments: getVaList([message])
            )
            return
        }
    }
    @available(iOS 10.0, *)
    @objc static func get(triggerType trigger: UNNotificationTrigger) -> String {
        switch trigger {
        case is UNTimeIntervalNotificationTrigger:
            return "TIME_INTERVAL"
        case is UNCalendarNotificationTrigger:
            return "CALENDAR"
        case is UNLocationNotificationTrigger:
            return "LOCATION"
        case is UNPushNotificationTrigger:
            return "PUSH"
        default:
            return "UNKNOWN"
        }
    }
    @available(iOS 10.0, *)
    @objc static func convert(attachments: [UNNotificationAttachment]) -> [[String:Any]] {
        return attachments.map { attachment in
            return [
                kSPPnAttachmentId: attachment.identifier,
                kSPPnAttachmentUrl: attachment.url,
                kSPPnAttachmentType: attachment.type
            ]
        }
    }
    @objc static func removeNullValues(fromDictWithDict dict: NSDictionary) -> NSDictionary {
        return dict.reduce(NSMutableDictionary()) { result, pair in
            if type(of: pair.value) != NSNull.self {
                result[pair.key] = pair.value
            }
            return result
        }
    }
    @objc(replaceHyphenatedKeysWithCamelcase:)
    static func replaceHyphenatedKeysWithCamelcase(dict: NSDictionary) -> NSDictionary {
        return dict.reduce(NSMutableDictionary()) { result, pair in
            let key: Any
            if let hyphenatedKey = pair.key as? String, hyphenatedKey.contains("-") {
                key = self.camelcase(parsedKey: hyphenatedKey)
            } else {
                key = pair.key
            }
            if let value = pair.value as? NSDictionary {
                result[key] = self.replaceHyphenatedKeysWithCamelcase(dict: value)
            } else {
                result[key] = pair.value
            }
            return result
        }
    }
    @objc static func camelcase(parsedKey key: String) -> String {
        let scanner = Scanner(string: key)
        var words: [NSString?] = []
        var scannedWord: NSString? = NSString()
        while !scanner.isAtEnd {
            scanner.scanUpTo("-", into: &scannedWord)
            words.append(scannedWord)
            scanner.scanString("-", into: nil)
        }
        if let word = words.first as? String {
            if words.count == 1 {
                return word.lowercased()
            } else if let range = Range(NSRange(location: 1, length: words.count - 1)) {
                return words[range].reduce(word.lowercased()) {
                    var result = $0
                    if let word = ($1 as String?)?.capitalized {
                        result.append(word)
                    }
                    return result
                }
            }
        }
        return ""
    }
}

private extension CGSize {

    static func *(size: CGSize, multiplier: CGFloat) -> CGSize {
        return CGSize(
            width: size.width * multiplier,
            height: size.height * multiplier
        )
    }
}
