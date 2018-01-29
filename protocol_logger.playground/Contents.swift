
import Foundation

protocol LoggerProfileProtocol {
    var loggerProfileId: String { get }
    func writeLog(level: String, message: String)
}

extension LoggerProfileProtocol {
    func getCurrentDateString() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy hh:ss"
        return dateFormatter.string(from: date)
    }
}

struct LoggerNull: LoggerProfileProtocol {
    let loggerProfileId: String = "lp.logger.null"
    func writeLog(level: String, message: String) {
        //do nothing
    }
}

struct LoggerConsole: LoggerProfileProtocol {
    let loggerProfileId: String = "lp.logger.console"
    func writeLog(level: String, message: String) {
        let now = getCurrentDateString()
        print("\(now): \(level) - \(message)")
    }
}

enum LogLevels: String {
    case Fatal
    case Error
    case Warn
    case Debug
    case Info

    static let allValues = [Fatal, Error, Warn, Debug, Info]
}

protocol LoggerProtocol {
    static var loggers: [LogLevels: [LoggerProfileProtocol]] { get set }
    static func writeLog(logLevel: LogLevels, message: String)
}

extension LoggerProtocol {
    static func LogLevelContainsProfile(logLevel: LogLevels,
                                        loggerProfile: LoggerProfileProtocol) -> Bool {
        if let logProfiles = loggers[logLevel] {
            for logProfile in logProfiles where
                logProfile.loggerProfileId == loggerProfile.loggerProfileId {
                return true
            }
        }
        return false
    }

    static func setLogLevel(logLevel: LogLevels, loggerProfile: LoggerProfileProtocol) {
        if let _ = loggers[logLevel] {
            if !LogLevelContainsProfile(logLevel: logLevel, loggerProfile: loggerProfile) {
                loggers[logLevel]?.append(loggerProfile)
            }
        } else {
            var a = [LoggerProfileProtocol]()
            a.append(loggerProfile)
            loggers[logLevel] = a
        }
    }

    static func addLogProfileToAllLoevels(defaultLoggerProfile: LoggerProfileProtocol) {
        for level in LogLevels.allValues {
            setLogLevel(logLevel: level, loggerProfile: defaultLoggerProfile)
        }
    }

    static func removeLogProfileFromLevel(logLevel: LogLevels,
                                              loggerProfile: LoggerProfileProtocol) {
        if var logProfiles = loggers[logLevel] {
            if let index = logProfiles.index(where: {$0.loggerProfileId == loggerProfile.loggerProfileId }) {
                logProfiles.remove(at: index)
            }
            loggers[logLevel] = logProfiles
        }
    }

    static func removeLogProfileFromAllLevels(loggerProfile: LoggerProfileProtocol) {
        for level in LogLevels.allValues {
            removeLogProfileFromLevel(logLevel: level, loggerProfile: loggerProfile)
        }
    }

    static func hasLoggerForLevel(logLevel: LogLevels) -> Bool {
        guard let _ = loggers[logLevel] else {
            return false
        }
        return true
    }

}

struct Logger: LoggerProtocol {
    static var loggers = [LogLevels: [LoggerProfileProtocol]]()

    static func writeLog(logLevel: LogLevels, message: String) {
        guard hasLoggerForLevel(logLevel: logLevel) else {
            print("no logger")
            return
        }

        if let logProfiles = loggers[logLevel] {
            for logProfile in logProfiles {
                logProfile.writeLog(level: logLevel.rawValue, message: message)
            }
        }
    }
}


Logger.addLogProfileToAllLoevels(defaultLoggerProfile: LoggerConsole())
Logger.writeLog(logLevel: LogLevels.Debug, message: "Debug Message 1")

Logger.setLogLevel(logLevel: LogLevels.Error, loggerProfile: LoggerConsole())
Logger.writeLog(logLevel: LogLevels.Error, message: "Error message 1")




