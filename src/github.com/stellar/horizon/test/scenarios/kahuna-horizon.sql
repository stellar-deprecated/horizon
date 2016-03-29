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
DROP TABLE IF EXISTS public.gorp_migrations;
DROP EXTENSION IF EXISTS hstore;
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
-- Name: gorp_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE gorp_migrations (
    id text NOT NULL,
    applied_at timestamp with time zone
);


--
-- Name: history_accounts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE history_accounts (
    id bigint NOT NULL,
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

INSERT INTO gorp_migrations VALUES ('1_initial_schema.sql', '2016-03-28 14:19:48.335447-08');
INSERT INTO gorp_migrations VALUES ('2_index_participants_by_toid.sql', '2016-03-28 14:19:48.338603-08');


--
-- Data for Name: history_accounts; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO history_accounts VALUES (1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_accounts VALUES (12884905985, 'GAXI33UCLQTCKM2NMRBS7XYBR535LLEVAHL5YBN4FTCB4HZHT7ZA5CVK');
INSERT INTO history_accounts VALUES (17179873281, 'GDXFAGJCSCI4CK2YHK6YRLA6TKEXFRX7BMGVMQOBMLIEUJRJ5YQNLMIB');
INSERT INTO history_accounts VALUES (30064775169, 'GA46VRKBCLI2X6DXLX7AIEVRFLH3UA7XBE3NGNP6O74HQ5LXHMGTV2JB');
INSERT INTO history_accounts VALUES (38654709761, 'GAG52TW6QAB6TGNMOTL32Y4M3UQQLNNNHPEHYAIYRP6SFF6ZAVRF5ZQY');
INSERT INTO history_accounts VALUES (47244644353, 'GDCVTBGSEEU7KLXUMHMSXBALXJ2T4I2KOPXW2S5TRLKDRIAXD5UDHAYO');
INSERT INTO history_accounts VALUES (51539611649, 'GCB7FPYGLL6RJ37HKRAYW5TAWMFBGGFGM4IM6ERBCZXI2BZ4OOOX2UAY');
INSERT INTO history_accounts VALUES (55834578945, 'GCHC4D2CS45CJRNN4QAHT2LFZAJIU5PA7H53K3VOP6WEJ6XWHNSNZKQG');
INSERT INTO history_accounts VALUES (55834583041, 'GANZGPKY5WSHWG5YOZMNG52GCK5SCJ4YGUWMJJVGZSK2FP4BI2JIJN2C');
INSERT INTO history_accounts VALUES (68719480833, 'GDRW375MAYR46ODGF2WGANQC2RRZL7O246DYHHCGWTV2RE7IHE2QUQLD');
INSERT INTO history_accounts VALUES (68719484929, 'GACAR2AEYEKITE2LKI5RMXF5MIVZ6Q7XILROGDT22O7JX4DSWFS7FDDP');
INSERT INTO history_accounts VALUES (68719489025, 'GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU');
INSERT INTO history_accounts VALUES (90194317313, 'GBOK7BOUSOWPHBANBYM6MIRYZJIDIPUYJPXHTHADF75UEVIVYWHHONQC');
INSERT INTO history_accounts VALUES (90194321409, 'GB2QIYT2IAUFMRXKLSLLPRECC6OCOGJMADSPTRK7TGNT2SFR2YGWDARD');
INSERT INTO history_accounts VALUES (107374186497, 'GB6GN3LJUW6JYR7EDOJ47VBH7D45M4JWHXGK6LHJRAEI5JBSN2DBQY7Q');
INSERT INTO history_accounts VALUES (115964121089, 'GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES');
INSERT INTO history_accounts VALUES (141733924865, 'GCJKJXPKBFIHOO3455WXWG5CDBZXQNYFRRGICYMPUQ35CPQ4WVS3KZLG');
INSERT INTO history_accounts VALUES (163208761345, 'GCVW5LCRZFP7PENXTAGOVIQXADDNUXXZJCNKF4VQB2IK7W2LPJWF73UG');
INSERT INTO history_accounts VALUES (163208765441, 'GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF');
INSERT INTO history_accounts VALUES (184683597825, 'GCHPXGVDKPF5KT4CNAT7X77OXYZ7YVE4JHKFDUHCGCVWCL4K4PQ67KKZ');
INSERT INTO history_accounts VALUES (197568499713, 'GDR53WAEIKOU3ZKN34CSHAWH7HV6K63CBJRUTWUDBFSMY7RRQK3SPKOS');
INSERT INTO history_accounts VALUES (206158434305, 'GAYSCMKQY6EYLXOPTT6JPPOXDMVNBWITPTSZIVWW4LWARVBOTH5RTLAD');
INSERT INTO history_accounts VALUES (227633270785, 'GACJPE4YUR22VP4CM2BDFDAHY3DLEF3H7NENKUQ53DT5TEI2GAHT5N4X');
INSERT INTO history_accounts VALUES (236223205377, 'GANFZDRBCNTUXIODCJEYMACPMCSZEVE4WZGZ3CZDZ3P2SXK4KH75IK6Y');


--
-- Data for Name: history_effects; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO history_effects VALUES (12884905985, 12884905985, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 12884905985, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (12884905985, 12884905985, 3, 10, '{"weight": 1, "public_key": "GAXI33UCLQTCKM2NMRBS7XYBR535LLEVAHL5YBN4FTCB4HZHT7ZA5CVK"}');
INSERT INTO history_effects VALUES (17179873281, 17179873281, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 17179873281, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (17179873281, 17179873281, 3, 10, '{"weight": 1, "public_key": "GDXFAGJCSCI4CK2YHK6YRLA6TKEXFRX7BMGVMQOBMLIEUJRJ5YQNLMIB"}');
INSERT INTO history_effects VALUES (17179873281, 21474840577, 1, 12, '{"weight": 1, "public_key": "GDXFAGJCSCI4CK2YHK6YRLA6TKEXFRX7BMGVMQOBMLIEUJRJ5YQNLMIB"}');
INSERT INTO history_effects VALUES (17179873281, 21474844673, 1, 12, '{"weight": 1, "public_key": "GDXFAGJCSCI4CK2YHK6YRLA6TKEXFRX7BMGVMQOBMLIEUJRJ5YQNLMIB"}');
INSERT INTO history_effects VALUES (17179873281, 21474844673, 2, 10, '{"weight": 1, "public_key": "GD3E7HKMRNT6HGBGHBT6I6JE4N2S4W5KZ246TGJ4KQSXJ2P4BXCUPQMP"}');
INSERT INTO history_effects VALUES (17179873281, 21474848769, 1, 4, '{"low_threshold": 2, "med_threshold": 2, "high_threshold": 2}');
INSERT INTO history_effects VALUES (17179873281, 21474848769, 2, 12, '{"weight": 1, "public_key": "GDXFAGJCSCI4CK2YHK6YRLA6TKEXFRX7BMGVMQOBMLIEUJRJ5YQNLMIB"}');
INSERT INTO history_effects VALUES (17179873281, 21474848769, 3, 10, '{"weight": 1, "public_key": "GD3E7HKMRNT6HGBGHBT6I6JE4N2S4W5KZ246TGJ4KQSXJ2P4BXCUPQMP"}');
INSERT INTO history_effects VALUES (17179873281, 25769807873, 1, 12, '{"weight": 2, "public_key": "GDXFAGJCSCI4CK2YHK6YRLA6TKEXFRX7BMGVMQOBMLIEUJRJ5YQNLMIB"}');
INSERT INTO history_effects VALUES (17179873281, 25769807873, 2, 12, '{"weight": 1, "public_key": "GD3E7HKMRNT6HGBGHBT6I6JE4N2S4W5KZ246TGJ4KQSXJ2P4BXCUPQMP"}');
INSERT INTO history_effects VALUES (30064775169, 30064775169, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 30064775169, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (30064775169, 30064775169, 3, 10, '{"weight": 1, "public_key": "GA46VRKBCLI2X6DXLX7AIEVRFLH3UA7XBE3NGNP6O74HQ5LXHMGTV2JB"}');
INSERT INTO history_effects VALUES (1, 34359742465, 1, 2, '{"amount": "1.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (30064775169, 34359742465, 2, 3, '{"amount": "1.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (1, 34359746561, 1, 2, '{"amount": "1.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (30064775169, 34359746561, 2, 3, '{"amount": "1.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (1, 34359750657, 1, 2, '{"amount": "1.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (30064775169, 34359750657, 2, 3, '{"amount": "1.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (1, 34359754753, 1, 2, '{"amount": "1.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (30064775169, 34359754753, 2, 3, '{"amount": "1.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (38654709761, 38654709761, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 38654709761, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (38654709761, 38654709761, 3, 10, '{"weight": 1, "public_key": "GAG52TW6QAB6TGNMOTL32Y4M3UQQLNNNHPEHYAIYRP6SFF6ZAVRF5ZQY"}');
INSERT INTO history_effects VALUES (1, 42949677057, 1, 2, '{"amount": "10.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (38654709761, 42949677057, 2, 3, '{"amount": "10.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (1, 42949677058, 1, 2, '{"amount": "10.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (38654709761, 42949677058, 2, 3, '{"amount": "10.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (47244644353, 47244644353, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 47244644353, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (47244644353, 47244644353, 3, 10, '{"weight": 1, "public_key": "GDCVTBGSEEU7KLXUMHMSXBALXJ2T4I2KOPXW2S5TRLKDRIAXD5UDHAYO"}');
INSERT INTO history_effects VALUES (51539611649, 51539611649, 1, 0, '{"starting_balance": "50.0000000"}');
INSERT INTO history_effects VALUES (47244644353, 51539611649, 2, 3, '{"amount": "50.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (51539611649, 51539611649, 3, 10, '{"weight": 1, "public_key": "GCB7FPYGLL6RJ37HKRAYW5TAWMFBGGFGM4IM6ERBCZXI2BZ4OOOX2UAY"}');
INSERT INTO history_effects VALUES (55834578945, 55834578945, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 55834578945, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (55834578945, 55834578945, 3, 10, '{"weight": 1, "public_key": "GCHC4D2CS45CJRNN4QAHT2LFZAJIU5PA7H53K3VOP6WEJ6XWHNSNZKQG"}');
INSERT INTO history_effects VALUES (55834583041, 55834583041, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 55834583041, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (55834583041, 55834583041, 3, 10, '{"weight": 1, "public_key": "GANZGPKY5WSHWG5YOZMNG52GCK5SCJ4YGUWMJJVGZSK2FP4BI2JIJN2C"}');
INSERT INTO history_effects VALUES (55834583041, 60129546241, 1, 2, '{"amount": "10.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (55834578945, 60129546241, 2, 3, '{"amount": "10.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (55834583041, 60129550337, 1, 20, '{"limit": "922337203685.4775807", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GCHC4D2CS45CJRNN4QAHT2LFZAJIU5PA7H53K3VOP6WEJ6XWHNSNZKQG"}');
INSERT INTO history_effects VALUES (55834583041, 64424513537, 1, 2, '{"amount": "10.0000000", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GCHC4D2CS45CJRNN4QAHT2LFZAJIU5PA7H53K3VOP6WEJ6XWHNSNZKQG"}');
INSERT INTO history_effects VALUES (55834578945, 64424513537, 2, 3, '{"amount": "10.0000000", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GCHC4D2CS45CJRNN4QAHT2LFZAJIU5PA7H53K3VOP6WEJ6XWHNSNZKQG"}');
INSERT INTO history_effects VALUES (68719480833, 68719480833, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 68719480833, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (68719480833, 68719480833, 3, 10, '{"weight": 1, "public_key": "GDRW375MAYR46ODGF2WGANQC2RRZL7O246DYHHCGWTV2RE7IHE2QUQLD"}');
INSERT INTO history_effects VALUES (68719484929, 68719484929, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 68719484929, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (68719484929, 68719484929, 3, 10, '{"weight": 1, "public_key": "GACAR2AEYEKITE2LKI5RMXF5MIVZ6Q7XILROGDT22O7JX4DSWFS7FDDP"}');
INSERT INTO history_effects VALUES (68719489025, 68719489025, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 68719489025, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (68719489025, 68719489025, 3, 10, '{"weight": 1, "public_key": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU"}');
INSERT INTO history_effects VALUES (68719484929, 73014448129, 1, 20, '{"limit": "922337203685.4775807", "asset_code": "EUR", "asset_type": "credit_alphanum4", "asset_issuer": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU"}');
INSERT INTO history_effects VALUES (68719480833, 73014452225, 1, 20, '{"limit": "922337203685.4775807", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU"}');
INSERT INTO history_effects VALUES (68719480833, 77309415425, 1, 2, '{"amount": "100.0000000", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU"}');
INSERT INTO history_effects VALUES (68719489025, 77309415425, 2, 3, '{"amount": "100.0000000", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU"}');
INSERT INTO history_effects VALUES (68719484929, 81604382721, 1, 2, '{"amount": "200.0000000", "asset_code": "EUR", "asset_type": "credit_alphanum4", "asset_issuer": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU"}');
INSERT INTO history_effects VALUES (68719480833, 81604382721, 2, 3, '{"amount": "100.0000000", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU"}');
INSERT INTO history_effects VALUES (68719480833, 81604382721, 3, 33, '{"seller": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU", "offer_id": 1, "sold_amount": "100.0000000", "bought_amount": "200.0000000", "sold_asset_code": "USD", "sold_asset_type": "credit_alphanum4", "bought_asset_type": "native", "sold_asset_issuer": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU"}');
INSERT INTO history_effects VALUES (68719489025, 81604382721, 4, 33, '{"seller": "GDRW375MAYR46ODGF2WGANQC2RRZL7O246DYHHCGWTV2RE7IHE2QUQLD", "offer_id": 1, "sold_amount": "200.0000000", "bought_amount": "100.0000000", "sold_asset_type": "native", "bought_asset_code": "USD", "bought_asset_type": "credit_alphanum4", "bought_asset_issuer": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU"}');
INSERT INTO history_effects VALUES (68719480833, 81604382721, 5, 33, '{"seller": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU", "offer_id": 2, "sold_amount": "200.0000000", "bought_amount": "200.0000000", "sold_asset_type": "native", "bought_asset_code": "EUR", "bought_asset_type": "credit_alphanum4", "bought_asset_issuer": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU"}');
INSERT INTO history_effects VALUES (68719489025, 81604382721, 6, 33, '{"seller": "GDRW375MAYR46ODGF2WGANQC2RRZL7O246DYHHCGWTV2RE7IHE2QUQLD", "offer_id": 2, "sold_amount": "200.0000000", "bought_amount": "200.0000000", "sold_asset_code": "EUR", "sold_asset_type": "credit_alphanum4", "bought_asset_type": "native", "sold_asset_issuer": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU"}');
INSERT INTO history_effects VALUES (68719484929, 85899350017, 1, 2, '{"amount": "100.0000000", "asset_code": "EUR", "asset_type": "credit_alphanum4", "asset_issuer": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU"}');
INSERT INTO history_effects VALUES (68719480833, 85899350017, 2, 3, '{"amount": "100.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (68719480833, 85899350017, 3, 33, '{"seller": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU", "offer_id": 2, "sold_amount": "100.0000000", "bought_amount": "100.0000000", "sold_asset_type": "native", "bought_asset_code": "EUR", "bought_asset_type": "credit_alphanum4", "bought_asset_issuer": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU"}');
INSERT INTO history_effects VALUES (68719489025, 85899350017, 4, 33, '{"seller": "GDRW375MAYR46ODGF2WGANQC2RRZL7O246DYHHCGWTV2RE7IHE2QUQLD", "offer_id": 2, "sold_amount": "100.0000000", "bought_amount": "100.0000000", "sold_asset_code": "EUR", "sold_asset_type": "credit_alphanum4", "bought_asset_type": "native", "sold_asset_issuer": "GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU"}');
INSERT INTO history_effects VALUES (90194317313, 90194317313, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 90194317313, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (90194317313, 90194317313, 3, 10, '{"weight": 1, "public_key": "GBOK7BOUSOWPHBANBYM6MIRYZJIDIPUYJPXHTHADF75UEVIVYWHHONQC"}');
INSERT INTO history_effects VALUES (90194321409, 90194321409, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 90194321409, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (90194321409, 90194321409, 3, 10, '{"weight": 1, "public_key": "GB2QIYT2IAUFMRXKLSLLPRECC6OCOGJMADSPTRK7TGNT2SFR2YGWDARD"}');
INSERT INTO history_effects VALUES (90194317313, 94489284609, 1, 20, '{"limit": "922337203685.4775807", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GB2QIYT2IAUFMRXKLSLLPRECC6OCOGJMADSPTRK7TGNT2SFR2YGWDARD"}');
INSERT INTO history_effects VALUES (90194321409, 103079219201, 1, 33, '{"seller": "GBOK7BOUSOWPHBANBYM6MIRYZJIDIPUYJPXHTHADF75UEVIVYWHHONQC", "offer_id": 3, "sold_amount": "20.0000000", "bought_amount": "20.0000000", "sold_asset_code": "USD", "sold_asset_type": "credit_alphanum4", "bought_asset_type": "native", "sold_asset_issuer": "GB2QIYT2IAUFMRXKLSLLPRECC6OCOGJMADSPTRK7TGNT2SFR2YGWDARD"}');
INSERT INTO history_effects VALUES (90194317313, 103079219201, 2, 33, '{"seller": "GB2QIYT2IAUFMRXKLSLLPRECC6OCOGJMADSPTRK7TGNT2SFR2YGWDARD", "offer_id": 3, "sold_amount": "20.0000000", "bought_amount": "20.0000000", "sold_asset_type": "native", "bought_asset_code": "USD", "bought_asset_type": "credit_alphanum4", "bought_asset_issuer": "GB2QIYT2IAUFMRXKLSLLPRECC6OCOGJMADSPTRK7TGNT2SFR2YGWDARD"}');
INSERT INTO history_effects VALUES (107374186497, 107374186497, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 107374186497, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (107374186497, 107374186497, 3, 10, '{"weight": 1, "public_key": "GB6GN3LJUW6JYR7EDOJ47VBH7D45M4JWHXGK6LHJRAEI5JBSN2DBQY7Q"}');
INSERT INTO history_effects VALUES (115964121089, 115964121089, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 115964121089, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (115964121089, 115964121089, 3, 10, '{"weight": 1, "public_key": "GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES"}');
INSERT INTO history_effects VALUES (115964121089, 120259088385, 1, 12, '{"weight": 1, "public_key": "GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES"}');
INSERT INTO history_effects VALUES (115964121089, 120259092481, 1, 6, '{"auth_required_flag": true}');
INSERT INTO history_effects VALUES (115964121089, 120259092481, 2, 12, '{"weight": 1, "public_key": "GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES"}');
INSERT INTO history_effects VALUES (115964121089, 120259096577, 1, 6, '{"auth_revocable_flag": true}');
INSERT INTO history_effects VALUES (115964121089, 120259096577, 2, 12, '{"weight": 1, "public_key": "GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES"}');
INSERT INTO history_effects VALUES (115964121089, 120259100673, 1, 12, '{"weight": 2, "public_key": "GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES"}');
INSERT INTO history_effects VALUES (115964121089, 120259104769, 1, 4, '{"low_threshold": 0, "med_threshold": 2, "high_threshold": 2}');
INSERT INTO history_effects VALUES (115964121089, 120259104769, 2, 12, '{"weight": 2, "public_key": "GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES"}');
INSERT INTO history_effects VALUES (115964121089, 120259108865, 1, 5, '{"home_domain": "example.com"}');
INSERT INTO history_effects VALUES (115964121089, 120259108865, 2, 12, '{"weight": 2, "public_key": "GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES"}');
INSERT INTO history_effects VALUES (115964121089, 120259112961, 1, 12, '{"weight": 2, "public_key": "GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES"}');
INSERT INTO history_effects VALUES (115964121089, 120259112961, 2, 10, '{"weight": 1, "public_key": "GB6J3WOLKYQE6KVDZEA4JDMFTTONUYP3PUHNDNZRWIKA6JQWIMJZATFE"}');
INSERT INTO history_effects VALUES (115964121089, 124554055681, 1, 12, '{"weight": 2, "public_key": "GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES"}');
INSERT INTO history_effects VALUES (115964121089, 124554055681, 2, 12, '{"weight": 1, "public_key": "GB6J3WOLKYQE6KVDZEA4JDMFTTONUYP3PUHNDNZRWIKA6JQWIMJZATFE"}');
INSERT INTO history_effects VALUES (115964121089, 128849022977, 1, 12, '{"weight": 2, "public_key": "GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES"}');
INSERT INTO history_effects VALUES (115964121089, 128849022977, 2, 12, '{"weight": 1, "public_key": "GB6J3WOLKYQE6KVDZEA4JDMFTTONUYP3PUHNDNZRWIKA6JQWIMJZATFE"}');
INSERT INTO history_effects VALUES (115964121089, 133143990273, 1, 12, '{"weight": 2, "public_key": "GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES"}');
INSERT INTO history_effects VALUES (115964121089, 133143990273, 2, 12, '{"weight": 5, "public_key": "GB6J3WOLKYQE6KVDZEA4JDMFTTONUYP3PUHNDNZRWIKA6JQWIMJZATFE"}');
INSERT INTO history_effects VALUES (115964121089, 137438957569, 1, 6, '{"auth_required_flag": false, "auth_revocable_flag": false}');
INSERT INTO history_effects VALUES (115964121089, 137438957569, 2, 12, '{"weight": 2, "public_key": "GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES"}');
INSERT INTO history_effects VALUES (115964121089, 137438957569, 3, 12, '{"weight": 5, "public_key": "GB6J3WOLKYQE6KVDZEA4JDMFTTONUYP3PUHNDNZRWIKA6JQWIMJZATFE"}');
INSERT INTO history_effects VALUES (115964121089, 137438961665, 1, 12, '{"weight": 2, "public_key": "GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES"}');
INSERT INTO history_effects VALUES (115964121089, 137438961665, 2, 11, '{"public_key": "GB6J3WOLKYQE6KVDZEA4JDMFTTONUYP3PUHNDNZRWIKA6JQWIMJZATFE"}');
INSERT INTO history_effects VALUES (141733924865, 141733924865, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 141733924865, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (141733924865, 141733924865, 3, 10, '{"weight": 1, "public_key": "GCJKJXPKBFIHOO3455WXWG5CDBZXQNYFRRGICYMPUQ35CPQ4WVS3KZLG"}');
INSERT INTO history_effects VALUES (141733924865, 146028892161, 1, 20, '{"limit": "922337203685.4775807", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H"}');
INSERT INTO history_effects VALUES (141733924865, 150323859457, 1, 22, '{"limit": "100.0000000", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H"}');
INSERT INTO history_effects VALUES (141733924865, 154618826753, 1, 22, '{"limit": "100.0000000", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H"}');
INSERT INTO history_effects VALUES (141733924865, 158913794049, 1, 21, '{"limit": "0.0000000", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H"}');
INSERT INTO history_effects VALUES (163208761345, 163208761345, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 163208761345, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (163208761345, 163208761345, 3, 10, '{"weight": 1, "public_key": "GCVW5LCRZFP7PENXTAGOVIQXADDNUXXZJCNKF4VQB2IK7W2LPJWF73UG"}');
INSERT INTO history_effects VALUES (163208765441, 163208765441, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 163208765441, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (163208765441, 163208765441, 3, 10, '{"weight": 1, "public_key": "GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF"}');
INSERT INTO history_effects VALUES (163208765441, 167503728641, 1, 6, '{"auth_required_flag": true, "auth_revocable_flag": true}');
INSERT INTO history_effects VALUES (163208765441, 167503728641, 2, 12, '{"weight": 1, "public_key": "GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF"}');
INSERT INTO history_effects VALUES (163208761345, 171798695937, 1, 20, '{"limit": "922337203685.4775807", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF"}');
INSERT INTO history_effects VALUES (163208761345, 171798700033, 1, 20, '{"limit": "922337203685.4775807", "asset_code": "EUR", "asset_type": "credit_alphanum4", "asset_issuer": "GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF"}');
INSERT INTO history_effects VALUES (163208765441, 176093663233, 1, 23, '{"trustor": "GCVW5LCRZFP7PENXTAGOVIQXADDNUXXZJCNKF4VQB2IK7W2LPJWF73UG", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF"}');
INSERT INTO history_effects VALUES (163208765441, 176093667329, 1, 23, '{"trustor": "GCVW5LCRZFP7PENXTAGOVIQXADDNUXXZJCNKF4VQB2IK7W2LPJWF73UG", "asset_code": "EUR", "asset_type": "credit_alphanum4", "asset_issuer": "GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF"}');
INSERT INTO history_effects VALUES (163208765441, 180388630529, 1, 24, '{"trustor": "GCVW5LCRZFP7PENXTAGOVIQXADDNUXXZJCNKF4VQB2IK7W2LPJWF73UG", "asset_code": "EUR", "asset_type": "credit_alphanum4", "asset_issuer": "GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF"}');
INSERT INTO history_effects VALUES (184683597825, 184683597825, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 184683597825, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (184683597825, 184683597825, 3, 10, '{"weight": 1, "public_key": "GCHPXGVDKPF5KT4CNAT7X77OXYZ7YVE4JHKFDUHCGCVWCL4K4PQ67KKZ"}');
INSERT INTO history_effects VALUES (184683597825, 188978565121, 1, 3, '{"amount": "999.9999900", "asset_type": "native"}');
INSERT INTO history_effects VALUES (1, 188978565121, 2, 2, '{"amount": "999.9999900", "asset_type": "native"}');
INSERT INTO history_effects VALUES (184683597825, 188978565121, 3, 1, '{}');
INSERT INTO history_effects VALUES (197568499713, 197568499713, 1, 0, '{"starting_balance": "2000000000.0000000"}');
INSERT INTO history_effects VALUES (1, 197568499713, 2, 3, '{"amount": "2000000000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (197568499713, 197568499713, 3, 10, '{"weight": 1, "public_key": "GDR53WAEIKOU3ZKN34CSHAWH7HV6K63CBJRUTWUDBFSMY7RRQK3SPKOS"}');
INSERT INTO history_effects VALUES (197568499713, 201863467009, 1, 12, '{"weight": 1, "public_key": "GDR53WAEIKOU3ZKN34CSHAWH7HV6K63CBJRUTWUDBFSMY7RRQK3SPKOS"}');
INSERT INTO history_effects VALUES (1, 201863471105, 1, 12, '{"weight": 1, "public_key": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H"}');
INSERT INTO history_effects VALUES (206158434305, 206158434305, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 206158434305, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (206158434305, 206158434305, 3, 10, '{"weight": 1, "public_key": "GAYSCMKQY6EYLXOPTT6JPPOXDMVNBWITPTSZIVWW4LWARVBOTH5RTLAD"}');
INSERT INTO history_effects VALUES (227633270785, 227633270785, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 227633270785, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (227633270785, 227633270785, 3, 10, '{"weight": 1, "public_key": "GACJPE4YUR22VP4CM2BDFDAHY3DLEF3H7NENKUQ53DT5TEI2GAHT5N4X"}');
INSERT INTO history_effects VALUES (227633270785, 231928238081, 1, 2, '{"amount": "10.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (1, 231928238081, 2, 3, '{"amount": "10.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (1, 231928238082, 1, 2, '{"amount": "10.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (227633270785, 231928238082, 2, 3, '{"amount": "10.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (236223205377, 236223205377, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 236223205377, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (236223205377, 236223205377, 3, 10, '{"weight": 1, "public_key": "GANFZDRBCNTUXIODCJEYMACPMCSZEVE4WZGZ3CZDZ3P2SXK4KH75IK6Y"}');
INSERT INTO history_effects VALUES (236223205377, 240518172673, 1, 2, '{"amount": "10.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (236223205377, 240518172673, 2, 3, '{"amount": "10.0000000", "asset_type": "native"}');


--
-- Data for Name: history_ledgers; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO history_ledgers VALUES (1, '63d98f536ee68d1b27b5b89f23af5311b7569a24faf1403ad0b52b633b07be99', NULL, 0, 0, '1970-01-01 00:00:00', '2016-03-29 19:22:37.679839', '2016-03-29 19:22:37.679839', 4294967296, 6, 1000000000000000000, 0, 100, 100000000, 100);
INSERT INTO history_ledgers VALUES (2, 'b6864ea54c0dfdaae4c48456f43a026a925b4b6e01d2989769e4a5a08e77eb22', '63d98f536ee68d1b27b5b89f23af5311b7569a24faf1403ad0b52b633b07be99', 0, 0, '2016-03-29 19:22:33', '2016-03-29 19:22:37.684995', '2016-03-29 19:22:37.684995', 8589934592, 6, 1000000000000000000, 0, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (3, 'b85d35dc8b5ab0a6394775e7c995eabb9e54fc2cf3c695620012f73029612249', 'b6864ea54c0dfdaae4c48456f43a026a925b4b6e01d2989769e4a5a08e77eb22', 1, 1, '2016-03-29 19:22:34', '2016-03-29 19:22:37.688431', '2016-03-29 19:22:37.688431', 12884901888, 6, 1000000000000000000, 100, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (4, '6647ce14f876444f81eba64433f7d0717652d7fdd7d750a7d4b246f54d5abaab', 'b85d35dc8b5ab0a6394775e7c995eabb9e54fc2cf3c695620012f73029612249', 1, 1, '2016-03-29 19:22:35', '2016-03-29 19:22:37.696176', '2016-03-29 19:22:37.696176', 17179869184, 6, 1000000000000000000, 200, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (5, '94c3da774c487ded929db78534822eb268eb8d656e595e708620f50aa735999a', '6647ce14f876444f81eba64433f7d0717652d7fdd7d750a7d4b246f54d5abaab', 3, 3, '2016-03-29 19:22:36', '2016-03-29 19:22:37.701774', '2016-03-29 19:22:37.701774', 21474836480, 6, 1000000000000000000, 500, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (6, '3431ac060d437eb78a502751071225ff8021c6283bf26533068e97df73a8f569', '94c3da774c487ded929db78534822eb268eb8d656e595e708620f50aa735999a', 1, 1, '2016-03-29 19:22:37', '2016-03-29 19:22:37.709224', '2016-03-29 19:22:37.709224', 25769803776, 6, 1000000000000000000, 600, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (7, 'b69bfb13b015c0aeb5c4001b47fe974c5a2a7a7e973432ac1a4d4d179a6d65b9', '3431ac060d437eb78a502751071225ff8021c6283bf26533068e97df73a8f569', 1, 1, '2016-03-29 19:22:38', '2016-03-29 19:22:37.71367', '2016-03-29 19:22:37.71367', 30064771072, 6, 1000000000000000000, 700, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (8, 'dba1d1c9b5d9f713070868b18e11a69997e96fed0446bf9eacc7ae17a8a1bc84', 'b69bfb13b015c0aeb5c4001b47fe974c5a2a7a7e973432ac1a4d4d179a6d65b9', 4, 4, '2016-03-29 19:22:39', '2016-03-29 19:22:37.719582', '2016-03-29 19:22:37.719582', 34359738368, 6, 1000000000000000000, 1100, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (9, 'a86e6e4d59dd426165ff31e2368df97ba6b5cd9055f610281e7b5519e3e3bdf4', 'dba1d1c9b5d9f713070868b18e11a69997e96fed0446bf9eacc7ae17a8a1bc84', 1, 1, '2016-03-29 19:22:40', '2016-03-29 19:22:37.728966', '2016-03-29 19:22:37.728966', 38654705664, 6, 1000000000000000000, 1200, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (10, 'aa3bf5b45ecca8861ad91cb98dffb38cb2ea493f66f61a438f92dc4fae49f021', 'a86e6e4d59dd426165ff31e2368df97ba6b5cd9055f610281e7b5519e3e3bdf4', 1, 2, '2016-03-29 19:22:41', '2016-03-29 19:22:37.734506', '2016-03-29 19:22:37.734506', 42949672960, 6, 1000000000000000000, 1400, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (11, 'c0aabf6b92eb168c78c521aac805b6ad82a9e20788f2e76495adc73737a13f79', 'aa3bf5b45ecca8861ad91cb98dffb38cb2ea493f66f61a438f92dc4fae49f021', 1, 1, '2016-03-29 19:22:42', '2016-03-29 19:22:37.740075', '2016-03-29 19:22:37.740075', 47244640256, 6, 1000000000000000000, 1500, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (12, '422f140c53a75c08a6107c7329e4a34602e63d7c903f2011d6c1808b5a10f50c', 'c0aabf6b92eb168c78c521aac805b6ad82a9e20788f2e76495adc73737a13f79', 1, 1, '2016-03-29 19:22:43', '2016-03-29 19:22:37.746839', '2016-03-29 19:22:37.74684', 51539607552, 6, 1000000000000000000, 1600, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (13, '0d6fb4b0201d085b0d3eeeccc1ef24248bf9454449858ad50e7b0ac3672912c6', '422f140c53a75c08a6107c7329e4a34602e63d7c903f2011d6c1808b5a10f50c', 2, 2, '2016-03-29 19:22:44', '2016-03-29 19:22:37.752122', '2016-03-29 19:22:37.752122', 55834574848, 6, 1000000000000000000, 1800, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (14, '476884bde8439e016b90c257b323450c5807123a0f7f305f88a5ecef859fb9f3', '0d6fb4b0201d085b0d3eeeccc1ef24248bf9454449858ad50e7b0ac3672912c6', 2, 2, '2016-03-29 19:22:45', '2016-03-29 19:22:37.759853', '2016-03-29 19:22:37.759853', 60129542144, 6, 1000000000000000000, 2000, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (15, '1ab2e51d3e5c31bf00f458993a4801435a34f633d5a2043a84826d735041b1ec', '476884bde8439e016b90c257b323450c5807123a0f7f305f88a5ecef859fb9f3', 1, 1, '2016-03-29 19:22:46', '2016-03-29 19:22:37.765601', '2016-03-29 19:22:37.765601', 64424509440, 6, 1000000000000000000, 2100, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (16, 'b50de97bac20352fd5d5b699b2ec96341d695e07b71d6dad0a928c255484f3e8', '1ab2e51d3e5c31bf00f458993a4801435a34f633d5a2043a84826d735041b1ec', 3, 3, '2016-03-29 19:22:47', '2016-03-29 19:22:37.770074', '2016-03-29 19:22:37.770074', 68719476736, 6, 1000000000000000000, 2400, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (17, 'e253aeb1e0cdca59c6af8b302c7371aad23e7f19ea822bdee6fe4110a05e910c', 'b50de97bac20352fd5d5b699b2ec96341d695e07b71d6dad0a928c255484f3e8', 2, 2, '2016-03-29 19:22:48', '2016-03-29 19:22:37.780428', '2016-03-29 19:22:37.780428', 73014444032, 6, 1000000000000000000, 2600, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (18, 'cae403c28aca1a1833ff002fd9c75fd151ee6d26af9094447e33c410f8f8f124', 'e253aeb1e0cdca59c6af8b302c7371aad23e7f19ea822bdee6fe4110a05e910c', 3, 3, '2016-03-29 19:22:49', '2016-03-29 19:22:37.788123', '2016-03-29 19:22:37.788123', 77309411328, 6, 1000000000000000000, 2900, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (19, '3b1e0862ca8de1cc2f414a59b89e825481c140ee5d4b976389b9b6627399cef9', 'cae403c28aca1a1833ff002fd9c75fd151ee6d26af9094447e33c410f8f8f124', 1, 1, '2016-03-29 19:22:50', '2016-03-29 19:22:37.795627', '2016-03-29 19:22:37.795627', 81604378624, 6, 1000000000000000000, 3000, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (20, '42b37d78557e5670dc46ad2a3209baa32357b62e98eb3084f6794c66fa4705a0', '3b1e0862ca8de1cc2f414a59b89e825481c140ee5d4b976389b9b6627399cef9', 1, 1, '2016-03-29 19:22:51', '2016-03-29 19:22:37.801768', '2016-03-29 19:22:37.801768', 85899345920, 6, 1000000000000000000, 3100, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (21, 'fcef08034d756b2974a6312ff0970176a13db73a6f138179006100f9fa8e3e2d', '42b37d78557e5670dc46ad2a3209baa32357b62e98eb3084f6794c66fa4705a0', 2, 2, '2016-03-29 19:22:52', '2016-03-29 19:22:37.807084', '2016-03-29 19:22:37.807084', 90194313216, 6, 1000000000000000000, 3300, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (22, '4135480624af9ec6d7a58de50ce23d6662b1ed4158cea4ff708de0471eabad0b', 'fcef08034d756b2974a6312ff0970176a13db73a6f138179006100f9fa8e3e2d', 1, 1, '2016-03-29 19:22:53', '2016-03-29 19:22:37.815299', '2016-03-29 19:22:37.815299', 94489280512, 6, 1000000000000000000, 3400, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (23, 'abf16cb6b5c11660172090088ab0d2c2d7feae914908b352b260f07855f45778', '4135480624af9ec6d7a58de50ce23d6662b1ed4158cea4ff708de0471eabad0b', 1, 1, '2016-03-29 19:22:54', '2016-03-29 19:22:37.819782', '2016-03-29 19:22:37.819782', 98784247808, 6, 1000000000000000000, 3500, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (24, 'c57bdabe04d5dacd49b2387810548e916c4218dcec0336f3bf3d1ea8c64619ce', 'abf16cb6b5c11660172090088ab0d2c2d7feae914908b352b260f07855f45778', 1, 1, '2016-03-29 19:22:55', '2016-03-29 19:22:37.824545', '2016-03-29 19:22:37.824545', 103079215104, 6, 1000000000000000000, 3600, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (25, '388463897f362ef57536f0c1d09e3ff6d25d4c7cc7c31f353dde454838e014f9', 'c57bdabe04d5dacd49b2387810548e916c4218dcec0336f3bf3d1ea8c64619ce', 1, 1, '2016-03-29 19:22:56', '2016-03-29 19:22:37.830918', '2016-03-29 19:22:37.830918', 107374182400, 6, 1000000000000000000, 3700, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (26, '450128f08555807eb360f5a048f0a0db1db2a74107d392bc707ac3c59a2c5939', '388463897f362ef57536f0c1d09e3ff6d25d4c7cc7c31f353dde454838e014f9', 2, 2, '2016-03-29 19:22:57', '2016-03-29 19:22:37.836548', '2016-03-29 19:22:37.836548', 111669149696, 6, 1000000000000000000, 3900, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (27, '30993d4463716eee75d2a6a0018340616655ba51b00e65e77af3c321de12b247', '450128f08555807eb360f5a048f0a0db1db2a74107d392bc707ac3c59a2c5939', 1, 1, '2016-03-29 19:22:58', '2016-03-29 19:22:37.841553', '2016-03-29 19:22:37.841553', 115964116992, 6, 1000000000000000000, 4000, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (28, '05441337cd611db98d3e490034570a6c38c02f990f99dc4c0fb4793c2cc4fbb2', '30993d4463716eee75d2a6a0018340616655ba51b00e65e77af3c321de12b247', 7, 7, '2016-03-29 19:22:59', '2016-03-29 19:22:37.84726', '2016-03-29 19:22:37.84726', 120259084288, 6, 1000000000000000000, 4700, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (29, '038ae33675803bb13241f88aedd2d59353ac90d8882996b6a653d19a837ef169', '05441337cd611db98d3e490034570a6c38c02f990f99dc4c0fb4793c2cc4fbb2', 1, 1, '2016-03-29 19:23:00', '2016-03-29 19:22:37.859812', '2016-03-29 19:22:37.859813', 124554051584, 6, 1000000000000000000, 4800, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (30, '1a24081cc99fe78dea70e5c0631d620283928928bed638d8a5ef657bb824b065', '038ae33675803bb13241f88aedd2d59353ac90d8882996b6a653d19a837ef169', 1, 1, '2016-03-29 19:23:01', '2016-03-29 19:22:37.86436', '2016-03-29 19:22:37.86436', 128849018880, 6, 1000000000000000000, 4900, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (31, 'e79dcb41a11b40ba675e095c5d398d9f3a304863850edb672c881b829aeda4ab', '1a24081cc99fe78dea70e5c0631d620283928928bed638d8a5ef657bb824b065', 1, 1, '2016-03-29 19:23:02', '2016-03-29 19:22:37.868685', '2016-03-29 19:22:37.868685', 133143986176, 6, 1000000000000000000, 5000, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (32, '3c33aebf7bd9f67d047f037274b7c152a52d6eed083a58ec40689a405142779a', 'e79dcb41a11b40ba675e095c5d398d9f3a304863850edb672c881b829aeda4ab', 2, 2, '2016-03-29 19:23:03', '2016-03-29 19:22:37.873201', '2016-03-29 19:22:37.873201', 137438953472, 6, 1000000000000000000, 5200, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (33, '9550609c3eec2e2be7d2bcc820359fd64c3207f137a05ea9af40ee9b4d1d7d1f', '3c33aebf7bd9f67d047f037274b7c152a52d6eed083a58ec40689a405142779a', 1, 1, '2016-03-29 19:23:04', '2016-03-29 19:22:37.879859', '2016-03-29 19:22:37.879859', 141733920768, 6, 1000000000000000000, 5300, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (34, '8e6b44410fbdd863645e0ce464baa3624718f289ed790c5edbd90a53fbdec2ae', '9550609c3eec2e2be7d2bcc820359fd64c3207f137a05ea9af40ee9b4d1d7d1f', 1, 1, '2016-03-29 19:23:05', '2016-03-29 19:22:37.885218', '2016-03-29 19:22:37.885218', 146028888064, 6, 1000000000000000000, 5400, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (35, '0c7b3fd1b42e4716b3f885ead79427675647d0f958749fd337902f93c2bd2340', '8e6b44410fbdd863645e0ce464baa3624718f289ed790c5edbd90a53fbdec2ae', 1, 1, '2016-03-29 19:23:06', '2016-03-29 19:22:37.889895', '2016-03-29 19:22:37.889895', 150323855360, 6, 1000000000000000000, 5500, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (36, '92780c0b3a27a89acf831bda9a316b9f3e84a9a37ec350b76043fe21758dcb01', '0c7b3fd1b42e4716b3f885ead79427675647d0f958749fd337902f93c2bd2340', 1, 1, '2016-03-29 19:23:07', '2016-03-29 19:22:37.894136', '2016-03-29 19:22:37.894136', 154618822656, 6, 1000000000000000000, 5600, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (37, '7648c1c4a4da97ea4f935f589fda3f5124d2785bdac0e79b9d837971ee0cf95e', '92780c0b3a27a89acf831bda9a316b9f3e84a9a37ec350b76043fe21758dcb01', 1, 1, '2016-03-29 19:23:08', '2016-03-29 19:22:37.898605', '2016-03-29 19:22:37.898605', 158913789952, 6, 1000000000000000000, 5700, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (38, '1611ccd411f703d96cc90c3d87242a27a9eee105c57a79b54d55fa963397e29d', '7648c1c4a4da97ea4f935f589fda3f5124d2785bdac0e79b9d837971ee0cf95e', 2, 2, '2016-03-29 19:23:09', '2016-03-29 19:22:37.902855', '2016-03-29 19:22:37.902855', 163208757248, 6, 1000000000000000000, 5900, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (39, '8617fc494e86da4d7b454c1d20e119e0ddb17771d48276615a2fbd699a6f0cd1', '1611ccd411f703d96cc90c3d87242a27a9eee105c57a79b54d55fa963397e29d', 1, 1, '2016-03-29 19:23:10', '2016-03-29 19:22:37.910641', '2016-03-29 19:22:37.910641', 167503724544, 6, 1000000000000000000, 6000, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (40, '8a4206642a7f3205f371141a3f14ee1cc0939f6cc790a544c964c5ef93897151', '8617fc494e86da4d7b454c1d20e119e0ddb17771d48276615a2fbd699a6f0cd1', 2, 2, '2016-03-29 19:23:11', '2016-03-29 19:22:37.915147', '2016-03-29 19:22:37.915147', 171798691840, 6, 1000000000000000000, 6200, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (41, 'fc75ce267307c0543f6d093a636df209ba422f5f25c3376c536a580f6b4d0a10', '8a4206642a7f3205f371141a3f14ee1cc0939f6cc790a544c964c5ef93897151', 2, 2, '2016-03-29 19:23:12', '2016-03-29 19:22:37.921762', '2016-03-29 19:22:37.921762', 176093659136, 6, 1000000000000000000, 6400, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (42, '4b8beb620c95421874a9618d193cccf900fede624250c59f4b6dc2ce6ca3ee96', 'fc75ce267307c0543f6d093a636df209ba422f5f25c3376c536a580f6b4d0a10', 1, 1, '2016-03-29 19:23:13', '2016-03-29 19:22:37.927218', '2016-03-29 19:22:37.927218', 180388626432, 6, 1000000000000000000, 6500, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (43, '43852cfca7b3685279283b0039ec4f9589f9078a762fb043ec2bf2a42404f969', '4b8beb620c95421874a9618d193cccf900fede624250c59f4b6dc2ce6ca3ee96', 1, 1, '2016-03-29 19:23:14', '2016-03-29 19:22:37.931546', '2016-03-29 19:22:37.931546', 184683593728, 6, 1000000000000000000, 6600, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (44, 'b8f0f030ad66e3c8f9a65cc87d088ea6e509061421ed7cedfa92d7e8b1257c9d', '43852cfca7b3685279283b0039ec4f9589f9078a762fb043ec2bf2a42404f969', 1, 1, '2016-03-29 19:23:15', '2016-03-29 19:22:37.936737', '2016-03-29 19:22:37.936737', 188978561024, 6, 1000000000000000000, 6700, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (45, '7da7a9c3f3eba23b29c875f1d61c6e36647a3ddcf23c7f940d6d7881ef2ecc0e', 'b8f0f030ad66e3c8f9a65cc87d088ea6e509061421ed7cedfa92d7e8b1257c9d', 1, 1, '2016-03-29 19:23:16', '2016-03-29 19:22:37.941379', '2016-03-29 19:22:37.941379', 193273528320, 6, 1000000000000000000, 190721000006800, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (46, '6742c6569355ea0c18405258e3be9fddea5f14010e05e6e144535f777069afcb', '7da7a9c3f3eba23b29c875f1d61c6e36647a3ddcf23c7f940d6d7881ef2ecc0e', 1, 1, '2016-03-29 19:23:17', '2016-03-29 19:22:37.945277', '2016-03-29 19:22:37.945277', 197568495616, 6, 1000000000000000000, 190721000006900, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (47, '12a6eb12634d1e9c9f9d6a9abcbf085c39ea96d315bcf8770802a3b17bc57191', '6742c6569355ea0c18405258e3be9fddea5f14010e05e6e144535f777069afcb', 2, 2, '2016-03-29 19:23:18', '2016-03-29 19:22:37.950527', '2016-03-29 19:22:37.950527', 201863462912, 6, 1000000000000000000, 190721000007100, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (48, '08685c4ac514234c86b1be74a9a6e8d27940bffc89ee80fe0ec5e1d50195fb72', '12a6eb12634d1e9c9f9d6a9abcbf085c39ea96d315bcf8770802a3b17bc57191', 1, 1, '2016-03-29 19:23:19', '2016-03-29 19:22:37.95582', '2016-03-29 19:22:37.95582', 206158430208, 6, 1000000000000000000, 190721000007200, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (49, '2ccd4a2c45a6fe904a527ef90e551135cac750d3c51d2325e8478fd74516f085', '08685c4ac514234c86b1be74a9a6e8d27940bffc89ee80fe0ec5e1d50195fb72', 2, 2, '2016-03-29 19:23:20', '2016-03-29 19:22:37.961345', '2016-03-29 19:22:37.961345', 210453397504, 6, 1000000000000000000, 190721000007400, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (50, 'f11ba91d124b26b0a019061cfa70d7f6e09ba430457217b7a93ae7ba8293f068', '2ccd4a2c45a6fe904a527ef90e551135cac750d3c51d2325e8478fd74516f085', 1, 1, '2016-03-29 19:23:21', '2016-03-29 19:22:37.966275', '2016-03-29 19:22:37.966275', 214748364800, 6, 1000000000000000000, 190721000007500, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (51, '046796b5702d71714f0e1a56bdcafd5809cdc479c7106ca74f78c2027b2839fb', 'f11ba91d124b26b0a019061cfa70d7f6e09ba430457217b7a93ae7ba8293f068', 1, 1, '2016-03-29 19:23:22', '2016-03-29 19:22:37.970201', '2016-03-29 19:22:37.970201', 219043332096, 6, 1000000000000000000, 190721000007600, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (52, 'cac2270e4cd8a84c9399c64edb4b9bb77f51611ebe9988f795352af1f12e3331', '046796b5702d71714f0e1a56bdcafd5809cdc479c7106ca74f78c2027b2839fb', 1, 1, '2016-03-29 19:23:23', '2016-03-29 19:22:37.974361', '2016-03-29 19:22:37.974361', 223338299392, 6, 1000000000000000000, 190721000007700, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (53, '866fbb046e6b67b59dc1b671e1396fc3a03cc276dc2524cb2c4865c9c72023a2', 'cac2270e4cd8a84c9399c64edb4b9bb77f51611ebe9988f795352af1f12e3331', 1, 1, '2016-03-29 19:23:24', '2016-03-29 19:22:37.978637', '2016-03-29 19:22:37.978637', 227633266688, 6, 1000000000000000000, 190721000007800, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (54, 'f900b300a8732e343b983cb4b124a675a9851d9591115aee6e11659c0974b690', '866fbb046e6b67b59dc1b671e1396fc3a03cc276dc2524cb2c4865c9c72023a2', 1, 2, '2016-03-29 19:23:25', '2016-03-29 19:22:37.984116', '2016-03-29 19:22:37.984116', 231928233984, 6, 1000000000000000000, 190721000008000, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (55, '32c7dbcedab5f1e498bed807a6773fbeaffe880b8065b236951bf7a496329c9e', 'f900b300a8732e343b983cb4b124a675a9851d9591115aee6e11659c0974b690', 1, 1, '2016-03-29 19:23:26', '2016-03-29 19:22:37.989444', '2016-03-29 19:22:37.989444', 236223201280, 6, 1000000000000000000, 190721000008100, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (56, 'c9a3763360ed6196e359925702e4076889a6d75b30cf64d16e3fef3435f130f9', '32c7dbcedab5f1e498bed807a6773fbeaffe880b8065b236951bf7a496329c9e', 1, 1, '2016-03-29 19:23:27', '2016-03-29 19:22:37.994639', '2016-03-29 19:22:37.994639', 240518168576, 6, 1000000000000000000, 190721000008200, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (57, 'e37c967e32080f67a7202b0e32e85d4450fce6c74fd5796ff0e961e57aad62d3', 'c9a3763360ed6196e359925702e4076889a6d75b30cf64d16e3fef3435f130f9', 0, 0, '2016-03-29 19:23:28', '2016-03-29 19:22:37.998948', '2016-03-29 19:22:37.998948', 244813135872, 6, 1000000000000000000, 190721000008200, 100, 100000000, 10000);


--
-- Data for Name: history_operation_participants; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO history_operation_participants VALUES (1, 12884905985, 1);
INSERT INTO history_operation_participants VALUES (2, 12884905985, 12884905985);
INSERT INTO history_operation_participants VALUES (3, 17179873281, 1);
INSERT INTO history_operation_participants VALUES (4, 17179873281, 17179873281);
INSERT INTO history_operation_participants VALUES (5, 21474840577, 17179873281);
INSERT INTO history_operation_participants VALUES (6, 21474844673, 17179873281);
INSERT INTO history_operation_participants VALUES (7, 21474848769, 17179873281);
INSERT INTO history_operation_participants VALUES (8, 25769807873, 17179873281);
INSERT INTO history_operation_participants VALUES (9, 30064775169, 1);
INSERT INTO history_operation_participants VALUES (10, 30064775169, 30064775169);
INSERT INTO history_operation_participants VALUES (11, 34359742465, 30064775169);
INSERT INTO history_operation_participants VALUES (12, 34359742465, 1);
INSERT INTO history_operation_participants VALUES (13, 34359746561, 30064775169);
INSERT INTO history_operation_participants VALUES (14, 34359746561, 1);
INSERT INTO history_operation_participants VALUES (15, 34359750657, 30064775169);
INSERT INTO history_operation_participants VALUES (16, 34359750657, 1);
INSERT INTO history_operation_participants VALUES (17, 34359754753, 30064775169);
INSERT INTO history_operation_participants VALUES (18, 34359754753, 1);
INSERT INTO history_operation_participants VALUES (19, 38654709761, 1);
INSERT INTO history_operation_participants VALUES (20, 38654709761, 38654709761);
INSERT INTO history_operation_participants VALUES (21, 42949677057, 38654709761);
INSERT INTO history_operation_participants VALUES (22, 42949677057, 1);
INSERT INTO history_operation_participants VALUES (23, 42949677058, 38654709761);
INSERT INTO history_operation_participants VALUES (24, 42949677058, 1);
INSERT INTO history_operation_participants VALUES (25, 47244644353, 1);
INSERT INTO history_operation_participants VALUES (26, 47244644353, 47244644353);
INSERT INTO history_operation_participants VALUES (27, 51539611649, 47244644353);
INSERT INTO history_operation_participants VALUES (28, 51539611649, 51539611649);
INSERT INTO history_operation_participants VALUES (29, 55834578945, 1);
INSERT INTO history_operation_participants VALUES (30, 55834578945, 55834578945);
INSERT INTO history_operation_participants VALUES (31, 55834583041, 1);
INSERT INTO history_operation_participants VALUES (32, 55834583041, 55834583041);
INSERT INTO history_operation_participants VALUES (33, 60129546241, 55834578945);
INSERT INTO history_operation_participants VALUES (34, 60129546241, 55834583041);
INSERT INTO history_operation_participants VALUES (35, 60129550337, 55834583041);
INSERT INTO history_operation_participants VALUES (36, 64424513537, 55834578945);
INSERT INTO history_operation_participants VALUES (37, 64424513537, 55834583041);
INSERT INTO history_operation_participants VALUES (38, 68719480833, 1);
INSERT INTO history_operation_participants VALUES (39, 68719480833, 68719480833);
INSERT INTO history_operation_participants VALUES (40, 68719484929, 1);
INSERT INTO history_operation_participants VALUES (41, 68719484929, 68719484929);
INSERT INTO history_operation_participants VALUES (42, 68719489025, 1);
INSERT INTO history_operation_participants VALUES (43, 68719489025, 68719489025);
INSERT INTO history_operation_participants VALUES (44, 73014448129, 68719484929);
INSERT INTO history_operation_participants VALUES (45, 73014452225, 68719480833);
INSERT INTO history_operation_participants VALUES (46, 77309415425, 68719489025);
INSERT INTO history_operation_participants VALUES (47, 77309415425, 68719480833);
INSERT INTO history_operation_participants VALUES (48, 77309419521, 68719489025);
INSERT INTO history_operation_participants VALUES (49, 77309423617, 68719489025);
INSERT INTO history_operation_participants VALUES (50, 81604382721, 68719480833);
INSERT INTO history_operation_participants VALUES (51, 81604382721, 68719484929);
INSERT INTO history_operation_participants VALUES (52, 85899350017, 68719480833);
INSERT INTO history_operation_participants VALUES (53, 85899350017, 68719484929);
INSERT INTO history_operation_participants VALUES (54, 90194317313, 1);
INSERT INTO history_operation_participants VALUES (55, 90194317313, 90194317313);
INSERT INTO history_operation_participants VALUES (56, 90194321409, 1);
INSERT INTO history_operation_participants VALUES (57, 90194321409, 90194321409);
INSERT INTO history_operation_participants VALUES (58, 94489284609, 90194317313);
INSERT INTO history_operation_participants VALUES (59, 98784251905, 90194317313);
INSERT INTO history_operation_participants VALUES (60, 103079219201, 90194321409);
INSERT INTO history_operation_participants VALUES (61, 107374186497, 1);
INSERT INTO history_operation_participants VALUES (62, 107374186497, 107374186497);
INSERT INTO history_operation_participants VALUES (63, 111669153793, 107374186497);
INSERT INTO history_operation_participants VALUES (64, 111669157889, 107374186497);
INSERT INTO history_operation_participants VALUES (65, 115964121089, 1);
INSERT INTO history_operation_participants VALUES (66, 115964121089, 115964121089);
INSERT INTO history_operation_participants VALUES (67, 120259088385, 115964121089);
INSERT INTO history_operation_participants VALUES (68, 120259092481, 115964121089);
INSERT INTO history_operation_participants VALUES (69, 120259096577, 115964121089);
INSERT INTO history_operation_participants VALUES (70, 120259100673, 115964121089);
INSERT INTO history_operation_participants VALUES (71, 120259104769, 115964121089);
INSERT INTO history_operation_participants VALUES (72, 120259108865, 115964121089);
INSERT INTO history_operation_participants VALUES (73, 120259112961, 115964121089);
INSERT INTO history_operation_participants VALUES (74, 124554055681, 115964121089);
INSERT INTO history_operation_participants VALUES (75, 128849022977, 115964121089);
INSERT INTO history_operation_participants VALUES (76, 133143990273, 115964121089);
INSERT INTO history_operation_participants VALUES (77, 137438957569, 115964121089);
INSERT INTO history_operation_participants VALUES (78, 137438961665, 115964121089);
INSERT INTO history_operation_participants VALUES (79, 141733924865, 1);
INSERT INTO history_operation_participants VALUES (80, 141733924865, 141733924865);
INSERT INTO history_operation_participants VALUES (81, 146028892161, 141733924865);
INSERT INTO history_operation_participants VALUES (82, 150323859457, 141733924865);
INSERT INTO history_operation_participants VALUES (83, 154618826753, 141733924865);
INSERT INTO history_operation_participants VALUES (84, 158913794049, 141733924865);
INSERT INTO history_operation_participants VALUES (85, 163208761345, 1);
INSERT INTO history_operation_participants VALUES (86, 163208761345, 163208761345);
INSERT INTO history_operation_participants VALUES (87, 163208765441, 1);
INSERT INTO history_operation_participants VALUES (88, 163208765441, 163208765441);
INSERT INTO history_operation_participants VALUES (89, 167503728641, 163208765441);
INSERT INTO history_operation_participants VALUES (90, 171798695937, 163208761345);
INSERT INTO history_operation_participants VALUES (91, 171798700033, 163208761345);
INSERT INTO history_operation_participants VALUES (92, 176093663233, 163208765441);
INSERT INTO history_operation_participants VALUES (93, 176093663233, 163208761345);
INSERT INTO history_operation_participants VALUES (94, 176093667329, 163208765441);
INSERT INTO history_operation_participants VALUES (95, 176093667329, 163208761345);
INSERT INTO history_operation_participants VALUES (96, 180388630529, 163208765441);
INSERT INTO history_operation_participants VALUES (97, 180388630529, 163208761345);
INSERT INTO history_operation_participants VALUES (98, 184683597825, 1);
INSERT INTO history_operation_participants VALUES (99, 184683597825, 184683597825);
INSERT INTO history_operation_participants VALUES (100, 188978565121, 184683597825);
INSERT INTO history_operation_participants VALUES (101, 188978565121, 1);
INSERT INTO history_operation_participants VALUES (102, 193273532417, 1);
INSERT INTO history_operation_participants VALUES (103, 197568499713, 1);
INSERT INTO history_operation_participants VALUES (104, 197568499713, 197568499713);
INSERT INTO history_operation_participants VALUES (105, 201863467009, 197568499713);
INSERT INTO history_operation_participants VALUES (106, 201863471105, 1);
INSERT INTO history_operation_participants VALUES (107, 206158434305, 1);
INSERT INTO history_operation_participants VALUES (108, 206158434305, 206158434305);
INSERT INTO history_operation_participants VALUES (109, 210453401601, 206158434305);
INSERT INTO history_operation_participants VALUES (110, 210453405697, 206158434305);
INSERT INTO history_operation_participants VALUES (111, 214748368897, 206158434305);
INSERT INTO history_operation_participants VALUES (112, 219043336193, 206158434305);
INSERT INTO history_operation_participants VALUES (113, 223338303489, 206158434305);
INSERT INTO history_operation_participants VALUES (114, 227633270785, 1);
INSERT INTO history_operation_participants VALUES (115, 227633270785, 227633270785);
INSERT INTO history_operation_participants VALUES (116, 231928238081, 1);
INSERT INTO history_operation_participants VALUES (117, 231928238081, 227633270785);
INSERT INTO history_operation_participants VALUES (118, 231928238082, 227633270785);
INSERT INTO history_operation_participants VALUES (119, 231928238082, 1);
INSERT INTO history_operation_participants VALUES (120, 236223205377, 1);
INSERT INTO history_operation_participants VALUES (121, 236223205377, 236223205377);
INSERT INTO history_operation_participants VALUES (122, 240518172673, 236223205377);


--
-- Name: history_operation_participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('history_operation_participants_id_seq', 122, true);


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
INSERT INTO history_operations VALUES (60129546241, 60129546240, 1, 1, '{"to": "GANZGPKY5WSHWG5YOZMNG52GCK5SCJ4YGUWMJJVGZSK2FP4BI2JIJN2C", "from": "GCHC4D2CS45CJRNN4QAHT2LFZAJIU5PA7H53K3VOP6WEJ6XWHNSNZKQG", "amount": "10.0000000", "asset_type": "native"}', 'GCHC4D2CS45CJRNN4QAHT2LFZAJIU5PA7H53K3VOP6WEJ6XWHNSNZKQG');
INSERT INTO history_operations VALUES (60129550337, 60129550336, 1, 6, '{"limit": "922337203685.4775807", "trustee": "GCHC4D2CS45CJRNN4QAHT2LFZAJIU5PA7H53K3VOP6WEJ6XWHNSNZKQG", "trustor": "GANZGPKY5WSHWG5YOZMNG52GCK5SCJ4YGUWMJJVGZSK2FP4BI2JIJN2C", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GCHC4D2CS45CJRNN4QAHT2LFZAJIU5PA7H53K3VOP6WEJ6XWHNSNZKQG"}', 'GANZGPKY5WSHWG5YOZMNG52GCK5SCJ4YGUWMJJVGZSK2FP4BI2JIJN2C');
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
INSERT INTO history_operations VALUES (193273532417, 193273532416, 1, 9, '{}', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_operations VALUES (197568499713, 197568499712, 1, 0, '{"funder": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "account": "GDR53WAEIKOU3ZKN34CSHAWH7HV6K63CBJRUTWUDBFSMY7RRQK3SPKOS", "starting_balance": "2000000000.0000000"}', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_operations VALUES (201863467009, 201863467008, 1, 5, '{"inflation_dest": "GDR53WAEIKOU3ZKN34CSHAWH7HV6K63CBJRUTWUDBFSMY7RRQK3SPKOS"}', 'GDR53WAEIKOU3ZKN34CSHAWH7HV6K63CBJRUTWUDBFSMY7RRQK3SPKOS');
INSERT INTO history_operations VALUES (201863471105, 201863471104, 1, 5, '{"inflation_dest": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H"}', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
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


--
-- Data for Name: history_transaction_participants; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO history_transaction_participants VALUES (1, 12884905984, 1);
INSERT INTO history_transaction_participants VALUES (2, 12884905984, 12884905985);
INSERT INTO history_transaction_participants VALUES (3, 17179873280, 1);
INSERT INTO history_transaction_participants VALUES (4, 17179873280, 17179873281);
INSERT INTO history_transaction_participants VALUES (5, 21474840576, 17179873281);
INSERT INTO history_transaction_participants VALUES (6, 21474844672, 17179873281);
INSERT INTO history_transaction_participants VALUES (7, 21474848768, 17179873281);
INSERT INTO history_transaction_participants VALUES (8, 25769807872, 17179873281);
INSERT INTO history_transaction_participants VALUES (9, 30064775168, 1);
INSERT INTO history_transaction_participants VALUES (10, 30064775168, 30064775169);
INSERT INTO history_transaction_participants VALUES (11, 34359742464, 30064775169);
INSERT INTO history_transaction_participants VALUES (12, 34359742464, 1);
INSERT INTO history_transaction_participants VALUES (13, 34359746560, 30064775169);
INSERT INTO history_transaction_participants VALUES (14, 34359746560, 1);
INSERT INTO history_transaction_participants VALUES (15, 34359750656, 30064775169);
INSERT INTO history_transaction_participants VALUES (16, 34359750656, 1);
INSERT INTO history_transaction_participants VALUES (17, 34359754752, 30064775169);
INSERT INTO history_transaction_participants VALUES (18, 34359754752, 1);
INSERT INTO history_transaction_participants VALUES (19, 38654709760, 1);
INSERT INTO history_transaction_participants VALUES (20, 38654709760, 38654709761);
INSERT INTO history_transaction_participants VALUES (21, 42949677056, 38654709761);
INSERT INTO history_transaction_participants VALUES (22, 42949677056, 1);
INSERT INTO history_transaction_participants VALUES (23, 47244644352, 1);
INSERT INTO history_transaction_participants VALUES (24, 47244644352, 47244644353);
INSERT INTO history_transaction_participants VALUES (25, 51539611648, 47244644353);
INSERT INTO history_transaction_participants VALUES (26, 51539611648, 51539611649);
INSERT INTO history_transaction_participants VALUES (27, 55834578944, 1);
INSERT INTO history_transaction_participants VALUES (28, 55834578944, 55834578945);
INSERT INTO history_transaction_participants VALUES (29, 55834583040, 1);
INSERT INTO history_transaction_participants VALUES (30, 55834583040, 55834583041);
INSERT INTO history_transaction_participants VALUES (31, 60129546240, 55834578945);
INSERT INTO history_transaction_participants VALUES (32, 60129546240, 55834583041);
INSERT INTO history_transaction_participants VALUES (33, 60129550336, 55834583041);
INSERT INTO history_transaction_participants VALUES (34, 64424513536, 55834578945);
INSERT INTO history_transaction_participants VALUES (35, 64424513536, 55834583041);
INSERT INTO history_transaction_participants VALUES (36, 68719480832, 1);
INSERT INTO history_transaction_participants VALUES (37, 68719480832, 68719480833);
INSERT INTO history_transaction_participants VALUES (38, 68719484928, 1);
INSERT INTO history_transaction_participants VALUES (39, 68719484928, 68719484929);
INSERT INTO history_transaction_participants VALUES (40, 68719489024, 1);
INSERT INTO history_transaction_participants VALUES (41, 68719489024, 68719489025);
INSERT INTO history_transaction_participants VALUES (42, 73014448128, 68719484929);
INSERT INTO history_transaction_participants VALUES (43, 73014452224, 68719480833);
INSERT INTO history_transaction_participants VALUES (44, 77309415424, 68719489025);
INSERT INTO history_transaction_participants VALUES (45, 77309415424, 68719480833);
INSERT INTO history_transaction_participants VALUES (46, 77309419520, 68719489025);
INSERT INTO history_transaction_participants VALUES (47, 77309423616, 68719489025);
INSERT INTO history_transaction_participants VALUES (48, 81604382720, 68719480833);
INSERT INTO history_transaction_participants VALUES (49, 81604382720, 68719489025);
INSERT INTO history_transaction_participants VALUES (50, 81604382720, 68719484929);
INSERT INTO history_transaction_participants VALUES (51, 85899350016, 68719480833);
INSERT INTO history_transaction_participants VALUES (52, 85899350016, 68719489025);
INSERT INTO history_transaction_participants VALUES (53, 85899350016, 68719484929);
INSERT INTO history_transaction_participants VALUES (54, 90194317312, 1);
INSERT INTO history_transaction_participants VALUES (55, 90194317312, 90194317313);
INSERT INTO history_transaction_participants VALUES (56, 90194321408, 1);
INSERT INTO history_transaction_participants VALUES (57, 90194321408, 90194321409);
INSERT INTO history_transaction_participants VALUES (58, 94489284608, 90194317313);
INSERT INTO history_transaction_participants VALUES (59, 98784251904, 90194317313);
INSERT INTO history_transaction_participants VALUES (60, 103079219200, 90194321409);
INSERT INTO history_transaction_participants VALUES (61, 103079219200, 90194317313);
INSERT INTO history_transaction_participants VALUES (62, 107374186496, 1);
INSERT INTO history_transaction_participants VALUES (63, 107374186496, 107374186497);
INSERT INTO history_transaction_participants VALUES (64, 111669153792, 107374186497);
INSERT INTO history_transaction_participants VALUES (65, 111669157888, 107374186497);
INSERT INTO history_transaction_participants VALUES (66, 115964121088, 1);
INSERT INTO history_transaction_participants VALUES (67, 115964121088, 115964121089);
INSERT INTO history_transaction_participants VALUES (68, 120259088384, 115964121089);
INSERT INTO history_transaction_participants VALUES (69, 120259092480, 115964121089);
INSERT INTO history_transaction_participants VALUES (70, 120259096576, 115964121089);
INSERT INTO history_transaction_participants VALUES (71, 120259100672, 115964121089);
INSERT INTO history_transaction_participants VALUES (72, 120259104768, 115964121089);
INSERT INTO history_transaction_participants VALUES (73, 120259108864, 115964121089);
INSERT INTO history_transaction_participants VALUES (74, 120259112960, 115964121089);
INSERT INTO history_transaction_participants VALUES (75, 124554055680, 115964121089);
INSERT INTO history_transaction_participants VALUES (76, 128849022976, 115964121089);
INSERT INTO history_transaction_participants VALUES (77, 133143990272, 115964121089);
INSERT INTO history_transaction_participants VALUES (78, 137438957568, 115964121089);
INSERT INTO history_transaction_participants VALUES (79, 137438961664, 115964121089);
INSERT INTO history_transaction_participants VALUES (80, 141733924864, 1);
INSERT INTO history_transaction_participants VALUES (81, 141733924864, 141733924865);
INSERT INTO history_transaction_participants VALUES (82, 146028892160, 141733924865);
INSERT INTO history_transaction_participants VALUES (83, 150323859456, 141733924865);
INSERT INTO history_transaction_participants VALUES (84, 154618826752, 141733924865);
INSERT INTO history_transaction_participants VALUES (85, 158913794048, 141733924865);
INSERT INTO history_transaction_participants VALUES (86, 163208761344, 1);
INSERT INTO history_transaction_participants VALUES (87, 163208761344, 163208761345);
INSERT INTO history_transaction_participants VALUES (88, 163208765440, 1);
INSERT INTO history_transaction_participants VALUES (89, 163208765440, 163208765441);
INSERT INTO history_transaction_participants VALUES (90, 167503728640, 163208765441);
INSERT INTO history_transaction_participants VALUES (91, 171798695936, 163208761345);
INSERT INTO history_transaction_participants VALUES (92, 171798700032, 163208761345);
INSERT INTO history_transaction_participants VALUES (93, 176093663232, 163208765441);
INSERT INTO history_transaction_participants VALUES (94, 176093663232, 163208761345);
INSERT INTO history_transaction_participants VALUES (95, 176093667328, 163208765441);
INSERT INTO history_transaction_participants VALUES (96, 176093667328, 163208761345);
INSERT INTO history_transaction_participants VALUES (97, 180388630528, 163208765441);
INSERT INTO history_transaction_participants VALUES (98, 180388630528, 163208761345);
INSERT INTO history_transaction_participants VALUES (99, 184683597824, 1);
INSERT INTO history_transaction_participants VALUES (100, 184683597824, 184683597825);
INSERT INTO history_transaction_participants VALUES (101, 188978565120, 184683597825);
INSERT INTO history_transaction_participants VALUES (102, 188978565120, 1);
INSERT INTO history_transaction_participants VALUES (103, 193273532416, 1);
INSERT INTO history_transaction_participants VALUES (104, 197568499712, 1);
INSERT INTO history_transaction_participants VALUES (105, 197568499712, 197568499713);
INSERT INTO history_transaction_participants VALUES (106, 201863467008, 197568499713);
INSERT INTO history_transaction_participants VALUES (107, 201863471104, 1);
INSERT INTO history_transaction_participants VALUES (108, 206158434304, 1);
INSERT INTO history_transaction_participants VALUES (109, 206158434304, 206158434305);
INSERT INTO history_transaction_participants VALUES (110, 210453401600, 206158434305);
INSERT INTO history_transaction_participants VALUES (111, 210453405696, 206158434305);
INSERT INTO history_transaction_participants VALUES (112, 214748368896, 206158434305);
INSERT INTO history_transaction_participants VALUES (113, 219043336192, 206158434305);
INSERT INTO history_transaction_participants VALUES (114, 223338303488, 206158434305);
INSERT INTO history_transaction_participants VALUES (115, 227633270784, 1);
INSERT INTO history_transaction_participants VALUES (116, 227633270784, 227633270785);
INSERT INTO history_transaction_participants VALUES (117, 231928238080, 1);
INSERT INTO history_transaction_participants VALUES (118, 231928238080, 227633270785);
INSERT INTO history_transaction_participants VALUES (119, 236223205376, 1);
INSERT INTO history_transaction_participants VALUES (120, 236223205376, 236223205377);
INSERT INTO history_transaction_participants VALUES (121, 240518172672, 236223205377);


--
-- Name: history_transaction_participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('history_transaction_participants_id_seq', 121, true);


--
-- Data for Name: history_transactions; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO history_transactions VALUES ('f5e0d1f500b2d0c4b42fb8a438d5ed764bc58d1392f4328f4713af407b1968ca', 3, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 1, 100, 1, '2016-03-29 19:22:37.688844', '2016-03-29 19:22:37.688844', 12884905984, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAABAAAAAQAAAAAAAABkAAAAAF4MUYAAAAAAAAAAAQAAAAAAAAAAAAAAAC6N7oJcJiUzTWRDL98Bj3fVrJUB19wFvCzEHh8nn/IOAAAAAlQL5AAAAAAAAAAAAVb8BfcAAABAXK6PX0t3GL+4TcNTKBIB9vkqahUMix+Rf/7WY5d6YJsmeBQ+o5ULJWvzgfc3aTx4f/DCUXc54KcOfCfzqH0uDQ==', '9eDR9QCy0MS0L7ikONXtdkvFjROS9DKPRxOvQHsZaMoAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAAAMAAAAAAAAAAC6N7oJcJiUzTWRDL98Bj3fVrJUB19wFvCzEHh8nn/IOAAAAAlQL5AAAAAADAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAMAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2sVNYG5wAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAABAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnZAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAADAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnY/+cAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{XK6PX0t3GL+4TcNTKBIB9vkqahUMix+Rf/7WY5d6YJsmeBQ+o5ULJWvzgfc3aTx4f/DCUXc54KcOfCfzqH0uDQ==}', 'none', NULL, '[100,1577865601)');
INSERT INTO history_transactions VALUES ('66e27fb28870cb5256ea92764bcb222adbbaa5fec2d89a62a9aa8c9c8e2ee9e9', 4, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 2, 100, 1, '2016-03-29 19:22:37.696511', '2016-03-29 19:22:37.696511', 17179873280, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAACAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAA7lAZIpCRwStYOr2IrB6aiXLG/wsNVkHBYtBKJinuINUAAAACVAvkAAAAAAAAAAABVvwF9wAAAECAUpO+hxiga/YgRsV3rFpBJydgOyn0TPImJCaQCMikkiG+sNXrQBsYXjJrlOiGjGsU3rk4uvGl85AriYD9PNYH', 'ZuJ/sohwy1JW6pJ2S8siKtu6pf7C2JpiqaqMnI4u6ekAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAAAQAAAAAAAAAAO5QGSKQkcErWDq9iKwemolyxv8LDVZBwWLQSiYp7iDVAAAAAlQL5AAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAQAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2rv9MNzgAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAADAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrFTWBucAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAEAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrFTWBs4AAAAAAAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{gFKTvocYoGv2IEbFd6xaQScnYDsp9EzyJiQmkAjIpJIhvrDV60AbGF4ya5TohoxrFN65OLrxpfOQK4mA/TzWBw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('e9d1a3000aea36743142f2ede106d3cb37c3d7e88508e3f21b496370b5863858', 5, 1, 'GDXFAGJCSCI4CK2YHK6YRLA6TKEXFRX7BMGVMQOBMLIEUJRJ5YQNLMIB', 17179869185, 100, 1, '2016-03-29 19:22:37.702108', '2016-03-29 19:22:37.702108', 21474840576, 'AAAAAO5QGSKQkcErWDq9iKwemolyxv8LDVZBwWLQSiYp7iDVAAAAZAAAAAQAAAABAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAEAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAASnuINUAAABASz0AtZeNzXSXkjPkKJfOE8aUTAuPR6pxMMbF337wxE3wzOTDaVcDQ2N5P3E9MKc+fbbFhZ9K+07+J0wMGltRBA==', '6dGjAArqNnQxQvLt4QbTyzfD1+iFCOPyG0ljcLWGOFgAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAA==', 'AAAAAAAAAAEAAAABAAAAAQAAAAUAAAAAAAAAAO5QGSKQkcErWDq9iKwemolyxv8LDVZBwWLQSiYp7iDVAAAAAlQL4tQAAAAEAAAAAwAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAEAAAAAAAAAADuUBkikJHBK1g6vYisHpqJcsb/Cw1WQcFi0EomKe4g1QAAAAJUC+QAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAFAAAAAAAAAADuUBkikJHBK1g6vYisHpqJcsb/Cw1WQcFi0EomKe4g1QAAAAJUC+OcAAAABAAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{Sz0AtZeNzXSXkjPkKJfOE8aUTAuPR6pxMMbF337wxE3wzOTDaVcDQ2N5P3E9MKc+fbbFhZ9K+07+J0wMGltRBA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('995b9269f9f9c4c1eace75501188766d6e8ae40c5413120811a50437683cb74c', 5, 2, 'GDXFAGJCSCI4CK2YHK6YRLA6TKEXFRX7BMGVMQOBMLIEUJRJ5YQNLMIB', 17179869186, 100, 1, '2016-03-29 19:22:37.703336', '2016-03-29 19:22:37.703336', 21474844672, 'AAAAAO5QGSKQkcErWDq9iKwemolyxv8LDVZBwWLQSiYp7iDVAAAAZAAAAAQAAAACAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAD2T51Mi2fjmCY4Z+R5JON1LluqzrnpmTxUJXTp/A3FRwAAAAEAAAAAAAAAASnuINUAAABADpkMMc7kkkYjDoPwfUlOE9tLYvWHI/m+BBe/gCKN1cVvEF1UBVeCCuGBTjury4TqoxplKl4NZHJST5/Orr4XCA==', 'mVuSafn5xMHqznVQEYh2bW6K5AxUExIIEaUEN2g8t0wAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAA==', 'AAAAAAAAAAEAAAABAAAAAQAAAAUAAAAAAAAAAO5QGSKQkcErWDq9iKwemolyxv8LDVZBwWLQSiYp7iDVAAAAAlQL4tQAAAAEAAAAAwAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAQAAAAD2T51Mi2fjmCY4Z+R5JON1LluqzrnpmTxUJXTp/A3FRwAAAAEAAAAAAAAAAA==', 'AAAAAQAAAAEAAAAFAAAAAAAAAADuUBkikJHBK1g6vYisHpqJcsb/Cw1WQcFi0EomKe4g1QAAAAJUC+M4AAAABAAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{DpkMMc7kkkYjDoPwfUlOE9tLYvWHI/m+BBe/gCKN1cVvEF1UBVeCCuGBTjury4TqoxplKl4NZHJST5/Orr4XCA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('f78dca926455579b4a43009ffe35a0229a6da4bed32d3c999d7a06ad26605a25', 5, 3, 'GDXFAGJCSCI4CK2YHK6YRLA6TKEXFRX7BMGVMQOBMLIEUJRJ5YQNLMIB', 17179869187, 100, 1, '2016-03-29 19:22:37.7048', '2016-03-29 19:22:37.7048', 21474848768, 'AAAAAO5QGSKQkcErWDq9iKwemolyxv8LDVZBwWLQSiYp7iDVAAAAZAAAAAQAAAADAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAAAAAABAAAAAgAAAAEAAAACAAAAAQAAAAIAAAAAAAAAAAAAAAAAAAABKe4g1QAAAEDglRRymtLjw+ImmGwTiBTKE7X7+2CywlHw8qed+t520SbAggcqboy5KXJaEP51/wRSMxtZUgDOFfaDn9Df04EA', '943KkmRVV5tKQwCf/jWgIpptpL7TLTyZnXoGrSZgWiUAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAA==', 'AAAAAAAAAAEAAAABAAAAAQAAAAUAAAAAAAAAAO5QGSKQkcErWDq9iKwemolyxv8LDVZBwWLQSiYp7iDVAAAAAlQL4tQAAAAEAAAAAwAAAAEAAAAAAAAAAAAAAAABAgICAAAAAQAAAAD2T51Mi2fjmCY4Z+R5JON1LluqzrnpmTxUJXTp/A3FRwAAAAEAAAAAAAAAAA==', 'AAAAAQAAAAEAAAAFAAAAAAAAAADuUBkikJHBK1g6vYisHpqJcsb/Cw1WQcFi0EomKe4g1QAAAAJUC+LUAAAABAAAAAMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{4JUUcprS48PiJphsE4gUyhO1+/tgssJR8PKnnfredtEmwIIHKm6MuSlyWhD+df8EUjMbWVIAzhX2g5/Q39OBAA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('a9085e13fbe9f84e07e320a0d445536de1afc2cfd8c7e4186687807edd2b4897', 6, 1, 'GDXFAGJCSCI4CK2YHK6YRLA6TKEXFRX7BMGVMQOBMLIEUJRJ5YQNLMIB', 17179869188, 100, 1, '2016-03-29 19:22:37.709547', '2016-03-29 19:22:37.709547', 25769807872, 'AAAAAO5QGSKQkcErWDq9iKwemolyxv8LDVZBwWLQSiYp7iDVAAAAZAAAAAQAAAAEAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAEAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAinuINUAAABA4PRAe0en/05ZH2leCeTOsxbT0cUu3wgUiWUcuDk4ya8G/gI90hlV6pzOYyAB6Zt5fN7pRrPRL/tTlnjgUAjaBvwNxUcAAABAFmdGR6JZukKJUC3Vr2YEJ/24G3tesqTv4cV5UcAozRhS2+w0PYVVqe7QTmOMNSGX/C3LxP1tSvpXdU/OhYsODw==', 'qQheE/vp+E4H4yCg1EVTbeGvws/Yx+QYZoeAft0rSJcAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAA==', 'AAAAAAAAAAEAAAABAAAAAQAAAAYAAAAAAAAAAO5QGSKQkcErWDq9iKwemolyxv8LDVZBwWLQSiYp7iDVAAAAAlQL4nAAAAAEAAAABAAAAAEAAAAAAAAAAAAAAAACAgICAAAAAQAAAAD2T51Mi2fjmCY4Z+R5JON1LluqzrnpmTxUJXTp/A3FRwAAAAEAAAAAAAAAAA==', 'AAAAAgAAAAMAAAAFAAAAAAAAAADuUBkikJHBK1g6vYisHpqJcsb/Cw1WQcFi0EomKe4g1QAAAAJUC+LUAAAABAAAAAMAAAABAAAAAAAAAAAAAAAAAQICAgAAAAEAAAAA9k+dTItn45gmOGfkeSTjdS5bqs656Zk8VCV06fwNxUcAAAABAAAAAAAAAAAAAAABAAAABgAAAAAAAAAA7lAZIpCRwStYOr2IrB6aiXLG/wsNVkHBYtBKJinuINUAAAACVAvicAAAAAQAAAAEAAAAAQAAAAAAAAAAAAAAAAECAgIAAAABAAAAAPZPnUyLZ+OYJjhn5Hkk43UuW6rOuemZPFQldOn8DcVHAAAAAQAAAAAAAAAA', '{4PRAe0en/05ZH2leCeTOsxbT0cUu3wgUiWUcuDk4ya8G/gI90hlV6pzOYyAB6Zt5fN7pRrPRL/tTlnjgUAjaBg==,FmdGR6JZukKJUC3Vr2YEJ/24G3tesqTv4cV5UcAozRhS2+w0PYVVqe7QTmOMNSGX/C3LxP1tSvpXdU/OhYsODw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('0fb9c2e20946222b23e1d1d660de9d74576c41cfd9b199f9d565a013c1ef89ca', 7, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 3, 100, 1, '2016-03-29 19:22:37.713989', '2016-03-29 19:22:37.713989', 30064775168, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAADAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAOerFQRLRq/h3Xf4EErEqz7oD9wk20zX+d/h4dXc7DToAAAACVAvkAAAAAAAAAAABVvwF9wAAAED8tIFyog9OeCqiaBNfxFdAlneNYTfjoNUMKi6FJCY5BqemnDBxGox3jKS/xx4zpxAToEFp3Y2M+NRJIU4g/H0J', 'D7nC4glGIisj4dHWYN6ddFdsQc/ZsZn51WWgE8HvicoAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAAAcAAAAAAAAAADnqxUES0av4d13+BBKxKs+6A/cJNtM1/nf4eHV3Ow06AAAAAlQL5AAAAAAHAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAcAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2rKtAUtQAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAEAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtq7/TDc4AAAAAAAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAHAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtq7/TDbUAAAAAAAAAAMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{/LSBcqIPTngqomgTX8RXQJZ3jWE346DVDCouhSQmOQanppwwcRqMd4ykv8ceM6cQE6BBad2NjPjUSSFOIPx9CQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('dd74eee27a59843b28a05ad08abf65eaa231b7debe4d05550c0a7a424cca5929', 8, 1, 'GA46VRKBCLI2X6DXLX7AIEVRFLH3UA7XBE3NGNP6O74HQ5LXHMGTV2JB', 30064771073, 100, 1, '2016-03-29 19:22:37.719897', '2016-03-29 19:22:37.719897', 34359742464, 'AAAAADnqxUES0av4d13+BBKxKs+6A/cJNtM1/nf4eHV3Ow06AAAAZAAAAAcAAAABAAAAAAAAAAIAAAAAAAAAewAAAAEAAAAAAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAAAAAAAAJiWgAAAAAAAAAABdzsNOgAAAEBjk5EFqV8GiL9xU62OUCKeScXxGMTMqJoD7ryiGf5jLPZJRSphbWC3ZycHE+pDuu/6EKSqcNUri5AXzQmM+GYB', '3XTu4npZhDsooFrQir9l6qIxt96+TQVVDAp6QkzKWSkAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAEAAAAAAAAAAA==', 'AAAAAAAAAAEAAAADAAAAAQAAAAgAAAAAAAAAADnqxUES0av4d13+BBKxKs+6A/cJNtM1/nf4eHV3Ow06AAAAAlNzS/AAAAAHAAAABAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAwAAAAcAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2rKtAUtQAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAgAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2rKvY6VQAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAHAAAAAAAAAAA56sVBEtGr+Hdd/gQSsSrPugP3CTbTNf53+Hh1dzsNOgAAAAJUC+QAAAAABwAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAIAAAAAAAAAAA56sVBEtGr+Hdd/gQSsSrPugP3CTbTNf53+Hh1dzsNOgAAAAJUC+OcAAAABwAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{Y5ORBalfBoi/cVOtjlAinknF8RjEzKiaA+68ohn+Yyz2SUUqYW1gt2cnBxPqQ7rv+hCkqnDVK4uQF80JjPhmAQ==}', 'id', '123', NULL);
INSERT INTO history_transactions VALUES ('2551e76a3ce4881b7bc73fdfd89d670d511ea7d4e56156252b51777023202de7', 8, 2, 'GA46VRKBCLI2X6DXLX7AIEVRFLH3UA7XBE3NGNP6O74HQ5LXHMGTV2JB', 30064771074, 100, 1, '2016-03-29 19:22:37.721394', '2016-03-29 19:22:37.721394', 34359746560, 'AAAAADnqxUES0av4d13+BBKxKs+6A/cJNtM1/nf4eHV3Ow06AAAAZAAAAAcAAAACAAAAAAAAAAEAAAAFaGVsbG8AAAAAAAABAAAAAAAAAAEAAAAAYvwdC9CRsrYcDdZWNGsqaNfTR8bywsjubQRHAlb8BfcAAAAAAAAAAACYloAAAAAAAAAAAXc7DToAAABAS2+MaPA79AjD0B7qjl0qEz0N6CkDmoS4kgnXjZfbvdc9IkqNm0S+vKBNgV80pSfixY147L+jvS/ganovqbLiAQ==', 'JVHnajzkiBt7xz/f2J1nDVEep9TlYVYlK1F3cCMgLecAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAEAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAQAAAAgAAAAAAAAAADnqxUES0av4d13+BBKxKs+6A/cJNtM1/nf4eHV3Ow06AAAAAlLatXAAAAAHAAAABAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAgAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2rKxxf9QAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAIAAAAAAAAAAA56sVBEtGr+Hdd/gQSsSrPugP3CTbTNf53+Hh1dzsNOgAAAAJUC+M4AAAABwAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{S2+MaPA79AjD0B7qjl0qEz0N6CkDmoS4kgnXjZfbvdc9IkqNm0S+vKBNgV80pSfixY147L+jvS/ganovqbLiAQ==}', 'text', 'hello', NULL);
INSERT INTO history_transactions VALUES ('3b36ecfbcc2adb0cfff08ae86199f64e12984f084bb03be9bb249611df82322b', 8, 3, 'GA46VRKBCLI2X6DXLX7AIEVRFLH3UA7XBE3NGNP6O74HQ5LXHMGTV2JB', 30064771075, 100, 1, '2016-03-29 19:22:37.72296', '2016-03-29 19:22:37.72296', 34359750656, 'AAAAADnqxUES0av4d13+BBKxKs+6A/cJNtM1/nf4eHV3Ow06AAAAZAAAAAcAAAADAAAAAAAAAAMBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAAEAAAAAAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAAAAAAAAJiWgAAAAAAAAAABdzsNOgAAAEDC9hMtMYZ6hbx1iAdXngRcCYQmf8eu4zcB9SLH2998tVYca6QYig5Dsgy2oCMD1J7khIL9jz/VWjcPhvTVvC8L', 'Ozbs+8wq2wz/8IroYZn2ThKYTwhLsDvpuySWEd+CMisAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAEAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAQAAAAgAAAAAAAAAADnqxUES0av4d13+BBKxKs+6A/cJNtM1/nf4eHV3Ow06AAAAAlJCHvAAAAAHAAAABAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAgAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2rK0KFlQAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAIAAAAAAAAAAA56sVBEtGr+Hdd/gQSsSrPugP3CTbTNf53+Hh1dzsNOgAAAAJUC+LUAAAABwAAAAMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{wvYTLTGGeoW8dYgHV54EXAmEJn/HruM3AfUix9vffLVWHGukGIoOQ7IMtqAjA9Se5ISC/Y8/1Vo3D4b01bwvCw==}', 'hash', 'AQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQE=', NULL);
INSERT INTO history_transactions VALUES ('e14885cb66af5f7f5e991b014eec475c61cc831292cf5526cdd0cda145300837', 8, 4, 'GA46VRKBCLI2X6DXLX7AIEVRFLH3UA7XBE3NGNP6O74HQ5LXHMGTV2JB', 30064771076, 100, 1, '2016-03-29 19:22:37.724423', '2016-03-29 19:22:37.724423', 34359754752, 'AAAAADnqxUES0av4d13+BBKxKs+6A/cJNtM1/nf4eHV3Ow06AAAAZAAAAAcAAAAEAAAAAAAAAAQCAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgAAAAEAAAAAAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAAAAAAAAJiWgAAAAAAAAAABdzsNOgAAAEBOfq9PQ8EGcpjRWEaqGxvhBjSVuk6K5A2rthLYHnmAXmQ1JjJD3EddjiES3bPZUF5efGQvRjoEKgiB2dU3f2wF', '4UiFy2avX39emRsBTuxHXGHMgxKSz1UmzdDNoUUwCDcAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAEAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAQAAAAgAAAAAAAAAADnqxUES0av4d13+BBKxKs+6A/cJNtM1/nf4eHV3Ow06AAAAAlGpiHAAAAAHAAAABAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAgAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2rK2irNQAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAIAAAAAAAAAAA56sVBEtGr+Hdd/gQSsSrPugP3CTbTNf53+Hh1dzsNOgAAAAJUC+JwAAAABwAAAAQAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{Tn6vT0PBBnKY0VhGqhsb4QY0lbpOiuQNq7YS2B55gF5kNSYyQ9xHXY4hEt2z2VBeXnxkL0Y6BCoIgdnVN39sBQ==}', 'return', 'AgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgI=', NULL);
INSERT INTO history_transactions VALUES ('66c28c0ccd5a2e47026aacafa2ecd3c501fe5de349ef376c0f8afb893c7bb55d', 9, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 4, 100, 1, '2016-03-29 19:22:37.729313', '2016-03-29 19:22:37.729313', 38654709760, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAAEAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAADd1O3oAD6ZmsdNe9Y4zdIQW1rTvIfAEYi/0il9kFYl4AAAACVAvkAAAAAAAAAAABVvwF9wAAAEARD6MVWgEASusfhr6JdF9K3Rie2XCRJKl/NoKyJcrd1kGs3ygpp55xu80YlFwgNVErZ/cEAHYOq06CwNfnE2sC', 'ZsKMDM1aLkcCaqyvouzTxQH+XeNJ7zdsD4r7iTx7tV0AAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAAAkAAAAAAAAAAA3dTt6AA+mZrHTXvWOM3SEFta07yHwBGIv9IpfZBWJeAAAAAlQL5AAAAAAJAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAkAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2qlmWyHAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAIAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtqytoqzUAAAAAAAAAAMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAJAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtqytoqxwAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{EQ+jFVoBAErrH4a+iXRfSt0YntlwkSSpfzaCsiXK3dZBrN8oKaeecbvNGJRcIDVRK2f3BAB2DqtOgsDX5xNrAg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('fdb696a797b769176cbaed3a50e4a6a8671119621f65a3f954a3bcf100c7ef0c', 10, 1, 'GAG52TW6QAB6TGNMOTL32Y4M3UQQLNNNHPEHYAIYRP6SFF6ZAVRF5ZQY', 38654705665, 200, 2, '2016-03-29 19:22:37.734877', '2016-03-29 19:22:37.734877', 42949677056, 'AAAAAA3dTt6AA+mZrHTXvWOM3SEFta07yHwBGIv9IpfZBWJeAAAAyAAAAAkAAAABAAAAAAAAAAAAAAACAAAAAAAAAAEAAAAAYvwdC9CRsrYcDdZWNGsqaNfTR8bywsjubQRHAlb8BfcAAAAAAAAAAAX14QAAAAAAAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAAAAAAABfXhAAAAAAAAAAAB2QViXgAAAEAxyl5gvCCDC7l0pq9b/Btd3cOUUcY9Rv0ALxVjul4EVSL1Vygr107GjDo11+YswdmlCuWf7KItU0chlogpns4L', '/baWp5e3aRdsuu06UOSmqGcRGWIfZaP5VKO88QDH7wwAAAAAAAAAyAAAAAAAAAACAAAAAAAAAAEAAAAAAAAAAAAAAAEAAAAAAAAAAA==', 'AAAAAAAAAAIAAAADAAAAAQAAAAoAAAAAAAAAAA3dTt6AA+mZrHTXvWOM3SEFta07yHwBGIv9IpfZBWJeAAAAAk4WAjgAAAAJAAAAAQAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAwAAAAkAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2qlmWyHAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAoAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2ql+MqXAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAEAAAAKAAAAAAAAAAAN3U7egAPpmax0171jjN0hBbWtO8h8ARiL/SKX2QViXgAAAAJIICE4AAAACQAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAKAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtqplgopwAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', 'AAAAAgAAAAMAAAAJAAAAAAAAAAAN3U7egAPpmax0171jjN0hBbWtO8h8ARiL/SKX2QViXgAAAAJUC+QAAAAACQAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAKAAAAAAAAAAAN3U7egAPpmax0171jjN0hBbWtO8h8ARiL/SKX2QViXgAAAAJUC+M4AAAACQAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{McpeYLwggwu5dKavW/wbXd3DlFHGPUb9AC8VY7peBFUi9VcoK9dOxow6NdfmLMHZpQrln+yiLVNHIZaIKZ7OCw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('67601a2ca212b84092a7d3c521172b67f4b93d72b726a06c540917d2ab83c1a1', 11, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 5, 100, 1, '2016-03-29 19:22:37.740424', '2016-03-29 19:22:37.740424', 47244644352, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAAFAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAxVmE0iEp9S70YdkrhAu6dT4jSnPvbUuzitQ4oBcfaDMAAAACVAvkAAAAAAAAAAABVvwF9wAAAEBHLko6/Tbv0v/5CWHkixXnbyoU6qQ6yewZGqPHFSzNxMfud86eYGkN0j4msMCXfLAou7iKOVn0MWyzlpvYRA0B', 'Z2AaLKISuECSp9PFIRcrZ/S5PXK3JqBsVAkX0quDwaEAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAAAsAAAAAAAAAAMVZhNIhKfUu9GHZK4QLunU+I0pz721Ls4rUOKAXH2gzAAAAAlQL5AAAAAALAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAsAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2qBF2pgwAAAAAAAAABQAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAKAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtqplgopwAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAALAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtqplgooMAAAAAAAAAAUAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{Ry5KOv0279L/+Qlh5IsV528qFOqkOsnsGRqjxxUszcTH7nfOnmBpDdI+JrDAl3ywKLu4ijlZ9DFss5ab2EQNAQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('0e128647b2b93786b6b76e182dcda0173757066f8caf0523d1ba3b47fd6f720d', 12, 1, 'GDCVTBGSEEU7KLXUMHMSXBALXJ2T4I2KOPXW2S5TRLKDRIAXD5UDHAYO', 47244640257, 100, 1, '2016-03-29 19:22:37.747166', '2016-03-29 19:22:37.747166', 51539611648, 'AAAAAMVZhNIhKfUu9GHZK4QLunU+I0pz721Ls4rUOKAXH2gzAAAAZAAAAAsAAAABAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAg/K/Blr9FO/nVEGLdmCzChMYpmcQzxIhFm6NBzxznX0AAAAAHc1lAAAAAAAAAAABFx9oMwAAAEBwY9HQAR2SMPe3JPvmBBtBk2jfog0GFEFYkLNFzQNqvYl7iZitmO5FQmkKlv/NO5ZcaWBqXcHhOQpk0s2XSBQF', 'DhKGR7K5N4a2t24YLc2gFzdXBm+MrwUj0bo7R/1vcg0AAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAAAwAAAAAAAAAAIPyvwZa/RTv51RBi3ZgswoTGKZnEM8SIRZujQc8c519AAAAAB3NZQAAAAAMAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAwAAAAAAAAAAMVZhNIhKfUu9GHZK4QLunU+I0pz721Ls4rUOKAXH2gzAAAAAjY+fpwAAAALAAAAAQAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAALAAAAAAAAAADFWYTSISn1LvRh2SuEC7p1PiNKc+9tS7OK1DigFx9oMwAAAAJUC+QAAAAACwAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAMAAAAAAAAAADFWYTSISn1LvRh2SuEC7p1PiNKc+9tS7OK1DigFx9oMwAAAAJUC+OcAAAACwAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{cGPR0AEdkjD3tyT75gQbQZNo36INBhRBWJCzRc0Dar2Je4mYrZjuRUJpCpb/zTuWXGlgal3B4TkKZNLNl0gUBQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('cd8a8e9eb53fd268d1294e228995c27f422d90783c4054e44ab0028fc1da210a', 13, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 6, 100, 1, '2016-03-29 19:22:37.752429', '2016-03-29 19:22:37.752429', 55834578944, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAAGAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAji4PQpc6JMWt5AB56WXIEop14Pn7tW6uf6xE+vY7ZNwAAAACVAvkAAAAAAAAAAABVvwF9wAAAEAUtdYWyr64yv/rKPr0/vV4vYyonfsWxpxHsiYLHKJ3bm6k+ypiAByc8t0K+7bzxSLPjmjKKN5Prw7AdenlC7MB', 'zYqOnrU/0mjRKU4iiZXCf0ItkHg8QFTkSrACj8HaIQoAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAAA0AAAAAAAAAAI4uD0KXOiTFreQAeellyBKKdeD5+7Vurn+sRPr2O2TcAAAAAlQL5AAAAAANAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAA0AAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2pb1qwUQAAAAAAAAABwAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAALAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtqgRdqYMAAAAAAAAAAUAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAANAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtqgRdqWoAAAAAAAAAAYAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{FLXWFsq+uMr/6yj69P71eL2MqJ37FsacR7ImCxyid25upPsqYgAcnPLdCvu288Uiz45oyijeT68OwHXp5QuzAQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('bfbd5e9457d717bcf847291a6c24b7cd8db4ff784ecd4592be30d08146c0c264', 13, 2, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 7, 100, 1, '2016-03-29 19:22:37.754802', '2016-03-29 19:22:37.754802', 55834583040, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAAHAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAG5M9WO2kexu4dljTd0YSuyEnmDUsxKamzJWiv4FGkoQAAAACVAvkAAAAAAAAAAABVvwF9wAAAEDY1TiMj+qj8+zYb2Vb60h+qWxZtFfSGwb0kvKttSFAHQhGOjIddiVQopx9LDRO6UgPmLLxFvQpIzeGnagh3vQD', 'v71elFfXF7z4RykabCS3zY20/3hOzUWSvjDQgUbAwmQAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAAA0AAAAAAAAAABuTPVjtpHsbuHZY03dGErshJ5g1LMSmpsyVor+BRpKEAAAAAlQL5AAAAAANAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAA0AAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2o2le3UQAAAAAAAAABwAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAANAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtqgRdqVEAAAAAAAAAAcAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{2NU4jI/qo/Ps2G9lW+tIfqlsWbRX0hsG9JLyrbUhQB0IRjoyHXYlUKKcfSw0TulID5iy8Rb0KSM3hp2oId70Aw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('30880dd42d8e402a30d8a3527b56c1e33e18e87c46e1332ea5cfc1721fd87cfb', 14, 1, 'GCHC4D2CS45CJRNN4QAHT2LFZAJIU5PA7H53K3VOP6WEJ6XWHNSNZKQG', 55834574849, 100, 1, '2016-03-29 19:22:37.760175', '2016-03-29 19:22:37.760175', 60129546240, 'AAAAAI4uD0KXOiTFreQAeellyBKKdeD5+7Vurn+sRPr2O2TcAAAAZAAAAA0AAAABAAAAAAAAAAAAAAABAAAAAAAAAAEAAAAAG5M9WO2kexu4dljTd0YSuyEnmDUsxKamzJWiv4FGkoQAAAAAAAAAAAX14QAAAAAAAAAAAfY7ZNwAAABAieZSSuOZqlwtyjnj5d/S0GUSGiQvy0ipPLynpl4UvO8qc7CDz3vsLROlN2g50qXirydSOdao56hvRhrEfRsGCA==', 'MIgN1C2OQCow2KNSe1bB4z4Y6HxG4TMupc/Bch/YfPsAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAEAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAQAAAA4AAAAAAAAAABuTPVjtpHsbuHZY03dGErshJ5g1LMSmpsyVor+BRpKEAAAAAloBxJwAAAANAAAAAQAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAA4AAAAAAAAAAI4uD0KXOiTFreQAeellyBKKdeD5+7Vurn+sRPr2O2TcAAAAAk4WApwAAAANAAAAAQAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAANAAAAAAAAAACOLg9Clzokxa3kAHnpZcgSinXg+fu1bq5/rET69jtk3AAAAAJUC+QAAAAADQAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAOAAAAAAAAAACOLg9Clzokxa3kAHnpZcgSinXg+fu1bq5/rET69jtk3AAAAAJUC+OcAAAADQAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{ieZSSuOZqlwtyjnj5d/S0GUSGiQvy0ipPLynpl4UvO8qc7CDz3vsLROlN2g50qXirydSOdao56hvRhrEfRsGCA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('dbd964fcfdb336a30f21c240fffdaf73d7c75880ed1b99375c62f84e3e592570', 14, 2, 'GANZGPKY5WSHWG5YOZMNG52GCK5SCJ4YGUWMJJVGZSK2FP4BI2JIJN2C', 55834574849, 100, 1, '2016-03-29 19:22:37.761612', '2016-03-29 19:22:37.761612', 60129550336, 'AAAAABuTPVjtpHsbuHZY03dGErshJ5g1LMSmpsyVor+BRpKEAAAAZAAAAA0AAAABAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABVVNEAAAAAACOLg9Clzokxa3kAHnpZcgSinXg+fu1bq5/rET69jtk3H//////////AAAAAAAAAAGBRpKEAAAAQGDAV/5Op2DmFUP84dmyT5G/gxn1WzgdMrkSSU7wfpu39ycq36Sg+gs2ypRjw5hxxeMUj/GVEKipcDGndei38Aw=', '29lk/P2zNqMPIcJA//2vc9fHWIDtG5k3XGL4Tj5ZJXAAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAYAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAAA4AAAABAAAAABuTPVjtpHsbuHZY03dGErshJ5g1LMSmpsyVor+BRpKEAAAAAVVTRAAAAAAAji4PQpc6JMWt5AB56WXIEop14Pn7tW6uf6xE+vY7ZNwAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAAA4AAAAAAAAAABuTPVjtpHsbuHZY03dGErshJ5g1LMSmpsyVor+BRpKEAAAAAloBxJwAAAANAAAAAQAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAANAAAAAAAAAAAbkz1Y7aR7G7h2WNN3RhK7ISeYNSzEpqbMlaK/gUaShAAAAAJUC+QAAAAADQAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAOAAAAAAAAAAAbkz1Y7aR7G7h2WNN3RhK7ISeYNSzEpqbMlaK/gUaShAAAAAJUC+OcAAAADQAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{YMBX/k6nYOYVQ/zh2bJPkb+DGfVbOB0yuRJJTvB+m7f3JyrfpKD6CzbKlGPDmHHF4xSP8ZUQqKlwMad16LfwDA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('142c988b1f67984f74a1581de9caecf499e60f1e0eed496661aa2c559238764c', 15, 1, 'GCHC4D2CS45CJRNN4QAHT2LFZAJIU5PA7H53K3VOP6WEJ6XWHNSNZKQG', 55834574850, 100, 1, '2016-03-29 19:22:37.76593', '2016-03-29 19:22:37.76593', 64424513536, 'AAAAAI4uD0KXOiTFreQAeellyBKKdeD5+7Vurn+sRPr2O2TcAAAAZAAAAA0AAAACAAAAAAAAAAAAAAABAAAAAAAAAAEAAAAAG5M9WO2kexu4dljTd0YSuyEnmDUsxKamzJWiv4FGkoQAAAABVVNEAAAAAACOLg9Clzokxa3kAHnpZcgSinXg+fu1bq5/rET69jtk3AAAAAAF9eEAAAAAAAAAAAH2O2TcAAAAQJBUx5tWfjAwXxab9U5HOjZvBRv3u95jXbyzuqeZ/kjsyMsU0jO/g03Rf1zgect1hj4hDYGN8mW4oEot0sSTZgw=', 'FCyYix9nmE90oVgd6crs9JnmDx4O7UlmYaosVZI4dkwAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAEAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAwAAAA4AAAABAAAAABuTPVjtpHsbuHZY03dGErshJ5g1LMSmpsyVor+BRpKEAAAAAVVTRAAAAAAAji4PQpc6JMWt5AB56WXIEop14Pn7tW6uf6xE+vY7ZNwAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAAA8AAAABAAAAABuTPVjtpHsbuHZY03dGErshJ5g1LMSmpsyVor+BRpKEAAAAAVVTRAAAAAAAji4PQpc6JMWt5AB56WXIEop14Pn7tW6uf6xE+vY7ZNwAAAAABfXhAH//////////AAAAAQAAAAAAAAAA', 'AAAAAgAAAAMAAAAOAAAAAAAAAACOLg9Clzokxa3kAHnpZcgSinXg+fu1bq5/rET69jtk3AAAAAJOFgKcAAAADQAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAPAAAAAAAAAACOLg9Clzokxa3kAHnpZcgSinXg+fu1bq5/rET69jtk3AAAAAJOFgI4AAAADQAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{kFTHm1Z+MDBfFpv1Tkc6Nm8FG/e73mNdvLO6p5n+SOzIyxTSM7+DTdF/XOB5y3WGPiENgY3yZbigSi3SxJNmDA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('a5a9e3ca63e9cc155359c97337bcb14464cca56b230a4d0c7f27582644d16809', 16, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 8, 100, 1, '2016-03-29 19:22:37.770421', '2016-03-29 19:22:37.770421', 68719480832, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAAIAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAA423/rAYjzzhmLqxgNgLUY5X92ueHg5xGtOuok+g5NQoAAAACVAvkAAAAAAAAAAABVvwF9wAAAEBhFD/bYaTZZJ3VJ9xJqXoW5eeLK0AeFaATBH92cRfx0WUTFqp6rXx47fMBUxkWYq8bAHMfYCS5XXPRg86sAGUK', 'panjymPpzBVTWclzN7yxRGTMpWsjCk0MfydYJkTRaAkAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAABAAAAAAAAAAAONt/6wGI884Zi6sYDYC1GOV/drnh4OcRrTrqJPoOTUKAAAAAlQL5AAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAABAAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2oRVS+BgAAAAAAAAACgAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAANAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtqNpXt1EAAAAAAAAAAcAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAQAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtqNpXtzgAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{YRQ/22Gk2WSd1SfcSal6FuXniytAHhWgEwR/dnEX8dFlExaqeq18eO3zAVMZFmKvGwBzH2AkuV1z0YPOrABlCg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('6a056189b45760c607e331c90c5a8b4cd720961df8bc8cecfd4aa388b577a6cb', 16, 2, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 9, 100, 1, '2016-03-29 19:22:37.772743', '2016-03-29 19:22:37.772743', 68719484928, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAAJAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAABAjoBMEUiZNLUjsWXL1iK59D90Li4w56076b8HKxZfIAAAACVAvkAAAAAAAAAAABVvwF9wAAAEAxC5cl7tkjQI0cfFZTiIFDuo0SwyYnNqTUH2hxDBtm7h/vUkBG3cgwGXS87ninVkhmvdIpTWfeIeGiw7kgefUA', 'agVhibRXYMYH4zHJDFqLTNcglh34vIzs/UqjiLV3pssAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAABAAAAAAAAAAAAQI6ATBFImTS1I7Fly9YiufQ/dC4uMOetO+m/BysWXyAAAAAlQL5AAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAABAAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2nsFHFBgAAAAAAAAACgAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAQAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtqNpXtx8AAAAAAAAAAkAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{MQuXJe7ZI0CNHHxWU4iBQ7qNEsMmJzak1B9ocQwbZu4f71JARt3IMBl0vO54p1ZIZr3SKU1n3iHhosO5IHn1AA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('18bf6cce20cfbb0f9079c4b8783718949d13bd12d173a60363d2b8e3a07efead', 16, 3, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 10, 100, 1, '2016-03-29 19:22:37.775049', '2016-03-29 19:22:37.775049', 68719489024, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAAKAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAACVAvkAAAAAAAAAAABVvwF9wAAAEC/RVto6ytAqHpd6ZFWjwXQyXopKORz8QSvz0d8RoPrOEBgNEuAj8+kbyhS7QieOqwbiJrS0AU8YWaBQQ4zc+wL', 'GL9sziDPuw+QecS4eDcYlJ0TvRLRc6YDY9K446B+/q0AAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAABAAAAAAAAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAAlQL5AAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAABAAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2nG07MBgAAAAAAAAACgAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAQAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtqNpXtwYAAAAAAAAAAoAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{v0VbaOsrQKh6XemRVo8F0Ml6KSjkc/EEr89HfEaD6zhAYDRLgI/PpG8oUu0InjqsG4ia0tAFPGFmgUEOM3PsCw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('d1f593eb5e14f97027bc79821fa46628c107034fba9a5acef6a9da79e051ee73', 17, 1, 'GACAR2AEYEKITE2LKI5RMXF5MIVZ6Q7XILROGDT22O7JX4DSWFS7FDDP', 68719476737, 100, 1, '2016-03-29 19:22:37.780969', '2016-03-29 19:22:37.780969', 73014448128, 'AAAAAAQI6ATBFImTS1I7Fly9YiufQ/dC4uMOetO+m/BysWXyAAAAZAAAABAAAAABAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABRVVSAAAAAAAuwvNzNk9twbuJHUBqnX26GYI3MbCdpQU9t4n6EVRXsX//////////AAAAAAAAAAFysWXyAAAAQI7hbwZc1+KWfheVnYAq5TXFX9ancHJmJq0wV0c9ONIfG6U8trhIVeVoiED2eUFFmhx+bBtF9TPSvifF/mfDlQk=', '0fWT614U+XAnvHmCH6RmKMEHA0+6mlrO9qnaeeBR7nMAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAYAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAABEAAAABAAAAAAQI6ATBFImTS1I7Fly9YiufQ/dC4uMOetO+m/BysWXyAAAAAUVVUgAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAABEAAAAAAAAAAAQI6ATBFImTS1I7Fly9YiufQ/dC4uMOetO+m/BysWXyAAAAAlQL45wAAAAQAAAAAQAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAQAAAAAAAAAAAECOgEwRSJk0tSOxZcvWIrn0P3QuLjDnrTvpvwcrFl8gAAAAJUC+QAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAARAAAAAAAAAAAECOgEwRSJk0tSOxZcvWIrn0P3QuLjDnrTvpvwcrFl8gAAAAJUC+OcAAAAEAAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{juFvBlzX4pZ+F5WdgCrlNcVf1qdwcmYmrTBXRz040h8bpTy2uEhV5WiIQPZ5QUWaHH5sG0X1M9K+J8X+Z8OVCQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('cdef45dd961d59375351ea7dd7ef6414ff49371a335723e84dafacea1e13665a', 17, 2, 'GDRW375MAYR46ODGF2WGANQC2RRZL7O246DYHHCGWTV2RE7IHE2QUQLD', 68719476737, 100, 1, '2016-03-29 19:22:37.782667', '2016-03-29 19:22:37.782667', 73014452224, 'AAAAAONt/6wGI884Zi6sYDYC1GOV/drnh4OcRrTrqJPoOTUKAAAAZAAAABAAAAABAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABVVNEAAAAAAAuwvNzNk9twbuJHUBqnX26GYI3MbCdpQU9t4n6EVRXsX//////////AAAAAAAAAAHoOTUKAAAAQIjLqcYXE8EAsH6Dx2hwPjiEfHGZ4jsMNZZc7PynNiJi9kFXjfvvLDlWizGAr2B9MFDrfDRDvjnBxKKhJifEcQM=', 'ze9F3ZYdWTdTUep91+9kFP9JNxozVyPoTa+s6h4TZloAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAYAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAABEAAAABAAAAAONt/6wGI884Zi6sYDYC1GOV/drnh4OcRrTrqJPoOTUKAAAAAVVTRAAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAABEAAAAAAAAAAONt/6wGI884Zi6sYDYC1GOV/drnh4OcRrTrqJPoOTUKAAAAAlQL45wAAAAQAAAAAQAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAQAAAAAAAAAADjbf+sBiPPOGYurGA2AtRjlf3a54eDnEa066iT6Dk1CgAAAAJUC+QAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAARAAAAAAAAAADjbf+sBiPPOGYurGA2AtRjlf3a54eDnEa066iT6Dk1CgAAAAJUC+OcAAAAEAAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{iMupxhcTwQCwfoPHaHA+OIR8cZniOww1llzs/Kc2ImL2QVeN++8sOVaLMYCvYH0wUOt8NEO+OcHEoqEmJ8RxAw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('902b90c2322b9e6b335e7543389a7446b86e3039ebf59ec66dffb50eaec0dc85', 18, 1, 'GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU', 68719476737, 100, 1, '2016-03-29 19:22:37.788504', '2016-03-29 19:22:37.788504', 77309415424, 'AAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAZAAAABAAAAABAAAAAAAAAAAAAAABAAAAAAAAAAEAAAAA423/rAYjzzhmLqxgNgLUY5X92ueHg5xGtOuok+g5NQoAAAABVVNEAAAAAAAuwvNzNk9twbuJHUBqnX26GYI3MbCdpQU9t4n6EVRXsQAAAAA7msoAAAAAAAAAAAERVFexAAAAQC9X2I3Zz1x3AQMqL4XCzePTlwnokv2BQnWGmT007oH59gai3eNu7/WVoHtW8hsgHjs1mZK709FzzRF2cbD2tQE=', 'kCuQwjIrnmszXnVDOJp0RrhuMDnr9Z7Gbf+1Dq7A3IUAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAEAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAwAAABEAAAABAAAAAONt/6wGI884Zi6sYDYC1GOV/drnh4OcRrTrqJPoOTUKAAAAAVVTRAAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAABIAAAABAAAAAONt/6wGI884Zi6sYDYC1GOV/drnh4OcRrTrqJPoOTUKAAAAAVVTRAAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAAO5rKAH//////////AAAAAQAAAAAAAAAA', 'AAAAAgAAAAMAAAAQAAAAAAAAAAAuwvNzNk9twbuJHUBqnX26GYI3MbCdpQU9t4n6EVRXsQAAAAJUC+QAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAASAAAAAAAAAAAuwvNzNk9twbuJHUBqnX26GYI3MbCdpQU9t4n6EVRXsQAAAAJUC+OcAAAAEAAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{L1fYjdnPXHcBAyovhcLN49OXCeiS/YFCdYaZPTTugfn2BqLd427v9ZWge1byGyAeOzWZkrvT0XPNEXZxsPa1AQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('ca756d1519ceda79f8722042b12cea7ba004c3bd961adb62b59f88a867f86eb3', 18, 2, 'GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU', 68719476738, 100, 1, '2016-03-29 19:22:37.790579', '2016-03-29 19:22:37.790579', 77309419520, 'AAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAZAAAABAAAAACAAAAAAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAA7msoAAAAAAEAAAACAAAAAAAAAAAAAAAAAAAAARFUV7EAAABALuai5QxceFbtAiC5nkntNVnvSPeWR+C+FgplPAdRgRS+PPESpUiSCyuiwuhmvuDw7kwxn+A6E0M4ca1s2qzMAg==', 'ynVtFRnO2nn4ciBCsSzqe6AEw72WGttitZ+IqGf4brMAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAAAAAAAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAAAAAAAQAAAAAAAAABVVNEAAAAAAAuwvNzNk9twbuJHUBqnX26GYI3MbCdpQU9t4n6EVRXsQAAAADuaygAAAAAAQAAAAIAAAAAAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAABIAAAACAAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAAAAAAAEAAAAAAAAAAVVTRAAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAA7msoAAAAAAEAAAACAAAAAAAAAAAAAAAAAAAAAQAAABIAAAAAAAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAAlQL4tQAAAAQAAAAAwAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAASAAAAAAAAAAAuwvNzNk9twbuJHUBqnX26GYI3MbCdpQU9t4n6EVRXsQAAAAJUC+M4AAAAEAAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{Luai5QxceFbtAiC5nkntNVnvSPeWR+C+FgplPAdRgRS+PPESpUiSCyuiwuhmvuDw7kwxn+A6E0M4ca1s2qzMAg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('37bb79f6959c0e8e9b3d31f6c9308d8d084d9c6742cfa56ca094cfa6eae99423', 18, 3, 'GAXMF43TGZHW3QN3REOUA2U5PW5BTARXGGYJ3JIFHW3YT6QRKRL3CPPU', 68719476739, 100, 1, '2016-03-29 19:22:37.791607', '2016-03-29 19:22:37.791607', 77309423616, 'AAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAZAAAABAAAAADAAAAAAAAAAAAAAABAAAAAAAAAAMAAAABRVVSAAAAAAAuwvNzNk9twbuJHUBqnX26GYI3MbCdpQU9t4n6EVRXsQAAAAAAAAAAstBeAAAAAAEAAAABAAAAAAAAAAAAAAAAAAAAARFUV7EAAABArzp9Fxxql+yoysglDjXm9+rsJeNX2GsSa7TOy3AzHOu4Y5Z8ICx52Q885gQGQWMtEP0w6yh83d6+o6kjC/WuAg==', 'N7t59pWcDo6bPTH2yTCNjQhNnGdCz6VsoJTPpurplCMAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAAAAAAAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAAAAAAAgAAAAFFVVIAAAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAAAAAAACy0F4AAAAAAQAAAAEAAAAAAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAABIAAAACAAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAAAAAAAIAAAABRVVSAAAAAAAuwvNzNk9twbuJHUBqnX26GYI3MbCdpQU9t4n6EVRXsQAAAAAAAAAAstBeAAAAAAEAAAABAAAAAAAAAAAAAAAAAAAAAQAAABIAAAAAAAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAAlQL4tQAAAAQAAAAAwAAAAIAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAASAAAAAAAAAAAuwvNzNk9twbuJHUBqnX26GYI3MbCdpQU9t4n6EVRXsQAAAAJUC+LUAAAAEAAAAAMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{rzp9Fxxql+yoysglDjXm9+rsJeNX2GsSa7TOy3AzHOu4Y5Z8ICx52Q885gQGQWMtEP0w6yh83d6+o6kjC/WuAg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('198844c8b472daacc5b717695a4ca16ac799a13fb2cf4152d19e2117ae1c56c3', 19, 1, 'GDRW375MAYR46ODGF2WGANQC2RRZL7O246DYHHCGWTV2RE7IHE2QUQLD', 68719476738, 100, 1, '2016-03-29 19:22:37.796029', '2016-03-29 19:22:37.796029', 81604382720, 'AAAAAONt/6wGI884Zi6sYDYC1GOV/drnh4OcRrTrqJPoOTUKAAAAZAAAABAAAAACAAAAAAAAAAAAAAABAAAAAAAAAAIAAAABVVNEAAAAAAAuwvNzNk9twbuJHUBqnX26GYI3MbCdpQU9t4n6EVRXsQAAAAA7msoAAAAAAAQI6ATBFImTS1I7Fly9YiufQ/dC4uMOetO+m/BysWXyAAAAAUVVUgAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAAdzWUAAAAAAEAAAAAAAAAAAAAAAHoOTUKAAAAQMs9vNZ518oYUMp38TakovW//DDTbs/9oPj1RAix5ElC/d7gbWaaNNJxKQR7eMNO6rB+ntGqee4WurTJgA4k2ws=', 'GYhEyLRy2qzFtxdpWkyhaseZoT+yz0FS0Z4hF64cVsMAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAIAAAAAAAAAAgAAAAAuwvNzNk9twbuJHUBqnX26GYI3MbCdpQU9t4n6EVRXsQAAAAAAAAABAAAAAAAAAAB3NZQAAAAAAVVTRAAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAAO5rKAAAAAAAuwvNzNk9twbuJHUBqnX26GYI3MbCdpQU9t4n6EVRXsQAAAAAAAAACAAAAAUVVUgAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAAdzWUAAAAAAAAAAAAdzWUAAAAAAAECOgEwRSJk0tSOxZcvWIrn0P3QuLjDnrTvpvwcrFl8gAAAAFFVVIAAAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAAHc1lAAAAAAA', 'AAAAAAAAAAEAAAAKAAAAAwAAABIAAAAAAAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAAlQL4tQAAAAQAAAAAwAAAAIAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAABMAAAAAAAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAAlQL4tQAAAAQAAAAAwAAAAIAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAwAAABEAAAABAAAAAAQI6ATBFImTS1I7Fly9YiufQ/dC4uMOetO+m/BysWXyAAAAAUVVUgAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAABMAAAABAAAAAAQI6ATBFImTS1I7Fly9YiufQ/dC4uMOetO+m/BysWXyAAAAAUVVUgAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAAdzWUAH//////////AAAAAQAAAAAAAAAAAAAAAwAAABIAAAABAAAAAONt/6wGI884Zi6sYDYC1GOV/drnh4OcRrTrqJPoOTUKAAAAAVVTRAAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAAO5rKAH//////////AAAAAQAAAAAAAAAAAAAAAQAAABMAAAABAAAAAONt/6wGI884Zi6sYDYC1GOV/drnh4OcRrTrqJPoOTUKAAAAAVVTRAAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAwAAABIAAAACAAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAAAAAAAEAAAAAAAAAAVVTRAAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAA7msoAAAAAAEAAAACAAAAAAAAAAAAAAAAAAAAAQAAABMAAAACAAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAAAAAAAEAAAAAAAAAAVVTRAAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAAdzWUAAAAAAEAAAACAAAAAAAAAAAAAAAAAAAAAwAAABIAAAACAAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAAAAAAAIAAAABRVVSAAAAAAAuwvNzNk9twbuJHUBqnX26GYI3MbCdpQU9t4n6EVRXsQAAAAAAAAAAstBeAAAAAAEAAAABAAAAAAAAAAAAAAAAAAAAAQAAABMAAAACAAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAAAAAAAIAAAABRVVSAAAAAAAuwvNzNk9twbuJHUBqnX26GYI3MbCdpQU9t4n6EVRXsQAAAAAAAAAAO5rKAAAAAAEAAAABAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAARAAAAAAAAAADjbf+sBiPPOGYurGA2AtRjlf3a54eDnEa066iT6Dk1CgAAAAJUC+OcAAAAEAAAAAEAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAATAAAAAAAAAADjbf+sBiPPOGYurGA2AtRjlf3a54eDnEa066iT6Dk1CgAAAAJUC+M4AAAAEAAAAAIAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{yz281nnXyhhQynfxNqSi9b/8MNNuz/2g+PVECLHkSUL93uBtZpo00nEpBHt4w07qsH6e0ap57ha6tMmADiTbCw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('f08dc1fec150f276562866ce4f5272f658cf0bd9fd8c1d96a22c196be2e1b25a', 20, 1, 'GDRW375MAYR46ODGF2WGANQC2RRZL7O246DYHHCGWTV2RE7IHE2QUQLD', 68719476739, 100, 1, '2016-03-29 19:22:37.80218', '2016-03-29 19:22:37.80218', 85899350016, 'AAAAAONt/6wGI884Zi6sYDYC1GOV/drnh4OcRrTrqJPoOTUKAAAAZAAAABAAAAADAAAAAAAAAAAAAAABAAAAAAAAAAIAAAAAAAAAADuaygAAAAAABAjoBMEUiZNLUjsWXL1iK59D90Li4w56076b8HKxZfIAAAABRVVSAAAAAAAuwvNzNk9twbuJHUBqnX26GYI3MbCdpQU9t4n6EVRXsQAAAAA7msoAAAAAAAAAAAAAAAAB6Dk1CgAAAEB+7jxesBKKrF343onyycjp2tiQLZiGH2ETl+9fuOqotveY2rIgvt9ng+QJ2aDP3+PnDsYEa9ZUaA+Zne2nIGgE', '8I3B/sFQ8nZWKGbOT1Jy9ljPC9n9jB2WoiwZa+LhsloAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAIAAAAAAAAAAQAAAAAuwvNzNk9twbuJHUBqnX26GYI3MbCdpQU9t4n6EVRXsQAAAAAAAAACAAAAAUVVUgAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAAO5rKAAAAAAAAAAAAO5rKAAAAAAAECOgEwRSJk0tSOxZcvWIrn0P3QuLjDnrTvpvwcrFl8gAAAAFFVVIAAAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAADuaygAAAAAA', 'AAAAAAAAAAEAAAAHAAAAAwAAABMAAAAAAAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAAlQL4tQAAAAQAAAAAwAAAAIAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAABQAAAAAAAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAAo+mrNQAAAAQAAAAAwAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAABQAAAAAAAAAAONt/6wGI884Zi6sYDYC1GOV/drnh4OcRrTrqJPoOTUKAAAAAhhxGNQAAAAQAAAAAwAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAwAAABMAAAABAAAAAAQI6ATBFImTS1I7Fly9YiufQ/dC4uMOetO+m/BysWXyAAAAAUVVUgAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAAdzWUAH//////////AAAAAQAAAAAAAAAAAAAAAQAAABQAAAABAAAAAAQI6ATBFImTS1I7Fly9YiufQ/dC4uMOetO+m/BysWXyAAAAAUVVUgAAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAAstBeAH//////////AAAAAQAAAAAAAAAAAAAAAwAAABMAAAACAAAAAC7C83M2T23Bu4kdQGqdfboZgjcxsJ2lBT23ifoRVFexAAAAAAAAAAIAAAABRVVSAAAAAAAuwvNzNk9twbuJHUBqnX26GYI3MbCdpQU9t4n6EVRXsQAAAAAAAAAAO5rKAAAAAAEAAAABAAAAAAAAAAAAAAAAAAAAAgAAAAIAAAAALsLzczZPbcG7iR1Aap19uhmCNzGwnaUFPbeJ+hFUV7EAAAAAAAAAAg==', 'AAAAAgAAAAMAAAATAAAAAAAAAADjbf+sBiPPOGYurGA2AtRjlf3a54eDnEa066iT6Dk1CgAAAAJUC+M4AAAAEAAAAAIAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAUAAAAAAAAAADjbf+sBiPPOGYurGA2AtRjlf3a54eDnEa066iT6Dk1CgAAAAJUC+LUAAAAEAAAAAMAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{fu48XrASiqxd+N6J8snI6drYkC2Yhh9hE5fvX7jqqLb3mNqyIL7fZ4PkCdmgz9/j5w7GBGvWVGgPmZ3tpyBoBA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('2a6987a6930eab7e3becacf9b76ed7a06802668c1f1eb0f82f5671014b4b636a', 21, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 11, 100, 1, '2016-03-29 19:22:37.807422', '2016-03-29 19:22:37.807422', 90194317312, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAALAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAXK+F1JOs84QNDhnmIjjKUDQ+mEvueZwDL/tCVRXFjncAAAACVAvkAAAAAAAAAAABVvwF9wAAAEDfpUesb4kQ/RfBx1UxqNOtZ2+4R4S0XxzggPR1C3YyhZAr/K8KyZCg4ejDTFnhu9qAh4GLZLkbBraGncT9DcYF', 'KmmHppMOq3477Kz5t27XoGgCZowfHrD4L1ZxAUtLY2oAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAABUAAAAAAAAAAFyvhdSTrPOEDQ4Z5iI4ylA0PphL7nmcAy/7QlUVxY53AAAAAlQL5AAAAAAVAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAABUAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2mhkvS1AAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAQAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtpxtOzAYAAAAAAAAAAoAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAVAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtpxtOy+0AAAAAAAAAAsAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{36VHrG+JEP0XwcdVMajTrWdvuEeEtF8c4ID0dQt2MoWQK/yvCsmQoOHow0xZ4bvagIeBi2S5Gwa2hp3E/Q3GBQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('96415ac1d2f79621b26b1568f963fd8dd6c50c20a22c7428cefbfe9dee867588', 21, 2, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 12, 100, 1, '2016-03-29 19:22:37.809907', '2016-03-29 19:22:37.809907', 90194321408, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAAMAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAdQRiekAoVkbqXJa3xIIXnCcZLADk+cVfmZs9SLHWDWEAAAACVAvkAAAAAAAAAAABVvwF9wAAAEDdJGdvdZ2S4QoXdO+Odt8ZRdeVu7mBvq7FtP9okqr98pGD/jSAraklQvaRmCyMALIMD2kG8R2KjhKvy7oIL6IB', 'lkFawdL3liGyaxVo+WP9jdbFDCCiLHQozvv+ne6GdYgAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAABUAAAAAAAAAAHUEYnpAKFZG6lyWt8SCF5wnGSwA5PnFX5mbPUix1g1hAAAAAlQL5AAAAAAVAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAABUAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2l8UjZ1AAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAVAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtpxtOy9QAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{3SRnb3WdkuEKF3TvjnbfGUXXlbu5gb6uxbT/aJKq/fKRg/40gK2pJUL2kZgsjACyDA9pBvEdio4Sr8u6CC+iAQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('be05e4bd966d58689e1b6fae013e5aa77bde56e6acd2db9b96870e5e746a4ab7', 22, 1, 'GBOK7BOUSOWPHBANBYM6MIRYZJIDIPUYJPXHTHADF75UEVIVYWHHONQC', 90194313217, 100, 1, '2016-03-29 19:22:37.815644', '2016-03-29 19:22:37.815644', 94489284608, 'AAAAAFyvhdSTrPOEDQ4Z5iI4ylA0PphL7nmcAy/7QlUVxY53AAAAZAAAABUAAAABAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABVVNEAAAAAAB1BGJ6QChWRupclrfEghecJxksAOT5xV+Zmz1IsdYNYX//////////AAAAAAAAAAEVxY53AAAAQDMCWfC0eGNJuYIX3s5AUNLernpcHTn8O6ygq/Nw3S5vny/W42O5G4G6UsihVU1xd5bR4im2+VzQlQYQhe0jhwg=', 'vgXkvZZtWGieG2+uAT5ap3veVuas0tublocOXnRqSrcAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAYAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAABYAAAABAAAAAFyvhdSTrPOEDQ4Z5iI4ylA0PphL7nmcAy/7QlUVxY53AAAAAVVTRAAAAAAAdQRiekAoVkbqXJa3xIIXnCcZLADk+cVfmZs9SLHWDWEAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAABYAAAAAAAAAAFyvhdSTrPOEDQ4Z5iI4ylA0PphL7nmcAy/7QlUVxY53AAAAAlQL45wAAAAVAAAAAQAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAVAAAAAAAAAABcr4XUk6zzhA0OGeYiOMpQND6YS+55nAMv+0JVFcWOdwAAAAJUC+QAAAAAFQAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAWAAAAAAAAAABcr4XUk6zzhA0OGeYiOMpQND6YS+55nAMv+0JVFcWOdwAAAAJUC+OcAAAAFQAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{MwJZ8LR4Y0m5ghfezkBQ0t6uelwdOfw7rKCr83DdLm+fL9bjY7kbgbpSyKFVTXF3ltHiKbb5XNCVBhCF7SOHCA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('d8b2508123656b1df1ee17c2767829bc22ab41959ad25e6ccc520e849516fba1', 23, 1, 'GBOK7BOUSOWPHBANBYM6MIRYZJIDIPUYJPXHTHADF75UEVIVYWHHONQC', 90194313218, 100, 1, '2016-03-29 19:22:37.820124', '2016-03-29 19:22:37.820124', 98784251904, 'AAAAAFyvhdSTrPOEDQ4Z5iI4ylA0PphL7nmcAy/7QlUVxY53AAAAZAAAABUAAAACAAAAAAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAdQRiekAoVkbqXJa3xIIXnCcZLADk+cVfmZs9SLHWDWEAAAAAC+vCAAAAAAEAAAABAAAAAAAAAAAAAAAAAAAAARXFjncAAABATR48xYiKbu8AOoXFwvcvILZ0/pQkfGuwwAoIZNefr7ydIwlcuL44XPM7pJ/6jDSbqBudTNWdE2JRjuq7HI7IAA==', '2LJQgSNlax3x7hfCdngpvCKrQZWa0l5szFIOhJUW+6EAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAAAAAAAAAAAAXK+F1JOs84QNDhnmIjjKUDQ+mEvueZwDL/tCVRXFjncAAAAAAAAAAwAAAAAAAAABVVNEAAAAAAB1BGJ6QChWRupclrfEghecJxksAOT5xV+Zmz1IsdYNYQAAAAAL68IAAAAAAQAAAAEAAAAAAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAABcAAAACAAAAAFyvhdSTrPOEDQ4Z5iI4ylA0PphL7nmcAy/7QlUVxY53AAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAdQRiekAoVkbqXJa3xIIXnCcZLADk+cVfmZs9SLHWDWEAAAAAC+vCAAAAAAEAAAABAAAAAAAAAAAAAAAAAAAAAQAAABcAAAAAAAAAAFyvhdSTrPOEDQ4Z5iI4ylA0PphL7nmcAy/7QlUVxY53AAAAAlQL4zgAAAAVAAAAAgAAAAIAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAWAAAAAAAAAABcr4XUk6zzhA0OGeYiOMpQND6YS+55nAMv+0JVFcWOdwAAAAJUC+OcAAAAFQAAAAEAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAXAAAAAAAAAABcr4XUk6zzhA0OGeYiOMpQND6YS+55nAMv+0JVFcWOdwAAAAJUC+M4AAAAFQAAAAIAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{TR48xYiKbu8AOoXFwvcvILZ0/pQkfGuwwAoIZNefr7ydIwlcuL44XPM7pJ/6jDSbqBudTNWdE2JRjuq7HI7IAA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('fe3707fbd5c844395c598f31dc719c61218d4cea4e8dddadb6733f4866089100', 28, 1, 'GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES', 115964116993, 100, 1, '2016-03-29 19:22:37.847576', '2016-03-29 19:22:37.847576', 120259088384, 'AAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAZAAAABsAAAABAAAAAAAAAAAAAAABAAAAAAAAAAUAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAQAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABMJ4wUAAAAEA/GIgE9sYPGwbCiIdLdhoEu25CyB0ZAcmjQonQItu6SE0gaSBVT/le355A/dw1NPaoXY9P/u0ou9D7h5Vb1fcK', '/jcH+9XIRDlcWY8x3HGcYSGNTOpOjd2ttnM/SGYIkQAAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAA==', 'AAAAAAAAAAEAAAABAAAAAQAAABwAAAAAAAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAAlQL4UQAAAAbAAAABwAAAAAAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAbAAAAAAAAAACQUsYKOw/kj+JXXI5eosCY2LS+fgH0zFHZXnenMJ4wUAAAAAJUC+QAAAAAGwAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAcAAAAAAAAAACQUsYKOw/kj+JXXI5eosCY2LS+fgH0zFHZXnenMJ4wUAAAAAJUC+OcAAAAGwAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{PxiIBPbGDxsGwoiHS3YaBLtuQsgdGQHJo0KJ0CLbukhNIGkgVU/5Xt+eQP3cNTT2qF2PT/7tKLvQ+4eVW9X3Cg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('01346de1ca30ce03149d9f54945956a22f9cbed3d81f81c62bb59cf8cdd8b893', 24, 1, 'GB2QIYT2IAUFMRXKLSLLPRECC6OCOGJMADSPTRK7TGNT2SFR2YGWDARD', 90194313217, 100, 1, '2016-03-29 19:22:37.825211', '2016-03-29 19:22:37.825211', 103079219200, 'AAAAAHUEYnpAKFZG6lyWt8SCF5wnGSwA5PnFX5mbPUix1g1hAAAAZAAAABUAAAABAAAAAAAAAAAAAAABAAAAAAAAAAMAAAABVVNEAAAAAAB1BGJ6QChWRupclrfEghecJxksAOT5xV+Zmz1IsdYNYQAAAAAAAAAAEeGjAAAAAAEAAAABAAAAAAAAAAAAAAAAAAAAAbHWDWEAAABA0L+69D1hxpytAkX6cvPiBuO80ql8SQKZ15POVxx9wYl6mZrL+6UWGab/+6ng2M+a29E7ON+Xs46Y9MNqTh91AQ==', 'ATRt4cowzgMUnZ9UlFlWoi+cvtPYH4HGK7Wc+M3YuJMAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAQAAAABcr4XUk6zzhA0OGeYiOMpQND6YS+55nAMv+0JVFcWOdwAAAAAAAAADAAAAAAAAAAAL68IAAAAAAVVTRAAAAAAAdQRiekAoVkbqXJa3xIIXnCcZLADk+cVfmZs9SLHWDWEAAAAAC+vCAAAAAAAAAAAAdQRiekAoVkbqXJa3xIIXnCcZLADk+cVfmZs9SLHWDWEAAAAAAAAABAAAAAFVU0QAAAAAAHUEYnpAKFZG6lyWt8SCF5wnGSwA5PnFX5mbPUix1g1hAAAAAAAAAAAF9eEAAAAAAQAAAAEAAAAAAAAAAAAAAAA=', 'AAAAAAAAAAEAAAAHAAAAAAAAABgAAAACAAAAAHUEYnpAKFZG6lyWt8SCF5wnGSwA5PnFX5mbPUix1g1hAAAAAAAAAAQAAAABVVNEAAAAAAB1BGJ6QChWRupclrfEghecJxksAOT5xV+Zmz1IsdYNYQAAAAAAAAAABfXhAAAAAAEAAAABAAAAAAAAAAAAAAAAAAAAAwAAABcAAAAAAAAAAFyvhdSTrPOEDQ4Z5iI4ylA0PphL7nmcAy/7QlUVxY53AAAAAlQL4zgAAAAVAAAAAgAAAAIAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAABgAAAAAAAAAAFyvhdSTrPOEDQ4Z5iI4ylA0PphL7nmcAy/7QlUVxY53AAAAAkggITgAAAAVAAAAAgAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAABgAAAAAAAAAAHUEYnpAKFZG6lyWt8SCF5wnGSwA5PnFX5mbPUix1g1hAAAAAl/3pZwAAAAVAAAAAQAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAABgAAAABAAAAAFyvhdSTrPOEDQ4Z5iI4ylA0PphL7nmcAy/7QlUVxY53AAAAAVVTRAAAAAAAdQRiekAoVkbqXJa3xIIXnCcZLADk+cVfmZs9SLHWDWEAAAAAC+vCAH//////////AAAAAQAAAAAAAAAAAAAAAwAAABcAAAACAAAAAFyvhdSTrPOEDQ4Z5iI4ylA0PphL7nmcAy/7QlUVxY53AAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAdQRiekAoVkbqXJa3xIIXnCcZLADk+cVfmZs9SLHWDWEAAAAAC+vCAAAAAAEAAAABAAAAAAAAAAAAAAAAAAAAAgAAAAIAAAAAXK+F1JOs84QNDhnmIjjKUDQ+mEvueZwDL/tCVRXFjncAAAAAAAAAAw==', 'AAAAAgAAAAMAAAAVAAAAAAAAAAB1BGJ6QChWRupclrfEghecJxksAOT5xV+Zmz1IsdYNYQAAAAJUC+QAAAAAFQAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAYAAAAAAAAAAB1BGJ6QChWRupclrfEghecJxksAOT5xV+Zmz1IsdYNYQAAAAJUC+OcAAAAFQAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{0L+69D1hxpytAkX6cvPiBuO80ql8SQKZ15POVxx9wYl6mZrL+6UWGab/+6ng2M+a29E7ON+Xs46Y9MNqTh91AQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('5065cd7c97cfb6fbf7da8493beed47ed2c7efb3b00b77a4c92692ed487fb86a4', 25, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 13, 100, 1, '2016-03-29 19:22:37.831283', '2016-03-29 19:22:37.831283', 107374186496, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAANAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAfGbtaaW8nEfkG5PP1Cf4+dZxNj3MryzpiAiOpDJuhhgAAAACVAvkAAAAAAAAAAABVvwF9wAAAEBthwT3JCg5IZkKRNK3pHBa/eG8zq8Af9gFPWlYvEdRo6jzA5D9fYOcDpKD3dEAuPLNNAHj9tNbZUJA3rwxN94B', 'UGXNfJfPtvv32oSTvu1H7Sx++zsAt3pMkmku1If7hqQAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAABkAAAAAAAAAAHxm7WmlvJxH5BuTz9Qn+PnWcTY9zK8s6YgIjqQyboYYAAAAAlQL5AAAAAAZAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAABkAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2lXEXguwAAAAAAAAADQAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAVAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtpfFI2dQAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAZAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtpfFI2bsAAAAAAAAAA0AAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{bYcE9yQoOSGZCkTSt6RwWv3hvM6vAH/YBT1pWLxHUaOo8wOQ/X2DnA6Sg93RALjyzTQB4/bTW2VCQN68MTfeAQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('a76e0260f6b83c6ea93f545d17de721c079dc31e81ee5edc41f159ec5fb48443', 26, 1, 'GB6GN3LJUW6JYR7EDOJ47VBH7D45M4JWHXGK6LHJRAEI5JBSN2DBQY7Q', 107374182401, 100, 1, '2016-03-29 19:22:37.836873', '2016-03-29 19:22:37.836873', 111669153792, 'AAAAAHxm7WmlvJxH5BuTz9Qn+PnWcTY9zK8s6YgIjqQyboYYAAAAZAAAABkAAAABAAAAAAAAAAAAAAABAAAAAAAAAAQAAAABVVNEAAAAAAB8Zu1ppbycR+Qbk8/UJ/j51nE2PcyvLOmICI6kMm6GGAAAAAAAAAAAdzWUAAAAAAEAAAABAAAAAAAAAAEyboYYAAAAQBqzCYDuLYn/jXhfEVxEGigMCJGoOBCK92lUb3Um15PgwSJ63tNl+FpH8+y5c+mCs/rzcvdyo9uXdodd4LXWiQg=', 'p24CYPa4PG6pP1RdF95yHAedwx6B7l7cQfFZ7F+0hEMAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAAAAAAAAAAAAfGbtaaW8nEfkG5PP1Cf4+dZxNj3MryzpiAiOpDJuhhgAAAAAAAAABQAAAAFVU0QAAAAAAHxm7WmlvJxH5BuTz9Qn+PnWcTY9zK8s6YgIjqQyboYYAAAAAAAAAAB3NZQAAAAAAQAAAAEAAAABAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAABoAAAACAAAAAHxm7WmlvJxH5BuTz9Qn+PnWcTY9zK8s6YgIjqQyboYYAAAAAAAAAAUAAAABVVNEAAAAAAB8Zu1ppbycR+Qbk8/UJ/j51nE2PcyvLOmICI6kMm6GGAAAAAAAAAAAdzWUAAAAAAEAAAABAAAAAQAAAAAAAAAAAAAAAQAAABoAAAAAAAAAAHxm7WmlvJxH5BuTz9Qn+PnWcTY9zK8s6YgIjqQyboYYAAAAAlQL4zgAAAAZAAAAAgAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAZAAAAAAAAAAB8Zu1ppbycR+Qbk8/UJ/j51nE2PcyvLOmICI6kMm6GGAAAAAJUC+QAAAAAGQAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAaAAAAAAAAAAB8Zu1ppbycR+Qbk8/UJ/j51nE2PcyvLOmICI6kMm6GGAAAAAJUC+OcAAAAGQAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{GrMJgO4tif+NeF8RXEQaKAwIkag4EIr3aVRvdSbXk+DBInre02X4Wkfz7Llz6YKz+vNy93Kj25d2h13gtdaJCA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('92a654c76966ac61acc9df0b75f91cbde3b551c9e9766730827af42d1e247cc3', 26, 2, 'GB6GN3LJUW6JYR7EDOJ47VBH7D45M4JWHXGK6LHJRAEI5JBSN2DBQY7Q', 107374182402, 100, 1, '2016-03-29 19:22:37.837894', '2016-03-29 19:22:37.837894', 111669157888, 'AAAAAHxm7WmlvJxH5BuTz9Qn+PnWcTY9zK8s6YgIjqQyboYYAAAAZAAAABkAAAACAAAAAAAAAAAAAAABAAAAAAAAAAQAAAAAAAAAAVVTRAAAAAAAfGbtaaW8nEfkG5PP1Cf4+dZxNj3MryzpiAiOpDJuhhgAAAAAdzWUAAAAAAEAAAABAAAAAAAAAAEyboYYAAAAQBbE9T7oBKoN0/S3AV7GoSRe+xT79SlWNCYEtL1RPExL8FLhw5EDsXLoAvIBbBvHIr9NKcPtWDyhcHlIuaZKIg8=', 'kqZUx2lmrGGsyd8LdfkcveO1Ucnpdmcwgnr0LR4kfMMAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAAAAAAAAAAAAfGbtaaW8nEfkG5PP1Cf4+dZxNj3MryzpiAiOpDJuhhgAAAAAAAAABgAAAAAAAAABVVNEAAAAAAB8Zu1ppbycR+Qbk8/UJ/j51nE2PcyvLOmICI6kMm6GGAAAAAB3NZQAAAAAAQAAAAEAAAABAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAABoAAAACAAAAAHxm7WmlvJxH5BuTz9Qn+PnWcTY9zK8s6YgIjqQyboYYAAAAAAAAAAYAAAAAAAAAAVVTRAAAAAAAfGbtaaW8nEfkG5PP1Cf4+dZxNj3MryzpiAiOpDJuhhgAAAAAdzWUAAAAAAEAAAABAAAAAQAAAAAAAAAAAAAAAQAAABoAAAAAAAAAAHxm7WmlvJxH5BuTz9Qn+PnWcTY9zK8s6YgIjqQyboYYAAAAAlQL4zgAAAAZAAAAAgAAAAIAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAaAAAAAAAAAAB8Zu1ppbycR+Qbk8/UJ/j51nE2PcyvLOmICI6kMm6GGAAAAAJUC+M4AAAAGQAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{FsT1PugEqg3T9LcBXsahJF77FPv1KVY0JgS0vVE8TEvwUuHDkQOxcugC8gFsG8civ00pw+1YPKFweUi5pkoiDw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('700fa44bb40e6ad2c5888656cd2e7b8d86de3d3557b653ae6874466175d64927', 27, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 14, 100, 1, '2016-03-29 19:22:37.841887', '2016-03-29 19:22:37.841887', 115964121088, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAAOAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAkFLGCjsP5I/iV1yOXqLAmNi0vn4B9MxR2V53pzCeMFAAAAACVAvkAAAAAAAAAAABVvwF9wAAAEBq3GPDVeRPfwqtW45GZNiUdQ9j6E9Nsz/lMYWcWDWGCZADSsEiEoXar1HWFK6drptsGEl9P6I9f7C2GBKb4YQM', 'cA+kS7QOatLFiIZWzS57jYbePTVXtlOuaHRGYXXWSScAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAABsAAAAAAAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAAlQL5AAAAAAbAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAABsAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2kx0LnogAAAAAAAAADgAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAZAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtpVxF4LsAAAAAAAAAA0AAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAbAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtpVxF4KIAAAAAAAAAA4AAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{atxjw1XkT38KrVuORmTYlHUPY+hPTbM/5TGFnFg1hgmQA0rBIhKF2q9R1hSuna6bbBhJfT+iPX+wthgSm+GEDA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('345ef7f85c6ea297e3f994feef279b63812628681bd173a1f615185a4368e482', 28, 2, 'GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES', 115964116994, 100, 1, '2016-03-29 19:22:37.848826', '2016-03-29 19:22:37.848826', 120259092480, 'AAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAZAAAABsAAAACAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABMJ4wUAAAAEDYxq3zpaFIC2JcuJUbrQ3MFXzqvu+5G7XUi4NnHlfbLutn76ylQcjuwLgbUG2lqcQfl75doPUZyurKtFP1rkMO', 'NF73+Fxuopfj+ZT+7yebY4EmKGgb0XOh9hUYWkNo5IIAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAA==', 'AAAAAAAAAAEAAAABAAAAAQAAABwAAAAAAAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAAlQL4UQAAAAbAAAABwAAAAAAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAQAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAcAAAAAAAAAACQUsYKOw/kj+JXXI5eosCY2LS+fgH0zFHZXnenMJ4wUAAAAAJUC+M4AAAAGwAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{2Mat86WhSAtiXLiVG60NzBV86r7vuRu11IuDZx5X2y7rZ++spUHI7sC4G1BtpanEH5e+XaD1GcrqyrRT9a5DDg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('2a14735d7b05109359444acdd87e7fe92c98e9295d2ba61b05e25d1f7ee10fd3', 28, 3, 'GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES', 115964116995, 100, 1, '2016-03-29 19:22:37.850206', '2016-03-29 19:22:37.850207', 120259096576, 'AAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAZAAAABsAAAADAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABMJ4wUAAAAEAKuQ1exMu8hdf8dOPeULX2DG7DZx5WWIUFHXJMWGG9KmVrQoZDt2S6a/1uYEVJnvvY/EoJM5RpVjh2ZCs30VYA', 'KhRzXXsFEJNZRErN2H5/6SyY6SldK6YbBeJdH37hD9MAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAA==', 'AAAAAAAAAAEAAAABAAAAAQAAABwAAAAAAAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAAlQL4UQAAAAbAAAABwAAAAAAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAwAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAcAAAAAAAAAACQUsYKOw/kj+JXXI5eosCY2LS+fgH0zFHZXnenMJ4wUAAAAAJUC+LUAAAAGwAAAAMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{CrkNXsTLvIXX/HTj3lC19gxuw2ceVliFBR1yTFhhvSpla0KGQ7dkumv9bmBFSZ772PxKCTOUaVY4dmQrN9FWAA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('4f9598206ab17cf27b5c3eb9e906d63ebee2626654112eabdd2bce7bf12cccf2', 28, 4, 'GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES', 115964116996, 100, 1, '2016-03-29 19:22:37.851597', '2016-03-29 19:22:37.851597', 120259100672, 'AAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAZAAAABsAAAAEAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAEAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAATCeMFAAAABAAd6MzHDjUdRtHozzDnD3jJA+uRDCar3PQtuH/43pnROzk1HkovJPQ1YyzcpOb/NeuU/LKNzseL0PJNasVX1lAQ==', 'T5WYIGqxfPJ7XD656QbWPr7iYmZUES6r3SvOe/EszPIAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAA==', 'AAAAAAAAAAEAAAABAAAAAQAAABwAAAAAAAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAAlQL4UQAAAAbAAAABwAAAAAAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAwAAAAACAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAcAAAAAAAAAACQUsYKOw/kj+JXXI5eosCY2LS+fgH0zFHZXnenMJ4wUAAAAAJUC+JwAAAAGwAAAAQAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{Ad6MzHDjUdRtHozzDnD3jJA+uRDCar3PQtuH/43pnROzk1HkovJPQ1YyzcpOb/NeuU/LKNzseL0PJNasVX1lAQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('852ba25e0e4aa149a22dc193bcb645ae9eba23e7f7432707f3b910474e9b6a5b', 28, 5, 'GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES', 115964116997, 100, 1, '2016-03-29 19:22:37.852745', '2016-03-29 19:22:37.852745', 120259104768, 'AAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAZAAAABsAAAAFAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAAAAAABAAAAAAAAAAEAAAACAAAAAQAAAAIAAAAAAAAAAAAAAAAAAAABMJ4wUAAAAEAnFzc6kqweyIL4TzIDbr+8GUOGGs1W5jcX5iSNw4DeonzQARlejYJ9NOn/XkrcoC9Hvd8hc5lNx+1h991GxJUJ', 'hSuiXg5KoUmiLcGTvLZFrp66I+f3QycH87kQR06balsAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAA==', 'AAAAAAAAAAEAAAABAAAAAQAAABwAAAAAAAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAAlQL4UQAAAAbAAAABwAAAAAAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAwAAAAACAAICAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAcAAAAAAAAAACQUsYKOw/kj+JXXI5eosCY2LS+fgH0zFHZXnenMJ4wUAAAAAJUC+IMAAAAGwAAAAUAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{Jxc3OpKsHsiC+E8yA26/vBlDhhrNVuY3F+YkjcOA3qJ80AEZXo2CfTTp/15K3KAvR73fIXOZTcftYffdRsSVCQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('8ccc0c28c3e99a63cc59bad7dec3f5c56eb3942c548ecd40bc39c509d6b081d4', 28, 6, 'GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES', 115964116998, 100, 1, '2016-03-29 19:22:37.854084', '2016-03-29 19:22:37.854084', 120259108864, 'AAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAZAAAABsAAAAGAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAC2V4YW1wbGUuY29tAAAAAAAAAAAAAAAAATCeMFAAAABAkID6CkBHP9eovLQXkMQJ7QkE6NWlmdKGmLxaiI1YaVKZaKJxz5P85x+6wzpYxxbs6Bd2l4qxVjS7Q36DwRiqBA==', 'jMwMKMPpmmPMWbrX3sP1xW6zlCxUjs1AvDnFCdawgdQAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAA==', 'AAAAAAAAAAEAAAABAAAAAQAAABwAAAAAAAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAAlQL4UQAAAAbAAAABwAAAAAAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAwAAAAtleGFtcGxlLmNvbQACAAICAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAcAAAAAAAAAACQUsYKOw/kj+JXXI5eosCY2LS+fgH0zFHZXnenMJ4wUAAAAAJUC+GoAAAAGwAAAAYAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{kID6CkBHP9eovLQXkMQJ7QkE6NWlmdKGmLxaiI1YaVKZaKJxz5P85x+6wzpYxxbs6Bd2l4qxVjS7Q36DwRiqBA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('83201014880073f8eff6f21ae76e51c2c4faf533e550ecd3c2205b48a092960a', 28, 7, 'GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES', 115964116999, 100, 1, '2016-03-29 19:22:37.855485', '2016-03-29 19:22:37.855485', 120259112960, 'AAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAZAAAABsAAAAHAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAB8ndnLViBPKqPJAcSNhZzc2mH7fQ7RtzGyFA8mFkMTkAAAAAEAAAAAAAAAATCeMFAAAABAtYtlsqMReQo1UoU2GYjb3h52wEKvnouCSO6LQO1xm/ArhtQO/sX5q35St8BjaYWEiFnp+SQj2FZC89OswCldAw==', 'gyAQFIgAc/jv9vIa525RwsT69TPlUOzTwiBbSKCSlgoAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAA==', 'AAAAAAAAAAEAAAABAAAAAQAAABwAAAAAAAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAAlQL4UQAAAAbAAAABwAAAAEAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAwAAAAtleGFtcGxlLmNvbQACAAICAAAAAQAAAAB8ndnLViBPKqPJAcSNhZzc2mH7fQ7RtzGyFA8mFkMTkAAAAAEAAAAAAAAAAA==', 'AAAAAQAAAAEAAAAcAAAAAAAAAACQUsYKOw/kj+JXXI5eosCY2LS+fgH0zFHZXnenMJ4wUAAAAAJUC+FEAAAAGwAAAAcAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{tYtlsqMReQo1UoU2GYjb3h52wEKvnouCSO6LQO1xm/ArhtQO/sX5q35St8BjaYWEiFnp+SQj2FZC89OswCldAw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('69f64ae0f809b08996c1f394ee795001a40eee69adb675ab63bfd1932d3aafb2', 29, 1, 'GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES', 115964117000, 100, 1, '2016-03-29 19:22:37.860188', '2016-03-29 19:22:37.860188', 124554055680, 'AAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAZAAAABsAAAAIAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAEAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAATCeMFAAAABAi69qDHclVS9A8GAaqyk6oIxiMC2KXXEneFijfxH5VyLGIQZNAxOOcCPpIalU6P1pYRX3K4OlKHZ4hIdxJzD6BQ==', 'afZK4PgJsImWwfOU7nlQAaQO7mmttnWrY7/Rky06r7IAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAA==', 'AAAAAAAAAAEAAAABAAAAAQAAAB0AAAAAAAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAAlQL4OAAAAAbAAAACAAAAAEAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAwAAAAtleGFtcGxlLmNvbQACAAICAAAAAQAAAAB8ndnLViBPKqPJAcSNhZzc2mH7fQ7RtzGyFA8mFkMTkAAAAAEAAAAAAAAAAA==', 'AAAAAgAAAAMAAAAcAAAAAAAAAACQUsYKOw/kj+JXXI5eosCY2LS+fgH0zFHZXnenMJ4wUAAAAAJUC+FEAAAAGwAAAAcAAAABAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAMAAAALZXhhbXBsZS5jb20AAgACAgAAAAEAAAAAfJ3Zy1YgTyqjyQHEjYWc3Nph+30O0bcxshQPJhZDE5AAAAABAAAAAAAAAAAAAAABAAAAHQAAAAAAAAAAkFLGCjsP5I/iV1yOXqLAmNi0vn4B9MxR2V53pzCeMFAAAAACVAvg4AAAABsAAAAIAAAAAQAAAAEAAAAAYvwdC9CRsrYcDdZWNGsqaNfTR8bywsjubQRHAlb8BfcAAAADAAAAC2V4YW1wbGUuY29tAAIAAgIAAAABAAAAAHyd2ctWIE8qo8kBxI2FnNzaYft9DtG3MbIUDyYWQxOQAAAAAQAAAAAAAAAA', '{i69qDHclVS9A8GAaqyk6oIxiMC2KXXEneFijfxH5VyLGIQZNAxOOcCPpIalU6P1pYRX3K4OlKHZ4hIdxJzD6BQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('a05daae230b1f743474e83ab6d4817df1f3f77661a7d815f7620cee2a9809480', 34, 1, 'GCJKJXPKBFIHOO3455WXWG5CDBZXQNYFRRGICYMPUQ35CPQ4WVS3KZLG', 141733920769, 100, 1, '2016-03-29 19:22:37.885813', '2016-03-29 19:22:37.885813', 146028892160, 'AAAAAJKk3eoJUHc7fO9texuiGHN4NwWMTIFhj6Q30T4ctWW1AAAAZAAAACEAAAABAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABVVNEAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF93//////////AAAAAAAAAAEctWW1AAAAQBYUnV3I1O35EAyay0msjg3MzZfanCtvalKGG+94pe6RxgE/kCk2kTT9HXgXjbraq//Q/0vJ0AoCAXSeT18Ujgk=', 'oF2q4jCx90NHToOrbUgX3x8/d2YafYFfdiDO4qmAlIAAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAYAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAACIAAAABAAAAAJKk3eoJUHc7fO9texuiGHN4NwWMTIFhj6Q30T4ctWW1AAAAAVVTRAAAAAAAYvwdC9CRsrYcDdZWNGsqaNfTR8bywsjubQRHAlb8BfcAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAACIAAAAAAAAAAJKk3eoJUHc7fO9texuiGHN4NwWMTIFhj6Q30T4ctWW1AAAAAlQL45wAAAAhAAAAAQAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAhAAAAAAAAAACSpN3qCVB3O3zvbXsbohhzeDcFjEyBYY+kN9E+HLVltQAAAAJUC+QAAAAAIQAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAiAAAAAAAAAACSpN3qCVB3O3zvbXsbohhzeDcFjEyBYY+kN9E+HLVltQAAAAJUC+OcAAAAIQAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{FhSdXcjU7fkQDJrLSayODczNl9qcK29qUoYb73il7pHGAT+QKTaRNP0deBeNutqr/9D/S8nQCgIBdJ5PXxSOCQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('c3cd47a311e025446f72c50426b5b5444e5261431fc5760e8e57467c87cd49fc', 30, 1, 'GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES', 115964117001, 100, 1, '2016-03-29 19:22:37.864696', '2016-03-29 19:22:37.864696', 128849022976, 'AAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAZAAAABsAAAAJAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAB8ndnLViBPKqPJAcSNhZzc2mH7fQ7RtzGyFA8mFkMTkAAAAAEAAAAAAAAAATCeMFAAAABA7ZMKq80ucQSt+55q+6VQrG3Hrv6zHtOLwkfAxxsZdYPIuk7xZsgbyhOCVXjheOQ9ygAW1vtybdXG41AxSFRtAg==', 'w81HoxHgJURvcsUEJrW1RE5SYUMfxXYOjldGfIfNSfwAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAA==', 'AAAAAAAAAAEAAAABAAAAAQAAAB4AAAAAAAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAAlQL4HwAAAAbAAAACQAAAAEAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAwAAAAtleGFtcGxlLmNvbQACAAICAAAAAQAAAAB8ndnLViBPKqPJAcSNhZzc2mH7fQ7RtzGyFA8mFkMTkAAAAAEAAAAAAAAAAA==', 'AAAAAgAAAAMAAAAdAAAAAAAAAACQUsYKOw/kj+JXXI5eosCY2LS+fgH0zFHZXnenMJ4wUAAAAAJUC+DgAAAAGwAAAAgAAAABAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAMAAAALZXhhbXBsZS5jb20AAgACAgAAAAEAAAAAfJ3Zy1YgTyqjyQHEjYWc3Nph+30O0bcxshQPJhZDE5AAAAABAAAAAAAAAAAAAAABAAAAHgAAAAAAAAAAkFLGCjsP5I/iV1yOXqLAmNi0vn4B9MxR2V53pzCeMFAAAAACVAvgfAAAABsAAAAJAAAAAQAAAAEAAAAAYvwdC9CRsrYcDdZWNGsqaNfTR8bywsjubQRHAlb8BfcAAAADAAAAC2V4YW1wbGUuY29tAAIAAgIAAAABAAAAAHyd2ctWIE8qo8kBxI2FnNzaYft9DtG3MbIUDyYWQxOQAAAAAQAAAAAAAAAA', '{7ZMKq80ucQSt+55q+6VQrG3Hrv6zHtOLwkfAxxsZdYPIuk7xZsgbyhOCVXjheOQ9ygAW1vtybdXG41AxSFRtAg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('299dc6631d585a55ae3602f660ec5b5a0088d24a14b344c72eccc2a62d9a8938', 31, 1, 'GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES', 115964117002, 100, 1, '2016-03-29 19:22:37.869007', '2016-03-29 19:22:37.869007', 133143990272, 'AAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAZAAAABsAAAAKAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAB8ndnLViBPKqPJAcSNhZzc2mH7fQ7RtzGyFA8mFkMTkAAAAAUAAAAAAAAAATCeMFAAAABA0wriernSr+5P2QCeon1uj5mrOLNTOrPYPPi5ricLug/nreEUhsgS/k3lA9JGpVbd+tacMEKmXKmFxHCEMjWPBg==', 'KZ3GYx1YWlWuNgL2YOxbWgCI0koUs0THLszCpi2aiTgAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAA==', 'AAAAAAAAAAEAAAABAAAAAQAAAB8AAAAAAAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAAlQL4BgAAAAbAAAACgAAAAEAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAwAAAAtleGFtcGxlLmNvbQACAAICAAAAAQAAAAB8ndnLViBPKqPJAcSNhZzc2mH7fQ7RtzGyFA8mFkMTkAAAAAUAAAAAAAAAAA==', 'AAAAAgAAAAMAAAAeAAAAAAAAAACQUsYKOw/kj+JXXI5eosCY2LS+fgH0zFHZXnenMJ4wUAAAAAJUC+B8AAAAGwAAAAkAAAABAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAMAAAALZXhhbXBsZS5jb20AAgACAgAAAAEAAAAAfJ3Zy1YgTyqjyQHEjYWc3Nph+30O0bcxshQPJhZDE5AAAAABAAAAAAAAAAAAAAABAAAAHwAAAAAAAAAAkFLGCjsP5I/iV1yOXqLAmNi0vn4B9MxR2V53pzCeMFAAAAACVAvgGAAAABsAAAAKAAAAAQAAAAEAAAAAYvwdC9CRsrYcDdZWNGsqaNfTR8bywsjubQRHAlb8BfcAAAADAAAAC2V4YW1wbGUuY29tAAIAAgIAAAABAAAAAHyd2ctWIE8qo8kBxI2FnNzaYft9DtG3MbIUDyYWQxOQAAAAAQAAAAAAAAAA', '{0wriernSr+5P2QCeon1uj5mrOLNTOrPYPPi5ricLug/nreEUhsgS/k3lA9JGpVbd+tacMEKmXKmFxHCEMjWPBg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('bb9d6654111fae501594400dc901c70d47489a67163d2a34f9b3e32a921a50dc', 32, 1, 'GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES', 115964117003, 100, 1, '2016-03-29 19:22:37.873533', '2016-03-29 19:22:37.873534', 137438957568, 'AAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAZAAAABsAAAALAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAMAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABMJ4wUAAAAEAFytUxjxN4bnJMrEJkSprnES9iGpOxAsNOFYrTP/xtGVk/PZ2oThUW+/hLRIk+hYYEgF21Gf58N/abJKFpqlsI', 'u51mVBEfrlAVlEANyQHHDUdImmcWPSo0+bPjKpIaUNwAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAA==', 'AAAAAAAAAAEAAAABAAAAAQAAACAAAAAAAAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAAlQL31AAAAAbAAAADAAAAAEAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAAAAAAtleGFtcGxlLmNvbQACAAICAAAAAQAAAAB8ndnLViBPKqPJAcSNhZzc2mH7fQ7RtzGyFA8mFkMTkAAAAAUAAAAAAAAAAA==', 'AAAAAgAAAAMAAAAfAAAAAAAAAACQUsYKOw/kj+JXXI5eosCY2LS+fgH0zFHZXnenMJ4wUAAAAAJUC+AYAAAAGwAAAAoAAAABAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAMAAAALZXhhbXBsZS5jb20AAgACAgAAAAEAAAAAfJ3Zy1YgTyqjyQHEjYWc3Nph+30O0bcxshQPJhZDE5AAAAAFAAAAAAAAAAAAAAABAAAAIAAAAAAAAAAAkFLGCjsP5I/iV1yOXqLAmNi0vn4B9MxR2V53pzCeMFAAAAACVAvftAAAABsAAAALAAAAAQAAAAEAAAAAYvwdC9CRsrYcDdZWNGsqaNfTR8bywsjubQRHAlb8BfcAAAADAAAAC2V4YW1wbGUuY29tAAIAAgIAAAABAAAAAHyd2ctWIE8qo8kBxI2FnNzaYft9DtG3MbIUDyYWQxOQAAAABQAAAAAAAAAA', '{BcrVMY8TeG5yTKxCZEqa5xEvYhqTsQLDThWK0z/8bRlZPz2dqE4VFvv4S0SJPoWGBIBdtRn+fDf2myShaapbCA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('6b38cdd5c17df2013d5a5e211c4b32218b6be91025316b1aab28bc12316615d5', 32, 2, 'GCIFFRQKHMH6JD7CK5OI4XVCYCMNRNF6PYA7JTCR3FPHPJZQTYYFB5ES', 115964117004, 100, 1, '2016-03-29 19:22:37.875362', '2016-03-29 19:22:37.875362', 137438961664, 'AAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAZAAAABsAAAAMAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAB8ndnLViBPKqPJAcSNhZzc2mH7fQ7RtzGyFA8mFkMTkAAAAAAAAAAAAAAAATCeMFAAAABAOb0qGWnk1WrSUXS6iQFocaIOY/BDmgG1zTmlPyg0boSid3jTBK3z9U8+IPGAOELNLgkQHtgGYFgFGMio1xY+BQ==', 'azjN1cF98gE9Wl4hHEsyIYtr6RAlMWsaqyi8EjFmFdUAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAA==', 'AAAAAAAAAAEAAAABAAAAAQAAACAAAAAAAAAAAJBSxgo7D+SP4ldcjl6iwJjYtL5+AfTMUdled6cwnjBQAAAAAlQL31AAAAAbAAAADAAAAAAAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAAAAAAtleGFtcGxlLmNvbQACAAICAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAgAAAAAAAAAACQUsYKOw/kj+JXXI5eosCY2LS+fgH0zFHZXnenMJ4wUAAAAAJUC99QAAAAGwAAAAwAAAABAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAMAAAALZXhhbXBsZS5jb20AAgACAgAAAAEAAAAAfJ3Zy1YgTyqjyQHEjYWc3Nph+30O0bcxshQPJhZDE5AAAAAFAAAAAAAAAAA=', '{Ob0qGWnk1WrSUXS6iQFocaIOY/BDmgG1zTmlPyg0boSid3jTBK3z9U8+IPGAOELNLgkQHtgGYFgFGMio1xY+BQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('6d78f17fafa2317d6af679e1e5420f351207ff61cdff21c600ea8f85155b3ea1', 33, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 15, 100, 1, '2016-03-29 19:22:37.880206', '2016-03-29 19:22:37.880206', 141733924864, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAAPAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAkqTd6glQdzt87217G6IYc3g3BYxMgWGPpDfRPhy1ZbUAAAACVAvkAAAAAAAAAAABVvwF9wAAAEC+mgKIzZqflQIKIqWn9LrciuyEx7XPfXGUhvyQ3sIQBnGdOWhkOt57UU/75LtUy4recT+jrY2cHKZj33puue8F', 'bXjxf6+iMX1q9nnh5UIPNRIH/2HN/yHGAOqPhRVbPqEAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAACEAAAAAAAAAAJKk3eoJUHc7fO9texuiGHN4NwWMTIFhj6Q30T4ctWW1AAAAAlQL5AAAAAAhAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAACEAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2kMj/uiQAAAAAAAAADwAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAbAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtpMdC56IAAAAAAAAAA4AAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAhAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtpMdC54kAAAAAAAAAA8AAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{vpoCiM2an5UCCiKlp/S63IrshMe1z31xlIb8kN7CEAZxnTloZDree1FP++S7VMuK3nE/o62NnBymY996brnvBQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('9fff61916716fb2550043fac968ac6c13802af5176a10fc29108fcfc445ef513', 49, 1, 'GAYSCMKQY6EYLXOPTT6JPPOXDMVNBWITPTSZIVWW4LWARVBOTH5RTLAD', 206158430209, 100, 1, '2016-03-29 19:22:37.96167', '2016-03-29 19:22:37.96167', 210453401600, 'AAAAADEhMVDHiYXdz5z8l73XGyrQ2RN85ZRW1uLsCNQumfsZAAAAZAAAADAAAAABAAAAAAAAAAAAAAABAAAAAAAAAAoAAAAFbmFtZTEAAAAAAAABAAAABDEyMzQAAAAAAAAAAS6Z+xkAAABAxKiHYYNLJiW3r5+kCJm8ucaoV7BcrEnQXFb3s1RyRyUbAkDlaCvE+RKwMZoNUfbkQUGrouyVKy1ZpUeccByqDg==', 'n/9hkWcW+yVQBD+slorGwTgCr1F2oQ/CkQj8/ERe9RMAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAoAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAADEAAAADAAAAADEhMVDHiYXdz5z8l73XGyrQ2RN85ZRW1uLsCNQumfsZAAAABW5hbWUxAAAAAAAABDEyMzQAAAAAAAAAAAAAAAEAAAAxAAAAAAAAAAAxITFQx4mF3c+c/Je91xsq0NkTfOWUVtbi7AjULpn7GQAAAAJUC+M4AAAAMAAAAAIAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', 'AAAAAgAAAAMAAAAwAAAAAAAAAAAxITFQx4mF3c+c/Je91xsq0NkTfOWUVtbi7AjULpn7GQAAAAJUC+QAAAAAMAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAxAAAAAAAAAAAxITFQx4mF3c+c/Je91xsq0NkTfOWUVtbi7AjULpn7GQAAAAJUC+OcAAAAMAAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{xKiHYYNLJiW3r5+kCJm8ucaoV7BcrEnQXFb3s1RyRyUbAkDlaCvE+RKwMZoNUfbkQUGrouyVKy1ZpUeccByqDg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('4e2442fe2e8dd8c686570c9f537acb2f50153a9883f8d199b6f4701eb289b3a0', 35, 1, 'GCJKJXPKBFIHOO3455WXWG5CDBZXQNYFRRGICYMPUQ35CPQ4WVS3KZLG', 141733920770, 100, 1, '2016-03-29 19:22:37.890248', '2016-03-29 19:22:37.890248', 150323859456, 'AAAAAJKk3eoJUHc7fO9texuiGHN4NwWMTIFhj6Q30T4ctWW1AAAAZAAAACEAAAACAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABVVNEAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAA7msoAAAAAAAAAAAEctWW1AAAAQNugq+B30pdbzvVVGz9RO3+DMeRdWqc/Xsd2NYdg6NBu7esvOdTWQ3nvoBEJyeGz8EE9zRQiSiqorwHlm+AGfwI=', 'TiRC/i6N2MaGVwyfU3rLL1AVOpiD+NGZtvRwHrKJs6AAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAYAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAwAAACIAAAABAAAAAJKk3eoJUHc7fO9texuiGHN4NwWMTIFhj6Q30T4ctWW1AAAAAVVTRAAAAAAAYvwdC9CRsrYcDdZWNGsqaNfTR8bywsjubQRHAlb8BfcAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAACMAAAABAAAAAJKk3eoJUHc7fO9texuiGHN4NwWMTIFhj6Q30T4ctWW1AAAAAVVTRAAAAAAAYvwdC9CRsrYcDdZWNGsqaNfTR8bywsjubQRHAlb8BfcAAAAAAAAAAAAAAAA7msoAAAAAAQAAAAAAAAAA', 'AAAAAgAAAAMAAAAiAAAAAAAAAACSpN3qCVB3O3zvbXsbohhzeDcFjEyBYY+kN9E+HLVltQAAAAJUC+OcAAAAIQAAAAEAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAjAAAAAAAAAACSpN3qCVB3O3zvbXsbohhzeDcFjEyBYY+kN9E+HLVltQAAAAJUC+M4AAAAIQAAAAIAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{26Cr4HfSl1vO9VUbP1E7f4Mx5F1apz9ex3Y1h2Do0G7t6y851NZDee+gEQnJ4bPwQT3NFCJKKqivAeWb4AZ/Ag==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('44cb6c8ed4dbec542af1aad23001dd9d678cf19c8c461a653e762a7253eded82', 36, 1, 'GCJKJXPKBFIHOO3455WXWG5CDBZXQNYFRRGICYMPUQ35CPQ4WVS3KZLG', 141733920771, 100, 1, '2016-03-29 19:22:37.89446', '2016-03-29 19:22:37.89446', 154618826752, 'AAAAAJKk3eoJUHc7fO9texuiGHN4NwWMTIFhj6Q30T4ctWW1AAAAZAAAACEAAAADAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABVVNEAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAA7msoAAAAAAAAAAAEctWW1AAAAQO+eTIPXUZk+GAq7O6H8d1/WT5buo0apjLhGgtBeSyl37UV7LCpZfCn6DYVc7lQOVNWhBc7KDA7Ne83AR41kYAk=', 'RMtsjtTb7FQq8arSMAHdnWeM8ZyMRhplPnYqclPt7YIAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAYAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAwAAACMAAAABAAAAAJKk3eoJUHc7fO9texuiGHN4NwWMTIFhj6Q30T4ctWW1AAAAAVVTRAAAAAAAYvwdC9CRsrYcDdZWNGsqaNfTR8bywsjubQRHAlb8BfcAAAAAAAAAAAAAAAA7msoAAAAAAQAAAAAAAAAAAAAAAQAAACQAAAABAAAAAJKk3eoJUHc7fO9texuiGHN4NwWMTIFhj6Q30T4ctWW1AAAAAVVTRAAAAAAAYvwdC9CRsrYcDdZWNGsqaNfTR8bywsjubQRHAlb8BfcAAAAAAAAAAAAAAAA7msoAAAAAAQAAAAAAAAAA', 'AAAAAgAAAAMAAAAjAAAAAAAAAACSpN3qCVB3O3zvbXsbohhzeDcFjEyBYY+kN9E+HLVltQAAAAJUC+M4AAAAIQAAAAIAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAkAAAAAAAAAACSpN3qCVB3O3zvbXsbohhzeDcFjEyBYY+kN9E+HLVltQAAAAJUC+LUAAAAIQAAAAMAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{755Mg9dRmT4YCrs7ofx3X9ZPlu6jRqmMuEaC0F5LKXftRXssKll8KfoNhVzuVA5U1aEFzsoMDs17zcBHjWRgCQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('52388a98e4e36c17749a94374270cc65bdb7271cb51277f095aaa8f1ca9d322c', 37, 1, 'GCJKJXPKBFIHOO3455WXWG5CDBZXQNYFRRGICYMPUQ35CPQ4WVS3KZLG', 141733920772, 100, 1, '2016-03-29 19:22:37.898945', '2016-03-29 19:22:37.898945', 158913794048, 'AAAAAJKk3eoJUHc7fO9texuiGHN4NwWMTIFhj6Q30T4ctWW1AAAAZAAAACEAAAAEAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABVVNEAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAAAAAAAAAAAAAAAAAEctWW1AAAAQM5SCoW10EJoKBBwwMu0Vw+f+bQ0GjQ9FO6w3l9Q/FIctm87248t9jXTbl0Rd4NgGcom0yoGxgcJiERwZGBMXQc=', 'UjiKmOTjbBd0mpQ3QnDMZb23Jxy1Enfwlaqo8cqdMiwAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAYAAAAAAAAAAA==', 'AAAAAAAAAAEAAAADAAAAAQAAACUAAAAAAAAAAJKk3eoJUHc7fO9texuiGHN4NwWMTIFhj6Q30T4ctWW1AAAAAlQL4nAAAAAhAAAABAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAwAAACQAAAABAAAAAJKk3eoJUHc7fO9texuiGHN4NwWMTIFhj6Q30T4ctWW1AAAAAVVTRAAAAAAAYvwdC9CRsrYcDdZWNGsqaNfTR8bywsjubQRHAlb8BfcAAAAAAAAAAAAAAAA7msoAAAAAAQAAAAAAAAAAAAAAAgAAAAEAAAAAkqTd6glQdzt87217G6IYc3g3BYxMgWGPpDfRPhy1ZbUAAAABVVNEAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w==', 'AAAAAgAAAAMAAAAkAAAAAAAAAACSpN3qCVB3O3zvbXsbohhzeDcFjEyBYY+kN9E+HLVltQAAAAJUC+LUAAAAIQAAAAMAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAlAAAAAAAAAACSpN3qCVB3O3zvbXsbohhzeDcFjEyBYY+kN9E+HLVltQAAAAJUC+JwAAAAIQAAAAQAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{zlIKhbXQQmgoEHDAy7RXD5/5tDQaND0U7rDeX1D8Uhy2bzvbjy32NdNuXRF3g2AZyibTKgbGBwmIRHBkYExdBw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('afeb8080522eba71ca328225bbcf731029edcfa254c827c45be580bae95c7231', 38, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 16, 100, 1, '2016-03-29 19:22:37.903171', '2016-03-29 19:22:37.903171', 163208761344, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAAQAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAq26sUclf95G3mAzqohcAxtpe+UiaovKwDpCv20t6bF8AAAACVAvkAAAAAAAAAAABVvwF9wAAAEDnzvNgEYB1u3BGTHFDlIWnk0GOq7BMpfcyewJRsJK9lT4HTMEwMQ2jSJyrWmB7xdBxHKaNMXQaAIx6CShLXpQH', 'r+uAgFIuunHKMoIlu89zECntz6JUyCfEW+WAuulccjEAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAACYAAAAAAAAAAKturFHJX/eRt5gM6qIXAMbaXvlImqLysA6Qr9tLemxfAAAAAlQL5AAAAAAmAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAACYAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2jnTz1VwAAAAAAAAAEQAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAhAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtpDI/7okAAAAAAAAAA8AAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAmAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtpDI/7nAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{587zYBGAdbtwRkxxQ5SFp5NBjquwTKX3MnsCUbCSvZU+B0zBMDENo0icq1pge8XQcRymjTF0GgCMegkoS16UBw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('2354df802111418a999e31c2964d16b8efe8e492b7d74de54939825190e1041f', 38, 2, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 17, 100, 1, '2016-03-29 19:22:37.905543', '2016-03-29 19:22:37.905543', 163208765440, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAARAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAA+SY4m6vkX+Y7FMkNv7RswsIkYNGXeZ4/YwEQNUpI8/gAAAACVAvkAAAAAAAAAAABVvwF9wAAAEDD6WvAYL1wilsd7zYDJt0iFO/lppQ6GJJn/A8UJl9jTjMNOjuQPBtA7fSxR5KT0BZLbtQy8qFlys0I6fTe/cwO', 'I1TfgCERQYqZnjHClk0WuO/o5JK3103lSTmCUZDhBB8AAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAACYAAAAAAAAAAPkmOJur5F/mOxTJDb+0bMLCJGDRl3meP2MBEDVKSPP4AAAAAlQL5AAAAAAmAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAACYAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2jCDn8VwAAAAAAAAAEQAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAmAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtpDI/7lcAAAAAAAAABEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{w+lrwGC9cIpbHe82AybdIhTv5aaUOhiSZ/wPFCZfY04zDTo7kDwbQO30sUeSk9AWS27UMvKhZcrNCOn03v3MDg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('11705f94cd65d7b673a124a85ce368c80f8458ffaedff719304d8f849535b4e0', 39, 1, 'GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF', 163208757249, 100, 1, '2016-03-29 19:22:37.910983', '2016-03-29 19:22:37.910983', 167503728640, 'AAAAAPkmOJur5F/mOxTJDb+0bMLCJGDRl3meP2MBEDVKSPP4AAAAZAAAACYAAAABAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABSkjz+AAAAECyjDa1e+jtXukTrHluO7x0Mx7Wj4mRoM4S5UAFmRV+2rVoxjMwqFJhtYnEAUV19+C5ycp5jOLLpWxrCeRKJQUG', 'EXBflM1l17ZzoSSoXONoyA+EWP+u3/cZME2PhJU1tOAAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAA==', 'AAAAAAAAAAEAAAABAAAAAQAAACcAAAAAAAAAAPkmOJur5F/mOxTJDb+0bMLCJGDRl3meP2MBEDVKSPP4AAAAAlQL45wAAAAmAAAAAQAAAAAAAAAAAAAAAwAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAmAAAAAAAAAAD5Jjibq+Rf5jsUyQ2/tGzCwiRg0Zd5nj9jARA1Skjz+AAAAAJUC+QAAAAAJgAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAnAAAAAAAAAAD5Jjibq+Rf5jsUyQ2/tGzCwiRg0Zd5nj9jARA1Skjz+AAAAAJUC+OcAAAAJgAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{sow2tXvo7V7pE6x5bju8dDMe1o+JkaDOEuVABZkVftq1aMYzMKhSYbWJxAFFdffgucnKeYziy6VsawnkSiUFBg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('6fa467b53f5386d77ad35c2502ed2cd3dd8b460a5be22b6b2818b81bcd3ed2da', 40, 1, 'GCVW5LCRZFP7PENXTAGOVIQXADDNUXXZJCNKF4VQB2IK7W2LPJWF73UG', 163208757249, 100, 1, '2016-03-29 19:22:37.916414', '2016-03-29 19:22:37.916415', 171798695936, 'AAAAAKturFHJX/eRt5gM6qIXAMbaXvlImqLysA6Qr9tLemxfAAAAZAAAACYAAAABAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABVVNEAAAAAAD5Jjibq+Rf5jsUyQ2/tGzCwiRg0Zd5nj9jARA1Skjz+H//////////AAAAAAAAAAFLemxfAAAAQKN8LftAafeoAGmvpsEokqm47jAuqw4g1UWjmL0j6QPm1jxoalzDwDS3W+N2HOHdjSJlEQaTxGBfQKHhr6nNsAA=', 'b6RntT9Thtd601wlAu0s092LRgpb4itrKBi4G80+0toAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAYAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAACgAAAABAAAAAKturFHJX/eRt5gM6qIXAMbaXvlImqLysA6Qr9tLemxfAAAAAVVTRAAAAAAA+SY4m6vkX+Y7FMkNv7RswsIkYNGXeZ4/YwEQNUpI8/gAAAAAAAAAAH//////////AAAAAAAAAAAAAAAAAAAAAQAAACgAAAAAAAAAAKturFHJX/eRt5gM6qIXAMbaXvlImqLysA6Qr9tLemxfAAAAAlQL4zgAAAAmAAAAAgAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAmAAAAAAAAAACrbqxRyV/3kbeYDOqiFwDG2l75SJqi8rAOkK/bS3psXwAAAAJUC+QAAAAAJgAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAoAAAAAAAAAACrbqxRyV/3kbeYDOqiFwDG2l75SJqi8rAOkK/bS3psXwAAAAJUC+OcAAAAJgAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{o3wt+0Bp96gAaa+mwSiSqbjuMC6rDiDVRaOYvSPpA+bWPGhqXMPANLdb43Yc4d2NImURBpPEYF9AoeGvqc2wAA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('0bcb67aa365446fd244fecff3a0c397f81f3a9b13428688965e776d447c0b1ea', 40, 2, 'GCVW5LCRZFP7PENXTAGOVIQXADDNUXXZJCNKF4VQB2IK7W2LPJWF73UG', 163208757250, 100, 1, '2016-03-29 19:22:37.917743', '2016-03-29 19:22:37.917743', 171798700032, 'AAAAAKturFHJX/eRt5gM6qIXAMbaXvlImqLysA6Qr9tLemxfAAAAZAAAACYAAAACAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABRVVSAAAAAAD5Jjibq+Rf5jsUyQ2/tGzCwiRg0Zd5nj9jARA1Skjz+H//////////AAAAAAAAAAFLemxfAAAAQMPVgYf+w09depDSxMcJnjVZHA2FlkBmhPmi0N66FuhAzTekWcCOMdCI0cUc+xJhywLXSMiKA6wP6K94NRlFlQE=', 'C8tnqjZURv0kT+z/Ogw5f4HzqbE0KGiJZed21EfAseoAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAYAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAACgAAAABAAAAAKturFHJX/eRt5gM6qIXAMbaXvlImqLysA6Qr9tLemxfAAAAAUVVUgAAAAAA+SY4m6vkX+Y7FMkNv7RswsIkYNGXeZ4/YwEQNUpI8/gAAAAAAAAAAH//////////AAAAAAAAAAAAAAAAAAAAAQAAACgAAAAAAAAAAKturFHJX/eRt5gM6qIXAMbaXvlImqLysA6Qr9tLemxfAAAAAlQL4zgAAAAmAAAAAgAAAAIAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAoAAAAAAAAAACrbqxRyV/3kbeYDOqiFwDG2l75SJqi8rAOkK/bS3psXwAAAAJUC+M4AAAAJgAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{w9WBh/7DT116kNLExwmeNVkcDYWWQGaE+aLQ3roW6EDNN6RZwI4x0IjRxRz7EmHLAtdIyIoDrA/or3g1GUWVAQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('6d2e30fd57492bf2e2b132e1bc91a548a369189bebf77eb2b3d829121a9d2c50', 41, 1, 'GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF', 163208757250, 100, 1, '2016-03-29 19:22:37.922079', '2016-03-29 19:22:37.922079', 176093663232, 'AAAAAPkmOJur5F/mOxTJDb+0bMLCJGDRl3meP2MBEDVKSPP4AAAAZAAAACYAAAACAAAAAAAAAAAAAAABAAAAAAAAAAcAAAAAq26sUclf95G3mAzqohcAxtpe+UiaovKwDpCv20t6bF8AAAABVVNEAAAAAAEAAAAAAAAAAUpI8/gAAABA6O2fe1gQBwoO0fMNNEUKH0QdVXVjEWbN5VL51DmRUedYMMXtbX5JKVSzla2kIGvWgls1dXuXHZY/IOlaK01rBQ==', 'bS4w/VdJK/LisTLhvJGlSKNpGJvr936ys9gpEhqdLFAAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAcAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAwAAACgAAAABAAAAAKturFHJX/eRt5gM6qIXAMbaXvlImqLysA6Qr9tLemxfAAAAAVVTRAAAAAAA+SY4m6vkX+Y7FMkNv7RswsIkYNGXeZ4/YwEQNUpI8/gAAAAAAAAAAH//////////AAAAAAAAAAAAAAAAAAAAAQAAACkAAAABAAAAAKturFHJX/eRt5gM6qIXAMbaXvlImqLysA6Qr9tLemxfAAAAAVVTRAAAAAAA+SY4m6vkX+Y7FMkNv7RswsIkYNGXeZ4/YwEQNUpI8/gAAAAAAAAAAH//////////AAAAAQAAAAAAAAAA', 'AAAAAgAAAAMAAAAnAAAAAAAAAAD5Jjibq+Rf5jsUyQ2/tGzCwiRg0Zd5nj9jARA1Skjz+AAAAAJUC+OcAAAAJgAAAAEAAAAAAAAAAAAAAAMAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAApAAAAAAAAAAD5Jjibq+Rf5jsUyQ2/tGzCwiRg0Zd5nj9jARA1Skjz+AAAAAJUC+M4AAAAJgAAAAIAAAAAAAAAAAAAAAMAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{6O2fe1gQBwoO0fMNNEUKH0QdVXVjEWbN5VL51DmRUedYMMXtbX5JKVSzla2kIGvWgls1dXuXHZY/IOlaK01rBQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('a832ff67085cb9eb6f1c4b740f6e033ba9b508af725fbf203469729a64a199ff', 41, 2, 'GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF', 163208757251, 100, 1, '2016-03-29 19:22:37.923356', '2016-03-29 19:22:37.923356', 176093667328, 'AAAAAPkmOJur5F/mOxTJDb+0bMLCJGDRl3meP2MBEDVKSPP4AAAAZAAAACYAAAADAAAAAAAAAAAAAAABAAAAAAAAAAcAAAAAq26sUclf95G3mAzqohcAxtpe+UiaovKwDpCv20t6bF8AAAABRVVSAAAAAAEAAAAAAAAAAUpI8/gAAABA1Qe8ngwANz4fLqYChwRjR5xng6cIqU5WBtjkZgF4ugVhi8J6kTpACvnvXso3IVym6Rfd6JdQW8QcLkFTX1MGCg==', 'qDL/ZwhcuetvHEt0D24DO6m1CK9yX78gNGlymmShmf8AAAAAAAAAZAAAAAAAAAABAAAAAAAAAAcAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAwAAACgAAAABAAAAAKturFHJX/eRt5gM6qIXAMbaXvlImqLysA6Qr9tLemxfAAAAAUVVUgAAAAAA+SY4m6vkX+Y7FMkNv7RswsIkYNGXeZ4/YwEQNUpI8/gAAAAAAAAAAH//////////AAAAAAAAAAAAAAAAAAAAAQAAACkAAAABAAAAAKturFHJX/eRt5gM6qIXAMbaXvlImqLysA6Qr9tLemxfAAAAAUVVUgAAAAAA+SY4m6vkX+Y7FMkNv7RswsIkYNGXeZ4/YwEQNUpI8/gAAAAAAAAAAH//////////AAAAAQAAAAAAAAAA', 'AAAAAQAAAAEAAAApAAAAAAAAAAD5Jjibq+Rf5jsUyQ2/tGzCwiRg0Zd5nj9jARA1Skjz+AAAAAJUC+LUAAAAJgAAAAMAAAAAAAAAAAAAAAMAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{1Qe8ngwANz4fLqYChwRjR5xng6cIqU5WBtjkZgF4ugVhi8J6kTpACvnvXso3IVym6Rfd6JdQW8QcLkFTX1MGCg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('d67cfb271a889e7854ffd61b08eacde76d56e758466fc37a8eec2d3a40ef8b14', 42, 1, 'GD4SMOE3VPSF7ZR3CTEQ3P5UNTBMEJDA2GLXTHR7MMARANKKJDZ7RPGF', 163208757252, 100, 1, '2016-03-29 19:22:37.927546', '2016-03-29 19:22:37.927546', 180388630528, 'AAAAAPkmOJur5F/mOxTJDb+0bMLCJGDRl3meP2MBEDVKSPP4AAAAZAAAACYAAAAEAAAAAAAAAAAAAAABAAAAAAAAAAcAAAAAq26sUclf95G3mAzqohcAxtpe+UiaovKwDpCv20t6bF8AAAABRVVSAAAAAAAAAAAAAAAAAUpI8/gAAABAEPKcQmATGpevrtlAcZnNI/GjfLLQEp9aODGGRFV+2C4UO8dU+UAMTkCSXQLD+xPaRQxzw93ScEok6GzYCtt7Bg==', '1nz7JxqInnhU/9YbCOrN521W51hGb8N6juwtOkDvixQAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAcAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAwAAACkAAAABAAAAAKturFHJX/eRt5gM6qIXAMbaXvlImqLysA6Qr9tLemxfAAAAAUVVUgAAAAAA+SY4m6vkX+Y7FMkNv7RswsIkYNGXeZ4/YwEQNUpI8/gAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAACoAAAABAAAAAKturFHJX/eRt5gM6qIXAMbaXvlImqLysA6Qr9tLemxfAAAAAUVVUgAAAAAA+SY4m6vkX+Y7FMkNv7RswsIkYNGXeZ4/YwEQNUpI8/gAAAAAAAAAAH//////////AAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAApAAAAAAAAAAD5Jjibq+Rf5jsUyQ2/tGzCwiRg0Zd5nj9jARA1Skjz+AAAAAJUC+LUAAAAJgAAAAMAAAAAAAAAAAAAAAMAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAqAAAAAAAAAAD5Jjibq+Rf5jsUyQ2/tGzCwiRg0Zd5nj9jARA1Skjz+AAAAAJUC+JwAAAAJgAAAAQAAAAAAAAAAAAAAAMAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{EPKcQmATGpevrtlAcZnNI/GjfLLQEp9aODGGRFV+2C4UO8dU+UAMTkCSXQLD+xPaRQxzw93ScEok6GzYCtt7Bg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('945b6171de747ab323b3cda52290933df39edd7061f6e260762663efc51bccb0', 43, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 18, 100, 1, '2016-03-29 19:22:37.931868', '2016-03-29 19:22:37.931868', 184683597824, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAASAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAjvuao1PL1U+CaCf7/+6+M/xUnEnUUdDiMKthL4rj4e8AAAACVAvkAAAAAAAAAAABVvwF9wAAAEBFbS2c5rrYNGslNVslTHH8j8x0ggew1eHHOUTNajMPy8GYn52RSwRncwwvv1ejEfA+g/mTXMpXrBO847C46KoA', 'lFthcd50erMjs82lIpCTPfOe3XBh9uJgdiZj78UbzLAAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAACsAAAAAAAAAAI77mqNTy9VPgmgn+//uvjP8VJxJ1FHQ4jCrYS+K4+HvAAAAAlQL5AAAAAArAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAACsAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2iczcDPgAAAAAAAAAEgAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAmAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtowg5/FcAAAAAAAAABEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAArAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtowg5/D4AAAAAAAAABIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{RW0tnOa62DRrJTVbJUxx/I/MdIIHsNXhxzlEzWozD8vBmJ+dkUsEZ3MML79XoxHwPoP5k1zKV6wTvOOwuOiqAA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('e0773d07aba23d11e6a06b021682294be1f9f202a2926827022539662ce2c7fc', 44, 1, 'GCHPXGVDKPF5KT4CNAT7X77OXYZ7YVE4JHKFDUHCGCVWCL4K4PQ67KKZ', 184683593729, 100, 1, '2016-03-29 19:22:37.937054', '2016-03-29 19:22:37.937054', 188978565120, 'AAAAAI77mqNTy9VPgmgn+//uvjP8VJxJ1FHQ4jCrYS+K4+HvAAAAZAAAACsAAAABAAAAAAAAAAAAAAABAAAAAAAAAAgAAAAAYvwdC9CRsrYcDdZWNGsqaNfTR8bywsjubQRHAlb8BfcAAAAAAAAAAYrj4e8AAABA3jJ7wBrRpsrcnqBQWjyzwvVz2v5UJ56G60IhgsaWQFSf+7om462KToc+HJ27aLVOQ83dGh1ivp+VIuREJq/SBw==', '4Hc9B6uiPRHmoGsCFoIpS+H58gKikmgnAiU5Zizix/wAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAgAAAAAAAAAAlQL45wAAAAA', 'AAAAAAAAAAEAAAADAAAAAwAAACsAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2iczcDPgAAAAAAAAAEgAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAACwAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2jCDn8JQAAAAAAAAAEgAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAAAjvuao1PL1U+CaCf7/+6+M/xUnEnUUdDiMKthL4rj4e8=', 'AAAAAgAAAAMAAAArAAAAAAAAAACO+5qjU8vVT4JoJ/v/7r4z/FScSdRR0OIwq2EviuPh7wAAAAJUC+QAAAAAKwAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAsAAAAAAAAAACO+5qjU8vVT4JoJ/v/7r4z/FScSdRR0OIwq2EviuPh7wAAAAJUC+OcAAAAKwAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{3jJ7wBrRpsrcnqBQWjyzwvVz2v5UJ56G60IhgsaWQFSf+7om462KToc+HJ27aLVOQ83dGh1ivp+VIuREJq/SBw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('a3a0d8e06f6bd4ff57bb55c3ac574dceabb78882c9b4dd5f5e65baed87020679', 45, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 19, 100, 1, '2016-03-29 19:22:37.941727', '2016-03-29 19:22:37.941727', 193273532416, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAATAAAAAAAAAAAAAAABAAAAAAAAAAkAAAAAAAAAAVb8BfcAAABAfITDtrEv7fA6W6uatgutQ6hqn8di+ZAcBB21rqZg6YoWTOQxE4LXvgk5zdXV+e9z7WRcxmarbHUR9/R9O0XpCg==', 'o6DY4G9r1P9Xu1XDrFdNzqu3iILJtN1fXmW67YcCBnkAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAkAAAAAAAAAAAAAAAA=', 'AAAAAAAAAAEAAAAA', 'AAAAAgAAAAMAAAAsAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtowg5/CUAAAAAAAAABIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAtAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtowg5/AwAAAAAAAAABMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{fITDtrEv7fA6W6uatgutQ6hqn8di+ZAcBB21rqZg6YoWTOQxE4LXvgk5zdXV+e9z7WRcxmarbHUR9/R9O0XpCg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('896b0f836305204005de589e2bad1cd0f651336432fec4082c08013bd04e30a3', 46, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 20, 100, 1, '2016-03-29 19:22:37.945599', '2016-03-29 19:22:37.945599', 197568499712, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAAUAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAA493YBEKdTeVN3wUjgsf56+V7YgpjSdqDCWTMfjGCtycARw3k34IAAAAAAAAAAAABVvwF9wAAAECmE9bj7HqrN1W4NC4lXT/hLIzQPcaz4gmWlqThzj2uOl/UY9yBaXeSH2wtIk5bt7nBCWRaRlD+vrKVHgCIREcI', 'iWsPg2MFIEAF3lieK60c0PZRM2Qy/sQILAgBO9BOMKMAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAAC4AAAAAAAAAAOPd2ARCnU3lTd8FI4LH+evle2IKY0nagwlkzH4xgrcnAEcN5N+CAAAAAAAuAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAC4AAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DZmop0Fl78wAAAAAAAAAFAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAtAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtowg5/AwAAAAAAAAABMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAuAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtowg5+/MAAAAAAAAABQAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{phPW4+x6qzdVuDQuJV0/4SyM0D3Gs+IJlpak4c49rjpf1GPcgWl3kh9sLSJOW7e5wQlkWkZQ/r6ylR4AiERHCA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('8c266248cf63b41585328921c57d770d3c467fc4881baafa4412516badf57586', 47, 1, 'GDR53WAEIKOU3ZKN34CSHAWH7HV6K63CBJRUTWUDBFSMY7RRQK3SPKOS', 197568495617, 100, 1, '2016-03-29 19:22:37.950868', '2016-03-29 19:22:37.950868', 201863467008, 'AAAAAOPd2ARCnU3lTd8FI4LH+evle2IKY0nagwlkzH4xgrcnAAAAZAAAAC4AAAABAAAAAAAAAAAAAAABAAAAAAAAAAUAAAABAAAAAOPd2ARCnU3lTd8FI4LH+evle2IKY0nagwlkzH4xgrcnAAAAAQAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABMYK3JwAAAEA+E+dy0ZoleU41awSD08yo34AaUVOov98jJMVGx8q8bfLLr/SM8aSGgnltdZBrcTfUDWyP3daO1ywCqGHQqH4B', 'jCZiSM9jtBWFMokhxX13DTxGf8SIG6r6RBJRa631dYYAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAA==', 'AAAAAAAAAAEAAAABAAAAAQAAAC8AAAAAAAAAAOPd2ARCnU3lTd8FI4LH+evle2IKY0nagwlkzH4xgrcnAEcN5N+B/5wAAAAuAAAAAQAAAAAAAAABAAAAAOPd2ARCnU3lTd8FI4LH+evle2IKY0nagwlkzH4xgrcnAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAuAAAAAAAAAADj3dgEQp1N5U3fBSOCx/nr5XtiCmNJ2oMJZMx+MYK3JwBHDeTfggAAAAAALgAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAvAAAAAAAAAADj3dgEQp1N5U3fBSOCx/nr5XtiCmNJ2oMJZMx+MYK3JwBHDeTfgf+cAAAALgAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{PhPnctGaJXlONWsEg9PMqN+AGlFTqL/fIyTFRsfKvG3yy6/0jPGkhoJ5bXWQa3E31A1sj93WjtcsAqhh0Kh+AQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('713efcc8b0192d7f39fedc2aabd5a1bcc4c492a0b6255e92161d7ac19d639db0', 47, 2, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 21, 100, 1, '2016-03-29 19:22:37.952036', '2016-03-29 19:22:37.952036', 201863471104, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAAVAAAAAAAAAAAAAAABAAAAAAAAAAUAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAQAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABVvwF9wAAAEAAyVHjUyp1OjQOuUTuyX/cE7RxMNgcsfS+dR9FsapR/VsgyfiCx7irGvGV6s2AJEhqQR6H6Uo6fzq/UGagvmII', 'cT78yLAZLX85/twqq9WhvMTEkqC2JV6SFh16wZ1jnbAAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAA==', 'AAAAAAAAAAEAAAABAAAAAQAAAC8AAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DZmop0Fl72gAAAAAAAAAFQAAAAAAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAuAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w2ZqKdBZe/MAAAAAAAAABQAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAvAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w2ZqKdBZe9oAAAAAAAAABUAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{AMlR41MqdTo0DrlE7sl/3BO0cTDYHLH0vnUfRbGqUf1bIMn4gse4qxrxlerNgCRIakEeh+lKOn86v1BmoL5iCA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('eb8586c9176c4cf2e864b2521948a972db5274de24673669463e0c7824cee056', 48, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 22, 100, 1, '2016-03-29 19:22:37.956175', '2016-03-29 19:22:37.956175', 206158434304, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAAWAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAMSExUMeJhd3PnPyXvdcbKtDZE3zllFbW4uwI1C6Z+xkAAAACVAvkAAAAAAAAAAABVvwF9wAAAECAMOn6G4jusgpfSoHwntHQkYIDxI/VnyH/qIi+bdMWzi1T6WlwnO+yITgm2+mOaWc6zVuxiLjHllzBeQ/xKvQN', '64WGyRdsTPLoZLJSGUipcttSdN4kZzZpRj4MeCTO4FYAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAADAAAAAAAAAAADEhMVDHiYXdz5z8l73XGyrQ2RN85ZRW1uLsCNQumfsZAAAAAlQL5AAAAAAwAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAADAAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DZmopO1aCwQAAAAAAAAAFgAAAAAAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAvAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w2ZqKdBZe9oAAAAAAAAABUAAAAAAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAwAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w2ZqKdBZe8EAAAAAAAAABYAAAAAAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{gDDp+huI7rIKX0qB8J7R0JGCA8SP1Z8h/6iIvm3TFs4tU+lpcJzvsiE4JtvpjmlnOs1bsYi4x5ZcwXkP8Sr0DQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('e4609180751e7702466a8845857df43e4d154ec84b6bad62ce507fe12f1daf99', 49, 2, 'GAYSCMKQY6EYLXOPTT6JPPOXDMVNBWITPTSZIVWW4LWARVBOTH5RTLAD', 206158430210, 100, 1, '2016-03-29 19:22:37.962639', '2016-03-29 19:22:37.962639', 210453405696, 'AAAAADEhMVDHiYXdz5z8l73XGyrQ2RN85ZRW1uLsCNQumfsZAAAAZAAAADAAAAACAAAAAAAAAAAAAAABAAAAAAAAAAoAAAAFbmFtZTIAAAAAAAABAAAABDU2NzgAAAAAAAAAAS6Z+xkAAABAjxgnTRBCa0n1efZocxpEjXeITQ5sEYTVd9fowuto2kPw5eFwgVnz6OrKJwCRt5L8ylmWiATXVI3Zyfi3yTKqBA==', '5GCRgHUedwJGaohFhX30Pk0VTshLa61izlB/4S8dr5kAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAoAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAADEAAAADAAAAADEhMVDHiYXdz5z8l73XGyrQ2RN85ZRW1uLsCNQumfsZAAAABW5hbWUyAAAAAAAABDU2NzgAAAAAAAAAAAAAAAEAAAAxAAAAAAAAAAAxITFQx4mF3c+c/Je91xsq0NkTfOWUVtbi7AjULpn7GQAAAAJUC+M4AAAAMAAAAAIAAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', 'AAAAAQAAAAEAAAAxAAAAAAAAAAAxITFQx4mF3c+c/Je91xsq0NkTfOWUVtbi7AjULpn7GQAAAAJUC+M4AAAAMAAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{jxgnTRBCa0n1efZocxpEjXeITQ5sEYTVd9fowuto2kPw5eFwgVnz6OrKJwCRt5L8ylmWiATXVI3Zyfi3yTKqBA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('def26097cd63b13105d21172854587a0f3a68eafd09f96b7bb45e8c7fafb0946', 50, 1, 'GAYSCMKQY6EYLXOPTT6JPPOXDMVNBWITPTSZIVWW4LWARVBOTH5RTLAD', 206158430211, 100, 1, '2016-03-29 19:22:37.966617', '2016-03-29 19:22:37.966617', 214748368896, 'AAAAADEhMVDHiYXdz5z8l73XGyrQ2RN85ZRW1uLsCNQumfsZAAAAZAAAADAAAAADAAAAAAAAAAAAAAABAAAAAAAAAAoAAAAFbmFtZTIAAAAAAAAAAAAAAAAAAAEumfsZAAAAQECC7FH/CV04TFceB2a8NjE7S5i+AokTd7/xDlO4pjHeYkiEN+rxB9STqBfpWqsnODXQ516SNKFoVsNeTWTpxg8=', '3vJgl81jsTEF0hFyhUWHoPOmjq/Qn5a3u0Xox/r7CUYAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAoAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAQAAADIAAAAAAAAAADEhMVDHiYXdz5z8l73XGyrQ2RN85ZRW1uLsCNQumfsZAAAAAlQL4tQAAAAwAAAAAwAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAMAAAAAMSExUMeJhd3PnPyXvdcbKtDZE3zllFbW4uwI1C6Z+xkAAAAFbmFtZTIAAAA=', 'AAAAAgAAAAMAAAAxAAAAAAAAAAAxITFQx4mF3c+c/Je91xsq0NkTfOWUVtbi7AjULpn7GQAAAAJUC+M4AAAAMAAAAAIAAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAyAAAAAAAAAAAxITFQx4mF3c+c/Je91xsq0NkTfOWUVtbi7AjULpn7GQAAAAJUC+LUAAAAMAAAAAMAAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{QILsUf8JXThMVx4HZrw2MTtLmL4CiRN3v/EOU7imMd5iSIQ36vEH1JOoF+laqyc4NdDnXpI0oWhWw15NZOnGDw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('9dd4ec8aa09fc3320a26f71e9817264b1db52ccabda0e09acf38c38b2b9e301d', 51, 1, 'GAYSCMKQY6EYLXOPTT6JPPOXDMVNBWITPTSZIVWW4LWARVBOTH5RTLAD', 206158430212, 100, 1, '2016-03-29 19:22:37.970566', '2016-03-29 19:22:37.970566', 219043336192, 'AAAAADEhMVDHiYXdz5z8l73XGyrQ2RN85ZRW1uLsCNQumfsZAAAAZAAAADAAAAAEAAAAAAAAAAAAAAABAAAAAAAAAAoAAAAFbmFtZTEAAAAAAAABAAAABDEyMzQAAAAAAAAAAS6Z+xkAAABAYJ2V8oNXM82nq16KsHBhzmKeudDYb1CPnIsVHI74d3uFiyWYXyPy+DriSjZI3k42kDpe76fXQnVEP27g2zmOCg==', 'ndTsiqCfwzIKJvcemBcmSx21LMq9oOCazzjDiyueMB0AAAAAAAAAZAAAAAAAAAABAAAAAAAAAAoAAAAAAAAAAA==', 'AAAAAAAAAAEAAAABAAAAAQAAADMAAAADAAAAADEhMVDHiYXdz5z8l73XGyrQ2RN85ZRW1uLsCNQumfsZAAAABW5hbWUxAAAAAAAABDEyMzQAAAAAAAAAAA==', 'AAAAAgAAAAMAAAAyAAAAAAAAAAAxITFQx4mF3c+c/Je91xsq0NkTfOWUVtbi7AjULpn7GQAAAAJUC+LUAAAAMAAAAAMAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAzAAAAAAAAAAAxITFQx4mF3c+c/Je91xsq0NkTfOWUVtbi7AjULpn7GQAAAAJUC+JwAAAAMAAAAAQAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{YJ2V8oNXM82nq16KsHBhzmKeudDYb1CPnIsVHI74d3uFiyWYXyPy+DriSjZI3k42kDpe76fXQnVEP27g2zmOCg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('c7f70738b57c1422e6845ba494a3aafb36387484d525680ecb176ee4ebee4807', 52, 1, 'GAYSCMKQY6EYLXOPTT6JPPOXDMVNBWITPTSZIVWW4LWARVBOTH5RTLAD', 206158430213, 100, 1, '2016-03-29 19:22:37.974735', '2016-03-29 19:22:37.974735', 223338303488, 'AAAAADEhMVDHiYXdz5z8l73XGyrQ2RN85ZRW1uLsCNQumfsZAAAAZAAAADAAAAAFAAAAAAAAAAAAAAABAAAAAAAAAAoAAAAFbmFtZTEAAAAAAAABAAAABDAwMDAAAAAAAAAAAS6Z+xkAAABAt72MSOt3aYwcuaRnJSMGJXitOh6u0sKTsIrfph9y3YdYiyV+SI/IP93vKlWEf0BjrwVrwHdaPrqA22PiF4beDw==', 'x/cHOLV8FCLmhFuklKOq+zY4dITVJWgOyxdu5OvuSAcAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAoAAAAAAAAAAA==', 'AAAAAAAAAAEAAAABAAAAAQAAADQAAAADAAAAADEhMVDHiYXdz5z8l73XGyrQ2RN85ZRW1uLsCNQumfsZAAAABW5hbWUxAAAAAAAABDAwMDAAAAAAAAAAAA==', 'AAAAAgAAAAMAAAAzAAAAAAAAAAAxITFQx4mF3c+c/Je91xsq0NkTfOWUVtbi7AjULpn7GQAAAAJUC+JwAAAAMAAAAAQAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAA0AAAAAAAAAAAxITFQx4mF3c+c/Je91xsq0NkTfOWUVtbi7AjULpn7GQAAAAJUC+IMAAAAMAAAAAUAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{t72MSOt3aYwcuaRnJSMGJXitOh6u0sKTsIrfph9y3YdYiyV+SI/IP93vKlWEf0BjrwVrwHdaPrqA22PiF4beDw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('df5f0e8b3b533dd9cda0ff7540bef3e9e19369060f8a4b0414b0e3c1b4315b1c', 53, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 23, 100, 1, '2016-03-29 19:22:37.979', '2016-03-29 19:22:37.979', 227633270784, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAAXAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAABJeTmKR1qr+CZoIyjAfGxrIXZ/tI1VId2OfZkRowDz4AAAACVAvkAAAAAAAAAAABVvwF9wAAAEDyHwhW9GXQVXG1qibbeqSjxYzhv5IC08K2vSkxzYTwJykvQ8l0+e4M4h2guoK89s8HUfIqIOzDmoGsNTaLcYUG', '318OiztTPdnNoP91QL7z6eGTaQYPiksEFLDjwbQxWxwAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAADUAAAAAAAAAAASXk5ikdaq/gmaCMowHxsayF2f7SNVSHdjn2ZEaMA8+AAAAAlQL5AAAAAA1AAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAADUAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DZmooplOJqAAAAAAAAAAFwAAAAAAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAAwAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w2ZqKTtWgsEAAAAAAAAABYAAAAAAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAA1AAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w2ZqKTtWgqgAAAAAAAAABcAAAAAAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{8h8IVvRl0FVxtaom23qko8WM4b+SAtPCtr0pMc2E8CcpL0PJdPnuDOIdoLqCvPbPB1HyKiDsw5qBrDU2i3GFBg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('85bbd2b558563518a38e9b749bd4b8ced60b9fbbb7a6b283e15ae98548302ac4', 54, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 24, 200, 2, '2016-03-29 19:22:37.984497', '2016-03-29 19:22:37.984497', 231928238080, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAyAAAAAAAAAAYAAAAAAAAAAAAAAACAAAAAAAAAAEAAAAABJeTmKR1qr+CZoIyjAfGxrIXZ/tI1VId2OfZkRowDz4AAAAAAAAAAAX14QAAAAABAAAAAASXk5ikdaq/gmaCMowHxsayF2f7SNVSHdjn2ZEaMA8+AAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAAAAAAABfXhAAAAAAAAAAACVvwF9wAAAEDRRWwMrdLrhnl+FIP+71tTHB5rlzCsPVyGnR3scvID9NmIL3LZEo992uTvDI9QLys5bC2yRc3WYR0vFiZRs40IGjAPPgAAAEDXbXWVdzmN6NWBjYU5OvB33WTUaa2wDZX3RmFTZQQ/+7JvPdblMtNCxo8IOYePQg90RajV9rB+k8P+SEpPHCUH', 'hbvStVhWNRijjpt0m9S4ztYLn7u3prKD4VrphUgwKsQAAAAAAAAAyAAAAAAAAAACAAAAAAAAAAEAAAAAAAAAAAAAAAEAAAAAAAAAAA==', 'AAAAAAAAAAIAAAADAAAAAwAAADUAAAAAAAAAAASXk5ikdaq/gmaCMowHxsayF2f7SNVSHdjn2ZEaMA8+AAAAAlQL5AAAAAA1AAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAADYAAAAAAAAAAASXk5ikdaq/gmaCMowHxsayF2f7SNVSHdjn2ZEaMA8+AAAAAloBxQAAAAA1AAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAADYAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DZmoopNYRNgAAAAAAAAAGAAAAAAAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAEAAAA2AAAAAAAAAAAEl5OYpHWqv4JmgjKMB8bGshdn+0jVUh3Y59mRGjAPPgAAAAJUC+QAAAAANQAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAA2AAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w2ZqKKZTiXYAAAAAAAAABgAAAAAAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', 'AAAAAgAAAAMAAAA1AAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w2ZqKKZTiagAAAAAAAAABcAAAAAAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAA2AAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w2ZqKKZTiXYAAAAAAAAABgAAAAAAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{0UVsDK3S64Z5fhSD/u9bUxwea5cwrD1chp0d7HLyA/TZiC9y2RKPfdrk7wyPUC8rOWwtskXN1mEdLxYmUbONCA==,1211lXc5jejVgY2FOTrwd91k1GmtsA2V90ZhU2UEP/uybz3W5TLTQsaPCDmHj0IPdEWo1fawfpPD/khKTxwlBw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('5bbbedfb52efd1d5d973e22540044a27b8115772314293e3ba8b1fb12e63ca2e', 55, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 25, 100, 1, '2016-03-29 19:22:37.989775', '2016-03-29 19:22:37.989775', 236223205376, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAAZAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAGlyOIRNnS6HDEkmGAE9gpZJUnLZNnYsjzt+pXVxR/9QAAAACVAvkAAAAAAAAAAABVvwF9wAAAEBCMMjX9xO3XKpQ6uS/U1BqdzRhSBYQ35ivmZxPBgfqQsTDma1BzOsq/bmHJ4P+fkYJRJUdZZazXJM2i4mF7nUH', 'W7vt+1Lv0dXZc+IlQARKJ7gRV3IxQpPjuosfsS5jyi4AAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAADcAAAAAAAAAABpcjiETZ0uhwxJJhgBPYKWSVJy2TZ2LI87fqV1cUf/UAAAAAlQL5AAAAAA3AAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAADcAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DZmooEVCQXQAAAAAAAAAGQAAAAAAAAABAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAA2AAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w2ZqKKZTiXYAAAAAAAAABgAAAAAAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAA3AAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w2ZqKKZTiV0AAAAAAAAABkAAAAAAAAAAQAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{QjDI1/cTt1yqUOrkv1NQanc0YUgWEN+Yr5mcTwYH6kLEw5mtQczrKv25hyeD/n5GCUSVHWWWs1yTNouJhe51Bw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('2a805712c6d10f9e74bb0ccf54ae92a2b4b1e586451fe8133a2433816f6b567c', 56, 1, 'GANFZDRBCNTUXIODCJEYMACPMCSZEVE4WZGZ3CZDZ3P2SXK4KH75IK6Y', 236223201281, 100, 1, '2016-03-29 19:22:37.994945', '2016-03-29 19:22:37.994945', 240518172672, 'AAAAABpcjiETZ0uhwxJJhgBPYKWSVJy2TZ2LI87fqV1cUf/UAAAAZAAAADcAAAABAAAAAAAAAAAAAAABAAAAAAAAAAEAAAAAGlyOIRNnS6HDEkmGAE9gpZJUnLZNnYsjzt+pXVxR/9QAAAAAAAAAAAX14QAAAAAAAAAAAVxR/9QAAABAK6pcXYMzAEmH08CZ1LWmvtNDKauhx+OImtP/Lk4hVTMJRVBOebVs5WEPj9iSrgGT0EswuDCZ2i5AEzwgGof9Ag==', 'KoBXEsbRD550uwzPVK6SorSx5YZFH+gTOiQzgW9rVnwAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAEAAAAAAAAAAA==', 'AAAAAAAAAAEAAAAA', 'AAAAAgAAAAMAAAA3AAAAAAAAAAAaXI4hE2dLocMSSYYAT2ClklSctk2diyPO36ldXFH/1AAAAAJUC+QAAAAANwAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAA4AAAAAAAAAAAaXI4hE2dLocMSSYYAT2ClklSctk2diyPO36ldXFH/1AAAAAJUC+OcAAAANwAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{K6pcXYMzAEmH08CZ1LWmvtNDKauhx+OImtP/Lk4hVTMJRVBOebVs5WEPj9iSrgGT0EswuDCZ2i5AEzwgGof9Ag==}', 'none', NULL, NULL);


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

