//
//  HistoryListItem.swift
//  Hanmu
//
//  Created by orangeboy on 2021/3/13.
//

import SwiftUI



struct HistoryListItem: View {
    
    @State var outOffset: CGFloat = 0
    @State var isSwiped: Bool = false
    
    
    
    var body: some View {
        ZStack{
            
            LinearGradient(gradient: Gradient(colors: [Color.blue]), startPoint: /*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/)
            
            HStack{
                Spacer()
                Button(action: {}, label: {
                    Text("Button2")
                }).padding()
            }.foregroundColor(.white)
            
            HStack(spacing: 15){
                VStack(alignment: .leading){
                    Text("108座位")
                        .font(.headline)
                    Text("2021-3-12 17:35")
                }.padding()
                
                Spacer()
                Text("已结束使用").padding()
            }
            .frame(height: 70, alignment: .center)
            .background(Color.white)
            .contentShape(Rectangle())
            .gesture(
                DragGesture().onChanged(onChanged(value:)).onEnded(onEnd(value:))
            )
            .offset(x: outOffset)
        }.frame(height: 70)
        

        
        
        
    }
    
    func onChanged(value: DragGesture.Value){
        if value.translation.width < 0{
            if self.isSwiped {
                outOffset = value.translation.width - 90
            }
            else{
                outOffset = value.translation.width
            }
        }
        
          
      }
      
      func onEnd(value: DragGesture.Value){
        withAnimation(.easeOut) {
                    
                    if value.translation.width < 0 {
                        
//                        if -value.translation.width > UIScreen.main.bounds.width / 2 {
//                            outOffset = -1000
//
//                        }
                        if -outOffset > 50 {
                            isSwiped = true
                            outOffset = -90
                        } else {
                            isSwiped = false
                            outOffset = 0
                        }
                        
                    }
                    else {
                        isSwiped = false
                        outOffset = 0
                    }
                }
        
      }
      
      
}

struct HistoryListItem_Previews: PreviewProvider {
    static var previews: some View {
        HistoryListItem()
    }
}
