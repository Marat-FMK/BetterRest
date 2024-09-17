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
    
//    @State private var alertTitle = ""
//    @State private var alertMessage = "kj"
//    @State private var showingAlert = false
    
     private var result: String {
        calculateBedTime()
    }
    
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
                    Stepper("\(sleepAmount.formatted()) hours",value: $sleepAmount,in: 4...10, step: 0.5)
                }
                Section("Daily coffee  intake"){
                    
                    Picker("Insert cus count", selection: $cofeeAmount){
                        ForEach(0..<9) {
                            Text("\($0)")
                        }
                    }
                }
               
            }
            VStack(alignment: .center) {
                Text("Bed time")
                    .foregroundStyle(.purple)
                Text(result)
                    .font(.largeTitle)
                    .foregroundStyle(.red)
                
            }
            Spacer()
            Spacer()
            Spacer()
            .navigationTitle("BetterRest")
//            .toolbar {
//                Button("Calculate", action: {})
//            }
//            .alert(alertTitle, isPresented: $showingAlert) {
//                Button("OK") {}
//            } message: {
//                Text(alertMessage)
//            }
        }
        
    }
    
    func calculateBedTime() -> String {
       
        do{
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUP)
            let hour = (components.hour ?? 0 ) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(cofeeAmount))
            
            let sleepTime = wakeUP - prediction.actualSleep // current time for go to bed
            return sleepTime.formatted(date: .omitted, time: .shortened)
//            alertTitle = "Your ideal bed time is..."
//            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened) 
            
           // // .ommited - "опустить" данные даты(в данном случаа)
            
        } catch {
            return  "Error"
        }
    }
}

#Preview {
    ContentView()
}
