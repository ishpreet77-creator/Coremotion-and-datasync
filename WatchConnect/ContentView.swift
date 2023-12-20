//
//  ContentView.swift
//  WatchConnect
//
//  Created by John on 19/12/23.
//


import SwiftUI
import CoreMotion
import HealthKit
import WatchConnectivity

class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    @Published var acceleration: (x: Double, y: Double, z: Double) = (0, 0, 0)
    @Published var attitude: (pitch: Double, roll: Double, yaw: Double) = (0, 0, 0)
    @Published var CsvData: String? = ""
    
    init() {
        startMotionUpdates()
    }
    
    private func startMotionUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.startDeviceMotionUpdates(to: .main) { data, error in
                if let attitude = data?.attitude, let gravity = data?.gravity {
                    DispatchQueue.main.async {
                        self.attitude = (attitude.pitch, attitude.roll, attitude.yaw)
                        self.acceleration = (gravity.x, gravity.y, gravity.z)
                    }
                    
                }
            }
        }
    }
    
    func generateCSVData() -> String {
        let timestamp = Date().formattedString()
        let dataDictionary: [String: Any] = [
            "Timestamp": timestamp,
            "AccelerationX": acceleration.x,
            "AccelerationY": acceleration.y,
            "AccelerationZ": acceleration.z,
            "AttitudePitch": attitude.pitch,
            "AttitudeRoll": attitude.roll,
            "AttitudeYaw": attitude.yaw
        ]

        return convertToJSONString(dictionary: dataDictionary)
    }

    private func convertToJSONString(dictionary: [String: Any]) -> String {
           do {
               let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
               if let jsonString = String(data: jsonData, encoding: .utf8) {
                   self.CsvData = "CsvData ===> \(jsonString)"
                   return jsonString
               }
           } catch {
               print("Error converting dictionary to JSON string: \(error.localizedDescription)")
           }

           return ""
       }
}


class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    @Published var heartRate: Double = 0.0
    @Published var stepCount: Double = 0.0

    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }

        let typesToRead: Set<HKObjectType> = [HKObjectType.quantityType(forIdentifier: .stepCount)!, HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!, HKObjectType.quantityType(forIdentifier: .heartRate)!]
        let typesToWrite: Set<HKSampleType> = []

        healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead) { success, error in
            if success {
                print("HealthKit authorization granted.")
                self.startHeartRateUpdates()
            } else {
                print("HealthKit authorization denied.")
            }
        }
    }
     func startStepCountUpdates() {
           let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
           let calendar = Calendar.current
           let now = Date()
           guard let startDate = calendar.date(byAdding: .day, value: -7, to: now) else { return }
           
           let anchorDate = calendar.startOfDay(for: startDate)
           let dailyComponents = DateComponents(day: 1)
           let predicate = HKQuery.predicateForSamples(withStart: anchorDate, end: now, options: .strictStartDate)
           
           let query = HKStatisticsCollectionQuery(quantityType: stepCountType, quantitySamplePredicate: predicate, options: .cumulativeSum, anchorDate: anchorDate, intervalComponents: dailyComponents)
           
           query.initialResultsHandler = { query, statisticsCollection, error in
               self.processStepCountResults(statisticsCollection)
           }
           
           healthStore.execute(query)
       }

       private func processStepCountResults(_ statisticsCollection: HKStatisticsCollection?) {
           guard let statisticsCollection = statisticsCollection else { return }

           let now = Date()
           let calendar = Calendar.current
           let endDate = calendar.startOfDay(for: now)
           guard let startDate = calendar.date(byAdding: .day, value: -6, to: endDate) else { return }

           statisticsCollection.enumerateStatistics(from: startDate, to: endDate) { statistics, stop in
               if let sum = statistics.sumQuantity() {
                   let stepCount = sum.doubleValue(for: .count())
                   self.stepCount = stepCount
               }
           }
       }
       

    private func startHeartRateUpdates() {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let query = HKObserverQuery(sampleType: heartRateType, predicate: nil) { _, _, error in
            if let error = error {
                print("Error observing heart rate changes: \(error.localizedDescription)")
                return
            }
            self.fetchHeartRate()
        }

        healthStore.execute(query)
    }

    private func fetchHeartRate() {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: nil) { _, samples, error in
            if let quantitySample = samples?.first as? HKQuantitySample {
                self.heartRate = quantitySample.quantity.doubleValue(for: .init(from: "count/min"))
            }
        }

        healthStore.execute(query)
    }
}


struct ContentView: View {
    @ObservedObject private var motionManager = MotionManager()
    @ObservedObject private var healthKitManager = HealthKitManager()
    
    @State private var watchActivacted = false

    var body: some View {
        VStack {
            Text("Acceleration: \(motionManager.acceleration.x), \(motionManager.acceleration.y), \(motionManager.acceleration.z)")
            Text("Attitude: \(motionManager.attitude.pitch), \(motionManager.attitude.roll), \(motionManager.attitude.yaw)")
            Text("Heart Rate: \(healthKitManager.heartRate)")
            
            Text("Step Count: \(healthKitManager.stepCount)")

            // Button to download data in a CSV file
            Button("Download CSV") {
                downloadCSV()
            }
            .padding()
            Button("Request HealthKit Authorization") {
                           healthKitManager.requestAuthorization()
                       }

            // Display received message from Watch

            Text("\(motionManager.CsvData ?? "")")

        }
        .onAppear {


        }
    }

    private func downloadCSV() {
        let csvData = motionManager.generateCSVData()

        // Save CSV data to a file
        if let fileURL = saveCSVToFile(csvData: csvData) {
            print("CSV file saved at: \(fileURL)")
            if let csvContent = readCSVFromFile(at: fileURL) {
                   // Process the CSV content
                   print("CSV Content:\n\(csvContent)")
               } else {
                   print("Failed to read CSV file.")
               }
        } else {
            print("Error saving CSV file.")
        }
    }
    func readCSVFromFile(at url: URL) -> String? {
        do {
            // Read the content of the file as a string
            let csvData = try String(contentsOf: url, encoding: .utf8)
           
            return csvData
        } catch {
            // Handle the error if reading fails
            print("Error reading CSV file: \(error.localizedDescription)")
            return nil
        }
    }

    private func saveCSVToFile(csvData: String) -> URL? {
        let fileName = "motion_data.csv"

        // Get the caches directory
        guard let cachesDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        let fileURL = cachesDirectory.appendingPathComponent(fileName)

        do {
            try csvData.write(to: fileURL, atomically: true, encoding: .utf8)
        print("Folder Path: \(fileURL.deletingLastPathComponent().path)")

            return fileURL
        } catch {
            print("Error writing CSV data to file: \(error.localizedDescription)")
            return nil
        }
    }
}

extension Date {
    func formattedString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: self)
    }
}




#Preview {
    ContentView()
}
