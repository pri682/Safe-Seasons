//
//  EmbeddedData.swift
//  SafeSeasons
//
//  SRP: offline data source only. Repositories depend on this, not persistence.
//

import Foundation

struct SeasonalReminder: Identifiable {
    let id = UUID()
    let season: String
    let tip: String
}

struct WEAEducationContent {
    let whatIsWEA: (title: String, content: String)
    let typesOfAlerts: (title: String, content: String)
    let whatToDo: (title: String, content: String)
    let limitations: (title: String, content: String)
}

enum EmbeddedData {
    private static func _state(_ name: String, _ abbr: String, _ level: RiskLevel, _ hazards: [String], _ seasonal: [SeasonalRisk]) -> StateRisk {
        StateRisk(name: name, abbreviation: abbr, riskLevel: level, topHazards: hazards, seasonalRisks: seasonal)
    }

    private static func _minimal(_ name: String, _ abbr: String) -> StateRisk {
        _state(name, abbr, .moderate, ["Various"], [])
    }

    static let states: [StateRisk] = [
        _state("Alabama", "AL", .moderate, ["Tornadoes", "Hurricanes", "Flooding", "Severe Storms"], []),
        _minimal("Alaska", "AK"),
        _state("Arizona", "AZ", .high, ["Wildfires", "Extreme Heat", "Drought", "Monsoon Flooding"], []),
        _state("Arkansas", "AR", .moderate, ["Tornadoes", "Flooding", "Severe Storms", "Ice Storms"], []),
        _state("California", "CA", .veryHigh, ["Wildfires", "Earthquakes", "Drought", "Landslides"], [
            SeasonalRisk(season: "Fire", months: ["June", "July", "August", "September", "October"], hazards: ["Wildfires", "Heat"], riskLevel: .veryHigh),
            SeasonalRisk(season: "Winter", months: ["November", "December", "January", "February"], hazards: ["Mudslides", "Floods"], riskLevel: .high),
            SeasonalRisk(season: "Earthquake", months: ["All Year"], hazards: ["Earthquakes"], riskLevel: .veryHigh)
        ]),
        _state("Colorado", "CO", .moderate, ["Wildfires", "Flooding", "Blizzards", "Avalanches"], [
            SeasonalRisk(season: "Fire", months: ["June", "July", "August"], hazards: ["Wildfires"], riskLevel: .high),
            SeasonalRisk(season: "Winter", months: ["November", "December", "January", "February", "March"], hazards: ["Blizzards", "Avalanches"], riskLevel: .high)
        ]),
        _minimal("Connecticut", "CT"),
        _minimal("Delaware", "DE"),
        _state("Florida", "FL", .veryHigh, ["Hurricanes", "Flooding", "Tornadoes", "Sinkholes"], [
            SeasonalRisk(season: "Hurricane", months: ["June", "July", "August", "September", "October", "November"], hazards: ["Hurricanes", "Storm Surge"], riskLevel: .veryHigh),
            SeasonalRisk(season: "Summer", months: ["May", "June", "July", "August"], hazards: ["Thunderstorms", "Lightning", "Flooding"], riskLevel: .high)
        ]),
        _state("Georgia", "GA", .moderate, ["Hurricanes", "Tornadoes", "Flooding", "Severe Storms"], []),
        _minimal("Hawaii", "HI"),
        _minimal("Idaho", "ID"),
        _state("Illinois", "IL", .moderate, ["Tornadoes", "Flooding", "Severe Storms", "Winter Storms"], []),
        _state("Indiana", "IN", .moderate, ["Tornadoes", "Flooding", "Severe Storms", "Winter Storms"], []),
        _state("Iowa", "IA", .moderate, ["Tornadoes", "Flooding", "Severe Storms", "Winter Storms"], []),
        _state("Kansas", "KS", .high, ["Tornadoes", "Severe Storms", "Ice Storms", "Wildfires"], []),
        _state("Kentucky", "KY", .moderate, ["Tornadoes", "Flooding", "Severe Storms", "Ice Storms"], []),
        _state("Louisiana", "LA", .veryHigh, ["Hurricanes", "Flooding", "Tornadoes"], [
            SeasonalRisk(season: "Hurricane", months: ["June", "July", "August", "September", "October"], hazards: ["Hurricanes", "Storm Surge"], riskLevel: .veryHigh)
        ]),
        _minimal("Maine", "ME"),
        _minimal("Maryland", "MD"),
        _minimal("Massachusetts", "MA"),
        _state("Michigan", "MI", .moderate, ["Winter Storms", "Flooding", "Severe Storms"], []),
        _state("Minnesota", "MN", .moderate, ["Winter Storms", "Blizzards", "Flooding"], []),
        _state("Mississippi", "MS", .high, ["Hurricanes", "Tornadoes", "Flooding", "Severe Storms"], []),
        _state("Missouri", "MO", .moderate, ["Tornadoes", "Flooding", "Severe Storms", "Ice Storms"], []),
        _state("Montana", "MT", .moderate, ["Wildfires", "Winter Storms", "Flooding"], []),
        _state("Nebraska", "NE", .moderate, ["Tornadoes", "Severe Storms", "Winter Storms", "Flooding"], []),
        _state("Nevada", "NV", .moderate, ["Wildfires", "Extreme Heat", "Drought"], []),
        _minimal("New Hampshire", "NH"),
        _minimal("New Jersey", "NJ"),
        _state("New Mexico", "NM", .moderate, ["Wildfires", "Extreme Heat", "Drought"], []),
        _minimal("New York", "NY"),
        _state("North Carolina", "NC", .high, ["Hurricanes", "Tornadoes", "Flooding", "Severe Storms"], []),
        _state("North Dakota", "ND", .moderate, ["Winter Storms", "Blizzards", "Flooding"], []),
        _state("Ohio", "OH", .moderate, ["Tornadoes", "Flooding", "Severe Storms", "Winter Storms"], []),
        _state("Oklahoma", "OK", .high, ["Tornadoes", "Severe Storms", "Ice Storms", "Wildfires"], [
            SeasonalRisk(season: "Tornado", months: ["April", "May", "June"], hazards: ["Tornadoes", "Hail"], riskLevel: .veryHigh),
            SeasonalRisk(season: "Winter", months: ["December", "January", "February"], hazards: ["Ice Storms", "Blizzards"], riskLevel: .moderate)
        ]),
        _state("Oregon", "OR", .moderate, ["Wildfires", "Earthquakes", "Flooding"], []),
        _minimal("Pennsylvania", "PA"),
        _minimal("Rhode Island", "RI"),
        _state("South Carolina", "SC", .high, ["Hurricanes", "Tornadoes", "Flooding", "Severe Storms"], []),
        _state("South Dakota", "SD", .moderate, ["Winter Storms", "Blizzards", "Flooding", "Tornadoes"], []),
        _state("Tennessee", "TN", .moderate, ["Tornadoes", "Flooding", "Severe Storms", "Ice Storms"], []),
        _state("Texas", "TX", .high, ["Hurricanes", "Tornadoes", "Flooding", "Heat"], [
            SeasonalRisk(season: "Hurricane", months: ["June", "July", "August", "September", "October"], hazards: ["Hurricanes", "Tropical Storms"], riskLevel: .high),
            SeasonalRisk(season: "Tornado", months: ["March", "April", "May"], hazards: ["Tornadoes", "Severe Storms"], riskLevel: .high),
            SeasonalRisk(season: "Summer", months: ["June", "July", "August"], hazards: ["Extreme Heat", "Drought"], riskLevel: .high)
        ]),
        _state("Utah", "UT", .moderate, ["Wildfires", "Winter Storms", "Flooding"], []),
        _minimal("Vermont", "VT"),
        _minimal("Virginia", "VA"),
        _state("Washington", "WA", .moderate, ["Earthquakes", "Wildfires", "Flooding"], []),
        _minimal("West Virginia", "WV"),
        _state("Wisconsin", "WI", .moderate, ["Winter Storms", "Blizzards", "Flooding", "Tornadoes"], []),
        _state("Wyoming", "WY", .moderate, ["Winter Storms", "Wildfires", "Flooding"], [])
    ]

    // MARK: - Checklist Items (with stable UUIDs for persistence)
    
    /// Stable UUIDs for checklist items to ensure persistence across app launches.
    /// These are hardcoded so that UserDefaults keys remain consistent.
    private static let checklistIDs: [UUID] = {
        let strings = [
            "550e8400-e29b-41d4-a716-446655440001", // water
            "550e8400-e29b-41d4-a716-446655440002", // food
            "550e8400-e29b-41d4-a716-446655440003", // flashlight
            "550e8400-e29b-41d4-a716-446655440004", // firstaid
            "550e8400-e29b-41d4-a716-446655440005", // meds
            "550e8400-e29b-41d4-a716-446655440006", // radio
            "550e8400-e29b-41d4-a716-446655440007", // documents
            "550e8400-e29b-41d4-a716-446655440008", // cash
            "550e8400-e29b-41d4-a716-446655440009", // whistle
            "550e8400-e29b-41d4-a716-446655440010", // dust-masks
            "550e8400-e29b-41d4-a716-446655440011", // moist-towelettes
            "550e8400-e29b-41d4-a716-446655440012", // wrench
            "550e8400-e29b-41d4-a716-446655440013", // can-opener
            "550e8400-e29b-41d4-a716-446655440014", // phone-charger
            "550e8400-e29b-41d4-a716-446655440015", // contact-list
            "550e8400-e29b-41d4-a716-446655440016", // pet-supplies
            "550e8400-e29b-41d4-a716-446655440017"  // blankets
        ]
        return strings.compactMap { UUID(uuidString: $0) }
    }()

    static let checklistItems: [ChecklistItem] = [
        ChecklistItem(id: checklistIDs[0], name: "Water (1 gallon per person per day, 3+ days)", category: .basicSupplies, priority: .critical),
        ChecklistItem(id: checklistIDs[1], name: "Non-perishable food (3+ days)", category: .basicSupplies, priority: .critical),
        ChecklistItem(id: checklistIDs[2], name: "Flashlight with extra batteries", category: .basicSupplies, priority: .critical),
        ChecklistItem(id: checklistIDs[3], name: "First aid kit", category: .medical, priority: .critical),
        ChecklistItem(id: checklistIDs[4], name: "Prescription medications (7-day supply)", category: .medical, priority: .critical),
        ChecklistItem(id: checklistIDs[5], name: "Battery-powered or hand-crank radio", category: .communication, priority: .high),
        ChecklistItem(id: checklistIDs[6], name: "Important documents (IDs, insurance) in waterproof container", category: .documents, priority: .high),
        ChecklistItem(id: checklistIDs[7], name: "Cash in small denominations", category: .basicSupplies, priority: .high),
        ChecklistItem(id: checklistIDs[8], name: "Whistle to signal for help", category: .basicSupplies, priority: .high),
        ChecklistItem(id: checklistIDs[9], name: "Dust masks (N95)", category: .medical, priority: .high),
        ChecklistItem(id: checklistIDs[10], name: "Moist towelettes, garbage bags, plastic ties", category: .basicSupplies, priority: .medium),
        ChecklistItem(id: checklistIDs[11], name: "Wrench or pliers to turn off utilities", category: .basicSupplies, priority: .medium),
        ChecklistItem(id: checklistIDs[12], name: "Manual can opener", category: .basicSupplies, priority: .medium),
        ChecklistItem(id: checklistIDs[13], name: "Cell phone with chargers (portable backup)", category: .communication, priority: .medium),
        ChecklistItem(id: checklistIDs[14], name: "Family emergency contact list", category: .communication, priority: .medium),
        ChecklistItem(id: checklistIDs[15], name: "Pet food and supplies (if applicable)", category: .basicSupplies, priority: .low),
        ChecklistItem(id: checklistIDs[16], name: "Blankets or sleeping bags", category: .basicSupplies, priority: .low)
    ]

    // MARK: - Disaster Categories

    private static func _disaster(
        _ name: String,
        _ icon: String,
        _ sev: DisasterSeverity,
        _ desc: String,
        _ steps: [String],
        _ supplies: [String],
        additionalInfo: String = "",
        warningSigns: [String] = [],
        duringEvent: [String] = [],
        sources: [DisasterSource] = []
    ) -> Disaster {
        Disaster(
            name: name,
            icon: icon,
            severity: sev,
            description: desc,
            preparednessSteps: steps,
            supplies: supplies,
            additionalInfo: additionalInfo,
            warningSigns: warningSigns,
            duringEvent: duringEvent,
            sources: sources
        )
    }

    static let disasterCategories: [DisasterCategory] = [
        DisasterCategory(
            name: "Weather",
            icon: "cloud.bolt.rain.fill",
            color: "blue",
            disasters: [
                _disaster(
                    "Hurricanes",
                    "hurricane",
                    .extreme,
                    "Tropical cyclones with sustained winds over 74 mph. Cause storm surge, flooding, and wind damage.",
                    ["Know evacuation routes", "Stock 3+ days of supplies", "Secure outdoor items", "Have a communication plan"],
                    ["Water (1 gal/person/day)", "Non-perishable food", "Flashlights", "Batteries", "First aid kit"],
                    additionalInfo: "Hurricanes are large, rotating storms that form over warm ocean waters. They are classified by wind speed into five categories:\n\nCategory 1: Winds 74-95 mph\nCategory 2: Winds 96-110 mph\nCategory 3: Winds 111-129 mph\nCategory 4: Winds 130-156 mph\nCategory 5: Winds 157 mph or higher\n\nThe most dangerous part of a hurricane is storm surge. This is water that gets pushed ashore by the winds and can reach over 20 feet high. Hurricanes can also create tornadoes and cause serious flooding from all the rain they bring.",
                    warningSigns: ["Tropical storm/hurricane watch issued", "Rising water levels", "Increasing wind speeds", "Barometric pressure dropping", "Heavy rain bands approaching"],
                    duringEvent: ["Stay indoors away from windows", "If in evacuation zone, leave immediately", "Do not drive through flooded areas", "Turn off utilities if instructed", "Stay tuned to NOAA Weather Radio"],
                    sources: [
                        DisasterSource(name: "FEMA - Hurricane Preparedness", url: "https://www.ready.gov/hurricanes"),
                        DisasterSource(name: "NOAA - National Hurricane Center", url: "https://www.nhc.noaa.gov/prepare/"),
                        DisasterSource(name: "American Red Cross - Hurricane Safety", url: "https://www.redcross.org/get-help/how-to-prepare-for-emergencies/types-of-emergencies/hurricane")
                    ]
                ),
                _disaster(
                    "Tornadoes",
                    "tornado",
                    .extreme,
                    "Violently rotating columns of air. Can form quickly with little warning.",
                    ["Identify safe room (basement or interior)", "Practice tornado drills", "Stay informed via NOAA Weather Radio", "Know the difference between watch and warning"],
                    ["Helmet", "Sturdy shoes", "Whistle", "Battery-powered radio", "Emergency kit"],
                    additionalInfo: "Tornadoes are violently rotating columns of air that drop down from thunderstorms to the ground. They can reach wind speeds over 300 mph and cause terrible damage. Scientists use the Enhanced Fujita Scale to rate tornadoes from EF0 to EF5 based on how much damage they cause.\n\nMost tornadoes happen in the central United States, an area called Tornado Alley. But tornadoes can happen anywhere. They usually only last a few minutes, but they can travel for miles. The warning time is often very short, sometimes just seconds.",
                    warningSigns: ["Dark, greenish sky", "Large, dark, low-lying cloud", "Roaring noise like a freight train", "Debris cloud", "Funnel cloud visible", "Hail or heavy rain followed by dead calm"],
                    duringEvent: ["Go to basement, storm cellar, or interior room on lowest floor", "Avoid windows", "Cover yourself with mattress or blankets", "If in vehicle, get out and seek shelter in low-lying area", "If outdoors, lie flat in ditch and cover head"],
                    sources: [
                        DisasterSource(name: "NOAA - Tornado Safety", url: "https://www.weather.gov/safety/tornado"),
                        DisasterSource(name: "FEMA - Tornado Preparedness", url: "https://www.ready.gov/tornadoes"),
                        DisasterSource(name: "American Red Cross - Tornado Safety", url: "https://www.redcross.org/get-help/how-to-prepare-for-emergencies/types-of-emergencies/tornado")
                    ]
                ),
                _disaster(
                    "Flooding",
                    "drop.triangle.fill",
                    .high,
                    "Overflow of water onto normally dry land. Includes flash floods, river floods, and storm surge.",
                    ["Know your flood zone", "Elevate critical utilities", "Never drive through flooded roads", "Create a flood emergency plan"],
                    ["Sandbags", "Sump pump", "Waterproof containers", "Water", "Non-perishable food"],
                    additionalInfo: "Flooding is the most common natural disaster in the United States. There are different types of floods:\n\nFlash floods happen within 6 hours of heavy rain and can occur anywhere.\nRiver floods develop over days or weeks as rivers rise.\nCoastal flooding happens when hurricanes push ocean water onto land.\n\nMoving water is very powerful. Just 6 inches of moving water can knock you down. Twelve inches can carry away a car. Most people who die in floods are in their vehicles. Floodwater can also be dangerous because it often contains sewage, chemicals, and debris.",
                    warningSigns: ["Heavy rainfall", "Rising water levels", "Flood watch or warning issued", "Rapidly rising streams or rivers", "Water pooling on roads"],
                    duringEvent: ["Move to higher ground immediately", "Never walk or drive through floodwaters", "Avoid bridges over fast-moving water", "If trapped in vehicle, abandon it and move to higher ground", "Stay away from downed power lines"],
                    sources: [
                        DisasterSource(name: "FEMA - Flood Preparedness", url: "https://www.ready.gov/floods"),
                        DisasterSource(name: "NOAA - Flood Safety", url: "https://www.weather.gov/safety/flood"),
                        DisasterSource(name: "American Red Cross - Flood Safety", url: "https://www.redcross.org/get-help/how-to-prepare-for-emergencies/types-of-emergencies/flood")
                    ]
                ),
                _disaster(
                    "Severe Thunderstorms",
                    "cloud.bolt.fill",
                    .moderate,
                    "Storms with hail, damaging winds, lightning, and possible tornadoes.",
                    ["Stay indoors", "Unplug electronics", "Avoid plumbing and corded phones", "Monitor weather alerts"],
                    ["Flashlight", "Batteries", "Battery radio", "First aid kit"],
                    additionalInfo: "Severe thunderstorms are storms that produce large hail (at least 1 inch), strong wind gusts over 58 mph, or tornadoes. Lightning strikes the United States about 25 million times each year and kills an average of 47 people annually.\n\nUse the 30-30 rule to stay safe. If you see lightning and hear thunder within 30 seconds, go indoors right away. Wait 30 minutes after you hear the last thunder before going back outside. Lightning can strike up to 10 miles away from where it's raining. Hail can cause serious damage to property and can injure people.",
                    warningSigns: ["Dark, towering clouds", "Lightning and thunder", "Strong winds", "Large hail", "Heavy rain", "Severe thunderstorm watch or warning"],
                    duringEvent: ["Stay indoors away from windows", "Avoid electrical equipment and plumbing", "If outdoors, seek shelter immediately", "If in vehicle, stay inside with windows closed", "Avoid tall objects and open areas"],
                    sources: [
                        DisasterSource(name: "NOAA - Thunderstorm Safety", url: "https://www.weather.gov/safety/thunderstorm"),
                        DisasterSource(name: "FEMA - Thunderstorm Preparedness", url: "https://www.ready.gov/thunderstorms-lightning"),
                        DisasterSource(name: "National Weather Service - Lightning Safety", url: "https://www.weather.gov/safety/lightning")
                    ]
                )
            ]
        ),
        DisasterCategory(
            name: "Fire & Heat",
            icon: "flame.fill",
            color: "orange",
            disasters: [
                _disaster(
                    "Wildfires",
                    "flame.fill",
                    .extreme,
                    "Uncontrolled fires in wildland areas. Spread quickly with wind and dry conditions.",
                    ["Create defensible space (30 ft)", "Clear gutters and roofs", "Have evacuation go-bag ready", "Know multiple evacuation routes"],
                    ["N95 masks", "Goggles", "Emergency kit", "Important documents", "Pet supplies"],
                    additionalInfo: "Wildfires can spread very quickly, up to 14 miles per hour, burning everything in their path. They happen most often in the western United States, but can occur anywhere when conditions are dry.\n\nFlying embers can travel up to a mile ahead of the main fire and start new fires. Breathing in smoke is dangerous, especially for people with asthma or other breathing problems. Wildfires can cause power outages, make the air unhealthy to breathe, and force many people to evacuate. Climate change has made wildfires happen more often and burn more intensely.",
                    warningSigns: ["Red flag warning issued", "Extreme heat and low humidity", "Strong winds", "Smoke visible in distance", "Evacuation order issued", "Unusual smell of smoke"],
                    duringEvent: ["Evacuate immediately if ordered", "Close all windows and doors", "Wear N95 mask if smoke is present", "Stay indoors with windows closed if not evacuating", "Avoid outdoor activities", "Monitor air quality alerts"],
                    sources: [
                        DisasterSource(name: "FEMA - Wildfire Preparedness", url: "https://www.ready.gov/wildfires"),
                        DisasterSource(name: "USDA Forest Service - Fire Safety", url: "https://www.fs.usda.gov/managing-land/fire"),
                        DisasterSource(name: "American Red Cross - Wildfire Safety", url: "https://www.redcross.org/get-help/how-to-prepare-for-emergencies/types-of-emergencies/wildfire"),
                        DisasterSource(name: "EPA - Wildfire Smoke Guide", url: "https://www.airnow.gov/wildfire-guide/")
                    ]
                ),
                _disaster(
                    "Extreme Heat",
                    "thermometer.sun.fill",
                    .high,
                    "Prolonged periods of dangerously high temperatures. Risk of heat stroke and dehydration.",
                    ["Stay hydrated", "Limit outdoor activity", "Check on vulnerable neighbors", "Know cooling center locations"],
                    ["Water", "Electrolytes", "Sunscreen", "Light clothing", "Cooling towels"],
                    additionalInfo: "Extreme heat kills more people in the United States than hurricanes, floods, and tornadoes combined. Heat exhaustion and heat stroke are serious illnesses that can be deadly.\n\nOlder adults, children, and people with ongoing health problems are most at risk. Cities can be much hotter than surrounding areas, sometimes 10 to 15 degrees warmer. This is called the heat island effect. When it's also humid, heat becomes more dangerous because your sweat can't evaporate to cool you down. Never leave children or pets in a parked car. The temperature inside can become deadly in just minutes.",
                    warningSigns: ["Excessive heat warning issued", "Heat index over 105°F", "Rapid pulse", "Nausea or dizziness", "Confusion", "Hot, dry skin (heat stroke)"],
                    duringEvent: ["Stay in air-conditioned spaces", "Drink water regularly, avoid alcohol and caffeine", "Wear lightweight, light-colored clothing", "Take cool showers", "Limit outdoor activities to early morning or evening", "Never leave anyone in parked vehicle"],
                    sources: [
                        DisasterSource(name: "CDC - Extreme Heat Safety", url: "https://www.cdc.gov/disasters/extremeheat/index.html"),
                        DisasterSource(name: "NOAA - Heat Safety", url: "https://www.weather.gov/safety/heat"),
                        DisasterSource(name: "FEMA - Extreme Heat Preparedness", url: "https://www.ready.gov/heat"),
                        DisasterSource(name: "American Red Cross - Heat Wave Safety", url: "https://www.redcross.org/get-help/how-to-prepare-for-emergencies/types-of-emergencies/heat-wave")
                    ]
                )
            ]
        ),
        DisasterCategory(
            name: "Winter",
            icon: "snowflake",
            color: "cyan",
            disasters: [
                _disaster(
                    "Blizzards",
                    "cloud.snow.fill",
                    .extreme,
                    "Severe snowstorms with strong winds, poor visibility, and life-threatening conditions.",
                    ["Stay indoors", "Stock emergency supplies", "Keep vehicle fuel tank full", "Have backup heat source"],
                    ["Rock salt", "Shovel", "Blankets", "Water", "Non-perishable food", "Battery radio"],
                    additionalInfo: "Blizzards are severe winter storms with strong winds over 35 mph, very poor visibility less than a quarter mile, and heavy snow that lasts for at least 3 hours. The wind chill can make it feel 30 to 50 degrees colder than the actual temperature. This can cause frostbite in just minutes.\n\nBlizzards create whiteout conditions where you can't see anything, making travel impossible. Power outages are common because heavy snow and ice weigh down power lines. If you're exposed to the cold, you're at serious risk of hypothermia.",
                    warningSigns: ["Blizzard warning issued", "Heavy snowfall", "Strong winds", "Rapidly dropping temperatures", "Reduced visibility", "Wind chill advisory"],
                    duringEvent: ["Stay indoors", "If trapped in vehicle, stay inside", "Run engine 10 minutes per hour for heat", "Keep exhaust pipe clear of snow", "Move arms and legs to maintain circulation", "Conserve phone battery"],
                    sources: [
                        DisasterSource(name: "NOAA - Winter Weather Safety", url: "https://www.weather.gov/safety/winter"),
                        DisasterSource(name: "FEMA - Winter Storm Preparedness", url: "https://www.ready.gov/winter-weather"),
                        DisasterSource(name: "American Red Cross - Winter Storm Safety", url: "https://www.redcross.org/get-help/how-to-prepare-for-emergencies/types-of-emergencies/winter-storm"),
                        DisasterSource(name: "CDC - Winter Weather Safety", url: "https://www.cdc.gov/disasters/winter/index.html")
                    ]
                ),
                _disaster(
                    "Ice Storms",
                    "cloud.sleet.fill",
                    .high,
                    "Freezing rain that coats surfaces in ice. Causes power outages and dangerous travel.",
                    ["Prepare for power loss", "Avoid travel", "Have alternative heat (safely)", "Stock water and food"],
                    ["Flashlights", "Batteries", "Blankets", "Manual can opener", "First aid kit"],
                    additionalInfo: "Ice storms happen when freezing rain builds up on everything, creating a layer of ice. Even a quarter inch of ice can cause serious damage. The ice can bring down power lines and tree branches, causing widespread power outages.\n\nRoads become extremely dangerous. Black ice is nearly invisible and very slippery. When ice builds up on trees, branches can break and fall, creating hazards. Ice storms can last for days, making it hard to recover.",
                    warningSigns: ["Freezing rain warning", "Temperatures near or below freezing", "Rain falling in freezing conditions", "Ice accumulating on surfaces", "Power lines sagging", "Tree branches breaking"],
                    duringEvent: ["Stay off roads", "Avoid walking on icy surfaces", "Keep refrigerator and freezer closed to preserve food", "Use generators safely—never indoors", "Check on elderly neighbors", "Stay away from downed power lines"],
                    sources: [
                        DisasterSource(name: "NOAA - Ice Storm Safety", url: "https://www.weather.gov/safety/winter-ice"),
                        DisasterSource(name: "FEMA - Ice Storm Preparedness", url: "https://www.ready.gov/winter-weather"),
                        DisasterSource(name: "American Red Cross - Ice Storm Safety", url: "https://www.redcross.org/get-help/how-to-prepare-for-emergencies/types-of-emergencies/winter-storm")
                    ]
                )
            ]
        ),
        DisasterCategory(
            name: "Geological",
            icon: "mountain.2.fill",
            color: "brown",
            disasters: [
                _disaster(
                    "Earthquakes",
                    "waveform.path.ecg",
                    .extreme,
                    "Sudden shaking of the ground. No advance warning. Can trigger tsunamis and landslides.",
                    ["Drop, Cover, Hold On", "Secure heavy furniture", "Know gas shut-off location", "Practice earthquake drills"],
                    ["Emergency kit", "Wrench for utilities", "Sturdy shoes", "Whistle", "Dust masks"],
                    additionalInfo: "Earthquakes happen when the earth's tectonic plates move and release energy, causing the ground to shake. Scientists cannot predict when earthquakes will happen, but some areas are at higher risk, like California, Alaska, and the Pacific Northwest where fault lines are located.\n\nThe Richter Scale measures how strong an earthquake is. Each whole number increase means the ground shakes 10 times more. After the main earthquake, smaller earthquakes called aftershocks can continue for days or weeks. Earthquakes can cause tsunamis, landslides, fires from gas leaks, and building collapses. Most injuries happen from falling objects, not from buildings collapsing.",
                    warningSigns: ["No advance warning—earthquakes strike suddenly", "If near coast and ground shakes severely, prepare for possible tsunami", "Aftershocks will follow—expect continued shaking"],
                    duringEvent: ["Drop to hands and knees", "Cover head and neck with arms, crawl under sturdy table", "Hold on until shaking stops", "If in bed, stay there and cover head with pillow", "If outdoors, move to open area away from buildings and trees", "If in vehicle, pull over and stay inside"],
                    sources: [
                        DisasterSource(name: "USGS - Earthquake Preparedness", url: "https://www.usgs.gov/natural-hazards/earthquake-hazards/science/earthquake-preparedness"),
                        DisasterSource(name: "FEMA - Earthquake Preparedness", url: "https://www.ready.gov/earthquakes"),
                        DisasterSource(name: "American Red Cross - Earthquake Safety", url: "https://www.redcross.org/get-help/how-to-prepare-for-emergencies/types-of-emergencies/earthquake"),
                        DisasterSource(name: "CUSEC - Central US Earthquake Consortium", url: "https://www.cusec.org/")
                    ]
                ),
                _disaster(
                    "Landslides",
                    "mountain.2.fill",
                    .high,
                    "Downward movement of soil and rock. Often triggered by heavy rain or earthquakes.",
                    ["Know landslide-prone areas", "Watch for warning signs", "Evacuate if advised", "Avoid steep slopes during storms"],
                    ["Emergency kit", "Battery radio", "Evacuation route map"],
                    additionalInfo: "Landslides happen when slopes become unstable due to water, earthquakes, or human activity. They can move slowly over time, or they can move very fast in what's called a debris flow.\n\nHeavy rain is the most common cause. Even just 2 inches of rain in a short time can trigger a landslide. Areas with steep slopes, places that recently had wildfires, or areas that have had landslides before are at higher risk. Landslides can block roads, damage buildings, and cause deaths. Debris flows can move as fast as 35 miles per hour.",
                    warningSigns: ["Heavy rainfall", "Cracks in ground or pavement", "Bulging ground at base of slope", "Water seeping from slope", "Tilting trees or utility poles", "Landslide warning issued", "Unusual sounds like trees cracking"],
                    duringEvent: ["Evacuate immediately if in path", "Move to higher ground", "Avoid river valleys and low-lying areas", "Stay away from slide area—watch for additional slides", "Listen for unusual sounds indicating movement"],
                    sources: [
                        DisasterSource(name: "USGS - Landslide Hazards", url: "https://www.usgs.gov/natural-hazards/landslide-hazards"),
                        DisasterSource(name: "FEMA - Landslide Preparedness", url: "https://www.ready.gov/landslides-debris-flow"),
                        DisasterSource(name: "NOAA - Landslide Safety", url: "https://www.weather.gov/safety/landslide"),
                        DisasterSource(name: "American Red Cross - Landslide Safety", url: "https://www.redcross.org/get-help/how-to-prepare-for-emergencies/types-of-emergencies/landslide")
                    ]
                )
            ]
        )
    ]

    // MARK: - Emergency Resources

    static let emergencyResources: [EmergencyResource] = [
        EmergencyResource(name: "UCLA Ronald Reagan Medical Center", type: .hospital, coordinate: Coordinate(latitude: 34.0669, longitude: -118.4452), address: "757 Westwood Plaza, Los Angeles, CA"),
        EmergencyResource(name: "LA Fire Station 27", type: .fireStation, coordinate: Coordinate(latitude: 34.0522, longitude: -118.2437), address: "1424 N Cahuenga Blvd, Los Angeles, CA"),
        EmergencyResource(name: "LAPD Central Division", type: .policeStation, coordinate: Coordinate(latitude: 34.0407, longitude: -118.2468), address: "251 E 6th St, Los Angeles, CA"),
        EmergencyResource(name: "American Red Cross LA Chapter", type: .shelter, coordinate: Coordinate(latitude: 34.0625, longitude: -118.3061), address: "11355 Ohio Ave, Los Angeles, CA"),
        EmergencyResource(name: "Memorial Hermann-TMC", type: .hospital, coordinate: Coordinate(latitude: 29.7074, longitude: -95.4019), address: "6411 Fannin St, Houston, TX"),
        EmergencyResource(name: "Houston Fire Station 8", type: .fireStation, coordinate: Coordinate(latitude: 29.7604, longitude: -95.3698), address: "2217 Milam St, Houston, TX"),
        EmergencyResource(name: "HPD Central Patrol", type: .policeStation, coordinate: Coordinate(latitude: 29.7525, longitude: -95.3667), address: "61 Riesner St, Houston, TX"),
        EmergencyResource(name: "George R. Brown Convention Center (Shelter)", type: .shelter, coordinate: Coordinate(latitude: 29.7513, longitude: -95.3608), address: "1001 Avenida de las Americas, Houston, TX"),
        EmergencyResource(name: "Jackson Memorial Hospital", type: .hospital, coordinate: Coordinate(latitude: 25.7907, longitude: -80.21), address: "1611 NW 12th Ave, Miami, FL"),
        EmergencyResource(name: "Miami Fire Rescue Station 1", type: .fireStation, coordinate: Coordinate(latitude: 25.7743, longitude: -80.1937), address: "144 NE 5th St, Miami, FL"),
        EmergencyResource(name: "Miami Police Department", type: .policeStation, coordinate: Coordinate(latitude: 25.7743, longitude: -80.1967), address: "400 NW 2nd Ave, Miami, FL"),
        EmergencyResource(name: "FIU Arena (Evacuation Shelter)", type: .shelter, coordinate: Coordinate(latitude: 25.757, longitude: -80.3733), address: "11200 SW 8th St, Miami, FL")
    ]

    // MARK: - WEA Data

    static let weaVerificationSteps: [WEAVerificationStep] = [
        WEAVerificationStep(title: "Check WEA is enabled", instructions: "Open Settings → Notifications. Scroll to Government Alerts. Ensure 'Emergency Alerts' and 'Public Safety Alerts' are ON. 'AMBER Alerts' is optional."),
        WEAVerificationStep(title: "Confirm carrier support", instructions: "WEA is supported by all major US carriers (AT&T, Verizon, T-Mobile, etc.). Your phone must be connected to a participating carrier's network. Roaming or WiFi-only may not receive WEAs."),
        WEAVerificationStep(title: "Test with a drill (optional)", instructions: "Some states conduct WEA tests. You may receive a test alert. Check your phone's alert history in Settings → Notifications → Government Alerts to see past WEAs.")
    ]

    static let weaEducation: WEAEducationContent = WEAEducationContent(
        whatIsWEA: (
            title: "What is WEA?",
            content: "Wireless Emergency Alerts (WEA) are free messages sent by government authorities (FEMA, NWS, state/local) to compatible cell phones. You don't need to sign up—if your phone is on and can receive, you get them. WEAs are used for imminent threats (tornado, hurricane, flash flood), AMBER Alerts, and Presidential alerts."
        ),
        typesOfAlerts: (
            title: "Types of Alerts",
            content: "**Imminent Threat:** Severe weather, natural disasters, active shooter, biological/chemical hazards. **AMBER Alerts:** Missing children. **Presidential:** National emergencies. All use a distinct sound and vibration, even if your phone is on silent."
        ),
        whatToDo: (
            title: "When You Receive a WEA",
            content: "1. Read the message carefully. 2. Follow any instructions (e.g., evacuate, seek shelter). 3. Don't rely solely on WEA—use NOAA Weather Radio, local news, and official apps. 4. Share the alert with others who may not have received it."
        ),
        limitations: (
            title: "Limitations",
            content: "WEAs are short (360 characters). They may be delayed in congested networks. Location accuracy is cell-tower based (about 0.1–1 mile). Keep a battery-powered radio and backup communication plan."
        )
    )

    static let seasonalReminders: [SeasonalReminder] = [
        SeasonalReminder(season: "Hurricane (Jun–Nov)", tip: "Review evacuation routes, stock 3+ days of supplies, and know your zone (A, B, C, etc.)."),
        SeasonalReminder(season: "Wildfire (Summer–Fall)", tip: "Create defensible space, pack a go-bag, and monitor air quality."),
        SeasonalReminder(season: "Tornado (Spring)", tip: "Identify your safe room, practice drills, and keep a NOAA Weather Radio."),
        SeasonalReminder(season: "Winter (Nov–Mar)", tip: "Winterize your home, keep car kit with blankets and shovel, and avoid travel in storms."),
        SeasonalReminder(season: "Earthquake (Year-round)", tip: "Secure heavy furniture, practice Drop-Cover-Hold-On, and know gas shut-off.")
    ]

    // MARK: - Weather Alert Templates

    /// Preloaded NWS-style weather alert templates. Matched by state abbreviation + month.
    /// Offline only — no network calls. Shows relevant alerts based on state/season.
    ///
    /// **Data Source & Attribution:**
    /// - Alert formats and terminology are based on National Weather Service (NWS) standards
    /// - Alert descriptions are generalized templates representing typical seasonal hazards
    /// - These are NOT real-time NWS alerts, but preloaded templates for offline use
    /// - Alert types, severity levels, and safety guidance follow NWS conventions
    /// - For real-time alerts, visit weather.gov or use official NWS apps
    ///
    /// **Credits & Sources:**
    /// - Alert format/style: National Weather Service (NWS) - weather.gov
    /// - Safety guidance and preparedness recommendations: 
    ///   • Federal Emergency Management Agency (FEMA) - ready.gov
    ///   • National Weather Service (NWS) - weather.gov/safety
    /// - Disaster preparedness information based on official FEMA and NWS public safety resources
    struct WeatherAlertTemplate {
        let alert: WeatherAlert
        let stateAbbr: String
        let months: [String]
    }

    static let weatherAlertTemplates: [WeatherAlertTemplate] = {
        func template(_ type: AlertType, _ severity: AlertSeverity, _ area: String, _ title: String, _ desc: String, _ stateAbbr: String, _ months: [String]) -> WeatherAlertTemplate {
            WeatherAlertTemplate(
                alert: WeatherAlert(
                    type: type,
                    severity: severity,
                    area: area,
                    title: title,
                    description: desc,
                    source: "National Weather Service"
                ),
                stateAbbr: stateAbbr,
                months: months
            )
        }
        return [
            // Texas — Extreme Cold (Winter)
            template(.extremeCold, .extreme, "Texas", "Extreme Cold Warning", "EXTREME COLD WARNING REMAINS IN EFFECT UNTIL NOON CST MONDAY. Dangerously cold wind chills as low as 5 degrees below zero possible over parts of the Hill Country and Central Texas. Frostbite and hypothermia can occur quickly. Limit time outdoors, dress in layers, and check on vulnerable neighbors.", "TX", ["December", "January", "February"]),
            // Texas — Tornado (Spring)
            template(.tornado, .extreme, "Texas", "Tornado Watch", "TORNADO WATCH IN EFFECT. Conditions are favorable for tornadoes and severe thunderstorms. Have a plan to move to a safe location immediately if a warning is issued. Monitor NOAA Weather Radio or local news.", "TX", ["March", "April", "May"]),
            // Texas — Heat (Summer)
            template(.extremeHeat, .severe, "Texas", "Extreme Heat Warning", "EXTREME HEAT WARNING. Heat index values up to 110 degrees expected. Heat-related illness likely. Stay hydrated, limit outdoor activity, and check on elderly and vulnerable people. Never leave children or pets in vehicles.", "TX", ["June", "July", "August"]),
            // Texas — Hurricane (Fall)
            template(.hurricane, .extreme, "Texas", "Hurricane Warning", "HURRICANE WARNING. Hurricane conditions expected within 36 hours. Life-threatening storm surge, flooding, and wind damage possible. Complete preparations and follow evacuation orders if issued. Know your evacuation zone.", "TX", ["August", "September", "October"]),
            // Oklahoma — Tornado (Spring)
            template(.tornado, .extreme, "Oklahoma", "Tornado Watch", "TORNADO WATCH IN EFFECT. Severe thunderstorms capable of producing tornadoes, large hail, and damaging winds. Move to an interior room on the lowest floor. Avoid windows.", "OK", ["April", "May", "June"]),
            // Oklahoma — Winter Storm
            template(.winterStorm, .severe, "Oklahoma", "Winter Storm Warning", "WINTER STORM WARNING. Heavy snow and ice accumulations expected. Travel will be difficult or impossible. Stay off roads if possible. Have emergency supplies ready.", "OK", ["December", "January", "February"]),
            // California — Wildfire (Summer/Fall)
            template(.wildfire, .extreme, "California", "Red Flag Warning", "RED FLAG WARNING. Critical fire weather conditions. Strong winds, low humidity, and dry fuels. Any fires that develop will spread rapidly. No outdoor burning. Be ready to evacuate if needed.", "CA", ["June", "July", "August", "September", "October"]),
            // California — Extreme Heat
            template(.extremeHeat, .severe, "California", "Extreme Heat Warning", "EXTREME HEAT WARNING. Dangerously hot conditions with heat index values up to 115 degrees. Heat-related illness likely. Stay indoors during peak heat. Use cooling centers if available.", "CA", ["June", "July", "August", "September"]),
            // California — Winter Floods/Mudslides
            template(.flashFlood, .severe, "California", "Flash Flood Watch", "FLASH FLOOD WATCH. Heavy rain may cause flash flooding and mudslides, especially in burn scar areas. Avoid low-lying areas and never drive through flooded roads. Be ready to move to higher ground.", "CA", ["November", "December", "January", "February"]),
            // Florida — Hurricane
            template(.hurricane, .extreme, "Florida", "Hurricane Warning", "HURRICANE WARNING. Hurricane conditions expected. Life-threatening storm surge, flooding, and wind damage. Complete preparations immediately. Follow evacuation orders. Know your evacuation zone and routes.", "FL", ["June", "July", "August", "September", "October", "November"]),
            // Florida — Heat
            template(.extremeHeat, .severe, "Florida", "Heat Advisory", "HEAT ADVISORY. Heat index values up to 108 degrees. Heat-related illness possible. Stay hydrated, limit outdoor activity, and check on vulnerable people.", "FL", ["May", "June", "July", "August", "September"]),
            // Louisiana — Hurricane
            template(.hurricane, .extreme, "Louisiana", "Hurricane Warning", "HURRICANE WARNING. Hurricane conditions expected. Life-threatening storm surge and flooding. Complete preparations and follow evacuation orders. Know your evacuation zone.", "LA", ["June", "July", "August", "September", "October"]),
            // Colorado — Blizzard
            template(.blizzard, .extreme, "Colorado", "Blizzard Warning", "BLIZZARD WARNING. Blowing snow, strong winds, and whiteout conditions. Travel will be extremely dangerous or impossible. Stay indoors. If you must travel, have a winter survival kit in your vehicle.", "CO", ["November", "December", "January", "February", "March"]),
            // Colorado — Wildfire
            template(.wildfire, .severe, "Colorado", "Red Flag Warning", "RED FLAG WARNING. Critical fire weather conditions. Strong winds and low humidity. Any fires will spread rapidly. No outdoor burning. Be ready to evacuate.", "CO", ["June", "July", "August"]),
            // Arizona — Extreme Heat
            template(.extremeHeat, .extreme, "Arizona", "Excessive Heat Warning", "EXCESSIVE HEAT WARNING. Dangerously hot conditions with temperatures up to 115 degrees. Heat-related illness likely. Stay indoors during peak heat. Never leave children or pets in vehicles.", "AZ", ["May", "June", "July", "August", "September"]),
            // Arizona — Monsoon Flooding
            template(.flashFlood, .severe, "Arizona", "Flash Flood Warning", "FLASH FLOOD WARNING. Heavy monsoon rains may cause flash flooding. Avoid low-lying areas, washes, and arroyos. Never drive through flooded roads. Turn around, don't drown.", "AZ", ["June", "July", "August", "September"]),
            // Kansas — Tornado
            template(.tornado, .extreme, "Kansas", "Tornado Warning", "TORNADO WARNING. A tornado has been sighted or indicated by radar. Take shelter immediately in an interior room on the lowest floor. Avoid windows. Protect your head.", "KS", ["April", "May", "June"]),
            // Kansas — Winter Storm
            template(.winterStorm, .severe, "Kansas", "Winter Storm Warning", "WINTER STORM WARNING. Heavy snow and ice expected. Travel will be difficult. Stay off roads if possible. Have emergency supplies ready.", "KS", ["December", "January", "February"]),
        ]
    }()
}
