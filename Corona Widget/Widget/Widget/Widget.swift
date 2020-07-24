//
//  Widget.swift
//  Widget
//
//  Created by Aaryan Kothari on 22/07/20.
//

import WidgetKit
import SwiftUI
import Intents
import MapKit

struct CountryModel : TimelineEntry {
    var date: Date
    var total : Double
    var active : Double
    var deaths : Double
    var recovered : Double
    var name : String
    var code : String
    var emoji : String
    var global : Global
}

struct GlobalData {
    var total : Double = 0.0
    var newTotal : Double = 0.0
    var active : Double = 0.0
    var newActive : Double = 0.0
    var deaths : Double = 0.0
    var newDeaths : Double = 0.0
    var recovered : Double = 0.0
    var newRecovered : Double = 0.0
}

struct DataProvider : TimelineProvider {
    
    @ObservedObject var coronaStore = SessionStore()
    
    func timeline(with context: Context, completion: @escaping (Timeline<Corona>) -> ()) {
        
        var entries: [Corona] = []
        
        let refresh = Calendar.current.date(byAdding: .second, value: 20, to: Date()) ?? Date()
        coronaStore.fetch{ corona in
            entries.append(corona)
            let timeline = Timeline(entries: entries, policy: .after(refresh))
            
            print("update")
            
            completion(timeline)
        }
    }
    
    func getCountryDetails(_ corona : Corona)->Countries{
        let country = CurrentCountry.county.rawValue
        let countries = corona.Countries
        let mycountry = countries.filter { $0.CountryCode == country}
        return mycountry.first!
    }
    
    func snapshot(with context: Context, completion: @escaping (Corona) -> ()) {
        coronaStore.fetch{ corona in
            
            completion(corona)
        }
    }
}


struct WidgetView : View{
    var data : DataProvider.Entry
    @Environment(\.widgetFamily) private var family
    var body : some View {
        Group {
            switch family {
            case .systemSmall:
                smallWidget(data: CountryData(data))
            case .systemMedium:
                mediumWidget(data: CountryData(data))
            case .systemLarge:
                largeWidget(data: data.Global, countries: data.Countries)
            @unknown default:
                smallWidget(data: CountryData(data))
            }
        }
    }
}

struct largeWidget : View {
    var data : Global
    var countries : Countries
    var body : some View {
        VStack{
            HStack{
                Image("global")
                    .resizable(capInsets: EdgeInsets(), resizingMode: .stretch)
                    .aspectRatio(contentMode: .fit)
                    .padding(.all,20)
            }
            VStack{
                countStack(total: data.TotalConfirmed, new: data.NewConfirmed, color: .coronapink, name: "confirmed")
                countStack(total: data.TotalRecovered, new: data.NewRecovered, color: .coronagreen, name: "recovered")
                countStack(total: data.TotalDeaths, new: data.NewDeaths, color: .coronagrey, name: "deaths")
                countStack(total: totalActive(), new: 0.0, color: .coronayellow, name: "active",isActive:true)
            }
            Spacer()
        }
    }
    
    func totalActive()-> Double{
        return data.TotalConfirmed - data.TotalDeaths - data.TotalRecovered
    }
    
    func topTen()->[String]{
     return []
    }
}

struct countStack : View {
    let total : Double
    let new : Double
    let color : Color
    let name : String
    var isActive = false
    var body: some View {
        HStack{
            Text("Total \(name) : \(Int(total))")
            Text(isActive ? "" : " + \(Int(new))").foregroundColor(color)
        }
    }
}

@main
struct Config : Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Widget", provider: DataProvider(), placeholder: Placeholder()) { data in
            WidgetView(data: data)
        }
        .supportedFamilies([.systemSmall,.systemMedium,.systemLarge])
        .description(Text("Current Time widget"))
    }
}


//struct Widget_Previews: PreviewProvider {
//    static var previews: some View {
//        WidgetView(data: CountryModel(date: Date(), total: 100, active: 30, deaths: 20, recovered: 50,name: "India", code: "IN",emoji: "🇮🇳", global: Global()))
//            .previewContext(WidgetPreviewContext(family: .systemLarge))
//    }
//}

extension CountryData {
    init(_ data : CountryModel){
        self.date =  Date()
        self.total = data.total
        self.active = data.active
        self.deaths = data.deaths
        self.recovered = data.recovered
        self.name = data.name
        self.code = data.code
        self.emoji = data.emoji
    }
}