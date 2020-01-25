// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


extension Coordinate : Equatable {}
func ==(lhs: Coordinate, rhs: Coordinate) -> Bool
{
	guard lhs.latitude == rhs.latitude else { return false }
	guard lhs.longitude == rhs.longitude else { return false }
	guard lhs.description == rhs.description else { return false }
	return true
}

extension Current : Equatable {}
func ==(lhs: Current, rhs: Current) -> Bool
{
	guard lhs.currentTime == rhs.currentTime else { return false }
	guard lhs.temperature == rhs.temperature else { return false }
	guard lhs.humidity == rhs.humidity else { return false }
	guard lhs.precipProbability == rhs.precipProbability else { return false }
	guard lhs.summary == rhs.summary else { return false }
	return true
}

extension CurrentImage : Equatable {}
func ==(lhs: CurrentImage, rhs: CurrentImage) -> Bool
{
	guard lhs.icon == rhs.icon else { return false }
	return true
}

