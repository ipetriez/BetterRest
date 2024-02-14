//
//  ContentView.swift
//  BetterRest
//
//  Created by Sergey Petrosyan on 14.02.24.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = Date.now
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("When do you want to wake up?")
                    .font(.headline)
                
                DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                
                Text("Desired amount of sleep")
                    .font(.headline)
                
                Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                    .padding()
                
                Text("Daily coffee intake")
                    .font(.headline)
                
                Stepper("\(coffeeAmount.formatted()) cup(s)", value: $coffeeAmount, in: 1...20)
                    .padding()
            }
            .navigationTitle("BetterRest")
            .toolbar {
                Button("Calculate", action: calculateSleepTime)
            }
            .alert(alertTitle, isPresented: $showAlert) {
                Button("Okay") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    func calculateSleepTime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hoursInSeconds = (components.hour ?? 0) * 60 * 60
            let minutesInSeconds = (components.minute ?? 0) * 60
            let prediction = try model.prediction(wake: Int64(hoursInSeconds + minutesInSeconds), estimatedSleep: sleepAmount, coffee: Int64(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bedtime is:"
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
            print("DEBUG: Failed to create SleepCalculator from MLModelConfiguration with error: \(error)")
        }
        showAlert = true
    }
}

#Preview {
    ContentView()
}
