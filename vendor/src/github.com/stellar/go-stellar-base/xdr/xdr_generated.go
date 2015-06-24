// Package xdr is generated from:
//
//  xdr/SCPXDR.x
//  xdr/Stellar-ledger-entries.x
//  xdr/Stellar-ledger.x
//  xdr/Stellar-overlay.x
//  xdr/Stellar-transaction.x
//  xdr/Stellar-types.x
//
// DO NOT EDIT or your changes may be overwritten
package xdr

import (
	"io"

	"github.com/nullstyle/go-xdr/xdr3"
)

// Unmarshal reads an xdr element from `r` into `v`.
func Unmarshal(r io.Reader, v interface{}) (int, error) {
	// delegate to xdr package's Unmarshal
	return xdr.Unmarshal(r, v)
}

// Marshal writes an xdr element `v` into `w`.
func Marshal(w io.Writer, v interface{}) (int, error) {
	// delegate to xdr package's Marshal
	return xdr.Marshal(w, v)
}

// Signature is an XDR Typedef defines as:
//
//   typedef opaque Signature[64];
//
type Signature [64]byte

// Hash is an XDR Typedef defines as:
//
//   typedef opaque Hash[32];
//
type Hash [32]byte

// Uint256 is an XDR Typedef defines as:
//
//   typedef opaque uint256[32];
//
type Uint256 [32]byte

// Uint32 is an XDR Typedef defines as:
//
//   typedef unsigned int uint32;
//
type Uint32 uint32

// Uint64 is an XDR Typedef defines as:
//
//   typedef unsigned hyper uint64;
//
type Uint64 uint64

// Value is an XDR Typedef defines as:
//
//   typedef opaque Value<>;
//
type Value []byte

// Evidence is an XDR Typedef defines as:
//
//   typedef opaque Evidence<>;
//
type Evidence []byte

// ScpBallot is an XDR Struct defines as:
//
//   struct SCPBallot
//    {
//        uint32 counter; // n
//        Value value;    // x
//    };
//
type ScpBallot struct {
	Counter Uint32
	Value   Value
}

// ScpStatementType is an XDR Enum defines as:
//
//   enum SCPStatementType
//    {
//        PREPARING = 0,
//        PREPARED = 1,
//        COMMITTING = 2,
//        COMMITTED = 3
//    };
//
type ScpStatementType int32

const (
	ScpStatementTypePreparing  ScpStatementType = 0
	ScpStatementTypePrepared                    = 1
	ScpStatementTypeCommitting                  = 2
	ScpStatementTypeCommitted                   = 3
)

var scpStatementTypeMap = map[int32]string{
	0: "ScpStatementTypePreparing",
	1: "ScpStatementTypePrepared",
	2: "ScpStatementTypeCommitting",
	3: "ScpStatementTypeCommitted",
}

// ValidEnum validates a proposed value for this enum.  Implements
// the Enum interface for ScpStatementType
func (e ScpStatementType) ValidEnum(v int32) bool {
	_, ok := scpStatementTypeMap[v]
	return ok
}

// String returns the name of `e`
func (e ScpStatementType) String() string {
	name, _ := scpStatementTypeMap[int32(e)]
	return name
}

// ScpStatementPrepare is an XDR NestedStruct defines as:
//
//   struct
//            {
//                SCPBallot excepted<>; // B_c
//                SCPBallot* prepared;  // p
//            }
//
type ScpStatementPrepare struct {
	Excepted []ScpBallot
	Prepared *ScpBallot
}

// ScpStatementPledges is an XDR NestedUnion defines as:
//
//   union switch (SCPStatementType type)
//        {
//        case PREPARING:
//            struct
//            {
//                SCPBallot excepted<>; // B_c
//                SCPBallot* prepared;  // p
//            } prepare;
//        case PREPARED:
//        case COMMITTING:
//        case COMMITTED:
//            void;
//        }
//
type ScpStatementPledges struct {
	Type    ScpStatementType
	Prepare *ScpStatementPrepare
}

// SwitchFieldName returns the field name in which this union's
// discriminant is stored
func (u ScpStatementPledges) SwitchFieldName() string {
	return "Type"
}

// ArmForSwitch returns which field name should be used for storing
// the value for an instance of ScpStatementPledges
func (u ScpStatementPledges) ArmForSwitch(sw int32) (string, bool) {
	switch ScpStatementType(sw) {
	case ScpStatementTypePreparing:
		return "Prepare", true
	case ScpStatementTypePrepared:
		return "", true
	case ScpStatementTypeCommitting:
		return "", true
	case ScpStatementTypeCommitted:
		return "", true
	}

	return "-", false
}

// NewScpStatementPledgesPreparing creates a new  ScpStatementPledges, initialized with
// ScpStatementTypePreparing as the disciminant and the provided val
func NewScpStatementPledgesPreparing(val ScpStatementPrepare) ScpStatementPledges {
	return ScpStatementPledges{
		Type:    ScpStatementTypePreparing,
		Prepare: &val,
	}
}

// NewScpStatementPledgesPrepared creates a new  ScpStatementPledges, initialized with
// ScpStatementTypePrepared as the disciminant and the provided val
func NewScpStatementPledgesPrepared() ScpStatementPledges {
	return ScpStatementPledges{
		Type: ScpStatementTypePrepared,
	}
}

// NewScpStatementPledgesCommitting creates a new  ScpStatementPledges, initialized with
// ScpStatementTypeCommitting as the disciminant and the provided val
func NewScpStatementPledgesCommitting() ScpStatementPledges {
	return ScpStatementPledges{
		Type: ScpStatementTypeCommitting,
	}
}

// NewScpStatementPledgesCommitted creates a new  ScpStatementPledges, initialized with
// ScpStatementTypeCommitted as the disciminant and the provided val
func NewScpStatementPledgesCommitted() ScpStatementPledges {
	return ScpStatementPledges{
		Type: ScpStatementTypeCommitted,
	}
}

// MustPrepare retrieves the Prepare value from the union,
// panicing if the value is not set.
func (u ScpStatementPledges) MustPrepare() ScpStatementPrepare {
	val, ok := u.GetPrepare()

	if !ok {
		panic("arm Prepare is not set")
	}

	return val
}

// GetPrepare retrieves the Prepare value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u ScpStatementPledges) GetPrepare() (result ScpStatementPrepare, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "Prepare" {
		result = *u.Prepare
		ok = true
	}

	return
}

// ScpStatement is an XDR Struct defines as:
//
//   struct SCPStatement
//    {
//        uint64 slotIndex;   // i
//        SCPBallot ballot;   // b
//        Hash quorumSetHash; // D
//
//        union switch (SCPStatementType type)
//        {
//        case PREPARING:
//            struct
//            {
//                SCPBallot excepted<>; // B_c
//                SCPBallot* prepared;  // p
//            } prepare;
//        case PREPARED:
//        case COMMITTING:
//        case COMMITTED:
//            void;
//        }
//        pledges;
//    };
//
type ScpStatement struct {
	SlotIndex     Uint64
	Ballot        ScpBallot
	QuorumSetHash Hash
	Pledges       ScpStatementPledges
}

// ScpEnvelope is an XDR Struct defines as:
//
//   struct SCPEnvelope
//    {
//        uint256 nodeID; // v
//        SCPStatement statement;
//        Signature signature;
//    };
//
type ScpEnvelope struct {
	NodeId    Uint256
	Statement ScpStatement
	Signature Signature
}

// ScpQuorumSet is an XDR Struct defines as:
//
//   struct SCPQuorumSet
//    {
//        uint32 threshold;
//    	Hash validators<>;
//        SCPQuorumSet innerSets<>;
//    };
//
type ScpQuorumSet struct {
	Threshold  Uint32
	Validators []Hash
	InnerSets  []ScpQuorumSet
}

// LedgerEntryType is an XDR Enum defines as:
//
//   enum LedgerEntryType
//    {
//        ACCOUNT = 0,
//        TRUSTLINE = 1,
//        OFFER = 2
//    };
//
type LedgerEntryType int32

const (
	LedgerEntryTypeAccount   LedgerEntryType = 0
	LedgerEntryTypeTrustline                 = 1
	LedgerEntryTypeOffer                     = 2
)

var ledgerEntryTypeMap = map[int32]string{
	0: "LedgerEntryTypeAccount",
	1: "LedgerEntryTypeTrustline",
	2: "LedgerEntryTypeOffer",
}

// ValidEnum validates a proposed value for this enum.  Implements
// the Enum interface for LedgerEntryType
func (e LedgerEntryType) ValidEnum(v int32) bool {
	_, ok := ledgerEntryTypeMap[v]
	return ok
}

// String returns the name of `e`
func (e LedgerEntryType) String() string {
	name, _ := ledgerEntryTypeMap[int32(e)]
	return name
}

// Signer is an XDR Struct defines as:
//
//   struct Signer
//    {
//        uint256 pubKey;
//        uint32 weight; // really only need 1byte
//    };
//
type Signer struct {
	PubKey Uint256
	Weight Uint32
}

// AccountFlags is an XDR Enum defines as:
//
//   enum AccountFlags
//    { // masks for each flag
//
//        // if set, TrustLines are created with authorized set to "false"
//        // requiring the issuer to set it for each TrustLine
//        AUTH_REQUIRED_FLAG = 0x1,
//        // if set, the authorized flag in TrustTines can be cleared
//        // otherwise, authorization cannot be revoked
//        AUTH_REVOCABLE_FLAG = 0x2
//    };
//
type AccountFlags int32

const (
	AccountFlagsAuthRequiredFlag  AccountFlags = 1
	AccountFlagsAuthRevocableFlag              = 2
)

var accountFlagsMap = map[int32]string{
	1: "AccountFlagsAuthRequiredFlag",
	2: "AccountFlagsAuthRevocableFlag",
}

// ValidEnum validates a proposed value for this enum.  Implements
// the Enum interface for AccountFlags
func (e AccountFlags) ValidEnum(v int32) bool {
	_, ok := accountFlagsMap[v]
	return ok
}

// String returns the name of `e`
func (e AccountFlags) String() string {
	name, _ := accountFlagsMap[int32(e)]
	return name
}

// AccountEntry is an XDR Struct defines as:
//
//   struct AccountEntry
//    {
//        AccountID accountID;      // master public key for this account
//        int64 balance;            // in stroops
//        SequenceNumber seqNum;    // last sequence number used for this account
//        uint32 numSubEntries;     // number of sub-entries this account has
//                                  // drives the reserve
//        AccountID* inflationDest; // Account to vote during inflation
//        uint32 flags;             // see AccountFlags
//
//        // fields used for signatures
//        // thresholds stores unsigned bytes: [weight of master|low|medium|high]
//        Thresholds thresholds;
//
//        string32 homeDomain; // can be used for reverse federation and memo lookup
//
//        Signer signers<20>; // possible signers for this account
//    };
//
type AccountEntry struct {
	AccountId     AccountId
	Balance       Int64
	SeqNum        SequenceNumber
	NumSubEntries Uint32
	InflationDest *AccountId
	Flags         Uint32
	Thresholds    Thresholds
	HomeDomain    String32
	Signers       []Signer
}

// TrustLineFlags is an XDR Enum defines as:
//
//   enum TrustLineFlags
//    {
//        // issuer has authorized account to perform transactions with its credit
//        AUTHORIZED_FLAG = 1
//    };
//
type TrustLineFlags int32

const (
	TrustLineFlagsAuthorizedFlag TrustLineFlags = 1
)

var trustLineFlagsMap = map[int32]string{
	1: "TrustLineFlagsAuthorizedFlag",
}

// ValidEnum validates a proposed value for this enum.  Implements
// the Enum interface for TrustLineFlags
func (e TrustLineFlags) ValidEnum(v int32) bool {
	_, ok := trustLineFlagsMap[v]
	return ok
}

// String returns the name of `e`
func (e TrustLineFlags) String() string {
	name, _ := trustLineFlagsMap[int32(e)]
	return name
}

// TrustLineEntry is an XDR Struct defines as:
//
//   struct TrustLineEntry
//    {
//        AccountID accountID; // account this trustline belongs to
//        Currency currency;   // currency (with issuer)
//        int64 balance;       // how much of this currency the user has.
//                             // Currency defines the unit for this;
//
//        int64 limit;  // balance cannot be above this
//        uint32 flags; // see TrustLineFlags
//    };
//
type TrustLineEntry struct {
	AccountId AccountId
	Currency  Currency
	Balance   Int64
	Limit     Int64
	Flags     Uint32
}

// OfferEntryFlags is an XDR Enum defines as:
//
//   enum OfferEntryFlags
//    {
//        // issuer has authorized account to perform transactions with its credit
//        PASSIVE_FLAG = 1
//    };
//
type OfferEntryFlags int32

const (
	OfferEntryFlagsPassiveFlag OfferEntryFlags = 1
)

var offerEntryFlagsMap = map[int32]string{
	1: "OfferEntryFlagsPassiveFlag",
}

// ValidEnum validates a proposed value for this enum.  Implements
// the Enum interface for OfferEntryFlags
func (e OfferEntryFlags) ValidEnum(v int32) bool {
	_, ok := offerEntryFlagsMap[v]
	return ok
}

// String returns the name of `e`
func (e OfferEntryFlags) String() string {
	name, _ := offerEntryFlagsMap[int32(e)]
	return name
}

// OfferEntry is an XDR Struct defines as:
//
//   struct OfferEntry
//    {
//        AccountID accountID;
//        uint64 offerID;
//        Currency takerGets; // A
//        Currency takerPays; // B
//        int64 amount;       // amount of A
//
//        /* price for this offer:
//            price of A in terms of B
//            price=AmountB/AmountA=priceNumerator/priceDenominator
//            price is after fees
//        */
//        Price price;
//        uint32 flags; // see OfferEntryFlags
//    };
//
type OfferEntry struct {
	AccountId AccountId
	OfferId   Uint64
	TakerGets Currency
	TakerPays Currency
	Amount    Int64
	Price     Price
	Flags     Uint32
}

// LedgerEntry is an XDR Union defines as:
//
//   union LedgerEntry switch (LedgerEntryType type)
//    {
//    case ACCOUNT:
//        AccountEntry account;
//
//    case TRUSTLINE:
//        TrustLineEntry trustLine;
//
//    case OFFER:
//        OfferEntry offer;
//    };
//
type LedgerEntry struct {
	Type      LedgerEntryType
	Account   *AccountEntry
	TrustLine *TrustLineEntry
	Offer     *OfferEntry
}

// SwitchFieldName returns the field name in which this union's
// discriminant is stored
func (u LedgerEntry) SwitchFieldName() string {
	return "Type"
}

// ArmForSwitch returns which field name should be used for storing
// the value for an instance of LedgerEntry
func (u LedgerEntry) ArmForSwitch(sw int32) (string, bool) {
	switch LedgerEntryType(sw) {
	case LedgerEntryTypeAccount:
		return "Account", true
	case LedgerEntryTypeTrustline:
		return "TrustLine", true
	case LedgerEntryTypeOffer:
		return "Offer", true
	}

	return "-", false
}

// NewLedgerEntryAccount creates a new  LedgerEntry, initialized with
// LedgerEntryTypeAccount as the disciminant and the provided val
func NewLedgerEntryAccount(val AccountEntry) LedgerEntry {
	return LedgerEntry{
		Type:    LedgerEntryTypeAccount,
		Account: &val,
	}
}

// NewLedgerEntryTrustline creates a new  LedgerEntry, initialized with
// LedgerEntryTypeTrustline as the disciminant and the provided val
func NewLedgerEntryTrustline(val TrustLineEntry) LedgerEntry {
	return LedgerEntry{
		Type:      LedgerEntryTypeTrustline,
		TrustLine: &val,
	}
}

// NewLedgerEntryOffer creates a new  LedgerEntry, initialized with
// LedgerEntryTypeOffer as the disciminant and the provided val
func NewLedgerEntryOffer(val OfferEntry) LedgerEntry {
	return LedgerEntry{
		Type:  LedgerEntryTypeOffer,
		Offer: &val,
	}
}

// MustAccount retrieves the Account value from the union,
// panicing if the value is not set.
func (u LedgerEntry) MustAccount() AccountEntry {
	val, ok := u.GetAccount()

	if !ok {
		panic("arm Account is not set")
	}

	return val
}

// GetAccount retrieves the Account value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u LedgerEntry) GetAccount() (result AccountEntry, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "Account" {
		result = *u.Account
		ok = true
	}

	return
}

// MustTrustLine retrieves the TrustLine value from the union,
// panicing if the value is not set.
func (u LedgerEntry) MustTrustLine() TrustLineEntry {
	val, ok := u.GetTrustLine()

	if !ok {
		panic("arm TrustLine is not set")
	}

	return val
}

// GetTrustLine retrieves the TrustLine value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u LedgerEntry) GetTrustLine() (result TrustLineEntry, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "TrustLine" {
		result = *u.TrustLine
		ok = true
	}

	return
}

// MustOffer retrieves the Offer value from the union,
// panicing if the value is not set.
func (u LedgerEntry) MustOffer() OfferEntry {
	val, ok := u.GetOffer()

	if !ok {
		panic("arm Offer is not set")
	}

	return val
}

// GetOffer retrieves the Offer value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u LedgerEntry) GetOffer() (result OfferEntry, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "Offer" {
		result = *u.Offer
		ok = true
	}

	return
}

// LedgerHeader is an XDR Struct defines as:
//
//   struct LedgerHeader
//    {
//        Hash previousLedgerHash; // hash of the previous ledger header
//        Hash txSetHash;          // the tx set that was SCP confirmed
//        Hash txSetResultHash;    // the TransactionResultSet that led to this ledger
//        Hash bucketListHash;     // hash of the ledger state
//
//        uint32 ledgerSeq; // sequence number of this ledger
//        uint64 closeTime; // network close time
//
//        int64 totalCoins; // total number of stroops in existence
//
//        int64 feePool;       // fees burned since last inflation run
//        uint32 inflationSeq; // inflation sequence number
//
//        uint64 idPool; // last used global ID, used for generating objects
//
//        int32 baseFee;     // base fee per operation in stroops
//        int32 baseReserve; // account base reserve in stroops
//
//        Hash skipList[4];  // hashes of ledgers in the past. allows you to jump back
//                           // in time without walking the chain back ledger by ledger
//    };
//
type LedgerHeader struct {
	PreviousLedgerHash Hash
	TxSetHash          Hash
	TxSetResultHash    Hash
	BucketListHash     Hash
	LedgerSeq          Uint32
	CloseTime          Uint64
	TotalCoins         Int64
	FeePool            Int64
	InflationSeq       Uint32
	IdPool             Uint64
	BaseFee            Int32
	BaseReserve        Int32
	SkipList           [4]Hash
}

// LedgerKeyAccount is an XDR NestedStruct defines as:
//
//   struct
//        {
//            AccountID accountID;
//        }
//
type LedgerKeyAccount struct {
	AccountId AccountId
}

// LedgerKeyTrustLine is an XDR NestedStruct defines as:
//
//   struct
//        {
//            AccountID accountID;
//            Currency currency;
//        }
//
type LedgerKeyTrustLine struct {
	AccountId AccountId
	Currency  Currency
}

// LedgerKeyOffer is an XDR NestedStruct defines as:
//
//   struct
//        {
//            AccountID accountID;
//            uint64 offerID;
//        }
//
type LedgerKeyOffer struct {
	AccountId AccountId
	OfferId   Uint64
}

// LedgerKey is an XDR Union defines as:
//
//   union LedgerKey switch (LedgerEntryType type)
//    {
//    case ACCOUNT:
//        struct
//        {
//            AccountID accountID;
//        } account;
//
//    case TRUSTLINE:
//        struct
//        {
//            AccountID accountID;
//            Currency currency;
//        } trustLine;
//
//    case OFFER:
//        struct
//        {
//            AccountID accountID;
//            uint64 offerID;
//        } offer;
//    };
//
type LedgerKey struct {
	Type      LedgerEntryType
	Account   *LedgerKeyAccount
	TrustLine *LedgerKeyTrustLine
	Offer     *LedgerKeyOffer
}

// SwitchFieldName returns the field name in which this union's
// discriminant is stored
func (u LedgerKey) SwitchFieldName() string {
	return "Type"
}

// ArmForSwitch returns which field name should be used for storing
// the value for an instance of LedgerKey
func (u LedgerKey) ArmForSwitch(sw int32) (string, bool) {
	switch LedgerEntryType(sw) {
	case LedgerEntryTypeAccount:
		return "Account", true
	case LedgerEntryTypeTrustline:
		return "TrustLine", true
	case LedgerEntryTypeOffer:
		return "Offer", true
	}

	return "-", false
}

// NewLedgerKeyAccount creates a new  LedgerKey, initialized with
// LedgerEntryTypeAccount as the disciminant and the provided val
func NewLedgerKeyAccount(val LedgerKeyAccount) LedgerKey {
	return LedgerKey{
		Type:    LedgerEntryTypeAccount,
		Account: &val,
	}
}

// NewLedgerKeyTrustline creates a new  LedgerKey, initialized with
// LedgerEntryTypeTrustline as the disciminant and the provided val
func NewLedgerKeyTrustline(val LedgerKeyTrustLine) LedgerKey {
	return LedgerKey{
		Type:      LedgerEntryTypeTrustline,
		TrustLine: &val,
	}
}

// NewLedgerKeyOffer creates a new  LedgerKey, initialized with
// LedgerEntryTypeOffer as the disciminant and the provided val
func NewLedgerKeyOffer(val LedgerKeyOffer) LedgerKey {
	return LedgerKey{
		Type:  LedgerEntryTypeOffer,
		Offer: &val,
	}
}

// MustAccount retrieves the Account value from the union,
// panicing if the value is not set.
func (u LedgerKey) MustAccount() LedgerKeyAccount {
	val, ok := u.GetAccount()

	if !ok {
		panic("arm Account is not set")
	}

	return val
}

// GetAccount retrieves the Account value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u LedgerKey) GetAccount() (result LedgerKeyAccount, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "Account" {
		result = *u.Account
		ok = true
	}

	return
}

// MustTrustLine retrieves the TrustLine value from the union,
// panicing if the value is not set.
func (u LedgerKey) MustTrustLine() LedgerKeyTrustLine {
	val, ok := u.GetTrustLine()

	if !ok {
		panic("arm TrustLine is not set")
	}

	return val
}

// GetTrustLine retrieves the TrustLine value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u LedgerKey) GetTrustLine() (result LedgerKeyTrustLine, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "TrustLine" {
		result = *u.TrustLine
		ok = true
	}

	return
}

// MustOffer retrieves the Offer value from the union,
// panicing if the value is not set.
func (u LedgerKey) MustOffer() LedgerKeyOffer {
	val, ok := u.GetOffer()

	if !ok {
		panic("arm Offer is not set")
	}

	return val
}

// GetOffer retrieves the Offer value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u LedgerKey) GetOffer() (result LedgerKeyOffer, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "Offer" {
		result = *u.Offer
		ok = true
	}

	return
}

// BucketEntryType is an XDR Enum defines as:
//
//   enum BucketEntryType
//    {
//        LIVEENTRY = 0,
//        DEADENTRY = 1
//    };
//
type BucketEntryType int32

const (
	BucketEntryTypeLiveentry BucketEntryType = 0
	BucketEntryTypeDeadentry                 = 1
)

var bucketEntryTypeMap = map[int32]string{
	0: "BucketEntryTypeLiveentry",
	1: "BucketEntryTypeDeadentry",
}

// ValidEnum validates a proposed value for this enum.  Implements
// the Enum interface for BucketEntryType
func (e BucketEntryType) ValidEnum(v int32) bool {
	_, ok := bucketEntryTypeMap[v]
	return ok
}

// String returns the name of `e`
func (e BucketEntryType) String() string {
	name, _ := bucketEntryTypeMap[int32(e)]
	return name
}

// BucketEntry is an XDR Union defines as:
//
//   union BucketEntry switch (BucketEntryType type)
//    {
//    case LIVEENTRY:
//        LedgerEntry liveEntry;
//
//    case DEADENTRY:
//        LedgerKey deadEntry;
//    };
//
type BucketEntry struct {
	Type      BucketEntryType
	LiveEntry *LedgerEntry
	DeadEntry *LedgerKey
}

// SwitchFieldName returns the field name in which this union's
// discriminant is stored
func (u BucketEntry) SwitchFieldName() string {
	return "Type"
}

// ArmForSwitch returns which field name should be used for storing
// the value for an instance of BucketEntry
func (u BucketEntry) ArmForSwitch(sw int32) (string, bool) {
	switch BucketEntryType(sw) {
	case BucketEntryTypeLiveentry:
		return "LiveEntry", true
	case BucketEntryTypeDeadentry:
		return "DeadEntry", true
	}

	return "-", false
}

// NewBucketEntryLiveentry creates a new  BucketEntry, initialized with
// BucketEntryTypeLiveentry as the disciminant and the provided val
func NewBucketEntryLiveentry(val LedgerEntry) BucketEntry {
	return BucketEntry{
		Type:      BucketEntryTypeLiveentry,
		LiveEntry: &val,
	}
}

// NewBucketEntryDeadentry creates a new  BucketEntry, initialized with
// BucketEntryTypeDeadentry as the disciminant and the provided val
func NewBucketEntryDeadentry(val LedgerKey) BucketEntry {
	return BucketEntry{
		Type:      BucketEntryTypeDeadentry,
		DeadEntry: &val,
	}
}

// MustLiveEntry retrieves the LiveEntry value from the union,
// panicing if the value is not set.
func (u BucketEntry) MustLiveEntry() LedgerEntry {
	val, ok := u.GetLiveEntry()

	if !ok {
		panic("arm LiveEntry is not set")
	}

	return val
}

// GetLiveEntry retrieves the LiveEntry value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u BucketEntry) GetLiveEntry() (result LedgerEntry, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "LiveEntry" {
		result = *u.LiveEntry
		ok = true
	}

	return
}

// MustDeadEntry retrieves the DeadEntry value from the union,
// panicing if the value is not set.
func (u BucketEntry) MustDeadEntry() LedgerKey {
	val, ok := u.GetDeadEntry()

	if !ok {
		panic("arm DeadEntry is not set")
	}

	return val
}

// GetDeadEntry retrieves the DeadEntry value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u BucketEntry) GetDeadEntry() (result LedgerKey, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "DeadEntry" {
		result = *u.DeadEntry
		ok = true
	}

	return
}

// TransactionSet is an XDR Struct defines as:
//
//   struct TransactionSet
//    {
//        Hash previousLedgerHash;
//        TransactionEnvelope txs<5000>;
//    };
//
type TransactionSet struct {
	PreviousLedgerHash Hash
	Txes               []TransactionEnvelope
}

// TransactionResultPair is an XDR Struct defines as:
//
//   struct TransactionResultPair
//    {
//        Hash transactionHash;
//        TransactionResult result; // result for the transaction
//    };
//
type TransactionResultPair struct {
	TransactionHash Hash
	Result          TransactionResult
}

// TransactionResultSet is an XDR Struct defines as:
//
//   struct TransactionResultSet
//    {
//        TransactionResultPair results<5000>;
//    };
//
type TransactionResultSet struct {
	Results []TransactionResultPair
}

// TransactionHistoryEntry is an XDR Struct defines as:
//
//   struct TransactionHistoryEntry
//    {
//        uint32 ledgerSeq;
//        TransactionSet txSet;
//    };
//
type TransactionHistoryEntry struct {
	LedgerSeq Uint32
	TxSet     TransactionSet
}

// TransactionHistoryResultEntry is an XDR Struct defines as:
//
//   struct TransactionHistoryResultEntry
//    {
//        uint32 ledgerSeq;
//        TransactionResultSet txResultSet;
//    };
//
type TransactionHistoryResultEntry struct {
	LedgerSeq   Uint32
	TxResultSet TransactionResultSet
}

// LedgerHeaderHistoryEntry is an XDR Struct defines as:
//
//   struct LedgerHeaderHistoryEntry
//    {
//        Hash hash;
//        LedgerHeader header;
//    };
//
type LedgerHeaderHistoryEntry struct {
	Hash   Hash
	Header LedgerHeader
}

// LedgerEntryChangeType is an XDR Enum defines as:
//
//   enum LedgerEntryChangeType
//    {
//        LEDGER_ENTRY_CREATED = 0, // entry was added to the ledger
//        LEDGER_ENTRY_UPDATED = 1, // entry was modified in the ledger
//        LEDGER_ENTRY_REMOVED = 2  // entry was removed from the ledger
//    };
//
type LedgerEntryChangeType int32

const (
	LedgerEntryChangeTypeLedgerEntryCreated LedgerEntryChangeType = 0
	LedgerEntryChangeTypeLedgerEntryUpdated                       = 1
	LedgerEntryChangeTypeLedgerEntryRemoved                       = 2
)

var ledgerEntryChangeTypeMap = map[int32]string{
	0: "LedgerEntryChangeTypeLedgerEntryCreated",
	1: "LedgerEntryChangeTypeLedgerEntryUpdated",
	2: "LedgerEntryChangeTypeLedgerEntryRemoved",
}

// ValidEnum validates a proposed value for this enum.  Implements
// the Enum interface for LedgerEntryChangeType
func (e LedgerEntryChangeType) ValidEnum(v int32) bool {
	_, ok := ledgerEntryChangeTypeMap[v]
	return ok
}

// String returns the name of `e`
func (e LedgerEntryChangeType) String() string {
	name, _ := ledgerEntryChangeTypeMap[int32(e)]
	return name
}

// LedgerEntryChange is an XDR Union defines as:
//
//   union LedgerEntryChange switch (LedgerEntryChangeType type)
//    {
//    case LEDGER_ENTRY_CREATED:
//        LedgerEntry created;
//    case LEDGER_ENTRY_UPDATED:
//        LedgerEntry updated;
//    case LEDGER_ENTRY_REMOVED:
//        LedgerKey removed;
//    };
//
type LedgerEntryChange struct {
	Type    LedgerEntryChangeType
	Created *LedgerEntry
	Updated *LedgerEntry
	Removed *LedgerKey
}

// SwitchFieldName returns the field name in which this union's
// discriminant is stored
func (u LedgerEntryChange) SwitchFieldName() string {
	return "Type"
}

// ArmForSwitch returns which field name should be used for storing
// the value for an instance of LedgerEntryChange
func (u LedgerEntryChange) ArmForSwitch(sw int32) (string, bool) {
	switch LedgerEntryChangeType(sw) {
	case LedgerEntryChangeTypeLedgerEntryCreated:
		return "Created", true
	case LedgerEntryChangeTypeLedgerEntryUpdated:
		return "Updated", true
	case LedgerEntryChangeTypeLedgerEntryRemoved:
		return "Removed", true
	}

	return "-", false
}

// NewLedgerEntryChangeLedgerEntryCreated creates a new  LedgerEntryChange, initialized with
// LedgerEntryChangeTypeLedgerEntryCreated as the disciminant and the provided val
func NewLedgerEntryChangeLedgerEntryCreated(val LedgerEntry) LedgerEntryChange {
	return LedgerEntryChange{
		Type:    LedgerEntryChangeTypeLedgerEntryCreated,
		Created: &val,
	}
}

// NewLedgerEntryChangeLedgerEntryUpdated creates a new  LedgerEntryChange, initialized with
// LedgerEntryChangeTypeLedgerEntryUpdated as the disciminant and the provided val
func NewLedgerEntryChangeLedgerEntryUpdated(val LedgerEntry) LedgerEntryChange {
	return LedgerEntryChange{
		Type:    LedgerEntryChangeTypeLedgerEntryUpdated,
		Updated: &val,
	}
}

// NewLedgerEntryChangeLedgerEntryRemoved creates a new  LedgerEntryChange, initialized with
// LedgerEntryChangeTypeLedgerEntryRemoved as the disciminant and the provided val
func NewLedgerEntryChangeLedgerEntryRemoved(val LedgerKey) LedgerEntryChange {
	return LedgerEntryChange{
		Type:    LedgerEntryChangeTypeLedgerEntryRemoved,
		Removed: &val,
	}
}

// MustCreated retrieves the Created value from the union,
// panicing if the value is not set.
func (u LedgerEntryChange) MustCreated() LedgerEntry {
	val, ok := u.GetCreated()

	if !ok {
		panic("arm Created is not set")
	}

	return val
}

// GetCreated retrieves the Created value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u LedgerEntryChange) GetCreated() (result LedgerEntry, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "Created" {
		result = *u.Created
		ok = true
	}

	return
}

// MustUpdated retrieves the Updated value from the union,
// panicing if the value is not set.
func (u LedgerEntryChange) MustUpdated() LedgerEntry {
	val, ok := u.GetUpdated()

	if !ok {
		panic("arm Updated is not set")
	}

	return val
}

// GetUpdated retrieves the Updated value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u LedgerEntryChange) GetUpdated() (result LedgerEntry, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "Updated" {
		result = *u.Updated
		ok = true
	}

	return
}

// MustRemoved retrieves the Removed value from the union,
// panicing if the value is not set.
func (u LedgerEntryChange) MustRemoved() LedgerKey {
	val, ok := u.GetRemoved()

	if !ok {
		panic("arm Removed is not set")
	}

	return val
}

// GetRemoved retrieves the Removed value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u LedgerEntryChange) GetRemoved() (result LedgerKey, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "Removed" {
		result = *u.Removed
		ok = true
	}

	return
}

// TransactionMeta is an XDR Struct defines as:
//
//   struct TransactionMeta
//    {
//        LedgerEntryChange changes<>;
//    };
//
type TransactionMeta struct {
	Changes []LedgerEntryChange
}

// StellarBallotValue is an XDR Struct defines as:
//
//   struct StellarBallotValue
//    {
//        Hash txSetHash;
//        uint64 closeTime;
//        uint32 baseFee;
//    };
//
type StellarBallotValue struct {
	TxSetHash Hash
	CloseTime Uint64
	BaseFee   Uint32
}

// StellarBallot is an XDR Struct defines as:
//
//   struct StellarBallot
//    {
//        uint256 nodeID;
//        Signature signature;
//        StellarBallotValue value;
//    };
//
type StellarBallot struct {
	NodeId    Uint256
	Signature Signature
	Value     StellarBallotValue
}

// Error is an XDR Struct defines as:
//
//   struct Error
//    {
//        int code;
//        string msg<100>;
//    };
//
type Error struct {
	Code int32
	Msg  string
}

// Hello is an XDR Struct defines as:
//
//   struct Hello
//    {
//        int protocolVersion;
//        string versionStr<100>;
//        int listeningPort;
//        opaque peerID[32];
//    };
//
type Hello struct {
	ProtocolVersion int32
	VersionStr      string
	ListeningPort   int32
	PeerId          [32]byte
}

// PeerAddress is an XDR Struct defines as:
//
//   struct PeerAddress
//    {
//        opaque ip[4];
//        uint32 port;
//        uint32 numFailures;
//    };
//
type PeerAddress struct {
	Ip          [4]byte
	Port        Uint32
	NumFailures Uint32
}

// MessageType is an XDR Enum defines as:
//
//   enum MessageType
//    {
//        ERROR_MSG = 0,
//        HELLO = 1,
//        DONT_HAVE = 2,
//
//        GET_PEERS = 3, // gets a list of peers this guy knows about
//        PEERS = 4,
//
//        GET_TX_SET = 5, // gets a particular txset by hash
//        TX_SET = 6,
//
//        TRANSACTION = 7, // pass on a tx you have heard about
//
//        // SCP
//        GET_SCP_QUORUMSET = 8,
//        SCP_QUORUMSET = 9,
//        SCP_MESSAGE = 10
//    };
//
type MessageType int32

const (
	MessageTypeErrorMsg        MessageType = 0
	MessageTypeHello                       = 1
	MessageTypeDontHave                    = 2
	MessageTypeGetPeer                     = 3
	MessageTypePeer                        = 4
	MessageTypeGetTxSet                    = 5
	MessageTypeTxSet                       = 6
	MessageTypeTransaction                 = 7
	MessageTypeGetScpQuorumset             = 8
	MessageTypeScpQuorumset                = 9
	MessageTypeScpMessage                  = 10
)

var messageTypeMap = map[int32]string{
	0:  "MessageTypeErrorMsg",
	1:  "MessageTypeHello",
	2:  "MessageTypeDontHave",
	3:  "MessageTypeGetPeer",
	4:  "MessageTypePeer",
	5:  "MessageTypeGetTxSet",
	6:  "MessageTypeTxSet",
	7:  "MessageTypeTransaction",
	8:  "MessageTypeGetScpQuorumset",
	9:  "MessageTypeScpQuorumset",
	10: "MessageTypeScpMessage",
}

// ValidEnum validates a proposed value for this enum.  Implements
// the Enum interface for MessageType
func (e MessageType) ValidEnum(v int32) bool {
	_, ok := messageTypeMap[v]
	return ok
}

// String returns the name of `e`
func (e MessageType) String() string {
	name, _ := messageTypeMap[int32(e)]
	return name
}

// DontHave is an XDR Struct defines as:
//
//   struct DontHave
//    {
//        MessageType type;
//        uint256 reqHash;
//    };
//
type DontHave struct {
	Type    MessageType
	ReqHash Uint256
}

// StellarMessage is an XDR Union defines as:
//
//   union StellarMessage switch (MessageType type)
//    {
//    case ERROR_MSG:
//        Error error;
//    case HELLO:
//        Hello hello;
//    case DONT_HAVE:
//        DontHave dontHave;
//    case GET_PEERS:
//        void;
//    case PEERS:
//        PeerAddress peers<>;
//
//    case GET_TX_SET:
//        uint256 txSetHash;
//    case TX_SET:
//        TransactionSet txSet;
//
//    case TRANSACTION:
//        TransactionEnvelope transaction;
//
//    // SCP
//    case GET_SCP_QUORUMSET:
//        uint256 qSetHash;
//    case SCP_QUORUMSET:
//        SCPQuorumSet qSet;
//    case SCP_MESSAGE:
//        SCPEnvelope envelope;
//    };
//
type StellarMessage struct {
	Type        MessageType
	Error       *Error
	Hello       *Hello
	DontHave    *DontHave
	Peers       *[]PeerAddress
	TxSetHash   *Uint256
	TxSet       *TransactionSet
	Transaction *TransactionEnvelope
	QSetHash    *Uint256
	QSet        *ScpQuorumSet
	Envelope    *ScpEnvelope
}

// SwitchFieldName returns the field name in which this union's
// discriminant is stored
func (u StellarMessage) SwitchFieldName() string {
	return "Type"
}

// ArmForSwitch returns which field name should be used for storing
// the value for an instance of StellarMessage
func (u StellarMessage) ArmForSwitch(sw int32) (string, bool) {
	switch MessageType(sw) {
	case MessageTypeErrorMsg:
		return "Error", true
	case MessageTypeHello:
		return "Hello", true
	case MessageTypeDontHave:
		return "DontHave", true
	case MessageTypeGetPeer:
		return "", true
	case MessageTypePeer:
		return "Peers", true
	case MessageTypeGetTxSet:
		return "TxSetHash", true
	case MessageTypeTxSet:
		return "TxSet", true
	case MessageTypeTransaction:
		return "Transaction", true
	case MessageTypeGetScpQuorumset:
		return "QSetHash", true
	case MessageTypeScpQuorumset:
		return "QSet", true
	case MessageTypeScpMessage:
		return "Envelope", true
	}

	return "-", false
}

// NewStellarMessageErrorMsg creates a new  StellarMessage, initialized with
// MessageTypeErrorMsg as the disciminant and the provided val
func NewStellarMessageErrorMsg(val Error) StellarMessage {
	return StellarMessage{
		Type:  MessageTypeErrorMsg,
		Error: &val,
	}
}

// NewStellarMessageHello creates a new  StellarMessage, initialized with
// MessageTypeHello as the disciminant and the provided val
func NewStellarMessageHello(val Hello) StellarMessage {
	return StellarMessage{
		Type:  MessageTypeHello,
		Hello: &val,
	}
}

// NewStellarMessageDontHave creates a new  StellarMessage, initialized with
// MessageTypeDontHave as the disciminant and the provided val
func NewStellarMessageDontHave(val DontHave) StellarMessage {
	return StellarMessage{
		Type:     MessageTypeDontHave,
		DontHave: &val,
	}
}

// NewStellarMessageGetPeer creates a new  StellarMessage, initialized with
// MessageTypeGetPeer as the disciminant and the provided val
func NewStellarMessageGetPeer() StellarMessage {
	return StellarMessage{
		Type: MessageTypeGetPeer,
	}
}

// NewStellarMessagePeer creates a new  StellarMessage, initialized with
// MessageTypePeer as the disciminant and the provided val
func NewStellarMessagePeer(val []PeerAddress) StellarMessage {
	return StellarMessage{
		Type:  MessageTypePeer,
		Peers: &val,
	}
}

// NewStellarMessageGetTxSet creates a new  StellarMessage, initialized with
// MessageTypeGetTxSet as the disciminant and the provided val
func NewStellarMessageGetTxSet(val Uint256) StellarMessage {
	return StellarMessage{
		Type:      MessageTypeGetTxSet,
		TxSetHash: &val,
	}
}

// NewStellarMessageTxSet creates a new  StellarMessage, initialized with
// MessageTypeTxSet as the disciminant and the provided val
func NewStellarMessageTxSet(val TransactionSet) StellarMessage {
	return StellarMessage{
		Type:  MessageTypeTxSet,
		TxSet: &val,
	}
}

// NewStellarMessageTransaction creates a new  StellarMessage, initialized with
// MessageTypeTransaction as the disciminant and the provided val
func NewStellarMessageTransaction(val TransactionEnvelope) StellarMessage {
	return StellarMessage{
		Type:        MessageTypeTransaction,
		Transaction: &val,
	}
}

// NewStellarMessageGetScpQuorumset creates a new  StellarMessage, initialized with
// MessageTypeGetScpQuorumset as the disciminant and the provided val
func NewStellarMessageGetScpQuorumset(val Uint256) StellarMessage {
	return StellarMessage{
		Type:     MessageTypeGetScpQuorumset,
		QSetHash: &val,
	}
}

// NewStellarMessageScpQuorumset creates a new  StellarMessage, initialized with
// MessageTypeScpQuorumset as the disciminant and the provided val
func NewStellarMessageScpQuorumset(val ScpQuorumSet) StellarMessage {
	return StellarMessage{
		Type: MessageTypeScpQuorumset,
		QSet: &val,
	}
}

// NewStellarMessageScpMessage creates a new  StellarMessage, initialized with
// MessageTypeScpMessage as the disciminant and the provided val
func NewStellarMessageScpMessage(val ScpEnvelope) StellarMessage {
	return StellarMessage{
		Type:     MessageTypeScpMessage,
		Envelope: &val,
	}
}

// MustError retrieves the Error value from the union,
// panicing if the value is not set.
func (u StellarMessage) MustError() Error {
	val, ok := u.GetError()

	if !ok {
		panic("arm Error is not set")
	}

	return val
}

// GetError retrieves the Error value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u StellarMessage) GetError() (result Error, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "Error" {
		result = *u.Error
		ok = true
	}

	return
}

// MustHello retrieves the Hello value from the union,
// panicing if the value is not set.
func (u StellarMessage) MustHello() Hello {
	val, ok := u.GetHello()

	if !ok {
		panic("arm Hello is not set")
	}

	return val
}

// GetHello retrieves the Hello value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u StellarMessage) GetHello() (result Hello, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "Hello" {
		result = *u.Hello
		ok = true
	}

	return
}

// MustDontHave retrieves the DontHave value from the union,
// panicing if the value is not set.
func (u StellarMessage) MustDontHave() DontHave {
	val, ok := u.GetDontHave()

	if !ok {
		panic("arm DontHave is not set")
	}

	return val
}

// GetDontHave retrieves the DontHave value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u StellarMessage) GetDontHave() (result DontHave, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "DontHave" {
		result = *u.DontHave
		ok = true
	}

	return
}

// MustPeers retrieves the Peers value from the union,
// panicing if the value is not set.
func (u StellarMessage) MustPeers() []PeerAddress {
	val, ok := u.GetPeers()

	if !ok {
		panic("arm Peers is not set")
	}

	return val
}

// GetPeers retrieves the Peers value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u StellarMessage) GetPeers() (result []PeerAddress, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "Peers" {
		result = *u.Peers
		ok = true
	}

	return
}

// MustTxSetHash retrieves the TxSetHash value from the union,
// panicing if the value is not set.
func (u StellarMessage) MustTxSetHash() Uint256 {
	val, ok := u.GetTxSetHash()

	if !ok {
		panic("arm TxSetHash is not set")
	}

	return val
}

// GetTxSetHash retrieves the TxSetHash value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u StellarMessage) GetTxSetHash() (result Uint256, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "TxSetHash" {
		result = *u.TxSetHash
		ok = true
	}

	return
}

// MustTxSet retrieves the TxSet value from the union,
// panicing if the value is not set.
func (u StellarMessage) MustTxSet() TransactionSet {
	val, ok := u.GetTxSet()

	if !ok {
		panic("arm TxSet is not set")
	}

	return val
}

// GetTxSet retrieves the TxSet value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u StellarMessage) GetTxSet() (result TransactionSet, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "TxSet" {
		result = *u.TxSet
		ok = true
	}

	return
}

// MustTransaction retrieves the Transaction value from the union,
// panicing if the value is not set.
func (u StellarMessage) MustTransaction() TransactionEnvelope {
	val, ok := u.GetTransaction()

	if !ok {
		panic("arm Transaction is not set")
	}

	return val
}

// GetTransaction retrieves the Transaction value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u StellarMessage) GetTransaction() (result TransactionEnvelope, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "Transaction" {
		result = *u.Transaction
		ok = true
	}

	return
}

// MustQSetHash retrieves the QSetHash value from the union,
// panicing if the value is not set.
func (u StellarMessage) MustQSetHash() Uint256 {
	val, ok := u.GetQSetHash()

	if !ok {
		panic("arm QSetHash is not set")
	}

	return val
}

// GetQSetHash retrieves the QSetHash value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u StellarMessage) GetQSetHash() (result Uint256, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "QSetHash" {
		result = *u.QSetHash
		ok = true
	}

	return
}

// MustQSet retrieves the QSet value from the union,
// panicing if the value is not set.
func (u StellarMessage) MustQSet() ScpQuorumSet {
	val, ok := u.GetQSet()

	if !ok {
		panic("arm QSet is not set")
	}

	return val
}

// GetQSet retrieves the QSet value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u StellarMessage) GetQSet() (result ScpQuorumSet, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "QSet" {
		result = *u.QSet
		ok = true
	}

	return
}

// MustEnvelope retrieves the Envelope value from the union,
// panicing if the value is not set.
func (u StellarMessage) MustEnvelope() ScpEnvelope {
	val, ok := u.GetEnvelope()

	if !ok {
		panic("arm Envelope is not set")
	}

	return val
}

// GetEnvelope retrieves the Envelope value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u StellarMessage) GetEnvelope() (result ScpEnvelope, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "Envelope" {
		result = *u.Envelope
		ok = true
	}

	return
}

// DecoratedSignature is an XDR Struct defines as:
//
//   struct DecoratedSignature
//    {
//        opaque hint[4];    // first 4 bytes of the public key, used as a hint
//        uint512 signature; // actual signature
//    };
//
type DecoratedSignature struct {
	Hint      [4]byte
	Signature Uint512
}

// OperationType is an XDR Enum defines as:
//
//   enum OperationType
//    {
//        CREATE_ACCOUNT = 0,
//        PAYMENT = 1,
//        PATH_PAYMENT = 2,
//        MANAGE_OFFER = 3,
//    	CREATE_PASSIVE_OFFER = 4,
//        SET_OPTIONS = 5,
//        CHANGE_TRUST = 6,
//        ALLOW_TRUST = 7,
//        ACCOUNT_MERGE = 8,
//        INFLATION = 9
//    };
//
type OperationType int32

const (
	OperationTypeCreateAccount      OperationType = 0
	OperationTypePayment                          = 1
	OperationTypePathPayment                      = 2
	OperationTypeManageOffer                      = 3
	OperationTypeCreatePassiveOffer               = 4
	OperationTypeSetOption                        = 5
	OperationTypeChangeTrust                      = 6
	OperationTypeAllowTrust                       = 7
	OperationTypeAccountMerge                     = 8
	OperationTypeInflation                        = 9
)

var operationTypeMap = map[int32]string{
	0: "OperationTypeCreateAccount",
	1: "OperationTypePayment",
	2: "OperationTypePathPayment",
	3: "OperationTypeManageOffer",
	4: "OperationTypeCreatePassiveOffer",
	5: "OperationTypeSetOption",
	6: "OperationTypeChangeTrust",
	7: "OperationTypeAllowTrust",
	8: "OperationTypeAccountMerge",
	9: "OperationTypeInflation",
}

// ValidEnum validates a proposed value for this enum.  Implements
// the Enum interface for OperationType
func (e OperationType) ValidEnum(v int32) bool {
	_, ok := operationTypeMap[v]
	return ok
}

// String returns the name of `e`
func (e OperationType) String() string {
	name, _ := operationTypeMap[int32(e)]
	return name
}

// CreateAccountOp is an XDR Struct defines as:
//
//   struct CreateAccountOp
//    {
//        AccountID destination; // account to create
//        int64 startingBalance; // amount they end up with
//    };
//
type CreateAccountOp struct {
	Destination     AccountId
	StartingBalance Int64
}

// PaymentOp is an XDR Struct defines as:
//
//   struct PaymentOp
//    {
//        AccountID destination; // recipient of the payment
//        Currency currency;     // what they end up with
//        int64 amount;          // amount they end up with
//    };
//
type PaymentOp struct {
	Destination AccountId
	Currency    Currency
	Amount      Int64
}

// PathPaymentOp is an XDR Struct defines as:
//
//   struct PathPaymentOp
//    {
//        Currency sendCurrency; // currency we pay with
//        int64 sendMax;         // the maximum amount of sendCurrency to
//                               // send (excluding fees).
//                               // The operation will fail if can't be met
//
//        AccountID destination; // recipient of the payment
//        Currency destCurrency; // what they end up with
//        int64 destAmount;      // amount they end up with
//
//        Currency path<5>; // additional hops it must go through to get there
//    };
//
type PathPaymentOp struct {
	SendCurrency Currency
	SendMax      Int64
	Destination  AccountId
	DestCurrency Currency
	DestAmount   Int64
	Path         []Currency
}

// ManageOfferOp is an XDR Struct defines as:
//
//   struct ManageOfferOp
//    {
//        Currency takerGets;
//        Currency takerPays;
//        int64 amount; // amount taker gets. if set to 0, delete the offer
//        Price price;  // =takerPaysAmount/takerGetsAmount
//
//        // 0=create a new offer, otherwise edit an existing offer
//        uint64 offerID;
//    };
//
type ManageOfferOp struct {
	TakerGets Currency
	TakerPays Currency
	Amount    Int64
	Price     Price
	OfferId   Uint64
}

// CreatePassiveOfferOp is an XDR Struct defines as:
//
//   struct CreatePassiveOfferOp
//    {
//        Currency takerGets;
//        Currency takerPays;
//        int64 amount; // amount taker gets. if set to 0, delete the offer
//        Price price;  // =takerPaysAmount/takerGetsAmount
//    };
//
type CreatePassiveOfferOp struct {
	TakerGets Currency
	TakerPays Currency
	Amount    Int64
	Price     Price
}

// SetOptionsOp is an XDR Struct defines as:
//
//   struct SetOptionsOp
//    {
//        AccountID* inflationDest; // sets the inflation destination
//
//        uint32* clearFlags; // which flags to clear
//        uint32* setFlags;   // which flags to set
//
//        Thresholds* thresholds; // update the thresholds for the account
//
//        string32* homeDomain; // sets the home domain
//
//        // Add, update or remove a signer for the account
//        // signer is deleted if the weight is 0
//        Signer* signer;
//    };
//
type SetOptionsOp struct {
	InflationDest *AccountId
	ClearFlags    *Uint32
	SetFlags      *Uint32
	Thresholds    *Thresholds
	HomeDomain    *String32
	Signer        *Signer
}

// ChangeTrustOp is an XDR Struct defines as:
//
//   struct ChangeTrustOp
//    {
//        Currency line;
//
//        // if limit is set to 0, deletes the trust line
//        int64 limit;
//    };
//
type ChangeTrustOp struct {
	Line  Currency
	Limit Int64
}

// AllowTrustOpCurrency is an XDR NestedUnion defines as:
//
//   union switch (CurrencyType type)
//        {
//        // CURRENCY_TYPE_NATIVE is not allowed
//        case CURRENCY_TYPE_ALPHANUM:
//            opaque currencyCode[4];
//
//            // add other currency types here in the future
//        }
//
type AllowTrustOpCurrency struct {
	Type         CurrencyType
	CurrencyCode *[4]byte
}

// SwitchFieldName returns the field name in which this union's
// discriminant is stored
func (u AllowTrustOpCurrency) SwitchFieldName() string {
	return "Type"
}

// ArmForSwitch returns which field name should be used for storing
// the value for an instance of AllowTrustOpCurrency
func (u AllowTrustOpCurrency) ArmForSwitch(sw int32) (string, bool) {
	switch CurrencyType(sw) {
	case CurrencyTypeCurrencyTypeAlphanum:
		return "CurrencyCode", true
	}

	return "-", false
}

// NewAllowTrustOpCurrencyCurrencyTypeAlphanum creates a new  AllowTrustOpCurrency, initialized with
// CurrencyTypeCurrencyTypeAlphanum as the disciminant and the provided val
func NewAllowTrustOpCurrencyCurrencyTypeAlphanum(val [4]byte) AllowTrustOpCurrency {
	return AllowTrustOpCurrency{
		Type:         CurrencyTypeCurrencyTypeAlphanum,
		CurrencyCode: &val,
	}
}

// MustCurrencyCode retrieves the CurrencyCode value from the union,
// panicing if the value is not set.
func (u AllowTrustOpCurrency) MustCurrencyCode() [4]byte {
	val, ok := u.GetCurrencyCode()

	if !ok {
		panic("arm CurrencyCode is not set")
	}

	return val
}

// GetCurrencyCode retrieves the CurrencyCode value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u AllowTrustOpCurrency) GetCurrencyCode() (result [4]byte, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "CurrencyCode" {
		result = *u.CurrencyCode
		ok = true
	}

	return
}

// AllowTrustOp is an XDR Struct defines as:
//
//   struct AllowTrustOp
//    {
//        AccountID trustor;
//        union switch (CurrencyType type)
//        {
//        // CURRENCY_TYPE_NATIVE is not allowed
//        case CURRENCY_TYPE_ALPHANUM:
//            opaque currencyCode[4];
//
//            // add other currency types here in the future
//        }
//        currency;
//
//        bool authorize;
//    };
//
type AllowTrustOp struct {
	Trustor   AccountId
	Currency  AllowTrustOpCurrency
	Authorize bool
}

// OperationBody is an XDR NestedUnion defines as:
//
//   union switch (OperationType type)
//        {
//        case CREATE_ACCOUNT:
//            CreateAccountOp createAccountOp;
//        case PAYMENT:
//            PaymentOp paymentOp;
//        case PATH_PAYMENT:
//            PathPaymentOp pathPaymentOp;
//        case MANAGE_OFFER:
//            ManageOfferOp manageOfferOp;
//    	case CREATE_PASSIVE_OFFER:
//            CreatePassiveOfferOp createPassiveOfferOp;
//        case SET_OPTIONS:
//            SetOptionsOp setOptionsOp;
//        case CHANGE_TRUST:
//            ChangeTrustOp changeTrustOp;
//        case ALLOW_TRUST:
//            AllowTrustOp allowTrustOp;
//        case ACCOUNT_MERGE:
//            uint256 destination;
//        case INFLATION:
//            void;
//        }
//
type OperationBody struct {
	Type                 OperationType
	CreateAccountOp      *CreateAccountOp
	PaymentOp            *PaymentOp
	PathPaymentOp        *PathPaymentOp
	ManageOfferOp        *ManageOfferOp
	CreatePassiveOfferOp *CreatePassiveOfferOp
	SetOptionsOp         *SetOptionsOp
	ChangeTrustOp        *ChangeTrustOp
	AllowTrustOp         *AllowTrustOp
	Destination          *Uint256
}

// SwitchFieldName returns the field name in which this union's
// discriminant is stored
func (u OperationBody) SwitchFieldName() string {
	return "Type"
}

// ArmForSwitch returns which field name should be used for storing
// the value for an instance of OperationBody
func (u OperationBody) ArmForSwitch(sw int32) (string, bool) {
	switch OperationType(sw) {
	case OperationTypeCreateAccount:
		return "CreateAccountOp", true
	case OperationTypePayment:
		return "PaymentOp", true
	case OperationTypePathPayment:
		return "PathPaymentOp", true
	case OperationTypeManageOffer:
		return "ManageOfferOp", true
	case OperationTypeCreatePassiveOffer:
		return "CreatePassiveOfferOp", true
	case OperationTypeSetOption:
		return "SetOptionsOp", true
	case OperationTypeChangeTrust:
		return "ChangeTrustOp", true
	case OperationTypeAllowTrust:
		return "AllowTrustOp", true
	case OperationTypeAccountMerge:
		return "Destination", true
	case OperationTypeInflation:
		return "", true
	}

	return "-", false
}

// NewOperationBodyCreateAccount creates a new  OperationBody, initialized with
// OperationTypeCreateAccount as the disciminant and the provided val
func NewOperationBodyCreateAccount(val CreateAccountOp) OperationBody {
	return OperationBody{
		Type:            OperationTypeCreateAccount,
		CreateAccountOp: &val,
	}
}

// NewOperationBodyPayment creates a new  OperationBody, initialized with
// OperationTypePayment as the disciminant and the provided val
func NewOperationBodyPayment(val PaymentOp) OperationBody {
	return OperationBody{
		Type:      OperationTypePayment,
		PaymentOp: &val,
	}
}

// NewOperationBodyPathPayment creates a new  OperationBody, initialized with
// OperationTypePathPayment as the disciminant and the provided val
func NewOperationBodyPathPayment(val PathPaymentOp) OperationBody {
	return OperationBody{
		Type:          OperationTypePathPayment,
		PathPaymentOp: &val,
	}
}

// NewOperationBodyManageOffer creates a new  OperationBody, initialized with
// OperationTypeManageOffer as the disciminant and the provided val
func NewOperationBodyManageOffer(val ManageOfferOp) OperationBody {
	return OperationBody{
		Type:          OperationTypeManageOffer,
		ManageOfferOp: &val,
	}
}

// NewOperationBodyCreatePassiveOffer creates a new  OperationBody, initialized with
// OperationTypeCreatePassiveOffer as the disciminant and the provided val
func NewOperationBodyCreatePassiveOffer(val CreatePassiveOfferOp) OperationBody {
	return OperationBody{
		Type:                 OperationTypeCreatePassiveOffer,
		CreatePassiveOfferOp: &val,
	}
}

// NewOperationBodySetOption creates a new  OperationBody, initialized with
// OperationTypeSetOption as the disciminant and the provided val
func NewOperationBodySetOption(val SetOptionsOp) OperationBody {
	return OperationBody{
		Type:         OperationTypeSetOption,
		SetOptionsOp: &val,
	}
}

// NewOperationBodyChangeTrust creates a new  OperationBody, initialized with
// OperationTypeChangeTrust as the disciminant and the provided val
func NewOperationBodyChangeTrust(val ChangeTrustOp) OperationBody {
	return OperationBody{
		Type:          OperationTypeChangeTrust,
		ChangeTrustOp: &val,
	}
}

// NewOperationBodyAllowTrust creates a new  OperationBody, initialized with
// OperationTypeAllowTrust as the disciminant and the provided val
func NewOperationBodyAllowTrust(val AllowTrustOp) OperationBody {
	return OperationBody{
		Type:         OperationTypeAllowTrust,
		AllowTrustOp: &val,
	}
}

// NewOperationBodyAccountMerge creates a new  OperationBody, initialized with
// OperationTypeAccountMerge as the disciminant and the provided val
func NewOperationBodyAccountMerge(val Uint256) OperationBody {
	return OperationBody{
		Type:        OperationTypeAccountMerge,
		Destination: &val,
	}
}

// NewOperationBodyInflation creates a new  OperationBody, initialized with
// OperationTypeInflation as the disciminant and the provided val
func NewOperationBodyInflation() OperationBody {
	return OperationBody{
		Type: OperationTypeInflation,
	}
}

// MustCreateAccountOp retrieves the CreateAccountOp value from the union,
// panicing if the value is not set.
func (u OperationBody) MustCreateAccountOp() CreateAccountOp {
	val, ok := u.GetCreateAccountOp()

	if !ok {
		panic("arm CreateAccountOp is not set")
	}

	return val
}

// GetCreateAccountOp retrieves the CreateAccountOp value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u OperationBody) GetCreateAccountOp() (result CreateAccountOp, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "CreateAccountOp" {
		result = *u.CreateAccountOp
		ok = true
	}

	return
}

// MustPaymentOp retrieves the PaymentOp value from the union,
// panicing if the value is not set.
func (u OperationBody) MustPaymentOp() PaymentOp {
	val, ok := u.GetPaymentOp()

	if !ok {
		panic("arm PaymentOp is not set")
	}

	return val
}

// GetPaymentOp retrieves the PaymentOp value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u OperationBody) GetPaymentOp() (result PaymentOp, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "PaymentOp" {
		result = *u.PaymentOp
		ok = true
	}

	return
}

// MustPathPaymentOp retrieves the PathPaymentOp value from the union,
// panicing if the value is not set.
func (u OperationBody) MustPathPaymentOp() PathPaymentOp {
	val, ok := u.GetPathPaymentOp()

	if !ok {
		panic("arm PathPaymentOp is not set")
	}

	return val
}

// GetPathPaymentOp retrieves the PathPaymentOp value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u OperationBody) GetPathPaymentOp() (result PathPaymentOp, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "PathPaymentOp" {
		result = *u.PathPaymentOp
		ok = true
	}

	return
}

// MustManageOfferOp retrieves the ManageOfferOp value from the union,
// panicing if the value is not set.
func (u OperationBody) MustManageOfferOp() ManageOfferOp {
	val, ok := u.GetManageOfferOp()

	if !ok {
		panic("arm ManageOfferOp is not set")
	}

	return val
}

// GetManageOfferOp retrieves the ManageOfferOp value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u OperationBody) GetManageOfferOp() (result ManageOfferOp, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "ManageOfferOp" {
		result = *u.ManageOfferOp
		ok = true
	}

	return
}

// MustCreatePassiveOfferOp retrieves the CreatePassiveOfferOp value from the union,
// panicing if the value is not set.
func (u OperationBody) MustCreatePassiveOfferOp() CreatePassiveOfferOp {
	val, ok := u.GetCreatePassiveOfferOp()

	if !ok {
		panic("arm CreatePassiveOfferOp is not set")
	}

	return val
}

// GetCreatePassiveOfferOp retrieves the CreatePassiveOfferOp value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u OperationBody) GetCreatePassiveOfferOp() (result CreatePassiveOfferOp, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "CreatePassiveOfferOp" {
		result = *u.CreatePassiveOfferOp
		ok = true
	}

	return
}

// MustSetOptionsOp retrieves the SetOptionsOp value from the union,
// panicing if the value is not set.
func (u OperationBody) MustSetOptionsOp() SetOptionsOp {
	val, ok := u.GetSetOptionsOp()

	if !ok {
		panic("arm SetOptionsOp is not set")
	}

	return val
}

// GetSetOptionsOp retrieves the SetOptionsOp value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u OperationBody) GetSetOptionsOp() (result SetOptionsOp, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "SetOptionsOp" {
		result = *u.SetOptionsOp
		ok = true
	}

	return
}

// MustChangeTrustOp retrieves the ChangeTrustOp value from the union,
// panicing if the value is not set.
func (u OperationBody) MustChangeTrustOp() ChangeTrustOp {
	val, ok := u.GetChangeTrustOp()

	if !ok {
		panic("arm ChangeTrustOp is not set")
	}

	return val
}

// GetChangeTrustOp retrieves the ChangeTrustOp value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u OperationBody) GetChangeTrustOp() (result ChangeTrustOp, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "ChangeTrustOp" {
		result = *u.ChangeTrustOp
		ok = true
	}

	return
}

// MustAllowTrustOp retrieves the AllowTrustOp value from the union,
// panicing if the value is not set.
func (u OperationBody) MustAllowTrustOp() AllowTrustOp {
	val, ok := u.GetAllowTrustOp()

	if !ok {
		panic("arm AllowTrustOp is not set")
	}

	return val
}

// GetAllowTrustOp retrieves the AllowTrustOp value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u OperationBody) GetAllowTrustOp() (result AllowTrustOp, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "AllowTrustOp" {
		result = *u.AllowTrustOp
		ok = true
	}

	return
}

// MustDestination retrieves the Destination value from the union,
// panicing if the value is not set.
func (u OperationBody) MustDestination() Uint256 {
	val, ok := u.GetDestination()

	if !ok {
		panic("arm Destination is not set")
	}

	return val
}

// GetDestination retrieves the Destination value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u OperationBody) GetDestination() (result Uint256, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "Destination" {
		result = *u.Destination
		ok = true
	}

	return
}

// Operation is an XDR Struct defines as:
//
//   struct Operation
//    {
//        // sourceAccount is the account used to run the operation
//        // if not set, the runtime defaults to "account" specified at
//        // the transaction level
//        AccountID* sourceAccount;
//
//        union switch (OperationType type)
//        {
//        case CREATE_ACCOUNT:
//            CreateAccountOp createAccountOp;
//        case PAYMENT:
//            PaymentOp paymentOp;
//        case PATH_PAYMENT:
//            PathPaymentOp pathPaymentOp;
//        case MANAGE_OFFER:
//            ManageOfferOp manageOfferOp;
//    	case CREATE_PASSIVE_OFFER:
//            CreatePassiveOfferOp createPassiveOfferOp;
//        case SET_OPTIONS:
//            SetOptionsOp setOptionsOp;
//        case CHANGE_TRUST:
//            ChangeTrustOp changeTrustOp;
//        case ALLOW_TRUST:
//            AllowTrustOp allowTrustOp;
//        case ACCOUNT_MERGE:
//            uint256 destination;
//        case INFLATION:
//            void;
//        }
//        body;
//    };
//
type Operation struct {
	SourceAccount *AccountId
	Body          OperationBody
}

// MemoType is an XDR Enum defines as:
//
//   enum MemoType
//    {
//        MEMO_NONE = 0,
//        MEMO_TEXT = 1,
//        MEMO_ID = 2,
//        MEMO_HASH = 3,
//        MEMO_RETURN = 4
//    };
//
type MemoType int32

const (
	MemoTypeMemoNone   MemoType = 0
	MemoTypeMemoText            = 1
	MemoTypeMemoId              = 2
	MemoTypeMemoHash            = 3
	MemoTypeMemoReturn          = 4
)

var memoTypeMap = map[int32]string{
	0: "MemoTypeMemoNone",
	1: "MemoTypeMemoText",
	2: "MemoTypeMemoId",
	3: "MemoTypeMemoHash",
	4: "MemoTypeMemoReturn",
}

// ValidEnum validates a proposed value for this enum.  Implements
// the Enum interface for MemoType
func (e MemoType) ValidEnum(v int32) bool {
	_, ok := memoTypeMap[v]
	return ok
}

// String returns the name of `e`
func (e MemoType) String() string {
	name, _ := memoTypeMap[int32(e)]
	return name
}

// Memo is an XDR Union defines as:
//
//   union Memo switch (MemoType type)
//    {
//    case MEMO_NONE:
//        void;
//    case MEMO_TEXT:
//        string text<28>;
//    case MEMO_ID:
//        uint64 id;
//    case MEMO_HASH:
//        Hash hash; // the hash of what to pull from the content server
//    case MEMO_RETURN:
//        Hash retHash; // the hash of the tx you are rejecting
//    };
//
type Memo struct {
	Type    MemoType
	Text    *string
	Id      *Uint64
	Hash    *Hash
	RetHash *Hash
}

// SwitchFieldName returns the field name in which this union's
// discriminant is stored
func (u Memo) SwitchFieldName() string {
	return "Type"
}

// ArmForSwitch returns which field name should be used for storing
// the value for an instance of Memo
func (u Memo) ArmForSwitch(sw int32) (string, bool) {
	switch MemoType(sw) {
	case MemoTypeMemoNone:
		return "", true
	case MemoTypeMemoText:
		return "Text", true
	case MemoTypeMemoId:
		return "Id", true
	case MemoTypeMemoHash:
		return "Hash", true
	case MemoTypeMemoReturn:
		return "RetHash", true
	}

	return "-", false
}

// NewMemoMemoNone creates a new  Memo, initialized with
// MemoTypeMemoNone as the disciminant and the provided val
func NewMemoMemoNone() Memo {
	return Memo{
		Type: MemoTypeMemoNone,
	}
}

// NewMemoMemoText creates a new  Memo, initialized with
// MemoTypeMemoText as the disciminant and the provided val
func NewMemoMemoText(val string) Memo {
	return Memo{
		Type: MemoTypeMemoText,
		Text: &val,
	}
}

// NewMemoMemoId creates a new  Memo, initialized with
// MemoTypeMemoId as the disciminant and the provided val
func NewMemoMemoId(val Uint64) Memo {
	return Memo{
		Type: MemoTypeMemoId,
		Id:   &val,
	}
}

// NewMemoMemoHash creates a new  Memo, initialized with
// MemoTypeMemoHash as the disciminant and the provided val
func NewMemoMemoHash(val Hash) Memo {
	return Memo{
		Type: MemoTypeMemoHash,
		Hash: &val,
	}
}

// NewMemoMemoReturn creates a new  Memo, initialized with
// MemoTypeMemoReturn as the disciminant and the provided val
func NewMemoMemoReturn(val Hash) Memo {
	return Memo{
		Type:    MemoTypeMemoReturn,
		RetHash: &val,
	}
}

// MustText retrieves the Text value from the union,
// panicing if the value is not set.
func (u Memo) MustText() string {
	val, ok := u.GetText()

	if !ok {
		panic("arm Text is not set")
	}

	return val
}

// GetText retrieves the Text value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u Memo) GetText() (result string, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "Text" {
		result = *u.Text
		ok = true
	}

	return
}

// MustId retrieves the Id value from the union,
// panicing if the value is not set.
func (u Memo) MustId() Uint64 {
	val, ok := u.GetId()

	if !ok {
		panic("arm Id is not set")
	}

	return val
}

// GetId retrieves the Id value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u Memo) GetId() (result Uint64, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "Id" {
		result = *u.Id
		ok = true
	}

	return
}

// MustHash retrieves the Hash value from the union,
// panicing if the value is not set.
func (u Memo) MustHash() Hash {
	val, ok := u.GetHash()

	if !ok {
		panic("arm Hash is not set")
	}

	return val
}

// GetHash retrieves the Hash value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u Memo) GetHash() (result Hash, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "Hash" {
		result = *u.Hash
		ok = true
	}

	return
}

// MustRetHash retrieves the RetHash value from the union,
// panicing if the value is not set.
func (u Memo) MustRetHash() Hash {
	val, ok := u.GetRetHash()

	if !ok {
		panic("arm RetHash is not set")
	}

	return val
}

// GetRetHash retrieves the RetHash value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u Memo) GetRetHash() (result Hash, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "RetHash" {
		result = *u.RetHash
		ok = true
	}

	return
}

// TimeBounds is an XDR Struct defines as:
//
//   struct TimeBounds
//    {
//        uint64 minTime;
//        uint64 maxTime;
//    };
//
type TimeBounds struct {
	MinTime Uint64
	MaxTime Uint64
}

// Transaction is an XDR Struct defines as:
//
//   struct Transaction
//    {
//        // account used to run the transaction
//        AccountID sourceAccount;
//
//        // the fee the sourceAccount will pay
//        int32 fee;
//
//        // sequence number to consume in the account
//        SequenceNumber seqNum;
//
//        // validity range (inclusive) for the last ledger close time
//        TimeBounds* timeBounds;
//
//        Memo memo;
//
//        Operation operations<100>;
//    };
//
type Transaction struct {
	SourceAccount AccountId
	Fee           Int32
	SeqNum        SequenceNumber
	TimeBounds    *TimeBounds
	Memo          Memo
	Operations    []Operation
}

// TransactionEnvelope is an XDR Struct defines as:
//
//   struct TransactionEnvelope
//    {
//        Transaction tx;
//        DecoratedSignature signatures<20>;
//    };
//
type TransactionEnvelope struct {
	Tx         Transaction
	Signatures []DecoratedSignature
}

// ClaimOfferAtom is an XDR Struct defines as:
//
//   struct ClaimOfferAtom
//    {
//        // emited to identify the offer
//        AccountID offerOwner; // Account that owns the offer
//        uint64 offerID;
//
//        // amount and currency taken from the owner
//        Currency currencyClaimed;
//        int64 amountClaimed;
//
//        // should we also include the amount that the owner gets in return?
//    };
//
type ClaimOfferAtom struct {
	OfferOwner      AccountId
	OfferId         Uint64
	CurrencyClaimed Currency
	AmountClaimed   Int64
}

// CreateAccountResultCode is an XDR Enum defines as:
//
//   enum CreateAccountResultCode
//    {
//        // codes considered as "success" for the operation
//        CREATE_ACCOUNT_SUCCESS = 0, // account was created
//
//        // codes considered as "failure" for the operation
//        CREATE_ACCOUNT_MALFORMED = 1,   // invalid destination
//        CREATE_ACCOUNT_UNDERFUNDED = 2, // not enough funds in source account
//        CREATE_ACCOUNT_LOW_RESERVE =
//            3, // would create an account below the min reserve
//        CREATE_ACCOUNT_ALREADY_EXIST = 4 // account already exists
//    };
//
type CreateAccountResultCode int32

const (
	CreateAccountResultCodeCreateAccountSuccess      CreateAccountResultCode = 0
	CreateAccountResultCodeCreateAccountMalformed                            = 1
	CreateAccountResultCodeCreateAccountUnderfunded                          = 2
	CreateAccountResultCodeCreateAccountLowReserve                           = 3
	CreateAccountResultCodeCreateAccountAlreadyExist                         = 4
)

var createAccountResultCodeMap = map[int32]string{
	0: "CreateAccountResultCodeCreateAccountSuccess",
	1: "CreateAccountResultCodeCreateAccountMalformed",
	2: "CreateAccountResultCodeCreateAccountUnderfunded",
	3: "CreateAccountResultCodeCreateAccountLowReserve",
	4: "CreateAccountResultCodeCreateAccountAlreadyExist",
}

// ValidEnum validates a proposed value for this enum.  Implements
// the Enum interface for CreateAccountResultCode
func (e CreateAccountResultCode) ValidEnum(v int32) bool {
	_, ok := createAccountResultCodeMap[v]
	return ok
}

// String returns the name of `e`
func (e CreateAccountResultCode) String() string {
	name, _ := createAccountResultCodeMap[int32(e)]
	return name
}

// CreateAccountResult is an XDR Union defines as:
//
//   union CreateAccountResult switch (CreateAccountResultCode code)
//    {
//    case CREATE_ACCOUNT_SUCCESS:
//        void;
//    default:
//        void;
//    };
//
type CreateAccountResult struct {
	Code CreateAccountResultCode
}

// SwitchFieldName returns the field name in which this union's
// discriminant is stored
func (u CreateAccountResult) SwitchFieldName() string {
	return "Code"
}

// ArmForSwitch returns which field name should be used for storing
// the value for an instance of CreateAccountResult
func (u CreateAccountResult) ArmForSwitch(sw int32) (string, bool) {
	switch CreateAccountResultCode(sw) {
	case CreateAccountResultCodeCreateAccountSuccess:
		return "", true
	default:
		return "", true
	}
}

// NewCreateAccountResultCreateAccountSuccess creates a new  CreateAccountResult, initialized with
// CreateAccountResultCodeCreateAccountSuccess as the disciminant and the provided val
func NewCreateAccountResultCreateAccountSuccess() CreateAccountResult {
	return CreateAccountResult{
		Code: CreateAccountResultCodeCreateAccountSuccess,
	}
}

// NewCreateAccountResultCreateAccountMalformed creates a new  CreateAccountResult, initialized with
// CreateAccountResultCodeCreateAccountMalformed as the disciminant and the provided val
func NewCreateAccountResultCreateAccountMalformed() CreateAccountResult {
	return CreateAccountResult{
		Code: CreateAccountResultCodeCreateAccountMalformed,
	}
}

// NewCreateAccountResultCreateAccountUnderfunded creates a new  CreateAccountResult, initialized with
// CreateAccountResultCodeCreateAccountUnderfunded as the disciminant and the provided val
func NewCreateAccountResultCreateAccountUnderfunded() CreateAccountResult {
	return CreateAccountResult{
		Code: CreateAccountResultCodeCreateAccountUnderfunded,
	}
}

// NewCreateAccountResultCreateAccountLowReserve creates a new  CreateAccountResult, initialized with
// CreateAccountResultCodeCreateAccountLowReserve as the disciminant and the provided val
func NewCreateAccountResultCreateAccountLowReserve() CreateAccountResult {
	return CreateAccountResult{
		Code: CreateAccountResultCodeCreateAccountLowReserve,
	}
}

// NewCreateAccountResultCreateAccountAlreadyExist creates a new  CreateAccountResult, initialized with
// CreateAccountResultCodeCreateAccountAlreadyExist as the disciminant and the provided val
func NewCreateAccountResultCreateAccountAlreadyExist() CreateAccountResult {
	return CreateAccountResult{
		Code: CreateAccountResultCodeCreateAccountAlreadyExist,
	}
}

// PaymentResultCode is an XDR Enum defines as:
//
//   enum PaymentResultCode
//    {
//        // codes considered as "success" for the operation
//        PAYMENT_SUCCESS = 0, // payment successfuly completed
//
//        // codes considered as "failure" for the operation
//        PAYMENT_MALFORMED = -1,      // bad input
//        PAYMENT_UNDERFUNDED = -2,    // not enough funds in source account
//        PAYMENT_NO_DESTINATION = -3, // destination account does not exist
//        PAYMENT_NO_TRUST = -4, // destination missing a trust line for currency
//        PAYMENT_NOT_AUTHORIZED = -5, // destination not authorized to hold currency
//        PAYMENT_LINE_FULL = -6       // destination would go above their limit
//    };
//
type PaymentResultCode int32

const (
	PaymentResultCodePaymentSuccess       PaymentResultCode = 0
	PaymentResultCodePaymentMalformed                       = -1
	PaymentResultCodePaymentUnderfunded                     = -2
	PaymentResultCodePaymentNoDestination                   = -3
	PaymentResultCodePaymentNoTrust                         = -4
	PaymentResultCodePaymentNotAuthorized                   = -5
	PaymentResultCodePaymentLineFull                        = -6
)

var paymentResultCodeMap = map[int32]string{
	0:  "PaymentResultCodePaymentSuccess",
	-1: "PaymentResultCodePaymentMalformed",
	-2: "PaymentResultCodePaymentUnderfunded",
	-3: "PaymentResultCodePaymentNoDestination",
	-4: "PaymentResultCodePaymentNoTrust",
	-5: "PaymentResultCodePaymentNotAuthorized",
	-6: "PaymentResultCodePaymentLineFull",
}

// ValidEnum validates a proposed value for this enum.  Implements
// the Enum interface for PaymentResultCode
func (e PaymentResultCode) ValidEnum(v int32) bool {
	_, ok := paymentResultCodeMap[v]
	return ok
}

// String returns the name of `e`
func (e PaymentResultCode) String() string {
	name, _ := paymentResultCodeMap[int32(e)]
	return name
}

// PaymentResult is an XDR Union defines as:
//
//   union PaymentResult switch (PaymentResultCode code)
//    {
//    case PAYMENT_SUCCESS:
//        void;
//    default:
//        void;
//    };
//
type PaymentResult struct {
	Code PaymentResultCode
}

// SwitchFieldName returns the field name in which this union's
// discriminant is stored
func (u PaymentResult) SwitchFieldName() string {
	return "Code"
}

// ArmForSwitch returns which field name should be used for storing
// the value for an instance of PaymentResult
func (u PaymentResult) ArmForSwitch(sw int32) (string, bool) {
	switch PaymentResultCode(sw) {
	case PaymentResultCodePaymentSuccess:
		return "", true
	default:
		return "", true
	}
}

// NewPaymentResultPaymentSuccess creates a new  PaymentResult, initialized with
// PaymentResultCodePaymentSuccess as the disciminant and the provided val
func NewPaymentResultPaymentSuccess() PaymentResult {
	return PaymentResult{
		Code: PaymentResultCodePaymentSuccess,
	}
}

// NewPaymentResultPaymentMalformed creates a new  PaymentResult, initialized with
// PaymentResultCodePaymentMalformed as the disciminant and the provided val
func NewPaymentResultPaymentMalformed() PaymentResult {
	return PaymentResult{
		Code: PaymentResultCodePaymentMalformed,
	}
}

// NewPaymentResultPaymentUnderfunded creates a new  PaymentResult, initialized with
// PaymentResultCodePaymentUnderfunded as the disciminant and the provided val
func NewPaymentResultPaymentUnderfunded() PaymentResult {
	return PaymentResult{
		Code: PaymentResultCodePaymentUnderfunded,
	}
}

// NewPaymentResultPaymentNoDestination creates a new  PaymentResult, initialized with
// PaymentResultCodePaymentNoDestination as the disciminant and the provided val
func NewPaymentResultPaymentNoDestination() PaymentResult {
	return PaymentResult{
		Code: PaymentResultCodePaymentNoDestination,
	}
}

// NewPaymentResultPaymentNoTrust creates a new  PaymentResult, initialized with
// PaymentResultCodePaymentNoTrust as the disciminant and the provided val
func NewPaymentResultPaymentNoTrust() PaymentResult {
	return PaymentResult{
		Code: PaymentResultCodePaymentNoTrust,
	}
}

// NewPaymentResultPaymentNotAuthorized creates a new  PaymentResult, initialized with
// PaymentResultCodePaymentNotAuthorized as the disciminant and the provided val
func NewPaymentResultPaymentNotAuthorized() PaymentResult {
	return PaymentResult{
		Code: PaymentResultCodePaymentNotAuthorized,
	}
}

// NewPaymentResultPaymentLineFull creates a new  PaymentResult, initialized with
// PaymentResultCodePaymentLineFull as the disciminant and the provided val
func NewPaymentResultPaymentLineFull() PaymentResult {
	return PaymentResult{
		Code: PaymentResultCodePaymentLineFull,
	}
}

// PathPaymentResultCode is an XDR Enum defines as:
//
//   enum PathPaymentResultCode
//    {
//        // codes considered as "success" for the operation
//        PATH_PAYMENT_SUCCESS = 0, // success
//
//        // codes considered as "failure" for the operation
//        PATH_PAYMENT_MALFORMED = -1,      // bad input
//        PATH_PAYMENT_UNDERFUNDED = -2,    // not enough funds in source account
//        PATH_PAYMENT_NO_DESTINATION = -3, // destination account does not exist
//        PATH_PAYMENT_NO_TRUST = -4, // destination missing a trust line for currency
//        PATH_PAYMENT_NOT_AUTHORIZED =
//            -5,                      // destination not authorized to hold currency
//        PATH_PAYMENT_LINE_FULL = -6, // destination would go above their limit
//        PATH_PAYMENT_TOO_FEW_OFFERS = -7, // not enough offers to satisfy path
//        PATH_PAYMENT_OVER_SENDMAX = -8    // could not satisfy sendmax
//    };
//
type PathPaymentResultCode int32

const (
	PathPaymentResultCodePathPaymentSuccess       PathPaymentResultCode = 0
	PathPaymentResultCodePathPaymentMalformed                           = -1
	PathPaymentResultCodePathPaymentUnderfunded                         = -2
	PathPaymentResultCodePathPaymentNoDestination                       = -3
	PathPaymentResultCodePathPaymentNoTrust                             = -4
	PathPaymentResultCodePathPaymentNotAuthorized                       = -5
	PathPaymentResultCodePathPaymentLineFull                            = -6
	PathPaymentResultCodePathPaymentTooFewOffer                         = -7
	PathPaymentResultCodePathPaymentOverSendmax                         = -8
)

var pathPaymentResultCodeMap = map[int32]string{
	0:  "PathPaymentResultCodePathPaymentSuccess",
	-1: "PathPaymentResultCodePathPaymentMalformed",
	-2: "PathPaymentResultCodePathPaymentUnderfunded",
	-3: "PathPaymentResultCodePathPaymentNoDestination",
	-4: "PathPaymentResultCodePathPaymentNoTrust",
	-5: "PathPaymentResultCodePathPaymentNotAuthorized",
	-6: "PathPaymentResultCodePathPaymentLineFull",
	-7: "PathPaymentResultCodePathPaymentTooFewOffer",
	-8: "PathPaymentResultCodePathPaymentOverSendmax",
}

// ValidEnum validates a proposed value for this enum.  Implements
// the Enum interface for PathPaymentResultCode
func (e PathPaymentResultCode) ValidEnum(v int32) bool {
	_, ok := pathPaymentResultCodeMap[v]
	return ok
}

// String returns the name of `e`
func (e PathPaymentResultCode) String() string {
	name, _ := pathPaymentResultCodeMap[int32(e)]
	return name
}

// SimplePaymentResult is an XDR Struct defines as:
//
//   struct SimplePaymentResult
//    {
//        AccountID destination;
//        Currency currency;
//        int64 amount;
//    };
//
type SimplePaymentResult struct {
	Destination AccountId
	Currency    Currency
	Amount      Int64
}

// PathPaymentResultSuccess is an XDR NestedStruct defines as:
//
//   struct
//        {
//            ClaimOfferAtom offers<>;
//            SimplePaymentResult last;
//        }
//
type PathPaymentResultSuccess struct {
	Offers []ClaimOfferAtom
	Last   SimplePaymentResult
}

// PathPaymentResult is an XDR Union defines as:
//
//   union PathPaymentResult switch (PathPaymentResultCode code)
//    {
//    case PATH_PAYMENT_SUCCESS:
//        struct
//        {
//            ClaimOfferAtom offers<>;
//            SimplePaymentResult last;
//        } success;
//    default:
//        void;
//    };
//
type PathPaymentResult struct {
	Code    PathPaymentResultCode
	Success *PathPaymentResultSuccess
}

// SwitchFieldName returns the field name in which this union's
// discriminant is stored
func (u PathPaymentResult) SwitchFieldName() string {
	return "Code"
}

// ArmForSwitch returns which field name should be used for storing
// the value for an instance of PathPaymentResult
func (u PathPaymentResult) ArmForSwitch(sw int32) (string, bool) {
	switch PathPaymentResultCode(sw) {
	case PathPaymentResultCodePathPaymentSuccess:
		return "Success", true
	default:
		return "", true
	}
}

// NewPathPaymentResultPathPaymentSuccess creates a new  PathPaymentResult, initialized with
// PathPaymentResultCodePathPaymentSuccess as the disciminant and the provided val
func NewPathPaymentResultPathPaymentSuccess(val PathPaymentResultSuccess) PathPaymentResult {
	return PathPaymentResult{
		Code:    PathPaymentResultCodePathPaymentSuccess,
		Success: &val,
	}
}

// NewPathPaymentResultPathPaymentMalformed creates a new  PathPaymentResult, initialized with
// PathPaymentResultCodePathPaymentMalformed as the disciminant and the provided val
func NewPathPaymentResultPathPaymentMalformed() PathPaymentResult {
	return PathPaymentResult{
		Code: PathPaymentResultCodePathPaymentMalformed,
	}
}

// NewPathPaymentResultPathPaymentUnderfunded creates a new  PathPaymentResult, initialized with
// PathPaymentResultCodePathPaymentUnderfunded as the disciminant and the provided val
func NewPathPaymentResultPathPaymentUnderfunded() PathPaymentResult {
	return PathPaymentResult{
		Code: PathPaymentResultCodePathPaymentUnderfunded,
	}
}

// NewPathPaymentResultPathPaymentNoDestination creates a new  PathPaymentResult, initialized with
// PathPaymentResultCodePathPaymentNoDestination as the disciminant and the provided val
func NewPathPaymentResultPathPaymentNoDestination() PathPaymentResult {
	return PathPaymentResult{
		Code: PathPaymentResultCodePathPaymentNoDestination,
	}
}

// NewPathPaymentResultPathPaymentNoTrust creates a new  PathPaymentResult, initialized with
// PathPaymentResultCodePathPaymentNoTrust as the disciminant and the provided val
func NewPathPaymentResultPathPaymentNoTrust() PathPaymentResult {
	return PathPaymentResult{
		Code: PathPaymentResultCodePathPaymentNoTrust,
	}
}

// NewPathPaymentResultPathPaymentNotAuthorized creates a new  PathPaymentResult, initialized with
// PathPaymentResultCodePathPaymentNotAuthorized as the disciminant and the provided val
func NewPathPaymentResultPathPaymentNotAuthorized() PathPaymentResult {
	return PathPaymentResult{
		Code: PathPaymentResultCodePathPaymentNotAuthorized,
	}
}

// NewPathPaymentResultPathPaymentLineFull creates a new  PathPaymentResult, initialized with
// PathPaymentResultCodePathPaymentLineFull as the disciminant and the provided val
func NewPathPaymentResultPathPaymentLineFull() PathPaymentResult {
	return PathPaymentResult{
		Code: PathPaymentResultCodePathPaymentLineFull,
	}
}

// NewPathPaymentResultPathPaymentTooFewOffer creates a new  PathPaymentResult, initialized with
// PathPaymentResultCodePathPaymentTooFewOffer as the disciminant and the provided val
func NewPathPaymentResultPathPaymentTooFewOffer() PathPaymentResult {
	return PathPaymentResult{
		Code: PathPaymentResultCodePathPaymentTooFewOffer,
	}
}

// NewPathPaymentResultPathPaymentOverSendmax creates a new  PathPaymentResult, initialized with
// PathPaymentResultCodePathPaymentOverSendmax as the disciminant and the provided val
func NewPathPaymentResultPathPaymentOverSendmax() PathPaymentResult {
	return PathPaymentResult{
		Code: PathPaymentResultCodePathPaymentOverSendmax,
	}
}

// MustSuccess retrieves the Success value from the union,
// panicing if the value is not set.
func (u PathPaymentResult) MustSuccess() PathPaymentResultSuccess {
	val, ok := u.GetSuccess()

	if !ok {
		panic("arm Success is not set")
	}

	return val
}

// GetSuccess retrieves the Success value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u PathPaymentResult) GetSuccess() (result PathPaymentResultSuccess, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Code))

	if armName == "Success" {
		result = *u.Success
		ok = true
	}

	return
}

// ManageOfferResultCode is an XDR Enum defines as:
//
//   enum ManageOfferResultCode
//    {
//        // codes considered as "success" for the operation
//        MANAGE_OFFER_SUCCESS = 0,
//
//        // codes considered as "failure" for the operation
//        MANAGE_OFFER_MALFORMED = -1,      // generated offer would be invalid
//        MANAGE_OFFER_NO_TRUST = -2,       // can't hold what it's buying
//        MANAGE_OFFER_NOT_AUTHORIZED = -3, // not authorized to sell or buy
//        MANAGE_OFFER_LINE_FULL = -4,      // can't receive more of what it's buying
//        MANAGE_OFFER_UNDERFUNDED = -5,    // doesn't hold what it's trying to sell
//        MANAGE_OFFER_CROSS_SELF = -6,     // would cross an offer from the same user
//
//        // update errors
//        MANAGE_OFFER_NOT_FOUND = -7, // offerID does not match an existing offer
//        MANAGE_OFFER_MISMATCH = -8,  // currencies don't match offer
//
//        MANAGE_OFFER_LOW_RESERVE = -9 // not enough funds to create a new Offer
//    };
//
type ManageOfferResultCode int32

const (
	ManageOfferResultCodeManageOfferSuccess       ManageOfferResultCode = 0
	ManageOfferResultCodeManageOfferMalformed                           = -1
	ManageOfferResultCodeManageOfferNoTrust                             = -2
	ManageOfferResultCodeManageOfferNotAuthorized                       = -3
	ManageOfferResultCodeManageOfferLineFull                            = -4
	ManageOfferResultCodeManageOfferUnderfunded                         = -5
	ManageOfferResultCodeManageOfferCrossSelf                           = -6
	ManageOfferResultCodeManageOfferNotFound                            = -7
	ManageOfferResultCodeManageOfferMismatch                            = -8
	ManageOfferResultCodeManageOfferLowReserve                          = -9
)

var manageOfferResultCodeMap = map[int32]string{
	0:  "ManageOfferResultCodeManageOfferSuccess",
	-1: "ManageOfferResultCodeManageOfferMalformed",
	-2: "ManageOfferResultCodeManageOfferNoTrust",
	-3: "ManageOfferResultCodeManageOfferNotAuthorized",
	-4: "ManageOfferResultCodeManageOfferLineFull",
	-5: "ManageOfferResultCodeManageOfferUnderfunded",
	-6: "ManageOfferResultCodeManageOfferCrossSelf",
	-7: "ManageOfferResultCodeManageOfferNotFound",
	-8: "ManageOfferResultCodeManageOfferMismatch",
	-9: "ManageOfferResultCodeManageOfferLowReserve",
}

// ValidEnum validates a proposed value for this enum.  Implements
// the Enum interface for ManageOfferResultCode
func (e ManageOfferResultCode) ValidEnum(v int32) bool {
	_, ok := manageOfferResultCodeMap[v]
	return ok
}

// String returns the name of `e`
func (e ManageOfferResultCode) String() string {
	name, _ := manageOfferResultCodeMap[int32(e)]
	return name
}

// ManageOfferEffect is an XDR Enum defines as:
//
//   enum ManageOfferEffect
//    {
//        MANAGE_OFFER_CREATED = 0,
//        MANAGE_OFFER_UPDATED = 1,
//        MANAGE_OFFER_DELETED = 2
//    };
//
type ManageOfferEffect int32

const (
	ManageOfferEffectManageOfferCreated ManageOfferEffect = 0
	ManageOfferEffectManageOfferUpdated                   = 1
	ManageOfferEffectManageOfferDeleted                   = 2
)

var manageOfferEffectMap = map[int32]string{
	0: "ManageOfferEffectManageOfferCreated",
	1: "ManageOfferEffectManageOfferUpdated",
	2: "ManageOfferEffectManageOfferDeleted",
}

// ValidEnum validates a proposed value for this enum.  Implements
// the Enum interface for ManageOfferEffect
func (e ManageOfferEffect) ValidEnum(v int32) bool {
	_, ok := manageOfferEffectMap[v]
	return ok
}

// String returns the name of `e`
func (e ManageOfferEffect) String() string {
	name, _ := manageOfferEffectMap[int32(e)]
	return name
}

// ManageOfferSuccessResultOffer is an XDR NestedUnion defines as:
//
//   union switch (ManageOfferEffect effect)
//        {
//        case MANAGE_OFFER_CREATED:
//        case MANAGE_OFFER_UPDATED:
//            OfferEntry offer;
//        default:
//            void;
//        }
//
type ManageOfferSuccessResultOffer struct {
	Effect ManageOfferEffect
	Offer  *OfferEntry
}

// SwitchFieldName returns the field name in which this union's
// discriminant is stored
func (u ManageOfferSuccessResultOffer) SwitchFieldName() string {
	return "Effect"
}

// ArmForSwitch returns which field name should be used for storing
// the value for an instance of ManageOfferSuccessResultOffer
func (u ManageOfferSuccessResultOffer) ArmForSwitch(sw int32) (string, bool) {
	switch ManageOfferEffect(sw) {
	case ManageOfferEffectManageOfferCreated:
		return "Offer", true
	case ManageOfferEffectManageOfferUpdated:
		return "Offer", true
	default:
		return "", true
	}
}

// NewManageOfferSuccessResultOfferManageOfferCreated creates a new  ManageOfferSuccessResultOffer, initialized with
// ManageOfferEffectManageOfferCreated as the disciminant and the provided val
func NewManageOfferSuccessResultOfferManageOfferCreated(val OfferEntry) ManageOfferSuccessResultOffer {
	return ManageOfferSuccessResultOffer{
		Effect: ManageOfferEffectManageOfferCreated,
		Offer:  &val,
	}
}

// NewManageOfferSuccessResultOfferManageOfferUpdated creates a new  ManageOfferSuccessResultOffer, initialized with
// ManageOfferEffectManageOfferUpdated as the disciminant and the provided val
func NewManageOfferSuccessResultOfferManageOfferUpdated(val OfferEntry) ManageOfferSuccessResultOffer {
	return ManageOfferSuccessResultOffer{
		Effect: ManageOfferEffectManageOfferUpdated,
		Offer:  &val,
	}
}

// NewManageOfferSuccessResultOfferManageOfferDeleted creates a new  ManageOfferSuccessResultOffer, initialized with
// ManageOfferEffectManageOfferDeleted as the disciminant and the provided val
func NewManageOfferSuccessResultOfferManageOfferDeleted() ManageOfferSuccessResultOffer {
	return ManageOfferSuccessResultOffer{
		Effect: ManageOfferEffectManageOfferDeleted,
	}
}

// MustOffer retrieves the Offer value from the union,
// panicing if the value is not set.
func (u ManageOfferSuccessResultOffer) MustOffer() OfferEntry {
	val, ok := u.GetOffer()

	if !ok {
		panic("arm Offer is not set")
	}

	return val
}

// GetOffer retrieves the Offer value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u ManageOfferSuccessResultOffer) GetOffer() (result OfferEntry, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Effect))

	if armName == "Offer" {
		result = *u.Offer
		ok = true
	}

	return
}

// ManageOfferSuccessResult is an XDR Struct defines as:
//
//   struct ManageOfferSuccessResult
//    {
//        // offers that got claimed while creating this offer
//        ClaimOfferAtom offersClaimed<>;
//
//        union switch (ManageOfferEffect effect)
//        {
//        case MANAGE_OFFER_CREATED:
//        case MANAGE_OFFER_UPDATED:
//            OfferEntry offer;
//        default:
//            void;
//        }
//        offer;
//    };
//
type ManageOfferSuccessResult struct {
	OffersClaimed []ClaimOfferAtom
	Offer         ManageOfferSuccessResultOffer
}

// ManageOfferResult is an XDR Union defines as:
//
//   union ManageOfferResult switch (ManageOfferResultCode code)
//    {
//    case MANAGE_OFFER_SUCCESS:
//        ManageOfferSuccessResult success;
//    default:
//        void;
//    };
//
type ManageOfferResult struct {
	Code    ManageOfferResultCode
	Success *ManageOfferSuccessResult
}

// SwitchFieldName returns the field name in which this union's
// discriminant is stored
func (u ManageOfferResult) SwitchFieldName() string {
	return "Code"
}

// ArmForSwitch returns which field name should be used for storing
// the value for an instance of ManageOfferResult
func (u ManageOfferResult) ArmForSwitch(sw int32) (string, bool) {
	switch ManageOfferResultCode(sw) {
	case ManageOfferResultCodeManageOfferSuccess:
		return "Success", true
	default:
		return "", true
	}
}

// NewManageOfferResultManageOfferSuccess creates a new  ManageOfferResult, initialized with
// ManageOfferResultCodeManageOfferSuccess as the disciminant and the provided val
func NewManageOfferResultManageOfferSuccess(val ManageOfferSuccessResult) ManageOfferResult {
	return ManageOfferResult{
		Code:    ManageOfferResultCodeManageOfferSuccess,
		Success: &val,
	}
}

// NewManageOfferResultManageOfferMalformed creates a new  ManageOfferResult, initialized with
// ManageOfferResultCodeManageOfferMalformed as the disciminant and the provided val
func NewManageOfferResultManageOfferMalformed() ManageOfferResult {
	return ManageOfferResult{
		Code: ManageOfferResultCodeManageOfferMalformed,
	}
}

// NewManageOfferResultManageOfferNoTrust creates a new  ManageOfferResult, initialized with
// ManageOfferResultCodeManageOfferNoTrust as the disciminant and the provided val
func NewManageOfferResultManageOfferNoTrust() ManageOfferResult {
	return ManageOfferResult{
		Code: ManageOfferResultCodeManageOfferNoTrust,
	}
}

// NewManageOfferResultManageOfferNotAuthorized creates a new  ManageOfferResult, initialized with
// ManageOfferResultCodeManageOfferNotAuthorized as the disciminant and the provided val
func NewManageOfferResultManageOfferNotAuthorized() ManageOfferResult {
	return ManageOfferResult{
		Code: ManageOfferResultCodeManageOfferNotAuthorized,
	}
}

// NewManageOfferResultManageOfferLineFull creates a new  ManageOfferResult, initialized with
// ManageOfferResultCodeManageOfferLineFull as the disciminant and the provided val
func NewManageOfferResultManageOfferLineFull() ManageOfferResult {
	return ManageOfferResult{
		Code: ManageOfferResultCodeManageOfferLineFull,
	}
}

// NewManageOfferResultManageOfferUnderfunded creates a new  ManageOfferResult, initialized with
// ManageOfferResultCodeManageOfferUnderfunded as the disciminant and the provided val
func NewManageOfferResultManageOfferUnderfunded() ManageOfferResult {
	return ManageOfferResult{
		Code: ManageOfferResultCodeManageOfferUnderfunded,
	}
}

// NewManageOfferResultManageOfferCrossSelf creates a new  ManageOfferResult, initialized with
// ManageOfferResultCodeManageOfferCrossSelf as the disciminant and the provided val
func NewManageOfferResultManageOfferCrossSelf() ManageOfferResult {
	return ManageOfferResult{
		Code: ManageOfferResultCodeManageOfferCrossSelf,
	}
}

// NewManageOfferResultManageOfferNotFound creates a new  ManageOfferResult, initialized with
// ManageOfferResultCodeManageOfferNotFound as the disciminant and the provided val
func NewManageOfferResultManageOfferNotFound() ManageOfferResult {
	return ManageOfferResult{
		Code: ManageOfferResultCodeManageOfferNotFound,
	}
}

// NewManageOfferResultManageOfferMismatch creates a new  ManageOfferResult, initialized with
// ManageOfferResultCodeManageOfferMismatch as the disciminant and the provided val
func NewManageOfferResultManageOfferMismatch() ManageOfferResult {
	return ManageOfferResult{
		Code: ManageOfferResultCodeManageOfferMismatch,
	}
}

// NewManageOfferResultManageOfferLowReserve creates a new  ManageOfferResult, initialized with
// ManageOfferResultCodeManageOfferLowReserve as the disciminant and the provided val
func NewManageOfferResultManageOfferLowReserve() ManageOfferResult {
	return ManageOfferResult{
		Code: ManageOfferResultCodeManageOfferLowReserve,
	}
}

// MustSuccess retrieves the Success value from the union,
// panicing if the value is not set.
func (u ManageOfferResult) MustSuccess() ManageOfferSuccessResult {
	val, ok := u.GetSuccess()

	if !ok {
		panic("arm Success is not set")
	}

	return val
}

// GetSuccess retrieves the Success value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u ManageOfferResult) GetSuccess() (result ManageOfferSuccessResult, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Code))

	if armName == "Success" {
		result = *u.Success
		ok = true
	}

	return
}

// SetOptionsResultCode is an XDR Enum defines as:
//
//   enum SetOptionsResultCode
//    {
//        // codes considered as "success" for the operation
//        SET_OPTIONS_SUCCESS = 0,
//        // codes considered as "failure" for the operation
//        SET_OPTIONS_LOW_RESERVE = -1,      // not enough funds to add a signer
//        SET_OPTIONS_TOO_MANY_SIGNERS = -2, // max number of signers already reached
//        SET_OPTIONS_BAD_FLAGS = -3,        // invalid combination of clear/set flags
//        SET_OPTIONS_INVALID_INFLATION = -4, // inflation account does not exist
//        SET_OPTIONS_CANT_CHANGE = -5,       // can no longer change this option
//        SET_OPTIONS_UNKNOWN_FLAG = -6		// can't set an unknown flag
//    };
//
type SetOptionsResultCode int32

const (
	SetOptionsResultCodeSetOptionsSuccess          SetOptionsResultCode = 0
	SetOptionsResultCodeSetOptionsLowReserve                            = -1
	SetOptionsResultCodeSetOptionsTooManySigner                         = -2
	SetOptionsResultCodeSetOptionsBadFlag                               = -3
	SetOptionsResultCodeSetOptionsInvalidInflation                      = -4
	SetOptionsResultCodeSetOptionsCantChange                            = -5
	SetOptionsResultCodeSetOptionsUnknownFlag                           = -6
)

var setOptionsResultCodeMap = map[int32]string{
	0:  "SetOptionsResultCodeSetOptionsSuccess",
	-1: "SetOptionsResultCodeSetOptionsLowReserve",
	-2: "SetOptionsResultCodeSetOptionsTooManySigner",
	-3: "SetOptionsResultCodeSetOptionsBadFlag",
	-4: "SetOptionsResultCodeSetOptionsInvalidInflation",
	-5: "SetOptionsResultCodeSetOptionsCantChange",
	-6: "SetOptionsResultCodeSetOptionsUnknownFlag",
}

// ValidEnum validates a proposed value for this enum.  Implements
// the Enum interface for SetOptionsResultCode
func (e SetOptionsResultCode) ValidEnum(v int32) bool {
	_, ok := setOptionsResultCodeMap[v]
	return ok
}

// String returns the name of `e`
func (e SetOptionsResultCode) String() string {
	name, _ := setOptionsResultCodeMap[int32(e)]
	return name
}

// SetOptionsResult is an XDR Union defines as:
//
//   union SetOptionsResult switch (SetOptionsResultCode code)
//    {
//    case SET_OPTIONS_SUCCESS:
//        void;
//    default:
//        void;
//    };
//
type SetOptionsResult struct {
	Code SetOptionsResultCode
}

// SwitchFieldName returns the field name in which this union's
// discriminant is stored
func (u SetOptionsResult) SwitchFieldName() string {
	return "Code"
}

// ArmForSwitch returns which field name should be used for storing
// the value for an instance of SetOptionsResult
func (u SetOptionsResult) ArmForSwitch(sw int32) (string, bool) {
	switch SetOptionsResultCode(sw) {
	case SetOptionsResultCodeSetOptionsSuccess:
		return "", true
	default:
		return "", true
	}
}

// NewSetOptionsResultSetOptionsSuccess creates a new  SetOptionsResult, initialized with
// SetOptionsResultCodeSetOptionsSuccess as the disciminant and the provided val
func NewSetOptionsResultSetOptionsSuccess() SetOptionsResult {
	return SetOptionsResult{
		Code: SetOptionsResultCodeSetOptionsSuccess,
	}
}

// NewSetOptionsResultSetOptionsLowReserve creates a new  SetOptionsResult, initialized with
// SetOptionsResultCodeSetOptionsLowReserve as the disciminant and the provided val
func NewSetOptionsResultSetOptionsLowReserve() SetOptionsResult {
	return SetOptionsResult{
		Code: SetOptionsResultCodeSetOptionsLowReserve,
	}
}

// NewSetOptionsResultSetOptionsTooManySigner creates a new  SetOptionsResult, initialized with
// SetOptionsResultCodeSetOptionsTooManySigner as the disciminant and the provided val
func NewSetOptionsResultSetOptionsTooManySigner() SetOptionsResult {
	return SetOptionsResult{
		Code: SetOptionsResultCodeSetOptionsTooManySigner,
	}
}

// NewSetOptionsResultSetOptionsBadFlag creates a new  SetOptionsResult, initialized with
// SetOptionsResultCodeSetOptionsBadFlag as the disciminant and the provided val
func NewSetOptionsResultSetOptionsBadFlag() SetOptionsResult {
	return SetOptionsResult{
		Code: SetOptionsResultCodeSetOptionsBadFlag,
	}
}

// NewSetOptionsResultSetOptionsInvalidInflation creates a new  SetOptionsResult, initialized with
// SetOptionsResultCodeSetOptionsInvalidInflation as the disciminant and the provided val
func NewSetOptionsResultSetOptionsInvalidInflation() SetOptionsResult {
	return SetOptionsResult{
		Code: SetOptionsResultCodeSetOptionsInvalidInflation,
	}
}

// NewSetOptionsResultSetOptionsCantChange creates a new  SetOptionsResult, initialized with
// SetOptionsResultCodeSetOptionsCantChange as the disciminant and the provided val
func NewSetOptionsResultSetOptionsCantChange() SetOptionsResult {
	return SetOptionsResult{
		Code: SetOptionsResultCodeSetOptionsCantChange,
	}
}

// NewSetOptionsResultSetOptionsUnknownFlag creates a new  SetOptionsResult, initialized with
// SetOptionsResultCodeSetOptionsUnknownFlag as the disciminant and the provided val
func NewSetOptionsResultSetOptionsUnknownFlag() SetOptionsResult {
	return SetOptionsResult{
		Code: SetOptionsResultCodeSetOptionsUnknownFlag,
	}
}

// ChangeTrustResultCode is an XDR Enum defines as:
//
//   enum ChangeTrustResultCode
//    {
//        // codes considered as "success" for the operation
//        CHANGE_TRUST_SUCCESS = 0,
//        // codes considered as "failure" for the operation
//        CHANGE_TRUST_MALFORMED = -1,     // bad input
//        CHANGE_TRUST_NO_ISSUER = -2,     // could not find issuer
//        CHANGE_TRUST_INVALID_LIMIT = -3, // cannot drop limit below balance
//        CHANGE_TRUST_LOW_RESERVE = -4 // not enough funds to create a new trust line
//    };
//
type ChangeTrustResultCode int32

const (
	ChangeTrustResultCodeChangeTrustSuccess      ChangeTrustResultCode = 0
	ChangeTrustResultCodeChangeTrustMalformed                          = -1
	ChangeTrustResultCodeChangeTrustNoIssuer                           = -2
	ChangeTrustResultCodeChangeTrustInvalidLimit                       = -3
	ChangeTrustResultCodeChangeTrustLowReserve                         = -4
)

var changeTrustResultCodeMap = map[int32]string{
	0:  "ChangeTrustResultCodeChangeTrustSuccess",
	-1: "ChangeTrustResultCodeChangeTrustMalformed",
	-2: "ChangeTrustResultCodeChangeTrustNoIssuer",
	-3: "ChangeTrustResultCodeChangeTrustInvalidLimit",
	-4: "ChangeTrustResultCodeChangeTrustLowReserve",
}

// ValidEnum validates a proposed value for this enum.  Implements
// the Enum interface for ChangeTrustResultCode
func (e ChangeTrustResultCode) ValidEnum(v int32) bool {
	_, ok := changeTrustResultCodeMap[v]
	return ok
}

// String returns the name of `e`
func (e ChangeTrustResultCode) String() string {
	name, _ := changeTrustResultCodeMap[int32(e)]
	return name
}

// ChangeTrustResult is an XDR Union defines as:
//
//   union ChangeTrustResult switch (ChangeTrustResultCode code)
//    {
//    case CHANGE_TRUST_SUCCESS:
//        void;
//    default:
//        void;
//    };
//
type ChangeTrustResult struct {
	Code ChangeTrustResultCode
}

// SwitchFieldName returns the field name in which this union's
// discriminant is stored
func (u ChangeTrustResult) SwitchFieldName() string {
	return "Code"
}

// ArmForSwitch returns which field name should be used for storing
// the value for an instance of ChangeTrustResult
func (u ChangeTrustResult) ArmForSwitch(sw int32) (string, bool) {
	switch ChangeTrustResultCode(sw) {
	case ChangeTrustResultCodeChangeTrustSuccess:
		return "", true
	default:
		return "", true
	}
}

// NewChangeTrustResultChangeTrustSuccess creates a new  ChangeTrustResult, initialized with
// ChangeTrustResultCodeChangeTrustSuccess as the disciminant and the provided val
func NewChangeTrustResultChangeTrustSuccess() ChangeTrustResult {
	return ChangeTrustResult{
		Code: ChangeTrustResultCodeChangeTrustSuccess,
	}
}

// NewChangeTrustResultChangeTrustMalformed creates a new  ChangeTrustResult, initialized with
// ChangeTrustResultCodeChangeTrustMalformed as the disciminant and the provided val
func NewChangeTrustResultChangeTrustMalformed() ChangeTrustResult {
	return ChangeTrustResult{
		Code: ChangeTrustResultCodeChangeTrustMalformed,
	}
}

// NewChangeTrustResultChangeTrustNoIssuer creates a new  ChangeTrustResult, initialized with
// ChangeTrustResultCodeChangeTrustNoIssuer as the disciminant and the provided val
func NewChangeTrustResultChangeTrustNoIssuer() ChangeTrustResult {
	return ChangeTrustResult{
		Code: ChangeTrustResultCodeChangeTrustNoIssuer,
	}
}

// NewChangeTrustResultChangeTrustInvalidLimit creates a new  ChangeTrustResult, initialized with
// ChangeTrustResultCodeChangeTrustInvalidLimit as the disciminant and the provided val
func NewChangeTrustResultChangeTrustInvalidLimit() ChangeTrustResult {
	return ChangeTrustResult{
		Code: ChangeTrustResultCodeChangeTrustInvalidLimit,
	}
}

// NewChangeTrustResultChangeTrustLowReserve creates a new  ChangeTrustResult, initialized with
// ChangeTrustResultCodeChangeTrustLowReserve as the disciminant and the provided val
func NewChangeTrustResultChangeTrustLowReserve() ChangeTrustResult {
	return ChangeTrustResult{
		Code: ChangeTrustResultCodeChangeTrustLowReserve,
	}
}

// AllowTrustResultCode is an XDR Enum defines as:
//
//   enum AllowTrustResultCode
//    {
//        // codes considered as "success" for the operation
//        ALLOW_TRUST_SUCCESS = 0,
//        // codes considered as "failure" for the operation
//        ALLOW_TRUST_MALFORMED = -1,     // currency is not CURRENCY_TYPE_ALPHANUM
//        ALLOW_TRUST_NO_TRUST_LINE = -2, // trustor does not have a trustline
//    									// source account does not require trust
//        ALLOW_TRUST_TRUST_NOT_REQUIRED = -3,
//        ALLOW_TRUST_CANT_REVOKE = -4    // source account can't revoke trust
//    };
//
type AllowTrustResultCode int32

const (
	AllowTrustResultCodeAllowTrustSuccess          AllowTrustResultCode = 0
	AllowTrustResultCodeAllowTrustMalformed                             = -1
	AllowTrustResultCodeAllowTrustNoTrustLine                           = -2
	AllowTrustResultCodeAllowTrustTrustNotRequired                      = -3
	AllowTrustResultCodeAllowTrustCantRevoke                            = -4
)

var allowTrustResultCodeMap = map[int32]string{
	0:  "AllowTrustResultCodeAllowTrustSuccess",
	-1: "AllowTrustResultCodeAllowTrustMalformed",
	-2: "AllowTrustResultCodeAllowTrustNoTrustLine",
	-3: "AllowTrustResultCodeAllowTrustTrustNotRequired",
	-4: "AllowTrustResultCodeAllowTrustCantRevoke",
}

// ValidEnum validates a proposed value for this enum.  Implements
// the Enum interface for AllowTrustResultCode
func (e AllowTrustResultCode) ValidEnum(v int32) bool {
	_, ok := allowTrustResultCodeMap[v]
	return ok
}

// String returns the name of `e`
func (e AllowTrustResultCode) String() string {
	name, _ := allowTrustResultCodeMap[int32(e)]
	return name
}

// AllowTrustResult is an XDR Union defines as:
//
//   union AllowTrustResult switch (AllowTrustResultCode code)
//    {
//    case ALLOW_TRUST_SUCCESS:
//        void;
//    default:
//        void;
//    };
//
type AllowTrustResult struct {
	Code AllowTrustResultCode
}

// SwitchFieldName returns the field name in which this union's
// discriminant is stored
func (u AllowTrustResult) SwitchFieldName() string {
	return "Code"
}

// ArmForSwitch returns which field name should be used for storing
// the value for an instance of AllowTrustResult
func (u AllowTrustResult) ArmForSwitch(sw int32) (string, bool) {
	switch AllowTrustResultCode(sw) {
	case AllowTrustResultCodeAllowTrustSuccess:
		return "", true
	default:
		return "", true
	}
}

// NewAllowTrustResultAllowTrustSuccess creates a new  AllowTrustResult, initialized with
// AllowTrustResultCodeAllowTrustSuccess as the disciminant and the provided val
func NewAllowTrustResultAllowTrustSuccess() AllowTrustResult {
	return AllowTrustResult{
		Code: AllowTrustResultCodeAllowTrustSuccess,
	}
}

// NewAllowTrustResultAllowTrustMalformed creates a new  AllowTrustResult, initialized with
// AllowTrustResultCodeAllowTrustMalformed as the disciminant and the provided val
func NewAllowTrustResultAllowTrustMalformed() AllowTrustResult {
	return AllowTrustResult{
		Code: AllowTrustResultCodeAllowTrustMalformed,
	}
}

// NewAllowTrustResultAllowTrustNoTrustLine creates a new  AllowTrustResult, initialized with
// AllowTrustResultCodeAllowTrustNoTrustLine as the disciminant and the provided val
func NewAllowTrustResultAllowTrustNoTrustLine() AllowTrustResult {
	return AllowTrustResult{
		Code: AllowTrustResultCodeAllowTrustNoTrustLine,
	}
}

// NewAllowTrustResultAllowTrustTrustNotRequired creates a new  AllowTrustResult, initialized with
// AllowTrustResultCodeAllowTrustTrustNotRequired as the disciminant and the provided val
func NewAllowTrustResultAllowTrustTrustNotRequired() AllowTrustResult {
	return AllowTrustResult{
		Code: AllowTrustResultCodeAllowTrustTrustNotRequired,
	}
}

// NewAllowTrustResultAllowTrustCantRevoke creates a new  AllowTrustResult, initialized with
// AllowTrustResultCodeAllowTrustCantRevoke as the disciminant and the provided val
func NewAllowTrustResultAllowTrustCantRevoke() AllowTrustResult {
	return AllowTrustResult{
		Code: AllowTrustResultCodeAllowTrustCantRevoke,
	}
}

// AccountMergeResultCode is an XDR Enum defines as:
//
//   enum AccountMergeResultCode
//    {
//        // codes considered as "success" for the operation
//        ACCOUNT_MERGE_SUCCESS = 0,
//        // codes considered as "failure" for the operation
//        ACCOUNT_MERGE_MALFORMED = -1,  // can't merge onto itself
//        ACCOUNT_MERGE_NO_ACCOUNT = -2, // destination does not exist
//        ACCOUNT_MERGE_HAS_CREDIT = -3, // account has active trust lines
//        ACCOUNT_MERGE_CREDIT_HELD = -4 // an issuer cannot be merged if used
//    };
//
type AccountMergeResultCode int32

const (
	AccountMergeResultCodeAccountMergeSuccess    AccountMergeResultCode = 0
	AccountMergeResultCodeAccountMergeMalformed                         = -1
	AccountMergeResultCodeAccountMergeNoAccount                         = -2
	AccountMergeResultCodeAccountMergeHasCredit                         = -3
	AccountMergeResultCodeAccountMergeCreditHeld                        = -4
)

var accountMergeResultCodeMap = map[int32]string{
	0:  "AccountMergeResultCodeAccountMergeSuccess",
	-1: "AccountMergeResultCodeAccountMergeMalformed",
	-2: "AccountMergeResultCodeAccountMergeNoAccount",
	-3: "AccountMergeResultCodeAccountMergeHasCredit",
	-4: "AccountMergeResultCodeAccountMergeCreditHeld",
}

// ValidEnum validates a proposed value for this enum.  Implements
// the Enum interface for AccountMergeResultCode
func (e AccountMergeResultCode) ValidEnum(v int32) bool {
	_, ok := accountMergeResultCodeMap[v]
	return ok
}

// String returns the name of `e`
func (e AccountMergeResultCode) String() string {
	name, _ := accountMergeResultCodeMap[int32(e)]
	return name
}

// AccountMergeResult is an XDR Union defines as:
//
//   union AccountMergeResult switch (AccountMergeResultCode code)
//    {
//    case ACCOUNT_MERGE_SUCCESS:
//        void;
//    default:
//        void;
//    };
//
type AccountMergeResult struct {
	Code AccountMergeResultCode
}

// SwitchFieldName returns the field name in which this union's
// discriminant is stored
func (u AccountMergeResult) SwitchFieldName() string {
	return "Code"
}

// ArmForSwitch returns which field name should be used for storing
// the value for an instance of AccountMergeResult
func (u AccountMergeResult) ArmForSwitch(sw int32) (string, bool) {
	switch AccountMergeResultCode(sw) {
	case AccountMergeResultCodeAccountMergeSuccess:
		return "", true
	default:
		return "", true
	}
}

// NewAccountMergeResultAccountMergeSuccess creates a new  AccountMergeResult, initialized with
// AccountMergeResultCodeAccountMergeSuccess as the disciminant and the provided val
func NewAccountMergeResultAccountMergeSuccess() AccountMergeResult {
	return AccountMergeResult{
		Code: AccountMergeResultCodeAccountMergeSuccess,
	}
}

// NewAccountMergeResultAccountMergeMalformed creates a new  AccountMergeResult, initialized with
// AccountMergeResultCodeAccountMergeMalformed as the disciminant and the provided val
func NewAccountMergeResultAccountMergeMalformed() AccountMergeResult {
	return AccountMergeResult{
		Code: AccountMergeResultCodeAccountMergeMalformed,
	}
}

// NewAccountMergeResultAccountMergeNoAccount creates a new  AccountMergeResult, initialized with
// AccountMergeResultCodeAccountMergeNoAccount as the disciminant and the provided val
func NewAccountMergeResultAccountMergeNoAccount() AccountMergeResult {
	return AccountMergeResult{
		Code: AccountMergeResultCodeAccountMergeNoAccount,
	}
}

// NewAccountMergeResultAccountMergeHasCredit creates a new  AccountMergeResult, initialized with
// AccountMergeResultCodeAccountMergeHasCredit as the disciminant and the provided val
func NewAccountMergeResultAccountMergeHasCredit() AccountMergeResult {
	return AccountMergeResult{
		Code: AccountMergeResultCodeAccountMergeHasCredit,
	}
}

// NewAccountMergeResultAccountMergeCreditHeld creates a new  AccountMergeResult, initialized with
// AccountMergeResultCodeAccountMergeCreditHeld as the disciminant and the provided val
func NewAccountMergeResultAccountMergeCreditHeld() AccountMergeResult {
	return AccountMergeResult{
		Code: AccountMergeResultCodeAccountMergeCreditHeld,
	}
}

// InflationResultCode is an XDR Enum defines as:
//
//   enum InflationResultCode
//    {
//        // codes considered as "success" for the operation
//        INFLATION_SUCCESS = 0,
//        // codes considered as "failure" for the operation
//        INFLATION_NOT_TIME = -1
//    };
//
type InflationResultCode int32

const (
	InflationResultCodeInflationSuccess InflationResultCode = 0
	InflationResultCodeInflationNotTime                     = -1
)

var inflationResultCodeMap = map[int32]string{
	0:  "InflationResultCodeInflationSuccess",
	-1: "InflationResultCodeInflationNotTime",
}

// ValidEnum validates a proposed value for this enum.  Implements
// the Enum interface for InflationResultCode
func (e InflationResultCode) ValidEnum(v int32) bool {
	_, ok := inflationResultCodeMap[v]
	return ok
}

// String returns the name of `e`
func (e InflationResultCode) String() string {
	name, _ := inflationResultCodeMap[int32(e)]
	return name
}

// InflationPayout is an XDR Struct defines as:
//
//   struct inflationPayout // or use PaymentResultAtom to limit types?
//    {
//        AccountID destination;
//        int64 amount;
//    };
//
type InflationPayout struct {
	Destination AccountId
	Amount      Int64
}

// InflationResult is an XDR Union defines as:
//
//   union InflationResult switch (InflationResultCode code)
//    {
//    case INFLATION_SUCCESS:
//        inflationPayout payouts<>;
//    default:
//        void;
//    };
//
type InflationResult struct {
	Code    InflationResultCode
	Payouts *[]InflationPayout
}

// SwitchFieldName returns the field name in which this union's
// discriminant is stored
func (u InflationResult) SwitchFieldName() string {
	return "Code"
}

// ArmForSwitch returns which field name should be used for storing
// the value for an instance of InflationResult
func (u InflationResult) ArmForSwitch(sw int32) (string, bool) {
	switch InflationResultCode(sw) {
	case InflationResultCodeInflationSuccess:
		return "Payouts", true
	default:
		return "", true
	}
}

// NewInflationResultInflationSuccess creates a new  InflationResult, initialized with
// InflationResultCodeInflationSuccess as the disciminant and the provided val
func NewInflationResultInflationSuccess(val []InflationPayout) InflationResult {
	return InflationResult{
		Code:    InflationResultCodeInflationSuccess,
		Payouts: &val,
	}
}

// NewInflationResultInflationNotTime creates a new  InflationResult, initialized with
// InflationResultCodeInflationNotTime as the disciminant and the provided val
func NewInflationResultInflationNotTime() InflationResult {
	return InflationResult{
		Code: InflationResultCodeInflationNotTime,
	}
}

// MustPayouts retrieves the Payouts value from the union,
// panicing if the value is not set.
func (u InflationResult) MustPayouts() []InflationPayout {
	val, ok := u.GetPayouts()

	if !ok {
		panic("arm Payouts is not set")
	}

	return val
}

// GetPayouts retrieves the Payouts value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u InflationResult) GetPayouts() (result []InflationPayout, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Code))

	if armName == "Payouts" {
		result = *u.Payouts
		ok = true
	}

	return
}

// OperationResultCode is an XDR Enum defines as:
//
//   enum OperationResultCode
//    {
//        opINNER = 0, // inner object result is valid
//
//        opBAD_AUTH = -1,  // not enough signatures to perform operation
//        opNO_ACCOUNT = -2 // source account was not found
//    };
//
type OperationResultCode int32

const (
	OperationResultCodeOpInner     OperationResultCode = 0
	OperationResultCodeOpBadAuth                       = -1
	OperationResultCodeOpNoAccount                     = -2
)

var operationResultCodeMap = map[int32]string{
	0:  "OperationResultCodeOpInner",
	-1: "OperationResultCodeOpBadAuth",
	-2: "OperationResultCodeOpNoAccount",
}

// ValidEnum validates a proposed value for this enum.  Implements
// the Enum interface for OperationResultCode
func (e OperationResultCode) ValidEnum(v int32) bool {
	_, ok := operationResultCodeMap[v]
	return ok
}

// String returns the name of `e`
func (e OperationResultCode) String() string {
	name, _ := operationResultCodeMap[int32(e)]
	return name
}

// OperationResultTr is an XDR NestedUnion defines as:
//
//   union switch (OperationType type)
//        {
//        case CREATE_ACCOUNT:
//            CreateAccountResult createAccountResult;
//        case PAYMENT:
//            PaymentResult paymentResult;
//        case PATH_PAYMENT:
//            PathPaymentResult pathPaymentResult;
//        case MANAGE_OFFER:
//            ManageOfferResult manageOfferResult;
//        case CREATE_PASSIVE_OFFER:
//            ManageOfferResult createPassiveOfferResult;
//        case SET_OPTIONS:
//            SetOptionsResult setOptionsResult;
//        case CHANGE_TRUST:
//            ChangeTrustResult changeTrustResult;
//        case ALLOW_TRUST:
//            AllowTrustResult allowTrustResult;
//        case ACCOUNT_MERGE:
//            AccountMergeResult accountMergeResult;
//        case INFLATION:
//            InflationResult inflationResult;
//        }
//
type OperationResultTr struct {
	Type                     OperationType
	CreateAccountResult      *CreateAccountResult
	PaymentResult            *PaymentResult
	PathPaymentResult        *PathPaymentResult
	ManageOfferResult        *ManageOfferResult
	CreatePassiveOfferResult *ManageOfferResult
	SetOptionsResult         *SetOptionsResult
	ChangeTrustResult        *ChangeTrustResult
	AllowTrustResult         *AllowTrustResult
	AccountMergeResult       *AccountMergeResult
	InflationResult          *InflationResult
}

// SwitchFieldName returns the field name in which this union's
// discriminant is stored
func (u OperationResultTr) SwitchFieldName() string {
	return "Type"
}

// ArmForSwitch returns which field name should be used for storing
// the value for an instance of OperationResultTr
func (u OperationResultTr) ArmForSwitch(sw int32) (string, bool) {
	switch OperationType(sw) {
	case OperationTypeCreateAccount:
		return "CreateAccountResult", true
	case OperationTypePayment:
		return "PaymentResult", true
	case OperationTypePathPayment:
		return "PathPaymentResult", true
	case OperationTypeManageOffer:
		return "ManageOfferResult", true
	case OperationTypeCreatePassiveOffer:
		return "CreatePassiveOfferResult", true
	case OperationTypeSetOption:
		return "SetOptionsResult", true
	case OperationTypeChangeTrust:
		return "ChangeTrustResult", true
	case OperationTypeAllowTrust:
		return "AllowTrustResult", true
	case OperationTypeAccountMerge:
		return "AccountMergeResult", true
	case OperationTypeInflation:
		return "InflationResult", true
	}

	return "-", false
}

// NewOperationResultTrCreateAccount creates a new  OperationResultTr, initialized with
// OperationTypeCreateAccount as the disciminant and the provided val
func NewOperationResultTrCreateAccount(val CreateAccountResult) OperationResultTr {
	return OperationResultTr{
		Type:                OperationTypeCreateAccount,
		CreateAccountResult: &val,
	}
}

// NewOperationResultTrPayment creates a new  OperationResultTr, initialized with
// OperationTypePayment as the disciminant and the provided val
func NewOperationResultTrPayment(val PaymentResult) OperationResultTr {
	return OperationResultTr{
		Type:          OperationTypePayment,
		PaymentResult: &val,
	}
}

// NewOperationResultTrPathPayment creates a new  OperationResultTr, initialized with
// OperationTypePathPayment as the disciminant and the provided val
func NewOperationResultTrPathPayment(val PathPaymentResult) OperationResultTr {
	return OperationResultTr{
		Type:              OperationTypePathPayment,
		PathPaymentResult: &val,
	}
}

// NewOperationResultTrManageOffer creates a new  OperationResultTr, initialized with
// OperationTypeManageOffer as the disciminant and the provided val
func NewOperationResultTrManageOffer(val ManageOfferResult) OperationResultTr {
	return OperationResultTr{
		Type:              OperationTypeManageOffer,
		ManageOfferResult: &val,
	}
}

// NewOperationResultTrCreatePassiveOffer creates a new  OperationResultTr, initialized with
// OperationTypeCreatePassiveOffer as the disciminant and the provided val
func NewOperationResultTrCreatePassiveOffer(val ManageOfferResult) OperationResultTr {
	return OperationResultTr{
		Type: OperationTypeCreatePassiveOffer,
		CreatePassiveOfferResult: &val,
	}
}

// NewOperationResultTrSetOption creates a new  OperationResultTr, initialized with
// OperationTypeSetOption as the disciminant and the provided val
func NewOperationResultTrSetOption(val SetOptionsResult) OperationResultTr {
	return OperationResultTr{
		Type:             OperationTypeSetOption,
		SetOptionsResult: &val,
	}
}

// NewOperationResultTrChangeTrust creates a new  OperationResultTr, initialized with
// OperationTypeChangeTrust as the disciminant and the provided val
func NewOperationResultTrChangeTrust(val ChangeTrustResult) OperationResultTr {
	return OperationResultTr{
		Type:              OperationTypeChangeTrust,
		ChangeTrustResult: &val,
	}
}

// NewOperationResultTrAllowTrust creates a new  OperationResultTr, initialized with
// OperationTypeAllowTrust as the disciminant and the provided val
func NewOperationResultTrAllowTrust(val AllowTrustResult) OperationResultTr {
	return OperationResultTr{
		Type:             OperationTypeAllowTrust,
		AllowTrustResult: &val,
	}
}

// NewOperationResultTrAccountMerge creates a new  OperationResultTr, initialized with
// OperationTypeAccountMerge as the disciminant and the provided val
func NewOperationResultTrAccountMerge(val AccountMergeResult) OperationResultTr {
	return OperationResultTr{
		Type:               OperationTypeAccountMerge,
		AccountMergeResult: &val,
	}
}

// NewOperationResultTrInflation creates a new  OperationResultTr, initialized with
// OperationTypeInflation as the disciminant and the provided val
func NewOperationResultTrInflation(val InflationResult) OperationResultTr {
	return OperationResultTr{
		Type:            OperationTypeInflation,
		InflationResult: &val,
	}
}

// MustCreateAccountResult retrieves the CreateAccountResult value from the union,
// panicing if the value is not set.
func (u OperationResultTr) MustCreateAccountResult() CreateAccountResult {
	val, ok := u.GetCreateAccountResult()

	if !ok {
		panic("arm CreateAccountResult is not set")
	}

	return val
}

// GetCreateAccountResult retrieves the CreateAccountResult value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u OperationResultTr) GetCreateAccountResult() (result CreateAccountResult, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "CreateAccountResult" {
		result = *u.CreateAccountResult
		ok = true
	}

	return
}

// MustPaymentResult retrieves the PaymentResult value from the union,
// panicing if the value is not set.
func (u OperationResultTr) MustPaymentResult() PaymentResult {
	val, ok := u.GetPaymentResult()

	if !ok {
		panic("arm PaymentResult is not set")
	}

	return val
}

// GetPaymentResult retrieves the PaymentResult value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u OperationResultTr) GetPaymentResult() (result PaymentResult, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "PaymentResult" {
		result = *u.PaymentResult
		ok = true
	}

	return
}

// MustPathPaymentResult retrieves the PathPaymentResult value from the union,
// panicing if the value is not set.
func (u OperationResultTr) MustPathPaymentResult() PathPaymentResult {
	val, ok := u.GetPathPaymentResult()

	if !ok {
		panic("arm PathPaymentResult is not set")
	}

	return val
}

// GetPathPaymentResult retrieves the PathPaymentResult value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u OperationResultTr) GetPathPaymentResult() (result PathPaymentResult, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "PathPaymentResult" {
		result = *u.PathPaymentResult
		ok = true
	}

	return
}

// MustManageOfferResult retrieves the ManageOfferResult value from the union,
// panicing if the value is not set.
func (u OperationResultTr) MustManageOfferResult() ManageOfferResult {
	val, ok := u.GetManageOfferResult()

	if !ok {
		panic("arm ManageOfferResult is not set")
	}

	return val
}

// GetManageOfferResult retrieves the ManageOfferResult value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u OperationResultTr) GetManageOfferResult() (result ManageOfferResult, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "ManageOfferResult" {
		result = *u.ManageOfferResult
		ok = true
	}

	return
}

// MustCreatePassiveOfferResult retrieves the CreatePassiveOfferResult value from the union,
// panicing if the value is not set.
func (u OperationResultTr) MustCreatePassiveOfferResult() ManageOfferResult {
	val, ok := u.GetCreatePassiveOfferResult()

	if !ok {
		panic("arm CreatePassiveOfferResult is not set")
	}

	return val
}

// GetCreatePassiveOfferResult retrieves the CreatePassiveOfferResult value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u OperationResultTr) GetCreatePassiveOfferResult() (result ManageOfferResult, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "CreatePassiveOfferResult" {
		result = *u.CreatePassiveOfferResult
		ok = true
	}

	return
}

// MustSetOptionsResult retrieves the SetOptionsResult value from the union,
// panicing if the value is not set.
func (u OperationResultTr) MustSetOptionsResult() SetOptionsResult {
	val, ok := u.GetSetOptionsResult()

	if !ok {
		panic("arm SetOptionsResult is not set")
	}

	return val
}

// GetSetOptionsResult retrieves the SetOptionsResult value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u OperationResultTr) GetSetOptionsResult() (result SetOptionsResult, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "SetOptionsResult" {
		result = *u.SetOptionsResult
		ok = true
	}

	return
}

// MustChangeTrustResult retrieves the ChangeTrustResult value from the union,
// panicing if the value is not set.
func (u OperationResultTr) MustChangeTrustResult() ChangeTrustResult {
	val, ok := u.GetChangeTrustResult()

	if !ok {
		panic("arm ChangeTrustResult is not set")
	}

	return val
}

// GetChangeTrustResult retrieves the ChangeTrustResult value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u OperationResultTr) GetChangeTrustResult() (result ChangeTrustResult, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "ChangeTrustResult" {
		result = *u.ChangeTrustResult
		ok = true
	}

	return
}

// MustAllowTrustResult retrieves the AllowTrustResult value from the union,
// panicing if the value is not set.
func (u OperationResultTr) MustAllowTrustResult() AllowTrustResult {
	val, ok := u.GetAllowTrustResult()

	if !ok {
		panic("arm AllowTrustResult is not set")
	}

	return val
}

// GetAllowTrustResult retrieves the AllowTrustResult value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u OperationResultTr) GetAllowTrustResult() (result AllowTrustResult, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "AllowTrustResult" {
		result = *u.AllowTrustResult
		ok = true
	}

	return
}

// MustAccountMergeResult retrieves the AccountMergeResult value from the union,
// panicing if the value is not set.
func (u OperationResultTr) MustAccountMergeResult() AccountMergeResult {
	val, ok := u.GetAccountMergeResult()

	if !ok {
		panic("arm AccountMergeResult is not set")
	}

	return val
}

// GetAccountMergeResult retrieves the AccountMergeResult value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u OperationResultTr) GetAccountMergeResult() (result AccountMergeResult, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "AccountMergeResult" {
		result = *u.AccountMergeResult
		ok = true
	}

	return
}

// MustInflationResult retrieves the InflationResult value from the union,
// panicing if the value is not set.
func (u OperationResultTr) MustInflationResult() InflationResult {
	val, ok := u.GetInflationResult()

	if !ok {
		panic("arm InflationResult is not set")
	}

	return val
}

// GetInflationResult retrieves the InflationResult value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u OperationResultTr) GetInflationResult() (result InflationResult, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "InflationResult" {
		result = *u.InflationResult
		ok = true
	}

	return
}

// OperationResult is an XDR Union defines as:
//
//   union OperationResult switch (OperationResultCode code)
//    {
//    case opINNER:
//        union switch (OperationType type)
//        {
//        case CREATE_ACCOUNT:
//            CreateAccountResult createAccountResult;
//        case PAYMENT:
//            PaymentResult paymentResult;
//        case PATH_PAYMENT:
//            PathPaymentResult pathPaymentResult;
//        case MANAGE_OFFER:
//            ManageOfferResult manageOfferResult;
//        case CREATE_PASSIVE_OFFER:
//            ManageOfferResult createPassiveOfferResult;
//        case SET_OPTIONS:
//            SetOptionsResult setOptionsResult;
//        case CHANGE_TRUST:
//            ChangeTrustResult changeTrustResult;
//        case ALLOW_TRUST:
//            AllowTrustResult allowTrustResult;
//        case ACCOUNT_MERGE:
//            AccountMergeResult accountMergeResult;
//        case INFLATION:
//            InflationResult inflationResult;
//        }
//        tr;
//    default:
//        void;
//    };
//
type OperationResult struct {
	Code OperationResultCode
	Tr   *OperationResultTr
}

// SwitchFieldName returns the field name in which this union's
// discriminant is stored
func (u OperationResult) SwitchFieldName() string {
	return "Code"
}

// ArmForSwitch returns which field name should be used for storing
// the value for an instance of OperationResult
func (u OperationResult) ArmForSwitch(sw int32) (string, bool) {
	switch OperationResultCode(sw) {
	case OperationResultCodeOpInner:
		return "Tr", true
	default:
		return "", true
	}
}

// NewOperationResultOpInner creates a new  OperationResult, initialized with
// OperationResultCodeOpInner as the disciminant and the provided val
func NewOperationResultOpInner(val OperationResultTr) OperationResult {
	return OperationResult{
		Code: OperationResultCodeOpInner,
		Tr:   &val,
	}
}

// NewOperationResultOpBadAuth creates a new  OperationResult, initialized with
// OperationResultCodeOpBadAuth as the disciminant and the provided val
func NewOperationResultOpBadAuth() OperationResult {
	return OperationResult{
		Code: OperationResultCodeOpBadAuth,
	}
}

// NewOperationResultOpNoAccount creates a new  OperationResult, initialized with
// OperationResultCodeOpNoAccount as the disciminant and the provided val
func NewOperationResultOpNoAccount() OperationResult {
	return OperationResult{
		Code: OperationResultCodeOpNoAccount,
	}
}

// MustTr retrieves the Tr value from the union,
// panicing if the value is not set.
func (u OperationResult) MustTr() OperationResultTr {
	val, ok := u.GetTr()

	if !ok {
		panic("arm Tr is not set")
	}

	return val
}

// GetTr retrieves the Tr value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u OperationResult) GetTr() (result OperationResultTr, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Code))

	if armName == "Tr" {
		result = *u.Tr
		ok = true
	}

	return
}

// TransactionResultCode is an XDR Enum defines as:
//
//   enum TransactionResultCode
//    {
//        txSUCCESS = 0, // all operations succeeded
//
//        txFAILED = -1, // one of the operations failed (but none were applied)
//
//        txTOO_EARLY = -2,         // ledger closeTime before minTime
//        txTOO_LATE = -3,          // ledger closeTime after maxTime
//        txMISSING_OPERATION = -4, // no operation was specified
//        txBAD_SEQ = -5,           // sequence number does not match source account
//
//        txBAD_AUTH = -6,             // not enough signatures to perform transaction
//        txINSUFFICIENT_BALANCE = -7, // fee would bring account below reserve
//        txNO_ACCOUNT = -8,           // source account not found
//        txINSUFFICIENT_FEE = -9,     // fee is too small
//        txBAD_AUTH_EXTRA = -10,      // too many signatures on transaction
//        txINTERNAL_ERROR = -11       // an unknown error occured
//    };
//
type TransactionResultCode int32

const (
	TransactionResultCodeTxSuccess             TransactionResultCode = 0
	TransactionResultCodeTxFailed                                    = -1
	TransactionResultCodeTxTooEarly                                  = -2
	TransactionResultCodeTxTooLate                                   = -3
	TransactionResultCodeTxMissingOperation                          = -4
	TransactionResultCodeTxBadSeq                                    = -5
	TransactionResultCodeTxBadAuth                                   = -6
	TransactionResultCodeTxInsufficientBalance                       = -7
	TransactionResultCodeTxNoAccount                                 = -8
	TransactionResultCodeTxInsufficientFee                           = -9
	TransactionResultCodeTxBadAuthExtra                              = -10
	TransactionResultCodeTxInternalError                             = -11
)

var transactionResultCodeMap = map[int32]string{
	0:   "TransactionResultCodeTxSuccess",
	-1:  "TransactionResultCodeTxFailed",
	-2:  "TransactionResultCodeTxTooEarly",
	-3:  "TransactionResultCodeTxTooLate",
	-4:  "TransactionResultCodeTxMissingOperation",
	-5:  "TransactionResultCodeTxBadSeq",
	-6:  "TransactionResultCodeTxBadAuth",
	-7:  "TransactionResultCodeTxInsufficientBalance",
	-8:  "TransactionResultCodeTxNoAccount",
	-9:  "TransactionResultCodeTxInsufficientFee",
	-10: "TransactionResultCodeTxBadAuthExtra",
	-11: "TransactionResultCodeTxInternalError",
}

// ValidEnum validates a proposed value for this enum.  Implements
// the Enum interface for TransactionResultCode
func (e TransactionResultCode) ValidEnum(v int32) bool {
	_, ok := transactionResultCodeMap[v]
	return ok
}

// String returns the name of `e`
func (e TransactionResultCode) String() string {
	name, _ := transactionResultCodeMap[int32(e)]
	return name
}

// TransactionResultResult is an XDR NestedUnion defines as:
//
//   union switch (TransactionResultCode code)
//        {
//        case txSUCCESS:
//        case txFAILED:
//            OperationResult results<>;
//        default:
//            void;
//        }
//
type TransactionResultResult struct {
	Code    TransactionResultCode
	Results *[]OperationResult
}

// SwitchFieldName returns the field name in which this union's
// discriminant is stored
func (u TransactionResultResult) SwitchFieldName() string {
	return "Code"
}

// ArmForSwitch returns which field name should be used for storing
// the value for an instance of TransactionResultResult
func (u TransactionResultResult) ArmForSwitch(sw int32) (string, bool) {
	switch TransactionResultCode(sw) {
	case TransactionResultCodeTxSuccess:
		return "Results", true
	case TransactionResultCodeTxFailed:
		return "Results", true
	default:
		return "", true
	}
}

// NewTransactionResultResultTxSuccess creates a new  TransactionResultResult, initialized with
// TransactionResultCodeTxSuccess as the disciminant and the provided val
func NewTransactionResultResultTxSuccess(val []OperationResult) TransactionResultResult {
	return TransactionResultResult{
		Code:    TransactionResultCodeTxSuccess,
		Results: &val,
	}
}

// NewTransactionResultResultTxFailed creates a new  TransactionResultResult, initialized with
// TransactionResultCodeTxFailed as the disciminant and the provided val
func NewTransactionResultResultTxFailed(val []OperationResult) TransactionResultResult {
	return TransactionResultResult{
		Code:    TransactionResultCodeTxFailed,
		Results: &val,
	}
}

// NewTransactionResultResultTxTooEarly creates a new  TransactionResultResult, initialized with
// TransactionResultCodeTxTooEarly as the disciminant and the provided val
func NewTransactionResultResultTxTooEarly() TransactionResultResult {
	return TransactionResultResult{
		Code: TransactionResultCodeTxTooEarly,
	}
}

// NewTransactionResultResultTxTooLate creates a new  TransactionResultResult, initialized with
// TransactionResultCodeTxTooLate as the disciminant and the provided val
func NewTransactionResultResultTxTooLate() TransactionResultResult {
	return TransactionResultResult{
		Code: TransactionResultCodeTxTooLate,
	}
}

// NewTransactionResultResultTxMissingOperation creates a new  TransactionResultResult, initialized with
// TransactionResultCodeTxMissingOperation as the disciminant and the provided val
func NewTransactionResultResultTxMissingOperation() TransactionResultResult {
	return TransactionResultResult{
		Code: TransactionResultCodeTxMissingOperation,
	}
}

// NewTransactionResultResultTxBadSeq creates a new  TransactionResultResult, initialized with
// TransactionResultCodeTxBadSeq as the disciminant and the provided val
func NewTransactionResultResultTxBadSeq() TransactionResultResult {
	return TransactionResultResult{
		Code: TransactionResultCodeTxBadSeq,
	}
}

// NewTransactionResultResultTxBadAuth creates a new  TransactionResultResult, initialized with
// TransactionResultCodeTxBadAuth as the disciminant and the provided val
func NewTransactionResultResultTxBadAuth() TransactionResultResult {
	return TransactionResultResult{
		Code: TransactionResultCodeTxBadAuth,
	}
}

// NewTransactionResultResultTxInsufficientBalance creates a new  TransactionResultResult, initialized with
// TransactionResultCodeTxInsufficientBalance as the disciminant and the provided val
func NewTransactionResultResultTxInsufficientBalance() TransactionResultResult {
	return TransactionResultResult{
		Code: TransactionResultCodeTxInsufficientBalance,
	}
}

// NewTransactionResultResultTxNoAccount creates a new  TransactionResultResult, initialized with
// TransactionResultCodeTxNoAccount as the disciminant and the provided val
func NewTransactionResultResultTxNoAccount() TransactionResultResult {
	return TransactionResultResult{
		Code: TransactionResultCodeTxNoAccount,
	}
}

// NewTransactionResultResultTxInsufficientFee creates a new  TransactionResultResult, initialized with
// TransactionResultCodeTxInsufficientFee as the disciminant and the provided val
func NewTransactionResultResultTxInsufficientFee() TransactionResultResult {
	return TransactionResultResult{
		Code: TransactionResultCodeTxInsufficientFee,
	}
}

// NewTransactionResultResultTxBadAuthExtra creates a new  TransactionResultResult, initialized with
// TransactionResultCodeTxBadAuthExtra as the disciminant and the provided val
func NewTransactionResultResultTxBadAuthExtra() TransactionResultResult {
	return TransactionResultResult{
		Code: TransactionResultCodeTxBadAuthExtra,
	}
}

// NewTransactionResultResultTxInternalError creates a new  TransactionResultResult, initialized with
// TransactionResultCodeTxInternalError as the disciminant and the provided val
func NewTransactionResultResultTxInternalError() TransactionResultResult {
	return TransactionResultResult{
		Code: TransactionResultCodeTxInternalError,
	}
}

// MustResults retrieves the Results value from the union,
// panicing if the value is not set.
func (u TransactionResultResult) MustResults() []OperationResult {
	val, ok := u.GetResults()

	if !ok {
		panic("arm Results is not set")
	}

	return val
}

// GetResults retrieves the Results value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u TransactionResultResult) GetResults() (result []OperationResult, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Code))

	if armName == "Results" {
		result = *u.Results
		ok = true
	}

	return
}

// TransactionResult is an XDR Struct defines as:
//
//   struct TransactionResult
//    {
//        int64 feeCharged; // actual fee charged for the transaction
//
//        union switch (TransactionResultCode code)
//        {
//        case txSUCCESS:
//        case txFAILED:
//            OperationResult results<>;
//        default:
//            void;
//        }
//        result;
//    };
//
type TransactionResult struct {
	FeeCharged Int64
	Result     TransactionResultResult
}

// Uint512 is an XDR Typedef defines as:
//
//   typedef opaque uint512[64];
//
type Uint512 [64]byte

// Int64 is an XDR Typedef defines as:
//
//   typedef hyper int64;
//
type Int64 int64

// Int32 is an XDR Typedef defines as:
//
//   typedef int int32;
//
type Int32 int32

// AccountId is an XDR Typedef defines as:
//
//   typedef opaque AccountID[32];
//
type AccountId [32]byte

// Thresholds is an XDR Typedef defines as:
//
//   typedef opaque Thresholds[4];
//
type Thresholds [4]byte

// String32 is an XDR Typedef defines as:
//
//   typedef string string32<32>;
//
type String32 string

// SequenceNumber is an XDR Typedef defines as:
//
//   typedef uint64 SequenceNumber;
//
type SequenceNumber Uint64

// CurrencyType is an XDR Enum defines as:
//
//   enum CurrencyType
//    {
//        CURRENCY_TYPE_NATIVE = 0,
//        CURRENCY_TYPE_ALPHANUM = 1
//    };
//
type CurrencyType int32

const (
	CurrencyTypeCurrencyTypeNative   CurrencyType = 0
	CurrencyTypeCurrencyTypeAlphanum              = 1
)

var currencyTypeMap = map[int32]string{
	0: "CurrencyTypeCurrencyTypeNative",
	1: "CurrencyTypeCurrencyTypeAlphanum",
}

// ValidEnum validates a proposed value for this enum.  Implements
// the Enum interface for CurrencyType
func (e CurrencyType) ValidEnum(v int32) bool {
	_, ok := currencyTypeMap[v]
	return ok
}

// String returns the name of `e`
func (e CurrencyType) String() string {
	name, _ := currencyTypeMap[int32(e)]
	return name
}

// CurrencyAlphaNum is an XDR NestedStruct defines as:
//
//   struct
//        {
//            opaque currencyCode[4];
//            AccountID issuer;
//        }
//
type CurrencyAlphaNum struct {
	CurrencyCode [4]byte
	Issuer       AccountId
}

// Currency is an XDR Union defines as:
//
//   union Currency switch (CurrencyType type)
//    {
//    case CURRENCY_TYPE_NATIVE:
//        void;
//
//    case CURRENCY_TYPE_ALPHANUM:
//        struct
//        {
//            opaque currencyCode[4];
//            AccountID issuer;
//        } alphaNum;
//
//        // add other currency types here in the future
//    };
//
type Currency struct {
	Type     CurrencyType
	AlphaNum *CurrencyAlphaNum
}

// SwitchFieldName returns the field name in which this union's
// discriminant is stored
func (u Currency) SwitchFieldName() string {
	return "Type"
}

// ArmForSwitch returns which field name should be used for storing
// the value for an instance of Currency
func (u Currency) ArmForSwitch(sw int32) (string, bool) {
	switch CurrencyType(sw) {
	case CurrencyTypeCurrencyTypeNative:
		return "", true
	case CurrencyTypeCurrencyTypeAlphanum:
		return "AlphaNum", true
	}

	return "-", false
}

// NewCurrencyCurrencyTypeNative creates a new  Currency, initialized with
// CurrencyTypeCurrencyTypeNative as the disciminant and the provided val
func NewCurrencyCurrencyTypeNative() Currency {
	return Currency{
		Type: CurrencyTypeCurrencyTypeNative,
	}
}

// NewCurrencyCurrencyTypeAlphanum creates a new  Currency, initialized with
// CurrencyTypeCurrencyTypeAlphanum as the disciminant and the provided val
func NewCurrencyCurrencyTypeAlphanum(val CurrencyAlphaNum) Currency {
	return Currency{
		Type:     CurrencyTypeCurrencyTypeAlphanum,
		AlphaNum: &val,
	}
}

// MustAlphaNum retrieves the AlphaNum value from the union,
// panicing if the value is not set.
func (u Currency) MustAlphaNum() CurrencyAlphaNum {
	val, ok := u.GetAlphaNum()

	if !ok {
		panic("arm AlphaNum is not set")
	}

	return val
}

// GetAlphaNum retrieves the AlphaNum value from the union,
// returning ok if the union's switch indicated the value is valid.
func (u Currency) GetAlphaNum() (result CurrencyAlphaNum, ok bool) {
	armName, _ := u.ArmForSwitch(int32(u.Type))

	if armName == "AlphaNum" {
		result = *u.AlphaNum
		ok = true
	}

	return
}

// Price is an XDR Struct defines as:
//
//   struct Price
//    {
//        int32 n; // numerator
//        int32 d; // denominator
//    };
//
type Price struct {
	N Int32
	D Int32
}
