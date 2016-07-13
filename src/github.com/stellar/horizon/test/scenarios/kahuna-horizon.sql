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

DROP INDEX IF EXISTS public.trade_effects_by_order_book;
DROP INDEX IF EXISTS public.index_history_transactions_on_id;
DROP INDEX IF EXISTS public.index_history_operations_on_type;
DROP INDEX IF EXISTS public.index_history_operations_on_transaction_id;
DROP INDEX IF EXISTS public.index_history_operations_on_id;
DROP INDEX IF EXISTS public.index_history_ledgers_on_sequence;
DROP INDEX IF EXISTS public.index_history_ledgers_on_previous_ledger_hash;
DROP INDEX IF EXISTS public.index_history_ledgers_on_ledger_hash;
DROP INDEX IF EXISTS public.index_history_ledgers_on_importer_version;
DROP INDEX IF EXISTS public.index_history_ledgers_on_id;
DROP INDEX IF EXISTS public.index_history_ledgers_on_closed_at;
DROP INDEX IF EXISTS public.index_history_effects_on_type;
DROP INDEX IF EXISTS public.index_history_accounts_on_id;
DROP INDEX IF EXISTS public.index_history_accounts_on_address;
DROP INDEX IF EXISTS public.htp_by_htid;
DROP INDEX IF EXISTS public.hs_transaction_by_id;
DROP INDEX IF EXISTS public.hs_ledger_by_id;
DROP INDEX IF EXISTS public.hop_by_hoid;
DROP INDEX IF EXISTS public.hist_tx_p_id;
DROP INDEX IF EXISTS public.hist_op_p_id;
DROP INDEX IF EXISTS public.hist_e_id;
DROP INDEX IF EXISTS public.hist_e_by_order;
DROP INDEX IF EXISTS public.by_ledger;
DROP INDEX IF EXISTS public.by_hash;
DROP INDEX IF EXISTS public.by_account;
ALTER TABLE IF EXISTS ONLY public.history_transaction_participants DROP CONSTRAINT IF EXISTS history_transaction_participants_pkey;
ALTER TABLE IF EXISTS ONLY public.history_operation_participants DROP CONSTRAINT IF EXISTS history_operation_participants_pkey;
ALTER TABLE IF EXISTS ONLY public.gorp_migrations DROP CONSTRAINT IF EXISTS gorp_migrations_pkey;
ALTER TABLE IF EXISTS public.history_transaction_participants ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.history_operation_participants ALTER COLUMN id DROP DEFAULT;
DROP TABLE IF EXISTS public.history_transactions;
DROP SEQUENCE IF EXISTS public.history_transaction_participants_id_seq;
DROP TABLE IF EXISTS public.history_transaction_participants;
DROP TABLE IF EXISTS public.history_operations;
DROP SEQUENCE IF EXISTS public.history_operation_participants_id_seq;
DROP TABLE IF EXISTS public.history_operation_participants;
DROP TABLE IF EXISTS public.history_ledgers;
DROP TABLE IF EXISTS public.history_effects;
DROP TABLE IF EXISTS public.history_accounts;
DROP SEQUENCE IF EXISTS public.history_accounts_id_seq;
DROP TABLE IF EXISTS public.gorp_migrations;
DROP EXTENSION IF EXISTS plpgsql;
DROP SCHEMA IF EXISTS public;
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


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: gorp_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE gorp_migrations (
    id text NOT NULL,
    applied_at timestamp with time zone
);


--
-- Name: history_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE history_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: history_accounts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE history_accounts (
    id bigint DEFAULT nextval('history_accounts_id_seq'::regclass) NOT NULL,
    address character varying(64)
);


--
-- Name: history_effects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE history_effects (
    history_account_id bigint NOT NULL,
    history_operation_id bigint NOT NULL,
    "order" integer NOT NULL,
    type integer NOT NULL,
    details jsonb
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
    id bigint,
    importer_version integer DEFAULT 1 NOT NULL,
    total_coins bigint NOT NULL,
    fee_pool bigint NOT NULL,
    base_fee integer NOT NULL,
    base_reserve integer NOT NULL,
    max_tx_set_size integer NOT NULL
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
    details jsonb,
    source_account character varying(64) DEFAULT ''::character varying NOT NULL
);


--
-- Name: history_transaction_participants; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE history_transaction_participants (
    id integer NOT NULL,
    history_transaction_id bigint NOT NULL,
    history_account_id bigint NOT NULL
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
-- Name: history_transactions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE history_transactions (
    transaction_hash character varying(64) NOT NULL,
    ledger_sequence integer NOT NULL,
    application_order integer NOT NULL,
    account character varying(64) NOT NULL,
    account_sequence bigint NOT NULL,
    fee_paid integer NOT NULL,
    operation_count integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id bigint,
    tx_envelope text NOT NULL,
    tx_result text NOT NULL,
    tx_meta text NOT NULL,
    tx_fee_meta text NOT NULL,
    signatures character varying(96)[] DEFAULT '{}'::character varying[] NOT NULL,
    memo_type character varying DEFAULT 'none'::character varying NOT NULL,
    memo character varying,
    time_bounds int8range
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
-- Data for Name: gorp_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO gorp_migrations VALUES ('1_initial_schema.sql', '2016-06-28 15:12:02.483252-07');
INSERT INTO gorp_migrations VALUES ('2_index_participants_by_toid.sql', '2016-06-28 15:12:02.486221-07');
INSERT INTO gorp_migrations VALUES ('3_use_sequence_in_history_accounts.sql', '2016-06-28 15:12:02.487849-07');


--
-- Data for Name: history_accounts; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO history_accounts VALUES (1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_accounts VALUES (2, 'GAXI33UCLQTCKM2NMRBS7XYBR535LLEVAHL5YBN4FTCB4HZHT7ZA5CVK');
INSERT INTO history_accounts VALUES (3, 'GDXFAGJCSCI4CK2YHK6YRLA6TKEXFRX7BMGVMQOBMLIEUJRJ5YQNLMIB');
INSERT INTO history_accounts VALUES (4, 'GA46VRKBCLI2X6DXLX7AIEVRFLH3UA7XBE3NGNP6O74HQ5LXHMGTV2JB');
INSERT INTO history_accounts VALUES (5, 'GAG52TW6QAB6TGNMOTL32Y4M3UQQLNNNHPEHYAIYRP6SFF6ZAVRF5ZQY');
INSERT INTO history_accounts VALUES (6, 'GDCVTBGSEEU7KLXUMHMSXBALXJ2T4I2KOPXW2S5TRLKDRIAXD5UDHAYO');
INSERT INTO history_accounts VALUES (7, 'GCB7FPYGLL6RJ37HKRAYW5TAWMFBGGFGM4IM6ERBCZXI2BZ4OOOX2UAY');
INSERT INTO history_accounts VALUES (8, 'GCHC4D2CS45CJRNN4QAHT2LFZAJIU5PA7H53K3VOP6WEJ6XWHNSNZKQG');
INSERT INTO history_accounts VALUES (9, 'GANZGPKY5WSHWG5YOZMNG52GCK5SCJ4YGUWMJJVGZSK2FP4BI2JIJN2C');
INSERT INTO history_accounts VALUES (10, 'GDRW375MAYR46ODGF2WGANQC2RRZL7O246DYHHCGWTV2RE7IHE2QUQLD');
INSERT INTO history_accounts VALUES (11, 'GACAR2AEYEKITE2LKI5RMXF5MIVZ6Q7XILROGDT22O7JX4DSWFS7FDDP');
INSERT INTO history_accounts VALUES (12, 'GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU');
INSERT INTO history_accounts VALUES (13, 'GBOK7BOUSOWPHBANBYM6MIRYZJIDIPUYJPXHTHADF75UEVIVYWHHONQC');
INSERT INTO history_accounts VALUES (14, 'GB2QIYT2IAUFMRXKLSLLPRECC6OCOGJMADSPTRK7TGNT2SFR2YGWDARD');
INSERT INTO history_accounts VALUES (15, 'GB6GN3LJUW6JYR7EDOJ47VBH7D45M4JWHXGK6LHJRAEI5JBSN2DBQY7Q');
INSERT INTO history_accounts VALUES (16, 'GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES');
INSERT INTO history_accounts VALUES (17, 'GCJKJXPKBFIHOO3455WXWG5CDBZXQNYFRRGICYMPUQ35CPQ4WVS3KZLG');
INSERT INTO history_accounts VALUES (18, 'GCVW5LCRZFP7PENXTAGOVIQXADDNUXXZJCNKF4VQB2IK7W2LPJWF73UG');
INSERT INTO history_accounts VALUES (19, 'GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF');
INSERT INTO history_accounts VALUES (20, 'GCHPXGVDKPF5KT4CNAT7X77OXYZ7YVE4JHKFDUHCGCVWCL4K4PQ67KKZ');
INSERT INTO history_accounts VALUES (21, 'GDR53WAEIKOU3ZKN34CSHAWH7HV6K63CBJRUTWUDBFSMY7RRQK3SPKOS');
INSERT INTO history_accounts VALUES (22, 'GAYSCMKQY6EYLXOPTT6JPPOXDMVNBWITPTSZIVWW4LWARVBOTH5RTLAD');
INSERT INTO history_accounts VALUES (23, 'GACJPE4YUR22VP4CM2BDFDAHY3DLEF3H7NENKUQ53DT5TEI2GAHT5N4X');
INSERT INTO history_accounts VALUES (24, 'GANFZDRBCNTUXIODCJEYMACPMCSZEVE4WZGZ3CZDZ3P2SXK4KH75IK6Y');
INSERT INTO history_accounts VALUES (25, 'GAKNI7DPN7BGAB62BU4GQC364JCFXFV7KIVTTDVOQK2ZPBPSJETABDQU');


--
-- Name: history_accounts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('history_accounts_id_seq', 25, true);


--
-- Data for Name: history_effects; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO history_effects VALUES (2, 12884905985, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 12884905985, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (2, 12884905985, 3, 10, '{"weight": 1, "public_key": "GAXI33UCLQTCKM2NMRBS7XYBR535LLEVAHL5YBN4FTCB4HZHT7ZA5CVK"}');
INSERT INTO history_effects VALUES (3, 17179873281, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 17179873281, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (3, 17179873281, 3, 10, '{"weight": 1, "public_key": "GDXFAGJCSCI4CK2YHK6YRLA6TKEXFRX7BMGVMQOBMLIEUJRJ5YQNLMIB"}');
INSERT INTO history_effects VALUES (3, 21474840577, 1, 12, '{"weight": 1, "public_key": "GDXFAGJCSCI4CK2YHK6YRLA6TKEXFRX7BMGVMQOBMLIEUJRJ5YQNLMIB"}');
INSERT INTO history_effects VALUES (3, 21474844673, 1, 12, '{"weight": 1, "public_key": "GDXFAGJCSCI4CK2YHK6YRLA6TKEXFRX7BMGVMQOBMLIEUJRJ5YQNLMIB"}');
INSERT INTO history_effects VALUES (3, 21474844673, 2, 10, '{"weight": 1, "public_key": "GD3E7HKMRNT6HGBGHBT6I6JE4N2S4W5KZ246TGJ4KQSXJ2P4BXCUPQMP"}');
INSERT INTO history_effects VALUES (3, 21474848769, 1, 4, '{"low_threshold": 2, "med_threshold": 2, "high_threshold": 2}');
INSERT INTO history_effects VALUES (3, 21474848769, 2, 12, '{"weight": 1, "public_key": "GDXFAGJCSCI4CK2YHK6YRLA6TKEXFRX7BMGVMQOBMLIEUJRJ5YQNLMIB"}');
INSERT INTO history_effects VALUES (3, 21474848769, 3, 10, '{"weight": 1, "public_key": "GD3E7HKMRNT6HGBGHBT6I6JE4N2S4W5KZ246TGJ4KQSXJ2P4BXCUPQMP"}');
INSERT INTO history_effects VALUES (3, 25769807873, 1, 12, '{"weight": 2, "public_key": "GDXFAGJCSCI4CK2YHK6YRLA6TKEXFRX7BMGVMQOBMLIEUJRJ5YQNLMIB"}');
INSERT INTO history_effects VALUES (3, 25769807873, 2, 12, '{"weight": 1, "public_key": "GD3E7HKMRNT6HGBGHBT6I6JE4N2S4W5KZ246TGJ4KQSXJ2P4BXCUPQMP"}');
INSERT INTO history_effects VALUES (4, 30064775169, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 30064775169, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (4, 30064775169, 3, 10, '{"weight": 1, "public_key": "GA46VRKBCLI2X6DXLX7AIEVRFLH3UA7XBE3NGNP6O74HQ5LXHMGTV2JB"}');
INSERT INTO history_effects VALUES (1, 34359742465, 1, 2, '{"amount": "1.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (4, 34359742465, 2, 3, '{"amount": "1.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (1, 34359746561, 1, 2, '{"amount": "1.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (4, 34359746561, 2, 3, '{"amount": "1.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (1, 34359750657, 1, 2, '{"amount": "1.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (4, 34359750657, 2, 3, '{"amount": "1.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (1, 34359754753, 1, 2, '{"amount": "1.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (4, 34359754753, 2, 3, '{"amount": "1.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (5, 38654709761, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 38654709761, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (5, 38654709761, 3, 10, '{"weight": 1, "public_key": "GAG52TW6QAB6TGNMOTL32Y4M3UQQLNNNHPEHYAIYRP6SFF6ZAVRF5ZQY"}');
INSERT INTO history_effects VALUES (1, 42949677057, 1, 2, '{"amount": "10.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (5, 42949677057, 2, 3, '{"amount": "10.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (1, 42949677058, 1, 2, '{"amount": "10.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (5, 42949677058, 2, 3, '{"amount": "10.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (6, 47244644353, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 47244644353, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (6, 47244644353, 3, 10, '{"weight": 1, "public_key": "GDCVTBGSEEU7KLXUMHMSXBALXJ2T4I2KOPXW2S5TRLKDRIAXD5UDHAYO"}');
INSERT INTO history_effects VALUES (7, 51539611649, 1, 0, '{"starting_balance": "50.0000000"}');
INSERT INTO history_effects VALUES (6, 51539611649, 2, 3, '{"amount": "50.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (7, 51539611649, 3, 10, '{"weight": 1, "public_key": "GCB7FPYGLL6RJ37HKRAYW5TAWMFBGGFGM4IM6ERBCZXI2BZ4OOOX2UAY"}');
INSERT INTO history_effects VALUES (8, 55834578945, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 55834578945, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (8, 55834578945, 3, 10, '{"weight": 1, "public_key": "GCHC4D2CS45CJRNN4QAHT2LFZAJIU5PA7H53K3VOP6WEJ6XWHNSNZKQG"}');
INSERT INTO history_effects VALUES (9, 55834583041, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 55834583041, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (9, 55834583041, 3, 10, '{"weight": 1, "public_key": "GANZGPKY5WSHWG5YOZMNG52GCK5SCJ4YGUWMJJVGZSK2FP4BI2JIJN2C"}');
INSERT INTO history_effects VALUES (9, 60129546241, 1, 20, '{"limit": "922337203685.4775807", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GCHC4D2CS45CJRNN4QAHT2LFZAJIU5PA7H53K3VOP6WEJ6XWHNSNZKQG"}');
INSERT INTO history_effects VALUES (9, 60129550337, 1, 2, '{"amount": "10.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (8, 60129550337, 2, 3, '{"amount": "10.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (9, 64424513537, 1, 2, '{"amount": "10.0000000", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GCHC4D2CS45CJRNN4QAHT2LFZAJIU5PA7H53K3VOP6WEJ6XWHNSNZKQG"}');
INSERT INTO history_effects VALUES (8, 64424513537, 2, 3, '{"amount": "10.0000000", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GCHC4D2CS45CJRNN4QAHT2LFZAJIU5PA7H53K3VOP6WEJ6XWHNSNZKQG"}');
INSERT INTO history_effects VALUES (10, 68719480833, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 68719480833, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (10, 68719480833, 3, 10, '{"weight": 1, "public_key": "GDRW375MAYR46ODGF2WGANQC2RRZL7O246DYHHCGWTV2RE7IHE2QUQLD"}');
INSERT INTO history_effects VALUES (11, 68719484929, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 68719484929, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (11, 68719484929, 3, 10, '{"weight": 1, "public_key": "GACAR2AEYEKITE2LKI5RMXF5MIVZ6Q7XILROGDT22O7JX4DSWFS7FDDP"}');
INSERT INTO history_effects VALUES (12, 68719489025, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 68719489025, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (12, 68719489025, 3, 10, '{"weight": 1, "public_key": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU"}');
INSERT INTO history_effects VALUES (11, 73014448129, 1, 20, '{"limit": "922337203685.4775807", "asset_code": "EUR", "asset_type": "credit_alphanum4", "asset_issuer": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU"}');
INSERT INTO history_effects VALUES (10, 73014452225, 1, 20, '{"limit": "922337203685.4775807", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU"}');
INSERT INTO history_effects VALUES (10, 77309415425, 1, 2, '{"amount": "100.0000000", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU"}');
INSERT INTO history_effects VALUES (12, 77309415425, 2, 3, '{"amount": "100.0000000", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU"}');
INSERT INTO history_effects VALUES (11, 81604382721, 1, 2, '{"amount": "200.0000000", "asset_code": "EUR", "asset_type": "credit_alphanum4", "asset_issuer": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU"}');
INSERT INTO history_effects VALUES (10, 81604382721, 2, 3, '{"amount": "100.0000000", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU"}');
INSERT INTO history_effects VALUES (10, 81604382721, 3, 33, '{"seller": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU", "offer_id": 1, "sold_amount": "100.0000000", "bought_amount": "200.0000000", "sold_asset_code": "USD", "sold_asset_type": "credit_alphanum4", "bought_asset_type": "native", "sold_asset_issuer": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU"}');
INSERT INTO history_effects VALUES (12, 81604382721, 4, 33, '{"seller": "GDRW375MAYR46ODGF2WGANQC2RRZL7O246DYHHCGWTV2RE7IHE2QUQLD", "offer_id": 1, "sold_amount": "200.0000000", "bought_amount": "100.0000000", "sold_asset_type": "native", "bought_asset_code": "USD", "bought_asset_type": "credit_alphanum4", "bought_asset_issuer": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU"}');
INSERT INTO history_effects VALUES (10, 81604382721, 5, 33, '{"seller": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU", "offer_id": 2, "sold_amount": "200.0000000", "bought_amount": "200.0000000", "sold_asset_type": "native", "bought_asset_code": "EUR", "bought_asset_type": "credit_alphanum4", "bought_asset_issuer": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU"}');
INSERT INTO history_effects VALUES (12, 81604382721, 6, 33, '{"seller": "GDRW375MAYR46ODGF2WGANQC2RRZL7O246DYHHCGWTV2RE7IHE2QUQLD", "offer_id": 2, "sold_amount": "200.0000000", "bought_amount": "200.0000000", "sold_asset_code": "EUR", "sold_asset_type": "credit_alphanum4", "bought_asset_type": "native", "sold_asset_issuer": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU"}');
INSERT INTO history_effects VALUES (11, 85899350017, 1, 2, '{"amount": "100.0000000", "asset_code": "EUR", "asset_type": "credit_alphanum4", "asset_issuer": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU"}');
INSERT INTO history_effects VALUES (10, 85899350017, 2, 3, '{"amount": "100.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (10, 85899350017, 3, 33, '{"seller": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU", "offer_id": 2, "sold_amount": "100.0000000", "bought_amount": "100.0000000", "sold_asset_type": "native", "bought_asset_code": "EUR", "bought_asset_type": "credit_alphanum4", "bought_asset_issuer": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU"}');
INSERT INTO history_effects VALUES (12, 85899350017, 4, 33, '{"seller": "GDRW375MAYR46ODGF2WGANQC2RRZL7O246DYHHCGWTV2RE7IHE2QUQLD", "offer_id": 2, "sold_amount": "100.0000000", "bought_amount": "100.0000000", "sold_asset_code": "EUR", "sold_asset_type": "credit_alphanum4", "bought_asset_type": "native", "sold_asset_issuer": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU"}');
INSERT INTO history_effects VALUES (13, 90194317313, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 90194317313, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (13, 90194317313, 3, 10, '{"weight": 1, "public_key": "GBOK7BOUSOWPHBANBYM6MIRYZJIDIPUYJPXHTHADF75UEVIVYWHHONQC"}');
INSERT INTO history_effects VALUES (14, 90194321409, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 90194321409, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (14, 90194321409, 3, 10, '{"weight": 1, "public_key": "GB2QIYT2IAUFMRXKLSLLPRECC6OCOGJMADSPTRK7TGNT2SFR2YGWDARD"}');
INSERT INTO history_effects VALUES (13, 94489284609, 1, 20, '{"limit": "922337203685.4775807", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GB2QIYT2IAUFMRXKLSLLPRECC6OCOGJMADSPTRK7TGNT2SFR2YGWDARD"}');
INSERT INTO history_effects VALUES (14, 103079219201, 1, 33, '{"seller": "GBOK7BOUSOWPHBANBYM6MIRYZJIDIPUYJPXHTHADF75UEVIVYWHHONQC", "offer_id": 3, "sold_amount": "20.0000000", "bought_amount": "20.0000000", "sold_asset_code": "USD", "sold_asset_type": "credit_alphanum4", "bought_asset_type": "native", "sold_asset_issuer": "GB2QIYT2IAUFMRXKLSLLPRECC6OCOGJMADSPTRK7TGNT2SFR2YGWDARD"}');
INSERT INTO history_effects VALUES (13, 103079219201, 2, 33, '{"seller": "GB2QIYT2IAUFMRXKLSLLPRECC6OCOGJMADSPTRK7TGNT2SFR2YGWDARD", "offer_id": 3, "sold_amount": "20.0000000", "bought_amount": "20.0000000", "sold_asset_type": "native", "bought_asset_code": "USD", "bought_asset_type": "credit_alphanum4", "bought_asset_issuer": "GB2QIYT2IAUFMRXKLSLLPRECC6OCOGJMADSPTRK7TGNT2SFR2YGWDARD"}');
INSERT INTO history_effects VALUES (15, 107374186497, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 107374186497, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (15, 107374186497, 3, 10, '{"weight": 1, "public_key": "GB6GN3LJUW6JYR7EDOJ47VBH7D45M4JWHXGK6LHJRAEI5JBSN2DBQY7Q"}');
INSERT INTO history_effects VALUES (16, 115964121089, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 115964121089, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (16, 115964121089, 3, 10, '{"weight": 1, "public_key": "GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES"}');
INSERT INTO history_effects VALUES (16, 120259088385, 1, 12, '{"weight": 1, "public_key": "GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES"}');
INSERT INTO history_effects VALUES (16, 120259092481, 1, 6, '{"auth_required_flag": true}');
INSERT INTO history_effects VALUES (16, 120259092481, 2, 12, '{"weight": 1, "public_key": "GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES"}');
INSERT INTO history_effects VALUES (16, 120259096577, 1, 6, '{"auth_revocable_flag": true}');
INSERT INTO history_effects VALUES (16, 120259096577, 2, 12, '{"weight": 1, "public_key": "GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES"}');
INSERT INTO history_effects VALUES (16, 120259100673, 1, 12, '{"weight": 2, "public_key": "GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES"}');
INSERT INTO history_effects VALUES (16, 120259104769, 1, 4, '{"low_threshold": 0, "med_threshold": 2, "high_threshold": 2}');
INSERT INTO history_effects VALUES (16, 120259104769, 2, 12, '{"weight": 2, "public_key": "GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES"}');
INSERT INTO history_effects VALUES (16, 120259108865, 1, 5, '{"home_domain": "example.com"}');
INSERT INTO history_effects VALUES (16, 120259108865, 2, 12, '{"weight": 2, "public_key": "GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES"}');
INSERT INTO history_effects VALUES (16, 120259112961, 1, 12, '{"weight": 2, "public_key": "GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES"}');
INSERT INTO history_effects VALUES (16, 120259112961, 2, 10, '{"weight": 1, "public_key": "GB6J3WOLKYQE6KVDZEA4JDMFTTONUYP3PUHNDNZRWIKA6JQWIMJZATFE"}');
INSERT INTO history_effects VALUES (16, 124554055681, 1, 12, '{"weight": 2, "public_key": "GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES"}');
INSERT INTO history_effects VALUES (16, 124554055681, 2, 12, '{"weight": 1, "public_key": "GB6J3WOLKYQE6KVDZEA4JDMFTTONUYP3PUHNDNZRWIKA6JQWIMJZATFE"}');
INSERT INTO history_effects VALUES (16, 128849022977, 1, 12, '{"weight": 2, "public_key": "GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES"}');
INSERT INTO history_effects VALUES (16, 128849022977, 2, 12, '{"weight": 1, "public_key": "GB6J3WOLKYQE6KVDZEA4JDMFTTONUYP3PUHNDNZRWIKA6JQWIMJZATFE"}');
INSERT INTO history_effects VALUES (16, 133143990273, 1, 12, '{"weight": 2, "public_key": "GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES"}');
INSERT INTO history_effects VALUES (16, 133143990273, 2, 12, '{"weight": 5, "public_key": "GB6J3WOLKYQE6KVDZEA4JDMFTTONUYP3PUHNDNZRWIKA6JQWIMJZATFE"}');
INSERT INTO history_effects VALUES (16, 137438957569, 1, 6, '{"auth_required_flag": false, "auth_revocable_flag": false}');
INSERT INTO history_effects VALUES (16, 137438957569, 2, 12, '{"weight": 2, "public_key": "GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES"}');
INSERT INTO history_effects VALUES (16, 137438957569, 3, 12, '{"weight": 5, "public_key": "GB6J3WOLKYQE6KVDZEA4JDMFTTONUYP3PUHNDNZRWIKA6JQWIMJZATFE"}');
INSERT INTO history_effects VALUES (16, 137438961665, 1, 12, '{"weight": 2, "public_key": "GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES"}');
INSERT INTO history_effects VALUES (16, 137438961665, 2, 11, '{"public_key": "GB6J3WOLKYQE6KVDZEA4JDMFTTONUYP3PUHNDNZRWIKA6JQWIMJZATFE"}');
INSERT INTO history_effects VALUES (17, 141733924865, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 141733924865, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (17, 141733924865, 3, 10, '{"weight": 1, "public_key": "GCJKJXPKBFIHOO3455WXWG5CDBZXQNYFRRGICYMPUQ35CPQ4WVS3KZLG"}');
INSERT INTO history_effects VALUES (17, 146028892161, 1, 20, '{"limit": "922337203685.4775807", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H"}');
INSERT INTO history_effects VALUES (17, 150323859457, 1, 22, '{"limit": "100.0000000", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H"}');
INSERT INTO history_effects VALUES (17, 154618826753, 1, 22, '{"limit": "100.0000000", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H"}');
INSERT INTO history_effects VALUES (17, 158913794049, 1, 21, '{"limit": "0.0000000", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H"}');
INSERT INTO history_effects VALUES (18, 163208761345, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 163208761345, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (18, 163208761345, 3, 10, '{"weight": 1, "public_key": "GCVW5LCRZFP7PENXTAGOVIQXADDNUXXZJCNKF4VQB2IK7W2LPJWF73UG"}');
INSERT INTO history_effects VALUES (19, 163208765441, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 163208765441, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (19, 163208765441, 3, 10, '{"weight": 1, "public_key": "GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF"}');
INSERT INTO history_effects VALUES (19, 167503728641, 1, 6, '{"auth_required_flag": true, "auth_revocable_flag": true}');
INSERT INTO history_effects VALUES (19, 167503728641, 2, 12, '{"weight": 1, "public_key": "GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF"}');
INSERT INTO history_effects VALUES (18, 171798695937, 1, 20, '{"limit": "922337203685.4775807", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF"}');
INSERT INTO history_effects VALUES (18, 171798700033, 1, 20, '{"limit": "922337203685.4775807", "asset_code": "EUR", "asset_type": "credit_alphanum4", "asset_issuer": "GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF"}');
INSERT INTO history_effects VALUES (19, 176093663233, 1, 23, '{"trustor": "GCVW5LCRZFP7PENXTAGOVIQXADDNUXXZJCNKF4VQB2IK7W2LPJWF73UG", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF"}');
INSERT INTO history_effects VALUES (19, 176093667329, 1, 23, '{"trustor": "GCVW5LCRZFP7PENXTAGOVIQXADDNUXXZJCNKF4VQB2IK7W2LPJWF73UG", "asset_code": "EUR", "asset_type": "credit_alphanum4", "asset_issuer": "GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF"}');
INSERT INTO history_effects VALUES (19, 180388630529, 1, 24, '{"trustor": "GCVW5LCRZFP7PENXTAGOVIQXADDNUXXZJCNKF4VQB2IK7W2LPJWF73UG", "asset_code": "EUR", "asset_type": "credit_alphanum4", "asset_issuer": "GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF"}');
INSERT INTO history_effects VALUES (20, 184683597825, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 184683597825, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (20, 184683597825, 3, 10, '{"weight": 1, "public_key": "GCHPXGVDKPF5KT4CNAT7X77OXYZ7YVE4JHKFDUHCGCVWCL4K4PQ67KKZ"}');
INSERT INTO history_effects VALUES (20, 188978565121, 1, 3, '{"amount": "999.9999900", "asset_type": "native"}');
INSERT INTO history_effects VALUES (1, 188978565121, 2, 2, '{"amount": "999.9999900", "asset_type": "native"}');
INSERT INTO history_effects VALUES (20, 188978565121, 3, 1, '{}');
INSERT INTO history_effects VALUES (21, 193273532417, 1, 0, '{"starting_balance": "20000000000.0000000"}');
INSERT INTO history_effects VALUES (1, 193273532417, 2, 3, '{"amount": "20000000000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (21, 193273532417, 3, 10, '{"weight": 1, "public_key": "GDR53WAEIKOU3ZKN34CSHAWH7HV6K63CBJRUTWUDBFSMY7RRQK3SPKOS"}');
INSERT INTO history_effects VALUES (1, 197568499713, 1, 12, '{"weight": 1, "public_key": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H"}');
INSERT INTO history_effects VALUES (21, 197568503809, 1, 12, '{"weight": 1, "public_key": "GDR53WAEIKOU3ZKN34CSHAWH7HV6K63CBJRUTWUDBFSMY7RRQK3SPKOS"}');
INSERT INTO history_effects VALUES (1, 201863467009, 1, 2, '{"amount": "15257676.9536092", "asset_type": "native"}');
INSERT INTO history_effects VALUES (21, 201863467009, 2, 2, '{"amount": "3814420.0001419", "asset_type": "native"}');
INSERT INTO history_effects VALUES (22, 206158434305, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 206158434305, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (22, 206158434305, 3, 10, '{"weight": 1, "public_key": "GAYSCMKQY6EYLXOPTT6JPPOXDMVNBWITPTSZIVWW4LWARVBOTH5RTLAD"}');
INSERT INTO history_effects VALUES (22, 210453401601, 1, 40, '{"name": "name1", "value": "MTIzNA=="}');
INSERT INTO history_effects VALUES (22, 210453405697, 1, 40, '{"name": "name2", "value": "NTY3OA=="}');
INSERT INTO history_effects VALUES (22, 214748368897, 1, 41, '{"name": "name2"}');
INSERT INTO history_effects VALUES (22, 219043336193, 1, 42, '{"name": "name1", "value": "MTIzNA=="}');
INSERT INTO history_effects VALUES (22, 223338303489, 1, 42, '{"name": "name1", "value": "MDAwMA=="}');
INSERT INTO history_effects VALUES (23, 227633270785, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 227633270785, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (23, 227633270785, 3, 10, '{"weight": 1, "public_key": "GACJPE4YUR22VP4CM2BDFDAHY3DLEF3H7NENKUQ53DT5TEI2GAHT5N4X"}');
INSERT INTO history_effects VALUES (23, 231928238081, 1, 2, '{"amount": "10.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (1, 231928238081, 2, 3, '{"amount": "10.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (1, 231928238082, 1, 2, '{"amount": "10.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (23, 231928238082, 2, 3, '{"amount": "10.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (24, 236223205377, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 236223205377, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (24, 236223205377, 3, 10, '{"weight": 1, "public_key": "GANFZDRBCNTUXIODCJEYMACPMCSZEVE4WZGZ3CZDZ3P2SXK4KH75IK6Y"}');
INSERT INTO history_effects VALUES (24, 240518172673, 1, 2, '{"amount": "10.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (24, 240518172673, 2, 3, '{"amount": "10.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (25, 244813139969, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 244813139969, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (25, 244813139969, 3, 10, '{"weight": 1, "public_key": "GAKNI7DPN7BGAB62BU4GQC364JCFXFV7KIVTTDVOQK2ZPBPSJETABDQU"}');


--
-- Data for Name: history_ledgers; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO history_ledgers VALUES (1, '63d98f536ee68d1b27b5b89f23af5311b7569a24faf1403ad0b52b633b07be99', NULL, 0, 0, '1970-01-01 00:00:00', '2016-06-29 16:34:09.007367', '2016-06-29 16:34:09.007367', 4294967296, 8, 1000000000000000000, 0, 100, 100000000, 100);
INSERT INTO history_ledgers VALUES (2, 'fb22bbb0ead9bb480ec3044722b33ffd6b4946aecdbd8f788873f79c09f70335', '63d98f536ee68d1b27b5b89f23af5311b7569a24faf1403ad0b52b633b07be99', 0, 0, '2016-06-29 16:34:04', '2016-06-29 16:34:09.010774', '2016-06-29 16:34:09.010774', 8589934592, 8, 1000000000000000000, 0, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (3, '7cdae330dcecade466d466c4f0c2c2a02fc48b476cf7d2cb9e4731a69624ca44', 'fb22bbb0ead9bb480ec3044722b33ffd6b4946aecdbd8f788873f79c09f70335', 1, 1, '2016-06-29 16:34:05', '2016-06-29 16:34:09.013412', '2016-06-29 16:34:09.013412', 12884901888, 8, 1000000000000000000, 100, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (4, 'b7bb22fc2725108201a32edc78403fd53fd1d578fa20edaa081ed463422661f0', '7cdae330dcecade466d466c4f0c2c2a02fc48b476cf7d2cb9e4731a69624ca44', 1, 1, '2016-06-29 16:34:06', '2016-06-29 16:34:09.021429', '2016-06-29 16:34:09.021429', 17179869184, 8, 1000000000000000000, 200, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (5, '5df4e168b81b3573173d7c921f1ba8e3a74d51f7c0374e435f06065477691bbc', 'b7bb22fc2725108201a32edc78403fd53fd1d578fa20edaa081ed463422661f0', 3, 3, '2016-06-29 16:34:07', '2016-06-29 16:34:09.027724', '2016-06-29 16:34:09.027724', 21474836480, 8, 1000000000000000000, 500, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (6, '57285676071d0ea948d8561ddc969e54d4d2f684f9304611fa8705128deaabe0', '5df4e168b81b3573173d7c921f1ba8e3a74d51f7c0374e435f06065477691bbc', 1, 1, '2016-06-29 16:34:08', '2016-06-29 16:34:09.035635', '2016-06-29 16:34:09.035635', 25769803776, 8, 1000000000000000000, 600, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (7, 'ed7ec35197e255143851646965a62973d566474c4aa3e755cf241c5ee88a7b73', '57285676071d0ea948d8561ddc969e54d4d2f684f9304611fa8705128deaabe0', 1, 1, '2016-06-29 16:34:09', '2016-06-29 16:34:09.040211', '2016-06-29 16:34:09.040211', 30064771072, 8, 1000000000000000000, 700, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (8, '24baf3dc56fd0819f25cb2024562c64c971ca1bb7fc4ff65efddbac4ffc3be3b', 'ed7ec35197e255143851646965a62973d566474c4aa3e755cf241c5ee88a7b73', 4, 4, '2016-06-29 16:34:10', '2016-06-29 16:34:09.046152', '2016-06-29 16:34:09.046152', 34359738368, 8, 1000000000000000000, 1100, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (9, '1c9139bae67821a5deb6e96e5058deb76f83d085a16ac4e6b7b551cc4637f1bd', '24baf3dc56fd0819f25cb2024562c64c971ca1bb7fc4ff65efddbac4ffc3be3b', 1, 1, '2016-06-29 16:34:11', '2016-06-29 16:34:09.057936', '2016-06-29 16:34:09.057936', 38654705664, 8, 1000000000000000000, 1200, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (10, 'd0b5bfcf3fd5dfe188354a142904dcbc6366b6ac0ba559970654d3a84e55e7db', '1c9139bae67821a5deb6e96e5058deb76f83d085a16ac4e6b7b551cc4637f1bd', 1, 2, '2016-06-29 16:34:12', '2016-06-29 16:34:09.0635', '2016-06-29 16:34:09.0635', 42949672960, 8, 1000000000000000000, 1400, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (11, 'b9f956b26ba7b3a480017f09eaf7c559b74f58bc678908727a09d65f5bd27872', 'd0b5bfcf3fd5dfe188354a142904dcbc6366b6ac0ba559970654d3a84e55e7db', 1, 1, '2016-06-29 16:34:13', '2016-06-29 16:34:09.069222', '2016-06-29 16:34:09.069222', 47244640256, 8, 1000000000000000000, 1500, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (12, '10f6bea3c70bf69b0753075ca35f37ffcadde446eb1c5d094e815216daa8711b', 'b9f956b26ba7b3a480017f09eaf7c559b74f58bc678908727a09d65f5bd27872', 1, 1, '2016-06-29 16:34:14', '2016-06-29 16:34:09.075512', '2016-06-29 16:34:09.075512', 51539607552, 8, 1000000000000000000, 1600, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (13, 'f8c6b5e201ae76d715d3eb497d5a31cdb3b0346e6148b2e05dcdbcf216a46642', '10f6bea3c70bf69b0753075ca35f37ffcadde446eb1c5d094e815216daa8711b', 2, 2, '2016-06-29 16:34:15', '2016-06-29 16:34:09.080862', '2016-06-29 16:34:09.080862', 55834574848, 8, 1000000000000000000, 1800, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (14, '8fa796e38b1d05cef9c8e353704583803afe65cde71e3aa34918b7b069d745a2', 'f8c6b5e201ae76d715d3eb497d5a31cdb3b0346e6148b2e05dcdbcf216a46642', 2, 2, '2016-06-29 16:34:16', '2016-06-29 16:34:09.088931', '2016-06-29 16:34:09.088931', 60129542144, 8, 1000000000000000000, 2000, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (15, 'f464f0cc1d68129cb88b949ed709d926884d08be9da3f4df044b1bbb66b8a163', '8fa796e38b1d05cef9c8e353704583803afe65cde71e3aa34918b7b069d745a2', 1, 1, '2016-06-29 16:34:17', '2016-06-29 16:34:09.095079', '2016-06-29 16:34:09.095079', 64424509440, 8, 1000000000000000000, 2100, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (16, '820b74b571d87173c0b9e26c19ce7a6444e1b285043e2f0141b16126b0df1db7', 'f464f0cc1d68129cb88b949ed709d926884d08be9da3f4df044b1bbb66b8a163', 3, 3, '2016-06-29 16:34:18', '2016-06-29 16:34:09.099691', '2016-06-29 16:34:09.099691', 68719476736, 8, 1000000000000000000, 2400, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (17, '5c8d74ee57d23d260c49be2f8199c5270e3515e1c9bf7cb7c5db8d636638966c', '820b74b571d87173c0b9e26c19ce7a6444e1b285043e2f0141b16126b0df1db7', 2, 2, '2016-06-29 16:34:19', '2016-06-29 16:34:09.110072', '2016-06-29 16:34:09.110072', 73014444032, 8, 1000000000000000000, 2600, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (18, 'd07aee90169d8a9c0e3b16bbdd1cd79178a768306a2ea3916b2b66f909ab4d54', '5c8d74ee57d23d260c49be2f8199c5270e3515e1c9bf7cb7c5db8d636638966c', 3, 3, '2016-06-29 16:34:20', '2016-06-29 16:34:09.115633', '2016-06-29 16:34:09.115633', 77309411328, 8, 1000000000000000000, 2900, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (19, 'c53162f2d34b34aff18c32f43ca63cd9036e9fe7b961b6cbcaf77122d465bd5a', 'd07aee90169d8a9c0e3b16bbdd1cd79178a768306a2ea3916b2b66f909ab4d54', 1, 1, '2016-06-29 16:34:21', '2016-06-29 16:34:09.123894', '2016-06-29 16:34:09.123894', 81604378624, 8, 1000000000000000000, 3000, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (20, '337eb030b7d0fdfecab3b13853cbc7bc44c953d4f3bcf33b847444d1b1acdac9', 'c53162f2d34b34aff18c32f43ca63cd9036e9fe7b961b6cbcaf77122d465bd5a', 1, 1, '2016-06-29 16:34:22', '2016-06-29 16:34:09.130777', '2016-06-29 16:34:09.130777', 85899345920, 8, 1000000000000000000, 3100, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (21, 'c9002d5676ea0cfa94d02b70f7e00966d299604ae15e3f3c8885701965f951e8', '337eb030b7d0fdfecab3b13853cbc7bc44c953d4f3bcf33b847444d1b1acdac9', 2, 2, '2016-06-29 16:34:23', '2016-06-29 16:34:09.136797', '2016-06-29 16:34:09.136797', 90194313216, 8, 1000000000000000000, 3300, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (22, 'a2185667d16e302acdd47e2fd49b59398eeccd1b7ef480f063955ffb266cd455', 'c9002d5676ea0cfa94d02b70f7e00966d299604ae15e3f3c8885701965f951e8', 1, 1, '2016-06-29 16:34:24', '2016-06-29 16:34:09.145043', '2016-06-29 16:34:09.145043', 94489280512, 8, 1000000000000000000, 3400, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (23, '60aa37da1d4e3aded83a3b4970821ab79ada120b034cb6111d3a98597513619d', 'a2185667d16e302acdd47e2fd49b59398eeccd1b7ef480f063955ffb266cd455', 1, 1, '2016-06-29 16:34:25', '2016-06-29 16:34:09.1504', '2016-06-29 16:34:09.1504', 98784247808, 8, 1000000000000000000, 3500, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (24, '9fcaa4deccfe3f2daa5cce744a3e0d886207bd35bf4f77ae836756dfc5ba9544', '60aa37da1d4e3aded83a3b4970821ab79ada120b034cb6111d3a98597513619d', 1, 1, '2016-06-29 16:34:26', '2016-06-29 16:34:09.154322', '2016-06-29 16:34:09.154322', 103079215104, 8, 1000000000000000000, 3600, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (25, 'd20cef6fe3aaa219d99d39f4100cf5286cd9489225007e238ab5b2ef5f1875dd', '9fcaa4deccfe3f2daa5cce744a3e0d886207bd35bf4f77ae836756dfc5ba9544', 1, 1, '2016-06-29 16:34:27', '2016-06-29 16:34:09.159046', '2016-06-29 16:34:09.159046', 107374182400, 8, 1000000000000000000, 3700, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (26, 'fe171a26b7bf9a75eb963e2f12d1aef7b278689066ab56176acee33157abdc12', 'd20cef6fe3aaa219d99d39f4100cf5286cd9489225007e238ab5b2ef5f1875dd', 2, 2, '2016-06-29 16:34:28', '2016-06-29 16:34:09.164851', '2016-06-29 16:34:09.164851', 111669149696, 8, 1000000000000000000, 3900, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (27, '658c89159547a94e13f3951947ba4ed0538f649a518107085b08315cfd7a2630', 'fe171a26b7bf9a75eb963e2f12d1aef7b278689066ab56176acee33157abdc12', 1, 1, '2016-06-29 16:34:29', '2016-06-29 16:34:09.169944', '2016-06-29 16:34:09.169944', 115964116992, 8, 1000000000000000000, 4000, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (28, '20970cff13a9b84272f846832db281cdbc3dafdd5ab51e06d6e7e78ab2443659', '658c89159547a94e13f3951947ba4ed0538f649a518107085b08315cfd7a2630', 7, 7, '2016-06-29 16:34:30', '2016-06-29 16:34:09.17543', '2016-06-29 16:34:09.17543', 120259084288, 8, 1000000000000000000, 4700, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (29, '53136ca4350555c522a52a2acc1f040595e510b8a7ffe48f16ccb70ba9e67db2', '20970cff13a9b84272f846832db281cdbc3dafdd5ab51e06d6e7e78ab2443659', 1, 1, '2016-06-29 16:34:31', '2016-06-29 16:34:09.18882', '2016-06-29 16:34:09.18882', 124554051584, 8, 1000000000000000000, 4800, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (30, '9b652c088b47c6a5af6574f4f4d19f9ae7bebaabc240dca74b74e8d24d284e71', '53136ca4350555c522a52a2acc1f040595e510b8a7ffe48f16ccb70ba9e67db2', 1, 1, '2016-06-29 16:34:32', '2016-06-29 16:34:09.192842', '2016-06-29 16:34:09.192843', 128849018880, 8, 1000000000000000000, 4900, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (31, 'ea8392131b70f17a294212b396a6c06ddfcfde7800e806987f6113623d5f2b2d', '9b652c088b47c6a5af6574f4f4d19f9ae7bebaabc240dca74b74e8d24d284e71', 1, 1, '2016-06-29 16:34:33', '2016-06-29 16:34:09.19688', '2016-06-29 16:34:09.19688', 133143986176, 8, 1000000000000000000, 5000, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (32, '7c779a3360debae7b94803aee99b1ceba229af4f65113162bb44b12774adcc4c', 'ea8392131b70f17a294212b396a6c06ddfcfde7800e806987f6113623d5f2b2d', 2, 2, '2016-06-29 16:34:34', '2016-06-29 16:34:09.201016', '2016-06-29 16:34:09.201016', 137438953472, 8, 1000000000000000000, 5200, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (33, '5092290a187f35857dd0c6edb8bd909fe956e00bed4d3b5e51cf2858671227e5', '7c779a3360debae7b94803aee99b1ceba229af4f65113162bb44b12774adcc4c', 1, 1, '2016-06-29 16:34:35', '2016-06-29 16:34:09.206753', '2016-06-29 16:34:09.206753', 141733920768, 8, 1000000000000000000, 5300, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (34, '78bb254f3edb6601690e1bb24fad11fc9552582ce877ee44bd9f11a4e5753564', '5092290a187f35857dd0c6edb8bd909fe956e00bed4d3b5e51cf2858671227e5', 1, 1, '2016-06-29 16:34:36', '2016-06-29 16:34:09.211857', '2016-06-29 16:34:09.211857', 146028888064, 8, 1000000000000000000, 5400, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (35, '1d959a45b01ad085b6b0dd139829c19c0aaa4c82d50c3a56088aeb2d5743c896', '78bb254f3edb6601690e1bb24fad11fc9552582ce877ee44bd9f11a4e5753564', 1, 1, '2016-06-29 16:34:37', '2016-06-29 16:34:09.216', '2016-06-29 16:34:09.216', 150323855360, 8, 1000000000000000000, 5500, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (36, 'e9dfdda7873f06d25d41696ac54100acf72e997e95728e636e229d5b87e1103c', '1d959a45b01ad085b6b0dd139829c19c0aaa4c82d50c3a56088aeb2d5743c896', 1, 1, '2016-06-29 16:34:38', '2016-06-29 16:34:09.220071', '2016-06-29 16:34:09.220071', 154618822656, 8, 1000000000000000000, 5600, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (37, '573d4c42fdfbe408bcf4ab046f83eb8a2cf52f3cbfa4ba09b2b93e72840453b2', 'e9dfdda7873f06d25d41696ac54100acf72e997e95728e636e229d5b87e1103c', 1, 1, '2016-06-29 16:34:39', '2016-06-29 16:34:09.225053', '2016-06-29 16:34:09.225053', 158913789952, 8, 1000000000000000000, 5700, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (38, '98d102af2d6aa56584bec40c7653363449f66f4cf4c226d05a93b20940d82646', '573d4c42fdfbe408bcf4ab046f83eb8a2cf52f3cbfa4ba09b2b93e72840453b2', 2, 2, '2016-06-29 16:34:40', '2016-06-29 16:34:09.229752', '2016-06-29 16:34:09.229752', 163208757248, 8, 1000000000000000000, 5900, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (39, '890c50c0932c82f8c41df25d8568c53ceb42a33946f2df983db358b1a83e3799', '98d102af2d6aa56584bec40c7653363449f66f4cf4c226d05a93b20940d82646', 1, 1, '2016-06-29 16:34:41', '2016-06-29 16:34:09.237889', '2016-06-29 16:34:09.237889', 167503724544, 8, 1000000000000000000, 6000, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (40, '20ef938feddb4219f252eb19b879b7fa8648960e13e868f5d6733d53a37a2731', '890c50c0932c82f8c41df25d8568c53ceb42a33946f2df983db358b1a83e3799', 2, 2, '2016-06-29 16:34:42', '2016-06-29 16:34:09.242176', '2016-06-29 16:34:09.242176', 171798691840, 8, 1000000000000000000, 6200, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (41, '366f4a57087dfc337d57d78f79b168bfee79de82ae0a15e67a191134d9ac1e49', '20ef938feddb4219f252eb19b879b7fa8648960e13e868f5d6733d53a37a2731', 2, 2, '2016-06-29 16:34:43', '2016-06-29 16:34:09.247617', '2016-06-29 16:34:09.247617', 176093659136, 8, 1000000000000000000, 6400, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (42, '68f7cdfa2ac3f6e498fd30db9b1bf526372814a0c6afe6cb3d3901226d677209', '366f4a57087dfc337d57d78f79b168bfee79de82ae0a15e67a191134d9ac1e49', 1, 1, '2016-06-29 16:34:44', '2016-06-29 16:34:09.253938', '2016-06-29 16:34:09.253938', 180388626432, 8, 1000000000000000000, 6500, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (43, 'b4e79e623978fb2aebca1ec33072de1ac1a7cb46972c66d26d84a3144cdac182', '68f7cdfa2ac3f6e498fd30db9b1bf526372814a0c6afe6cb3d3901226d677209', 1, 1, '2016-06-29 16:34:45', '2016-06-29 16:34:09.258199', '2016-06-29 16:34:09.258199', 184683593728, 8, 1000000000000000000, 6600, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (44, '277c3f2dc5f9fa4eb8e3bea34fc843a331593fd8bf7d184298bc779fd859152e', 'b4e79e623978fb2aebca1ec33072de1ac1a7cb46972c66d26d84a3144cdac182', 1, 1, '2016-06-29 16:34:46', '2016-06-29 16:34:09.263678', '2016-06-29 16:34:09.263678', 188978561024, 8, 1000000000000000000, 6700, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (45, '79d1ae228f9b699da85112c1faa4f0f4c5c4afed550142e83554deced0858749', '277c3f2dc5f9fa4eb8e3bea34fc843a331593fd8bf7d184298bc779fd859152e', 1, 1, '2016-06-29 16:34:47', '2016-06-29 16:34:09.268328', '2016-06-29 16:34:09.268328', 193273528320, 8, 1000000000000000000, 6800, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (46, '3ad81dbb2c6aae081b02a8d6447ba507fe14d15f691b12bc977071e6b575cdb6', '79d1ae228f9b699da85112c1faa4f0f4c5c4afed550142e83554deced0858749', 2, 2, '2016-06-29 16:34:48', '2016-06-29 16:34:09.273658', '2016-06-29 16:34:09.273658', 197568495616, 8, 1000000000000000000, 7000, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (47, '5e1e79ef7a71b949b2bbeed735f454e918a820dd56a1ff4c3dde72b827cedaf0', '3ad81dbb2c6aae081b02a8d6447ba507fe14d15f691b12bc977071e6b575cdb6', 1, 1, '2016-06-29 16:34:49', '2016-06-29 16:34:09.279223', '2016-06-29 16:34:09.279223', 201863462912, 8, 1000190720969537511, 30469589, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (48, '86828dece93d95adcdf7c92f3bfa12afbe90c97841637d286ddbc263633c8fed', '5e1e79ef7a71b949b2bbeed735f454e918a820dd56a1ff4c3dde72b827cedaf0', 1, 1, '2016-06-29 16:34:50', '2016-06-29 16:34:09.283597', '2016-06-29 16:34:09.283597', 206158430208, 8, 1000190720969537511, 30469689, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (49, '817455af1d00a880abdbc2d5b9b1a7599b75931edba42a948da547a960e31410', '86828dece93d95adcdf7c92f3bfa12afbe90c97841637d286ddbc263633c8fed', 2, 2, '2016-06-29 16:34:51', '2016-06-29 16:34:09.288866', '2016-06-29 16:34:09.288866', 210453397504, 8, 1000190720969537511, 30469889, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (50, '1b605f49072ff6bd40ccb13d2ba9a1afbab3f2a5c0a1b1a8d7b77536b867ec50', '817455af1d00a880abdbc2d5b9b1a7599b75931edba42a948da547a960e31410', 1, 1, '2016-06-29 16:34:52', '2016-06-29 16:34:09.29421', '2016-06-29 16:34:09.29421', 214748364800, 8, 1000190720969537511, 30469989, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (51, '85a0c73535835431cbd5170837ed5be3aa8de2bdf656bfca7585104eb169bbeb', '1b605f49072ff6bd40ccb13d2ba9a1afbab3f2a5c0a1b1a8d7b77536b867ec50', 1, 1, '2016-06-29 16:34:53', '2016-06-29 16:34:09.298085', '2016-06-29 16:34:09.298085', 219043332096, 8, 1000190720969537511, 30470089, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (52, '4f261dfbd6491b335340bcb29fa6735c0660339393eabc7ee9315abdab2f1586', '85a0c73535835431cbd5170837ed5be3aa8de2bdf656bfca7585104eb169bbeb', 1, 1, '2016-06-29 16:34:54', '2016-06-29 16:34:09.302884', '2016-06-29 16:34:09.302884', 223338299392, 8, 1000190720969537511, 30470189, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (53, 'd48ce25386e6910336a4977b8f3dfb9c1095e0f29726d5fb5e4efe82d0f5f0f1', '4f261dfbd6491b335340bcb29fa6735c0660339393eabc7ee9315abdab2f1586', 1, 1, '2016-06-29 16:34:55', '2016-06-29 16:34:09.307427', '2016-06-29 16:34:09.307427', 227633266688, 8, 1000190720969537511, 30470289, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (54, '0027eff1c2f17b8ab7f3a1bd1b90ddb4b302843180412c83830b2c4b0578a968', 'd48ce25386e6910336a4977b8f3dfb9c1095e0f29726d5fb5e4efe82d0f5f0f1', 1, 2, '2016-06-29 16:34:56', '2016-06-29 16:34:09.31272', '2016-06-29 16:34:09.31272', 231928233984, 8, 1000190720969537511, 30470489, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (55, '4ca9d0efafaec46db7f82fabe157341eb4d8c16ea1addab5d8a9705dfa6c79a1', '0027eff1c2f17b8ab7f3a1bd1b90ddb4b302843180412c83830b2c4b0578a968', 1, 1, '2016-06-29 16:34:57', '2016-06-29 16:34:09.318595', '2016-06-29 16:34:09.318595', 236223201280, 8, 1000190720969537511, 30470589, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (56, 'df49ca7c5d95a9d114bddb1cb6ee6826ca3e06f1f8d56ca4dbc8f720bc25e5e2', '4ca9d0efafaec46db7f82fabe157341eb4d8c16ea1addab5d8a9705dfa6c79a1', 1, 1, '2016-06-29 16:34:58', '2016-06-29 16:34:09.323873', '2016-06-29 16:34:09.323873', 240518168576, 8, 1000190720969537511, 30470689, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (57, '27d8624e4cb6cd71a2d36c78a21c9d1abec47175e55c87459877049702bb5fa8', 'df49ca7c5d95a9d114bddb1cb6ee6826ca3e06f1f8d56ca4dbc8f720bc25e5e2', 1, 1, '2016-06-29 16:34:59', '2016-06-29 16:34:09.327991', '2016-06-29 16:34:09.327991', 244813135872, 8, 1000190720969537511, 30470789, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (58, '6728a7de5d054186933b5776924a12ff34faa6cf77615c8b31eec1a386115c60', '27d8624e4cb6cd71a2d36c78a21c9d1abec47175e55c87459877049702bb5fa8', 1, 1, '2016-06-29 16:35:00', '2016-06-29 16:34:09.333569', '2016-06-29 16:34:09.333569', 249108103168, 8, 1000190720969537511, 30470889, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (59, 'bcf5788cb12788e5a7288407263982a60d24307a4a4bd2fb5e30583c7c37736d', '6728a7de5d054186933b5776924a12ff34faa6cf77615c8b31eec1a386115c60', 0, 0, '2016-06-29 16:35:01', '2016-06-29 16:34:09.337252', '2016-06-29 16:34:09.337252', 253403070464, 8, 1000190720969537511, 30470889, 100, 100000000, 10000);


--
-- Data for Name: history_operation_participants; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO history_operation_participants VALUES (1, 12884905985, 1);
INSERT INTO history_operation_participants VALUES (2, 12884905985, 2);
INSERT INTO history_operation_participants VALUES (3, 17179873281, 1);
INSERT INTO history_operation_participants VALUES (4, 17179873281, 3);
INSERT INTO history_operation_participants VALUES (5, 21474840577, 3);
INSERT INTO history_operation_participants VALUES (6, 21474844673, 3);
INSERT INTO history_operation_participants VALUES (7, 21474848769, 3);
INSERT INTO history_operation_participants VALUES (8, 25769807873, 3);
INSERT INTO history_operation_participants VALUES (9, 30064775169, 1);
INSERT INTO history_operation_participants VALUES (10, 30064775169, 4);
INSERT INTO history_operation_participants VALUES (11, 34359742465, 4);
INSERT INTO history_operation_participants VALUES (12, 34359742465, 1);
INSERT INTO history_operation_participants VALUES (13, 34359746561, 4);
INSERT INTO history_operation_participants VALUES (14, 34359746561, 1);
INSERT INTO history_operation_participants VALUES (15, 34359750657, 4);
INSERT INTO history_operation_participants VALUES (16, 34359750657, 1);
INSERT INTO history_operation_participants VALUES (17, 34359754753, 4);
INSERT INTO history_operation_participants VALUES (18, 34359754753, 1);
INSERT INTO history_operation_participants VALUES (19, 38654709761, 1);
INSERT INTO history_operation_participants VALUES (20, 38654709761, 5);
INSERT INTO history_operation_participants VALUES (21, 42949677057, 5);
INSERT INTO history_operation_participants VALUES (22, 42949677057, 1);
INSERT INTO history_operation_participants VALUES (23, 42949677058, 5);
INSERT INTO history_operation_participants VALUES (24, 42949677058, 1);
INSERT INTO history_operation_participants VALUES (25, 47244644353, 1);
INSERT INTO history_operation_participants VALUES (26, 47244644353, 6);
INSERT INTO history_operation_participants VALUES (27, 51539611649, 6);
INSERT INTO history_operation_participants VALUES (28, 51539611649, 7);
INSERT INTO history_operation_participants VALUES (29, 55834578945, 1);
INSERT INTO history_operation_participants VALUES (30, 55834578945, 8);
INSERT INTO history_operation_participants VALUES (31, 55834583041, 9);
INSERT INTO history_operation_participants VALUES (32, 55834583041, 1);
INSERT INTO history_operation_participants VALUES (33, 60129546241, 9);
INSERT INTO history_operation_participants VALUES (34, 60129550337, 8);
INSERT INTO history_operation_participants VALUES (35, 60129550337, 9);
INSERT INTO history_operation_participants VALUES (36, 64424513537, 8);
INSERT INTO history_operation_participants VALUES (37, 64424513537, 9);
INSERT INTO history_operation_participants VALUES (38, 68719480833, 1);
INSERT INTO history_operation_participants VALUES (39, 68719480833, 10);
INSERT INTO history_operation_participants VALUES (40, 68719484929, 1);
INSERT INTO history_operation_participants VALUES (41, 68719484929, 11);
INSERT INTO history_operation_participants VALUES (42, 68719489025, 1);
INSERT INTO history_operation_participants VALUES (43, 68719489025, 12);
INSERT INTO history_operation_participants VALUES (44, 73014448129, 11);
INSERT INTO history_operation_participants VALUES (45, 73014452225, 10);
INSERT INTO history_operation_participants VALUES (46, 77309415425, 12);
INSERT INTO history_operation_participants VALUES (47, 77309415425, 10);
INSERT INTO history_operation_participants VALUES (48, 77309419521, 12);
INSERT INTO history_operation_participants VALUES (49, 77309423617, 12);
INSERT INTO history_operation_participants VALUES (50, 81604382721, 10);
INSERT INTO history_operation_participants VALUES (51, 81604382721, 11);
INSERT INTO history_operation_participants VALUES (52, 85899350017, 10);
INSERT INTO history_operation_participants VALUES (53, 85899350017, 11);
INSERT INTO history_operation_participants VALUES (54, 90194317313, 13);
INSERT INTO history_operation_participants VALUES (55, 90194317313, 1);
INSERT INTO history_operation_participants VALUES (56, 90194321409, 1);
INSERT INTO history_operation_participants VALUES (57, 90194321409, 14);
INSERT INTO history_operation_participants VALUES (58, 94489284609, 13);
INSERT INTO history_operation_participants VALUES (59, 98784251905, 13);
INSERT INTO history_operation_participants VALUES (60, 103079219201, 14);
INSERT INTO history_operation_participants VALUES (61, 107374186497, 1);
INSERT INTO history_operation_participants VALUES (62, 107374186497, 15);
INSERT INTO history_operation_participants VALUES (63, 111669153793, 15);
INSERT INTO history_operation_participants VALUES (64, 111669157889, 15);
INSERT INTO history_operation_participants VALUES (65, 115964121089, 1);
INSERT INTO history_operation_participants VALUES (66, 115964121089, 16);
INSERT INTO history_operation_participants VALUES (67, 120259088385, 16);
INSERT INTO history_operation_participants VALUES (68, 120259092481, 16);
INSERT INTO history_operation_participants VALUES (69, 120259096577, 16);
INSERT INTO history_operation_participants VALUES (70, 120259100673, 16);
INSERT INTO history_operation_participants VALUES (71, 120259104769, 16);
INSERT INTO history_operation_participants VALUES (72, 120259108865, 16);
INSERT INTO history_operation_participants VALUES (73, 120259112961, 16);
INSERT INTO history_operation_participants VALUES (74, 124554055681, 16);
INSERT INTO history_operation_participants VALUES (75, 128849022977, 16);
INSERT INTO history_operation_participants VALUES (76, 133143990273, 16);
INSERT INTO history_operation_participants VALUES (77, 137438957569, 16);
INSERT INTO history_operation_participants VALUES (78, 137438961665, 16);
INSERT INTO history_operation_participants VALUES (79, 141733924865, 1);
INSERT INTO history_operation_participants VALUES (80, 141733924865, 17);
INSERT INTO history_operation_participants VALUES (81, 146028892161, 17);
INSERT INTO history_operation_participants VALUES (82, 150323859457, 17);
INSERT INTO history_operation_participants VALUES (83, 154618826753, 17);
INSERT INTO history_operation_participants VALUES (84, 158913794049, 17);
INSERT INTO history_operation_participants VALUES (85, 163208761345, 1);
INSERT INTO history_operation_participants VALUES (86, 163208761345, 18);
INSERT INTO history_operation_participants VALUES (87, 163208765441, 1);
INSERT INTO history_operation_participants VALUES (88, 163208765441, 19);
INSERT INTO history_operation_participants VALUES (89, 167503728641, 19);
INSERT INTO history_operation_participants VALUES (90, 171798695937, 18);
INSERT INTO history_operation_participants VALUES (91, 171798700033, 18);
INSERT INTO history_operation_participants VALUES (92, 176093663233, 19);
INSERT INTO history_operation_participants VALUES (93, 176093663233, 18);
INSERT INTO history_operation_participants VALUES (94, 176093667329, 19);
INSERT INTO history_operation_participants VALUES (95, 176093667329, 18);
INSERT INTO history_operation_participants VALUES (96, 180388630529, 19);
INSERT INTO history_operation_participants VALUES (97, 180388630529, 18);
INSERT INTO history_operation_participants VALUES (98, 184683597825, 1);
INSERT INTO history_operation_participants VALUES (99, 184683597825, 20);
INSERT INTO history_operation_participants VALUES (100, 188978565121, 20);
INSERT INTO history_operation_participants VALUES (101, 188978565121, 1);
INSERT INTO history_operation_participants VALUES (102, 193273532417, 1);
INSERT INTO history_operation_participants VALUES (103, 193273532417, 21);
INSERT INTO history_operation_participants VALUES (104, 197568499713, 1);
INSERT INTO history_operation_participants VALUES (105, 197568503809, 21);
INSERT INTO history_operation_participants VALUES (106, 201863467009, 1);
INSERT INTO history_operation_participants VALUES (107, 206158434305, 1);
INSERT INTO history_operation_participants VALUES (108, 206158434305, 22);
INSERT INTO history_operation_participants VALUES (109, 210453401601, 22);
INSERT INTO history_operation_participants VALUES (110, 210453405697, 22);
INSERT INTO history_operation_participants VALUES (111, 214748368897, 22);
INSERT INTO history_operation_participants VALUES (112, 219043336193, 22);
INSERT INTO history_operation_participants VALUES (113, 223338303489, 22);
INSERT INTO history_operation_participants VALUES (114, 227633270785, 1);
INSERT INTO history_operation_participants VALUES (115, 227633270785, 23);
INSERT INTO history_operation_participants VALUES (116, 231928238081, 1);
INSERT INTO history_operation_participants VALUES (117, 231928238081, 23);
INSERT INTO history_operation_participants VALUES (118, 231928238082, 23);
INSERT INTO history_operation_participants VALUES (119, 231928238082, 1);
INSERT INTO history_operation_participants VALUES (120, 236223205377, 24);
INSERT INTO history_operation_participants VALUES (121, 236223205377, 1);
INSERT INTO history_operation_participants VALUES (122, 240518172673, 24);
INSERT INTO history_operation_participants VALUES (123, 244813139969, 1);
INSERT INTO history_operation_participants VALUES (124, 244813139969, 25);
INSERT INTO history_operation_participants VALUES (125, 249108107265, 24);


--
-- Name: history_operation_participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('history_operation_participants_id_seq', 125, true);


--
-- Data for Name: history_operations; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO history_operations VALUES (12884905985, 12884905984, 1, 0, '{"funder": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "account": "GAXI33UCLQTCKM2NMRBS7XYBR535LLEVAHL5YBN4FTCB4HZHT7ZA5CVK", "starting_balance": "1000.0000000"}', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_operations VALUES (17179873281, 17179873280, 1, 0, '{"funder": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "account": "GDXFAGJCSCI4CK2YHK6YRLA6TKEXFRX7BMGVMQOBMLIEUJRJ5YQNLMIB", "starting_balance": "1000.0000000"}', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_operations VALUES (21474840577, 21474840576, 1, 5, '{"master_key_weight": 1}', 'GDXFAGJCSCI4CK2YHK6YRLA6TKEXFRX7BMGVMQOBMLIEUJRJ5YQNLMIB');
INSERT INTO history_operations VALUES (21474844673, 21474844672, 1, 5, '{"signer_key": "GD3E7HKMRNT6HGBGHBT6I6JE4N2S4W5KZ246TGJ4KQSXJ2P4BXCUPQMP", "signer_weight": 1}', 'GDXFAGJCSCI4CK2YHK6YRLA6TKEXFRX7BMGVMQOBMLIEUJRJ5YQNLMIB');
INSERT INTO history_operations VALUES (21474848769, 21474848768, 1, 5, '{"low_threshold": 2, "med_threshold": 2, "high_threshold": 2}', 'GDXFAGJCSCI4CK2YHK6YRLA6TKEXFRX7BMGVMQOBMLIEUJRJ5YQNLMIB');
INSERT INTO history_operations VALUES (25769807873, 25769807872, 1, 5, '{"master_key_weight": 2}', 'GDXFAGJCSCI4CK2YHK6YRLA6TKEXFRX7BMGVMQOBMLIEUJRJ5YQNLMIB');
INSERT INTO history_operations VALUES (30064775169, 30064775168, 1, 0, '{"funder": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "account": "GA46VRKBCLI2X6DXLX7AIEVRFLH3UA7XBE3NGNP6O74HQ5LXHMGTV2JB", "starting_balance": "1000.0000000"}', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_operations VALUES (34359742465, 34359742464, 1, 1, '{"to": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "from": "GA46VRKBCLI2X6DXLX7AIEVRFLH3UA7XBE3NGNP6O74HQ5LXHMGTV2JB", "amount": "1.0000000", "asset_type": "native"}', 'GA46VRKBCLI2X6DXLX7AIEVRFLH3UA7XBE3NGNP6O74HQ5LXHMGTV2JB');
INSERT INTO history_operations VALUES (34359746561, 34359746560, 1, 1, '{"to": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "from": "GA46VRKBCLI2X6DXLX7AIEVRFLH3UA7XBE3NGNP6O74HQ5LXHMGTV2JB", "amount": "1.0000000", "asset_type": "native"}', 'GA46VRKBCLI2X6DXLX7AIEVRFLH3UA7XBE3NGNP6O74HQ5LXHMGTV2JB');
INSERT INTO history_operations VALUES (34359750657, 34359750656, 1, 1, '{"to": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "from": "GA46VRKBCLI2X6DXLX7AIEVRFLH3UA7XBE3NGNP6O74HQ5LXHMGTV2JB", "amount": "1.0000000", "asset_type": "native"}', 'GA46VRKBCLI2X6DXLX7AIEVRFLH3UA7XBE3NGNP6O74HQ5LXHMGTV2JB');
INSERT INTO history_operations VALUES (34359754753, 34359754752, 1, 1, '{"to": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "from": "GA46VRKBCLI2X6DXLX7AIEVRFLH3UA7XBE3NGNP6O74HQ5LXHMGTV2JB", "amount": "1.0000000", "asset_type": "native"}', 'GA46VRKBCLI2X6DXLX7AIEVRFLH3UA7XBE3NGNP6O74HQ5LXHMGTV2JB');
INSERT INTO history_operations VALUES (38654709761, 38654709760, 1, 0, '{"funder": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "account": "GAG52TW6QAB6TGNMOTL32Y4M3UQQLNNNHPEHYAIYRP6SFF6ZAVRF5ZQY", "starting_balance": "1000.0000000"}', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_operations VALUES (42949677057, 42949677056, 1, 1, '{"to": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "from": "GAG52TW6QAB6TGNMOTL32Y4M3UQQLNNNHPEHYAIYRP6SFF6ZAVRF5ZQY", "amount": "10.0000000", "asset_type": "native"}', 'GAG52TW6QAB6TGNMOTL32Y4M3UQQLNNNHPEHYAIYRP6SFF6ZAVRF5ZQY');
INSERT INTO history_operations VALUES (42949677058, 42949677056, 2, 1, '{"to": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "from": "GAG52TW6QAB6TGNMOTL32Y4M3UQQLNNNHPEHYAIYRP6SFF6ZAVRF5ZQY", "amount": "10.0000000", "asset_type": "native"}', 'GAG52TW6QAB6TGNMOTL32Y4M3UQQLNNNHPEHYAIYRP6SFF6ZAVRF5ZQY');
INSERT INTO history_operations VALUES (47244644353, 47244644352, 1, 0, '{"funder": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "account": "GDCVTBGSEEU7KLXUMHMSXBALXJ2T4I2KOPXW2S5TRLKDRIAXD5UDHAYO", "starting_balance": "1000.0000000"}', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_operations VALUES (51539611649, 51539611648, 1, 0, '{"funder": "GDCVTBGSEEU7KLXUMHMSXBALXJ2T4I2KOPXW2S5TRLKDRIAXD5UDHAYO", "account": "GCB7FPYGLL6RJ37HKRAYW5TAWMFBGGFGM4IM6ERBCZXI2BZ4OOOX2UAY", "starting_balance": "50.0000000"}', 'GDCVTBGSEEU7KLXUMHMSXBALXJ2T4I2KOPXW2S5TRLKDRIAXD5UDHAYO');
INSERT INTO history_operations VALUES (55834578945, 55834578944, 1, 0, '{"funder": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "account": "GCHC4D2CS45CJRNN4QAHT2LFZAJIU5PA7H53K3VOP6WEJ6XWHNSNZKQG", "starting_balance": "1000.0000000"}', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_operations VALUES (55834583041, 55834583040, 1, 0, '{"funder": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "account": "GANZGPKY5WSHWG5YOZMNG52GCK5SCJ4YGUWMJJVGZSK2FP4BI2JIJN2C", "starting_balance": "1000.0000000"}', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_operations VALUES (60129546241, 60129546240, 1, 6, '{"limit": "922337203685.4775807", "trustee": "GCHC4D2CS45CJRNN4QAHT2LFZAJIU5PA7H53K3VOP6WEJ6XWHNSNZKQG", "trustor": "GANZGPKY5WSHWG5YOZMNG52GCK5SCJ4YGUWMJJVGZSK2FP4BI2JIJN2C", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GCHC4D2CS45CJRNN4QAHT2LFZAJIU5PA7H53K3VOP6WEJ6XWHNSNZKQG"}', 'GANZGPKY5WSHWG5YOZMNG52GCK5SCJ4YGUWMJJVGZSK2FP4BI2JIJN2C');
INSERT INTO history_operations VALUES (60129550337, 60129550336, 1, 1, '{"to": "GANZGPKY5WSHWG5YOZMNG52GCK5SCJ4YGUWMJJVGZSK2FP4BI2JIJN2C", "from": "GCHC4D2CS45CJRNN4QAHT2LFZAJIU5PA7H53K3VOP6WEJ6XWHNSNZKQG", "amount": "10.0000000", "asset_type": "native"}', 'GCHC4D2CS45CJRNN4QAHT2LFZAJIU5PA7H53K3VOP6WEJ6XWHNSNZKQG');
INSERT INTO history_operations VALUES (64424513537, 64424513536, 1, 1, '{"to": "GANZGPKY5WSHWG5YOZMNG52GCK5SCJ4YGUWMJJVGZSK2FP4BI2JIJN2C", "from": "GCHC4D2CS45CJRNN4QAHT2LFZAJIU5PA7H53K3VOP6WEJ6XWHNSNZKQG", "amount": "10.0000000", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GCHC4D2CS45CJRNN4QAHT2LFZAJIU5PA7H53K3VOP6WEJ6XWHNSNZKQG"}', 'GCHC4D2CS45CJRNN4QAHT2LFZAJIU5PA7H53K3VOP6WEJ6XWHNSNZKQG');
INSERT INTO history_operations VALUES (68719480833, 68719480832, 1, 0, '{"funder": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "account": "GDRW375MAYR46ODGF2WGANQC2RRZL7O246DYHHCGWTV2RE7IHE2QUQLD", "starting_balance": "1000.0000000"}', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_operations VALUES (68719484929, 68719484928, 1, 0, '{"funder": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "account": "GACAR2AEYEKITE2LKI5RMXF5MIVZ6Q7XILROGDT22O7JX4DSWFS7FDDP", "starting_balance": "1000.0000000"}', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_operations VALUES (68719489025, 68719489024, 1, 0, '{"funder": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "account": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU", "starting_balance": "1000.0000000"}', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_operations VALUES (73014448129, 73014448128, 1, 6, '{"limit": "922337203685.4775807", "trustee": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU", "trustor": "GACAR2AEYEKITE2LKI5RMXF5MIVZ6Q7XILROGDT22O7JX4DSWFS7FDDP", "asset_code": "EUR", "asset_type": "credit_alphanum4", "asset_issuer": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU"}', 'GACAR2AEYEKITE2LKI5RMXF5MIVZ6Q7XILROGDT22O7JX4DSWFS7FDDP');
INSERT INTO history_operations VALUES (73014452225, 73014452224, 1, 6, '{"limit": "922337203685.4775807", "trustee": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU", "trustor": "GDRW375MAYR46ODGF2WGANQC2RRZL7O246DYHHCGWTV2RE7IHE2QUQLD", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU"}', 'GDRW375MAYR46ODGF2WGANQC2RRZL7O246DYHHCGWTV2RE7IHE2QUQLD');
INSERT INTO history_operations VALUES (141733924865, 141733924864, 1, 0, '{"funder": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "account": "GCJKJXPKBFIHOO3455WXWG5CDBZXQNYFRRGICYMPUQ35CPQ4WVS3KZLG", "starting_balance": "1000.0000000"}', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_operations VALUES (77309415425, 77309415424, 1, 1, '{"to": "GDRW375MAYR46ODGF2WGANQC2RRZL7O246DYHHCGWTV2RE7IHE2QUQLD", "from": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU", "amount": "100.0000000", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU"}', 'GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU');
INSERT INTO history_operations VALUES (77309419521, 77309419520, 1, 3, '{"price": "0.5000000", "amount": "400.0000000", "price_r": {"d": 2, "n": 1}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_type": "native", "buying_asset_issuer": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU"}', 'GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU');
INSERT INTO history_operations VALUES (77309423617, 77309423616, 1, 3, '{"price": "1.0000000", "amount": "300.0000000", "price_r": {"d": 1, "n": 1}, "offer_id": 0, "buying_asset_type": "native", "selling_asset_code": "EUR", "selling_asset_type": "credit_alphanum4", "selling_asset_issuer": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU"}', 'GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU');
INSERT INTO history_operations VALUES (81604382721, 81604382720, 1, 2, '{"to": "GACAR2AEYEKITE2LKI5RMXF5MIVZ6Q7XILROGDT22O7JX4DSWFS7FDDP", "from": "GDRW375MAYR46ODGF2WGANQC2RRZL7O246DYHHCGWTV2RE7IHE2QUQLD", "path": [{"asset_type": "native"}], "amount": "200.0000000", "asset_code": "EUR", "asset_type": "credit_alphanum4", "source_max": "100.0000000", "asset_issuer": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU", "source_amount": "100.0000000", "source_asset_code": "USD", "source_asset_type": "credit_alphanum4", "source_asset_issuer": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU"}', 'GDRW375MAYR46ODGF2WGANQC2RRZL7O246DYHHCGWTV2RE7IHE2QUQLD');
INSERT INTO history_operations VALUES (85899350017, 85899350016, 1, 2, '{"to": "GACAR2AEYEKITE2LKI5RMXF5MIVZ6Q7XILROGDT22O7JX4DSWFS7FDDP", "from": "GDRW375MAYR46ODGF2WGANQC2RRZL7O246DYHHCGWTV2RE7IHE2QUQLD", "path": [], "amount": "100.0000000", "asset_code": "EUR", "asset_type": "credit_alphanum4", "source_max": "100.0000000", "asset_issuer": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU", "source_amount": "100.0000000", "source_asset_type": "native"}', 'GDRW375MAYR46ODGF2WGANQC2RRZL7O246DYHHCGWTV2RE7IHE2QUQLD');
INSERT INTO history_operations VALUES (90194317313, 90194317312, 1, 0, '{"funder": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "account": "GBOK7BOUSOWPHBANBYM6MIRYZJIDIPUYJPXHTHADF75UEVIVYWHHONQC", "starting_balance": "1000.0000000"}', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_operations VALUES (90194321409, 90194321408, 1, 0, '{"funder": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "account": "GB2QIYT2IAUFMRXKLSLLPRECC6OCOGJMADSPTRK7TGNT2SFR2YGWDARD", "starting_balance": "1000.0000000"}', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_operations VALUES (94489284609, 94489284608, 1, 6, '{"limit": "922337203685.4775807", "trustee": "GB2QIYT2IAUFMRXKLSLLPRECC6OCOGJMADSPTRK7TGNT2SFR2YGWDARD", "trustor": "GBOK7BOUSOWPHBANBYM6MIRYZJIDIPUYJPXHTHADF75UEVIVYWHHONQC", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GB2QIYT2IAUFMRXKLSLLPRECC6OCOGJMADSPTRK7TGNT2SFR2YGWDARD"}', 'GBOK7BOUSOWPHBANBYM6MIRYZJIDIPUYJPXHTHADF75UEVIVYWHHONQC');
INSERT INTO history_operations VALUES (98784251905, 98784251904, 1, 3, '{"price": "1.0000000", "amount": "20.0000000", "price_r": {"d": 1, "n": 1}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_type": "native", "buying_asset_issuer": "GB2QIYT2IAUFMRXKLSLLPRECC6OCOGJMADSPTRK7TGNT2SFR2YGWDARD"}', 'GBOK7BOUSOWPHBANBYM6MIRYZJIDIPUYJPXHTHADF75UEVIVYWHHONQC');
INSERT INTO history_operations VALUES (103079219201, 103079219200, 1, 3, '{"price": "1.0000000", "amount": "30.0000000", "price_r": {"d": 1, "n": 1}, "offer_id": 0, "buying_asset_type": "native", "selling_asset_code": "USD", "selling_asset_type": "credit_alphanum4", "selling_asset_issuer": "GB2QIYT2IAUFMRXKLSLLPRECC6OCOGJMADSPTRK7TGNT2SFR2YGWDARD"}', 'GB2QIYT2IAUFMRXKLSLLPRECC6OCOGJMADSPTRK7TGNT2SFR2YGWDARD');
INSERT INTO history_operations VALUES (107374186497, 107374186496, 1, 0, '{"funder": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "account": "GB6GN3LJUW6JYR7EDOJ47VBH7D45M4JWHXGK6LHJRAEI5JBSN2DBQY7Q", "starting_balance": "1000.0000000"}', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_operations VALUES (111669153793, 111669153792, 1, 4, '{"price": "1.0000000", "amount": "200.0000000", "price_r": {"d": 1, "n": 1}, "buying_asset_type": "native", "selling_asset_code": "USD", "selling_asset_type": "credit_alphanum4", "selling_asset_issuer": "GB6GN3LJUW6JYR7EDOJ47VBH7D45M4JWHXGK6LHJRAEI5JBSN2DBQY7Q"}', 'GB6GN3LJUW6JYR7EDOJ47VBH7D45M4JWHXGK6LHJRAEI5JBSN2DBQY7Q');
INSERT INTO history_operations VALUES (111669157889, 111669157888, 1, 4, '{"price": "1.0000000", "amount": "200.0000000", "price_r": {"d": 1, "n": 1}, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_type": "native", "buying_asset_issuer": "GB6GN3LJUW6JYR7EDOJ47VBH7D45M4JWHXGK6LHJRAEI5JBSN2DBQY7Q"}', 'GB6GN3LJUW6JYR7EDOJ47VBH7D45M4JWHXGK6LHJRAEI5JBSN2DBQY7Q');
INSERT INTO history_operations VALUES (115964121089, 115964121088, 1, 0, '{"funder": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "account": "GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES", "starting_balance": "1000.0000000"}', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_operations VALUES (120259088385, 120259088384, 1, 5, '{"inflation_dest": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H"}', 'GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES');
INSERT INTO history_operations VALUES (120259092481, 120259092480, 1, 5, '{"set_flags": [1], "set_flags_s": ["auth_required"]}', 'GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES');
INSERT INTO history_operations VALUES (120259096577, 120259096576, 1, 5, '{"set_flags": [2], "set_flags_s": ["auth_revocable"]}', 'GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES');
INSERT INTO history_operations VALUES (120259100673, 120259100672, 1, 5, '{"master_key_weight": 2}', 'GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES');
INSERT INTO history_operations VALUES (120259104769, 120259104768, 1, 5, '{"low_threshold": 0, "med_threshold": 2, "high_threshold": 2}', 'GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES');
INSERT INTO history_operations VALUES (120259108865, 120259108864, 1, 5, '{"home_domain": "example.com"}', 'GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES');
INSERT INTO history_operations VALUES (120259112961, 120259112960, 1, 5, '{"signer_key": "GB6J3WOLKYQE6KVDZEA4JDMFTTONUYP3PUHNDNZRWIKA6JQWIMJZATFE", "signer_weight": 1}', 'GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES');
INSERT INTO history_operations VALUES (124554055681, 124554055680, 1, 5, '{"master_key_weight": 2}', 'GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES');
INSERT INTO history_operations VALUES (128849022977, 128849022976, 1, 5, '{"signer_key": "GB6J3WOLKYQE6KVDZEA4JDMFTTONUYP3PUHNDNZRWIKA6JQWIMJZATFE", "signer_weight": 1}', 'GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES');
INSERT INTO history_operations VALUES (133143990273, 133143990272, 1, 5, '{"signer_key": "GB6J3WOLKYQE6KVDZEA4JDMFTTONUYP3PUHNDNZRWIKA6JQWIMJZATFE", "signer_weight": 5}', 'GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES');
INSERT INTO history_operations VALUES (137438957569, 137438957568, 1, 5, '{"clear_flags": [1, 2], "clear_flags_s": ["auth_required", "auth_revocable"]}', 'GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES');
INSERT INTO history_operations VALUES (137438961665, 137438961664, 1, 5, '{"signer_key": "GB6J3WOLKYQE6KVDZEA4JDMFTTONUYP3PUHNDNZRWIKA6JQWIMJZATFE", "signer_weight": 0}', 'GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES');
INSERT INTO history_operations VALUES (146028892161, 146028892160, 1, 6, '{"limit": "922337203685.4775807", "trustee": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "trustor": "GCJKJXPKBFIHOO3455WXWG5CDBZXQNYFRRGICYMPUQ35CPQ4WVS3KZLG", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H"}', 'GCJKJXPKBFIHOO3455WXWG5CDBZXQNYFRRGICYMPUQ35CPQ4WVS3KZLG');
INSERT INTO history_operations VALUES (150323859457, 150323859456, 1, 6, '{"limit": "100.0000000", "trustee": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "trustor": "GCJKJXPKBFIHOO3455WXWG5CDBZXQNYFRRGICYMPUQ35CPQ4WVS3KZLG", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H"}', 'GCJKJXPKBFIHOO3455WXWG5CDBZXQNYFRRGICYMPUQ35CPQ4WVS3KZLG');
INSERT INTO history_operations VALUES (154618826753, 154618826752, 1, 6, '{"limit": "100.0000000", "trustee": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "trustor": "GCJKJXPKBFIHOO3455WXWG5CDBZXQNYFRRGICYMPUQ35CPQ4WVS3KZLG", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H"}', 'GCJKJXPKBFIHOO3455WXWG5CDBZXQNYFRRGICYMPUQ35CPQ4WVS3KZLG');
INSERT INTO history_operations VALUES (158913794049, 158913794048, 1, 6, '{"limit": "0.0000000", "trustee": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "trustor": "GCJKJXPKBFIHOO3455WXWG5CDBZXQNYFRRGICYMPUQ35CPQ4WVS3KZLG", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H"}', 'GCJKJXPKBFIHOO3455WXWG5CDBZXQNYFRRGICYMPUQ35CPQ4WVS3KZLG');
INSERT INTO history_operations VALUES (163208761345, 163208761344, 1, 0, '{"funder": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "account": "GCVW5LCRZFP7PENXTAGOVIQXADDNUXXZJCNKF4VQB2IK7W2LPJWF73UG", "starting_balance": "1000.0000000"}', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_operations VALUES (163208765441, 163208765440, 1, 0, '{"funder": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "account": "GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF", "starting_balance": "1000.0000000"}', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_operations VALUES (167503728641, 167503728640, 1, 5, '{"set_flags": [1, 2], "set_flags_s": ["auth_required", "auth_revocable"]}', 'GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF');
INSERT INTO history_operations VALUES (171798695937, 171798695936, 1, 6, '{"limit": "922337203685.4775807", "trustee": "GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF", "trustor": "GCVW5LCRZFP7PENXTAGOVIQXADDNUXXZJCNKF4VQB2IK7W2LPJWF73UG", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF"}', 'GCVW5LCRZFP7PENXTAGOVIQXADDNUXXZJCNKF4VQB2IK7W2LPJWF73UG');
INSERT INTO history_operations VALUES (171798700033, 171798700032, 1, 6, '{"limit": "922337203685.4775807", "trustee": "GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF", "trustor": "GCVW5LCRZFP7PENXTAGOVIQXADDNUXXZJCNKF4VQB2IK7W2LPJWF73UG", "asset_code": "EUR", "asset_type": "credit_alphanum4", "asset_issuer": "GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF"}', 'GCVW5LCRZFP7PENXTAGOVIQXADDNUXXZJCNKF4VQB2IK7W2LPJWF73UG');
INSERT INTO history_operations VALUES (176093663233, 176093663232, 1, 7, '{"trustee": "GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF", "trustor": "GCVW5LCRZFP7PENXTAGOVIQXADDNUXXZJCNKF4VQB2IK7W2LPJWF73UG", "authorize": true, "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF"}', 'GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF');
INSERT INTO history_operations VALUES (176093667329, 176093667328, 1, 7, '{"trustee": "GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF", "trustor": "GCVW5LCRZFP7PENXTAGOVIQXADDNUXXZJCNKF4VQB2IK7W2LPJWF73UG", "authorize": true, "asset_code": "EUR", "asset_type": "credit_alphanum4", "asset_issuer": "GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF"}', 'GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF');
INSERT INTO history_operations VALUES (180388630529, 180388630528, 1, 7, '{"trustee": "GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF", "trustor": "GCVW5LCRZFP7PENXTAGOVIQXADDNUXXZJCNKF4VQB2IK7W2LPJWF73UG", "authorize": false, "asset_code": "EUR", "asset_type": "credit_alphanum4", "asset_issuer": "GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF"}', 'GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF');
INSERT INTO history_operations VALUES (184683597825, 184683597824, 1, 0, '{"funder": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "account": "GCHPXGVDKPF5KT4CNAT7X77OXYZ7YVE4JHKFDUHCGCVWCL4K4PQ67KKZ", "starting_balance": "1000.0000000"}', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_operations VALUES (188978565121, 188978565120, 1, 8, '{"into": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "account": "GCHPXGVDKPF5KT4CNAT7X77OXYZ7YVE4JHKFDUHCGCVWCL4K4PQ67KKZ"}', 'GCHPXGVDKPF5KT4CNAT7X77OXYZ7YVE4JHKFDUHCGCVWCL4K4PQ67KKZ');
INSERT INTO history_operations VALUES (193273532417, 193273532416, 1, 0, '{"funder": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "account": "GDR53WAEIKOU3ZKN34CSHAWH7HV6K63CBJRUTWUDBFSMY7RRQK3SPKOS", "starting_balance": "20000000000.0000000"}', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_operations VALUES (197568499713, 197568499712, 1, 5, '{"inflation_dest": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H"}', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_operations VALUES (197568503809, 197568503808, 1, 5, '{"inflation_dest": "GDR53WAEIKOU3ZKN34CSHAWH7HV6K63CBJRUTWUDBFSMY7RRQK3SPKOS"}', 'GDR53WAEIKOU3ZKN34CSHAWH7HV6K63CBJRUTWUDBFSMY7RRQK3SPKOS');
INSERT INTO history_operations VALUES (201863467009, 201863467008, 1, 9, '{}', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_operations VALUES (206158434305, 206158434304, 1, 0, '{"funder": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "account": "GAYSCMKQY6EYLXOPTT6JPPOXDMVNBWITPTSZIVWW4LWARVBOTH5RTLAD", "starting_balance": "1000.0000000"}', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_operations VALUES (210453401601, 210453401600, 1, 10, '{"name": "name1", "value": "MTIzNA=="}', 'GAYSCMKQY6EYLXOPTT6JPPOXDMVNBWITPTSZIVWW4LWARVBOTH5RTLAD');
INSERT INTO history_operations VALUES (210453405697, 210453405696, 1, 10, '{"name": "name2", "value": "NTY3OA=="}', 'GAYSCMKQY6EYLXOPTT6JPPOXDMVNBWITPTSZIVWW4LWARVBOTH5RTLAD');
INSERT INTO history_operations VALUES (214748368897, 214748368896, 1, 10, '{"name": "name2", "value": null}', 'GAYSCMKQY6EYLXOPTT6JPPOXDMVNBWITPTSZIVWW4LWARVBOTH5RTLAD');
INSERT INTO history_operations VALUES (219043336193, 219043336192, 1, 10, '{"name": "name1", "value": "MTIzNA=="}', 'GAYSCMKQY6EYLXOPTT6JPPOXDMVNBWITPTSZIVWW4LWARVBOTH5RTLAD');
INSERT INTO history_operations VALUES (223338303489, 223338303488, 1, 10, '{"name": "name1", "value": "MDAwMA=="}', 'GAYSCMKQY6EYLXOPTT6JPPOXDMVNBWITPTSZIVWW4LWARVBOTH5RTLAD');
INSERT INTO history_operations VALUES (227633270785, 227633270784, 1, 0, '{"funder": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "account": "GACJPE4YUR22VP4CM2BDFDAHY3DLEF3H7NENKUQ53DT5TEI2GAHT5N4X", "starting_balance": "1000.0000000"}', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_operations VALUES (231928238081, 231928238080, 1, 1, '{"to": "GACJPE4YUR22VP4CM2BDFDAHY3DLEF3H7NENKUQ53DT5TEI2GAHT5N4X", "from": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "amount": "10.0000000", "asset_type": "native"}', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_operations VALUES (231928238082, 231928238080, 2, 1, '{"to": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "from": "GACJPE4YUR22VP4CM2BDFDAHY3DLEF3H7NENKUQ53DT5TEI2GAHT5N4X", "amount": "10.0000000", "asset_type": "native"}', 'GACJPE4YUR22VP4CM2BDFDAHY3DLEF3H7NENKUQ53DT5TEI2GAHT5N4X');
INSERT INTO history_operations VALUES (236223205377, 236223205376, 1, 0, '{"funder": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "account": "GANFZDRBCNTUXIODCJEYMACPMCSZEVE4WZGZ3CZDZ3P2SXK4KH75IK6Y", "starting_balance": "1000.0000000"}', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_operations VALUES (240518172673, 240518172672, 1, 1, '{"to": "GANFZDRBCNTUXIODCJEYMACPMCSZEVE4WZGZ3CZDZ3P2SXK4KH75IK6Y", "from": "GANFZDRBCNTUXIODCJEYMACPMCSZEVE4WZGZ3CZDZ3P2SXK4KH75IK6Y", "amount": "10.0000000", "asset_type": "native"}', 'GANFZDRBCNTUXIODCJEYMACPMCSZEVE4WZGZ3CZDZ3P2SXK4KH75IK6Y');
INSERT INTO history_operations VALUES (244813139969, 244813139968, 1, 0, '{"funder": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "account": "GAKNI7DPN7BGAB62BU4GQC364JCFXFV7KIVTTDVOQK2ZPBPSJETABDQU", "starting_balance": "1000.0000000"}', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_operations VALUES (249108107265, 249108107264, 1, 6, '{"limit": "922337203685.4775807", "trustee": "GANFZDRBCNTUXIODCJEYMACPMCSZEVE4WZGZ3CZDZ3P2SXK4KH75IK6Y", "trustor": "GANFZDRBCNTUXIODCJEYMACPMCSZEVE4WZGZ3CZDZ3P2SXK4KH75IK6Y", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GANFZDRBCNTUXIODCJEYMACPMCSZEVE4WZGZ3CZDZ3P2SXK4KH75IK6Y"}', 'GANFZDRBCNTUXIODCJEYMACPMCSZEVE4WZGZ3CZDZ3P2SXK4KH75IK6Y');


--
-- Data for Name: history_transaction_participants; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO history_transaction_participants VALUES (1, 12884905984, 1);
INSERT INTO history_transaction_participants VALUES (2, 12884905984, 2);
INSERT INTO history_transaction_participants VALUES (3, 17179873280, 1);
INSERT INTO history_transaction_participants VALUES (4, 17179873280, 3);
INSERT INTO history_transaction_participants VALUES (5, 21474840576, 3);
INSERT INTO history_transaction_participants VALUES (6, 21474844672, 3);
INSERT INTO history_transaction_participants VALUES (7, 21474848768, 3);
INSERT INTO history_transaction_participants VALUES (8, 25769807872, 3);
INSERT INTO history_transaction_participants VALUES (9, 30064775168, 1);
INSERT INTO history_transaction_participants VALUES (10, 30064775168, 4);
INSERT INTO history_transaction_participants VALUES (11, 34359742464, 4);
INSERT INTO history_transaction_participants VALUES (12, 34359742464, 1);
INSERT INTO history_transaction_participants VALUES (13, 34359746560, 4);
INSERT INTO history_transaction_participants VALUES (14, 34359746560, 1);
INSERT INTO history_transaction_participants VALUES (15, 34359750656, 4);
INSERT INTO history_transaction_participants VALUES (16, 34359750656, 1);
INSERT INTO history_transaction_participants VALUES (17, 34359754752, 4);
INSERT INTO history_transaction_participants VALUES (18, 34359754752, 1);
INSERT INTO history_transaction_participants VALUES (19, 38654709760, 1);
INSERT INTO history_transaction_participants VALUES (20, 38654709760, 5);
INSERT INTO history_transaction_participants VALUES (21, 42949677056, 5);
INSERT INTO history_transaction_participants VALUES (22, 42949677056, 1);
INSERT INTO history_transaction_participants VALUES (23, 47244644352, 1);
INSERT INTO history_transaction_participants VALUES (24, 47244644352, 6);
INSERT INTO history_transaction_participants VALUES (25, 51539611648, 6);
INSERT INTO history_transaction_participants VALUES (26, 51539611648, 7);
INSERT INTO history_transaction_participants VALUES (27, 55834578944, 1);
INSERT INTO history_transaction_participants VALUES (28, 55834578944, 8);
INSERT INTO history_transaction_participants VALUES (29, 55834583040, 1);
INSERT INTO history_transaction_participants VALUES (30, 55834583040, 9);
INSERT INTO history_transaction_participants VALUES (31, 60129546240, 9);
INSERT INTO history_transaction_participants VALUES (32, 60129550336, 8);
INSERT INTO history_transaction_participants VALUES (33, 60129550336, 9);
INSERT INTO history_transaction_participants VALUES (34, 64424513536, 8);
INSERT INTO history_transaction_participants VALUES (35, 64424513536, 9);
INSERT INTO history_transaction_participants VALUES (36, 68719480832, 1);
INSERT INTO history_transaction_participants VALUES (37, 68719480832, 10);
INSERT INTO history_transaction_participants VALUES (38, 68719484928, 1);
INSERT INTO history_transaction_participants VALUES (39, 68719484928, 11);
INSERT INTO history_transaction_participants VALUES (40, 68719489024, 1);
INSERT INTO history_transaction_participants VALUES (41, 68719489024, 12);
INSERT INTO history_transaction_participants VALUES (42, 73014448128, 11);
INSERT INTO history_transaction_participants VALUES (43, 73014452224, 10);
INSERT INTO history_transaction_participants VALUES (44, 77309415424, 12);
INSERT INTO history_transaction_participants VALUES (45, 77309415424, 10);
INSERT INTO history_transaction_participants VALUES (46, 77309419520, 12);
INSERT INTO history_transaction_participants VALUES (47, 77309423616, 12);
INSERT INTO history_transaction_participants VALUES (48, 81604382720, 11);
INSERT INTO history_transaction_participants VALUES (49, 81604382720, 10);
INSERT INTO history_transaction_participants VALUES (50, 81604382720, 12);
INSERT INTO history_transaction_participants VALUES (51, 85899350016, 11);
INSERT INTO history_transaction_participants VALUES (52, 85899350016, 10);
INSERT INTO history_transaction_participants VALUES (53, 85899350016, 12);
INSERT INTO history_transaction_participants VALUES (54, 90194317312, 1);
INSERT INTO history_transaction_participants VALUES (55, 90194317312, 13);
INSERT INTO history_transaction_participants VALUES (56, 90194321408, 1);
INSERT INTO history_transaction_participants VALUES (57, 90194321408, 14);
INSERT INTO history_transaction_participants VALUES (58, 94489284608, 13);
INSERT INTO history_transaction_participants VALUES (59, 98784251904, 13);
INSERT INTO history_transaction_participants VALUES (60, 103079219200, 14);
INSERT INTO history_transaction_participants VALUES (61, 103079219200, 13);
INSERT INTO history_transaction_participants VALUES (62, 107374186496, 1);
INSERT INTO history_transaction_participants VALUES (63, 107374186496, 15);
INSERT INTO history_transaction_participants VALUES (64, 111669153792, 15);
INSERT INTO history_transaction_participants VALUES (65, 111669157888, 15);
INSERT INTO history_transaction_participants VALUES (66, 115964121088, 1);
INSERT INTO history_transaction_participants VALUES (67, 115964121088, 16);
INSERT INTO history_transaction_participants VALUES (68, 120259088384, 16);
INSERT INTO history_transaction_participants VALUES (69, 120259092480, 16);
INSERT INTO history_transaction_participants VALUES (70, 120259096576, 16);
INSERT INTO history_transaction_participants VALUES (71, 120259100672, 16);
INSERT INTO history_transaction_participants VALUES (72, 120259104768, 16);
INSERT INTO history_transaction_participants VALUES (73, 120259108864, 16);
INSERT INTO history_transaction_participants VALUES (74, 120259112960, 16);
INSERT INTO history_transaction_participants VALUES (75, 124554055680, 16);
INSERT INTO history_transaction_participants VALUES (76, 128849022976, 16);
INSERT INTO history_transaction_participants VALUES (77, 133143990272, 16);
INSERT INTO history_transaction_participants VALUES (78, 137438957568, 16);
INSERT INTO history_transaction_participants VALUES (79, 137438961664, 16);
INSERT INTO history_transaction_participants VALUES (80, 141733924864, 1);
INSERT INTO history_transaction_participants VALUES (81, 141733924864, 17);
INSERT INTO history_transaction_participants VALUES (82, 146028892160, 17);
INSERT INTO history_transaction_participants VALUES (83, 150323859456, 17);
INSERT INTO history_transaction_participants VALUES (84, 154618826752, 17);
INSERT INTO history_transaction_participants VALUES (85, 158913794048, 17);
INSERT INTO history_transaction_participants VALUES (86, 163208761344, 1);
INSERT INTO history_transaction_participants VALUES (87, 163208761344, 18);
INSERT INTO history_transaction_participants VALUES (88, 163208765440, 19);
INSERT INTO history_transaction_participants VALUES (89, 163208765440, 1);
INSERT INTO history_transaction_participants VALUES (90, 167503728640, 19);
INSERT INTO history_transaction_participants VALUES (91, 171798695936, 18);
INSERT INTO history_transaction_participants VALUES (92, 171798700032, 18);
INSERT INTO history_transaction_participants VALUES (93, 176093663232, 19);
INSERT INTO history_transaction_participants VALUES (94, 176093663232, 18);
INSERT INTO history_transaction_participants VALUES (95, 176093667328, 19);
INSERT INTO history_transaction_participants VALUES (96, 176093667328, 18);
INSERT INTO history_transaction_participants VALUES (97, 180388630528, 19);
INSERT INTO history_transaction_participants VALUES (98, 180388630528, 18);
INSERT INTO history_transaction_participants VALUES (99, 184683597824, 1);
INSERT INTO history_transaction_participants VALUES (100, 184683597824, 20);
INSERT INTO history_transaction_participants VALUES (101, 188978565120, 20);
INSERT INTO history_transaction_participants VALUES (102, 188978565120, 1);
INSERT INTO history_transaction_participants VALUES (103, 193273532416, 1);
INSERT INTO history_transaction_participants VALUES (104, 193273532416, 21);
INSERT INTO history_transaction_participants VALUES (105, 197568499712, 1);
INSERT INTO history_transaction_participants VALUES (106, 197568503808, 21);
INSERT INTO history_transaction_participants VALUES (107, 201863467008, 1);
INSERT INTO history_transaction_participants VALUES (108, 201863467008, 21);
INSERT INTO history_transaction_participants VALUES (109, 206158434304, 1);
INSERT INTO history_transaction_participants VALUES (110, 206158434304, 22);
INSERT INTO history_transaction_participants VALUES (111, 210453401600, 22);
INSERT INTO history_transaction_participants VALUES (112, 210453405696, 22);
INSERT INTO history_transaction_participants VALUES (113, 214748368896, 22);
INSERT INTO history_transaction_participants VALUES (114, 219043336192, 22);
INSERT INTO history_transaction_participants VALUES (115, 223338303488, 22);
INSERT INTO history_transaction_participants VALUES (116, 227633270784, 1);
INSERT INTO history_transaction_participants VALUES (117, 227633270784, 23);
INSERT INTO history_transaction_participants VALUES (118, 231928238080, 1);
INSERT INTO history_transaction_participants VALUES (119, 231928238080, 23);
INSERT INTO history_transaction_participants VALUES (120, 236223205376, 1);
INSERT INTO history_transaction_participants VALUES (121, 236223205376, 24);
INSERT INTO history_transaction_participants VALUES (122, 240518172672, 24);
INSERT INTO history_transaction_participants VALUES (123, 244813139968, 1);
INSERT INTO history_transaction_participants VALUES (124, 244813139968, 25);
INSERT INTO history_transaction_participants VALUES (125, 249108107264, 24);


--
-- Name: history_transaction_participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('history_transaction_participants_id_seq', 125, true);


--
-- Data for Name: history_transactions; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO history_transactions VALUES ('f5e0d1f500b2d0c4b42fb8a438d5ed764bc58d1392f4328f4713af407b1968ca', 3, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 1, 100, 1, '2016-06-29 16:34:09.013772', '2016-06-29 16:34:09.013772', 12884905984, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAABAAAAAQAAAAAAAABkAAAAAF4MUYAAAAAAAAAAAQAAAAAAAAAAAAAAAC6N7oJcJiUzTWRDL98Bj3fVrJUB19wFvCzEHh8nn/IOAAAAAlQL5AAAAAAAAAAAAVb8BfcAAABAXK6PX0t3GL+4TcNTKBIB9vkqahUMix+Rf/7WY5d6YJsmeBQ+o5ULJWvzgfc3aTx4f/DCUXc54KcOfCfzqH0uDQ==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAAAMAAAAAAAAAAC6N7oJcJiUzTWRDL98Bj3fVrJUB19wFvCzEHh8nn/IOAAAAAlQL5AAAAAADAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAMAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2sVNYG5wAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAABAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnZAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAADAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnY/+cAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{XK6PX0t3GL+4TcNTKBIB9vkqahUMix+Rf/7WY5d6YJsmeBQ+o5ULJWvzgfc3aTx4f/DCUXc54KcOfCfzqH0uDQ==}', 'none', NULL, '[100,1577865601)');
INSERT INTO history_transactions VALUES ('66e27fb28870cb5256ea92764bcb222adbbaa5fec2d89a62a9aa8c9c8e2ee9e9', 4, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 2, 100, 1, '2016-06-29 16:34:09.021772', '2016-06-29 16:34:09.021772', 17179873280, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAACAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAA7lAZIpCRwStYOr2IrB6aiXLG/wsNVkHBYtBKJinuINUAAAACVAvkAAAAAAAAAAABVvwF9wAAAECAUpO+hxiga/YgRsV3rFpBJydgOyn0TPImJCaQCMikkiG+sNXrQBsYXjJrlOiGjGsU3rk4uvGl85AriYD9PNYH', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAAAQAAAAAAAAAAO5QGSKQkcErWDq9iKwemolyxv8LDVZBwWLQSiYp7iDVAAAAAlQL5AAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAQAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2rv9MNzgAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAADAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrFTWBucAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAEAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrFTWBs4AAAAAAAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{gFKTvocYoGv2IEbFd6xaQScnYDsp9EzyJiQmkAjIpJIhvrDV60AbGF4ya5TohoxrFN65OLrxpfOQK4mA/TzWBw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('e9d1a3000aea36743142f2ede106d3cb37c3d7e88508e3f21b496370b5863858', 5, 1, 'GDXFAGJCSCI4CK2YHK6YRLA6TKEXFRX7BMGVMQOBMLIEUJRJ5YQNLMIB', 17179869185, 100, 1, '2016-06-29 16:34:09.028055', '2016-06-29 16:34:09.028055', 21474840576, 'AAAAAO5QGSKQkcErWDq9iKwemolyxv8LDVZBwWLQSiYp7iDVAAAAZAAAAAQAAAABAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAEAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAASnuINUAAABASz0AtZeNzXSXkjPkKJfOE8aUTAuPR6pxMMbF337wxE3wzOTDaVcDQ2N5P3E9MKc+fbbFhZ9K+07+J0wMGltRBA==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAFAAAAAAAAAAA=', 'AAAAAAAAAAEAAAABAAAAAQAAAAUAAAAAAAAAAO5QGSKQkcErWDq9iKwemolyxv8LDVZBwWLQSiYp7iDVAAAAAlQL4tQAAAAEAAAAAwAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAEAAAAAAAAAADuUBkikJHBK1g6vYisHpqJcsb/Cw1WQcFi0EomKe4g1QAAAAJUC+QAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAFAAAAAAAAAADuUBkikJHBK1g6vYisHpqJcsb/Cw1WQcFi0EomKe4g1QAAAAJUC+OcAAAABAAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{Sz0AtZeNzXSXkjPkKJfOE8aUTAuPR6pxMMbF337wxE3wzOTDaVcDQ2N5P3E9MKc+fbbFhZ9K+07+J0wMGltRBA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('995b9269f9f9c4c1eace75501188766d6e8ae40c5413120811a50437683cb74c', 5, 2, 'GDXFAGJCSCI4CK2YHK6YRLA6TKEXFRX7BMGVMQOBMLIEUJRJ5YQNLMIB', 17179869186, 100, 1, '2016-06-29 16:34:09.02979', '2016-06-29 16:34:09.02979', 21474844672, 'AAAAAO5QGSKQkcErWDq9iKwemolyxv8LDVZBwWLQSiYp7iDVAAAAZAAAAAQAAAACAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAD2T51Mi2fjmCY4Z+R5JON1LluqzrnpmTxUJXTp/A3FRwAAAAEAAAAAAAAAASnuINUAAABADpkMMc7kkkYjDoPwfUlOE9tLYvWHI/m+BBe/gCKN1cVvEF1UBVeCCuGBTjury4TqoxplKl4NZHJST5/Orr4XCA==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAFAAAAAAAAAAA=', 'AAAAAAAAAAEAAAABAAAAAQAAAAUAAAAAAAAAAO5QGSKQkcErWDq9iKwemolyxv8LDVZBwWLQSiYp7iDVAAAAAlQL4tQAAAAEAAAAAwAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAQAAAAD2T51Mi2fjmCY4Z+R5JON1LluqzrnpmTxUJXTp/A3FRwAAAAEAAAAAAAAAAA==', 'AAAAAQAAAAEAAAAFAAAAAAAAAADuUBkikJHBK1g6vYisHpqJcsb/Cw1WQcFi0EomKe4g1QAAAAJUC+M4AAAABAAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{DpkMMc7kkkYjDoPwfUlOE9tLYvWHI/m+BBe/gCKN1cVvEF1UBVeCCuGBTjury4TqoxplKl4NZHJST5/Orr4XCA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('f78dca926455579b4a43009ffe35a0229a6da4bed32d3c999d7a06ad26605a25', 5, 3, 'GDXFAGJCSCI4CK2YHK6YRLA6TKEXFRX7BMGVMQOBMLIEUJRJ5YQNLMIB', 17179869187, 100, 1, '2016-06-29 16:34:09.031433', '2016-06-29 16:34:09.031433', 21474848768, 'AAAAAO5QGSKQkcErWDq9iKwemolyxv8LDVZBwWLQSiYp7iDVAAAAZAAAAAQAAAADAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAAAAAABAAAAAgAAAAEAAAACAAAAAQAAAAIAAAAAAAAAAAAAAAAAAAABKe4g1QAAAEDglRRymtLjw+ImmGwTiBTKE7X7+2CywlHw8qed+t520SbAggcqboy5KXJaEP51/wRSMxtZUgDOFfaDn9Df04EA', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAFAAAAAAAAAAA=', 'AAAAAAAAAAEAAAABAAAAAQAAAAUAAAAAAAAAAO5QGSKQkcErWDq9iKwemolyxv8LDVZBwWLQSiYp7iDVAAAAAlQL4tQAAAAEAAAAAwAAAAEAAAAAAAAAAAAAAAABAgICAAAAAQAAAAD2T51Mi2fjmCY4Z+R5JON1LluqzrnpmTxUJXTp/A3FRwAAAAEAAAAAAAAAAA==', 'AAAAAQAAAAEAAAAFAAAAAAAAAADuUBkikJHBK1g6vYisHpqJcsb/Cw1WQcFi0EomKe4g1QAAAAJUC+LUAAAABAAAAAMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{4JUUcprS48PiJphsE4gUyhO1+/tgssJR8PKnnfredtEmwIIHKm6MuSlyWhD+df8EUjMbWVIAzhX2g5/Q39OBAA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('a9085e13fbe9f84e07e320a0d445536de1afc2cfd8c7e4186687807edd2b4897', 6, 1, 'GDXFAGJCSCI4CK2YHK6YRLA6TKEXFRX7BMGVMQOBMLIEUJRJ5YQNLMIB', 17179869188, 100, 1, '2016-06-29 16:34:09.035934', '2016-06-29 16:34:09.035934', 25769807872, 'AAAAAO5QGSKQkcErWDq9iKwemolyxv8LDVZBwWLQSiYp7iDVAAAAZAAAAAQAAAAEAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAEAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAinuINUAAABA4PRAe0en/05ZH2leCeTOsxbT0cUu3wgUiWUcuDk4ya8G/gI90hlV6pzOYyAB6Zt5fN7pRrPRL/tTlnjgUAjaBvwNxUcAAABAFmdGR6JZukKJUC3Vr2YEJ/24G3tesqTv4cV5UcAozRhS2+w0PYVVqe7QTmOMNSGX/C3LxP1tSvpXdU/OhYsODw==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAFAAAAAAAAAAA=', 'AAAAAAAAAAEAAAABAAAAAQAAAAYAAAAAAAAAAO5QGSKQkcErWDq9iKwemolyxv8LDVZBwWLQSiYp7iDVAAAAAlQL4nAAAAAEAAAABAAAAAEAAAAAAAAAAAAAAAACAgICAAAAAQAAAAD2T51Mi2fjmCY4Z+R5JON1LluqzrnpmTxUJXTp/A3FRwAAAAEAAAAAAAAAAA==', 'AAAAAgAAAAMAAAAFAAAAAAAAAADuUBkikJHBK1g6vYisHpqJcsb/Cw1WQcFi0EomKe4g1QAAAAJUC+LUAAAABAAAAAMAAAABAAAAAAAAAAAAAAAAAQICAgAAAAEAAAAA9k+dTItn45gmOGfkeSTjdS5bqs656Zk8VCV06fwNxUcAAAABAAAAAAAAAAAAAAABAAAABgAAAAAAAAAA7lAZIpCRwStYOr2IrB6aiXLG/wsNVkHBYtBKJinuINUAAAACVAvicAAAAAQAAAAEAAAAAQAAAAAAAAAAAAAAAAECAgIAAAABAAAAAPZPnUyLZ+OYJjhn5Hkk43UuW6rOuemZPFQldOn8DcVHAAAAAQAAAAAAAAAA', '{4PRAe0en/05ZH2leCeTOsxbT0cUu3wgUiWUcuDk4ya8G/gI90hlV6pzOYyAB6Zt5fN7pRrPRL/tTlnjgUAjaBg==,FmdGR6JZukKJUC3Vr2YEJ/24G3tesqTv4cV5UcAozRhS2+w0PYVVqe7QTmOMNSGX/C3LxP1tSvpXdU/OhYsODw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('0fb9c2e20946222b23e1d1d660de9d74576c41cfd9b199f9d565a013c1ef89ca', 7, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 3, 100, 1, '2016-06-29 16:34:09.040518', '2016-06-29 16:34:09.040518', 30064775168, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAADAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAOerFQRLRq/h3Xf4EErEqz7oD9wk20zX+d/h4dXc7DToAAAACVAvkAAAAAAAAAAABVvwF9wAAAED8tIFyog9OeCqiaBNfxFdAlneNYTfjoNUMKi6FJCY5BqemnDBxGox3jKS/xx4zpxAToEFp3Y2M+NRJIU4g/H0J', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAAAcAAAAAAAAAADnqxUES0av4d13+BBKxKs+6A/cJNtM1/nf4eHV3Ow06AAAAAlQL5AAAAAAHAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAcAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2rKtAUtQAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAEAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtq7/TDc4AAAAAAAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAHAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtq7/TDbUAAAAAAAAAAMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{/LSBcqIPTngqomgTX8RXQJZ3jWE346DVDCouhSQmOQanppwwcRqMd4ykv8ceM6cQE6BBad2NjPjUSSFOIPx9CQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('dd74eee27a59843b28a05ad08abf65eaa231b7debe4d05550c0a7a424cca5929', 8, 1, 'GA46VRKBCLI2X6DXLX7AIEVRFLH3UA7XBE3NGNP6O74HQ5LXHMGTV2JB', 30064771073, 100, 1, '2016-06-29 16:34:09.046461', '2016-06-29 16:34:09.046461', 34359742464, 'AAAAADnqxUES0av4d13+BBKxKs+6A/cJNtM1/nf4eHV3Ow06AAAAZAAAAAcAAAABAAAAAAAAAAIAAAAAAAAAewAAAAEAAAAAAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAAAAAAAAJiWgAAAAAAAAAABdzsNOgAAAEBjk5EFqV8GiL9xU62OUCKeScXxGMTMqJoD7ryiGf5jLPZJRSphbWC3ZycHE+pDuu/6EKSqcNUri5AXzQmM+GYB', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAA=', 'AAAAAAAAAAEAAAADAAAAAQAAAAgAAAAAAAAAADnqxUES0av4d13+BBKxKs+6A/cJNtM1/nf4eHV3Ow06AAAAAlNzS/AAAAAHAAAABAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAwAAAAcAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2rKtAUtQAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAgAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2rKvY6VQAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAHAAAAAAAAAAA56sVBEtGr+Hdd/gQSsSrPugP3CTbTNf53+Hh1dzsNOgAAAAJUC+QAAAAABwAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAIAAAAAAAAAAA56sVBEtGr+Hdd/gQSsSrPugP3CTbTNf53+Hh1dzsNOgAAAAJUC+OcAAAABwAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{Y5ORBalfBoi/cVOtjlAinknF8RjEzKiaA+68ohn+Yyz2SUUqYW1gt2cnBxPqQ7rv+hCkqnDVK4uQF80JjPhmAQ==}', 'id', '123', NULL);
INSERT INTO history_transactions VALUES ('2551e76a3ce4881b7bc73fdfd89d670d511ea7d4e56156252b51777023202de7', 8, 2, 'GA46VRKBCLI2X6DXLX7AIEVRFLH3UA7XBE3NGNP6O74HQ5LXHMGTV2JB', 30064771074, 100, 1, '2016-06-29 16:34:09.048849', '2016-06-29 16:34:09.048849', 34359746560, 'AAAAADnqxUES0av4d13+BBKxKs+6A/cJNtM1/nf4eHV3Ow06AAAAZAAAAAcAAAACAAAAAAAAAAEAAAAFaGVsbG8AAAAAAAABAAAAAAAAAAEAAAAAYvwdC9CRsrYcDdZWNGsqaNfTR8bywsjubQRHAlb8BfcAAAAAAAAAAACYloAAAAAAAAAAAXc7DToAAABAS2+MaPA79AjD0B7qjl0qEz0N6CkDmoS4kgnXjZfbvdc9IkqNm0S+vKBNgV80pSfixY147L+jvS/ganovqbLiAQ==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAQAAAAgAAAAAAAAAADnqxUES0av4d13+BBKxKs+6A/cJNtM1/nf4eHV3Ow06AAAAAlLatXAAAAAHAAAABAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAgAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2rKxxf9QAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAIAAAAAAAAAAA56sVBEtGr+Hdd/gQSsSrPugP3CTbTNf53+Hh1dzsNOgAAAAJUC+M4AAAABwAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{S2+MaPA79AjD0B7qjl0qEz0N6CkDmoS4kgnXjZfbvdc9IkqNm0S+vKBNgV80pSfixY147L+jvS/ganovqbLiAQ==}', 'text', 'hello', NULL);
INSERT INTO history_transactions VALUES ('3b36ecfbcc2adb0cfff08ae86199f64e12984f084bb03be9bb249611df82322b', 8, 3, 'GA46VRKBCLI2X6DXLX7AIEVRFLH3UA7XBE3NGNP6O74HQ5LXHMGTV2JB', 30064771075, 100, 1, '2016-06-29 16:34:09.050995', '2016-06-29 16:34:09.050995', 34359750656, 'AAAAADnqxUES0av4d13+BBKxKs+6A/cJNtM1/nf4eHV3Ow06AAAAZAAAAAcAAAADAAAAAAAAAAMBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAAEAAAAAAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAAAAAAAAJiWgAAAAAAAAAABdzsNOgAAAEDC9hMtMYZ6hbx1iAdXngRcCYQmf8eu4zcB9SLH2998tVYca6QYig5Dsgy2oCMD1J7khIL9jz/VWjcPhvTVvC8L', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAQAAAAgAAAAAAAAAADnqxUES0av4d13+BBKxKs+6A/cJNtM1/nf4eHV3Ow06AAAAAlJCHvAAAAAHAAAABAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAgAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2rK0KFlQAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAIAAAAAAAAAAA56sVBEtGr+Hdd/gQSsSrPugP3CTbTNf53+Hh1dzsNOgAAAAJUC+LUAAAABwAAAAMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{wvYTLTGGeoW8dYgHV54EXAmEJn/HruM3AfUix9vffLVWHGukGIoOQ7IMtqAjA9Se5ISC/Y8/1Vo3D4b01bwvCw==}', 'hash', 'AQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQE=', NULL);
INSERT INTO history_transactions VALUES ('e14885cb66af5f7f5e991b014eec475c61cc831292cf5526cdd0cda145300837', 8, 4, 'GA46VRKBCLI2X6DXLX7AIEVRFLH3UA7XBE3NGNP6O74HQ5LXHMGTV2JB', 30064771076, 100, 1, '2016-06-29 16:34:09.053096', '2016-06-29 16:34:09.053096', 34359754752, 'AAAAADnqxUES0av4d13+BBKxKs+6A/cJNtM1/nf4eHV3Ow06AAAAZAAAAAcAAAAEAAAAAAAAAAQCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAAAEAAAAAAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAAAAAAAAJiWgAAAAAAAAAABdzsNOgAAAEBOfq9PQ8EGcpjRWEaqGxvhBjSVuk6K5A2rthLYHnmAXmQ1JjJD3EddjiES3bPZUF5efGQvRjoEKgiB2dU3f2wF', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAQAAAAgAAAAAAAAAADnqxUES0av4d13+BBKxKs+6A/cJNtM1/nf4eHV3Ow06AAAAAlGpiHAAAAAHAAAABAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAgAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2rK2irNQAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAIAAAAAAAAAAA56sVBEtGr+Hdd/gQSsSrPugP3CTbTNf53+Hh1dzsNOgAAAAJUC+JwAAAABwAAAAQAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{Tn6vT0PBBnKY0VhGqhsb4QY0lbpOiuQNq7YS2B55gF5kNSYyQ9xHXY4hEt2z2VBeXnxkL0Y6BCoIgdnVN39sBQ==}', 'return', 'AgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgI=', NULL);
INSERT INTO history_transactions VALUES ('66c28c0ccd5a2e47026aacafa2ecd3c501fe5de349ef376c0f8afb893c7bb55d', 9, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 4, 100, 1, '2016-06-29 16:34:09.058301', '2016-06-29 16:34:09.058301', 38654709760, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAAEAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAADd1O3oAD6ZmsdNe9Y4zdIQW1rTvIfAEYi/0il9kFYl4AAAACVAvkAAAAAAAAAAABVvwF9wAAAEARD6MVWgEASusfhr6JdF9K3Rie2XCRJKl/NoKyJcrd1kGs3ygpp55xu80YlFwgNVErZ/cEAHYOq06CwNfnE2sC', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAAAkAAAAAAAAAAA3dTt6AA+mZrHTXvWOM3SEFta07yHwBGIv9IpfZBWJeAAAAAlQL5AAAAAAJAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAkAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2qlmWyHAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAIAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtqytoqzUAAAAAAAAAAMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAJAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtqytoqxwAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{EQ+jFVoBAErrH4a+iXRfSt0YntlwkSSpfzaCsiXK3dZBrN8oKaeecbvNGJRcIDVRK2f3BAB2DqtOgsDX5xNrAg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('fdb696a797b769176cbaed3a50e4a6a8671119621f65a3f954a3bcf100c7ef0c', 10, 1, 'GAG52TW6QAB6TGNMOTL32Y4M3UQQLNNNHPEHYAIYRP6SFF6ZAVRF5ZQY', 38654705665, 200, 2, '2016-06-29 16:34:09.063825', '2016-06-29 16:34:09.063825', 42949677056, 'AAAAAA3dTt6AA+mZrHTXvWOM3SEFta07yHwBGIv9IpfZBWJeAAAAyAAAAAkAAAABAAAAAAAAAAAAAAACAAAAAAAAAAEAAAAAYvwdC9CRsrYcDdZWNGsqaNfTR8bywsjubQRHAlb8BfcAAAAAAAAAAAX14QAAAAAAAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAAAAAAABfXhAAAAAAAAAAAB2QViXgAAAEAxyl5gvCCDC7l0pq9b/Btd3cOUUcY9Rv0ALxVjul4EVSL1Vygr107GjDo11+YswdmlCuWf7KItU0chlogpns4L', 'AAAAAAAAAMgAAAAAAAAAAgAAAAAAAAABAAAAAAAAAAAAAAABAAAAAAAAAAA=', 'AAAAAAAAAAIAAAADAAAAAQAAAAoAAAAAAAAAAA3dTt6AA+mZrHTXvWOM3SEFta07yHwBGIv9IpfZBWJeAAAAAk4WAjgAAAAJAAAAAQAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAwAAAAkAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2qlmWyHAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAoAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2ql+MqXAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAEAAAAKAAAAAAAAAAAN3U7egAPpmax0171jjN0hBbWtO8h8ARiL/SKX2QViXgAAAAJIICE4AAAACQAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAKAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtqplgopwAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', 'AAAAAgAAAAMAAAAJAAAAAAAAAAAN3U7egAPpmax0171jjN0hBbWtO8h8ARiL/SKX2QViXgAAAAJUC+QAAAAACQAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAKAAAAAAAAAAAN3U7egAPpmax0171jjN0hBbWtO8h8ARiL/SKX2QViXgAAAAJUC+M4AAAACQAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{McpeYLwggwu5dKavW/wbXd3DlFHGPUb9AC8VY7peBFUi9VcoK9dOxow6NdfmLMHZpQrln+yiLVNHIZaIKZ7OCw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('67601a2ca212b84092a7d3c521172b67f4b93d72b726a06c540917d2ab83c1a1', 11, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 5, 100, 1, '2016-06-29 16:34:09.069515', '2016-06-29 16:34:09.069515', 47244644352, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAAFAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAxVmE0iEp9S70YdkrhAu6dT4jSnPvbUuzitQ4oBcfaDMAAAACVAvkAAAAAAAAAAABVvwF9wAAAEBHLko6/Tbv0v/5CWHkixXnbyoU6qQ6yewZGqPHFSzNxMfud86eYGkN0j4msMCXfLAou7iKOVn0MWyzlpvYRA0B', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAAAsAAAAAAAAAAMVZhNIhKfUu9GHZK4QLunU+I0pz721Ls4rUOKAXH2gzAAAAAlQL5AAAAAALAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAsAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2qBF2pgwAAAAAAAAABQAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAKAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtqplgopwAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAALAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtqplgooMAAAAAAAAAAUAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{Ry5KOv0279L/+Qlh5IsV528qFOqkOsnsGRqjxxUszcTH7nfOnmBpDdI+JrDAl3ywKLu4ijlZ9DFss5ab2EQNAQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('0e128647b2b93786b6b76e182dcda0173757066f8caf0523d1ba3b47fd6f720d', 12, 1, 'GDCVTBGSEEU7KLXUMHMSXBALXJ2T4I2KOPXW2S5TRLKDRIAXD5UDHAYO', 47244640257, 100, 1, '2016-06-29 16:34:09.075813', '2016-06-29 16:34:09.075814', 51539611648, 'AAAAAMVZhNIhKfUu9GHZK4QLunU+I0pz721Ls4rUOKAXH2gzAAAAZAAAAAsAAAABAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAg/K/Blr9FO/nVEGLdmCzChMYpmcQzxIhFm6NBzxznX0AAAAAHc1lAAAAAAAAAAABFx9oMwAAAEBwY9HQAR2SMPe3JPvmBBtBk2jfog0GFEFYkLNFzQNqvYl7iZitmO5FQmkKlv/NO5ZcaWBqXcHhOQpk0s2XSBQF', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAAAwAAAAAAAAAAIPyvwZa/RTv51RBi3ZgswoTGKZnEM8SIRZujQc8c519AAAAAB3NZQAAAAAMAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAwAAAAAAAAAAMVZhNIhKfUu9GHZK4QLunU+I0pz721Ls4rUOKAXH2gzAAAAAjY+fpwAAAALAAAAAQAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAALAAAAAAAAAADFWYTSISn1LvRh2SuEC7p1PiNKc+9tS7OK1DigFx9oMwAAAAJUC+QAAAAACwAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAMAAAAAAAAAADFWYTSISn1LvRh2SuEC7p1PiNKc+9tS7OK1DigFx9oMwAAAAJUC+OcAAAACwAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{cGPR0AEdkjD3tyT75gQbQZNo36INBhRBWJCzRc0Dar2Je4mYrZjuRUJpCpb/zTuWXGlgal3B4TkKZNLNl0gUBQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('cd8a8e9eb53fd268d1294e228995c27f422d90783c4054e44ab0028fc1da210a', 13, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 6, 100, 1, '2016-06-29 16:34:09.081166', '2016-06-29 16:34:09.081166', 55834578944, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAAGAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAji4PQpc6JMWt5AB56WXIEop14Pn7tW6uf6xE+vY7ZNwAAAACVAvkAAAAAAAAAAABVvwF9wAAAEAUtdYWyr64yv/rKPr0/vV4vYyonfsWxpxHsiYLHKJ3bm6k+ypiAByc8t0K+7bzxSLPjmjKKN5Prw7AdenlC7MB', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAAA0AAAAAAAAAAI4uD0KXOiTFreQAeellyBKKdeD5+7Vurn+sRPr2O2TcAAAAAlQL5AAAAAANAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAA0AAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2pb1qwUQAAAAAAAAABwAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAALAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtqgRdqYMAAAAAAAAAAUAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAANAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtqgRdqWoAAAAAAAAAAYAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{FLXWFsq+uMr/6yj69P71eL2MqJ37FsacR7ImCxyid25upPsqYgAcnPLdCvu288Uiz45oyijeT68OwHXp5QuzAQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('bfbd5e9457d717bcf847291a6c24b7cd8db4ff784ecd4592be30d08146c0c264', 13, 2, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 7, 100, 1, '2016-06-29 16:34:09.08373', '2016-06-29 16:34:09.08373', 55834583040, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAAHAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAG5M9WO2kexu4dljTd0YSuyEnmDUsxKamzJWiv4FGkoQAAAACVAvkAAAAAAAAAAABVvwF9wAAAEDY1TiMj+qj8+zYb2Vb60h+qWxZtFfSGwb0kvKttSFAHQhGOjIddiVQopx9LDRO6UgPmLLxFvQpIzeGnagh3vQD', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAAA0AAAAAAAAAABuTPVjtpHsbuHZY03dGErshJ5g1LMSmpsyVor+BRpKEAAAAAlQL5AAAAAANAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAA0AAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2o2le3UQAAAAAAAAABwAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAANAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtqgRdqVEAAAAAAAAAAcAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{2NU4jI/qo/Ps2G9lW+tIfqlsWbRX0hsG9JLyrbUhQB0IRjoyHXYlUKKcfSw0TulID5iy8Rb0KSM3hp2oId70Aw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('dbd964fcfdb336a30f21c240fffdaf73d7c75880ed1b99375c62f84e3e592570', 14, 1, 'GANZGPKY5WSHWG5YOZMNG52GCK5SCJ4YGUWMJJVGZSK2FP4BI2JIJN2C', 55834574849, 100, 1, '2016-06-29 16:34:09.089246', '2016-06-29 16:34:09.089247', 60129546240, 'AAAAABuTPVjtpHsbuHZY03dGErshJ5g1LMSmpsyVor+BRpKEAAAAZAAAAA0AAAABAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABVVNEAAAAAACOLg9Clzokxa3kAHnpZcgSinXg+fu1bq5/rET69jtk3H//////////AAAAAAAAAAGBRpKEAAAAQGDAV/5Op2DmFUP84dmyT5G/gxn1WzgdMrkSSU7wfpu39ycq36Sg+gs2ypRjw5hxxeMUj/GVEKipcDGndei38Aw=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAGAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAAA4AAAABAAAAABuTPVjtpHsbuHZY03dGErshJ5g1LMSmpsyVor+BRpKEAAAAAVVTRAAAAAAAji4PQpc6JMWt5AB56WXIEop14Pn7tW6uf6xE+vY7ZNwAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAAA4AAAAAAAAAABuTPVjtpHsbuHZY03dGErshJ5g1LMSmpsyVor+BRpKEAAAAAlQL45wAAAANAAAAAQAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAANAAAAAAAAAAAbkz1Y7aR7G7h2WNN3RhK7ISeYNSzEpqbMlaK/gUaShAAAAAJUC+QAAAAADQAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAOAAAAAAAAAAAbkz1Y7aR7G7h2WNN3RhK7ISeYNSzEpqbMlaK/gUaShAAAAAJUC+OcAAAADQAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{YMBX/k6nYOYVQ/zh2bJPkb+DGfVbOB0yuRJJTvB+m7f3JyrfpKD6CzbKlGPDmHHF4xSP8ZUQqKlwMad16LfwDA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('30880dd42d8e402a30d8a3527b56c1e33e18e87c46e1332ea5cfc1721fd87cfb', 14, 2, 'GCHC4D2CS45CJRNN4QAHT2LFZAJIU5PA7H53K3VOP6WEJ6XWHNSNZKQG', 55834574849, 100, 1, '2016-06-29 16:34:09.090837', '2016-06-29 16:34:09.090837', 60129550336, 'AAAAAI4uD0KXOiTFreQAeellyBKKdeD5+7Vurn+sRPr2O2TcAAAAZAAAAA0AAAABAAAAAAAAAAAAAAABAAAAAAAAAAEAAAAAG5M9WO2kexu4dljTd0YSuyEnmDUsxKamzJWiv4FGkoQAAAAAAAAAAAX14QAAAAAAAAAAAfY7ZNwAAABAieZSSuOZqlwtyjnj5d/S0GUSGiQvy0ipPLynpl4UvO8qc7CDz3vsLROlN2g50qXirydSOdao56hvRhrEfRsGCA==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAQAAAA4AAAAAAAAAABuTPVjtpHsbuHZY03dGErshJ5g1LMSmpsyVor+BRpKEAAAAAloBxJwAAAANAAAAAQAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAA4AAAAAAAAAAI4uD0KXOiTFreQAeellyBKKdeD5+7Vurn+sRPr2O2TcAAAAAk4WApwAAAANAAAAAQAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAANAAAAAAAAAACOLg9Clzokxa3kAHnpZcgSinXg+fu1bq5/rET69jtk3AAAAAJUC+QAAAAADQAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAOAAAAAAAAAACOLg9Clzokxa3kAHnpZcgSinXg+fu1bq5/rET69jtk3AAAAAJUC+OcAAAADQAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{ieZSSuOZqlwtyjnj5d/S0GUSGiQvy0ipPLynpl4UvO8qc7CDz3vsLROlN2g50qXirydSOdao56hvRhrEfRsGCA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('852ba25e0e4aa149a22dc193bcb645ae9eba23e7f7432707f3b910474e9b6a5b', 28, 5, 'GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES', 115964116997, 100, 1, '2016-06-29 16:34:09.181842', '2016-06-29 16:34:09.181842', 120259104768, 'AAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAZAAAABsAAAAFAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAAAAAABAAAAAAAAAAEAAAACAAAAAQAAAAIAAAAAAAAAAAAAAAAAAAABMJ4wUAAAAEAnFzc6kqweyIL4TzIDbr+8GUOGGs1W5jcX5iSNw4DeonzQARlejYJ9NOn/XkrcoC9Hvd8hc5lNx+1h991GxJUJ', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAFAAAAAAAAAAA=', 'AAAAAAAAAAEAAAABAAAAAQAAABwAAAAAAAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAAlQL4UQAAAAbAAAABwAAAAAAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAwAAAAACAAICAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAcAAAAAAAAAACQUsYKOw/kj+JXXI5eosCY2LS+fgH0zFHZXnenMJ4wUAAAAAJUC+IMAAAAGwAAAAUAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{Jxc3OpKsHsiC+E8yA26/vBlDhhrNVuY3F+YkjcOA3qJ80AEZXo2CfTTp/15K3KAvR73fIXOZTcftYffdRsSVCQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('142c988b1f67984f74a1581de9caecf499e60f1e0eed496661aa2c559238764c', 15, 1, 'GCHC4D2CS45CJRNN4QAHT2LFZAJIU5PA7H53K3VOP6WEJ6XWHNSNZKQG', 55834574850, 100, 1, '2016-06-29 16:34:09.095377', '2016-06-29 16:34:09.095377', 64424513536, 'AAAAAI4uD0KXOiTFreQAeellyBKKdeD5+7Vurn+sRPr2O2TcAAAAZAAAAA0AAAACAAAAAAAAAAAAAAABAAAAAAAAAAEAAAAAG5M9WO2kexu4dljTd0YSuyEnmDUsxKamzJWiv4FGkoQAAAABVVNEAAAAAACOLg9Clzokxa3kAHnpZcgSinXg+fu1bq5/rET69jtk3AAAAAAF9eEAAAAAAAAAAAH2O2TcAAAAQJBUx5tWfjAwXxab9U5HOjZvBRv3u95jXbyzuqeZ/kjsyMsU0jO/g03Rf1zgect1hj4hDYGN8mW4oEot0sSTZgw=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAwAAAA4AAAABAAAAABuTPVjtpHsbuHZY03dGErshJ5g1LMSmpsyVor+BRpKEAAAAAVVTRAAAAAAAji4PQpc6JMWt5AB56WXIEop14Pn7tW6uf6xE+vY7ZNwAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAAA8AAAABAAAAABuTPVjtpHsbuHZY03dGErshJ5g1LMSmpsyVor+BRpKEAAAAAVVTRAAAAAAAji4PQpc6JMWt5AB56WXIEop14Pn7tW6uf6xE+vY7ZNwAAAAABfXhAH//////////AAAAAQAAAAAAAAAA', 'AAAAAgAAAAMAAAAOAAAAAAAAAACOLg9Clzokxa3kAHnpZcgSinXg+fu1bq5/rET69jtk3AAAAAJOFgKcAAAADQAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAPAAAAAAAAAACOLg9Clzokxa3kAHnpZcgSinXg+fu1bq5/rET69jtk3AAAAAJOFgI4AAAADQAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{kFTHm1Z+MDBfFpv1Tkc6Nm8FG/e73mNdvLO6p5n+SOzIyxTSM7+DTdF/XOB5y3WGPiENgY3yZbigSi3SxJNmDA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('a5a9e3ca63e9cc155359c97337bcb14464cca56b230a4d0c7f27582644d16809', 16, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 8, 100, 1, '2016-06-29 16:34:09.099986', '2016-06-29 16:34:09.099986', 68719480832, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAAIAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAA423/rAYjzzhmLqxgNgLUY5X92ueHg5xGtOuok+g5NQoAAAACVAvkAAAAAAAAAAABVvwF9wAAAEBhFD/bYaTZZJ3VJ9xJqXoW5eeLK0AeFaATBH92cRfx0WUTFqp6rXx47fMBUxkWYq8bAHMfYCS5XXPRg86sAGUK', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAABAAAAAAAAAAAONt/6wGI884Zi6sYDYC1GOV/drnh4OcRrTrqJPoOTUKAAAAAlQL5AAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAABAAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2oRVS+BgAAAAAAAAACgAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAANAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtqNpXt1EAAAAAAAAAAcAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAQAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtqNpXtzgAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{YRQ/22Gk2WSd1SfcSal6FuXniytAHhWgEwR/dnEX8dFlExaqeq18eO3zAVMZFmKvGwBzH2AkuV1z0YPOrABlCg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('6a056189b45760c607e331c90c5a8b4cd720961df8bc8cecfd4aa388b577a6cb', 16, 2, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 9, 100, 1, '2016-06-29 16:34:09.102685', '2016-06-29 16:34:09.102685', 68719484928, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAAJAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAABAjoBMEUiZNLUjsWXL1iK59D90Li4w56076b8HKxZfIAAAACVAvkAAAAAAAAAAABVvwF9wAAAEAxC5cl7tkjQI0cfFZTiIFDuo0SwyYnNqTUH2hxDBtm7h/vUkBG3cgwGXS87ninVkhmvdIpTWfeIeGiw7kgefUA', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAABAAAAAAAAAAAAQI6ATBFImTS1I7Fly9YiufQ/dC4uMOetO+m/BysWXyAAAAAlQL5AAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAABAAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2nsFHFBgAAAAAAAAACgAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAQAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtqNpXtx8AAAAAAAAAAkAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{MQuXJe7ZI0CNHHxWU4iBQ7qNEsMmJzak1B9ocQwbZu4f71JARt3IMBl0vO54p1ZIZr3SKU1n3iHhosO5IHn1AA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('18bf6cce20cfbb0f9079c4b8783718949d13bd12d173a60363d2b8e3a07efead', 16, 3, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 10, 100, 1, '2016-06-29 16:34:09.105273', '2016-06-29 16:34:09.105273', 68719489024, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAAKAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAACVAvkAAAAAAAAAAABVvwF9wAAAEC/RVto6ytAqHpd6ZFWjwXQyXopKORz8QSvz0d8RoPrOEBgNEuAj8+kbyhS7QieOqwbiJrS0AU8YWaBQQ4zc+wL', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAABAAAAAAAAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAAlQL5AAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAABAAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2nG07MBgAAAAAAAAACgAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAQAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtqNpXtwYAAAAAAAAAAoAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{v0VbaOsrQKh6XemRVo8F0Ml6KSjkc/EEr89HfEaD6zhAYDRLgI/PpG8oUu0InjqsG4ia0tAFPGFmgUEOM3PsCw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('d1f593eb5e14f97027bc79821fa46628c107034fba9a5acef6a9da79e051ee73', 17, 1, 'GACAR2AEYEKITE2LKI5RMXF5MIVZ6Q7XILROGDT22O7JX4DSWFS7FDDP', 68719476737, 100, 1, '2016-06-29 16:34:09.11034', '2016-06-29 16:34:09.11034', 73014448128, 'AAAAAAQI6ATBFImTS1I7Fly9YiufQ/dC4uMOetO+m/BysWXyAAAAZAAAABAAAAABAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABRVVSAAAAAAAuwvNzNk9twbuJHUBqnX26GYI3MbCdpQU9t4n6EVRXsX//////////AAAAAAAAAAFysWXyAAAAQI7hbwZc1+KWfheVnYAq5TXFX9ancHJmJq0wV0c9ONIfG6U8trhIVeVoiED2eUFFmhx+bBtF9TPSvifF/mfDlQk=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAGAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAABEAAAABAAAAAAQI6ATBFImTS1I7Fly9YiufQ/dC4uMOetO+m/BysWXyAAAAAUVVUgAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAABEAAAAAAAAAAAQI6ATBFImTS1I7Fly9YiufQ/dC4uMOetO+m/BysWXyAAAAAlQL45wAAAAQAAAAAQAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAQAAAAAAAAAAAECOgEwRSJk0tSOxZcvWIrn0P3QuLjDnrTvpvwcrFl8gAAAAJUC+QAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAARAAAAAAAAAAAECOgEwRSJk0tSOxZcvWIrn0P3QuLjDnrTvpvwcrFl8gAAAAJUC+OcAAAAEAAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{juFvBlzX4pZ+F5WdgCrlNcVf1qdwcmYmrTBXRz040h8bpTy2uEhV5WiIQPZ5QUWaHH5sG0X1M9K+J8X+Z8OVCQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('cdef45dd961d59375351ea7dd7ef6414ff49371a335723e84dafacea1e13665a', 17, 2, 'GDRW375MAYR46ODGF2WGANQC2RRZL7O246DYHHCGWTV2RE7IHE2QUQLD', 68719476737, 100, 1, '2016-06-29 16:34:09.111845', '2016-06-29 16:34:09.111845', 73014452224, 'AAAAAONt/6wGI884Zi6sYDYC1GOV/drnh4OcRrTrqJPoOTUKAAAAZAAAABAAAAABAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABVVNEAAAAAAAuwvNzNk9twbuJHUBqnX26GYI3MbCdpQU9t4n6EVRXsX//////////AAAAAAAAAAHoOTUKAAAAQIjLqcYXE8EAsH6Dx2hwPjiEfHGZ4jsMNZZc7PynNiJi9kFXjfvvLDlWizGAr2B9MFDrfDRDvjnBxKKhJifEcQM=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAGAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAABEAAAABAAAAAONt/6wGI884Zi6sYDYC1GOV/drnh4OcRrTrqJPoOTUKAAAAAVVTRAAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAABEAAAAAAAAAAONt/6wGI884Zi6sYDYC1GOV/drnh4OcRrTrqJPoOTUKAAAAAlQL45wAAAAQAAAAAQAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAQAAAAAAAAAADjbf+sBiPPOGYurGA2AtRjlf3a54eDnEa066iT6Dk1CgAAAAJUC+QAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAARAAAAAAAAAADjbf+sBiPPOGYurGA2AtRjlf3a54eDnEa066iT6Dk1CgAAAAJUC+OcAAAAEAAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{iMupxhcTwQCwfoPHaHA+OIR8cZniOww1llzs/Kc2ImL2QVeN++8sOVaLMYCvYH0wUOt8NEO+OcHEoqEmJ8RxAw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('8ccc0c28c3e99a63cc59bad7dec3f5c56eb3942c548ecd40bc39c509d6b081d4', 28, 6, 'GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES', 115964116998, 100, 1, '2016-06-29 16:34:09.183415', '2016-06-29 16:34:09.183415', 120259108864, 'AAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAZAAAABsAAAAGAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAC2V4YW1wbGUuY29tAAAAAAAAAAAAAAAAATCeMFAAAABAkID6CkBHP9eovLQXkMQJ7QkE6NWlmdKGmLxaiI1YaVKZaKJxz5P85x+6wzpYxxbs6Bd2l4qxVjS7Q36DwRiqBA==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAFAAAAAAAAAAA=', 'AAAAAAAAAAEAAAABAAAAAQAAABwAAAAAAAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAAlQL4UQAAAAbAAAABwAAAAAAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAwAAAAtleGFtcGxlLmNvbQACAAICAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAcAAAAAAAAAACQUsYKOw/kj+JXXI5eosCY2LS+fgH0zFHZXnenMJ4wUAAAAAJUC+GoAAAAGwAAAAYAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{kID6CkBHP9eovLQXkMQJ7QkE6NWlmdKGmLxaiI1YaVKZaKJxz5P85x+6wzpYxxbs6Bd2l4qxVjS7Q36DwRiqBA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('902b90c2322b9e6b335e7543389a7446b86e3039ebf59ec66dffb50eaec0dc85', 18, 1, 'GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU', 68719476737, 100, 1, '2016-06-29 16:34:09.115921', '2016-06-29 16:34:09.115921', 77309415424, 'AAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAZAAAABAAAAABAAAAAAAAAAAAAAABAAAAAAAAAAEAAAAA423/rAYjzzhmLqxgNgLUY5X92ueHg5xGtOuok+g5NQoAAAABVVNEAAAAAAAuwvNzNk9twbuJHUBqnX26GYI3MbCdpQU9t4n6EVRXsQAAAAA7msoAAAAAAAAAAAERVFexAAAAQC9X2I3Zz1x3AQMqL4XCzePTlwnokv2BQnWGmT007oH59gai3eNu7/WVoHtW8hsgHjs1mZK709FzzRF2cbD2tQE=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAwAAABEAAAABAAAAAONt/6wGI884Zi6sYDYC1GOV/drnh4OcRrTrqJPoOTUKAAAAAVVTRAAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAABIAAAABAAAAAONt/6wGI884Zi6sYDYC1GOV/drnh4OcRrTrqJPoOTUKAAAAAVVTRAAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAAO5rKAH//////////AAAAAQAAAAAAAAAA', 'AAAAAgAAAAMAAAAQAAAAAAAAAAAuwvNzNk9twbuJHUBqnX26GYI3MbCdpQU9t4n6EVRXsQAAAAJUC+QAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAASAAAAAAAAAAAuwvNzNk9twbuJHUBqnX26GYI3MbCdpQU9t4n6EVRXsQAAAAJUC+OcAAAAEAAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{L1fYjdnPXHcBAyovhcLN49OXCeiS/YFCdYaZPTTugfn2BqLd427v9ZWge1byGyAeOzWZkrvT0XPNEXZxsPa1AQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('ca756d1519ceda79f8722042b12cea7ba004c3bd961adb62b59f88a867f86eb3', 18, 2, 'GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU', 68719476738, 100, 1, '2016-06-29 16:34:09.118661', '2016-06-29 16:34:09.118661', 77309419520, 'AAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAZAAAABAAAAACAAAAAAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAA7msoAAAAAAEAAAACAAAAAAAAAAAAAAAAAAAAARFUV7EAAABALuai5QxceFbtAiC5nkntNVnvSPeWR+C+FgplPAdRgRS+PPESpUiSCyuiwuhmvuDw7kwxn+A6E0M4ca1s2qzMAg==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAAAAAAAEAAAAAAAAAAVVTRAAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAA7msoAAAAAAEAAAACAAAAAAAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAABIAAAACAAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAAAAAAAEAAAAAAAAAAVVTRAAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAA7msoAAAAAAEAAAACAAAAAAAAAAAAAAAAAAAAAQAAABIAAAAAAAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAAlQL4tQAAAAQAAAAAwAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAASAAAAAAAAAAAuwvNzNk9twbuJHUBqnX26GYI3MbCdpQU9t4n6EVRXsQAAAAJUC+M4AAAAEAAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{Luai5QxceFbtAiC5nkntNVnvSPeWR+C+FgplPAdRgRS+PPESpUiSCyuiwuhmvuDw7kwxn+A6E0M4ca1s2qzMAg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('37bb79f6959c0e8e9b3d31f6c9308d8d084d9c6742cfa56ca094cfa6eae99423', 18, 3, 'GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU', 68719476739, 100, 1, '2016-06-29 16:34:09.119959', '2016-06-29 16:34:09.119959', 77309423616, 'AAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAZAAAABAAAAADAAAAAAAAAAAAAAABAAAAAAAAAAMAAAABRVVSAAAAAAAuwvNzNk9twbuJHUBqnX26GYI3MbCdpQU9t4n6EVRXsQAAAAAAAAAAstBeAAAAAAEAAAABAAAAAAAAAAAAAAAAAAAAARFUV7EAAABArzp9Fxxql+yoysglDjXm9+rsJeNX2GsSa7TOy3AzHOu4Y5Z8ICx52Q885gQGQWMtEP0w6yh83d6+o6kjC/WuAg==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAAAAAAAIAAAABRVVSAAAAAAAuwvNzNk9twbuJHUBqnX26GYI3MbCdpQU9t4n6EVRXsQAAAAAAAAAAstBeAAAAAAEAAAABAAAAAAAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAABIAAAACAAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAAAAAAAIAAAABRVVSAAAAAAAuwvNzNk9twbuJHUBqnX26GYI3MbCdpQU9t4n6EVRXsQAAAAAAAAAAstBeAAAAAAEAAAABAAAAAAAAAAAAAAAAAAAAAQAAABIAAAAAAAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAAlQL4tQAAAAQAAAAAwAAAAIAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAASAAAAAAAAAAAuwvNzNk9twbuJHUBqnX26GYI3MbCdpQU9t4n6EVRXsQAAAAJUC+LUAAAAEAAAAAMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{rzp9Fxxql+yoysglDjXm9+rsJeNX2GsSa7TOy3AzHOu4Y5Z8ICx52Q885gQGQWMtEP0w6yh83d6+o6kjC/WuAg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('198844c8b472daacc5b717695a4ca16ac799a13fb2cf4152d19e2117ae1c56c3', 19, 1, 'GDRW375MAYR46ODGF2WGANQC2RRZL7O246DYHHCGWTV2RE7IHE2QUQLD', 68719476738, 100, 1, '2016-06-29 16:34:09.124275', '2016-06-29 16:34:09.124275', 81604382720, 'AAAAAONt/6wGI884Zi6sYDYC1GOV/drnh4OcRrTrqJPoOTUKAAAAZAAAABAAAAACAAAAAAAAAAAAAAABAAAAAAAAAAIAAAABVVNEAAAAAAAuwvNzNk9twbuJHUBqnX26GYI3MbCdpQU9t4n6EVRXsQAAAAA7msoAAAAAAAQI6ATBFImTS1I7Fly9YiufQ/dC4uMOetO+m/BysWXyAAAAAUVVUgAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAAdzWUAAAAAAEAAAAAAAAAAAAAAAHoOTUKAAAAQMs9vNZ518oYUMp38TakovW//DDTbs/9oPj1RAix5ElC/d7gbWaaNNJxKQR7eMNO6rB+ntGqee4WurTJgA4k2ws=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAACAAAAAAAAAAIAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAAAAAAAQAAAAAAAAAAdzWUAAAAAAFVU0QAAAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAADuaygAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAAAAAAAgAAAAFFVVIAAAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAAHc1lAAAAAAAAAAAAHc1lAAAAAAABAjoBMEUiZNLUjsWXL1iK59D90Li4w56076b8HKxZfIAAAABRVVSAAAAAAAuwvNzNk9twbuJHUBqnX26GYI3MbCdpQU9t4n6EVRXsQAAAAB3NZQAAAAAAA==', 'AAAAAAAAAAEAAAAKAAAAAwAAABIAAAAAAAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAAlQL4tQAAAAQAAAAAwAAAAIAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAABMAAAAAAAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAAlQL4tQAAAAQAAAAAwAAAAIAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAwAAABEAAAABAAAAAAQI6ATBFImTS1I7Fly9YiufQ/dC4uMOetO+m/BysWXyAAAAAUVVUgAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAABMAAAABAAAAAAQI6ATBFImTS1I7Fly9YiufQ/dC4uMOetO+m/BysWXyAAAAAUVVUgAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAAdzWUAH//////////AAAAAQAAAAAAAAAAAAAAAwAAABIAAAABAAAAAONt/6wGI884Zi6sYDYC1GOV/drnh4OcRrTrqJPoOTUKAAAAAVVTRAAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAAO5rKAH//////////AAAAAQAAAAAAAAAAAAAAAQAAABMAAAABAAAAAONt/6wGI884Zi6sYDYC1GOV/drnh4OcRrTrqJPoOTUKAAAAAVVTRAAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAwAAABIAAAACAAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAAAAAAAEAAAAAAAAAAVVTRAAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAA7msoAAAAAAEAAAACAAAAAAAAAAAAAAAAAAAAAQAAABMAAAACAAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAAAAAAAEAAAAAAAAAAVVTRAAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAAdzWUAAAAAAEAAAACAAAAAAAAAAAAAAAAAAAAAwAAABIAAAACAAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAAAAAAAIAAAABRVVSAAAAAAAuwvNzNk9twbuJHUBqnX26GYI3MbCdpQU9t4n6EVRXsQAAAAAAAAAAstBeAAAAAAEAAAABAAAAAAAAAAAAAAAAAAAAAQAAABMAAAACAAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAAAAAAAIAAAABRVVSAAAAAAAuwvNzNk9twbuJHUBqnX26GYI3MbCdpQU9t4n6EVRXsQAAAAAAAAAAO5rKAAAAAAEAAAABAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAARAAAAAAAAAADjbf+sBiPPOGYurGA2AtRjlf3a54eDnEa066iT6Dk1CgAAAAJUC+OcAAAAEAAAAAEAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAATAAAAAAAAAADjbf+sBiPPOGYurGA2AtRjlf3a54eDnEa066iT6Dk1CgAAAAJUC+M4AAAAEAAAAAIAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{yz281nnXyhhQynfxNqSi9b/8MNNuz/2g+PVECLHkSUL93uBtZpo00nEpBHt4w07qsH6e0ap57ha6tMmADiTbCw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('f08dc1fec150f276562866ce4f5272f658cf0bd9fd8c1d96a22c196be2e1b25a', 20, 1, 'GDRW375MAYR46ODGF2WGANQC2RRZL7O246DYHHCGWTV2RE7IHE2QUQLD', 68719476739, 100, 1, '2016-06-29 16:34:09.131133', '2016-06-29 16:34:09.131133', 85899350016, 'AAAAAONt/6wGI884Zi6sYDYC1GOV/drnh4OcRrTrqJPoOTUKAAAAZAAAABAAAAADAAAAAAAAAAAAAAABAAAAAAAAAAIAAAAAAAAAADuaygAAAAAABAjoBMEUiZNLUjsWXL1iK59D90Li4w56076b8HKxZfIAAAABRVVSAAAAAAAuwvNzNk9twbuJHUBqnX26GYI3MbCdpQU9t4n6EVRXsQAAAAA7msoAAAAAAAAAAAAAAAAB6Dk1CgAAAEB+7jxesBKKrF343onyycjp2tiQLZiGH2ETl+9fuOqotveY2rIgvt9ng+QJ2aDP3+PnDsYEa9ZUaA+Zne2nIGgE', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAACAAAAAAAAAAEAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAAAAAAAgAAAAFFVVIAAAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAADuaygAAAAAAAAAAADuaygAAAAAABAjoBMEUiZNLUjsWXL1iK59D90Li4w56076b8HKxZfIAAAABRVVSAAAAAAAuwvNzNk9twbuJHUBqnX26GYI3MbCdpQU9t4n6EVRXsQAAAAA7msoAAAAAAA==', 'AAAAAAAAAAEAAAAHAAAAAwAAABMAAAAAAAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAAlQL4tQAAAAQAAAAAwAAAAIAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAABQAAAAAAAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAAo+mrNQAAAAQAAAAAwAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAABQAAAAAAAAAAONt/6wGI884Zi6sYDYC1GOV/drnh4OcRrTrqJPoOTUKAAAAAhhxGNQAAAAQAAAAAwAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAwAAABMAAAABAAAAAAQI6ATBFImTS1I7Fly9YiufQ/dC4uMOetO+m/BysWXyAAAAAUVVUgAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAAdzWUAH//////////AAAAAQAAAAAAAAAAAAAAAQAAABQAAAABAAAAAAQI6ATBFImTS1I7Fly9YiufQ/dC4uMOetO+m/BysWXyAAAAAUVVUgAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAAstBeAH//////////AAAAAQAAAAAAAAAAAAAAAwAAABMAAAACAAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAAAAAAAIAAAABRVVSAAAAAAAuwvNzNk9twbuJHUBqnX26GYI3MbCdpQU9t4n6EVRXsQAAAAAAAAAAO5rKAAAAAAEAAAABAAAAAAAAAAAAAAAAAAAAAgAAAAIAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAAAAAAAg==', 'AAAAAgAAAAMAAAATAAAAAAAAAADjbf+sBiPPOGYurGA2AtRjlf3a54eDnEa066iT6Dk1CgAAAAJUC+M4AAAAEAAAAAIAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAUAAAAAAAAAADjbf+sBiPPOGYurGA2AtRjlf3a54eDnEa066iT6Dk1CgAAAAJUC+LUAAAAEAAAAAMAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{fu48XrASiqxd+N6J8snI6drYkC2Yhh9hE5fvX7jqqLb3mNqyIL7fZ4PkCdmgz9/j5w7GBGvWVGgPmZ3tpyBoBA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('2a6987a6930eab7e3becacf9b76ed7a06802668c1f1eb0f82f5671014b4b636a', 21, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 11, 100, 1, '2016-06-29 16:34:09.137128', '2016-06-29 16:34:09.137128', 90194317312, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAALAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAXK+F1JOs84QNDhnmIjjKUDQ+mEvueZwDL/tCVRXFjncAAAACVAvkAAAAAAAAAAABVvwF9wAAAEDfpUesb4kQ/RfBx1UxqNOtZ2+4R4S0XxzggPR1C3YyhZAr/K8KyZCg4ejDTFnhu9qAh4GLZLkbBraGncT9DcYF', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAABUAAAAAAAAAAFyvhdSTrPOEDQ4Z5iI4ylA0PphL7nmcAy/7QlUVxY53AAAAAlQL5AAAAAAVAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAABUAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2mhkvS1AAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAQAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtpxtOzAYAAAAAAAAAAoAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAVAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtpxtOy+0AAAAAAAAAAsAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{36VHrG+JEP0XwcdVMajTrWdvuEeEtF8c4ID0dQt2MoWQK/yvCsmQoOHow0xZ4bvagIeBi2S5Gwa2hp3E/Q3GBQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('96415ac1d2f79621b26b1568f963fd8dd6c50c20a22c7428cefbfe9dee867588', 21, 2, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 12, 100, 1, '2016-06-29 16:34:09.139971', '2016-06-29 16:34:09.139971', 90194321408, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAAMAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAdQRiekAoVkbqXJa3xIIXnCcZLADk+cVfmZs9SLHWDWEAAAACVAvkAAAAAAAAAAABVvwF9wAAAEDdJGdvdZ2S4QoXdO+Odt8ZRdeVu7mBvq7FtP9okqr98pGD/jSAraklQvaRmCyMALIMD2kG8R2KjhKvy7oIL6IB', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAABUAAAAAAAAAAHUEYnpAKFZG6lyWt8SCF5wnGSwA5PnFX5mbPUix1g1hAAAAAlQL5AAAAAAVAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAABUAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2l8UjZ1AAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAVAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtpxtOy9QAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{3SRnb3WdkuEKF3TvjnbfGUXXlbu5gb6uxbT/aJKq/fKRg/40gK2pJUL2kZgsjACyDA9pBvEdio4Sr8u6CC+iAQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('be05e4bd966d58689e1b6fae013e5aa77bde56e6acd2db9b96870e5e746a4ab7', 22, 1, 'GBOK7BOUSOWPHBANBYM6MIRYZJIDIPUYJPXHTHADF75UEVIVYWHHONQC', 90194313217, 100, 1, '2016-06-29 16:34:09.145371', '2016-06-29 16:34:09.145371', 94489284608, 'AAAAAFyvhdSTrPOEDQ4Z5iI4ylA0PphL7nmcAy/7QlUVxY53AAAAZAAAABUAAAABAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABVVNEAAAAAAB1BGJ6QChWRupclrfEghecJxksAOT5xV+Zmz1IsdYNYX//////////AAAAAAAAAAEVxY53AAAAQDMCWfC0eGNJuYIX3s5AUNLernpcHTn8O6ygq/Nw3S5vny/W42O5G4G6UsihVU1xd5bR4im2+VzQlQYQhe0jhwg=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAGAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAABYAAAABAAAAAFyvhdSTrPOEDQ4Z5iI4ylA0PphL7nmcAy/7QlUVxY53AAAAAVVTRAAAAAAAdQRiekAoVkbqXJa3xIIXnCcZLADk+cVfmZs9SLHWDWEAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAABYAAAAAAAAAAFyvhdSTrPOEDQ4Z5iI4ylA0PphL7nmcAy/7QlUVxY53AAAAAlQL45wAAAAVAAAAAQAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAVAAAAAAAAAABcr4XUk6zzhA0OGeYiOMpQND6YS+55nAMv+0JVFcWOdwAAAAJUC+QAAAAAFQAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAWAAAAAAAAAABcr4XUk6zzhA0OGeYiOMpQND6YS+55nAMv+0JVFcWOdwAAAAJUC+OcAAAAFQAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{MwJZ8LR4Y0m5ghfezkBQ0t6uelwdOfw7rKCr83DdLm+fL9bjY7kbgbpSyKFVTXF3ltHiKbb5XNCVBhCF7SOHCA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('d8b2508123656b1df1ee17c2767829bc22ab41959ad25e6ccc520e849516fba1', 23, 1, 'GBOK7BOUSOWPHBANBYM6MIRYZJIDIPUYJPXHTHADF75UEVIVYWHHONQC', 90194313218, 100, 1, '2016-06-29 16:34:09.150749', '2016-06-29 16:34:09.150749', 98784251904, 'AAAAAFyvhdSTrPOEDQ4Z5iI4ylA0PphL7nmcAy/7QlUVxY53AAAAZAAAABUAAAACAAAAAAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAdQRiekAoVkbqXJa3xIIXnCcZLADk+cVfmZs9SLHWDWEAAAAAC+vCAAAAAAEAAAABAAAAAAAAAAAAAAAAAAAAARXFjncAAABATR48xYiKbu8AOoXFwvcvILZ0/pQkfGuwwAoIZNefr7ydIwlcuL44XPM7pJ/6jDSbqBudTNWdE2JRjuq7HI7IAA==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAFyvhdSTrPOEDQ4Z5iI4ylA0PphL7nmcAy/7QlUVxY53AAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAdQRiekAoVkbqXJa3xIIXnCcZLADk+cVfmZs9SLHWDWEAAAAAC+vCAAAAAAEAAAABAAAAAAAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAABcAAAACAAAAAFyvhdSTrPOEDQ4Z5iI4ylA0PphL7nmcAy/7QlUVxY53AAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAdQRiekAoVkbqXJa3xIIXnCcZLADk+cVfmZs9SLHWDWEAAAAAC+vCAAAAAAEAAAABAAAAAAAAAAAAAAAAAAAAAQAAABcAAAAAAAAAAFyvhdSTrPOEDQ4Z5iI4ylA0PphL7nmcAy/7QlUVxY53AAAAAlQL4zgAAAAVAAAAAgAAAAIAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAWAAAAAAAAAABcr4XUk6zzhA0OGeYiOMpQND6YS+55nAMv+0JVFcWOdwAAAAJUC+OcAAAAFQAAAAEAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAXAAAAAAAAAABcr4XUk6zzhA0OGeYiOMpQND6YS+55nAMv+0JVFcWOdwAAAAJUC+M4AAAAFQAAAAIAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{TR48xYiKbu8AOoXFwvcvILZ0/pQkfGuwwAoIZNefr7ydIwlcuL44XPM7pJ/6jDSbqBudTNWdE2JRjuq7HI7IAA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('01346de1ca30ce03149d9f54945956a22f9cbed3d81f81c62bb59cf8cdd8b893', 24, 1, 'GB2QIYT2IAUFMRXKLSLLPRECC6OCOGJMADSPTRK7TGNT2SFR2YGWDARD', 90194313217, 100, 1, '2016-06-29 16:34:09.154662', '2016-06-29 16:34:09.154662', 103079219200, 'AAAAAHUEYnpAKFZG6lyWt8SCF5wnGSwA5PnFX5mbPUix1g1hAAAAZAAAABUAAAABAAAAAAAAAAAAAAABAAAAAAAAAAMAAAABVVNEAAAAAAB1BGJ6QChWRupclrfEghecJxksAOT5xV+Zmz1IsdYNYQAAAAAAAAAAEeGjAAAAAAEAAAABAAAAAAAAAAAAAAAAAAAAAbHWDWEAAABA0L+69D1hxpytAkX6cvPiBuO80ql8SQKZ15POVxx9wYl6mZrL+6UWGab/+6ng2M+a29E7ON+Xs46Y9MNqTh91AQ==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAEAAAAAXK+F1JOs84QNDhnmIjjKUDQ+mEvueZwDL/tCVRXFjncAAAAAAAAAAwAAAAAAAAAAC+vCAAAAAAFVU0QAAAAAAHUEYnpAKFZG6lyWt8SCF5wnGSwA5PnFX5mbPUix1g1hAAAAAAvrwgAAAAAAAAAAAHUEYnpAKFZG6lyWt8SCF5wnGSwA5PnFX5mbPUix1g1hAAAAAAAAAAQAAAABVVNEAAAAAAB1BGJ6QChWRupclrfEghecJxksAOT5xV+Zmz1IsdYNYQAAAAAAAAAABfXhAAAAAAEAAAABAAAAAAAAAAAAAAAA', 'AAAAAAAAAAEAAAAIAAAAAAAAABgAAAACAAAAAHUEYnpAKFZG6lyWt8SCF5wnGSwA5PnFX5mbPUix1g1hAAAAAAAAAAQAAAABVVNEAAAAAAB1BGJ6QChWRupclrfEghecJxksAOT5xV+Zmz1IsdYNYQAAAAAAAAAABfXhAAAAAAEAAAABAAAAAAAAAAAAAAAAAAAAAwAAABcAAAAAAAAAAFyvhdSTrPOEDQ4Z5iI4ylA0PphL7nmcAy/7QlUVxY53AAAAAlQL4zgAAAAVAAAAAgAAAAIAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAABgAAAAAAAAAAFyvhdSTrPOEDQ4Z5iI4ylA0PphL7nmcAy/7QlUVxY53AAAAAkggITgAAAAVAAAAAgAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAABgAAAAAAAAAAHUEYnpAKFZG6lyWt8SCF5wnGSwA5PnFX5mbPUix1g1hAAAAAl/3pZwAAAAVAAAAAQAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAwAAABYAAAABAAAAAFyvhdSTrPOEDQ4Z5iI4ylA0PphL7nmcAy/7QlUVxY53AAAAAVVTRAAAAAAAdQRiekAoVkbqXJa3xIIXnCcZLADk+cVfmZs9SLHWDWEAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAABgAAAABAAAAAFyvhdSTrPOEDQ4Z5iI4ylA0PphL7nmcAy/7QlUVxY53AAAAAVVTRAAAAAAAdQRiekAoVkbqXJa3xIIXnCcZLADk+cVfmZs9SLHWDWEAAAAAC+vCAH//////////AAAAAQAAAAAAAAAAAAAAAwAAABcAAAACAAAAAFyvhdSTrPOEDQ4Z5iI4ylA0PphL7nmcAy/7QlUVxY53AAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAdQRiekAoVkbqXJa3xIIXnCcZLADk+cVfmZs9SLHWDWEAAAAAC+vCAAAAAAEAAAABAAAAAAAAAAAAAAAAAAAAAgAAAAIAAAAAXK+F1JOs84QNDhnmIjjKUDQ+mEvueZwDL/tCVRXFjncAAAAAAAAAAw==', 'AAAAAgAAAAMAAAAVAAAAAAAAAAB1BGJ6QChWRupclrfEghecJxksAOT5xV+Zmz1IsdYNYQAAAAJUC+QAAAAAFQAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAYAAAAAAAAAAB1BGJ6QChWRupclrfEghecJxksAOT5xV+Zmz1IsdYNYQAAAAJUC+OcAAAAFQAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{0L+69D1hxpytAkX6cvPiBuO80ql8SQKZ15POVxx9wYl6mZrL+6UWGab/+6ng2M+a29E7ON+Xs46Y9MNqTh91AQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('5065cd7c97cfb6fbf7da8493beed47ed2c7efb3b00b77a4c92692ed487fb86a4', 25, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 13, 100, 1, '2016-06-29 16:34:09.15939', '2016-06-29 16:34:09.15939', 107374186496, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAANAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAfGbtaaW8nEfkG5PP1Cf4+dZxNj3MryzpiAiOpDJuhhgAAAACVAvkAAAAAAAAAAABVvwF9wAAAEBthwT3JCg5IZkKRNK3pHBa/eG8zq8Af9gFPWlYvEdRo6jzA5D9fYOcDpKD3dEAuPLNNAHj9tNbZUJA3rwxN94B', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAABkAAAAAAAAAAHxm7WmlvJxH5BuTz9Qn+PnWcTY9zK8s6YgIjqQyboYYAAAAAlQL5AAAAAAZAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAABkAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2lXEXguwAAAAAAAAADQAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAVAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtpfFI2dQAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAZAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtpfFI2bsAAAAAAAAAA0AAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{bYcE9yQoOSGZCkTSt6RwWv3hvM6vAH/YBT1pWLxHUaOo8wOQ/X2DnA6Sg93RALjyzTQB4/bTW2VCQN68MTfeAQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('a76e0260f6b83c6ea93f545d17de721c079dc31e81ee5edc41f159ec5fb48443', 26, 1, 'GB6GN3LJUW6JYR7EDOJ47VBH7D45M4JWHXGK6LHJRAEI5JBSN2DBQY7Q', 107374182401, 100, 1, '2016-06-29 16:34:09.165163', '2016-06-29 16:34:09.165163', 111669153792, 'AAAAAHxm7WmlvJxH5BuTz9Qn+PnWcTY9zK8s6YgIjqQyboYYAAAAZAAAABkAAAABAAAAAAAAAAAAAAABAAAAAAAAAAQAAAABVVNEAAAAAAB8Zu1ppbycR+Qbk8/UJ/j51nE2PcyvLOmICI6kMm6GGAAAAAAAAAAAdzWUAAAAAAEAAAABAAAAAAAAAAEyboYYAAAAQBqzCYDuLYn/jXhfEVxEGigMCJGoOBCK92lUb3Um15PgwSJ63tNl+FpH8+y5c+mCs/rzcvdyo9uXdodd4LXWiQg=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAHxm7WmlvJxH5BuTz9Qn+PnWcTY9zK8s6YgIjqQyboYYAAAAAAAAAAUAAAABVVNEAAAAAAB8Zu1ppbycR+Qbk8/UJ/j51nE2PcyvLOmICI6kMm6GGAAAAAAAAAAAdzWUAAAAAAEAAAABAAAAAQAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAABoAAAACAAAAAHxm7WmlvJxH5BuTz9Qn+PnWcTY9zK8s6YgIjqQyboYYAAAAAAAAAAUAAAABVVNEAAAAAAB8Zu1ppbycR+Qbk8/UJ/j51nE2PcyvLOmICI6kMm6GGAAAAAAAAAAAdzWUAAAAAAEAAAABAAAAAQAAAAAAAAAAAAAAAQAAABoAAAAAAAAAAHxm7WmlvJxH5BuTz9Qn+PnWcTY9zK8s6YgIjqQyboYYAAAAAlQL4zgAAAAZAAAAAgAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAZAAAAAAAAAAB8Zu1ppbycR+Qbk8/UJ/j51nE2PcyvLOmICI6kMm6GGAAAAAJUC+QAAAAAGQAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAaAAAAAAAAAAB8Zu1ppbycR+Qbk8/UJ/j51nE2PcyvLOmICI6kMm6GGAAAAAJUC+OcAAAAGQAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{GrMJgO4tif+NeF8RXEQaKAwIkag4EIr3aVRvdSbXk+DBInre02X4Wkfz7Llz6YKz+vNy93Kj25d2h13gtdaJCA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('92a654c76966ac61acc9df0b75f91cbde3b551c9e9766730827af42d1e247cc3', 26, 2, 'GB6GN3LJUW6JYR7EDOJ47VBH7D45M4JWHXGK6LHJRAEI5JBSN2DBQY7Q', 107374182402, 100, 1, '2016-06-29 16:34:09.166591', '2016-06-29 16:34:09.166591', 111669157888, 'AAAAAHxm7WmlvJxH5BuTz9Qn+PnWcTY9zK8s6YgIjqQyboYYAAAAZAAAABkAAAACAAAAAAAAAAAAAAABAAAAAAAAAAQAAAAAAAAAAVVTRAAAAAAAfGbtaaW8nEfkG5PP1Cf4+dZxNj3MryzpiAiOpDJuhhgAAAAAdzWUAAAAAAEAAAABAAAAAAAAAAEyboYYAAAAQBbE9T7oBKoN0/S3AV7GoSRe+xT79SlWNCYEtL1RPExL8FLhw5EDsXLoAvIBbBvHIr9NKcPtWDyhcHlIuaZKIg8=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAHxm7WmlvJxH5BuTz9Qn+PnWcTY9zK8s6YgIjqQyboYYAAAAAAAAAAYAAAAAAAAAAVVTRAAAAAAAfGbtaaW8nEfkG5PP1Cf4+dZxNj3MryzpiAiOpDJuhhgAAAAAdzWUAAAAAAEAAAABAAAAAQAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAABoAAAACAAAAAHxm7WmlvJxH5BuTz9Qn+PnWcTY9zK8s6YgIjqQyboYYAAAAAAAAAAYAAAAAAAAAAVVTRAAAAAAAfGbtaaW8nEfkG5PP1Cf4+dZxNj3MryzpiAiOpDJuhhgAAAAAdzWUAAAAAAEAAAABAAAAAQAAAAAAAAAAAAAAAQAAABoAAAAAAAAAAHxm7WmlvJxH5BuTz9Qn+PnWcTY9zK8s6YgIjqQyboYYAAAAAlQL4zgAAAAZAAAAAgAAAAIAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAaAAAAAAAAAAB8Zu1ppbycR+Qbk8/UJ/j51nE2PcyvLOmICI6kMm6GGAAAAAJUC+M4AAAAGQAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{FsT1PugEqg3T9LcBXsahJF77FPv1KVY0JgS0vVE8TEvwUuHDkQOxcugC8gFsG8civ00pw+1YPKFweUi5pkoiDw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('700fa44bb40e6ad2c5888656cd2e7b8d86de3d3557b653ae6874466175d64927', 27, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 14, 100, 1, '2016-06-29 16:34:09.170223', '2016-06-29 16:34:09.170223', 115964121088, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAAOAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAkFLGCjsP5I/iV1yOXqLAmNi0vn4B9MxR2V53pzCeMFAAAAACVAvkAAAAAAAAAAABVvwF9wAAAEBq3GPDVeRPfwqtW45GZNiUdQ9j6E9Nsz/lMYWcWDWGCZADSsEiEoXar1HWFK6drptsGEl9P6I9f7C2GBKb4YQM', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAABsAAAAAAAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAAlQL5AAAAAAbAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAABsAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2kx0LnogAAAAAAAAADgAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAZAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtpVxF4LsAAAAAAAAAA0AAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAbAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtpVxF4KIAAAAAAAAAA4AAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{atxjw1XkT38KrVuORmTYlHUPY+hPTbM/5TGFnFg1hgmQA0rBIhKF2q9R1hSuna6bbBhJfT+iPX+wthgSm+GEDA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('fe3707fbd5c844395c598f31dc719c61218d4cea4e8dddadb6733f4866089100', 28, 1, 'GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES', 115964116993, 100, 1, '2016-06-29 16:34:09.175725', '2016-06-29 16:34:09.175725', 120259088384, 'AAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAZAAAABsAAAABAAAAAAAAAAAAAAABAAAAAAAAAAUAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAQAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABMJ4wUAAAAEA/GIgE9sYPGwbCiIdLdhoEu25CyB0ZAcmjQonQItu6SE0gaSBVT/le355A/dw1NPaoXY9P/u0ou9D7h5Vb1fcK', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAFAAAAAAAAAAA=', 'AAAAAAAAAAEAAAABAAAAAQAAABwAAAAAAAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAAlQL4UQAAAAbAAAABwAAAAAAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAbAAAAAAAAAACQUsYKOw/kj+JXXI5eosCY2LS+fgH0zFHZXnenMJ4wUAAAAAJUC+QAAAAAGwAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAcAAAAAAAAAACQUsYKOw/kj+JXXI5eosCY2LS+fgH0zFHZXnenMJ4wUAAAAAJUC+OcAAAAGwAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{PxiIBPbGDxsGwoiHS3YaBLtuQsgdGQHJo0KJ0CLbukhNIGkgVU/5Xt+eQP3cNTT2qF2PT/7tKLvQ+4eVW9X3Cg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('345ef7f85c6ea297e3f994feef279b63812628681bd173a1f615185a4368e482', 28, 2, 'GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES', 115964116994, 100, 1, '2016-06-29 16:34:09.177188', '2016-06-29 16:34:09.177188', 120259092480, 'AAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAZAAAABsAAAACAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABMJ4wUAAAAEDYxq3zpaFIC2JcuJUbrQ3MFXzqvu+5G7XUi4NnHlfbLutn76ylQcjuwLgbUG2lqcQfl75doPUZyurKtFP1rkMO', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAFAAAAAAAAAAA=', 'AAAAAAAAAAEAAAABAAAAAQAAABwAAAAAAAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAAlQL4UQAAAAbAAAABwAAAAAAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAQAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAcAAAAAAAAAACQUsYKOw/kj+JXXI5eosCY2LS+fgH0zFHZXnenMJ4wUAAAAAJUC+M4AAAAGwAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{2Mat86WhSAtiXLiVG60NzBV86r7vuRu11IuDZx5X2y7rZ++spUHI7sC4G1BtpanEH5e+XaD1GcrqyrRT9a5DDg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('2a14735d7b05109359444acdd87e7fe92c98e9295d2ba61b05e25d1f7ee10fd3', 28, 3, 'GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES', 115964116995, 100, 1, '2016-06-29 16:34:09.178825', '2016-06-29 16:34:09.178825', 120259096576, 'AAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAZAAAABsAAAADAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABMJ4wUAAAAEAKuQ1exMu8hdf8dOPeULX2DG7DZx5WWIUFHXJMWGG9KmVrQoZDt2S6a/1uYEVJnvvY/EoJM5RpVjh2ZCs30VYA', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAFAAAAAAAAAAA=', 'AAAAAAAAAAEAAAABAAAAAQAAABwAAAAAAAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAAlQL4UQAAAAbAAAABwAAAAAAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAwAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAcAAAAAAAAAACQUsYKOw/kj+JXXI5eosCY2LS+fgH0zFHZXnenMJ4wUAAAAAJUC+LUAAAAGwAAAAMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{CrkNXsTLvIXX/HTj3lC19gxuw2ceVliFBR1yTFhhvSpla0KGQ7dkumv9bmBFSZ772PxKCTOUaVY4dmQrN9FWAA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('4f9598206ab17cf27b5c3eb9e906d63ebee2626654112eabdd2bce7bf12cccf2', 28, 4, 'GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES', 115964116996, 100, 1, '2016-06-29 16:34:09.18038', '2016-06-29 16:34:09.18038', 120259100672, 'AAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAZAAAABsAAAAEAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAEAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAATCeMFAAAABAAd6MzHDjUdRtHozzDnD3jJA+uRDCar3PQtuH/43pnROzk1HkovJPQ1YyzcpOb/NeuU/LKNzseL0PJNasVX1lAQ==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAFAAAAAAAAAAA=', 'AAAAAAAAAAEAAAABAAAAAQAAABwAAAAAAAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAAlQL4UQAAAAbAAAABwAAAAAAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAwAAAAACAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAcAAAAAAAAAACQUsYKOw/kj+JXXI5eosCY2LS+fgH0zFHZXnenMJ4wUAAAAAJUC+JwAAAAGwAAAAQAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{Ad6MzHDjUdRtHozzDnD3jJA+uRDCar3PQtuH/43pnROzk1HkovJPQ1YyzcpOb/NeuU/LKNzseL0PJNasVX1lAQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('83201014880073f8eff6f21ae76e51c2c4faf533e550ecd3c2205b48a092960a', 28, 7, 'GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES', 115964116999, 100, 1, '2016-06-29 16:34:09.184958', '2016-06-29 16:34:09.184958', 120259112960, 'AAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAZAAAABsAAAAHAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAB8ndnLViBPKqPJAcSNhZzc2mH7fQ7RtzGyFA8mFkMTkAAAAAEAAAAAAAAAATCeMFAAAABAtYtlsqMReQo1UoU2GYjb3h52wEKvnouCSO6LQO1xm/ArhtQO/sX5q35St8BjaYWEiFnp+SQj2FZC89OswCldAw==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAFAAAAAAAAAAA=', 'AAAAAAAAAAEAAAABAAAAAQAAABwAAAAAAAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAAlQL4UQAAAAbAAAABwAAAAEAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAwAAAAtleGFtcGxlLmNvbQACAAICAAAAAQAAAAB8ndnLViBPKqPJAcSNhZzc2mH7fQ7RtzGyFA8mFkMTkAAAAAEAAAAAAAAAAA==', 'AAAAAQAAAAEAAAAcAAAAAAAAAACQUsYKOw/kj+JXXI5eosCY2LS+fgH0zFHZXnenMJ4wUAAAAAJUC+FEAAAAGwAAAAcAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{tYtlsqMReQo1UoU2GYjb3h52wEKvnouCSO6LQO1xm/ArhtQO/sX5q35St8BjaYWEiFnp+SQj2FZC89OswCldAw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('69f64ae0f809b08996c1f394ee795001a40eee69adb675ab63bfd1932d3aafb2', 29, 1, 'GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES', 115964117000, 100, 1, '2016-06-29 16:34:09.189104', '2016-06-29 16:34:09.189104', 124554055680, 'AAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAZAAAABsAAAAIAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAEAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAATCeMFAAAABAi69qDHclVS9A8GAaqyk6oIxiMC2KXXEneFijfxH5VyLGIQZNAxOOcCPpIalU6P1pYRX3K4OlKHZ4hIdxJzD6BQ==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAFAAAAAAAAAAA=', 'AAAAAAAAAAEAAAABAAAAAQAAAB0AAAAAAAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAAlQL4OAAAAAbAAAACAAAAAEAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAwAAAAtleGFtcGxlLmNvbQACAAICAAAAAQAAAAB8ndnLViBPKqPJAcSNhZzc2mH7fQ7RtzGyFA8mFkMTkAAAAAEAAAAAAAAAAA==', 'AAAAAgAAAAMAAAAcAAAAAAAAAACQUsYKOw/kj+JXXI5eosCY2LS+fgH0zFHZXnenMJ4wUAAAAAJUC+FEAAAAGwAAAAcAAAABAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAMAAAALZXhhbXBsZS5jb20AAgACAgAAAAEAAAAAfJ3Zy1YgTyqjyQHEjYWc3Nph+30O0bcxshQPJhZDE5AAAAABAAAAAAAAAAAAAAABAAAAHQAAAAAAAAAAkFLGCjsP5I/iV1yOXqLAmNi0vn4B9MxR2V53pzCeMFAAAAACVAvg4AAAABsAAAAIAAAAAQAAAAEAAAAAYvwdC9CRsrYcDdZWNGsqaNfTR8bywsjubQRHAlb8BfcAAAADAAAAC2V4YW1wbGUuY29tAAIAAgIAAAABAAAAAHyd2ctWIE8qo8kBxI2FnNzaYft9DtG3MbIUDyYWQxOQAAAAAQAAAAAAAAAA', '{i69qDHclVS9A8GAaqyk6oIxiMC2KXXEneFijfxH5VyLGIQZNAxOOcCPpIalU6P1pYRX3K4OlKHZ4hIdxJzD6BQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('c3cd47a311e025446f72c50426b5b5444e5261431fc5760e8e57467c87cd49fc', 30, 1, 'GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES', 115964117001, 100, 1, '2016-06-29 16:34:09.193122', '2016-06-29 16:34:09.193122', 128849022976, 'AAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAZAAAABsAAAAJAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAB8ndnLViBPKqPJAcSNhZzc2mH7fQ7RtzGyFA8mFkMTkAAAAAEAAAAAAAAAATCeMFAAAABA7ZMKq80ucQSt+55q+6VQrG3Hrv6zHtOLwkfAxxsZdYPIuk7xZsgbyhOCVXjheOQ9ygAW1vtybdXG41AxSFRtAg==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAFAAAAAAAAAAA=', 'AAAAAAAAAAEAAAABAAAAAQAAAB4AAAAAAAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAAlQL4HwAAAAbAAAACQAAAAEAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAwAAAAtleGFtcGxlLmNvbQACAAICAAAAAQAAAAB8ndnLViBPKqPJAcSNhZzc2mH7fQ7RtzGyFA8mFkMTkAAAAAEAAAAAAAAAAA==', 'AAAAAgAAAAMAAAAdAAAAAAAAAACQUsYKOw/kj+JXXI5eosCY2LS+fgH0zFHZXnenMJ4wUAAAAAJUC+DgAAAAGwAAAAgAAAABAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAMAAAALZXhhbXBsZS5jb20AAgACAgAAAAEAAAAAfJ3Zy1YgTyqjyQHEjYWc3Nph+30O0bcxshQPJhZDE5AAAAABAAAAAAAAAAAAAAABAAAAHgAAAAAAAAAAkFLGCjsP5I/iV1yOXqLAmNi0vn4B9MxR2V53pzCeMFAAAAACVAvgfAAAABsAAAAJAAAAAQAAAAEAAAAAYvwdC9CRsrYcDdZWNGsqaNfTR8bywsjubQRHAlb8BfcAAAADAAAAC2V4YW1wbGUuY29tAAIAAgIAAAABAAAAAHyd2ctWIE8qo8kBxI2FnNzaYft9DtG3MbIUDyYWQxOQAAAAAQAAAAAAAAAA', '{7ZMKq80ucQSt+55q+6VQrG3Hrv6zHtOLwkfAxxsZdYPIuk7xZsgbyhOCVXjheOQ9ygAW1vtybdXG41AxSFRtAg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('299dc6631d585a55ae3602f660ec5b5a0088d24a14b344c72eccc2a62d9a8938', 31, 1, 'GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES', 115964117002, 100, 1, '2016-06-29 16:34:09.197161', '2016-06-29 16:34:09.197161', 133143990272, 'AAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAZAAAABsAAAAKAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAB8ndnLViBPKqPJAcSNhZzc2mH7fQ7RtzGyFA8mFkMTkAAAAAUAAAAAAAAAATCeMFAAAABA0wriernSr+5P2QCeon1uj5mrOLNTOrPYPPi5ricLug/nreEUhsgS/k3lA9JGpVbd+tacMEKmXKmFxHCEMjWPBg==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAFAAAAAAAAAAA=', 'AAAAAAAAAAEAAAABAAAAAQAAAB8AAAAAAAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAAlQL4BgAAAAbAAAACgAAAAEAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAwAAAAtleGFtcGxlLmNvbQACAAICAAAAAQAAAAB8ndnLViBPKqPJAcSNhZzc2mH7fQ7RtzGyFA8mFkMTkAAAAAUAAAAAAAAAAA==', 'AAAAAgAAAAMAAAAeAAAAAAAAAACQUsYKOw/kj+JXXI5eosCY2LS+fgH0zFHZXnenMJ4wUAAAAAJUC+B8AAAAGwAAAAkAAAABAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAMAAAALZXhhbXBsZS5jb20AAgACAgAAAAEAAAAAfJ3Zy1YgTyqjyQHEjYWc3Nph+30O0bcxshQPJhZDE5AAAAABAAAAAAAAAAAAAAABAAAAHwAAAAAAAAAAkFLGCjsP5I/iV1yOXqLAmNi0vn4B9MxR2V53pzCeMFAAAAACVAvgGAAAABsAAAAKAAAAAQAAAAEAAAAAYvwdC9CRsrYcDdZWNGsqaNfTR8bywsjubQRHAlb8BfcAAAADAAAAC2V4YW1wbGUuY29tAAIAAgIAAAABAAAAAHyd2ctWIE8qo8kBxI2FnNzaYft9DtG3MbIUDyYWQxOQAAAAAQAAAAAAAAAA', '{0wriernSr+5P2QCeon1uj5mrOLNTOrPYPPi5ricLug/nreEUhsgS/k3lA9JGpVbd+tacMEKmXKmFxHCEMjWPBg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('bb9d6654111fae501594400dc901c70d47489a67163d2a34f9b3e32a921a50dc', 32, 1, 'GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES', 115964117003, 100, 1, '2016-06-29 16:34:09.201298', '2016-06-29 16:34:09.201298', 137438957568, 'AAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAZAAAABsAAAALAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAMAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABMJ4wUAAAAEAFytUxjxN4bnJMrEJkSprnES9iGpOxAsNOFYrTP/xtGVk/PZ2oThUW+/hLRIk+hYYEgF21Gf58N/abJKFpqlsI', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAFAAAAAAAAAAA=', 'AAAAAAAAAAEAAAABAAAAAQAAACAAAAAAAAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAAlQL31AAAAAbAAAADAAAAAEAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAAAAAAtleGFtcGxlLmNvbQACAAICAAAAAQAAAAB8ndnLViBPKqPJAcSNhZzc2mH7fQ7RtzGyFA8mFkMTkAAAAAUAAAAAAAAAAA==', 'AAAAAgAAAAMAAAAfAAAAAAAAAACQUsYKOw/kj+JXXI5eosCY2LS+fgH0zFHZXnenMJ4wUAAAAAJUC+AYAAAAGwAAAAoAAAABAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAMAAAALZXhhbXBsZS5jb20AAgACAgAAAAEAAAAAfJ3Zy1YgTyqjyQHEjYWc3Nph+30O0bcxshQPJhZDE5AAAAAFAAAAAAAAAAAAAAABAAAAIAAAAAAAAAAAkFLGCjsP5I/iV1yOXqLAmNi0vn4B9MxR2V53pzCeMFAAAAACVAvftAAAABsAAAALAAAAAQAAAAEAAAAAYvwdC9CRsrYcDdZWNGsqaNfTR8bywsjubQRHAlb8BfcAAAADAAAAC2V4YW1wbGUuY29tAAIAAgIAAAABAAAAAHyd2ctWIE8qo8kBxI2FnNzaYft9DtG3MbIUDyYWQxOQAAAABQAAAAAAAAAA', '{BcrVMY8TeG5yTKxCZEqa5xEvYhqTsQLDThWK0z/8bRlZPz2dqE4VFvv4S0SJPoWGBIBdtRn+fDf2myShaapbCA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('6b38cdd5c17df2013d5a5e211c4b32218b6be91025316b1aab28bc12316615d5', 32, 2, 'GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES', 115964117004, 100, 1, '2016-06-29 16:34:09.203086', '2016-06-29 16:34:09.203086', 137438961664, 'AAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAZAAAABsAAAAMAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAB8ndnLViBPKqPJAcSNhZzc2mH7fQ7RtzGyFA8mFkMTkAAAAAAAAAAAAAAAATCeMFAAAABAOb0qGWnk1WrSUXS6iQFocaIOY/BDmgG1zTmlPyg0boSid3jTBK3z9U8+IPGAOELNLgkQHtgGYFgFGMio1xY+BQ==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAFAAAAAAAAAAA=', 'AAAAAAAAAAEAAAABAAAAAQAAACAAAAAAAAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAAlQL31AAAAAbAAAADAAAAAAAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAAAAAAtleGFtcGxlLmNvbQACAAICAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAgAAAAAAAAAACQUsYKOw/kj+JXXI5eosCY2LS+fgH0zFHZXnenMJ4wUAAAAAJUC99QAAAAGwAAAAwAAAABAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAMAAAALZXhhbXBsZS5jb20AAgACAgAAAAEAAAAAfJ3Zy1YgTyqjyQHEjYWc3Nph+30O0bcxshQPJhZDE5AAAAAFAAAAAAAAAAA=', '{Ob0qGWnk1WrSUXS6iQFocaIOY/BDmgG1zTmlPyg0boSid3jTBK3z9U8+IPGAOELNLgkQHtgGYFgFGMio1xY+BQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('6d78f17fafa2317d6af679e1e5420f351207ff61cdff21c600ea8f85155b3ea1', 33, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 15, 100, 1, '2016-06-29 16:34:09.207043', '2016-06-29 16:34:09.207043', 141733924864, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAAPAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAkqTd6glQdzt87217G6IYc3g3BYxMgWGPpDfRPhy1ZbUAAAACVAvkAAAAAAAAAAABVvwF9wAAAEC+mgKIzZqflQIKIqWn9LrciuyEx7XPfXGUhvyQ3sIQBnGdOWhkOt57UU/75LtUy4recT+jrY2cHKZj33puue8F', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAACEAAAAAAAAAAJKk3eoJUHc7fO9texuiGHN4NwWMTIFhj6Q30T4ctWW1AAAAAlQL5AAAAAAhAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAACEAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2kMj/uiQAAAAAAAAADwAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAbAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtpMdC56IAAAAAAAAAA4AAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAhAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtpMdC54kAAAAAAAAAA8AAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{vpoCiM2an5UCCiKlp/S63IrshMe1z31xlIb8kN7CEAZxnTloZDree1FP++S7VMuK3nE/o62NnBymY996brnvBQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('a05daae230b1f743474e83ab6d4817df1f3f77661a7d815f7620cee2a9809480', 34, 1, 'GCJKJXPKBFIHOO3455WXWG5CDBZXQNYFRRGICYMPUQ35CPQ4WVS3KZLG', 141733920769, 100, 1, '2016-06-29 16:34:09.212396', '2016-06-29 16:34:09.212396', 146028892160, 'AAAAAJKk3eoJUHc7fO9texuiGHN4NwWMTIFhj6Q30T4ctWW1AAAAZAAAACEAAAABAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABVVNEAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF93//////////AAAAAAAAAAEctWW1AAAAQBYUnV3I1O35EAyay0msjg3MzZfanCtvalKGG+94pe6RxgE/kCk2kTT9HXgXjbraq//Q/0vJ0AoCAXSeT18Ujgk=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAGAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAACIAAAABAAAAAJKk3eoJUHc7fO9texuiGHN4NwWMTIFhj6Q30T4ctWW1AAAAAVVTRAAAAAAAYvwdC9CRsrYcDdZWNGsqaNfTR8bywsjubQRHAlb8BfcAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAACIAAAAAAAAAAJKk3eoJUHc7fO9texuiGHN4NwWMTIFhj6Q30T4ctWW1AAAAAlQL45wAAAAhAAAAAQAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAhAAAAAAAAAACSpN3qCVB3O3zvbXsbohhzeDcFjEyBYY+kN9E+HLVltQAAAAJUC+QAAAAAIQAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAiAAAAAAAAAACSpN3qCVB3O3zvbXsbohhzeDcFjEyBYY+kN9E+HLVltQAAAAJUC+OcAAAAIQAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{FhSdXcjU7fkQDJrLSayODczNl9qcK29qUoYb73il7pHGAT+QKTaRNP0deBeNutqr/9D/S8nQCgIBdJ5PXxSOCQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('4e2442fe2e8dd8c686570c9f537acb2f50153a9883f8d199b6f4701eb289b3a0', 35, 1, 'GCJKJXPKBFIHOO3455WXWG5CDBZXQNYFRRGICYMPUQ35CPQ4WVS3KZLG', 141733920770, 100, 1, '2016-06-29 16:34:09.216315', '2016-06-29 16:34:09.216315', 150323859456, 'AAAAAJKk3eoJUHc7fO9texuiGHN4NwWMTIFhj6Q30T4ctWW1AAAAZAAAACEAAAACAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABVVNEAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAA7msoAAAAAAAAAAAEctWW1AAAAQNugq+B30pdbzvVVGz9RO3+DMeRdWqc/Xsd2NYdg6NBu7esvOdTWQ3nvoBEJyeGz8EE9zRQiSiqorwHlm+AGfwI=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAGAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAwAAACIAAAABAAAAAJKk3eoJUHc7fO9texuiGHN4NwWMTIFhj6Q30T4ctWW1AAAAAVVTRAAAAAAAYvwdC9CRsrYcDdZWNGsqaNfTR8bywsjubQRHAlb8BfcAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAACMAAAABAAAAAJKk3eoJUHc7fO9texuiGHN4NwWMTIFhj6Q30T4ctWW1AAAAAVVTRAAAAAAAYvwdC9CRsrYcDdZWNGsqaNfTR8bywsjubQRHAlb8BfcAAAAAAAAAAAAAAAA7msoAAAAAAQAAAAAAAAAA', 'AAAAAgAAAAMAAAAiAAAAAAAAAACSpN3qCVB3O3zvbXsbohhzeDcFjEyBYY+kN9E+HLVltQAAAAJUC+OcAAAAIQAAAAEAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAjAAAAAAAAAACSpN3qCVB3O3zvbXsbohhzeDcFjEyBYY+kN9E+HLVltQAAAAJUC+M4AAAAIQAAAAIAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{26Cr4HfSl1vO9VUbP1E7f4Mx5F1apz9ex3Y1h2Do0G7t6y851NZDee+gEQnJ4bPwQT3NFCJKKqivAeWb4AZ/Ag==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('44cb6c8ed4dbec542af1aad23001dd9d678cf19c8c461a653e762a7253eded82', 36, 1, 'GCJKJXPKBFIHOO3455WXWG5CDBZXQNYFRRGICYMPUQ35CPQ4WVS3KZLG', 141733920771, 100, 1, '2016-06-29 16:34:09.22036', '2016-06-29 16:34:09.22036', 154618826752, 'AAAAAJKk3eoJUHc7fO9texuiGHN4NwWMTIFhj6Q30T4ctWW1AAAAZAAAACEAAAADAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABVVNEAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAA7msoAAAAAAAAAAAEctWW1AAAAQO+eTIPXUZk+GAq7O6H8d1/WT5buo0apjLhGgtBeSyl37UV7LCpZfCn6DYVc7lQOVNWhBc7KDA7Ne83AR41kYAk=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAGAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAwAAACMAAAABAAAAAJKk3eoJUHc7fO9texuiGHN4NwWMTIFhj6Q30T4ctWW1AAAAAVVTRAAAAAAAYvwdC9CRsrYcDdZWNGsqaNfTR8bywsjubQRHAlb8BfcAAAAAAAAAAAAAAAA7msoAAAAAAQAAAAAAAAAAAAAAAQAAACQAAAABAAAAAJKk3eoJUHc7fO9texuiGHN4NwWMTIFhj6Q30T4ctWW1AAAAAVVTRAAAAAAAYvwdC9CRsrYcDdZWNGsqaNfTR8bywsjubQRHAlb8BfcAAAAAAAAAAAAAAAA7msoAAAAAAQAAAAAAAAAA', 'AAAAAgAAAAMAAAAjAAAAAAAAAACSpN3qCVB3O3zvbXsbohhzeDcFjEyBYY+kN9E+HLVltQAAAAJUC+M4AAAAIQAAAAIAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAkAAAAAAAAAACSpN3qCVB3O3zvbXsbohhzeDcFjEyBYY+kN9E+HLVltQAAAAJUC+LUAAAAIQAAAAMAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{755Mg9dRmT4YCrs7ofx3X9ZPlu6jRqmMuEaC0F5LKXftRXssKll8KfoNhVzuVA5U1aEFzsoMDs17zcBHjWRgCQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('52388a98e4e36c17749a94374270cc65bdb7271cb51277f095aaa8f1ca9d322c', 37, 1, 'GCJKJXPKBFIHOO3455WXWG5CDBZXQNYFRRGICYMPUQ35CPQ4WVS3KZLG', 141733920772, 100, 1, '2016-06-29 16:34:09.225374', '2016-06-29 16:34:09.225374', 158913794048, 'AAAAAJKk3eoJUHc7fO9texuiGHN4NwWMTIFhj6Q30T4ctWW1AAAAZAAAACEAAAAEAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABVVNEAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAAAAAAAAAAAAAAAAAEctWW1AAAAQM5SCoW10EJoKBBwwMu0Vw+f+bQ0GjQ9FO6w3l9Q/FIctm87248t9jXTbl0Rd4NgGcom0yoGxgcJiERwZGBMXQc=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAGAAAAAAAAAAA=', 'AAAAAAAAAAEAAAADAAAAAQAAACUAAAAAAAAAAJKk3eoJUHc7fO9texuiGHN4NwWMTIFhj6Q30T4ctWW1AAAAAlQL4nAAAAAhAAAABAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAwAAACQAAAABAAAAAJKk3eoJUHc7fO9texuiGHN4NwWMTIFhj6Q30T4ctWW1AAAAAVVTRAAAAAAAYvwdC9CRsrYcDdZWNGsqaNfTR8bywsjubQRHAlb8BfcAAAAAAAAAAAAAAAA7msoAAAAAAQAAAAAAAAAAAAAAAgAAAAEAAAAAkqTd6glQdzt87217G6IYc3g3BYxMgWGPpDfRPhy1ZbUAAAABVVNEAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w==', 'AAAAAgAAAAMAAAAkAAAAAAAAAACSpN3qCVB3O3zvbXsbohhzeDcFjEyBYY+kN9E+HLVltQAAAAJUC+LUAAAAIQAAAAMAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAlAAAAAAAAAACSpN3qCVB3O3zvbXsbohhzeDcFjEyBYY+kN9E+HLVltQAAAAJUC+JwAAAAIQAAAAQAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{zlIKhbXQQmgoEHDAy7RXD5/5tDQaND0U7rDeX1D8Uhy2bzvbjy32NdNuXRF3g2AZyibTKgbGBwmIRHBkYExdBw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('afeb8080522eba71ca328225bbcf731029edcfa254c827c45be580bae95c7231', 38, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 16, 100, 1, '2016-06-29 16:34:09.230109', '2016-06-29 16:34:09.230109', 163208761344, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAAQAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAq26sUclf95G3mAzqohcAxtpe+UiaovKwDpCv20t6bF8AAAACVAvkAAAAAAAAAAABVvwF9wAAAEDnzvNgEYB1u3BGTHFDlIWnk0GOq7BMpfcyewJRsJK9lT4HTMEwMQ2jSJyrWmB7xdBxHKaNMXQaAIx6CShLXpQH', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAACYAAAAAAAAAAKturFHJX/eRt5gM6qIXAMbaXvlImqLysA6Qr9tLemxfAAAAAlQL5AAAAAAmAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAACYAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2jnTz1VwAAAAAAAAAEQAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAhAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtpDI/7okAAAAAAAAAA8AAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAmAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtpDI/7nAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{587zYBGAdbtwRkxxQ5SFp5NBjquwTKX3MnsCUbCSvZU+B0zBMDENo0icq1pge8XQcRymjTF0GgCMegkoS16UBw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('2354df802111418a999e31c2964d16b8efe8e492b7d74de54939825190e1041f', 38, 2, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 17, 100, 1, '2016-06-29 16:34:09.232883', '2016-06-29 16:34:09.232883', 163208765440, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAARAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAA+SY4m6vkX+Y7FMkNv7RswsIkYNGXeZ4/YwEQNUpI8/gAAAACVAvkAAAAAAAAAAABVvwF9wAAAEDD6WvAYL1wilsd7zYDJt0iFO/lppQ6GJJn/A8UJl9jTjMNOjuQPBtA7fSxR5KT0BZLbtQy8qFlys0I6fTe/cwO', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAACYAAAAAAAAAAPkmOJur5F/mOxTJDb+0bMLCJGDRl3meP2MBEDVKSPP4AAAAAlQL5AAAAAAmAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAACYAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2jCDn8VwAAAAAAAAAEQAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAmAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtpDI/7lcAAAAAAAAABEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{w+lrwGC9cIpbHe82AybdIhTv5aaUOhiSZ/wPFCZfY04zDTo7kDwbQO30sUeSk9AWS27UMvKhZcrNCOn03v3MDg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('11705f94cd65d7b673a124a85ce368c80f8458ffaedff719304d8f849535b4e0', 39, 1, 'GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF', 163208757249, 100, 1, '2016-06-29 16:34:09.238201', '2016-06-29 16:34:09.238201', 167503728640, 'AAAAAPkmOJur5F/mOxTJDb+0bMLCJGDRl3meP2MBEDVKSPP4AAAAZAAAACYAAAABAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABSkjz+AAAAECyjDa1e+jtXukTrHluO7x0Mx7Wj4mRoM4S5UAFmRV+2rVoxjMwqFJhtYnEAUV19+C5ycp5jOLLpWxrCeRKJQUG', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAFAAAAAAAAAAA=', 'AAAAAAAAAAEAAAABAAAAAQAAACcAAAAAAAAAAPkmOJur5F/mOxTJDb+0bMLCJGDRl3meP2MBEDVKSPP4AAAAAlQL45wAAAAmAAAAAQAAAAAAAAAAAAAAAwAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAmAAAAAAAAAAD5Jjibq+Rf5jsUyQ2/tGzCwiRg0Zd5nj9jARA1Skjz+AAAAAJUC+QAAAAAJgAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAnAAAAAAAAAAD5Jjibq+Rf5jsUyQ2/tGzCwiRg0Zd5nj9jARA1Skjz+AAAAAJUC+OcAAAAJgAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{sow2tXvo7V7pE6x5bju8dDMe1o+JkaDOEuVABZkVftq1aMYzMKhSYbWJxAFFdffgucnKeYziy6VsawnkSiUFBg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('6fa467b53f5386d77ad35c2502ed2cd3dd8b460a5be22b6b2818b81bcd3ed2da', 40, 1, 'GCVW5LCRZFP7PENXTAGOVIQXADDNUXXZJCNKF4VQB2IK7W2LPJWF73UG', 163208757249, 100, 1, '2016-06-29 16:34:09.242483', '2016-06-29 16:34:09.242483', 171798695936, 'AAAAAKturFHJX/eRt5gM6qIXAMbaXvlImqLysA6Qr9tLemxfAAAAZAAAACYAAAABAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABVVNEAAAAAAD5Jjibq+Rf5jsUyQ2/tGzCwiRg0Zd5nj9jARA1Skjz+H//////////AAAAAAAAAAFLemxfAAAAQKN8LftAafeoAGmvpsEokqm47jAuqw4g1UWjmL0j6QPm1jxoalzDwDS3W+N2HOHdjSJlEQaTxGBfQKHhr6nNsAA=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAGAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAACgAAAABAAAAAKturFHJX/eRt5gM6qIXAMbaXvlImqLysA6Qr9tLemxfAAAAAVVTRAAAAAAA+SY4m6vkX+Y7FMkNv7RswsIkYNGXeZ4/YwEQNUpI8/gAAAAAAAAAAH//////////AAAAAAAAAAAAAAAAAAAAAQAAACgAAAAAAAAAAKturFHJX/eRt5gM6qIXAMbaXvlImqLysA6Qr9tLemxfAAAAAlQL4zgAAAAmAAAAAgAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAmAAAAAAAAAACrbqxRyV/3kbeYDOqiFwDG2l75SJqi8rAOkK/bS3psXwAAAAJUC+QAAAAAJgAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAoAAAAAAAAAACrbqxRyV/3kbeYDOqiFwDG2l75SJqi8rAOkK/bS3psXwAAAAJUC+OcAAAAJgAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{o3wt+0Bp96gAaa+mwSiSqbjuMC6rDiDVRaOYvSPpA+bWPGhqXMPANLdb43Yc4d2NImURBpPEYF9AoeGvqc2wAA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('0bcb67aa365446fd244fecff3a0c397f81f3a9b13428688965e776d447c0b1ea', 40, 2, 'GCVW5LCRZFP7PENXTAGOVIQXADDNUXXZJCNKF4VQB2IK7W2LPJWF73UG', 163208757250, 100, 1, '2016-06-29 16:34:09.243981', '2016-06-29 16:34:09.243981', 171798700032, 'AAAAAKturFHJX/eRt5gM6qIXAMbaXvlImqLysA6Qr9tLemxfAAAAZAAAACYAAAACAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABRVVSAAAAAAD5Jjibq+Rf5jsUyQ2/tGzCwiRg0Zd5nj9jARA1Skjz+H//////////AAAAAAAAAAFLemxfAAAAQMPVgYf+w09depDSxMcJnjVZHA2FlkBmhPmi0N66FuhAzTekWcCOMdCI0cUc+xJhywLXSMiKA6wP6K94NRlFlQE=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAGAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAACgAAAABAAAAAKturFHJX/eRt5gM6qIXAMbaXvlImqLysA6Qr9tLemxfAAAAAUVVUgAAAAAA+SY4m6vkX+Y7FMkNv7RswsIkYNGXeZ4/YwEQNUpI8/gAAAAAAAAAAH//////////AAAAAAAAAAAAAAAAAAAAAQAAACgAAAAAAAAAAKturFHJX/eRt5gM6qIXAMbaXvlImqLysA6Qr9tLemxfAAAAAlQL4zgAAAAmAAAAAgAAAAIAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAoAAAAAAAAAACrbqxRyV/3kbeYDOqiFwDG2l75SJqi8rAOkK/bS3psXwAAAAJUC+M4AAAAJgAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{w9WBh/7DT116kNLExwmeNVkcDYWWQGaE+aLQ3roW6EDNN6RZwI4x0IjRxRz7EmHLAtdIyIoDrA/or3g1GUWVAQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('6d2e30fd57492bf2e2b132e1bc91a548a369189bebf77eb2b3d829121a9d2c50', 41, 1, 'GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF', 163208757250, 100, 1, '2016-06-29 16:34:09.247908', '2016-06-29 16:34:09.247908', 176093663232, 'AAAAAPkmOJur5F/mOxTJDb+0bMLCJGDRl3meP2MBEDVKSPP4AAAAZAAAACYAAAACAAAAAAAAAAAAAAABAAAAAAAAAAcAAAAAq26sUclf95G3mAzqohcAxtpe+UiaovKwDpCv20t6bF8AAAABVVNEAAAAAAEAAAAAAAAAAUpI8/gAAABA6O2fe1gQBwoO0fMNNEUKH0QdVXVjEWbN5VL51DmRUedYMMXtbX5JKVSzla2kIGvWgls1dXuXHZY/IOlaK01rBQ==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAHAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAwAAACgAAAABAAAAAKturFHJX/eRt5gM6qIXAMbaXvlImqLysA6Qr9tLemxfAAAAAVVTRAAAAAAA+SY4m6vkX+Y7FMkNv7RswsIkYNGXeZ4/YwEQNUpI8/gAAAAAAAAAAH//////////AAAAAAAAAAAAAAAAAAAAAQAAACkAAAABAAAAAKturFHJX/eRt5gM6qIXAMbaXvlImqLysA6Qr9tLemxfAAAAAVVTRAAAAAAA+SY4m6vkX+Y7FMkNv7RswsIkYNGXeZ4/YwEQNUpI8/gAAAAAAAAAAH//////////AAAAAQAAAAAAAAAA', 'AAAAAgAAAAMAAAAnAAAAAAAAAAD5Jjibq+Rf5jsUyQ2/tGzCwiRg0Zd5nj9jARA1Skjz+AAAAAJUC+OcAAAAJgAAAAEAAAAAAAAAAAAAAAMAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAApAAAAAAAAAAD5Jjibq+Rf5jsUyQ2/tGzCwiRg0Zd5nj9jARA1Skjz+AAAAAJUC+M4AAAAJgAAAAIAAAAAAAAAAAAAAAMAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{6O2fe1gQBwoO0fMNNEUKH0QdVXVjEWbN5VL51DmRUedYMMXtbX5JKVSzla2kIGvWgls1dXuXHZY/IOlaK01rBQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('a832ff67085cb9eb6f1c4b740f6e033ba9b508af725fbf203469729a64a199ff', 41, 2, 'GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF', 163208757251, 100, 1, '2016-06-29 16:34:09.249801', '2016-06-29 16:34:09.249801', 176093667328, 'AAAAAPkmOJur5F/mOxTJDb+0bMLCJGDRl3meP2MBEDVKSPP4AAAAZAAAACYAAAADAAAAAAAAAAAAAAABAAAAAAAAAAcAAAAAq26sUclf95G3mAzqohcAxtpe+UiaovKwDpCv20t6bF8AAAABRVVSAAAAAAEAAAAAAAAAAUpI8/gAAABA1Qe8ngwANz4fLqYChwRjR5xng6cIqU5WBtjkZgF4ugVhi8J6kTpACvnvXso3IVym6Rfd6JdQW8QcLkFTX1MGCg==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAHAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAwAAACgAAAABAAAAAKturFHJX/eRt5gM6qIXAMbaXvlImqLysA6Qr9tLemxfAAAAAUVVUgAAAAAA+SY4m6vkX+Y7FMkNv7RswsIkYNGXeZ4/YwEQNUpI8/gAAAAAAAAAAH//////////AAAAAAAAAAAAAAAAAAAAAQAAACkAAAABAAAAAKturFHJX/eRt5gM6qIXAMbaXvlImqLysA6Qr9tLemxfAAAAAUVVUgAAAAAA+SY4m6vkX+Y7FMkNv7RswsIkYNGXeZ4/YwEQNUpI8/gAAAAAAAAAAH//////////AAAAAQAAAAAAAAAA', 'AAAAAQAAAAEAAAApAAAAAAAAAAD5Jjibq+Rf5jsUyQ2/tGzCwiRg0Zd5nj9jARA1Skjz+AAAAAJUC+LUAAAAJgAAAAMAAAAAAAAAAAAAAAMAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{1Qe8ngwANz4fLqYChwRjR5xng6cIqU5WBtjkZgF4ugVhi8J6kTpACvnvXso3IVym6Rfd6JdQW8QcLkFTX1MGCg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('d67cfb271a889e7854ffd61b08eacde76d56e758466fc37a8eec2d3a40ef8b14', 42, 1, 'GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF', 163208757252, 100, 1, '2016-06-29 16:34:09.254227', '2016-06-29 16:34:09.254227', 180388630528, 'AAAAAPkmOJur5F/mOxTJDb+0bMLCJGDRl3meP2MBEDVKSPP4AAAAZAAAACYAAAAEAAAAAAAAAAAAAAABAAAAAAAAAAcAAAAAq26sUclf95G3mAzqohcAxtpe+UiaovKwDpCv20t6bF8AAAABRVVSAAAAAAAAAAAAAAAAAUpI8/gAAABAEPKcQmATGpevrtlAcZnNI/GjfLLQEp9aODGGRFV+2C4UO8dU+UAMTkCSXQLD+xPaRQxzw93ScEok6GzYCtt7Bg==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAHAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAwAAACkAAAABAAAAAKturFHJX/eRt5gM6qIXAMbaXvlImqLysA6Qr9tLemxfAAAAAUVVUgAAAAAA+SY4m6vkX+Y7FMkNv7RswsIkYNGXeZ4/YwEQNUpI8/gAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAACoAAAABAAAAAKturFHJX/eRt5gM6qIXAMbaXvlImqLysA6Qr9tLemxfAAAAAUVVUgAAAAAA+SY4m6vkX+Y7FMkNv7RswsIkYNGXeZ4/YwEQNUpI8/gAAAAAAAAAAH//////////AAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAApAAAAAAAAAAD5Jjibq+Rf5jsUyQ2/tGzCwiRg0Zd5nj9jARA1Skjz+AAAAAJUC+LUAAAAJgAAAAMAAAAAAAAAAAAAAAMAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAqAAAAAAAAAAD5Jjibq+Rf5jsUyQ2/tGzCwiRg0Zd5nj9jARA1Skjz+AAAAAJUC+JwAAAAJgAAAAQAAAAAAAAAAAAAAAMAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{EPKcQmATGpevrtlAcZnNI/GjfLLQEp9aODGGRFV+2C4UO8dU+UAMTkCSXQLD+xPaRQxzw93ScEok6GzYCtt7Bg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('945b6171de747ab323b3cda52290933df39edd7061f6e260762663efc51bccb0', 43, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 18, 100, 1, '2016-06-29 16:34:09.258497', '2016-06-29 16:34:09.258497', 184683597824, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAASAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAjvuao1PL1U+CaCf7/+6+M/xUnEnUUdDiMKthL4rj4e8AAAACVAvkAAAAAAAAAAABVvwF9wAAAEBFbS2c5rrYNGslNVslTHH8j8x0ggew1eHHOUTNajMPy8GYn52RSwRncwwvv1ejEfA+g/mTXMpXrBO847C46KoA', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAACsAAAAAAAAAAI77mqNTy9VPgmgn+//uvjP8VJxJ1FHQ4jCrYS+K4+HvAAAAAlQL5AAAAAArAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAACsAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2iczcDPgAAAAAAAAAEgAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAmAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtowg5/FcAAAAAAAAABEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAArAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtowg5/D4AAAAAAAAABIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{RW0tnOa62DRrJTVbJUxx/I/MdIIHsNXhxzlEzWozD8vBmJ+dkUsEZ3MML79XoxHwPoP5k1zKV6wTvOOwuOiqAA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('e0773d07aba23d11e6a06b021682294be1f9f202a2926827022539662ce2c7fc', 44, 1, 'GCHPXGVDKPF5KT4CNAT7X77OXYZ7YVE4JHKFDUHCGCVWCL4K4PQ67KKZ', 184683593729, 100, 1, '2016-06-29 16:34:09.263986', '2016-06-29 16:34:09.263986', 188978565120, 'AAAAAI77mqNTy9VPgmgn+//uvjP8VJxJ1FHQ4jCrYS+K4+HvAAAAZAAAACsAAAABAAAAAAAAAAAAAAABAAAAAAAAAAgAAAAAYvwdC9CRsrYcDdZWNGsqaNfTR8bywsjubQRHAlb8BfcAAAAAAAAAAYrj4e8AAABA3jJ7wBrRpsrcnqBQWjyzwvVz2v5UJ56G60IhgsaWQFSf+7om462KToc+HJ27aLVOQ83dGh1ivp+VIuREJq/SBw==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAIAAAAAAAAAAJUC+OcAAAAAA==', 'AAAAAAAAAAEAAAADAAAAAwAAACsAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2iczcDPgAAAAAAAAAEgAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAACwAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2jCDn8JQAAAAAAAAAEgAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAAAjvuao1PL1U+CaCf7/+6+M/xUnEnUUdDiMKthL4rj4e8=', 'AAAAAgAAAAMAAAArAAAAAAAAAACO+5qjU8vVT4JoJ/v/7r4z/FScSdRR0OIwq2EviuPh7wAAAAJUC+QAAAAAKwAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAsAAAAAAAAAACO+5qjU8vVT4JoJ/v/7r4z/FScSdRR0OIwq2EviuPh7wAAAAJUC+OcAAAAKwAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{3jJ7wBrRpsrcnqBQWjyzwvVz2v5UJ56G60IhgsaWQFSf+7om462KToc+HJ27aLVOQ83dGh1ivp+VIuREJq/SBw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('5b42c77042f04bf716659a05e7ca3f4703af038a7da75b10b8538707c9ff172f', 45, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 19, 100, 1, '2016-06-29 16:34:09.268612', '2016-06-29 16:34:09.268612', 193273532416, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAATAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAA493YBEKdTeVN3wUjgsf56+V7YgpjSdqDCWTMfjGCtycCxorwuxQAAAAAAAAAAAABVvwF9wAAAECGClRePcAExQ/WKroo3/3dfchP/yI8TRDrrjt/chZ83ULiTc54l5wcz1AkbLa6CAapdSGpUWXk5ksTqDXLn4AA', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAAC0AAAAAAAAAAOPd2ARCnU3lTd8FI4LH+evle2IKY0nagwlkzH4xgrcnAsaK8LsUAAAAAAAtAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAC0AAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3Cxorm2XT8DAAAAAAAAAAEwAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAsAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtowg5/CUAAAAAAAAABIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAtAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtowg5/AwAAAAAAAAABMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{hgpUXj3ABMUP1iq6KN/93X3IT/8iPE0Q6647f3IWfN1C4k3OeJecHM9QJGy2uggGqXUhqVFl5OZLE6g1y5+AAA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('d24f486bd722fd1875b843839e880bdeea324e25db706a26af5e4daa8c5071eb', 46, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 20, 100, 1, '2016-06-29 16:34:09.273973', '2016-06-29 16:34:09.273973', 197568499712, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAAUAAAAAAAAAAAAAAABAAAAAAAAAAUAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAQAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABVvwF9wAAAEBYI0TMQVWPvnC2KPbDph9Myz5UMuBRIYt2YQdtlPYC4UHamYnHsMghpIMfaS7MWdHuGY81+FBozOsS+/HGohQD', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAFAAAAAAAAAAA=', 'AAAAAAAAAAEAAAABAAAAAQAAAC4AAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3Cxorm2XT78wAAAAAAAAAFAAAAAAAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAtAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wsaK5tl0/AwAAAAAAAAABMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAuAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wsaK5tl0+/MAAAAAAAAABQAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{WCNEzEFVj75wtij2w6YfTMs+VDLgUSGLdmEHbZT2AuFB2pmJx7DIIaSDH2kuzFnR7hmPNfhQaMzrEvvxxqIUAw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('7207de5b75243e0b062c3833f587036b7e9f64453be49ff50f3f3fdc7516ec6b', 46, 2, 'GDR53WAEIKOU3ZKN34CSHAWH7HV6K63CBJRUTWUDBFSMY7RRQK3SPKOS', 193273528321, 100, 1, '2016-06-29 16:34:09.275472', '2016-06-29 16:34:09.275472', 197568503808, 'AAAAAOPd2ARCnU3lTd8FI4LH+evle2IKY0nagwlkzH4xgrcnAAAAZAAAAC0AAAABAAAAAAAAAAAAAAABAAAAAAAAAAUAAAABAAAAAOPd2ARCnU3lTd8FI4LH+evle2IKY0nagwlkzH4xgrcnAAAAAQAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABMYK3JwAAAEAOkGOPTOBDSQ7nW2Zn+bls2PDUebk2/k3/gqHKQ8eYOFsD6nBeEvyMD858vo5BabjQwB9injABIM8esDh7bEkC', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAFAAAAAAAAAAA=', 'AAAAAAAAAAEAAAABAAAAAQAAAC4AAAAAAAAAAOPd2ARCnU3lTd8FI4LH+evle2IKY0nagwlkzH4xgrcnAsaK8LsT/5wAAAAtAAAAAQAAAAAAAAABAAAAAOPd2ARCnU3lTd8FI4LH+evle2IKY0nagwlkzH4xgrcnAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAtAAAAAAAAAADj3dgEQp1N5U3fBSOCx/nr5XtiCmNJ2oMJZMx+MYK3JwLGivC7FAAAAAAALQAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAuAAAAAAAAAADj3dgEQp1N5U3fBSOCx/nr5XtiCmNJ2oMJZMx+MYK3JwLGivC7E/+cAAAALQAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{DpBjj0zgQ0kO51tmZ/m5bNjw1Hm5Nv5N/4KhykPHmDhbA+pwXhL8jA/OfL6OQWm40MAfYp4wASDPHrA4e2xJAg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('ea93efd8c2f4e45c0318c69ec958623a0e4374f40d569eec124d43c8a54d6256', 47, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 21, 100, 1, '2016-06-29 16:34:09.279524', '2016-06-29 16:34:09.279524', 201863467008, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAAVAAAAAAAAAAAAAAABAAAAAAAAAAkAAAAAAAAAAVb8BfcAAABABUHuXY+MTgW/wDv5+NDVh9fw4meszxeXO98HEQfgXVeCZ7eObCI2orSGUNA/SK6HV9/uTVSxIQQWIso1QoxHBQ==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAJAAAAAAAAAAIAAAAAYvwdC9CRsrYcDdZWNGsqaNfTR8bywsjubQRHAlb8BfcAAIrEjCYwXAAAAADj3dgEQp1N5U3fBSOCx/nr5XtiCmNJ2oMJZMx+MYK3JwAAIrEjfceLAAAAAA==', 'AAAAAAAAAAEAAAADAAAAAQAAAC8AAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3Cxq2X/H6H8QAAAAAAAAAFQAAAAAAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAwAAAC4AAAAAAAAAAOPd2ARCnU3lTd8FI4LH+evle2IKY0nagwlkzH4xgrcnAsaK8LsT/5wAAAAtAAAAAQAAAAAAAAABAAAAAOPd2ARCnU3lTd8FI4LH+evle2IKY0nagwlkzH4xgrcnAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAC8AAAAAAAAAAOPd2ARCnU3lTd8FI4LH+evle2IKY0nagwlkzH4xgrcnAsatod6RxycAAAAtAAAAAQAAAAAAAAABAAAAAOPd2ARCnU3lTd8FI4LH+evle2IKY0nagwlkzH4xgrcnAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAuAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wsaK5tl0+/MAAAAAAAAABQAAAAAAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAvAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wsaK5tl0+9oAAAAAAAAABUAAAAAAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{BUHuXY+MTgW/wDv5+NDVh9fw4meszxeXO98HEQfgXVeCZ7eObCI2orSGUNA/SK6HV9/uTVSxIQQWIso1QoxHBQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('eb8586c9176c4cf2e864b2521948a972db5274de24673669463e0c7824cee056', 48, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 22, 100, 1, '2016-06-29 16:34:09.28389', '2016-06-29 16:34:09.28389', 206158434304, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAAWAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAMSExUMeJhd3PnPyXvdcbKtDZE3zllFbW4uwI1C6Z+xkAAAACVAvkAAAAAAAAAAABVvwF9wAAAECAMOn6G4jusgpfSoHwntHQkYIDxI/VnyH/qIi+bdMWzi1T6WlwnO+yITgm2+mOaWc6zVuxiLjHllzBeQ/xKvQN', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAADAAAAAAAAAAADEhMVDHiYXdz5z8l73XGyrQ2RN85ZRW1uLsCNQumfsZAAAAAlQL5AAAAAAwAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAADAAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3Cxq2XZ3uO2AAAAAAAAAAFgAAAAAAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAvAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wsatl/x+h/EAAAAAAAAABUAAAAAAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAwAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wsatl/x+h9gAAAAAAAAABYAAAAAAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{gDDp+huI7rIKX0qB8J7R0JGCA8SP1Z8h/6iIvm3TFs4tU+lpcJzvsiE4JtvpjmlnOs1bsYi4x5ZcwXkP8Sr0DQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('9fff61916716fb2550043fac968ac6c13802af5176a10fc29108fcfc445ef513', 49, 1, 'GAYSCMKQY6EYLXOPTT6JPPOXDMVNBWITPTSZIVWW4LWARVBOTH5RTLAD', 206158430209, 100, 1, '2016-06-29 16:34:09.289159', '2016-06-29 16:34:09.289159', 210453401600, 'AAAAADEhMVDHiYXdz5z8l73XGyrQ2RN85ZRW1uLsCNQumfsZAAAAZAAAADAAAAABAAAAAAAAAAAAAAABAAAAAAAAAAoAAAAFbmFtZTEAAAAAAAABAAAABDEyMzQAAAAAAAAAAS6Z+xkAAABAxKiHYYNLJiW3r5+kCJm8ucaoV7BcrEnQXFb3s1RyRyUbAkDlaCvE+RKwMZoNUfbkQUGrouyVKy1ZpUeccByqDg==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAKAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAADEAAAADAAAAADEhMVDHiYXdz5z8l73XGyrQ2RN85ZRW1uLsCNQumfsZAAAABW5hbWUxAAAAAAAABDEyMzQAAAAAAAAAAAAAAAEAAAAxAAAAAAAAAAAxITFQx4mF3c+c/Je91xsq0NkTfOWUVtbi7AjULpn7GQAAAAJUC+M4AAAAMAAAAAIAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', 'AAAAAgAAAAMAAAAwAAAAAAAAAAAxITFQx4mF3c+c/Je91xsq0NkTfOWUVtbi7AjULpn7GQAAAAJUC+QAAAAAMAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAxAAAAAAAAAAAxITFQx4mF3c+c/Je91xsq0NkTfOWUVtbi7AjULpn7GQAAAAJUC+OcAAAAMAAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{xKiHYYNLJiW3r5+kCJm8ucaoV7BcrEnQXFb3s1RyRyUbAkDlaCvE+RKwMZoNUfbkQUGrouyVKy1ZpUeccByqDg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('e4609180751e7702466a8845857df43e4d154ec84b6bad62ce507fe12f1daf99', 49, 2, 'GAYSCMKQY6EYLXOPTT6JPPOXDMVNBWITPTSZIVWW4LWARVBOTH5RTLAD', 206158430210, 100, 1, '2016-06-29 16:34:09.290597', '2016-06-29 16:34:09.290597', 210453405696, 'AAAAADEhMVDHiYXdz5z8l73XGyrQ2RN85ZRW1uLsCNQumfsZAAAAZAAAADAAAAACAAAAAAAAAAAAAAABAAAAAAAAAAoAAAAFbmFtZTIAAAAAAAABAAAABDU2NzgAAAAAAAAAAS6Z+xkAAABAjxgnTRBCa0n1efZocxpEjXeITQ5sEYTVd9fowuto2kPw5eFwgVnz6OrKJwCRt5L8ylmWiATXVI3Zyfi3yTKqBA==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAKAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAADEAAAADAAAAADEhMVDHiYXdz5z8l73XGyrQ2RN85ZRW1uLsCNQumfsZAAAABW5hbWUyAAAAAAAABDU2NzgAAAAAAAAAAAAAAAEAAAAxAAAAAAAAAAAxITFQx4mF3c+c/Je91xsq0NkTfOWUVtbi7AjULpn7GQAAAAJUC+M4AAAAMAAAAAIAAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', 'AAAAAQAAAAEAAAAxAAAAAAAAAAAxITFQx4mF3c+c/Je91xsq0NkTfOWUVtbi7AjULpn7GQAAAAJUC+M4AAAAMAAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{jxgnTRBCa0n1efZocxpEjXeITQ5sEYTVd9fowuto2kPw5eFwgVnz6OrKJwCRt5L8ylmWiATXVI3Zyfi3yTKqBA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('def26097cd63b13105d21172854587a0f3a68eafd09f96b7bb45e8c7fafb0946', 50, 1, 'GAYSCMKQY6EYLXOPTT6JPPOXDMVNBWITPTSZIVWW4LWARVBOTH5RTLAD', 206158430211, 100, 1, '2016-06-29 16:34:09.294512', '2016-06-29 16:34:09.294512', 214748368896, 'AAAAADEhMVDHiYXdz5z8l73XGyrQ2RN85ZRW1uLsCNQumfsZAAAAZAAAADAAAAADAAAAAAAAAAAAAAABAAAAAAAAAAoAAAAFbmFtZTIAAAAAAAAAAAAAAAAAAAEumfsZAAAAQECC7FH/CV04TFceB2a8NjE7S5i+AokTd7/xDlO4pjHeYkiEN+rxB9STqBfpWqsnODXQ516SNKFoVsNeTWTpxg8=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAKAAAAAAAAAAA=', 'AAAAAAAAAAEAAAADAAAAAQAAADIAAAAAAAAAADEhMVDHiYXdz5z8l73XGyrQ2RN85ZRW1uLsCNQumfsZAAAAAlQL4tQAAAAwAAAAAwAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAwAAAAAAAAADAAAAADEhMVDHiYXdz5z8l73XGyrQ2RN85ZRW1uLsCNQumfsZAAAABW5hbWUyAAAAAAAABDU2NzgAAAAAAAAAAAAAAAIAAAADAAAAADEhMVDHiYXdz5z8l73XGyrQ2RN85ZRW1uLsCNQumfsZAAAABW5hbWUyAAAA', 'AAAAAgAAAAMAAAAxAAAAAAAAAAAxITFQx4mF3c+c/Je91xsq0NkTfOWUVtbi7AjULpn7GQAAAAJUC+M4AAAAMAAAAAIAAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAyAAAAAAAAAAAxITFQx4mF3c+c/Je91xsq0NkTfOWUVtbi7AjULpn7GQAAAAJUC+LUAAAAMAAAAAMAAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{QILsUf8JXThMVx4HZrw2MTtLmL4CiRN3v/EOU7imMd5iSIQ36vEH1JOoF+laqyc4NdDnXpI0oWhWw15NZOnGDw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('9dd4ec8aa09fc3320a26f71e9817264b1db52ccabda0e09acf38c38b2b9e301d', 51, 1, 'GAYSCMKQY6EYLXOPTT6JPPOXDMVNBWITPTSZIVWW4LWARVBOTH5RTLAD', 206158430212, 100, 1, '2016-06-29 16:34:09.298373', '2016-06-29 16:34:09.298373', 219043336192, 'AAAAADEhMVDHiYXdz5z8l73XGyrQ2RN85ZRW1uLsCNQumfsZAAAAZAAAADAAAAAEAAAAAAAAAAAAAAABAAAAAAAAAAoAAAAFbmFtZTEAAAAAAAABAAAABDEyMzQAAAAAAAAAAS6Z+xkAAABAYJ2V8oNXM82nq16KsHBhzmKeudDYb1CPnIsVHI74d3uFiyWYXyPy+DriSjZI3k42kDpe76fXQnVEP27g2zmOCg==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAKAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAwAAAAAAAAADAAAAADEhMVDHiYXdz5z8l73XGyrQ2RN85ZRW1uLsCNQumfsZAAAABW5hbWUxAAAAAAAABDEyMzQAAAAAAAAAAAAAAAEAAAAzAAAAAwAAAAAxITFQx4mF3c+c/Je91xsq0NkTfOWUVtbi7AjULpn7GQAAAAVuYW1lMQAAAAAAAAQxMjM0AAAAAAAAAAA=', 'AAAAAgAAAAMAAAAyAAAAAAAAAAAxITFQx4mF3c+c/Je91xsq0NkTfOWUVtbi7AjULpn7GQAAAAJUC+LUAAAAMAAAAAMAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAzAAAAAAAAAAAxITFQx4mF3c+c/Je91xsq0NkTfOWUVtbi7AjULpn7GQAAAAJUC+JwAAAAMAAAAAQAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{YJ2V8oNXM82nq16KsHBhzmKeudDYb1CPnIsVHI74d3uFiyWYXyPy+DriSjZI3k42kDpe76fXQnVEP27g2zmOCg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('c7f70738b57c1422e6845ba494a3aafb36387484d525680ecb176ee4ebee4807', 52, 1, 'GAYSCMKQY6EYLXOPTT6JPPOXDMVNBWITPTSZIVWW4LWARVBOTH5RTLAD', 206158430213, 100, 1, '2016-06-29 16:34:09.303215', '2016-06-29 16:34:09.303215', 223338303488, 'AAAAADEhMVDHiYXdz5z8l73XGyrQ2RN85ZRW1uLsCNQumfsZAAAAZAAAADAAAAAFAAAAAAAAAAAAAAABAAAAAAAAAAoAAAAFbmFtZTEAAAAAAAABAAAABDAwMDAAAAAAAAAAAS6Z+xkAAABAt72MSOt3aYwcuaRnJSMGJXitOh6u0sKTsIrfph9y3YdYiyV+SI/IP93vKlWEf0BjrwVrwHdaPrqA22PiF4beDw==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAKAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAwAAAAAAAAADAAAAADEhMVDHiYXdz5z8l73XGyrQ2RN85ZRW1uLsCNQumfsZAAAABW5hbWUxAAAAAAAABDEyMzQAAAAAAAAAAAAAAAEAAAA0AAAAAwAAAAAxITFQx4mF3c+c/Je91xsq0NkTfOWUVtbi7AjULpn7GQAAAAVuYW1lMQAAAAAAAAQwMDAwAAAAAAAAAAA=', 'AAAAAgAAAAMAAAAzAAAAAAAAAAAxITFQx4mF3c+c/Je91xsq0NkTfOWUVtbi7AjULpn7GQAAAAJUC+JwAAAAMAAAAAQAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAA0AAAAAAAAAAAxITFQx4mF3c+c/Je91xsq0NkTfOWUVtbi7AjULpn7GQAAAAJUC+IMAAAAMAAAAAUAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{t72MSOt3aYwcuaRnJSMGJXitOh6u0sKTsIrfph9y3YdYiyV+SI/IP93vKlWEf0BjrwVrwHdaPrqA22PiF4beDw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('df5f0e8b3b533dd9cda0ff7540bef3e9e19369060f8a4b0414b0e3c1b4315b1c', 53, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 23, 100, 1, '2016-06-29 16:34:09.307767', '2016-06-29 16:34:09.307767', 227633270784, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAAXAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAABJeTmKR1qr+CZoIyjAfGxrIXZ/tI1VId2OfZkRowDz4AAAACVAvkAAAAAAAAAAABVvwF9wAAAEDyHwhW9GXQVXG1qibbeqSjxYzhv5IC08K2vSkxzYTwJykvQ8l0+e4M4h2guoK89s8HUfIqIOzDmoGsNTaLcYUG', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAADUAAAAAAAAAAASXk5ikdaq/gmaCMowHxsayF2f7SNVSHdjn2ZEaMA8+AAAAAlQL5AAAAAA1AAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAADUAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3Cxq2W0niVvwAAAAAAAAAFwAAAAAAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAwAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wsatl2d7jtgAAAAAAAAABYAAAAAAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAA1AAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wsatl2d7jr8AAAAAAAAABcAAAAAAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{8h8IVvRl0FVxtaom23qko8WM4b+SAtPCtr0pMc2E8CcpL0PJdPnuDOIdoLqCvPbPB1HyKiDsw5qBrDU2i3GFBg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('85bbd2b558563518a38e9b749bd4b8ced60b9fbbb7a6b283e15ae98548302ac4', 54, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 24, 200, 2, '2016-06-29 16:34:09.313061', '2016-06-29 16:34:09.313061', 231928238080, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAyAAAAAAAAAAYAAAAAAAAAAAAAAACAAAAAAAAAAEAAAAABJeTmKR1qr+CZoIyjAfGxrIXZ/tI1VId2OfZkRowDz4AAAAAAAAAAAX14QAAAAABAAAAAASXk5ikdaq/gmaCMowHxsayF2f7SNVSHdjn2ZEaMA8+AAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAAAAAAABfXhAAAAAAAAAAACVvwF9wAAAEDRRWwMrdLrhnl+FIP+71tTHB5rlzCsPVyGnR3scvID9NmIL3LZEo992uTvDI9QLys5bC2yRc3WYR0vFiZRs40IGjAPPgAAAEDXbXWVdzmN6NWBjYU5OvB33WTUaa2wDZX3RmFTZQQ/+7JvPdblMtNCxo8IOYePQg90RajV9rB+k8P+SEpPHCUH', 'AAAAAAAAAMgAAAAAAAAAAgAAAAAAAAABAAAAAAAAAAAAAAABAAAAAAAAAAA=', 'AAAAAAAAAAIAAAADAAAAAwAAADUAAAAAAAAAAASXk5ikdaq/gmaCMowHxsayF2f7SNVSHdjn2ZEaMA8+AAAAAlQL5AAAAAA1AAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAADYAAAAAAAAAAASXk5ikdaq/gmaCMowHxsayF2f7SNVSHdjn2ZEaMA8+AAAAAloBxQAAAAA1AAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAADYAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3Cxq2W0PsdTQAAAAAAAAAGAAAAAAAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAEAAAA2AAAAAAAAAAAEl5OYpHWqv4JmgjKMB8bGshdn+0jVUh3Y59mRGjAPPgAAAAJUC+QAAAAANQAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAA2AAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wsatltJ4lY0AAAAAAAAABgAAAAAAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', 'AAAAAgAAAAMAAAA1AAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wsatltJ4lb8AAAAAAAAABcAAAAAAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAA2AAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wsatltJ4lY0AAAAAAAAABgAAAAAAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{0UVsDK3S64Z5fhSD/u9bUxwea5cwrD1chp0d7HLyA/TZiC9y2RKPfdrk7wyPUC8rOWwtskXN1mEdLxYmUbONCA==,1211lXc5jejVgY2FOTrwd91k1GmtsA2V90ZhU2UEP/uybz3W5TLTQsaPCDmHj0IPdEWo1fawfpPD/khKTxwlBw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('5bbbedfb52efd1d5d973e22540044a27b8115772314293e3ba8b1fb12e63ca2e', 55, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 25, 100, 1, '2016-06-29 16:34:09.318932', '2016-06-29 16:34:09.318932', 236223205376, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAAZAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAGlyOIRNnS6HDEkmGAE9gpZJUnLZNnYsjzt+pXVxR/9QAAAACVAvkAAAAAAAAAAABVvwF9wAAAEBCMMjX9xO3XKpQ6uS/U1BqdzRhSBYQ35ivmZxPBgfqQsTDma1BzOsq/bmHJ4P+fkYJRJUdZZazXJM2i4mF7nUH', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAADcAAAAAAAAAABpcjiETZ0uhwxJJhgBPYKWSVJy2TZ2LI87fqV1cUf/UAAAAAlQL5AAAAAA3AAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAADcAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3Cxq2WPXWcdAAAAAAAAAAGQAAAAAAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAA2AAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wsatltJ4lY0AAAAAAAAABgAAAAAAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAA3AAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wsatltJ4lXQAAAAAAAAABkAAAAAAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{QjDI1/cTt1yqUOrkv1NQanc0YUgWEN+Yr5mcTwYH6kLEw5mtQczrKv25hyeD/n5GCUSVHWWWs1yTNouJhe51Bw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('2a805712c6d10f9e74bb0ccf54ae92a2b4b1e586451fe8133a2433816f6b567c', 56, 1, 'GANFZDRBCNTUXIODCJEYMACPMCSZEVE4WZGZ3CZDZ3P2SXK4KH75IK6Y', 236223201281, 100, 1, '2016-06-29 16:34:09.324177', '2016-06-29 16:34:09.324177', 240518172672, 'AAAAABpcjiETZ0uhwxJJhgBPYKWSVJy2TZ2LI87fqV1cUf/UAAAAZAAAADcAAAABAAAAAAAAAAAAAAABAAAAAAAAAAEAAAAAGlyOIRNnS6HDEkmGAE9gpZJUnLZNnYsjzt+pXVxR/9QAAAAAAAAAAAX14QAAAAAAAAAAAVxR/9QAAABAK6pcXYMzAEmH08CZ1LWmvtNDKauhx+OImtP/Lk4hVTMJRVBOebVs5WEPj9iSrgGT0EswuDCZ2i5AEzwgGof9Ag==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAA=', 'AAAAAAAAAAEAAAAA', 'AAAAAgAAAAMAAAA3AAAAAAAAAAAaXI4hE2dLocMSSYYAT2ClklSctk2diyPO36ldXFH/1AAAAAJUC+QAAAAANwAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAA4AAAAAAAAAAAaXI4hE2dLocMSSYYAT2ClklSctk2diyPO36ldXFH/1AAAAAJUC+OcAAAANwAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{K6pcXYMzAEmH08CZ1LWmvtNDKauhx+OImtP/Lk4hVTMJRVBOebVs5WEPj9iSrgGT0EswuDCZ2i5AEzwgGof9Ag==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('7e0a75b8d7c4901b4b845936e0ba39db8e1fe3c743b7f72fa4bd95a69bbbe524', 57, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 26, 100, 1, '2016-06-29 16:34:09.328328', '2016-06-29 16:34:09.328329', 244813139968, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAAaAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAFNR8b2/CYAfaDThoC37iRFuWv1IrOY6ugrWXhfJJJgAAAAACVAvkAAAAAAAAAAABVvwF9wAAAED647Bq8fDRUtx+msiDZ+1+omZLNEjo8U6QY0snKz2HqDm+WkHwA0SRRk/i6dy5FbU0OFAwKtjC/1UQYYZmmVMC', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAADkAAAAAAAAAABTUfG9vwmAH2g04aAt+4kRblr9SKzmOroK1l4XySSYAAAAAAlQL5AAAAAA5AAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAADkAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3Cxq2VqHKjWwAAAAAAAAAGgAAAAAAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAA3AAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wsatlj11nHQAAAAAAAAABkAAAAAAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAA5AAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wsatlj11nFsAAAAAAAAABoAAAAAAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{+uOwavHw0VLcfprIg2ftfqJmSzRI6PFOkGNLJys9h6g5vlpB8ANEkUZP4uncuRW1NDhQMCrYwv9VEGGGZplTAg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('6f356f7576ff40af6349d734617104c910e4f61e234615f8595b8884743925c2', 58, 1, 'GANFZDRBCNTUXIODCJEYMACPMCSZEVE4WZGZ3CZDZ3P2SXK4KH75IK6Y', 236223201282, 100, 1, '2016-06-29 16:34:09.33388', '2016-06-29 16:34:09.33388', 249108107264, 'AAAAABpcjiETZ0uhwxJJhgBPYKWSVJy2TZ2LI87fqV1cUf/UAAAAZAAAADcAAAACAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABVVNEAAAAAAAaXI4hE2dLocMSSYYAT2ClklSctk2diyPO36ldXFH/1H//////////AAAAAAAAAAFcUf/UAAAAQIT+cY8umew9OrXfGKi0VF4bqO7pb/oW1Nj0AkcYPA5eLB/V0F936co52NW3BLVYpNNTg4k2pU429rABSWe/DwI=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAGAAAAAAAAAAA=', 'AAAAAAAAAAEAAAAA', 'AAAAAgAAAAMAAAA4AAAAAAAAAAAaXI4hE2dLocMSSYYAT2ClklSctk2diyPO36ldXFH/1AAAAAJUC+OcAAAANwAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAA6AAAAAAAAAAAaXI4hE2dLocMSSYYAT2ClklSctk2diyPO36ldXFH/1AAAAAJUC+M4AAAANwAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{hP5xjy6Z7D06td8YqLRUXhuo7ulv+hbU2PQCRxg8Dl4sH9XQX3fpyjnY1bcEtVik01ODiTalTjb2sAFJZ78PAg==}', 'none', NULL, NULL);


--
-- Name: gorp_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY gorp_migrations
    ADD CONSTRAINT gorp_migrations_pkey PRIMARY KEY (id);


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
-- Name: hist_e_by_order; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX hist_e_by_order ON history_effects USING btree (history_operation_id, "order");


--
-- Name: hist_e_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX hist_e_id ON history_effects USING btree (history_account_id, history_operation_id, "order");


--
-- Name: hist_op_p_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX hist_op_p_id ON history_operation_participants USING btree (history_account_id, history_operation_id);


--
-- Name: hist_tx_p_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX hist_tx_p_id ON history_transaction_participants USING btree (history_account_id, history_transaction_id);


--
-- Name: hop_by_hoid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX hop_by_hoid ON history_operation_participants USING btree (history_operation_id);


--
-- Name: hs_ledger_by_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX hs_ledger_by_id ON history_ledgers USING btree (id);


--
-- Name: hs_transaction_by_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX hs_transaction_by_id ON history_transactions USING btree (id);


--
-- Name: htp_by_htid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX htp_by_htid ON history_transaction_participants USING btree (history_transaction_id);


--
-- Name: index_history_accounts_on_address; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_history_accounts_on_address ON history_accounts USING btree (address);


--
-- Name: index_history_accounts_on_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_history_accounts_on_id ON history_accounts USING btree (id);


--
-- Name: index_history_effects_on_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_history_effects_on_type ON history_effects USING btree (type);


--
-- Name: index_history_ledgers_on_closed_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_history_ledgers_on_closed_at ON history_ledgers USING btree (closed_at);


--
-- Name: index_history_ledgers_on_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_history_ledgers_on_id ON history_ledgers USING btree (id);


--
-- Name: index_history_ledgers_on_importer_version; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_history_ledgers_on_importer_version ON history_ledgers USING btree (importer_version);


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
-- Name: index_history_transactions_on_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_history_transactions_on_id ON history_transactions USING btree (id);


--
-- Name: trade_effects_by_order_book; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX trade_effects_by_order_book ON history_effects USING btree (((details ->> 'sold_asset_type'::text)), ((details ->> 'sold_asset_code'::text)), ((details ->> 'sold_asset_issuer'::text)), ((details ->> 'bought_asset_type'::text)), ((details ->> 'bought_asset_code'::text)), ((details ->> 'bought_asset_issuer'::text))) WHERE (type = 33);


--
-- PostgreSQL database dump complete
--

