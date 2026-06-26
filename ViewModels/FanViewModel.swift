import SwiftUI
import AppKit

// MARK: - View Model
class FanViewModel: ObservableObject {
    @Published var fans: [FanJSON] = []
    @Published var cpuTemp: Double? = nil
    @Published var gpuTemp: Double? = nil
    @Published var batteryTemp: Double? = nil
    @Published var tempHistory: [TempRecord] = []
    
    private var lastHistoryRecordTime: Date? = nil
    
    @Published var isAuthorized: Bool = false
    @Published var linkedFans: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isPollingActive: Bool = false
    
    private var isFetchingStatus: Bool = false
    
    @Published var rules: [TriggerRule] = [] {
        didSet {
            saveRules()
        }
    }
    @Published var isRulesEngineEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(isRulesEngineEnabled, forKey: "isRulesEngineEnabled")
            if !isRulesEngineEnabled && wasRuleApplied {
                resetAll()
                wasRuleApplied = false
                lastSetSpeedPercent = nil
            }
        }
    }
    private var wasRuleApplied = false
    private var lastSetSpeedPercent: Double? = nil
    
    private var timer: Timer? = nil
    
    var helperPath: String {
        let bundleHelper = Bundle.main.bundlePath + "/Contents/MacOS/smc-helper"
        if FileManager.default.fileExists(atPath: bundleHelper) {
            return bundleHelper
        }
        return FileManager.default.currentDirectoryPath + "/smc-helper"
    }
    
    init() {
        checkAuthorization()
        loadRules()
        loadHistory()
        startPolling()
    }
    
    func checkAuthorization() {
        let path = helperPath
        guard FileManager.default.fileExists(atPath: path) else {
            DispatchQueue.main.async {
                self.isAuthorized = false
            }
            return
        }
        
        if let attributes = try? FileManager.default.attributesOfItem(atPath: path) {
            let ownerId = attributes[.ownerAccountID] as? Int ?? -1
            let posixPermissions = attributes[.posixPermissions] as? Int ?? 0
            let isSetuid = (posixPermissions & 0o4000) != 0
            
            DispatchQueue.main.async {
                self.isAuthorized = (ownerId == 0 && isSetuid)
            }
        } else {
            DispatchQueue.main.async {
                self.isAuthorized = false
            }
        }
    }
    
    func authorize() {
        let path = helperPath
        guard FileManager.default.fileExists(atPath: path) else {
            self.errorMessage = "Helper tool 'smc-helper' not found. Please verify project compilation."
            return
        }
        
        let appleScriptSource = """
        do shell script "chown root:wheel '\(path)' && chmod +s '\(path)'" with administrator privileges
        """
        
        guard let appleScript = NSAppleScript(source: appleScriptSource) else {
            self.errorMessage = "Failed to compile authorization script."
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            var error: NSDictionary? = nil
            appleScript.executeAndReturnError(&error)
            
            DispatchQueue.main.async {
                if let err = error {
                    let desc = err[NSAppleScript.errorMessage] as? String ?? "Authorization rejected or failed."
                    if desc.contains("Read-only file system") {
                        self.errorMessage = "Please move Fan Control to your Applications folder before authorizing. The helper tool cannot be configured on a read-only disk image."
                    } else {
                        self.errorMessage = desc
                    }
                    self.isAuthorized = false
                } else {
                    self.errorMessage = nil
                    self.isAuthorized = true
                    self.updateStatus()
                }
            }
        }
    }
    
    func startPolling() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
            self?.updateStatus()
        }
        updateStatus()
    }
    
    func updateStatus() {
        let path = helperPath
        guard FileManager.default.fileExists(atPath: path) else { return }
        
        guard !isFetchingStatus else { return }
        isFetchingStatus = true
        
        DispatchQueue.global(qos: .default).async {
            let task = Process()
            task.executableURL = URL(fileURLWithPath: path)
            task.arguments = ["get"]
            
            let pipe = Pipe()
            task.standardOutput = pipe
            task.standardError = pipe
            
            defer {
                self.isFetchingStatus = false
            }
            
            do {
                try task.run()
                
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                task.waitUntilExit()
                pipe.fileHandleForReading.closeFile()
                
                if let decoded = try? JSONDecoder().decode(SystemStatusJSON.self, from: data) {
                    DispatchQueue.main.async {
                        self.fans = decoded.fans
                        self.cpuTemp = decoded.cpuTemp
                        self.gpuTemp = decoded.gpuTemp
                        self.batteryTemp = decoded.batteryTemp
                        self.isPollingActive = true
                        self.evaluateRules()
                        self.recordHistoryIfNeeded()
                    }
                }
            } catch {
                print("Status fetch failed: \(error)")
            }
        }
    }
    
    func setFanMode(fanId: Int, mode: Int, speed: Int? = nil) {
        let path = helperPath
        guard FileManager.default.fileExists(atPath: path) else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let task = Process()
            task.executableURL = URL(fileURLWithPath: path)
            
            var args = ["set", "\(fanId)", "\(mode)"]
            if mode == 1, let spd = speed {
                args.append("\(spd)")
            }
            task.arguments = args
            
            do {
                try task.run()
                task.waitUntilExit()
                DispatchQueue.main.async {
                    self.updateStatus()
                }
            } catch {
                print("Set fan failed: \(error)")
            }
        }
    }
    
    func changeFanMode(fanId: Int, mode: Int) {
        if linkedFans {
            for i in 0..<fans.count {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    fans[i].mode = mode
                    if mode == 1 { fans[i].targetSpeed = fans[i].minSpeed }
                }
                let targetSpeed = mode == 1 ? fans[i].minSpeed : nil
                setFanMode(fanId: fans[i].id, mode: mode, speed: targetSpeed)
            }
        } else {
            if let i = fans.firstIndex(where: { $0.id == fanId }) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    fans[i].mode = mode
                    if mode == 1 { fans[i].targetSpeed = fans[i].minSpeed }
                }
                let targetSpeed = mode == 1 ? fans[i].minSpeed : nil
                setFanMode(fanId: fanId, mode: mode, speed: targetSpeed)
            }
        }
    }
    
    func changeFanSpeed(fanId: Int, speed: Int) {
        if linkedFans {
            guard let sourceFan = fans.first(where: { $0.id == fanId }) else { return }
            let range = Double(sourceFan.maxSpeed - sourceFan.minSpeed)
            let pct = range > 0 ? (Double(speed) - Double(sourceFan.minSpeed)) / range : 0.0
            
            for i in 0..<fans.count {
                let fanRange = Double(fans[i].maxSpeed - fans[i].minSpeed)
                let targetSpeed = Double(fans[i].minSpeed) + fanRange * pct
                let boundedSpeed = min(max(Int(targetSpeed), fans[i].minSpeed), fans[i].maxSpeed)
                
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    fans[i].mode = 1
                    fans[i].targetSpeed = boundedSpeed
                }
                setFanMode(fanId: fans[i].id, mode: 1, speed: boundedSpeed)
            }
        } else {
            if let i = fans.firstIndex(where: { $0.id == fanId }) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    fans[i].mode = 1
                    fans[i].targetSpeed = speed
                }
            }
            setFanMode(fanId: fanId, mode: 1, speed: speed)
        }
    }
    
    func resetAll() {
        let path = helperPath
        guard FileManager.default.fileExists(atPath: path) else { return }
        
        for i in 0..<fans.count {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                fans[i].mode = 0
            }
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let task = Process()
            task.executableURL = URL(fileURLWithPath: path)
            task.arguments = ["reset"]
            
            do {
                try task.run()
                task.waitUntilExit()
                DispatchQueue.main.async {
                    self.updateStatus()
                }
            } catch {
                print("Reset failed: \(error)")
            }
        }
    }
    
    func setAllToPercentage(_ pct: Double) {
        let path = helperPath
        guard FileManager.default.fileExists(atPath: path) else { return }
        
        for i in 0..<fans.count {
            let range = Double(fans[i].maxSpeed - fans[i].minSpeed)
            let targetSpeed = Double(fans[i].minSpeed) + range * pct
            let speed = Int(targetSpeed)
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                fans[i].mode = 1
                fans[i].targetSpeed = speed
            }
            setFanMode(fanId: fans[i].id, mode: 1, speed: speed)
        }
    }
    
    func syncAllFans(toSpeed speed: Int) {
        for i in 0..<fans.count {
            if fans[i].mode != 1 {
                changeFanMode(fanId: fans[i].id, mode: 1)
            }
            changeFanSpeed(fanId: fans[i].id, speed: speed)
        }
    }
    
    func saveRules() {
        if let encoded = try? JSONEncoder().encode(rules) {
            UserDefaults.standard.set(encoded, forKey: "triggerRules")
        }
    }
    
    func loadRules() {
        isRulesEngineEnabled = UserDefaults.standard.bool(forKey: "isRulesEngineEnabled")
        if let data = UserDefaults.standard.data(forKey: "triggerRules"),
           let decoded = try? JSONDecoder().decode([TriggerRule].self, from: data) {
            self.rules = decoded
        } else {
            self.rules = [
                TriggerRule(isEnabled: false, sensor: .cpu, thresholdTemp: 75.0, targetSpeedPercent: 80.0),
                TriggerRule(isEnabled: false, sensor: .battery, thresholdTemp: 40.0, targetSpeedPercent: 60.0)
            ]
        }
    }
    
    func evaluateRules() {
        guard isRulesEngineEnabled else { return }
        
        var maxTargetPercent: Double? = nil
        
        for rule in rules where rule.isEnabled {
            guard let currentTemp = getTempFor(sensor: rule.sensor) else { continue }
            
            if rule.ruleType == .threshold {
                if currentTemp >= rule.thresholdTemp {
                    if maxTargetPercent == nil || rule.targetSpeedPercent > maxTargetPercent! {
                        maxTargetPercent = rule.targetSpeedPercent
                    }
                }
            } else if rule.ruleType == .curve {
                if currentTemp >= rule.minTemp {
                    let range = rule.maxTemp - rule.minTemp
                    let tempDiff = currentTemp - rule.minTemp
                    let speedDiff = rule.maxSpeedPercent - rule.minSpeedPercent
                    
                    var calculatedPercent = rule.minSpeedPercent
                    if range > 0 {
                        let ratio = min(max(tempDiff / range, 0.0), 1.0)
                        calculatedPercent = rule.minSpeedPercent + ratio * speedDiff
                    }
                    
                    if maxTargetPercent == nil || calculatedPercent > maxTargetPercent! {
                        maxTargetPercent = calculatedPercent
                    }
                }
            }
        }
        
        if let targetPercent = maxTargetPercent {
            let speedFraction = targetPercent / 100.0
            if !wasRuleApplied || lastSetSpeedPercent != targetPercent {
                setAllToPercentage(speedFraction)
                lastSetSpeedPercent = targetPercent
                wasRuleApplied = true
            }
        } else {
            if wasRuleApplied {
                resetAll()
                wasRuleApplied = false
                lastSetSpeedPercent = nil
            }
        }
    }
    
    func getTempFor(sensor: TriggerRule.SensorType) -> Double? {
        switch sensor {
        case .cpu: return cpuTemp
        case .gpu: return gpuTemp
        case .battery: return batteryTemp
        }
    }
    
    // MARK: - Temperature History Management
    private func recordHistoryIfNeeded() {
        let now = Date()
        
        // Ensure we have at least one valid reading
        guard cpuTemp != nil || gpuTemp != nil || batteryTemp != nil else { return }
        
        if let lastTime = lastHistoryRecordTime {
            // Only record every 30 seconds to avoid bloating
            guard now.timeIntervalSince(lastTime) >= 30.0 else { return }
        }
        
        let record = TempRecord(timestamp: now, cpu: cpuTemp, gpu: gpuTemp, battery: batteryTemp)
        tempHistory.append(record)
        lastHistoryRecordTime = now
        
        pruneHistory()
        saveHistory()
    }
    
    private func pruneHistory() {
        let cutoff = Date().addingTimeInterval(-12 * 3600) // 12 hours ago
        tempHistory.removeAll { $0.timestamp < cutoff }
    }
    
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(tempHistory) {
            UserDefaults.standard.set(encoded, forKey: "tempHistory")
        }
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: "tempHistory"),
           let decoded = try? JSONDecoder().decode([TempRecord].self, from: data) {
            self.tempHistory = decoded
            self.lastHistoryRecordTime = decoded.last?.timestamp
        }
    }
}
