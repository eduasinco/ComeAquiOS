//
//  Strings.swift
//  ComeAquiOS
//
//  Created by eduardo rodríguez on 15/04/2020.
//  Copyright © 2020 Eduardo Rodríguez Pérez. All rights reserved.
//

import UIKit

let local_server = "http://0.0.0.0:65100"
let real_local_server = "http://10.153.31.109:65100"
let production_server = "http://54.193.13.44"
let production_async_server = "http://54.193.13.44:8001"

let SERVER = production_server
let ASYNC_SERVER = production_async_server

let GOOGLE_KEY = "AIzaSyDqkl1DgwHu03SmMoqVey3sgR62GnJ-VY4"


let darkMapStyle = "[" +
"  {" +
"    \"featureType\": \"all\"," +
"    \"elementType\": \"geometry\"," +
"    \"stylers\": [" +
"      {" +
"        \"color\": \"#242f3e\"" +
"      }" +
"    ]" +
"  }," +
"  {" +
"    \"featureType\": \"all\"," +
"    \"elementType\": \"labels.text.stroke\"," +
"    \"stylers\": [" +
"      {" +
"        \"lightness\": -80" +
"      }" +
"    ]" +
"  }," +
"  {" +
"    \"featureType\": \"administrative\"," +
"    \"elementType\": \"labels.text.fill\"," +
"    \"stylers\": [" +
"      {" +
"        \"color\": \"#746855\"" +
"      }" +
"    ]" +
"  }," +
"  {" +
"    \"featureType\": \"administrative.locality\"," +
"    \"elementType\": \"labels.text.fill\"," +
"    \"stylers\": [" +
"      {" +
"        \"color\": \"#d59563\"" +
"      }" +
"    ]" +
"  }," +
"  {" +
"    \"featureType\": \"poi\"," +
"    \"elementType\": \"labels.text.fill\"," +
"    \"stylers\": [" +
"      {" +
"        \"color\": \"#d59563\"" +
"      }" +
"    ]" +
"  }," +
"  {" +
"    \"featureType\": \"poi.park\"," +
"    \"elementType\": \"geometry\"," +
"    \"stylers\": [" +
"      {" +
"        \"color\": \"#263c3f\"" +
"      }" +
"    ]" +
"  }," +
"  {" +
"    \"featureType\": \"poi.park\"," +
"    \"elementType\": \"labels.text.fill\"," +
"    \"stylers\": [" +
"      {" +
"        \"color\": \"#6b9a76\"" +
"      }" +
"    ]" +
"  }," +
"  {" +
"    \"featureType\": \"road\"," +
"    \"elementType\": \"geometry.fill\"," +
"    \"stylers\": [" +
"      {" +
"        \"color\": \"#2b3544\"" +
"      }" +
"    ]" +
"  }," +
"  {" +
"    \"featureType\": \"road\"," +
"    \"elementType\": \"labels.text.fill\"," +
"    \"stylers\": [" +
"      {" +
"        \"color\": \"#9ca5b3\"" +
"      }" +
"    ]" +
"  }," +
"  {" +
"    \"featureType\": \"road.arterial\"," +
"    \"elementType\": \"geometry.fill\"," +
"    \"stylers\": [" +
"      {" +
"        \"color\": \"#38414e\"" +
"      }" +
"    ]" +
"  }," +
"  {" +
"    \"featureType\": \"road.arterial\"," +
"    \"elementType\": \"geometry.stroke\"," +
"    \"stylers\": [" +
"      {" +
"        \"color\": \"#212a37\"" +
"      }" +
"    ]" +
"  }," +
"  {" +
"    \"featureType\": \"road.highway\"," +
"    \"elementType\": \"geometry.fill\"," +
"    \"stylers\": [" +
"      {" +
"        \"color\": \"#746855\"" +
"      }" +
"    ]" +
"  }," +
"  {" +
"    \"featureType\": \"road.highway\"," +
"    \"elementType\": \"geometry.stroke\"," +
"    \"stylers\": [" +
"      {" +
"        \"color\": \"#1f2835\"" +
"      }" +
"    ]" +
"  }," +
"  {" +
"    \"featureType\": \"road.highway\"," +
"    \"elementType\": \"labels.text.fill\"," +
"    \"stylers\": [" +
"      {" +
"        \"color\": \"#f3d19c\"" +
"      }" +
"    ]" +
"  }," +
"  {" +
"    \"featureType\": \"road.local\"," +
"    \"elementType\": \"geometry.fill\"," +
"    \"stylers\": [" +
"      {" +
"        \"color\": \"#38414e\"" +
"      }" +
"    ]" +
"  }," +
"  {" +
"    \"featureType\": \"road.local\"," +
"    \"elementType\": \"geometry.stroke\"," +
"    \"stylers\": [" +
"      {" +
"        \"color\": \"#212a37\"" +
"      }" +
"    ]" +
"  }," +
"  {" +
"    \"featureType\": \"transit\"," +
"    \"elementType\": \"geometry\"," +
"    \"stylers\": [" +
"      {" +
"        \"color\": \"#2f3948\"" +
"      }" +
"    ]" +
"  }," +
"  {" +
"    \"featureType\": \"transit.station\"," +
"    \"elementType\": \"labels.text.fill\"," +
"    \"stylers\": [" +
"      {" +
"        \"color\": \"#d59563\"" +
"      }" +
"    ]" +
"  }," +
"  {" +
"    \"featureType\": \"water\"," +
"    \"elementType\": \"geometry\"," +
"    \"stylers\": [" +
"      {" +
"        \"color\": \"#17263c\"" +
"      }" +
"    ]" +
"  }," +
"  {" +
"    \"featureType\": \"water\"," +
"    \"elementType\": \"labels.text.fill\"," +
"    \"stylers\": [" +
"      {" +
"        \"color\": \"#515c6d\"" +
"      }" +
"    ]" +
"  }," +
"  {" +
"    \"featureType\": \"water\"," +
"    \"elementType\": \"labels.text.stroke\"," +
"    \"stylers\": [" +
"      {" +
"        \"lightness\": -20" +
"      }" +
"    ]" +
"  }" +
"]"
