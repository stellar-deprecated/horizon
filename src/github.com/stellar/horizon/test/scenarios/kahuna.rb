# This is the big kahuna test scenario.  It aims to comprehensively use
# stellar's features, exercising each feature and option at least once.
#
# As new features are added to stellar, this scenario will get updated to
# exercise those new features.  This scenario is used during the horizon
# ingestion tests.
#
use_manual_close
KP = Stellar::KeyPair
close_ledger

## Transaction exercises

# time bounds
  # Secret seed: SBQGG7PY4JZQT6F2MBXDDI4VNDKZYG2Y5TJLKNG7AG6ETNNTJT6MCBOF
  # Public: GAXI33UCLQTCKM2NMRBS7XYBR535LLEVAHL5YBN4FTCB4HZHT7ZA5CVK
  account :time_bounds, KP.from_seed("SBQGG7PY4JZQT6F2MBXDDI4VNDKZYG2Y5TJLKNG7AG6ETNNTJT6MCBOF")
  create_account :time_bounds do |env|
    env.tx.time_bounds = Stellar::TimeBounds.new(min_time: 100, max_time: Time.parse("2020-01-01").to_i)
    env.signatures = [env.tx.sign_decorated(get_account :master)]
  end

  close_ledger

# multisig
  # Secret seed: SCUNXR4FVJGNH4CZBA5K3IIK264WBH7FURTLDMOT3FGWNZKOZCPBW3GS
  # Public: GDXFAGJCSCI4CK2YHK6YRLA6TKEXFRX7BMGVMQOBMLIEUJRJ5YQNLMIB
  account :multisig, KP.from_seed("SCUNXR4FVJGNH4CZBA5K3IIK264WBH7FURTLDMOT3FGWNZKOZCPBW3GS")
  # Secret seed: SBYRIKN5UMKMLVMVJOV2TC2FI3VIU572W4V5KIKR7EDNNORPBIW2RO3I
  # Public: GD3E7HKMRNT6HGBGHBT6I6JE4N2S4W5KZ246TGJ4KQSXJ2P4BXCUPQMP
  multisig_2 = KP.from_seed("SBYRIKN5UMKMLVMVJOV2TC2FI3VIU572W4V5KIKR7EDNNORPBIW2RO3I")

  create_account :multisig
  close_ledger

  set_master_signer_weight :multisig, 1
  add_signer :multisig, multisig_2, 1
  set_thresholds :multisig, low: 2, medium: 2, high: 2

  close_ledger

  set_master_signer_weight :multisig, 2 do |env|
    env.signatures << env.tx.sign_decorated(multisig_2)
  end

  close_ledger

# memo
  # Secret seed: SACUGRIIBI3WTZTVYZNS7KM4JSJQJKUE2AQ4GDE3MEZRAT5QEJ76YWFE
  # Public: GA46VRKBCLI2X6DXLX7AIEVRFLH3UA7XBE3NGNP6O74HQ5LXHMGTV2JB
  account :memo, KP.from_seed("SACUGRIIBI3WTZTVYZNS7KM4JSJQJKUE2AQ4GDE3MEZRAT5QEJ76YWFE")
  create_account :memo
  close_ledger

  payment :memo, :master, [:native, "1.0"], memo: [:id, 123]
  payment :memo, :master, [:native, "1.0"], memo: [:text, "hello"]
  payment :memo, :master, [:native, "1.0"], memo: [:hash, "\x01" * 32]
  payment :memo, :master, [:native, "1.0"], memo: [:return, "\x02" * 32]
  close_ledger

# multiop
  # Secret seed: SD7MLW2LH2PJOU5ZS2AVOZ5OWTH47MXYHOY6JSTNJU4RORU5RLNUTM7V
  # Public: GAG52TW6QAB6TGNMOTL32Y4M3UQQLNNNHPEHYAIYRP6SFF6ZAVRF5ZQY
  account :multiop, KP.from_seed("SD7MLW2LH2PJOU5ZS2AVOZ5OWTH47MXYHOY6JSTNJU4RORU5RLNUTM7V")
  create_account :multiop
  close_ledger

  payment :multiop, :master,  [:native, "10.00"] do |env|
    env.tx.operations = env.tx.operations * 2
    env.tx.fee = 200
    env.signatures = [env.tx.sign_decorated(get_account :multiop)]
  end

  close_ledger

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
  close_ledger

  # create with custom starting balance
  create_account :second_create, :first_create, "50.00"

  close_ledger

# payment
  # Secret seed: SCYYD7ZVS4UNOOIEQA2W77ZEXLOVTGQXA3Z6WCP3KD7YLMT3GFTTTMMO
  # Public: GCHC4D2CS45CJRNN4QAHT2LFZAJIU5PA7H53K3VOP6WEJ6XWHNSNZKQG
  account :payer, KP.from_seed("SCYYD7ZVS4UNOOIEQA2W77ZEXLOVTGQXA3Z6WCP3KD7YLMT3GFTTTMMO")
  # Secret seed: SAZRXWWS6BZ5G7TTW22CXDPJQC2PHYVDBQJBDADS4MHN4NRJQYPW7JFU
  # Public: GANZGPKY5WSHWG5YOZMNG52GCK5SCJ4YGUWMJJVGZSK2FP4BI2JIJN2C
  account :payee, KP.from_seed("SAZRXWWS6BZ5G7TTW22CXDPJQC2PHYVDBQJBDADS4MHN4NRJQYPW7JFU")

  create_account :payer
  create_account :payee
  close_ledger

  # native payment
  payment :payer, :payee,  [:native, "10.00"]

  # non-native payment
  trust :payee, :payer, "USD"
  close_ledger
  payment :payer, :payee,  ["USD", :payer, "10.00"]

  close_ledger

# path payment
# TODO

# manage offer
# TODO

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
