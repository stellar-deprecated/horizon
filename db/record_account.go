package db

type AccountRecord struct {
	HistoryAccountRecord
	CoreAccountRecord
	Trustlines []CoreTrustlineRecord
}

