# Trip Planner - Code Challenge

## Specs

Write an app that helps users select the most convenient route between our destinations.

1. Download and parse information from: https://raw.githubusercontent.com/TuiMobilityHub/ios-code-challenge/master/connections.json The JSON contains a list of flight connections with the relative price and position.
2. The user should be able to select any departure city and any destination city available (even if a direct connection between the two cities is not available)
3. The purpose of this app is to find the cheapest route between the two cities that the user select and to show the total price in a label in the same page
4. Use coordinates available in the JSON to show the cheapest selected route on a map
5. BONUS: To select the cities use a text field with autocomplete (from the list of the available cities you get from the JSON)

## Instructions:

- Write the app thinking about code reusability and SOLID principles
- Don’t pay too much attention to UI/UX, use standard UI elements instead.
- Code in Swift 4.
- Use iOS SDK version of your choice.
- Don’t use any 3rd party tools/frameworks.
- Return Xcode 10(+) project, zipped and few words about your code.
- Do Test-driven Development and write meaningful unit tests
- Please note that we have different datasets for testing and we expect that your app still works with different cities and/or prices

# Solution Overview

## Summary

The solution to this is the weighted shortest distance problem if you substitute distance for price. There are well-know solutions to this problem
which include:
1) Bellman Ford algorithm (which is what I chose, as it can handle negative weights
2) Djisktra

Airports are the nodes, connections are the edges. Each edge has a cost associated with it and the aim would be to get from one airport to the final destination airport at the minimum total cost.

I first created a playground to test using Bellman Ford. You will find a APIPlayground Loader for the playground in the api.swift file.

In the api.swift file you will find the declaration of Services which can contain an api.
Currently this api can be fullfilled via 3 concrete implementations that implement the *IGetTrips* protocol:
1) APINetwork (this uses the above endpoint to fetch the raw data)
2) APIBundle for loading one of the 3 supplied ??.json files located in /SampleData
3) APIPlayground should one want to use it in a play ground

The /Algorithms/Strategy class  is a facade intended to grow into a property strategy generator that could use/choose best algorithm based on constraints.
e.g For extremely large data sets the Djikstra algorithm would be faster

My biggest challenges were in implementing the /View/ACTextField set of classes as I did not like the inline autocompletion as one would have to know or guess the data.
So I decided to implement a UITextField that would use a scrollable drop down UITableView which gets populated with the list of airports/cities to choose from.
What I did as a kludge, is that if you clear/empty the field and simply press the <return> key it will list all available destinations, which one can click to select

Once you click on the [CALC] button it will calculate the cheapast price and display it in a UILabel. (0.0 displayed for unreachable routes)

Having calculated the cheaptest cost , by definition I now have vertexArray that contains all the edges travelled, which I then use to plot a geodesic overlays for the route travelled.

### Known bugs

The map geodesic route is correct, but I don't think I ended it off properly. Guess I'm a little rusty and just need to brush up a little.


## Installation

Download the repo and load it as a local directory.
Open the TripPlanner.xcodeproj file with XCode

## Example

.

## REVIEW

### Good:

• Nice autocomplete labels
• Cost calculation seems to be working fine
• Using decodable
• Able to fetch destinations either via URLRequest or json file

### Not so good:

• Not so good architecture (Route calculation in the ViewController)
• A lot of methods declared as public / open?
• Map coordinates is not working properly
• Theme is a nice touch but not uniform and dynamic (Any view can pick any theme it wants, should exists a currentTheme var somewhere)
• Autocomplete shows cities that are not in the list
• Unnecessary or unrelated code in the project

## Enhancements

Pressing <return> on empty field to get drop down list of trips - needs to be more intuitive

## License

TripPlanner is available voetstoots - as-is.
