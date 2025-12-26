//
//  DurationPicker.swift
//  Air
//
//  Created by Ihar Katkavets on 10/11/2025.
//

import SwiftUI

extension DurationSeconds {
    func secondsFor(minutes: Int) -> DurationSeconds {
        return Double(minutes)*60
    }
    
    func secondsFor(hours: Int) -> DurationSeconds {
        return Double(hours)*60*60
    }
    
    func secondsFor(days: Int) -> DurationSeconds {
        return Double(days)*24*60*60
    }
    
    func minutesFor(seconds: Int) -> DurationSeconds {
        return Double(seconds) / 60
    }
    
    func days(value: Int) -> DurationSeconds     {
        return Double(value)*24*60*60
    }
}

struct DurationPicker: View {
    struct Configuration {
        let numbers: CountableClosedRange<Int>
        let units: [String]
    }
    
    @State private var value: Int
    @State private var unit: String
    @Binding var duration: DurationSeconds
    let configuration: Configuration
    
    init(duration: Binding<DurationSeconds>, configuration: Configuration) {
        self._duration = duration
        self.configuration = configuration
        self.value = configuration.numbers.lowerBound
        self.unit = configuration.units.first ?? ""
    }

    var body: some View {
        HStack(spacing: 0) {
            Picker("Value", selection: $value) {
                ForEach(configuration.numbers, id: \.self) { number in
                    Text("\(number)").tag(number)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)

            Picker("Unit", selection: $unit) {
                ForEach(configuration.units, id: \.self) { u in
                    Text(u).tag(u)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)
        }
        .frame(height: 160)
        .onChange(of: value) { oldValue, newValue in
            DurationParser.parse("\(value)\(unit)").map { duration = $0 }
        }
        .onChange(of: unit) { oldValue, newValue in
            DurationParser.parse("\(value)\(unit)").map { duration = $0 }
        }
        .onAppear {
        }
    }
}

#Preview {
    VStack {
        DurationPicker(duration: .constant(0), configuration: .init(numbers: 0...10, units: ["s","m","h","d"]))
    }
}
