#require './app'


app = ->(call) { [200, {}, ["hi"]]}
run app
