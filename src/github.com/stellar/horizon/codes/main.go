//Package codes is a helper package to help convert to transaction and operation result codes
//to strings used in horizon.
package codes

import (
	"github.com/go-errors/errors"
	"github.com/stellar/go-stellar-base/xdr"
)

var ErrUnknownCode = errors.New("Unknown result code")

//String returns the appropriate string representation of the provided result code
func String(code interface{}) (string, error) {
	switch code := code.(type) {
	case xdr.TransactionResultCode:
		switch code {
		case xdr.TransactionResultCodeTxSuccess:
			return "tx_success", nil
		case xdr.TransactionResultCodeTxFailed:
			return "tx_failed", nil
		case xdr.TransactionResultCodeTxTooEarly:
			return "tx_too_early", nil
		case xdr.TransactionResultCodeTxTooLate:
			return "tx_too_late", nil
		case xdr.TransactionResultCodeTxMissingOperation:
			return "tx_missing_operation", nil
		case xdr.TransactionResultCodeTxBadSeq:
			return "tx_bad_seq", nil
		case xdr.TransactionResultCodeTxBadAuth:
			return "tx_bad_auth", nil
		case xdr.TransactionResultCodeTxInsufficientBalance:
			return "tx_insufficient_balance", nil
		case xdr.TransactionResultCodeTxNoAccount:
			return "tx_no_account", nil
		case xdr.TransactionResultCodeTxInsufficientFee:
			return "tx_insufficient_fee", nil
		case xdr.TransactionResultCodeTxBadAuthExtra:
			return "tx_bad_auth_extra", nil
		case xdr.TransactionResultCodeTxInternalError:
			return "tx_internal_error", nil
		}
	case xdr.OperationResultCode:
		switch code {
		case xdr.OperationResultCodeOpInner:
			return "op_inner", nil
		case xdr.OperationResultCodeOpBadAuth:
			return "op_bad_auth", nil
		case xdr.OperationResultCodeOpNoAccount:
			return "op_no_account", nil
		}
	case xdr.CreateAccountResultCode:
		switch code {
		case xdr.CreateAccountResultCodeCreateAccountSuccess:
			return "op_success", nil
		case xdr.CreateAccountResultCodeCreateAccountMalformed:
			return "op_malformed", nil
		case xdr.CreateAccountResultCodeCreateAccountUnderfunded:
			return "op_underfunded", nil
		case xdr.CreateAccountResultCodeCreateAccountLowReserve:
			return "op_low_reserve", nil
		case xdr.CreateAccountResultCodeCreateAccountAlreadyExist:
			return "op_already_exists", nil
		}
	case xdr.PaymentResultCode:
		switch code {
		case xdr.PaymentResultCodePaymentSuccess:
			return "op_success", nil
		case xdr.PaymentResultCodePaymentMalformed:
			return "op_malformed", nil
		case xdr.PaymentResultCodePaymentUnderfunded:
			return "op_underfunded", nil
		case xdr.PaymentResultCodePaymentSrcNoTrust:
			return "op_src_no_trust", nil
		case xdr.PaymentResultCodePaymentSrcNotAuthorized:
			return "op_src_not_authorized", nil
		case xdr.PaymentResultCodePaymentNoDestination:
			return "op_no_destination", nil
		case xdr.PaymentResultCodePaymentNoTrust:
			return "op_no_trust", nil
		case xdr.PaymentResultCodePaymentNotAuthorized:
			return "op_not_authorized", nil
		case xdr.PaymentResultCodePaymentLineFull:
			return "op_line_full", nil
		case xdr.PaymentResultCodePaymentNoIssuer:
			return "op_no_issuer", nil
		}
	case xdr.PathPaymentResultCode:
		switch code {
		case xdr.PathPaymentResultCodePathPaymentSuccess:
			return "op_success", nil
		case xdr.PathPaymentResultCodePathPaymentMalformed:
			return "op_malformed", nil
		case xdr.PathPaymentResultCodePathPaymentUnderfunded:
			return "op_underfunded", nil
		case xdr.PathPaymentResultCodePathPaymentSrcNoTrust:
			return "op_src_no_trust", nil
		case xdr.PathPaymentResultCodePathPaymentSrcNotAuthorized:
			return "op_src_not_authorized", nil
		case xdr.PathPaymentResultCodePathPaymentNoDestination:
			return "op_no_destination", nil
		case xdr.PathPaymentResultCodePathPaymentNoTrust:
			return "op_no_trust", nil
		case xdr.PathPaymentResultCodePathPaymentNotAuthorized:
			return "op_not_authorized", nil
		case xdr.PathPaymentResultCodePathPaymentLineFull:
			return "op_line_full", nil
		case xdr.PathPaymentResultCodePathPaymentNoIssuer:
			return "op_no_issuer", nil
		case xdr.PathPaymentResultCodePathPaymentTooFewOffers:
			return "op_too_few_offers", nil
		case xdr.PathPaymentResultCodePathPaymentOfferCrossSelf:
			return "op_cross_self", nil
		case xdr.PathPaymentResultCodePathPaymentOverSendmax:
			return "op_over_source_max", nil
		}
	case xdr.ManageOfferResultCode:
		switch code {
		case xdr.ManageOfferResultCodeManageOfferSuccess:
			return "op_success", nil
		case xdr.ManageOfferResultCodeManageOfferMalformed:
			return "op_malformed", nil
		case xdr.ManageOfferResultCodeManageOfferSellNoTrust:
			return "op_sell_no_trust", nil
		case xdr.ManageOfferResultCodeManageOfferBuyNoTrust:
			return "op_buy_no_trust", nil
		case xdr.ManageOfferResultCodeManageOfferSellNotAuthorized:
			return "sell_not_authorized", nil
		case xdr.ManageOfferResultCodeManageOfferBuyNotAuthorized:
			return "buy_not_authorized", nil
		case xdr.ManageOfferResultCodeManageOfferLineFull:
			return "op_line_full", nil
		case xdr.ManageOfferResultCodeManageOfferUnderfunded:
			return "op_underfunded", nil
		case xdr.ManageOfferResultCodeManageOfferCrossSelf:
			return "op_cross_self", nil
		case xdr.ManageOfferResultCodeManageOfferSellNoIssuer:
			return "op_sell_no_issuer", nil
		case xdr.ManageOfferResultCodeManageOfferBuyNoIssuer:
			return "buy_no_issuer", nil
		case xdr.ManageOfferResultCodeManageOfferNotFound:
			return "op_offer_not_found", nil
		case xdr.ManageOfferResultCodeManageOfferLowReserve:
			return "op_low_reserve", nil
		}
	case xdr.SetOptionsResultCode:
		switch code {
		case xdr.SetOptionsResultCodeSetOptionsSuccess:
			return "op_success", nil
		case xdr.SetOptionsResultCodeSetOptionsLowReserve:
			return "op_low_reserve", nil
		case xdr.SetOptionsResultCodeSetOptionsTooManySigners:
			return "op_too_many_signers", nil
		case xdr.SetOptionsResultCodeSetOptionsBadFlags:
			return "op_bad_flags", nil
		case xdr.SetOptionsResultCodeSetOptionsInvalidInflation:
			return "op_invalid_inflation", nil
		case xdr.SetOptionsResultCodeSetOptionsCantChange:
			return "op_cant_change", nil
		case xdr.SetOptionsResultCodeSetOptionsUnknownFlag:
			return "op_unknown_flag", nil
		case xdr.SetOptionsResultCodeSetOptionsThresholdOutOfRange:
			return "op_threshold_out_of_range", nil
		case xdr.SetOptionsResultCodeSetOptionsBadSigner:
			return "op_bad_signer", nil
		case xdr.SetOptionsResultCodeSetOptionsInvalidHomeDomain:
			return "op_invalid_home_domain", nil
		}
	case xdr.ChangeTrustResultCode:
		switch code {
		case xdr.ChangeTrustResultCodeChangeTrustSuccess:
			return "op_success", nil
		case xdr.ChangeTrustResultCodeChangeTrustMalformed:
			return "op_malformed", nil
		case xdr.ChangeTrustResultCodeChangeTrustNoIssuer:
			return "op_no_issuer", nil
		case xdr.ChangeTrustResultCodeChangeTrustInvalidLimit:
			return "op_invalid_limit", nil
		case xdr.ChangeTrustResultCodeChangeTrustLowReserve:
			return "op_low_reserve", nil
		}
	case xdr.AllowTrustResultCode:
		switch code {
		case xdr.AllowTrustResultCodeAllowTrustSuccess:
			return "op_success", nil
		case xdr.AllowTrustResultCodeAllowTrustMalformed:
			return "op_malformed", nil
		case xdr.AllowTrustResultCodeAllowTrustNoTrustLine:
			return "op_no_trustline", nil
		case xdr.AllowTrustResultCodeAllowTrustTrustNotRequired:
			return "op_not_required", nil
		case xdr.AllowTrustResultCodeAllowTrustCantRevoke:
			return "op_cant_revoke", nil
		}
	case xdr.AccountMergeResultCode:
		switch code {
		case xdr.AccountMergeResultCodeAccountMergeSuccess:
			return "op_success", nil
		case xdr.AccountMergeResultCodeAccountMergeMalformed:
			return "op_malformed", nil
		case xdr.AccountMergeResultCodeAccountMergeNoAccount:
			return "op_no_account", nil
		case xdr.AccountMergeResultCodeAccountMergeImmutableSet:
			return "op_immutable_set", nil
		case xdr.AccountMergeResultCodeAccountMergeHasSubEntries:
			return "op_has_sub_entries", nil
		}
	case xdr.InflationResultCode:
		switch code {
		case xdr.InflationResultCodeInflationSuccess:
			return "op_success", nil
		case xdr.InflationResultCodeInflationNotTime:
			return "op_not_time", nil
		}
	}

	return "", errors.New(ErrUnknownCode)
}
