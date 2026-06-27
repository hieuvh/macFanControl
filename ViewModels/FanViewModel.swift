import SwiftUI
import AppKit
import ServiceManagement

// MARK: - View Model
@MainActor
class FanViewModel: ObservableObject {
    @Published var snapshot: FanSnapshot = FanSnapshot(fans: [], cpuTemp: nil, gpuTemp: nil, batteryTemp: nil, timestamp: Date())
    @Published var tempHistory: [TempRecord] = []
    
    public var fans: [FanJSON] {
        get { snapshot.fans }
        set { snapshot.fans = newValue }
    }
    public var cpuTemp: Double? { snapshot.cpuTemp }
    public var gpuTemp: Double? { snapshot.gpuTemp }
    public var batteryTemp: Double? { snapshot.batteryTemp }
    
    private(set) var ringBuffer: [TempRecord] = []
    
    func expand() {
        loadHistory()
    }
    
    func shrink() {
        tempHistory.removeAll(keepingCapacity: false)
    }
    
    private var lastHistoryRecordTime: Date? = nil
    
    @Published var isAuthorized: Bool = false
    @Published var linkedFans: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isPollingActive: Bool = false
    
    private var isFetchingStatus: Bool = false
    
    var isAppWindowVisible: Bool = false {
        didSet {
            updateTimerFrequency()
            if isAppWindowVisible {
                expand()
            } else {
                shrink()
            }
        }
    }
    
    var isMenuBarPopoverVisible: Bool = false {
        didSet {
            updateTimerFrequency()
        }
    }
    
    private var currentInterval: TimeInterval = 1.5
    
    @Published var selectedTab: DashboardTab = .overview
    
    @Published var launchAtStartup: Bool = false {
        didSet {
            guard launchAtStartup != oldValue else { return }
            setLaunchAtStartup(enabled: launchAtStartup)
        }
    }
    
    @Published var rules: [TriggerRule] = [] {
        didSet {
            saveRules()
        }
    }
    @Published var isRulesEngineEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(isRulesEngineEnabled, forKey: "isRulesEngineEnabled")
            updateTimerFrequency()
            if !isRulesEngineEnabled && wasRuleApplied {
                resetAll()
                wasRuleApplied = false
                lastSetSpeedPercent = nil
            }
        }
    }
    private var wasRuleApplied = false
    private var lastSetSpeedPercent: Double? = nil
    
    private var timerSource: DispatchSourceTimer? = nil
    private var windowStateTask: Task<Void, Never>? = nil
    
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
        checkLaunchAtStartupStatus()
        setupNotificationObservers()
        startPolling()
    }
    
    private func setupNotificationObservers() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(handleWindowNotification), name: NSWindow.didBecomeKeyNotification, object: nil)
        nc.addObserver(self, selector: #selector(handleWindowNotification), name: NSWindow.didResignKeyNotification, object: nil)
        nc.addObserver(self, selector: #selector(handleWindowNotification), name: NSWindow.willCloseNotification, object: nil)
        nc.addObserver(self, selector: #selector(handleWindowNotification), name: NSWindow.didMiniaturizeNotification, object: nil)
        nc.addObserver(self, selector: #selector(handleWindowNotification), name: NSWindow.didDeminiaturizeNotification, object: nil)
    }
    
    @objc private func handleWindowNotification() {
        windowStateTask?.cancel()
        windowStateTask = Task { [weak self] in
            // Debounce by 100ms to avoid double-triggers from SwiftUI scene reconstruction
            try? await Task.sleep(nanoseconds: 100_000_000)
            guard !Task.isCancelled else { return }
            self?.updateWindowVisibility()
        }
    }
    
    private func updateWindowVisibility() {
        let isVisible = NSApplication.shared.windows.contains { window in
            guard window.identifier?.rawValue == "main-window" else { return false }
            return window.isVisible && !window.isMiniaturized
        }
        if self.isAppWindowVisible != isVisible {
            self.isAppWindowVisible = isVisible
        }
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
            
            DispatchQueue.main.async { [weak self] in
                self?.isAuthorized = (ownerId == 0 && isSetuid)
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.isAuthorized = false
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
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            var error: NSDictionary? = nil
            appleScript.executeAndReturnError(&error)
            
            DispatchQueue.main.async {
                guard let self = self else { return }
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
        updateTimerFrequency()
        updateStatus()
    }
    
    private func updateTimerFrequency() {
        let newInterval: TimeInterval
        if isAppWindowVisible || isMenuBarPopoverVisible {
            newInterval = 1.5
        } else {
            // Idle polling is 5s to capture fan speed spikes
            newInterval = 5.0
        }
        
        if timerSource == nil || abs(currentInterval - newInterval) > 0.01 {
            currentInterval = newInterval
            timerSource?.cancel()
            
            let source = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
            source.schedule(deadline: .now(), repeating: newInterval, leeway: .milliseconds(100))
            source.setEventHandler { [weak self] in
                self?.updateStatus()
            }
            source.resume()
            timerSource = source
        }
    }
    
    nonisolated private func readSMCSnapshot() -> FanSnapshot? {
        let smc = SMC.shared
        guard let fanCountVal = smc.getValue("FNum") else { return nil }
        
        let fanCount = Int(fanCountVal)
        var fansList: [FanJSON] = []
        
        for i in 0..<fanCount {
            let name: String
            if fanCount == 2 {
                name = i == 0 ? "Left" : "Right"
            } else if fanCount == 1 {
                name = "Fan"
            } else {
                name = "Fan \(i + 1)"
            }
            let current = Int(smc.getValue("F\(i)Ac") ?? 0)
            let minS = Int(smc.getValue("F\(i)Mn") ?? 0)
            let maxS = Int(smc.getValue("F\(i)Mx") ?? 0)
            let target = Int(smc.getValue("F\(i)Tg") ?? 0)
            
            let modeKey = smc.fanModeKey(i)
            let modeVal = Int(smc.getValue(modeKey) ?? 0)
            let mode = FanMode(rawValue: modeVal) ?? .automatic
            
            fansList.append(FanJSON(
                id: i,
                name: name,
                currentSpeed: current,
                minSpeed: minS,
                maxSpeed: maxS,
                targetSpeed: target,
                mode: mode
            ))
        }
        
        let cpuKeys = ["TC0P", "TC0D", "TC0F", "TC1C", "TCAD", "TCBD", "Tp09", "Tp0T", "Tp01", "Tp05", "Tp0D", "Tp0C", "Tp0g", "Tp0h", "Te0S"]
        let gpuKeys = ["TG0D", "TG0H", "TG0P", "Tg05", "Tg0j", "Tg0g", "Tg01", "Tg0c"]
        let batteryKeys = ["TB0T", "TB1T", "TB2T", "Tw0P", "Ts0P", "Th0H"]
        
        func getFirstValidTemp(keys: [String]) -> Double? {
            for key in keys {
                if let val = smc.getValue(key), val > 0 && val < 150 { return val }
            }
            return nil
        }
        
        let currentCpu = getFirstValidTemp(keys: cpuKeys)
        let currentGpu = getFirstValidTemp(keys: gpuKeys)
        let currentBatt = getFirstValidTemp(keys: batteryKeys)
        
        return FanSnapshot(
            fans: fansList,
            cpuTemp: currentCpu,
            gpuTemp: currentGpu,
            batteryTemp: currentBatt,
            timestamp: Date()
        )
    }

    func updateStatus() {
        guard !isFetchingStatus else { return }
        isFetchingStatus = true
        
        DispatchQueue.global(qos: .default).async { [weak self] in
            autoreleasepool {
                guard let self = self else { return }
                let newSnapshot = self.readSMCSnapshot()
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    if let newSnapshot = newSnapshot {
                        self.snapshot = newSnapshot
                        self.isPollingActive = true
                        self.updateRingBuffer()
                        self.evaluateRules()
                        self.recordHistoryIfNeeded()
                    }
                    self.isFetchingStatus = false
                }
            }
        }
    }
    
    func setFanMode(fanId: Int, mode: FanMode, speed: Int? = nil) {
        let path = helperPath
        guard FileManager.default.fileExists(atPath: path) else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let task = Process()
            task.executableURL = URL(fileURLWithPath: path)
            
            var args = ["set", "\(fanId)", "\(mode.rawValue)"]
            if mode == .forced, let spd = speed {
                args.append("\(spd)")
            }
            task.arguments = args
            
            do {
                try task.run()
                task.waitUntilExit()
            } catch {
                print("Set fan failed: \(error)")
            }
        }
    }
    
    func changeFanMode(fanId: Int, mode: FanMode) {
        if linkedFans {
            for i in 0..<fans.count {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    fans[i].mode = mode
                    if mode == .forced { fans[i].targetSpeed = fans[i].minSpeed }
                }
                let targetSpeed = mode == .forced ? fans[i].minSpeed : nil
                setFanMode(fanId: fans[i].id, mode: mode, speed: targetSpeed)
            }
        } else {
            if let i = fans.firstIndex(where: { $0.id == fanId }) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    fans[i].mode = mode
                    if mode == .forced { fans[i].targetSpeed = fans[i].minSpeed }
                }
                let targetSpeed = mode == .forced ? fans[i].minSpeed : nil
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
                    fans[i].mode = .forced
                    fans[i].targetSpeed = boundedSpeed
                }
                setFanMode(fanId: fans[i].id, mode: .forced, speed: boundedSpeed)
            }
        } else {
            if let i = fans.firstIndex(where: { $0.id == fanId }) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    fans[i].mode = .forced
                    fans[i].targetSpeed = speed
                }
            }
            setFanMode(fanId: fanId, mode: .forced, speed: speed)
        }
    }
    
    func resetAll() {
        let path = helperPath
        guard FileManager.default.fileExists(atPath: path) else { return }
        
        for i in 0..<fans.count {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                fans[i].mode = .automatic
            }
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let task = Process()
            task.executableURL = URL(fileURLWithPath: path)
            task.arguments = ["reset"]
            
            do {
                try task.run()
                task.waitUntilExit()
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
                fans[i].mode = .forced
                fans[i].targetSpeed = speed
            }
            setFanMode(fanId: fans[i].id, mode: .forced, speed: speed)
        }
    }
    
    func syncAllFans(toSpeed speed: Int) {
        for i in 0..<fans.count {
            if fans[i].mode != .forced {
                changeFanMode(fanId: fans[i].id, mode: .forced)
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
    private func updateRingBuffer() {
        let now = Date()
        guard snapshot.cpuTemp != nil || snapshot.gpuTemp != nil || snapshot.batteryTemp != nil else { return }
        
        let record = TempRecord(timestamp: now, cpu: snapshot.cpuTemp, gpu: snapshot.gpuTemp, battery: snapshot.batteryTemp)
        ringBuffer.append(record)
        if ringBuffer.count > 10 {
            ringBuffer.removeFirst()
        }
    }
    
    private func recordHistoryIfNeeded() {
        guard isAppWindowVisible else { return }
        let now = Date()
        
        // Ensure we have at least one valid reading
        guard snapshot.cpuTemp != nil || snapshot.gpuTemp != nil || snapshot.batteryTemp != nil else { return }
        
        if let lastTime = lastHistoryRecordTime {
            // Only record every 30 seconds to avoid bloating
            guard now.timeIntervalSince(lastTime) >= 30.0 else { return }
        }
        
        let record = TempRecord(timestamp: now, cpu: snapshot.cpuTemp, gpu: snapshot.gpuTemp, battery: snapshot.batteryTemp)
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
    
    private func checkLaunchAtStartupStatus() {
        if #available(macOS 13.0, *) {
            let status = SMAppService.mainApp.status
            self.launchAtStartup = (status == .enabled)
        }
    }
    
    private func setLaunchAtStartup(enabled: Bool) {
        if #available(macOS 13.0, *) {
            let service = SMAppService.mainApp
            let currentlyEnabled = (service.status == .enabled)
            guard enabled != currentlyEnabled else { return }
            
            if enabled {
                do {
                    try service.register()
                } catch {
                    print("Failed to register SMAppService: \(error)")
                    DispatchQueue.main.async {
                        self.launchAtStartup = false
                    }
                }
            } else {
                do {
                    try service.unregister()
                } catch {
                    print("Failed to unregister SMAppService: \(error)")
                    DispatchQueue.main.async {
                        self.launchAtStartup = true
                    }
                }
            }
        }
    }
    
    deinit {
        timerSource?.cancel()
        timerSource = nil
        NotificationCenter.default.removeObserver(self)
    }
}
