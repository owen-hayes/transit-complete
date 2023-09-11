# Transit Express 

Transit Express is a fork of [richwolf/Transit](https://github.com/richwolf/transit), that strives to be the Swiftiest way to interact with a GTFS static dataset feed.
Consider it as a n-ish side project; therefore, support can't be provided and this project will evolve according to my needs.

## Introduction

The [General Transit Feed Specification](https://developers.google.com/transit/gtfs), or GTFS, is a dataset specification that enables a transit agency to describe a transit system to developers. More formally, GTFS is actually comprised of two data specifications: the **GTFS Static Specification** and the **GTFS Real-Time Specification**. The GTFS Static Specification describes those features of a transit system that remain reasonably static (i.e., transit routes, stops, schedules, etc.). 

## Installing Transit Express

Transit Express is distributed as a [Swift package](https://developer.apple.com/documentation/swift_packages). There are many online tutorials which describe how packages can be installed in an Xcode project.

## Usage Example

To use Transit Express, simply instantiate a `Feed` with the contents of a folder containing GTFS datasets. You can then ask the feed for agency, route, and stop data.

```swift
// Create a feed
let feedURL = URL(fileURLWithPath: "path-to-folder-containing-GTFS-datasets"!)
let feed = Feed(contentsOfURL: feedURL)

// Get the agency name from the feed
if let agencyName = feed.agency?.name {
	print(agencyName)
}

// Print info for every route in the feed
if let routes = feed.routes {
	for route in routes {
		print(route)
	}
}

// Print info for every stop in the feed
if let stops = feed.stops {
	for stop in stops {
		print(stop)
	}
}
```

## Documentation

Transit Express has embraced Apple’s [DocC](https://developer.apple.com/documentation/docc) documentation compiler. DocC makes it simple to add documentation for a project. Please refer to the documentation included within the Transit Express package for details on Transit Express use or for help.
