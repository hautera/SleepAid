//
//  ContentView.swift
//  SleepAid
//
//  Created by Austin Hauter on 5/19/21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var timerManager = TimerManager()
    @State var timeSelected: NapTimes = .short
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Sleep Timer")
                    .font(.title)
                    .padding()
                
                if timerManager.state != .initial {
                    Text("\(self.timerManager.minutesRemainingAsText())")
                        .font(.system(size: 100))
                        .padding()
                }
                
                Image(systemName: self.timerManager.state.pictureName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .onTapGesture(perform: {
                        timerManager.buttonPress(userSelection:
                                                    self.timeSelected)
                    })
                
                //reset button
                if self.timerManager.state == .paused {
                    Button(action: {
                        self.timerManager.reset()
                    }) {
                        Text("Reset")
                            .font(.system(size: 20))
                            .padding()
                            .foregroundColor(.blue)
                        
                    }
                }
                
                //select the run time if the timer is not being used
                if self.timerManager.state == .initial {
                    Picker("Length", selection: $timeSelected, content: {
                        ForEach(NapTimes.allCases, id: \.self) { time in
                            Text("\(time.readable)")
                        }
                    })
                }
                Spacer()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
