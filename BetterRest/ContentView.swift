//
//  ContentView.swift
//  BetterRest
//
//  Created by Marat Fakhrizhanov on 16.09.2024.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUP = wakeUpTime
    @State private var sleepAmount = 8.0
    @State private var cofeeAmount = 0
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var wakeUpTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
        
    }
    
    var body: some View {
        NavigationStack{
            Form {
                Section("When do you want to wake up? "){
                    DatePicker("Please, enter a time", selection: $wakeUP, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                Section("Desired amount of sleep"){
                    Stepper("\(sleepAmount.formatted()) hours",value: $sleepAmount,in: 4...12, step: 0.5)
                }
                Section("Daily coffee  intake"){
                    Stepper("^[\(cofeeAmount) cup](inflect: true)",value: $cofeeAmount, in: 1...9, step: 1)
                    
//                    Picker("Insert cus count", selection: $cofeeAmount){
//                        ForEach(0..<9) {
//                            Text("\($0)")
//                        }
                    }
                }
                Section("Bed time"){
                    Text("23:30")
                }
            }
            .navigationTitle("BetterRest")
            .toolbar {
                Button("Calculate", action: calculateBedTime)
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
        }
        
    }
    
    func calculateBedTime() {
        do{
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUP)
            let hour = (components.hour ?? 0 ) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(cofeeAmount))
            
            let sleepTime = wakeUP - prediction.actualSleep // current time for go to bed
            alertTitle = "Your ideal bed time is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened) // .ommited - "опустить данные даты(в данном случаа)"
            
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, thee was a problem calculation."
        }
        showingAlert = true
    }
}

#Preview {
    ContentView()
}
