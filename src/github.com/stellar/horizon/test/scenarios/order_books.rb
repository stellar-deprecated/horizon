require 'factory_girl'
FactoryGirl.find_definitions

use_manual_close

account :usd_gateway, FactoryGirl.create(:usd_gateway_key_pair)
account :scott,       FactoryGirl.create(:scott_key_pair)
account :andrew,      FactoryGirl.create(:andrew_key_pair)

create_account :usd_gateway
create_account :scott
create_account :andrew

close_ledger

trust :scott,  :usd_gateway, "USD"
trust :andrew, :usd_gateway, "USD"

trust :scott,  :usd_gateway, "BTC"
trust :andrew, :usd_gateway, "BTC"

close_ledger

payment :usd_gateway, :scott,   ["USD", :usd_gateway, 5000]
payment :usd_gateway, :andrew,  ["USD", :usd_gateway, 5000]

payment :usd_gateway, :scott,   ["BTC", :usd_gateway, 5000]
payment :usd_gateway, :andrew,  ["BTC", :usd_gateway, 5000]

close_ledger

offer :scott, {buy:["USD", :usd_gateway], with: :native}, 10, 10.0
offer :scott, {buy:["USD", :usd_gateway], with: :native}, 100, 9.0
offer :scott, {buy:["USD", :usd_gateway], with: :native}, 1000, 5.0

offer :andrew, {sell:["USD", :usd_gateway], for: :native}, 10, 15.0
offer :andrew, {sell:["USD", :usd_gateway], for: :native}, 100, 20.0
offer :andrew, {sell:["USD", :usd_gateway], for: :native}, 1000, 50.0

close_ledger

offer :scott, {buy:["USD", :usd_gateway], with: ["BTC", :usd_gateway]}, 10, 10.0
offer :scott, {buy:["USD", :usd_gateway], with: ["BTC", :usd_gateway]}, 100, 9.0
offer :scott, {buy:["USD", :usd_gateway], with: ["BTC", :usd_gateway]}, 1000, 5.0

offer :andrew, {sell:["USD", :usd_gateway], for: ["BTC", :usd_gateway]}, 10, 15.0
offer :andrew, {sell:["USD", :usd_gateway], for: ["BTC", :usd_gateway]}, 100, 20.0
offer :andrew, {sell:["USD", :usd_gateway], for: ["BTC", :usd_gateway]}, 1000, 50.0
