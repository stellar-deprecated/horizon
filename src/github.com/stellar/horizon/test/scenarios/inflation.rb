run_recipe File.dirname(__FILE__) + "/_common_accounts.rb"

use_manual_close

create_account :scott,  :master, 2_000_000_000

close_ledger

set_inflation_dest :master, :master
set_inflation_dest :scott, :scott
inflation
