//
//  NotificationBanner.swift
//  Hanmu
//
//  Created by orangeboy on 2021/6/19.
//

import SwiftUI

class BannerService {
    private static var instance = BannerService()
    
    var contentView: ContentView?
    
    private init(){}
    
    public static func getInstance() -> BannerService {
        return .instance
    }
    
    public func showBanner(title: String, content: String, type: Banner.BannerType) {
        let bannerData = Banner.BannerData(title: title, detail: content, type: type)
        contentView?.bannerData = bannerData
        contentView?.isShowBanner = true
    }
}

struct Banner: View {
    struct BannerData {
        var title: String
        var detail: String
        var type: BannerType
    }
    
    enum BannerType {
        case Info
        case Warning
        case Success
        case Error

        var tintColor: Color {
            switch self {
            case .Info:
                return Color(red: 67/255, green: 154/255, blue: 215/255)
            case .Success:
                return Color.green
            case .Warning:
                return Color.yellow
            case .Error:
                return Color.red
            }
        }
    }
    
    @Binding var data:BannerData
    @Binding var isShow: Bool
    
    var body: some View {
        if isShow {
            HStack {
                VStack(alignment: .leading) {
                    Text(data.title).bold()
                    if data.detail != "" {
                        Text(data.detail)
                            .font(Font.system(size: 15, weight: Font.Weight.light, design: Font.Design.default))
                    }
                }
                Spacer()
            }
            .foregroundColor(Color.white)
            .padding(8)
            .background(data.type.tintColor)
            .cornerRadius(8)
            .animation(.easeInOut)
            .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
            .onTapGesture {
                withAnimation {
                    self.isShow = false
                }
                
            }
            .onAppear(perform: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        self.isShow = false
                    }
                }
            })
            
        }


    }
}

struct NotificationBanner_Previews: PreviewProvider {
    static var previews: some View {
        Banner(data: .constant(Banner.BannerData(title: "Default Title", detail: "This is the detail text for the action you just did or whatever blah blah blah blah blah", type: .Info)), isShow: .constant(true))
    }
}
