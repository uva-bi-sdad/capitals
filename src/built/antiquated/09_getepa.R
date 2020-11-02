library(readr)


ia_violations = read_csv("Rivanna file path")
or_violations = read_csv("Rivanna file path")
va_violations = read_csv("Rivanna file path")

ia_violations$STATEFP = "19"
or_violations$STATEFP = "41"
va_violations$STATEFP = "51"

# Not sure what I was going to do with water systems that serve multiple counties
# I considered just separating those systems into rows with equal populationServed sizes 