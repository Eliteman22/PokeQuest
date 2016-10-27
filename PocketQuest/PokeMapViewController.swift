//
//  PokeMapViewController.swift
//  Pods
//
//  Created by Flavio Lici on 7/19/16.
//
//

import UIKit
import Mapbox
import MapKit
import CoreLocation
import AudioToolbox
import Firebase
import Parse



extension PokeMapViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

class PokeMapViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate, MGLMapViewDelegate {
    
    let locationManager = CLLocationManager()
    
    var mapView: MGLMapView!
    
    let ref = FIRDatabase.database().reference()
    
    @IBOutlet weak var points: UILabel!
    
    @IBOutlet weak var map: UIView!
    
    @IBOutlet weak var pokemonPicture: UIImageView!
    
    @IBOutlet weak var nameOfPokemon: UILabel!
    
    @IBOutlet weak var methodOfSpot: UIImageView!

    @IBOutlet weak var displayPokemon: UIView!
    
    @IBOutlet weak var method: UILabel!
    
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var timePosted: UILabel!
    
    
    @IBOutlet weak var messageButton: UIButton!
    
    @IBOutlet weak var postButton: UIButton!
    
    @IBOutlet weak var locationView: UIImageView!
    
    @IBOutlet weak var selectLocation: UIView!
    
    @IBOutlet weak var cancelLocation: UIButton!
    
    @IBOutlet weak var locationText: UILabel!
    
    @IBOutlet weak var selectPokemonView: UIView!
    
    @IBOutlet weak var selectPokemonBox: UIImageView!
    
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet weak var blackout: UIView!
    
    
    @IBOutlet weak var shoesImage: UIImageView!
    
    
    var pokeballType: String!
    
    var pokeBall: [String]!
    var greatBall: [String]!
    var ultraBall: [String]!
    var masterBall: [String]!
    
    @IBOutlet weak var backButton: UIButton!
    
    var pokeList: [Pokemon]!
    @IBOutlet weak var pokeTable: UITableView!
    
    var selectedPokemon: String!
    
    var counter = 0
    var timer : NSTimer?
    
    var lat: String!
    var lon: String!
    
    var uilpgr: UILongPressGestureRecognizer!
    
    var currentLocation: CLLocationCoordinate2D!
    
    @IBOutlet weak var pokePic: UIImageView!
    
    @IBOutlet weak var distanceFromPokemon: UILabel!
    
    var pokemonViewOpen: Bool!

    
   //SEARCH FUNCTIONALITY//
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var filteredPokemon = [Pokemon]()
    
    
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredPokemon = pokeList.filter { candy in
            return candy.name.lowercaseString.containsString(searchText.lowercaseString)
        }
        
        pokeTable.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredPokemon.count
        }
        return pokeList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! PokeFilterTableViewCell
        let pokemon: Pokemon
        if searchController.active && searchController.searchBar.text != "" {
            pokemon = filteredPokemon[indexPath.row]
        } else {
            pokemon = pokeList[indexPath.row]
        }
        cell.pokemonName.text = pokemon.name
        cell.pokemonPicture.image = UIImage(named: "\(pokemon.name)")
        return cell
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        print(indexPath.row)
        if searchController.active {
            selectedPokemon = pokeList[indexPath.row].name as! String
        } else {
            selectedPokemon = pokeList[indexPath.row].name as! String
        }
 
        print(selectedPokemon)
        
        UIView.animateWithDuration(0.5, animations: {
            self.confirmButton.alpha = 1
            self.confirmButton.enabled = true
        })
        
        
        
        return indexPath
    }
    
    
    //////////////////////
    
    @IBAction func confirmFind(sender: UIButton) {
        
        if pokeBall.contains(selectedPokemon) {
            pokeballType = "Pokeball"
        } else if greatBall.contains(selectedPokemon) {
            pokeballType = "Greatball"
        } else if ultraBall.contains(selectedPokemon) {
            pokeballType = "Ultraball"
        } else {
            pokeballType = "Masterball"
        }
        
        ref.child("SpottedPokemon").childByAutoId().setValue(["Pokemon": selectedPokemon, "lat": lat, "lon": lon, "pokeballType": pokeballType])
        
        self.backButton.alpha = 0
        self.selectPokemonView.alpha = 0
        self.selectPokemonBox.alpha = 0
        self.pokeTable.alpha = 0
        self.view.sendSubviewToBack(self.pokeTable)
        confirmButton.enabled = false
        confirmButton.alpha = 0
        
        
        
        self.searchButton.alpha = 1
        self.searchButton.enabled = true
        self.messageButton.alpha = 1
        self.messageButton.enabled = true
        self.postButton.alpha = 1
        self.postButton.enabled = true
        
    }
    
    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
        
        var annotationImage = mapView.dequeueReusableAnnotationImageWithIdentifier("Pokeball")
        
        if annotationImage == nil && annotation.title! != nil {
            
            var pokemonName = annotation.title!
            
            print(pokemonName!)
            
            var image: UIImage!
            
            if pokeBall.contains(pokemonName!) {
                print("pokeball")
                image = UIImage(named: "pokeballSmall")!
                
                image = image.imageWithAlignmentRectInsets(UIEdgeInsetsMake(0, 0, image.size.height/2, 0))
                annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "pokeball")
                
            } else if greatBall.contains(pokemonName!) {
                print("great")
                image = UIImage(named: "GreatballSmall")
                
                image = image.imageWithAlignmentRectInsets(UIEdgeInsetsMake(0, 0, image.size.height/2, 0))
                annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "greatball")
                
            } else if ultraBall.contains(pokemonName!) {
                image = UIImage(named: "UltraballSmall")
                print("ultra")
                
                image = image.imageWithAlignmentRectInsets(UIEdgeInsetsMake(0, 0, image.size.height/2, 0))
                annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "ultraball")
                
            } else if masterBall.contains(pokemonName!) {
                image = UIImage(named: "MasterballSmall")
                
                
                image = image.imageWithAlignmentRectInsets(UIEdgeInsetsMake(0, 0, image.size.height/2, 0))
                annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "masterball")
            }
            
            
            
            
            
        } else {
          
        }
        
        return annotationImage
    }
    @IBOutlet weak var grayBox: UIView!
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        print("tapped")
    
        pokePic.alpha = 1
        
        self.view.bringSubviewToFront(pokePic)
        
        var currentLocationMeasure = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        
        var pokemonCoordinate = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        
        var distance = currentLocationMeasure.distanceFromLocation(pokemonCoordinate)
        
        grayBox.layer.cornerRadius = 10
        
        pokemonViewOpen = true
        
        UIView.animateWithDuration(0.5, animations: {
            self.postButton.alpha = 0
            self.postButton.enabled = false
            
            self.blackout.alpha = 0.4
            
            self.displayPokemon.alpha = 1
            self.displayPokemon.userInteractionEnabled = true
        })
        
        
        
        if distance < 500 {
            
            distanceFromPokemon.text = ""
            
            var pokemonName = annotation.title!
            nameOfPokemon.text = pokemonName
     
            pokePic.image = UIImage(named: "\(pokemonName!)")
            methodOfSpot.image = UIImage(named: "TrainerHat")
            method.text = "Pokemon Trainer"
        } else {

            nameOfPokemon.text = "?????"
            shoesImage.alpha = 1
            
            var pokemonName = annotation.title!
            
            var distanceToPost = Int(distance)
            
            if distanceToPost > 1000 {
                var distanceNew = distanceToPost / 1000
                distanceFromPokemon.text = "\(distanceNew)km away"
            } else {
                distanceFromPokemon.text = "\(distanceToPost)m away"
            }
            
            
            
            if pokeBall.contains(pokemonName!) {
                pokeballType = "pokeballSmall"
            } else if greatBall.contains(pokemonName!) {
                pokeballType = "GreatballSmall"
            } else if ultraBall.contains(pokemonName!) {
                pokeballType = "UltraballSmall"
            } else if masterBall.contains(pokemonName!) {
                pokeballType = "MasterballSmall"
            }
            method.text = "Pokemon Trainer"
            print(pokeballType)
            pokePic.image = UIImage(named: "\(pokeballType)")
            
        }
        
        print(distance)
        return false
    }
    
    //Custom Callout//
    
    
    func mapView(mapView: MGLMapView, calloutViewForAnnotation annotation: MGLAnnotation) -> UIView? {
        // Only show callouts for `Hello world!` annotation
        if annotation.respondsToSelector(Selector("title")) {
            // Instantiate and return our custom callout view
            return CustomCalloutView(representedObject: annotation)
        }
        return nil
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            
            if pokemonViewOpen == true {
                pokemonViewOpen = false
                
                UIView.animateWithDuration(0.5, animations: {
                    self.postButton.alpha = 1
                    self.postButton.enabled = true
                    
                    self.blackout.alpha = 0
                    
                    self.displayPokemon.alpha = 0
                    self.displayPokemon.userInteractionEnabled = false
                    self.shoesImage.alpha = 0
                })
                
            }
        }
    }
    
    func mapView(mapView: MGLMapView, tapOnCalloutForAnnotation annotation: MGLAnnotation) {
        // Optionally handle taps on the callout
        print("Tapped the callout for: \(annotation)")
        
        // Hide the callout
        mapView.deselectAnnotation(annotation, animated: true)
    }
    
    @IBAction func recenterView(sender: UIButton) {
        mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: currentLocation.latitude,
            longitude: currentLocation.longitude),
                                    zoomLevel: 14, animated: true)
        
    }
    
    /////////////////
    
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let testObject = PFObject(className: "TestObject")
        testObject["foo"] = "bar"
        testObject.saveInBackgroundWithBlock { (success, error) -> Void in
            print("Object has been saved.")
            if error != nil {
                print(error)
            }
        }
        
        
        // Post Pokestops//
        
        ///////////////////
        
        
        shoesImage.alpha = 0
        
        pokemonViewOpen = false
        
        blackout.alpha = 0
        displayPokemon.layer.cornerRadius = 10
        displayPokemon.alpha = 0
        displayPokemon.userInteractionEnabled = false
        
        confirmButton.alpha = 0
        confirmButton.enabled = false
        
        pokeTable.delegate = self
        pokeTable.dataSource = self
        
        
        
        
        // Poke Balls For Each Pokemon //
        //notHIghlighted
        pokeBall = ["Caterpie", "Metapod", "Weedle", "Kakuna", "Pidgey", "Rattata",  "Spearow", "Ekans", "Sandshrew", "Nidoran♀", "Nidoran♂", "Clefairy", "Zubat", "Oddish", "Paras", "Venonat", "Diglett", "Psyduck", "Mankey", "Poliwag", "Abra", "Machop", "Bellsprout", "Tentacool", "Geodude", "Pontya", "Slowpoke", "Magnemite", "Doduo", "Seel", "Shellder", "Gastly", "Drowzee", "Krabby", "Voltorb", "Exeggcute", "Cubone", "Koffing", "Horsea", "Goldeen", "Staryu", "Jynx", "Magikarp", "Eevee"]
        
        //Yellow
        greatBall = ["Bulbasaur", "Charmander", "Squirtle", "Butterfree", "Beedrill", "Pidgeotto", "Raticate", "Fearow", "Arbok", "Pikachu", "Nidorina", "Nidorino", "Vulpix", "Jigglypuff", "Golbat", "Gloom", "Venomoth", "Meowth", "Persian", "Growlithe", "Poliwhirl", "Kadabra", "Machoke", "Weepinbell", "Graveler", "Slowbro", "Magneton", "Farfetch'd", "Dewgong", "Grimer", "Haunter", "Onix", "Hypno", "Kingler", "Electrode", "Exeggcutor", "Lickitung", "Rhyhorn", "Chansey", "Tangela", "Seaking", "Starmie", "Scyther", "Electabuzz", "Magmar", "Pinsir", "Tauros", "Porygon", "Omanyte", "Kabuto", "Aerodactyl", "Dratini", "Dragonair"]
        
            
        //Red
        ultraBall = ["Ivysaur", "Venusaur", "Charmeleon", "Charizard", "Wartortle", "Blastoise", "Pidgeot", "Raichu", "Sandslash", "Nidoking", "Nidoqueen", "Clefable", "Ninetales", "Wigglytuff", "Vileplume", "Parasect", "Dugtrio", "Golduck", "Primeape", "Arcanine", "Poliwrath", "Alakazam", "Machamp", "Victreebel", "Tentacruel", "Golem", "Rapidash", "Dodrio", "Muk", "Cloyster", "Gengar", "Marowak", "Hitmonlee", "Hitmonchan", "Weezing", "Rhydon", "Kangaskhan", "Seadra", "Mr. Mime", "Gyarados", "Lapras", "Ditto", "Vaporeon", "Jolteon", "Flareon", "Omastar", "Kabutops", "Snorlax", "Dragonite"]
            
        //Green
        masterBall = ["Articuno", "Zapdos", "Moltres", "Mewtwo", "Mew"]
        
        /////////////////////////////////
        
        
        // Post Stuff to map //
        
        ref.child("SpottedPokemon").observeEventType(.ChildAdded, withBlock: {
            (snapshot) in
            
            let pokemonName = snapshot.value?.objectForKey("Pokemon") as? String
            let preLat = snapshot.value?.objectForKey("lat") as? NSString
            let preLon = snapshot.value?.objectForKey("lon") as? NSString
            let type = snapshot.value?.objectForKey("pokeballType") as? String
            
            
            var lat = preLat?.doubleValue
            var lon = preLon?.doubleValue
            
            var coord = CLLocationCoordinate2D(latitude: lat!, longitude: lon!)
            
            
            var newAnnotation: MGLPointAnnotation = MGLPointAnnotation()
            newAnnotation.coordinate = coord
            newAnnotation.title = pokemonName
            
            
            self.mapView.addAnnotation(newAnnotation)
            
            
        })
        

        
        //////////////////////
        
        
        
        
        pokeList = [Pokemon(name: "Abra", image: UIImage(named: "Abra")!),
                    Pokemon(name: "Alakazam", image: UIImage(named: "Alakazam")!), Pokemon(name: "Aerodactyl", image: UIImage(named: "Aerodactyl")!),
                    Pokemon(name: "Arbok", image: UIImage(named: "Arbok")!),
                    Pokemon(name: "Arcanine", image: UIImage(named: "Arcanine")!),
                    Pokemon(name: "Articuno", image: UIImage(named: "Articuno")!),
                    Pokemon(name: "Beedrill", image: UIImage(named: "Beedrill")!),
                    Pokemon(name: "Bellsprout", image: UIImage(named: "Bellsprout")!),
                    Pokemon(name: "Blastoise", image: UIImage(named: "Blastoise")!),
                    Pokemon(name: "Bulbasaur", image: UIImage(named: "Bulbasaur")!),
                    Pokemon(name: "Butterfree", image: UIImage(named: "Butterfree")!),
                    Pokemon(name: "Caterpie", image: UIImage(named: "Caterpie")!),
                    Pokemon(name: "Chansey", image: UIImage(named: "Chansey")!),
                    Pokemon(name: "Charizard", image: UIImage(named: "Charizard")!),
                    Pokemon(name: "Charmander", image: UIImage(named: "Charmander")!),
                    Pokemon(name: "Charmeleon", image: UIImage(named: "Charmeleon")!),
                    Pokemon(name: "Clefable", image: UIImage(named: "Clefable")!),
                    Pokemon(name: "Clefairy", image: UIImage(named: "Clefairy")!),
                    Pokemon(name: "Cloyster", image: UIImage(named: "Cloyster")!),
                    Pokemon(name: "Cubone", image: UIImage(named: "Cubone")!),
                    Pokemon(name: "Dewgong", image: UIImage(named: "Dewgong")!),
                    Pokemon(name: "Diglett", image: UIImage(named: "Diglett")!),
                    Pokemon(name: "Ditto", image: UIImage(named: "Ditto")!),
                    Pokemon(name: "Dodrio", image: UIImage(named: "Dodrio")!),
                    Pokemon(name: "Doduo", image: UIImage(named: "Doduo")!),
                    Pokemon(name: "Dragonair", image: UIImage(named: "Dragonair")!),
                    Pokemon(name: "Dragonite", image: UIImage(named: "Dragonite")!),
                    Pokemon(name: "Dratini", image: UIImage(named: "Dratini")!),
                    Pokemon(name: "Drowzee", image: UIImage(named: "Drowzee")!),
                    Pokemon(name: "Dugtrio", image: UIImage(named: "Dugtrio")!),
                    Pokemon(name: "Eevee", image: UIImage(named: "Eevee")!),
                    Pokemon(name: "Ekans", image: UIImage(named: "Ekans")!),
                    Pokemon(name: "Electabuzz", image: UIImage(named: "Electabuzz")!),
                    Pokemon(name: "Electrode", image: UIImage(named: "Electrode")!),
                    Pokemon(name: "Exeggcute", image: UIImage(named: "Exeggcute")!),
                    Pokemon(name: "Exeggutor", image: UIImage(named: "Exeggutor")!),
                    Pokemon(name: "Farfetch'd", image: UIImage(named: "Farfetch'd")!),
                    Pokemon(name: "Fearow", image: UIImage(named: "Fearow")!),
                    Pokemon(name: "Flareon", image: UIImage(named: "Flareon")!),
                    Pokemon(name: "Gastly", image: UIImage(named: "Gastly")!),
                    Pokemon(name: "Gengar", image: UIImage(named: "Gengar")!),
                    Pokemon(name: "Geodude", image: UIImage(named: "Geodude")!),
                    Pokemon(name: "Gloom", image: UIImage(named: "Gloom")!),
                    Pokemon(name: "Golbat", image: UIImage(named: "Golbat")!),
                    Pokemon(name: "Goldeen", image: UIImage(named: "Goldeen")!),
                    Pokemon(name: "Golduck", image: UIImage(named: "Golduck")!),
                    Pokemon(name: "Golem", image: UIImage(named: "Golem")!),
                    Pokemon(name: "Graveler", image: UIImage(named: "Graveler")!),
                    Pokemon(name: "Grimer", image: UIImage(named: "Grimer")!),
                    Pokemon(name: "Growlithe", image: UIImage(named: "Growlithe")!),
                    Pokemon(name: "Gyarados", image: UIImage(named: "Gyarados")!),
                    Pokemon(name: "Haunter", image: UIImage(named: "Haunter")!),
                    Pokemon(name: "Hitmonchan", image: UIImage(named: "Hitmonchan")!),
                    Pokemon(name: "Hitmonlee", image: UIImage(named: "Hitmonlee")!),
                    Pokemon(name: "Horsea", image: UIImage(named: "Horsea")!),
                    Pokemon(name: "Hypno", image: UIImage(named: "Hypno")!),
                    Pokemon(name: "Ivysaur", image: UIImage(named: "Ivysaur")!),
                    Pokemon(name: "Jigglypuff", image: UIImage(named: "Jigglypuff")!),
                    Pokemon(name: "Jolteon", image: UIImage(named: "Jolteon")!),
                    Pokemon(name: "Jynx", image: UIImage(named: "Jynx")!),
                    Pokemon(name: "Kabuto", image: UIImage(named: "Kabuto")!),
                    Pokemon(name: "Kabutops", image: UIImage(named: "Kabutops")!),
                    Pokemon(name: "Kadabra", image: UIImage(named: "Kadabra")!),
                    Pokemon(name: "Kakuna", image: UIImage(named: "Kakuna")!),
                    Pokemon(name: "Kangaskhan", image: UIImage(named: "Kangaskhan")!),
                    Pokemon(name: "Kingler", image: UIImage(named: "Kingler")!),
                    Pokemon(name: "Koffing", image: UIImage(named: "Koffing")!),
                    Pokemon(name: "Krabby", image: UIImage(named: "Krabby")!),
                    Pokemon(name: "Lapras", image: UIImage(named: "Lapras")!),
                    Pokemon(name: "Lickitung", image: UIImage(named: "Lickitung")!),
                    Pokemon(name: "Machamp", image: UIImage(named: "Machamp")!),
                    Pokemon(name: "Machoke", image: UIImage(named: "Machoke")!),
                    Pokemon(name: "Machop", image: UIImage(named: "Machop")!),
                    Pokemon(name: "Magikarp", image: UIImage(named: "Magikarp")!),
                    Pokemon(name: "Magmar", image: UIImage(named: "Magmar")!),
                    Pokemon(name: "Magnemite", image: UIImage(named: "Magnemite")!),
                    Pokemon(name: "Magneton", image: UIImage(named: "Magneton")!),
                    Pokemon(name: "Mankey", image: UIImage(named: "Mankey")!),
                    Pokemon(name: "Marowak", image: UIImage(named: "Marowak")!),
                    Pokemon(name: "Meowth", image: UIImage(named: "Meowth")!),
                    Pokemon(name: "Metapod", image: UIImage(named: "Metapod")!),
                    Pokemon(name: "Mew†", image: UIImage(named: "Mew†")!),
                    Pokemon(name: "Mewtwo", image: UIImage(named: "Mewtwo")!),
                    Pokemon(name: "Moltres", image: UIImage(named: "Moltres")!),
                    Pokemon(name: "Mr. Mime", image: UIImage(named: "Mr. Mime")!),
                    Pokemon(name: "Muk", image: UIImage(named: "Muk")!),
                    Pokemon(name: "Nidoking", image: UIImage(named: "Nidoking")!),
                    Pokemon(name: "Nidoqueen", image: UIImage(named: "Nidoqueen")!),
                    Pokemon(name: "Nidoran♀", image: UIImage(named: "Nidoran♀")!),
                    Pokemon(name: "Nidoran♂", image: UIImage(named: "Nidoran♂")!),
                    Pokemon(name: "Nidorina", image: UIImage(named: "Nidorina")!),
                    Pokemon(name: "Nidorino", image: UIImage(named: "Nidorino")!),
                    Pokemon(name: "Ninetales", image: UIImage(named: "Ninetales")!),
                    Pokemon(name: "Oddish", image: UIImage(named: "Oddish")!),
                    Pokemon(name: "Omanyte", image: UIImage(named: "Omanyte")!),
                    Pokemon(name: "Omastar", image: UIImage(named: "Omastar")!),
                    Pokemon(name: "Onix", image: UIImage(named: "Onix")!),
                    Pokemon(name: "Paras", image: UIImage(named: "Paras")!),
                    Pokemon(name: "Parasect", image: UIImage(named: "Parasect")!),
                    Pokemon(name: "Persian", image: UIImage(named: "Persian")!),
                    Pokemon(name: "Pidgeot", image: UIImage(named: "Pidgeot")!),
                    Pokemon(name: "Pidgeotto", image: UIImage(named: "Pidgeotto")!),
                    Pokemon(name: "Pidgey", image: UIImage(named: "Pidgey")!),
                    Pokemon(name: "Pikachu", image: UIImage(named: "Pikachu")!),
                    Pokemon(name: "Pinsir", image: UIImage(named: "Pinsir")!),
                    Pokemon(name: "Poliwag", image: UIImage(named: "Poliwag")!),
                    Pokemon(name: "Poliwhirl", image: UIImage(named: "Poliwhirl")!),
                    Pokemon(name: "Poliwrath", image: UIImage(named: "Poliwrath")!),
                    Pokemon(name: "Pontya", image: UIImage(named: "Ponyta")!),
                    Pokemon(name: "Porygon", image: UIImage(named: "Porygon")!),
                    Pokemon(name: "Primeape", image: UIImage(named: "Primeape")!),
                    Pokemon(name: "Psyduck", image: UIImage(named: "Psyduck")!),
                    Pokemon(name: "Raichu", image: UIImage(named: "Raichu")!),
                    Pokemon(name: "Rapidash", image: UIImage(named: "Rapidash")!),
                    Pokemon(name: "Raticate", image: UIImage(named: "Raticate")!),
                    Pokemon(name: "Rattata", image: UIImage(named: "Rattata")!),
                    Pokemon(name: "Rhydon", image: UIImage(named: "Rhydon")!),
                    Pokemon(name: "Rhyhorn", image: UIImage(named: "Rhyhorn")!),
                    Pokemon(name: "Sandshrew", image: UIImage(named: "Sandshrew")!),
                    Pokemon(name: "Sandslash", image: UIImage(named: "Sandslash")!),
                    Pokemon(name: "Scyther", image: UIImage(named: "Scyther")!),
                    Pokemon(name: "Seadra", image: UIImage(named: "Seadra")!),
                    Pokemon(name: "Seaking", image: UIImage(named: "Seaking")!),
                    Pokemon(name: "Seel", image: UIImage(named: "Seel")!),
                    Pokemon(name: "Shellder", image: UIImage(named: "Shellder")!),
                    Pokemon(name: "Slowbro", image: UIImage(named: "Slowbro")!),
                    Pokemon(name: "Slowpoke", image: UIImage(named: "Slowpoke")!),
                    Pokemon(name: "Snorlax", image: UIImage(named: "Snorlax")!),
                    Pokemon(name: "Spearow", image: UIImage(named: "Spearow")!),
                    Pokemon(name: "Squirtle", image: UIImage(named: "Squirtle")!),
                    Pokemon(name: "Starmie", image: UIImage(named: "Starmie")!),
                    Pokemon(name: "Staryu", image: UIImage(named: "Staryu")!),
                    Pokemon(name: "Tangela", image: UIImage(named: "Tangela")!),
                    Pokemon(name: "Tauros", image: UIImage(named: "Tauros")!),
                    Pokemon(name: "Tentacool", image: UIImage(named: "Tentacool")!),
                    Pokemon(name: "Tentacruel", image: UIImage(named: "Tentacruel")!),
                    Pokemon(name: "Vaporeon", image: UIImage(named: "Vaporeon")!),
                    Pokemon(name: "Venomoth", image: UIImage(named: "Venomoth")!),
                    Pokemon(name: "Venonat", image: UIImage(named: "Venonat")!),
                    Pokemon(name: "Venusaur", image: UIImage(named: "Venusaur")!),
                    Pokemon(name: "Victreebel", image: UIImage(named: "Victreebel")!),
                    Pokemon(name: "Vileplume", image: UIImage(named: "Vileplume")!),
                    Pokemon(name: "Voltorb", image: UIImage(named: "Voltorb")!),
                    Pokemon(name: "Vulpix", image: UIImage(named: "Vulpix")!),
                    Pokemon(name: "Wartortle", image: UIImage(named: "Wartortle")!),
                    Pokemon(name: "Weedle", image: UIImage(named: "Weedle")!),
                    Pokemon(name: "Weepinbell", image: UIImage(named: "Weepinbell")!),
                    Pokemon(name: "Weezing", image: UIImage(named: "Weezing")!),
                    Pokemon(name: "Wigglytuff", image: UIImage(named: "Wigglytuff")!),
                    Pokemon(name: "Zapdos", image: UIImage(named: "Zapdos")!),
                    Pokemon(name: "Zubat", image: UIImage(named: "Zubat")!)]
        
        
        
        //Search//
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        pokeTable.tableHeaderView = searchController.searchBar
        
        searchController.searchBar.placeholder = "Which Pokemon did you find?..."
        ///////////
        
        
        cancelLocation.layer.zPosition = 1
        backButton.layer.zPosition = 1
     
        selectPokemonView.alpha = 0
        pokeTable.alpha = 0
        pokeTable.layer.zPosition = 1
        selectPokemonView.layer.zPosition = 1
        selectPokemonBox.layer.zPosition = 1
        selectPokemonBox.alpha = 0
       
        

        locationText.layer.zPosition = 1
        locationView.alpha = 0
        self.locationView.layer.zPosition  = 1
        self.selectLocation.layer.zPosition = 1
        selectLocation.alpha = 0
        self.messageButton.layer.zPosition = 1
        self.view.bringSubviewToFront(postButton)
        self.searchButton.layer.zPosition = 1
        self.pokeTable.layer.zPosition = 1
//        let defaults = NSUserDefaults.standardUserDefaults()
//        
//        var pointsVal = defaults.integerForKey("Points") as! Int
//        
//        var faction = defaults.objectForKey("team") as! String
//        
//        if faction == "Instinct" {
//            
//        } else if faction == "Mystic" {
//            
//        } else if faction == "Valor" {
//            
//        }
//        
//        
//        points.text = String(pointsVal)
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }

        let styleURL = NSURL(string: "mapbox://styles/dmbernaal/cirntergw000yg5nlmm0ut8ee")
        
        mapView = MGLMapView(frame: view.bounds,
                             styleURL: styleURL)
        
        mapView.allowsTilting = false
        
        mapView.allowsRotating = false
        
        mapView.showsUserLocation = false
        
        
        mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        
        mapView.showsUserLocation = true
        mapView.compassView.hidden = true
        
        uilpgr = UILongPressGestureRecognizer(target: self, action: "action:")
        uilpgr.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(uilpgr)
        
        uilpgr.enabled = false
        
        pokeTable.reloadData()
    
        map.addSubview(mapView)
        mapView.delegate = self
        
        mapView.bringSubviewToFront(pokeTable)
    }
    
    func vibratePhone() {
        counter++
        switch counter {
        case 1:
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        default:
            timer?.invalidate()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        var locValue:CLLocationCoordinate2D = manager.location!.coordinate
        
        var myLocation = CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude)
        
        self.currentLocation = myLocation
        
        mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: locValue.latitude,
            longitude: locValue.longitude),
                                    zoomLevel: 14, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    

    override func prefersStatusBarHidden() -> Bool {
        return true
    
    }
    
    @IBAction func postPoke(sender: UIButton) {
        searchButton.alpha = 0
        messageButton.alpha = 0
        postButton.alpha = 0
        UIView.animateWithDuration(0.5, animations: {
            self.locationView.alpha = 1
            self.selectLocation.alpha = 1
        })
        
        uilpgr.enabled = true
        
        
    }
    
  
    
    func action(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            print("detected")
            counter = 0
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "vibratePhone", userInfo: nil, repeats: true)
            var touchPoint = gestureRecognizer.locationInView(self.mapView)
            
            print("half")
            
            var newCoordinates = self.mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
            
            var location = CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude)
            var geocoder: CLGeocoder = CLGeocoder()
            
            print("worked")

                
                var newAnnotation: MGLPointAnnotation = MGLPointAnnotation()
            print("1")
                newAnnotation.coordinate = newCoordinates
            
            print(newAnnotation)
                self.mapView!.addAnnotation(newAnnotation)
            print("3")

            
            lat = "\(newCoordinates.latitude)"
            lon = "\(newCoordinates.longitude)"
            uilpgr.enabled = false
            self.locationView.alpha = 0
            self.selectLocation.alpha = 0
            UIView.animateWithDuration( 0.5, animations: {
                self.backButton.alpha = 1
                self.selectPokemonView.alpha = 1
                self.selectPokemonBox.alpha = 1
                self.pokeTable.alpha = 1
              self.view.bringSubviewToFront(self.pokeTable)
                self.mapView.removeAnnotation(newAnnotation)
                
            })
            
                
                
        }
        
    }
    
    
}

class CustomAnnotationView: MGLAnnotationView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Force the annotation view to maintain a constant size when the map is tilted.
        scalesWithViewingDistance = false
        
        // Use CALayer’s corner radius to turn this view into a circle.
        layer.cornerRadius = frame.width / 2
        layer.borderWidth = 2
        layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Animate the border width in/out, creating an iris effect.
        let animation = CABasicAnimation(keyPath: "borderWidth")
        animation.duration = 0.1
        layer.borderWidth = selected ? frame.width / 4 : 2
        layer.addAnimation(animation, forKey: "borderWidth")
    }
}

class CustomCalloutView: UIView, MGLCalloutView {
    var representedObject: MGLAnnotation
    lazy var leftAccessoryView = UIView()/* unused */
    lazy var rightAccessoryView = UIView()/* unused */
    weak var delegate: MGLCalloutViewDelegate?
    
    let tipHeight: CGFloat = 10.0
    let tipWidth: CGFloat = 20.0
    
    let mainBody: UIButton
    
    required init(representedObject: MGLAnnotation) {
        self.representedObject = representedObject
        self.mainBody = UIButton(type: .System)
        
        super.init(frame: CGRectZero)
        
        backgroundColor = UIColor.clearColor()
        
        mainBody.backgroundColor = backgroundColorForCallout()
        mainBody.tintColor = UIColor.whiteColor()
        mainBody.contentEdgeInsets = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)
        mainBody.layer.cornerRadius = 4.0
        
        addSubview(mainBody)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - MGLCalloutView API
    
    func presentCalloutFromRect(rect: CGRect, inView view: UIView, constrainedToView constrainedView: UIView, animated: Bool) {
        if !representedObject.respondsToSelector(Selector("title")) {
            return
        }
        
        view.addSubview(self)
        
        // Prepare title label
        mainBody.setTitle(representedObject.title!, forState: .Normal)
        mainBody.sizeToFit()
        
        if isCalloutTappable() {
            // Handle taps and eventually try to send them to the delegate (usually the map view)
            mainBody.addTarget(self, action: Selector("calloutTapped"), forControlEvents: .TouchUpInside)
        } else {
            // Disable tapping and highlighting
            mainBody.userInteractionEnabled = false
        }
        
        // Prepare our frame, adding extra space at the bottom for the tip
        let frameWidth = mainBody.bounds.size.width
        let frameHeight = mainBody.bounds.size.height + tipHeight
        let frameOriginX = rect.origin.x + (rect.size.width/2.0) - (frameWidth/2.0)
        let frameOriginY = rect.origin.y - frameHeight
        frame = CGRectMake(frameOriginX, frameOriginY, frameWidth, frameHeight)
        
        if animated {
            alpha = 0
            
            UIView.animateWithDuration(0.2) { [weak self] in
                self?.alpha = 1
            }
        }
    }
    
    func dismissCalloutAnimated(animated: Bool) {
        if (superview != nil) {
            if animated {
                UIView.animateWithDuration(0.2, animations: { [weak self] in
                    self?.alpha = 0
                    }, completion: { [weak self] _ in
                        self?.removeFromSuperview()
                    })
            } else {
                removeFromSuperview()
            }
        }
    }
    
    // MARK: - Callout interaction handlers
    
    func isCalloutTappable() -> Bool {
        if let delegate = delegate {
            if delegate.respondsToSelector(Selector("calloutViewShouldHighlight:")) {
                return delegate.calloutViewShouldHighlight!(self)
            }
        }
        return false
    }
    
    func calloutTapped() {
        if isCalloutTappable() && delegate!.respondsToSelector(Selector("calloutViewTapped:")) {
            delegate!.calloutViewTapped!(self)
            
        }
    }
    
    // MARK: - Custom view styling
    
    func backgroundColorForCallout() -> UIColor {
        return UIColor.darkGrayColor()
    }
    
    override func drawRect(rect: CGRect) {
        // Draw the pointed tip at the bottom
        let fillColor = backgroundColorForCallout()
        
        let tipLeft = rect.origin.x + (rect.size.width / 2.0) - (tipWidth / 2.0)
        let tipBottom = CGPointMake(rect.origin.x + (rect.size.width / 2.0), rect.origin.y + rect.size.height)
        let heightWithoutTip = rect.size.height - tipHeight
        
        let currentContext = UIGraphicsGetCurrentContext()!
        
        let tipPath = CGPathCreateMutable()
        CGPathMoveToPoint(tipPath, nil, tipLeft, heightWithoutTip)
        CGPathAddLineToPoint(tipPath, nil, tipBottom.x, tipBottom.y)
        CGPathAddLineToPoint(tipPath, nil, tipLeft + tipWidth, heightWithoutTip)
        CGPathCloseSubpath(tipPath)
        
        fillColor.setFill()
        CGContextAddPath(currentContext, tipPath)
        CGContextFillPath(currentContext)
    }
}
