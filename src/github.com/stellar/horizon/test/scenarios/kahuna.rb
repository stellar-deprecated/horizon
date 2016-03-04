# This is the big kahuna test scenario.  It aims to comprehensively use
# stellar's features, exercising each feature and option at least once.
#
# As new features are added to stellar, this scenario will get updated to
# exercise those new features.  This scenario is used during the horizon
# ingestion tests.
#
use_manual_close
KP = Stellar::KeyPair
close_ledger #2

## Transaction exercises

# time bounds
  # Secret seed: SBQGG7PY4JZQT6F2MBXDDI4VNDKZYG2Y5TJLKNG7AG6ETNNTJT6MCBOF
  # Public: GAXI33UCLQTCKM2NMRBS7XYBR535LLEVAHL5YBN4FTCB4HZHT7ZA5CVK
  account :time_bounds, KP.from_seed("SBQGG7PY4JZQT6F2MBXDDI4VNDKZYG2Y5TJLKNG7AG6ETNNTJT6MCBOF")
  create_account :time_bounds do |env|
    env.tx.time_bounds = Stellar::TimeBounds.new(min_time: 100, max_time: Time.parse("2020-01-01").to_i)
    env.signatures = [env.tx.sign_decorated(get_account :master)]
  end

  close_ledger #3

# multisig
  # Secret seed: SCUNXR4FVJGNH4CZBA5K3IIK264WBH7FURTLDMOT3FGWNZKOZCPBW3GS
  # Public: GDXFAGJCSCI4CK2YHK6YRLA6TKEXFRX7BMGVMQOBMLIEUJRJ5YQNLMIB
  account :multisig, KP.from_seed("SCUNXR4FVJGNH4CZBA5K3IIK264WBH7FURTLDMOT3FGWNZKOZCPBW3GS")
  # Secret seed: SBYRIKN5UMKMLVMVJOV2TC2FI3VIU572W4V5KIKR7EDNNORPBIW2RO3I
  # Public: GD3E7HKMRNT6HGBGHBT6I6JE4N2S4W5KZ246TGJ4KQSXJ2P4BXCUPQMP
  multisig_2 = KP.from_seed("SBYRIKN5UMKMLVMVJOV2TC2FI3VIU572W4V5KIKR7EDNNORPBIW2RO3I")

  create_account :multisig
  close_ledger #4

  set_master_signer_weight :multisig, 1
  add_signer :multisig, multisig_2, 1
  set_thresholds :multisig, low: 2, medium: 2, high: 2

  close_ledger #5

  set_master_signer_weight :multisig, 2 do |env|
    env.signatures << env.tx.sign_decorated(multisig_2)
  end

  close_ledger #6

# memo
  # Secret seed: SACUGRIIBI3WTZTVYZNS7KM4JSJQJKUE2AQ4GDE3MEZRAT5QEJ76YWFE
  # Public: GA46VRKBCLI2X6DXLX7AIEVRFLH3UA7XBE3NGNP6O74HQ5LXHMGTV2JB
  account :memo, KP.from_seed("SACUGRIIBI3WTZTVYZNS7KM4JSJQJKUE2AQ4GDE3MEZRAT5QEJ76YWFE")
  create_account :memo
  close_ledger #7

  payment :memo, :master, [:native, "1.0"], memo: [:id, 123]
  payment :memo, :master, [:native, "1.0"], memo: [:text, "hello"]
  payment :memo, :master, [:native, "1.0"], memo: [:hash, "\x01" * 32]
  payment :memo, :master, [:native, "1.0"], memo: [:return, "\x02" * 32]
  close_ledger #8

# multiop
  # Secret seed: SD7MLW2LH2PJOU5ZS2AVOZ5OWTH47MXYHOY6JSTNJU4RORU5RLNUTM7V
  # Public: GAG52TW6QAB6TGNMOTL32Y4M3UQQLNNNHPEHYAIYRP6SFF6ZAVRF5ZQY
  account :multiop, KP.from_seed("SD7MLW2LH2PJOU5ZS2AVOZ5OWTH47MXYHOY6JSTNJU4RORU5RLNUTM7V")
  create_account :multiop
  close_ledger #9

  payment :multiop, :master,  [:native, "10.00"] do |env|
    env.tx.operations = env.tx.operations * 2
    env.tx.fee = 200
    env.signatures = [env.tx.sign_decorated(get_account :multiop)]
  end

  close_ledger #10

## Operation exercises

# create account
  # Secret seed: SDM2YMHCCJWEOSDA26XV7OAKP4DPS5MZXBM7RHUR5N7XMKVDOMCQDINF
  # Public: GDCVTBGSEEU7KLXUMHMSXBALXJ2T4I2KOPXW2S5TRLKDRIAXD5UDHAYO
  account :first_create, KP.from_seed("SDM2YMHCCJWEOSDA26XV7OAKP4DPS5MZXBM7RHUR5N7XMKVDOMCQDINF")
  # Secret seed: SCHWJBPUXWXYXQ5GCTDSGZUQWNRX7IO5DDD3ULPTR5JQPK6AG7YOKMFF
  # Public: GCB7FPYGLL6RJ37HKRAYW5TAWMFBGGFGM4IM6ERBCZXI2BZ4OOOX2UAY
  account :second_create, KP.from_seed("SCHWJBPUXWXYXQ5GCTDSGZUQWNRX7IO5DDD3ULPTR5JQPK6AG7YOKMFF")

  # default create from root account
  create_account :first_create
  close_ledger #11

  # create with custom starting balance
  create_account :second_create, :first_create, "50.00"

  close_ledger #12

# payment
  # Secret seed: SCYYD7ZVS4UNOOIEQA2W77ZEXLOVTGQXA3Z6WCP3KD7YLMT3GFTTTMMO
  # Public: GCHC4D2CS45CJRNN4QAHT2LFZAJIU5PA7H53K3VOP6WEJ6XWHNSNZKQG
  account :payer, KP.from_seed("SCYYD7ZVS4UNOOIEQA2W77ZEXLOVTGQXA3Z6WCP3KD7YLMT3GFTTTMMO")
  # Secret seed: SAZRXWWS6BZ5G7TTW22CXDPJQC2PHYVDBQJBDADS4MHN4NRJQYPW7JFU
  # Public: GANZGPKY5WSHWG5YOZMNG52GCK5SCJ4YGUWMJJVGZSK2FP4BI2JIJN2C
  account :payee, KP.from_seed("SAZRXWWS6BZ5G7TTW22CXDPJQC2PHYVDBQJBDADS4MHN4NRJQYPW7JFU")

  create_account :payer
  create_account :payee
  close_ledger #13

  # native payment
  payment :payer, :payee,  [:native, "10.00"]

  # non-native payment
  trust :payee, :payer, "USD"
  close_ledger #14
  payment :payer, :payee,  ["USD", :payer, "10.00"]

  close_ledger #15

# path payment

  # Secret seed: SBVM6Q7LG23HQGK6P56RY4UMI24DB6DSYPH6QSBUMD7FM3YOAO4JTZOE
  # Public: GDRW375MAYR46ODGF2WGANQC2RRZL7O246DYHHCGWTV2RE7IHE2QUQLD
  account :path_payer, KP.from_seed("SBVM6Q7LG23HQGK6P56RY4UMI24DB6DSYPH6QSBUMD7FM3YOAO4JTZOE")
  # Secret seed: SCKTG6NCSP5JMZBXCI7UQUDB2X3UOFIKDHB4Z3RZ7ZP4UOIHBGEU6VDA
  # Public: GACAR2AEYEKITE2LKI5RMXF5MIVZ6Q7XILROGDT22O7JX4DSWFS7FDDP
  account :path_payee, KP.from_seed("SCKTG6NCSP5JMZBXCI7UQUDB2X3UOFIKDHB4Z3RZ7ZP4UOIHBGEU6VDA")
  # Secret seed: SB6E22ZX7QOUNZCINQGNXCFQXZNSLU3WTUIWDRFNXNNMYLIWQLX2IIMB
  # Public: GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU
  account :path_gateway, KP.from_seed("SB6E22ZX7QOUNZCINQGNXCFQXZNSLU3WTUIWDRFNXNNMYLIWQLX2IIMB")

  create_account :path_payer
  create_account :path_payee
  create_account :path_gateway
  close_ledger #16

  trust :path_payer,  :path_gateway, "USD"
  trust :path_payee,  :path_gateway, "EUR"
  close_ledger #17

  payment :path_gateway, :path_payer,  ["USD", :path_gateway, "100.00"]
  offer :path_gateway, {buy:["USD", :path_gateway], with: :native}, "200.0", "2.0"
  offer :path_gateway, {sell:["EUR", :path_gateway], for: :native}, "300.0", "1.0"
  close_ledger #18

  payment :path_payer, :path_payee,
    ["EUR", :path_gateway, "200.0"],
    with: ["USD", :path_gateway, "100.0"],
    path:[:native]
  close_ledger #19

  payment :path_payer, :path_payee,
    ["EUR", :path_gateway, "100.0"],
    with: [:native, "100.0"],
    path:[]
  close_ledger #20

# manage offer

  # Secret seed: SDK24P4CD2ILEMNEDAWEZIJS6TZYTQQH7VQRPNVXXIJVYDI7IBUSUG2K
  # Public: GBOK7BOUSOWPHBANBYM6MIRYZJIDIPUYJPXHTHADF75UEVIVYWHHONQC
  account :manage_trader, KP.from_seed("SDK24P4CD2ILEMNEDAWEZIJS6TZYTQQH7VQRPNVXXIJVYDI7IBUSUG2K")
  # Secret seed: SCPIDWDRQCS2CNEXDQBJ7WLXJKG2D3WMPWZ74YXDHGBKX2BZZL625UE7
  # Public: GB2QIYT2IAUFMRXKLSLLPRECC6OCOGJMADSPTRK7TGNT2SFR2YGWDARD
  account :manage_gateway, KP.from_seed("SCPIDWDRQCS2CNEXDQBJ7WLXJKG2D3WMPWZ74YXDHGBKX2BZZL625UE7")
  create_account :manage_trader
  create_account :manage_gateway
  close_ledger #21

  trust :manage_trader,  :manage_gateway, "USD"
  close_ledger #22

  # make offer
  offer :manage_trader, {buy:["USD", :manage_gateway], with: :native}, "20.0", "1.0"
  close_ledger #23

  # offer that consumes another
  offer :manage_gateway, {sell:["USD", :manage_gateway], for: :native}, "30.0", "1.0"
  close_ledger #24

# create passive offer
# TODO

# set options
# TODO

# change trust
# TODO

# allow trust
# TODO

# account merge
# TODO

# inflation
# TODO

# manage_data
# TODO

# different source account
# TODO
