--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

DROP INDEX public.unique_schema_migrations;
DROP INDEX public.index_history_transaction_statuses_lc_on_all;
DROP INDEX public.index_history_transaction_participants_on_transaction_hash;
DROP INDEX public.index_history_transaction_participants_on_account;
DROP INDEX public.index_history_operations_on_type;
DROP INDEX public.index_history_operations_on_transaction_id;
DROP INDEX public.index_history_operations_on_id;
DROP INDEX public.index_history_ledgers_on_sequence;
DROP INDEX public.index_history_ledgers_on_previous_ledger_hash;
DROP INDEX public.index_history_ledgers_on_ledger_hash;
DROP INDEX public.index_history_ledgers_on_closed_at;
DROP INDEX public.index_history_accounts_on_id;
DROP INDEX public.hs_transaction_by_id;
DROP INDEX public.hs_ledger_by_id;
DROP INDEX public.hist_op_p_id;
DROP INDEX public.by_status;
DROP INDEX public.by_ledger;
DROP INDEX public.by_hash;
DROP INDEX public.by_account;
ALTER TABLE ONLY public.history_transaction_statuses DROP CONSTRAINT history_transaction_statuses_pkey;
ALTER TABLE ONLY public.history_transaction_participants DROP CONSTRAINT history_transaction_participants_pkey;
ALTER TABLE ONLY public.history_operation_participants DROP CONSTRAINT history_operation_participants_pkey;
ALTER TABLE public.history_transaction_statuses ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.history_transaction_participants ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.history_operation_participants ALTER COLUMN id DROP DEFAULT;
DROP TABLE public.schema_migrations;
DROP TABLE public.history_transactions;
DROP SEQUENCE public.history_transaction_statuses_id_seq;
DROP TABLE public.history_transaction_statuses;
DROP SEQUENCE public.history_transaction_participants_id_seq;
DROP TABLE public.history_transaction_participants;
DROP TABLE public.history_operations;
DROP SEQUENCE public.history_operation_participants_id_seq;
DROP TABLE public.history_operation_participants;
DROP TABLE public.history_ledgers;
DROP TABLE public.history_accounts;
DROP EXTENSION hstore;
DROP EXTENSION plpgsql;
DROP SCHEMA public;
--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: history_accounts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE history_accounts (
    id bigint NOT NULL,
    address character varying(64)
);


--
-- Name: history_ledgers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE history_ledgers (
    sequence integer NOT NULL,
    ledger_hash character varying(64) NOT NULL,
    previous_ledger_hash character varying(64),
    transaction_count integer DEFAULT 0 NOT NULL,
    operation_count integer DEFAULT 0 NOT NULL,
    closed_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id bigint
);


--
-- Name: history_operation_participants; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE history_operation_participants (
    id integer NOT NULL,
    history_operation_id bigint NOT NULL,
    history_account_id bigint NOT NULL
);


--
-- Name: history_operation_participants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE history_operation_participants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: history_operation_participants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE history_operation_participants_id_seq OWNED BY history_operation_participants.id;


--
-- Name: history_operations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE history_operations (
    id bigint NOT NULL,
    transaction_id bigint NOT NULL,
    application_order integer NOT NULL,
    type integer NOT NULL,
    details jsonb
);


--
-- Name: history_transaction_participants; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE history_transaction_participants (
    id integer NOT NULL,
    transaction_hash character varying(64) NOT NULL,
    account character varying(64) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: history_transaction_participants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE history_transaction_participants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: history_transaction_participants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE history_transaction_participants_id_seq OWNED BY history_transaction_participants.id;


--
-- Name: history_transaction_statuses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE history_transaction_statuses (
    id integer NOT NULL,
    result_code_s character varying(255) NOT NULL,
    result_code integer NOT NULL
);


--
-- Name: history_transaction_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE history_transaction_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: history_transaction_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE history_transaction_statuses_id_seq OWNED BY history_transaction_statuses.id;


--
-- Name: history_transactions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE history_transactions (
    transaction_hash character varying(64) NOT NULL,
    ledger_sequence integer NOT NULL,
    application_order integer NOT NULL,
    account character varying(64) NOT NULL,
    account_sequence bigint NOT NULL,
    max_fee integer NOT NULL,
    fee_paid integer NOT NULL,
    operation_count integer NOT NULL,
    transaction_status_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id bigint
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY history_operation_participants ALTER COLUMN id SET DEFAULT nextval('history_operation_participants_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY history_transaction_participants ALTER COLUMN id SET DEFAULT nextval('history_transaction_participants_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY history_transaction_statuses ALTER COLUMN id SET DEFAULT nextval('history_transaction_statuses_id_seq'::regclass);


--
-- Data for Name: history_accounts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_accounts (id, address) FROM stdin;
0	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC
12884905984	gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq
12884910080	gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ
12884914176	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ
\.


--
-- Data for Name: history_ledgers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_ledgers (sequence, ledger_hash, previous_ledger_hash, transaction_count, operation_count, closed_at, created_at, updated_at, id) FROM stdin;
1	a9d12414d405652b752ce4425d3d94e7996a07a52228a58d7bf3bd35dd50eb46	\N	0	0	1970-01-01 00:00:00	2015-06-16 16:35:34.385494	2015-06-16 16:35:34.385494	4294967296
2	605128dc1b01efa246aa72b89e59271d44ae7fa49850e080b07a74e6dcd2c682	a9d12414d405652b752ce4425d3d94e7996a07a52228a58d7bf3bd35dd50eb46	0	0	2015-06-16 16:35:31	2015-06-16 16:35:34.394777	2015-06-16 16:35:34.394777	8589934592
3	56975170cbe54a9f06c9bb4330c3ffed005066dbcbc23768fedf44a6b5a98491	605128dc1b01efa246aa72b89e59271d44ae7fa49850e080b07a74e6dcd2c682	3	3	2015-06-16 16:35:32	2015-06-16 16:35:34.408597	2015-06-16 16:35:34.408597	12884901888
4	b8da2c9accb86effb3779e34adc58586d65bca499dc74a3351daf0f79d496eac	56975170cbe54a9f06c9bb4330c3ffed005066dbcbc23768fedf44a6b5a98491	4	4	2015-06-16 16:35:33	2015-06-16 16:35:34.497412	2015-06-16 16:35:34.497412	17179869184
5	e9cc849a88dd8dad83b518fe96ab993a7163e1b0b18368219dd35d94c8c20a4a	b8da2c9accb86effb3779e34adc58586d65bca499dc74a3351daf0f79d496eac	4	4	2015-06-16 16:35:34	2015-06-16 16:35:34.542106	2015-06-16 16:35:34.542106	21474836480
6	16aa837ad9a7a762a3be4d75f10ddd3cf597670c82a12483d2ef9de373447a6b	e9cc849a88dd8dad83b518fe96ab993a7163e1b0b18368219dd35d94c8c20a4a	6	6	2015-06-16 16:35:35	2015-06-16 16:35:34.586792	2015-06-16 16:35:34.586792	25769803776
7	3227b5adfd4c51727341a06c35c69127611c7c8569e1dd7c1acc4d19d8a93752	16aa837ad9a7a762a3be4d75f10ddd3cf597670c82a12483d2ef9de373447a6b	6	6	2015-06-16 16:35:36	2015-06-16 16:35:34.638878	2015-06-16 16:35:34.638878	30064771072
\.


--
-- Data for Name: history_operation_participants; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_operation_participants (id, history_operation_id, history_account_id) FROM stdin;
456	12884905984	0
457	12884905984	12884905984
458	12884910080	0
459	12884910080	12884910080
460	12884914176	0
461	12884914176	12884914176
462	17179873280	12884914176
463	17179877376	12884910080
464	17179881472	12884914176
465	17179885568	12884910080
466	21474840576	12884905984
467	21474840576	12884910080
468	21474844672	12884905984
469	21474844672	12884914176
470	21474848768	12884905984
471	21474848768	12884910080
472	21474852864	12884905984
473	21474852864	12884914176
474	25769807872	12884910080
475	25769811968	12884914176
476	25769816064	12884910080
477	25769820160	12884914176
478	25769824256	12884914176
479	25769828352	12884910080
480	30064775168	12884910080
481	30064779264	12884914176
482	30064783360	12884910080
483	30064787456	12884914176
484	30064791552	12884914176
485	30064795648	12884910080
\.


--
-- Name: history_operation_participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('history_operation_participants_id_seq', 485, true);


--
-- Data for Name: history_operations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_operations (id, transaction_id, application_order, type, details) FROM stdin;
12884905984	12884905984	0	0	{"funder": "gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC", "account": "gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq", "starting_balance": 10000000000}
12884910080	12884910080	0	0	{"funder": "gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC", "account": "gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ", "starting_balance": 10000000000}
12884914176	12884914176	0	0	{"funder": "gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC", "account": "gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ", "starting_balance": 10000000000}
17179873280	17179873280	0	6	{"limit": 9223372036854775807, "trustee": "gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq", "trustor": "gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ", "currency_code": "USD", "currency_type": "alphanum", "currency_issuer": "gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq"}
17179877376	17179877376	0	6	{"limit": 9223372036854775807, "trustee": "gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq", "trustor": "gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ", "currency_code": "USD", "currency_type": "alphanum", "currency_issuer": "gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq"}
17179881472	17179881472	0	6	{"limit": 9223372036854775807, "trustee": "gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq", "trustor": "gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ", "currency_code": "BTC", "currency_type": "alphanum", "currency_issuer": "gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq"}
17179885568	17179885568	0	6	{"limit": 9223372036854775807, "trustee": "gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq", "trustor": "gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ", "currency_code": "BTC", "currency_type": "alphanum", "currency_issuer": "gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq"}
21474840576	21474840576	0	1	{"to": "gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ", "from": "gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq", "amount": 5000, "currency_code": "USD", "currency_type": "alphanum", "currency_issuer": "gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq"}
21474844672	21474844672	0	1	{"to": "gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ", "from": "gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq", "amount": 5000, "currency_code": "USD", "currency_type": "alphanum", "currency_issuer": "gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq"}
21474848768	21474848768	0	1	{"to": "gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ", "from": "gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq", "amount": 5000, "currency_code": "BTC", "currency_type": "alphanum", "currency_issuer": "gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq"}
21474852864	21474852864	0	1	{"to": "gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ", "from": "gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq", "amount": 5000, "currency_code": "BTC", "currency_type": "alphanum", "currency_issuer": "gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq"}
25769807872	25769807872	0	3	{"price": {"d": 10, "n": 1}, "amount": 1, "offer_id": 0}
25769811968	25769811968	0	3	{"price": {"d": 1, "n": 15}, "amount": 10, "offer_id": 0}
25769816064	25769816064	0	3	{"price": {"d": 9, "n": 1}, "amount": 11, "offer_id": 0}
25769820160	25769820160	0	3	{"price": {"d": 1, "n": 20}, "amount": 100, "offer_id": 0}
25769824256	25769824256	0	3	{"price": {"d": 1, "n": 50}, "amount": 1000, "offer_id": 0}
25769828352	25769828352	0	3	{"price": {"d": 5, "n": 1}, "amount": 200, "offer_id": 0}
30064775168	30064775168	0	3	{"price": {"d": 10, "n": 1}, "amount": 1, "offer_id": 0}
30064779264	30064779264	0	3	{"price": {"d": 1, "n": 15}, "amount": 10, "offer_id": 0}
30064783360	30064783360	0	3	{"price": {"d": 9, "n": 1}, "amount": 11, "offer_id": 0}
30064787456	30064787456	0	3	{"price": {"d": 1, "n": 20}, "amount": 100, "offer_id": 0}
30064791552	30064791552	0	3	{"price": {"d": 1, "n": 50}, "amount": 1000, "offer_id": 0}
30064795648	30064795648	0	3	{"price": {"d": 5, "n": 1}, "amount": 200, "offer_id": 0}
\.


--
-- Data for Name: history_transaction_participants; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_transaction_participants (id, transaction_hash, account, created_at, updated_at) FROM stdin;
661	e2b3ecd737eb4c241e7abe15a6d079dbe1de708263f59d1882c05eb7d0e89c08	gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq	2015-06-16 16:35:34.444695	2015-06-16 16:35:34.444695
662	e2b3ecd737eb4c241e7abe15a6d079dbe1de708263f59d1882c05eb7d0e89c08	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2015-06-16 16:35:34.446432	2015-06-16 16:35:34.446432
663	9692abb6739c52f1b76a2bc1ecc515763e8c481f8c46ac0bb13386305040af99	gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	2015-06-16 16:35:34.468264	2015-06-16 16:35:34.468264
664	9692abb6739c52f1b76a2bc1ecc515763e8c481f8c46ac0bb13386305040af99	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2015-06-16 16:35:34.469235	2015-06-16 16:35:34.469235
665	7aa3ca5873e4f8bd88715475d8be02fe3d31c82becad84fe1b41541fd442ec21	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ	2015-06-16 16:35:34.479696	2015-06-16 16:35:34.479696
666	7aa3ca5873e4f8bd88715475d8be02fe3d31c82becad84fe1b41541fd442ec21	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2015-06-16 16:35:34.480652	2015-06-16 16:35:34.480652
667	f44b155ce8e6a7db7dd6294166bb710a481f102514b3c73fcada10ff20dca37c	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ	2015-06-16 16:35:34.50253	2015-06-16 16:35:34.50253
668	1b92d9a9651b11379a62c13a21958d516cf3dfe15f3628981243f0b4475c02fa	gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	2015-06-16 16:35:34.511074	2015-06-16 16:35:34.511074
669	2539e9b5d905c70fb01874c98fd3b4026118c6b0d487f2c33258c3dc8f805aab	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ	2015-06-16 16:35:34.51958	2015-06-16 16:35:34.51958
670	6926fd316741a0dcc449863a3f57e7e311311099be8d98d667c6c2c30da8ed13	gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	2015-06-16 16:35:34.527804	2015-06-16 16:35:34.527804
671	2a837e4ec972a058de2c94598f9e44478f1efdbc30f6e8302324e7b5485172d6	gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq	2015-06-16 16:35:34.546631	2015-06-16 16:35:34.546631
672	4e4af6fa9c4b4d908da5a9a3457d744baeef2aa858afec364d25510ac4698560	gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq	2015-06-16 16:35:34.555618	2015-06-16 16:35:34.555618
673	d292bdbc5d65e7b81c9fb81ac4201e6f64b117c048b93024c0a5822ff5ac7d45	gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq	2015-06-16 16:35:34.564046	2015-06-16 16:35:34.564046
674	7193ad8f9fc201eee35cad60fa456ad6373e46e06487814f74d064b95bb0e16b	gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq	2015-06-16 16:35:34.572688	2015-06-16 16:35:34.572688
675	24d3f1cea2ea00634fafc5a5247f17e003947e9ec5763235e3e8950ebfca169c	gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	2015-06-16 16:35:34.591246	2015-06-16 16:35:34.591246
676	f0957ad75f54e72aecf74032bb37ce2307032b6772fa8d4b28161eb975c1a623	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ	2015-06-16 16:35:34.59831	2015-06-16 16:35:34.59831
677	aab7ebae362461dfc6b5452fa507751ee05509d3015821b44e311f865c709f80	gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	2015-06-16 16:35:34.605351	2015-06-16 16:35:34.605351
678	53366442616e19a8fdcbbefe5fc7e4f35bc333d5c82cffad3b5a335aee105bc2	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ	2015-06-16 16:35:34.612252	2015-06-16 16:35:34.612252
679	88d133fe0c3b703ca6f62afa9434b840de8a3d8b0089e4732825dac556c96573	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ	2015-06-16 16:35:34.619067	2015-06-16 16:35:34.619067
680	f30d222e6f13c505946b3d499633dfc440af67d9eaea6a264e8fc01d2afdf5f0	gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	2015-06-16 16:35:34.626331	2015-06-16 16:35:34.626331
681	f99ecd57eadce52b981792264554ec6528c73b7bda3e828d65f26769476253e0	gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	2015-06-16 16:35:34.643154	2015-06-16 16:35:34.643154
682	82a463c3129e41293499fae5db1cc90f1f0710bf12bd33cb3a82d843c11aa311	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ	2015-06-16 16:35:34.650228	2015-06-16 16:35:34.650228
683	774d6fd7f515481d5374d4a1120236382b7a87f8172294aa6834480af3606037	gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	2015-06-16 16:35:34.657598	2015-06-16 16:35:34.657598
684	11b37de46c9846b3ac349b4cc64b06a0aee8c41205fb6e12be004759b4a07016	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ	2015-06-16 16:35:34.664933	2015-06-16 16:35:34.664933
685	38dfc4049bb6a5d4aa72264e556dd6140edc5264c1f6b02bf1ba3c452ee57620	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ	2015-06-16 16:35:34.671747	2015-06-16 16:35:34.671747
686	d655d70e665ac894085bf98db8d512e7963ec1b7dd611251a30813c46f2f3fa1	gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	2015-06-16 16:35:34.678759	2015-06-16 16:35:34.678759
\.


--
-- Name: history_transaction_participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('history_transaction_participants_id_seq', 686, true);


--
-- Data for Name: history_transaction_statuses; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_transaction_statuses (id, result_code_s, result_code) FROM stdin;
\.


--
-- Name: history_transaction_statuses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('history_transaction_statuses_id_seq', 1, false);


--
-- Data for Name: history_transactions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_transactions (transaction_hash, ledger_sequence, application_order, account, account_sequence, max_fee, fee_paid, operation_count, transaction_status_id, created_at, updated_at, id) FROM stdin;
e2b3ecd737eb4c241e7abe15a6d079dbe1de708263f59d1882c05eb7d0e89c08	3	1	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	1	10	10	1	-1	2015-06-16 16:35:34.438664	2015-06-16 16:35:34.438664	12884905984
9692abb6739c52f1b76a2bc1ecc515763e8c481f8c46ac0bb13386305040af99	3	2	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2	10	10	1	-1	2015-06-16 16:35:34.46657	2015-06-16 16:35:34.46657	12884910080
7aa3ca5873e4f8bd88715475d8be02fe3d31c82becad84fe1b41541fd442ec21	3	3	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	3	10	10	1	-1	2015-06-16 16:35:34.478069	2015-06-16 16:35:34.478069	12884914176
f44b155ce8e6a7db7dd6294166bb710a481f102514b3c73fcada10ff20dca37c	4	1	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ	12884901889	10	10	1	-1	2015-06-16 16:35:34.500487	2015-06-16 16:35:34.500487	17179873280
1b92d9a9651b11379a62c13a21958d516cf3dfe15f3628981243f0b4475c02fa	4	2	gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	12884901889	10	10	1	-1	2015-06-16 16:35:34.509206	2015-06-16 16:35:34.509206	17179877376
2539e9b5d905c70fb01874c98fd3b4026118c6b0d487f2c33258c3dc8f805aab	4	3	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ	12884901890	10	10	1	-1	2015-06-16 16:35:34.5179	2015-06-16 16:35:34.5179	17179881472
6926fd316741a0dcc449863a3f57e7e311311099be8d98d667c6c2c30da8ed13	4	4	gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	12884901890	10	10	1	-1	2015-06-16 16:35:34.526189	2015-06-16 16:35:34.526189	17179885568
2a837e4ec972a058de2c94598f9e44478f1efdbc30f6e8302324e7b5485172d6	5	1	gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq	12884901889	10	10	1	-1	2015-06-16 16:35:34.5451	2015-06-16 16:35:34.5451	21474840576
4e4af6fa9c4b4d908da5a9a3457d744baeef2aa858afec364d25510ac4698560	5	2	gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq	12884901890	10	10	1	-1	2015-06-16 16:35:34.554113	2015-06-16 16:35:34.554113	21474844672
d292bdbc5d65e7b81c9fb81ac4201e6f64b117c048b93024c0a5822ff5ac7d45	5	3	gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq	12884901891	10	10	1	-1	2015-06-16 16:35:34.56257	2015-06-16 16:35:34.56257	21474848768
7193ad8f9fc201eee35cad60fa456ad6373e46e06487814f74d064b95bb0e16b	5	4	gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq	12884901892	10	10	1	-1	2015-06-16 16:35:34.571171	2015-06-16 16:35:34.571171	21474852864
24d3f1cea2ea00634fafc5a5247f17e003947e9ec5763235e3e8950ebfca169c	6	1	gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	12884901891	10	10	1	-1	2015-06-16 16:35:34.589714	2015-06-16 16:35:34.589714	25769807872
f0957ad75f54e72aecf74032bb37ce2307032b6772fa8d4b28161eb975c1a623	6	2	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ	12884901891	10	10	1	-1	2015-06-16 16:35:34.596808	2015-06-16 16:35:34.596808	25769811968
aab7ebae362461dfc6b5452fa507751ee05509d3015821b44e311f865c709f80	6	3	gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	12884901892	10	10	1	-1	2015-06-16 16:35:34.603894	2015-06-16 16:35:34.603894	25769816064
53366442616e19a8fdcbbefe5fc7e4f35bc333d5c82cffad3b5a335aee105bc2	6	4	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ	12884901892	10	10	1	-1	2015-06-16 16:35:34.610763	2015-06-16 16:35:34.610763	25769820160
88d133fe0c3b703ca6f62afa9434b840de8a3d8b0089e4732825dac556c96573	6	5	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ	12884901893	10	10	1	-1	2015-06-16 16:35:34.61749	2015-06-16 16:35:34.61749	25769824256
f30d222e6f13c505946b3d499633dfc440af67d9eaea6a264e8fc01d2afdf5f0	6	6	gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	12884901893	10	10	1	-1	2015-06-16 16:35:34.624791	2015-06-16 16:35:34.624791	25769828352
f99ecd57eadce52b981792264554ec6528c73b7bda3e828d65f26769476253e0	7	1	gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	12884901894	10	10	1	-1	2015-06-16 16:35:34.641676	2015-06-16 16:35:34.641676	30064775168
82a463c3129e41293499fae5db1cc90f1f0710bf12bd33cb3a82d843c11aa311	7	2	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ	12884901894	10	10	1	-1	2015-06-16 16:35:34.648679	2015-06-16 16:35:34.648679	30064779264
774d6fd7f515481d5374d4a1120236382b7a87f8172294aa6834480af3606037	7	3	gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	12884901895	10	10	1	-1	2015-06-16 16:35:34.656095	2015-06-16 16:35:34.656095	30064783360
11b37de46c9846b3ac349b4cc64b06a0aee8c41205fb6e12be004759b4a07016	7	4	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ	12884901895	10	10	1	-1	2015-06-16 16:35:34.663357	2015-06-16 16:35:34.663357	30064787456
38dfc4049bb6a5d4aa72264e556dd6140edc5264c1f6b02bf1ba3c452ee57620	7	5	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ	12884901896	10	10	1	-1	2015-06-16 16:35:34.670342	2015-06-16 16:35:34.670342	30064791552
d655d70e665ac894085bf98db8d512e7963ec1b7dd611251a30813c46f2f3fa1	7	6	gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	12884901896	10	10	1	-1	2015-06-16 16:35:34.677267	2015-06-16 16:35:34.677267	30064795648
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY schema_migrations (version) FROM stdin;
20150501160031
20150310224849
20150313225945
20150313225955
20150508003829
20150508175821
20150508183542
20150508215546
20150609230237
\.


--
-- Name: history_operation_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY history_operation_participants
    ADD CONSTRAINT history_operation_participants_pkey PRIMARY KEY (id);


--
-- Name: history_transaction_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY history_transaction_participants
    ADD CONSTRAINT history_transaction_participants_pkey PRIMARY KEY (id);


--
-- Name: history_transaction_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY history_transaction_statuses
    ADD CONSTRAINT history_transaction_statuses_pkey PRIMARY KEY (id);


--
-- Name: by_account; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX by_account ON history_transactions USING btree (account, account_sequence);


--
-- Name: by_hash; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX by_hash ON history_transactions USING btree (transaction_hash);


--
-- Name: by_ledger; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX by_ledger ON history_transactions USING btree (ledger_sequence, application_order);


--
-- Name: by_status; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX by_status ON history_transactions USING btree (transaction_status_id);


--
-- Name: hist_op_p_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX hist_op_p_id ON history_operation_participants USING btree (history_account_id, history_operation_id);


--
-- Name: hs_ledger_by_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX hs_ledger_by_id ON history_ledgers USING btree (id);


--
-- Name: hs_transaction_by_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX hs_transaction_by_id ON history_transactions USING btree (id);


--
-- Name: index_history_accounts_on_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_history_accounts_on_id ON history_accounts USING btree (id);


--
-- Name: index_history_ledgers_on_closed_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_history_ledgers_on_closed_at ON history_ledgers USING btree (closed_at);


--
-- Name: index_history_ledgers_on_ledger_hash; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_history_ledgers_on_ledger_hash ON history_ledgers USING btree (ledger_hash);


--
-- Name: index_history_ledgers_on_previous_ledger_hash; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_history_ledgers_on_previous_ledger_hash ON history_ledgers USING btree (previous_ledger_hash);


--
-- Name: index_history_ledgers_on_sequence; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_history_ledgers_on_sequence ON history_ledgers USING btree (sequence);


--
-- Name: index_history_operations_on_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_history_operations_on_id ON history_operations USING btree (id);


--
-- Name: index_history_operations_on_transaction_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_history_operations_on_transaction_id ON history_operations USING btree (transaction_id);


--
-- Name: index_history_operations_on_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_history_operations_on_type ON history_operations USING btree (type);


--
-- Name: index_history_transaction_participants_on_account; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_history_transaction_participants_on_account ON history_transaction_participants USING btree (account);


--
-- Name: index_history_transaction_participants_on_transaction_hash; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_history_transaction_participants_on_transaction_hash ON history_transaction_participants USING btree (transaction_hash);


--
-- Name: index_history_transaction_statuses_lc_on_all; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_history_transaction_statuses_lc_on_all ON history_transaction_statuses USING btree (id, result_code, result_code_s);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: public; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM nullstyle;
GRANT ALL ON SCHEMA public TO nullstyle;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

