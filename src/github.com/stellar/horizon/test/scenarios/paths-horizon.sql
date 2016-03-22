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

DROP INDEX IF EXISTS public.unique_schema_migrations;
DROP INDEX IF EXISTS public.trade_effects_by_order_book;
DROP INDEX IF EXISTS public.index_history_transactions_on_id;
DROP INDEX IF EXISTS public.index_history_transaction_statuses_lc_on_all;
DROP INDEX IF EXISTS public.index_history_transaction_participants_on_transaction_hash;
DROP INDEX IF EXISTS public.index_history_transaction_participants_on_account;
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
DROP INDEX IF EXISTS public.hs_transaction_by_id;
DROP INDEX IF EXISTS public.hs_ledger_by_id;
DROP INDEX IF EXISTS public.hist_op_p_id;
DROP INDEX IF EXISTS public.hist_e_id;
DROP INDEX IF EXISTS public.hist_e_by_order;
DROP INDEX IF EXISTS public.by_ledger;
DROP INDEX IF EXISTS public.by_hash;
DROP INDEX IF EXISTS public.by_account;
ALTER TABLE IF EXISTS ONLY public.history_transaction_statuses DROP CONSTRAINT IF EXISTS history_transaction_statuses_pkey;
ALTER TABLE IF EXISTS ONLY public.history_transaction_participants DROP CONSTRAINT IF EXISTS history_transaction_participants_pkey;
ALTER TABLE IF EXISTS ONLY public.history_operation_participants DROP CONSTRAINT IF EXISTS history_operation_participants_pkey;
ALTER TABLE IF EXISTS public.history_transaction_statuses ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.history_transaction_participants ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.history_operation_participants ALTER COLUMN id DROP DEFAULT;
DROP TABLE IF EXISTS public.schema_migrations;
DROP TABLE IF EXISTS public.history_transactions;
DROP SEQUENCE IF EXISTS public.history_transaction_statuses_id_seq;
DROP TABLE IF EXISTS public.history_transaction_statuses;
DROP SEQUENCE IF EXISTS public.history_transaction_participants_id_seq;
DROP TABLE IF EXISTS public.history_transaction_participants;
DROP TABLE IF EXISTS public.history_operations;
DROP SEQUENCE IF EXISTS public.history_operation_participants_id_seq;
DROP TABLE IF EXISTS public.history_operation_participants;
DROP TABLE IF EXISTS public.history_ledgers;
DROP TABLE IF EXISTS public.history_effects;
DROP TABLE IF EXISTS public.history_accounts;
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
    result_code_s character varying NOT NULL,
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

INSERT INTO history_accounts VALUES (1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_accounts VALUES (8589938689, 'GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN');
INSERT INTO history_accounts VALUES (8589942785, 'GARSFJNXJIHO6ULUBK3DBYKVSIZE7SC72S5DYBCHU7DKL22UXKVD7MXP');
INSERT INTO history_accounts VALUES (8589946881, 'GAEDTJ4PPEFVW5XV2S7LUXBEHNQMX5Q2GM562RJGOQG7GVCE5H3HIB4V');
INSERT INTO history_accounts VALUES (8589950977, 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL');


--
-- Data for Name: history_effects; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO history_effects VALUES (8589938689, 8589938689, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 8589938689, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (8589938689, 8589938689, 3, 10, '{"weight": 1, "public_key": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}');
INSERT INTO history_effects VALUES (8589942785, 8589942785, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 8589942785, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (8589942785, 8589942785, 3, 10, '{"weight": 1, "public_key": "GARSFJNXJIHO6ULUBK3DBYKVSIZE7SC72S5DYBCHU7DKL22UXKVD7MXP"}');
INSERT INTO history_effects VALUES (8589946881, 8589946881, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 8589946881, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (8589946881, 8589946881, 3, 10, '{"weight": 1, "public_key": "GAEDTJ4PPEFVW5XV2S7LUXBEHNQMX5Q2GM562RJGOQG7GVCE5H3HIB4V"}');
INSERT INTO history_effects VALUES (8589950977, 8589950977, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 8589950977, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (8589950977, 8589950977, 3, 10, '{"weight": 1, "public_key": "GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL"}');
INSERT INTO history_effects VALUES (8589942785, 12884905985, 1, 20, '{"limit": "922337203685.4775807", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}');
INSERT INTO history_effects VALUES (8589946881, 12884910081, 1, 20, '{"limit": "922337203685.4775807", "asset_code": "EUR", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}');
INSERT INTO history_effects VALUES (8589950977, 12884914177, 1, 20, '{"limit": "922337203685.4775807", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}');
INSERT INTO history_effects VALUES (8589950977, 12884918273, 1, 20, '{"limit": "922337203685.4775807", "asset_code": "EUR", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}');
INSERT INTO history_effects VALUES (8589950977, 12884922369, 1, 20, '{"limit": "922337203685.4775807", "asset_code": "1", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}');
INSERT INTO history_effects VALUES (8589950977, 12884926465, 1, 20, '{"limit": "922337203685.4775807", "asset_code": "21", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}');
INSERT INTO history_effects VALUES (8589950977, 12884930561, 1, 20, '{"limit": "922337203685.4775807", "asset_code": "22", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}');
INSERT INTO history_effects VALUES (8589950977, 12884934657, 1, 20, '{"limit": "922337203685.4775807", "asset_code": "31", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}');
INSERT INTO history_effects VALUES (8589950977, 12884938753, 1, 20, '{"limit": "922337203685.4775807", "asset_code": "32", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}');
INSERT INTO history_effects VALUES (8589950977, 12884942849, 1, 20, '{"limit": "922337203685.4775807", "asset_code": "33", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}');
INSERT INTO history_effects VALUES (8589942785, 17179873281, 1, 2, '{"amount": "5000.0000000", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}');
INSERT INTO history_effects VALUES (8589938689, 17179873281, 2, 3, '{"amount": "5000.0000000", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}');
INSERT INTO history_effects VALUES (8589950977, 17179877377, 1, 2, '{"amount": "5000.0000000", "asset_code": "EUR", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}');
INSERT INTO history_effects VALUES (8589938689, 17179877377, 2, 3, '{"amount": "5000.0000000", "asset_code": "EUR", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}');
INSERT INTO history_effects VALUES (8589950977, 17179881473, 1, 2, '{"amount": "5000.0000000", "asset_code": "1", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}');
INSERT INTO history_effects VALUES (8589938689, 17179881473, 2, 3, '{"amount": "5000.0000000", "asset_code": "1", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}');
INSERT INTO history_effects VALUES (8589950977, 17179885569, 1, 2, '{"amount": "5000.0000000", "asset_code": "21", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}');
INSERT INTO history_effects VALUES (8589938689, 17179885569, 2, 3, '{"amount": "5000.0000000", "asset_code": "21", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}');
INSERT INTO history_effects VALUES (8589950977, 17179889665, 1, 2, '{"amount": "5000.0000000", "asset_code": "22", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}');
INSERT INTO history_effects VALUES (8589938689, 17179889665, 2, 3, '{"amount": "5000.0000000", "asset_code": "22", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}');
INSERT INTO history_effects VALUES (8589950977, 17179893761, 1, 2, '{"amount": "5000.0000000", "asset_code": "31", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}');
INSERT INTO history_effects VALUES (8589938689, 17179893761, 2, 3, '{"amount": "5000.0000000", "asset_code": "31", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}');
INSERT INTO history_effects VALUES (8589950977, 17179897857, 1, 2, '{"amount": "5000.0000000", "asset_code": "32", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}');
INSERT INTO history_effects VALUES (8589938689, 17179897857, 2, 3, '{"amount": "5000.0000000", "asset_code": "32", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}');
INSERT INTO history_effects VALUES (8589950977, 17179901953, 1, 2, '{"amount": "5000.0000000", "asset_code": "33", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}');
INSERT INTO history_effects VALUES (8589938689, 17179901953, 2, 3, '{"amount": "5000.0000000", "asset_code": "33", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}');


--
-- Data for Name: history_ledgers; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO history_ledgers VALUES (1, '63d98f536ee68d1b27b5b89f23af5311b7569a24faf1403ad0b52b633b07be99', NULL, 0, 0, '1970-01-01 00:00:00', '2016-03-22 16:08:48.013839', '2016-03-22 16:08:48.013839', 4294967296, 5, 1000000000000000000, 0, 100, 100000000, 100);
INSERT INTO history_ledgers VALUES (2, 'dcb9a503cd26c311ce958c115addbc298a36871284a9ebca67a290ef135f2100', '63d98f536ee68d1b27b5b89f23af5311b7569a24faf1403ad0b52b633b07be99', 4, 4, '2016-03-22 16:08:46', '2016-03-22 16:08:48.032261', '2016-03-22 16:08:48.032261', 8589934592, 5, 1000000000000000000, 400, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (3, '55a7df682d35b2252c2b2b2510d83afca9b250e8390bb0d6e9fca7d0bf3dddcf', 'dcb9a503cd26c311ce958c115addbc298a36871284a9ebca67a290ef135f2100', 10, 10, '2016-03-22 16:08:47', '2016-03-22 16:08:48.150582', '2016-03-22 16:08:48.150582', 12884901888, 5, 1000000000000000000, 1400, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (4, '14fd25f14f74c1c61d77a9cbd64c82c8f74b1f7dc8917a53d8d3aa3203be9db2', '55a7df682d35b2252c2b2b2510d83afca9b250e8390bb0d6e9fca7d0bf3dddcf', 8, 8, '2016-03-22 16:08:48', '2016-03-22 16:08:48.298507', '2016-03-22 16:08:48.298507', 17179869184, 5, 1000000000000000000, 2200, 100, 100000000, 10000);
INSERT INTO history_ledgers VALUES (5, '3e8689360d529c01927a13a0d4b9a61019a81b0e058a28cebdf2651b989a715d', '14fd25f14f74c1c61d77a9cbd64c82c8f74b1f7dc8917a53d8d3aa3203be9db2', 13, 13, '2016-03-22 16:08:49', '2016-03-22 16:08:48.453874', '2016-03-22 16:08:48.453874', 21474836480, 5, 1000000000000000000, 3500, 100, 100000000, 10000);


--
-- Data for Name: history_operation_participants; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO history_operation_participants VALUES (922, 8589938689, 1);
INSERT INTO history_operation_participants VALUES (923, 8589938689, 8589938689);
INSERT INTO history_operation_participants VALUES (924, 8589942785, 1);
INSERT INTO history_operation_participants VALUES (925, 8589942785, 8589942785);
INSERT INTO history_operation_participants VALUES (926, 8589946881, 1);
INSERT INTO history_operation_participants VALUES (927, 8589946881, 8589946881);
INSERT INTO history_operation_participants VALUES (928, 8589950977, 1);
INSERT INTO history_operation_participants VALUES (929, 8589950977, 8589950977);
INSERT INTO history_operation_participants VALUES (930, 12884905985, 8589942785);
INSERT INTO history_operation_participants VALUES (931, 12884910081, 8589946881);
INSERT INTO history_operation_participants VALUES (932, 12884914177, 8589950977);
INSERT INTO history_operation_participants VALUES (933, 12884918273, 8589950977);
INSERT INTO history_operation_participants VALUES (934, 12884922369, 8589950977);
INSERT INTO history_operation_participants VALUES (935, 12884926465, 8589950977);
INSERT INTO history_operation_participants VALUES (936, 12884930561, 8589950977);
INSERT INTO history_operation_participants VALUES (937, 12884934657, 8589950977);
INSERT INTO history_operation_participants VALUES (938, 12884938753, 8589950977);
INSERT INTO history_operation_participants VALUES (939, 12884942849, 8589950977);
INSERT INTO history_operation_participants VALUES (940, 17179873281, 8589938689);
INSERT INTO history_operation_participants VALUES (941, 17179873281, 8589942785);
INSERT INTO history_operation_participants VALUES (942, 17179877377, 8589938689);
INSERT INTO history_operation_participants VALUES (943, 17179877377, 8589950977);
INSERT INTO history_operation_participants VALUES (944, 17179881473, 8589938689);
INSERT INTO history_operation_participants VALUES (945, 17179881473, 8589950977);
INSERT INTO history_operation_participants VALUES (946, 17179885569, 8589938689);
INSERT INTO history_operation_participants VALUES (947, 17179885569, 8589950977);
INSERT INTO history_operation_participants VALUES (948, 17179889665, 8589938689);
INSERT INTO history_operation_participants VALUES (949, 17179889665, 8589950977);
INSERT INTO history_operation_participants VALUES (950, 17179893761, 8589938689);
INSERT INTO history_operation_participants VALUES (951, 17179893761, 8589950977);
INSERT INTO history_operation_participants VALUES (952, 17179897857, 8589938689);
INSERT INTO history_operation_participants VALUES (953, 17179897857, 8589950977);
INSERT INTO history_operation_participants VALUES (954, 17179901953, 8589938689);
INSERT INTO history_operation_participants VALUES (955, 17179901953, 8589950977);
INSERT INTO history_operation_participants VALUES (956, 21474840577, 8589950977);
INSERT INTO history_operation_participants VALUES (957, 21474844673, 8589938689);
INSERT INTO history_operation_participants VALUES (958, 21474848769, 8589950977);
INSERT INTO history_operation_participants VALUES (959, 21474852865, 8589938689);
INSERT INTO history_operation_participants VALUES (960, 21474856961, 8589950977);
INSERT INTO history_operation_participants VALUES (961, 21474861057, 8589938689);
INSERT INTO history_operation_participants VALUES (962, 21474865153, 8589950977);
INSERT INTO history_operation_participants VALUES (963, 21474869249, 8589950977);
INSERT INTO history_operation_participants VALUES (964, 21474873345, 8589950977);
INSERT INTO history_operation_participants VALUES (965, 21474877441, 8589950977);
INSERT INTO history_operation_participants VALUES (966, 21474881537, 8589950977);
INSERT INTO history_operation_participants VALUES (967, 21474885633, 8589950977);
INSERT INTO history_operation_participants VALUES (968, 21474889729, 8589950977);


--
-- Name: history_operation_participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('history_operation_participants_id_seq', 968, true);


--
-- Data for Name: history_operations; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO history_operations VALUES (8589938689, 8589938688, 1, 0, '{"funder": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "account": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN", "starting_balance": "1000.0000000"}', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_operations VALUES (8589942785, 8589942784, 1, 0, '{"funder": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "account": "GARSFJNXJIHO6ULUBK3DBYKVSIZE7SC72S5DYBCHU7DKL22UXKVD7MXP", "starting_balance": "1000.0000000"}', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_operations VALUES (8589946881, 8589946880, 1, 0, '{"funder": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "account": "GAEDTJ4PPEFVW5XV2S7LUXBEHNQMX5Q2GM562RJGOQG7GVCE5H3HIB4V", "starting_balance": "1000.0000000"}', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_operations VALUES (8589950977, 8589950976, 1, 0, '{"funder": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "account": "GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL", "starting_balance": "1000.0000000"}', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_operations VALUES (12884905985, 12884905984, 1, 6, '{"limit": "922337203685.4775807", "trustee": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN", "trustor": "GARSFJNXJIHO6ULUBK3DBYKVSIZE7SC72S5DYBCHU7DKL22UXKVD7MXP", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}', 'GARSFJNXJIHO6ULUBK3DBYKVSIZE7SC72S5DYBCHU7DKL22UXKVD7MXP');
INSERT INTO history_operations VALUES (12884910081, 12884910080, 1, 6, '{"limit": "922337203685.4775807", "trustee": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN", "trustor": "GAEDTJ4PPEFVW5XV2S7LUXBEHNQMX5Q2GM562RJGOQG7GVCE5H3HIB4V", "asset_code": "EUR", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}', 'GAEDTJ4PPEFVW5XV2S7LUXBEHNQMX5Q2GM562RJGOQG7GVCE5H3HIB4V');
INSERT INTO history_operations VALUES (12884914177, 12884914176, 1, 6, '{"limit": "922337203685.4775807", "trustee": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN", "trustor": "GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL');
INSERT INTO history_operations VALUES (12884918273, 12884918272, 1, 6, '{"limit": "922337203685.4775807", "trustee": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN", "trustor": "GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL", "asset_code": "EUR", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL');
INSERT INTO history_operations VALUES (12884922369, 12884922368, 1, 6, '{"limit": "922337203685.4775807", "trustee": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN", "trustor": "GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL", "asset_code": "1", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL');
INSERT INTO history_operations VALUES (12884926465, 12884926464, 1, 6, '{"limit": "922337203685.4775807", "trustee": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN", "trustor": "GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL", "asset_code": "21", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL');
INSERT INTO history_operations VALUES (12884930561, 12884930560, 1, 6, '{"limit": "922337203685.4775807", "trustee": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN", "trustor": "GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL", "asset_code": "22", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL');
INSERT INTO history_operations VALUES (12884934657, 12884934656, 1, 6, '{"limit": "922337203685.4775807", "trustee": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN", "trustor": "GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL", "asset_code": "31", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL');
INSERT INTO history_operations VALUES (12884938753, 12884938752, 1, 6, '{"limit": "922337203685.4775807", "trustee": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN", "trustor": "GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL", "asset_code": "32", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL');
INSERT INTO history_operations VALUES (12884942849, 12884942848, 1, 6, '{"limit": "922337203685.4775807", "trustee": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN", "trustor": "GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL", "asset_code": "33", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL');
INSERT INTO history_operations VALUES (17179873281, 17179873280, 1, 1, '{"to": "GARSFJNXJIHO6ULUBK3DBYKVSIZE7SC72S5DYBCHU7DKL22UXKVD7MXP", "from": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN", "amount": "5000.0000000", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}', 'GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN');
INSERT INTO history_operations VALUES (17179877377, 17179877376, 1, 1, '{"to": "GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL", "from": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN", "amount": "5000.0000000", "asset_code": "EUR", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}', 'GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN');
INSERT INTO history_operations VALUES (17179881473, 17179881472, 1, 1, '{"to": "GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL", "from": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN", "amount": "5000.0000000", "asset_code": "1", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}', 'GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN');
INSERT INTO history_operations VALUES (17179885569, 17179885568, 1, 1, '{"to": "GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL", "from": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN", "amount": "5000.0000000", "asset_code": "21", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}', 'GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN');
INSERT INTO history_operations VALUES (17179889665, 17179889664, 1, 1, '{"to": "GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL", "from": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN", "amount": "5000.0000000", "asset_code": "22", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}', 'GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN');
INSERT INTO history_operations VALUES (17179893761, 17179893760, 1, 1, '{"to": "GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL", "from": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN", "amount": "5000.0000000", "asset_code": "31", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}', 'GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN');
INSERT INTO history_operations VALUES (17179897857, 17179897856, 1, 1, '{"to": "GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL", "from": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN", "amount": "5000.0000000", "asset_code": "32", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}', 'GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN');
INSERT INTO history_operations VALUES (17179901953, 17179901952, 1, 1, '{"to": "GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL", "from": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN", "amount": "5000.0000000", "asset_code": "33", "asset_type": "credit_alphanum4", "asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}', 'GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN');
INSERT INTO history_operations VALUES (21474840577, 21474840576, 1, 3, '{"price": "0.5000000", "amount": "10.0000000", "price_r": {"d": 2, "n": 1}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_code": "EUR", "selling_asset_type": "credit_alphanum4", "buying_asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN", "selling_asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL');
INSERT INTO history_operations VALUES (21474844673, 21474844672, 1, 3, '{"price": "1.0000000", "amount": "10.0000000", "price_r": {"d": 1, "n": 1}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_code": "EUR", "selling_asset_type": "credit_alphanum4", "buying_asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN", "selling_asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}', 'GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN');
INSERT INTO history_operations VALUES (21474848769, 21474848768, 1, 3, '{"price": "1.0000000", "amount": "20.0000000", "price_r": {"d": 1, "n": 1}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_code": "1", "selling_asset_type": "credit_alphanum4", "buying_asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN", "selling_asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL');
INSERT INTO history_operations VALUES (21474852865, 21474852864, 1, 3, '{"price": "0.5000000", "amount": "10.0000000", "price_r": {"d": 2, "n": 1}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_code": "EUR", "selling_asset_type": "credit_alphanum4", "buying_asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN", "selling_asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}', 'GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN');
INSERT INTO history_operations VALUES (21474856961, 21474856960, 1, 3, '{"price": "1.0000000", "amount": "20.0000000", "price_r": {"d": 1, "n": 1}, "offer_id": 0, "buying_asset_code": "1", "buying_asset_type": "credit_alphanum4", "selling_asset_code": "EUR", "selling_asset_type": "credit_alphanum4", "buying_asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN", "selling_asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL');
INSERT INTO history_operations VALUES (21474861057, 21474861056, 1, 3, '{"price": "0.1000000", "amount": "1000.0000000", "price_r": {"d": 10, "n": 1}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_type": "native", "buying_asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}', 'GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN');
INSERT INTO history_operations VALUES (21474865153, 21474865152, 1, 3, '{"price": "1.0000000", "amount": "30.0000000", "price_r": {"d": 1, "n": 1}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_code": "21", "selling_asset_type": "credit_alphanum4", "buying_asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN", "selling_asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL');
INSERT INTO history_operations VALUES (21474869249, 21474869248, 1, 3, '{"price": "1.0000000", "amount": "30.0000000", "price_r": {"d": 1, "n": 1}, "offer_id": 0, "buying_asset_code": "21", "buying_asset_type": "credit_alphanum4", "selling_asset_code": "22", "selling_asset_type": "credit_alphanum4", "buying_asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN", "selling_asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL');
INSERT INTO history_operations VALUES (21474873345, 21474873344, 1, 3, '{"price": "1.0000000", "amount": "30.0000000", "price_r": {"d": 1, "n": 1}, "offer_id": 0, "buying_asset_code": "22", "buying_asset_type": "credit_alphanum4", "selling_asset_code": "EUR", "selling_asset_type": "credit_alphanum4", "buying_asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN", "selling_asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL');
INSERT INTO history_operations VALUES (21474877441, 21474877440, 1, 3, '{"price": "2.0000000", "amount": "40.0000000", "price_r": {"d": 1, "n": 2}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_code": "31", "selling_asset_type": "credit_alphanum4", "buying_asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN", "selling_asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL');
INSERT INTO history_operations VALUES (21474881537, 21474881536, 1, 3, '{"price": "2.0000000", "amount": "40.0000000", "price_r": {"d": 1, "n": 2}, "offer_id": 0, "buying_asset_code": "31", "buying_asset_type": "credit_alphanum4", "selling_asset_code": "32", "selling_asset_type": "credit_alphanum4", "buying_asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN", "selling_asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL');
INSERT INTO history_operations VALUES (21474885633, 21474885632, 1, 3, '{"price": "2.0000000", "amount": "40.0000000", "price_r": {"d": 1, "n": 2}, "offer_id": 0, "buying_asset_code": "32", "buying_asset_type": "credit_alphanum4", "selling_asset_code": "33", "selling_asset_type": "credit_alphanum4", "buying_asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN", "selling_asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL');
INSERT INTO history_operations VALUES (21474889729, 21474889728, 1, 3, '{"price": "2.0000000", "amount": "40.0000000", "price_r": {"d": 1, "n": 2}, "offer_id": 0, "buying_asset_code": "33", "buying_asset_type": "credit_alphanum4", "selling_asset_code": "EUR", "selling_asset_type": "credit_alphanum4", "buying_asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN", "selling_asset_issuer": "GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN"}', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL');


--
-- Data for Name: history_transaction_participants; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO history_transaction_participants VALUES (945, '9ff6b71bba6b24c8afc6ca53b12702566d40e9c8abf9b8439e9a3b08300e4188', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', '2016-03-22 16:08:48.041632', '2016-03-22 16:08:48.041632');
INSERT INTO history_transaction_participants VALUES (946, '9ff6b71bba6b24c8afc6ca53b12702566d40e9c8abf9b8439e9a3b08300e4188', 'GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN', '2016-03-22 16:08:48.043422', '2016-03-22 16:08:48.043422');
INSERT INTO history_transaction_participants VALUES (947, 'afc983f7f88809442fc616c1ce425b6c8cf6d8f7493b33ff6a809003a845ec16', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', '2016-03-22 16:08:48.070219', '2016-03-22 16:08:48.070219');
INSERT INTO history_transaction_participants VALUES (948, 'afc983f7f88809442fc616c1ce425b6c8cf6d8f7493b33ff6a809003a845ec16', 'GARSFJNXJIHO6ULUBK3DBYKVSIZE7SC72S5DYBCHU7DKL22UXKVD7MXP', '2016-03-22 16:08:48.071287', '2016-03-22 16:08:48.071287');
INSERT INTO history_transaction_participants VALUES (949, '5c71f1b198a9be6b1c7e36737bb3e32c7f258530573bc11f20827d0913ba1433', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', '2016-03-22 16:08:48.098627', '2016-03-22 16:08:48.098627');
INSERT INTO history_transaction_participants VALUES (950, '5c71f1b198a9be6b1c7e36737bb3e32c7f258530573bc11f20827d0913ba1433', 'GAEDTJ4PPEFVW5XV2S7LUXBEHNQMX5Q2GM562RJGOQG7GVCE5H3HIB4V', '2016-03-22 16:08:48.099699', '2016-03-22 16:08:48.099699');
INSERT INTO history_transaction_participants VALUES (951, '06445dc688fc2e583567e4a4940440d87cf4877a57af306ece7c64f1f061def4', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', '2016-03-22 16:08:48.121799', '2016-03-22 16:08:48.121799');
INSERT INTO history_transaction_participants VALUES (952, '06445dc688fc2e583567e4a4940440d87cf4877a57af306ece7c64f1f061def4', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', '2016-03-22 16:08:48.122758', '2016-03-22 16:08:48.122758');
INSERT INTO history_transaction_participants VALUES (953, '563ab1cf87e65377e015813499a6027081e63177a9ef35a0c5e0c0c2a5a918f7', 'GARSFJNXJIHO6ULUBK3DBYKVSIZE7SC72S5DYBCHU7DKL22UXKVD7MXP', '2016-03-22 16:08:48.156525', '2016-03-22 16:08:48.156525');
INSERT INTO history_transaction_participants VALUES (954, 'cdb0ce2cef61c5cab6566c1c65c5bc632f943b2bd43cfdd80984a66994cb7484', 'GAEDTJ4PPEFVW5XV2S7LUXBEHNQMX5Q2GM562RJGOQG7GVCE5H3HIB4V', '2016-03-22 16:08:48.169628', '2016-03-22 16:08:48.169628');
INSERT INTO history_transaction_participants VALUES (955, 'd76450086b21a849e31a168577a9c112a913c3317a3f0c1a80c6cb43e16cf348', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', '2016-03-22 16:08:48.182591', '2016-03-22 16:08:48.182591');
INSERT INTO history_transaction_participants VALUES (956, 'ffe9db595b5e8be4d54b738e78652704dd96ad8729bc6b6adc17c300162f2c98', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', '2016-03-22 16:08:48.195879', '2016-03-22 16:08:48.195879');
INSERT INTO history_transaction_participants VALUES (957, '1a1dc052649f98314a12a17911d3868523d7806887d49a52749221b17cd713ce', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', '2016-03-22 16:08:48.209115', '2016-03-22 16:08:48.209115');
INSERT INTO history_transaction_participants VALUES (958, '6bfdfd3aeff0f617532caf59ee28fe60b7c20ffa6574e08beecda9a890d8f2b2', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', '2016-03-22 16:08:48.221821', '2016-03-22 16:08:48.221821');
INSERT INTO history_transaction_participants VALUES (959, 'b48686858ee595141fb7d5d9999d5d40b78cacc4e27092e48824c8a0ac01370e', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', '2016-03-22 16:08:48.234657', '2016-03-22 16:08:48.234657');
INSERT INTO history_transaction_participants VALUES (960, 'e6315711266014d425b16b339bba063ad1b8d8823b5dfb8cd3399644754be459', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', '2016-03-22 16:08:48.247466', '2016-03-22 16:08:48.247466');
INSERT INTO history_transaction_participants VALUES (961, '344a58add4f45245924cef37386866e0fd10f38f797615551c59fc0b5521e517', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', '2016-03-22 16:08:48.264248', '2016-03-22 16:08:48.264248');
INSERT INTO history_transaction_participants VALUES (962, '254f4bd646c27c730501f50bf5c9543b3510c10f8b39152b74a75cd78ec5aa7a', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', '2016-03-22 16:08:48.27823', '2016-03-22 16:08:48.27823');
INSERT INTO history_transaction_participants VALUES (963, 'a3fc459ac9baa9c327254ae6eb182fb60dd597ac3761159393de1564f59efa77', 'GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN', '2016-03-22 16:08:48.304166', '2016-03-22 16:08:48.304166');
INSERT INTO history_transaction_participants VALUES (964, 'a3fc459ac9baa9c327254ae6eb182fb60dd597ac3761159393de1564f59efa77', 'GARSFJNXJIHO6ULUBK3DBYKVSIZE7SC72S5DYBCHU7DKL22UXKVD7MXP', '2016-03-22 16:08:48.311681', '2016-03-22 16:08:48.311681');
INSERT INTO history_transaction_participants VALUES (965, '9dc1746a8a1fae0abf8756d189c3d421bb5b5a0d5c0f8a3834da6d6aae8311c7', 'GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN', '2016-03-22 16:08:48.327782', '2016-03-22 16:08:48.327782');
INSERT INTO history_transaction_participants VALUES (966, '9dc1746a8a1fae0abf8756d189c3d421bb5b5a0d5c0f8a3834da6d6aae8311c7', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', '2016-03-22 16:08:48.328932', '2016-03-22 16:08:48.328932');
INSERT INTO history_transaction_participants VALUES (967, '335970f27c1141c865b9a77189ffe71591d13c49c8d62d57239228562bc43cf2', 'GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN', '2016-03-22 16:08:48.344965', '2016-03-22 16:08:48.344965');
INSERT INTO history_transaction_participants VALUES (968, '335970f27c1141c865b9a77189ffe71591d13c49c8d62d57239228562bc43cf2', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', '2016-03-22 16:08:48.345896', '2016-03-22 16:08:48.345896');
INSERT INTO history_transaction_participants VALUES (969, '63fd31091c6a3333a8ee23297c255e1d899a275519c48defd3ce0708a904c12b', 'GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN', '2016-03-22 16:08:48.362011', '2016-03-22 16:08:48.362011');
INSERT INTO history_transaction_participants VALUES (970, '63fd31091c6a3333a8ee23297c255e1d899a275519c48defd3ce0708a904c12b', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', '2016-03-22 16:08:48.362984', '2016-03-22 16:08:48.362984');
INSERT INTO history_transaction_participants VALUES (971, '9b28e1c8e857b0efd958c70c36d777f36e053d4f0d2073d3276c18cfc85f9249', 'GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN', '2016-03-22 16:08:48.379144', '2016-03-22 16:08:48.379144');
INSERT INTO history_transaction_participants VALUES (972, '9b28e1c8e857b0efd958c70c36d777f36e053d4f0d2073d3276c18cfc85f9249', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', '2016-03-22 16:08:48.380146', '2016-03-22 16:08:48.380146');
INSERT INTO history_transaction_participants VALUES (973, '8208aa13fc4d71b7ae079072b3a3af1bfd8806ba6fd354d3fcbd127b7c0fe232', 'GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN', '2016-03-22 16:08:48.396469', '2016-03-22 16:08:48.396469');
INSERT INTO history_transaction_participants VALUES (974, '8208aa13fc4d71b7ae079072b3a3af1bfd8806ba6fd354d3fcbd127b7c0fe232', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', '2016-03-22 16:08:48.397416', '2016-03-22 16:08:48.397416');
INSERT INTO history_transaction_participants VALUES (975, '7c663b4fe86794c57b4f3d718b5048be1aa1e084e52f3468dd470829a057cfeb', 'GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN', '2016-03-22 16:08:48.413923', '2016-03-22 16:08:48.413923');
INSERT INTO history_transaction_participants VALUES (976, '7c663b4fe86794c57b4f3d718b5048be1aa1e084e52f3468dd470829a057cfeb', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', '2016-03-22 16:08:48.414988', '2016-03-22 16:08:48.414988');
INSERT INTO history_transaction_participants VALUES (977, '57d54e294ca2d6206226a8950976bbec3852a05f977c895b68510e329ed1cf9b', 'GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN', '2016-03-22 16:08:48.431081', '2016-03-22 16:08:48.431081');
INSERT INTO history_transaction_participants VALUES (978, '57d54e294ca2d6206226a8950976bbec3852a05f977c895b68510e329ed1cf9b', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', '2016-03-22 16:08:48.432044', '2016-03-22 16:08:48.432044');
INSERT INTO history_transaction_participants VALUES (979, 'a11c4e1aada500470b2f9519a3797f6cfb70f8a776869fbf4b4b516b4d2e8133', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', '2016-03-22 16:08:48.459266', '2016-03-22 16:08:48.459266');
INSERT INTO history_transaction_participants VALUES (980, 'b5e88105a360ca97acb39a2636f7cf5cdf7a901acd0d4be9c8091ba227e0452c', 'GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN', '2016-03-22 16:08:48.469334', '2016-03-22 16:08:48.469334');
INSERT INTO history_transaction_participants VALUES (981, '4781659c29cabdfdc55dd8d007ddd1540f6fb45f3b4ce648e45c32257e47c4a6', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', '2016-03-22 16:08:48.479121', '2016-03-22 16:08:48.479121');
INSERT INTO history_transaction_participants VALUES (982, 'fac63542d996fcba0e6bcb723ca94b5a3b415b36e4eeac64c881dfd61d478fe7', 'GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN', '2016-03-22 16:08:48.488636', '2016-03-22 16:08:48.488636');
INSERT INTO history_transaction_participants VALUES (983, '8915d7a8cc6be26c19195a736b535d5d7bba506f267267449787240bae9c1c80', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', '2016-03-22 16:08:48.497918', '2016-03-22 16:08:48.497918');
INSERT INTO history_transaction_participants VALUES (984, '0e12e13702a9573c885291f36b36561c288d8fc4d2f92dcf484132b6c8d408bf', 'GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN', '2016-03-22 16:08:48.507721', '2016-03-22 16:08:48.507721');
INSERT INTO history_transaction_participants VALUES (985, 'b9925fafee10dce3211337718217a7a0691ca60d9f67c56d9a3ec823acd0c95e', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', '2016-03-22 16:08:48.517082', '2016-03-22 16:08:48.517082');
INSERT INTO history_transaction_participants VALUES (986, 'a89dc0b7e9e01af735994cb66cf775bfd37fb0e61225254294c00627f2cfe91a', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', '2016-03-22 16:08:48.526355', '2016-03-22 16:08:48.526355');
INSERT INTO history_transaction_participants VALUES (987, 'c92bb5f0ce6cbf74949af7b6404e0aae1839dcb174ca07b86b0690386b488e30', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', '2016-03-22 16:08:48.535799', '2016-03-22 16:08:48.535799');
INSERT INTO history_transaction_participants VALUES (988, '8af50985527a5383992cef73235c1f9a650aa613984936afd47b72bf0b23d07a', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', '2016-03-22 16:08:48.545259', '2016-03-22 16:08:48.545259');
INSERT INTO history_transaction_participants VALUES (989, '487644504432e9323eace0dd116cbb3218f2801391a91b2646cb67d797897abf', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', '2016-03-22 16:08:48.554695', '2016-03-22 16:08:48.554695');
INSERT INTO history_transaction_participants VALUES (990, 'a34de60105499cdc69a3020fc67fa40229cd2fba20efa64e7e3530e6dcb5a4f4', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', '2016-03-22 16:08:48.564209', '2016-03-22 16:08:48.564209');
INSERT INTO history_transaction_participants VALUES (991, '94e908960415a58313962f8319cc695922cf0a45b56b3b6be9b81778134b9b81', 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', '2016-03-22 16:08:48.57381', '2016-03-22 16:08:48.57381');


--
-- Name: history_transaction_participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('history_transaction_participants_id_seq', 991, true);


--
-- Data for Name: history_transaction_statuses; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Name: history_transaction_statuses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('history_transaction_statuses_id_seq', 1, false);


--
-- Data for Name: history_transactions; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO history_transactions VALUES ('9ff6b71bba6b24c8afc6ca53b12702566d40e9c8abf9b8439e9a3b08300e4188', 2, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 1, 100, 1, '2016-03-22 16:08:48.038056', '2016-03-22 16:08:48.038056', 8589938688, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAABAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAA5BFB2+Hs81DQk/cAlJes5R0+3PUQaZ62NZJoKPsBWnsAAAACVAvkAAAAAAAAAAABVvwF9wAAAEC96/+BcbMflvMQfFAQTbAKGu+6BR1M6SG/KVzTJSlIY8ovSVywuthk9dOW9jm23siTiIZE0IAl84wK83gnAcEK', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAAAIAAAAAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAAlQL5AAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAIAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2sVNYGnAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAABAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnZAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAACAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnY/+cAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{vev/gXGzH5bzEHxQEE2wChrvugUdTOkhvylc0yUpSGPKL0lcsLrYZPXTlvY5tt7Ik4iGRNCAJfOMCvN4JwHBCg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('afc983f7f88809442fc616c1ce425b6c8cf6d8f7493b33ff6a809003a845ec16', 2, 2, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 2, 100, 1, '2016-03-22 16:08:48.067866', '2016-03-22 16:08:48.067866', 8589942784, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAACAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAIyKlt0oO71F0CrYw4VWSMk/IX9S6PARHp8al61S6qj8AAAACVAvkAAAAAAAAAAABVvwF9wAAAECXh9/+55FmQjeMx9IMQfBn42fYY1fKAT/gb+e7P3jdSMCKiKhwoxj1bub733a2XuxPETpe79uzatzm8/KI0asI', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAAAIAAAAAAAAAACMipbdKDu9RdAq2MOFVkjJPyF/UujwER6fGpetUuqo/AAAAAlQL5AAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAIAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2rv9MNnAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAACAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnY/84AAAAAAAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{l4ff/ueRZkI3jMfSDEHwZ+Nn2GNXygE/4G/nuz943UjAioiocKMY9W7m+992tl7sTxE6Xu/bs2rc5vPyiNGrCA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('5c71f1b198a9be6b1c7e36737bb3e32c7f258530573bc11f20827d0913ba1433', 2, 3, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 3, 100, 1, '2016-03-22 16:08:48.0963', '2016-03-22 16:08:48.0963', 8589946880, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAADAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAACDmnj3kLW3b11L66XCQ7YMv2GjM77UUmdA3zVETp9nQAAAACVAvkAAAAAAAAAAABVvwF9wAAAEBdnUBKCV3HlHOqp5iNLsP8auaNCvxDeBp+0C+lwPYUNrzRALQRDJDWuKfExmsRrEnW8LKJbMdeW9ilLaEc2lAO', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAAAIAAAAAAAAAAAg5p495C1t29dS+ulwkO2DL9hozO+1FJnQN81RE6fZ0AAAAAlQL5AAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAIAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2rKtAUnAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAACAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnY/7UAAAAAAAAAAMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{XZ1ASgldx5RzqqeYjS7D/GrmjQr8Q3gaftAvpcD2FDa80QC0EQyQ1rinxMZrEaxJ1vCyiWzHXlvYpS2hHNpQDg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('06445dc688fc2e583567e4a4940440d87cf4877a57af306ece7c64f1f061def4', 2, 4, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 4, 100, 1, '2016-03-22 16:08:48.119709', '2016-03-22 16:08:48.119709', 8589950976, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAAEAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAANNFzLrsuusAQh1EFJvz7NvUGFdN7Svc8ddcE7EpgQacAAAACVAvkAAAAAAAAAAABVvwF9wAAAEAfH3XJo+xZ8adtaA2PZZ3T0kM57CXfxGl+JItnC6nP9LziLQMKgl1EEhuiPqfjn14KK5WfEv0E0op5BJFAkd8O', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAAAIAAAAAAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAAlQL5AAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAIAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2qlc0bnAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAACAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnY/5wAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{Hx91yaPsWfGnbWgNj2Wd09JDOewl38RpfiSLZwupz/S84i0DCoJdRBIboj6n459eCiuVnxL9BNKKeQSRQJHfDg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('563ab1cf87e65377e015813499a6027081e63177a9ef35a0c5e0c0c2a5a918f7', 3, 1, 'GARSFJNXJIHO6ULUBK3DBYKVSIZE7SC72S5DYBCHU7DKL22UXKVD7MXP', 8589934593, 100, 1, '2016-03-22 16:08:48.15428', '2016-03-22 16:08:48.15428', 12884905984, 'AAAAACMipbdKDu9RdAq2MOFVkjJPyF/UujwER6fGpetUuqo/AAAAZAAAAAIAAAABAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABVVNEAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFae3//////////AAAAAAAAAAFUuqo/AAAAQKblh64EFK4tp2+xohOkNaSdfMFDId/y4nop7dVmZRsbe4f/eVCpUrKQCRWLJ4bXzMpPTOTsjHRIxOa8WekP+ww=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAGAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAAAMAAAABAAAAACMipbdKDu9RdAq2MOFVkjJPyF/UujwER6fGpetUuqo/AAAAAVVTRAAAAAAA5BFB2+Hs81DQk/cAlJes5R0+3PUQaZ62NZJoKPsBWnsAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAAAMAAAAAAAAAACMipbdKDu9RdAq2MOFVkjJPyF/UujwER6fGpetUuqo/AAAAAlQL45wAAAACAAAAAQAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAACAAAAAAAAAAAjIqW3Sg7vUXQKtjDhVZIyT8hf1Lo8BEenxqXrVLqqPwAAAAJUC+QAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAADAAAAAAAAAAAjIqW3Sg7vUXQKtjDhVZIyT8hf1Lo8BEenxqXrVLqqPwAAAAJUC+OcAAAAAgAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{puWHrgQUri2nb7GiE6Q1pJ18wUMh3/Lieint1WZlGxt7h/95UKlSspAJFYsnhtfMyk9M5OyMdEjE5rxZ6Q/7DA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('cdb0ce2cef61c5cab6566c1c65c5bc632f943b2bd43cfdd80984a66994cb7484', 3, 2, 'GAEDTJ4PPEFVW5XV2S7LUXBEHNQMX5Q2GM562RJGOQG7GVCE5H3HIB4V', 8589934593, 100, 1, '2016-03-22 16:08:48.167566', '2016-03-22 16:08:48.167566', 12884910080, 'AAAAAAg5p495C1t29dS+ulwkO2DL9hozO+1FJnQN81RE6fZ0AAAAZAAAAAIAAAABAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABRVVSAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFae3//////////AAAAAAAAAAFE6fZ0AAAAQNSm/BIxP9LwabXoBKigrTG85o/PUp6VOWh/ne6mMaT5hvehDUvbRHQghJ/SZTDfjD+FPPjbe3nzcJEun1EX4g0=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAGAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAAAMAAAABAAAAAAg5p495C1t29dS+ulwkO2DL9hozO+1FJnQN81RE6fZ0AAAAAUVVUgAAAAAA5BFB2+Hs81DQk/cAlJes5R0+3PUQaZ62NZJoKPsBWnsAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAAAMAAAAAAAAAAAg5p495C1t29dS+ulwkO2DL9hozO+1FJnQN81RE6fZ0AAAAAlQL45wAAAACAAAAAQAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAACAAAAAAAAAAAIOaePeQtbdvXUvrpcJDtgy/YaMzvtRSZ0DfNUROn2dAAAAAJUC+QAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAADAAAAAAAAAAAIOaePeQtbdvXUvrpcJDtgy/YaMzvtRSZ0DfNUROn2dAAAAAJUC+OcAAAAAgAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{1Kb8EjE/0vBptegEqKCtMbzmj89SnpU5aH+d7qYxpPmG96ENS9tEdCCEn9JlMN+MP4U8+Nt7efNwkS6fURfiDQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('d76450086b21a849e31a168577a9c112a913c3317a3f0c1a80c6cb43e16cf348', 3, 3, 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', 8589934593, 100, 1, '2016-03-22 16:08:48.180249', '2016-03-22 16:08:48.180249', 12884914176, 'AAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAZAAAAAIAAAABAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABVVNEAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFae3//////////AAAAAAAAAAFKYEGnAAAAQC0FIi0RCGDQ0EuuBT5Kg2XxzHxLXRrCxYGj+hY7/sB2Y+JtWyWRjlq3DYL4ajSFE8Na1KKm42oM/gjZUx+1PQU=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAGAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAAAMAAAABAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAAVVTRAAAAAAA5BFB2+Hs81DQk/cAlJes5R0+3PUQaZ62NZJoKPsBWnsAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAAAMAAAAAAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAAlQL4OAAAAACAAAACAAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAACAAAAAAAAAAA00XMuuy66wBCHUQUm/Ps29QYV03tK9zx11wTsSmBBpwAAAAJUC+QAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAADAAAAAAAAAAA00XMuuy66wBCHUQUm/Ps29QYV03tK9zx11wTsSmBBpwAAAAJUC+OcAAAAAgAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{LQUiLREIYNDQS64FPkqDZfHMfEtdGsLFgaP6Fjv+wHZj4m1bJZGOWrcNgvhqNIUTw1rUoqbjagz+CNlTH7U9BQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('ffe9db595b5e8be4d54b738e78652704dd96ad8729bc6b6adc17c300162f2c98', 3, 4, 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', 8589934594, 100, 1, '2016-03-22 16:08:48.193773', '2016-03-22 16:08:48.193773', 12884918272, 'AAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAZAAAAAIAAAACAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABRVVSAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFae3//////////AAAAAAAAAAFKYEGnAAAAQNdoCZqF5REF4OZCu65uUph5WUYmUKAcNCwgaJe4Mbakx92kViEe9kaJ13EhVOP7U+yjno/L1v1wpTaTa7YDiAc=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAGAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAAAMAAAABAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAAUVVUgAAAAAA5BFB2+Hs81DQk/cAlJes5R0+3PUQaZ62NZJoKPsBWnsAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAAAMAAAAAAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAAlQL4OAAAAACAAAACAAAAAIAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAADAAAAAAAAAAA00XMuuy66wBCHUQUm/Ps29QYV03tK9zx11wTsSmBBpwAAAAJUC+M4AAAAAgAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{12gJmoXlEQXg5kK7rm5SmHlZRiZQoBw0LCBol7gxtqTH3aRWIR72RonXcSFU4/tT7KOej8vW/XClNpNrtgOIBw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('1a1dc052649f98314a12a17911d3868523d7806887d49a52749221b17cd713ce', 3, 5, 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', 8589934595, 100, 1, '2016-03-22 16:08:48.207064', '2016-03-22 16:08:48.207064', 12884922368, 'AAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAZAAAAAIAAAADAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABMQAAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFae3//////////AAAAAAAAAAFKYEGnAAAAQMXWsXqylJxEXU0J+7PHlS/xBkw6/LXU23Q3sv7ew9z8KZZJbFEqDgrh340V57e/Xo1CIOdcRWHYpSZ0YZf5jg0=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAGAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAAAMAAAABAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAATEAAAAAAAAA5BFB2+Hs81DQk/cAlJes5R0+3PUQaZ62NZJoKPsBWnsAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAAAMAAAAAAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAAlQL4OAAAAACAAAACAAAAAMAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAADAAAAAAAAAAA00XMuuy66wBCHUQUm/Ps29QYV03tK9zx11wTsSmBBpwAAAAJUC+LUAAAAAgAAAAMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{xdaxerKUnERdTQn7s8eVL/EGTDr8tdTbdDey/t7D3PwplklsUSoOCuHfjRXnt79ejUIg51xFYdilJnRhl/mODQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('6bfdfd3aeff0f617532caf59ee28fe60b7c20ffa6574e08beecda9a890d8f2b2', 3, 6, 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', 8589934596, 100, 1, '2016-03-22 16:08:48.219704', '2016-03-22 16:08:48.219704', 12884926464, 'AAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAZAAAAAIAAAAEAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABMjEAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFae3//////////AAAAAAAAAAFKYEGnAAAAQI7tUQkz1Dedybs2Y9fYkjeZMkPxYJyQ21NNYmdl4rV3nI+pu3ymAiPtqrLWk21sXWSh8//1rx4sXH0aG+faQQ0=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAGAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAAAMAAAABAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAATIxAAAAAAAA5BFB2+Hs81DQk/cAlJes5R0+3PUQaZ62NZJoKPsBWnsAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAAAMAAAAAAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAAlQL4OAAAAACAAAACAAAAAQAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAADAAAAAAAAAAA00XMuuy66wBCHUQUm/Ps29QYV03tK9zx11wTsSmBBpwAAAAJUC+JwAAAAAgAAAAQAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{ju1RCTPUN53JuzZj19iSN5kyQ/FgnJDbU01iZ2XitXecj6m7fKYCI+2qstaTbWxdZKHz//WvHixcfRob59pBDQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('b48686858ee595141fb7d5d9999d5d40b78cacc4e27092e48824c8a0ac01370e', 3, 7, 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', 8589934597, 100, 1, '2016-03-22 16:08:48.232508', '2016-03-22 16:08:48.232508', 12884930560, 'AAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAZAAAAAIAAAAFAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABMjIAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFae3//////////AAAAAAAAAAFKYEGnAAAAQKacYiD/dSVGNuCAcHUal15ITf0UzHebfNWNudVk5DPvnxFMOqXBkxAVOyVqqXKslFAtco/hI9WNB5yaf2i8eQU=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAGAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAAAMAAAABAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAATIyAAAAAAAA5BFB2+Hs81DQk/cAlJes5R0+3PUQaZ62NZJoKPsBWnsAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAAAMAAAAAAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAAlQL4OAAAAACAAAACAAAAAUAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAADAAAAAAAAAAA00XMuuy66wBCHUQUm/Ps29QYV03tK9zx11wTsSmBBpwAAAAJUC+IMAAAAAgAAAAUAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{ppxiIP91JUY24IBwdRqXXkhN/RTMd5t81Y251WTkM++fEUw6pcGTEBU7JWqpcqyUUC1yj+Ej1Y0HnJp/aLx5BQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('e6315711266014d425b16b339bba063ad1b8d8823b5dfb8cd3399644754be459', 3, 8, 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', 8589934598, 100, 1, '2016-03-22 16:08:48.245401', '2016-03-22 16:08:48.245401', 12884934656, 'AAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAZAAAAAIAAAAGAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABMzEAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFae3//////////AAAAAAAAAAFKYEGnAAAAQI84TOk9J4ISBmnHAPy5KLkGnho/BjBWrZuYFB9I/6Z6QI9B25/mQw0EUOxBoX6X9q74a48TpIrf6n9LgonC8ws=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAGAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAAAMAAAABAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAATMxAAAAAAAA5BFB2+Hs81DQk/cAlJes5R0+3PUQaZ62NZJoKPsBWnsAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAAAMAAAAAAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAAlQL4OAAAAACAAAACAAAAAYAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAADAAAAAAAAAAA00XMuuy66wBCHUQUm/Ps29QYV03tK9zx11wTsSmBBpwAAAAJUC+GoAAAAAgAAAAYAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{jzhM6T0nghIGaccA/LkouQaeGj8GMFatm5gUH0j/pnpAj0Hbn+ZDDQRQ7EGhfpf2rvhrjxOkit/qf0uCicLzCw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('344a58add4f45245924cef37386866e0fd10f38f797615551c59fc0b5521e517', 3, 9, 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', 8589934599, 100, 1, '2016-03-22 16:08:48.261839', '2016-03-22 16:08:48.261839', 12884938752, 'AAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAZAAAAAIAAAAHAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABMzIAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFae3//////////AAAAAAAAAAFKYEGnAAAAQIYa/VDKchzI2ce0Hi7EZejOglDpZLsh3oLRGRkitrOM6zm9hJSZEfPZGPY/9+b14+fNnAyiHXGuVJK2ybiTJgU=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAGAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAAAMAAAABAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAATMyAAAAAAAA5BFB2+Hs81DQk/cAlJes5R0+3PUQaZ62NZJoKPsBWnsAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAAAMAAAAAAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAAlQL4OAAAAACAAAACAAAAAcAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAADAAAAAAAAAAA00XMuuy66wBCHUQUm/Ps29QYV03tK9zx11wTsSmBBpwAAAAJUC+FEAAAAAgAAAAcAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{hhr9UMpyHMjZx7QeLsRl6M6CUOlkuyHegtEZGSK2s4zrOb2ElJkR89kY9j/35vXj582cDKIdca5UkrbJuJMmBQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('254f4bd646c27c730501f50bf5c9543b3510c10f8b39152b74a75cd78ec5aa7a', 3, 10, 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', 8589934600, 100, 1, '2016-03-22 16:08:48.275948', '2016-03-22 16:08:48.275948', 12884942848, 'AAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAZAAAAAIAAAAIAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABMzMAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFae3//////////AAAAAAAAAAFKYEGnAAAAQKAZjNrWsdz1Pve6US/r4vC01x+rDl62xDI2NxieKesGxMS+yIs4Rn39O6iWlApGqGJ5LlC7QRidIVWIaF8V6gA=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAGAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAAAMAAAABAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAATMzAAAAAAAA5BFB2+Hs81DQk/cAlJes5R0+3PUQaZ62NZJoKPsBWnsAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAAAMAAAAAAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAAlQL4OAAAAACAAAACAAAAAgAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAADAAAAAAAAAAA00XMuuy66wBCHUQUm/Ps29QYV03tK9zx11wTsSmBBpwAAAAJUC+DgAAAAAgAAAAgAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{oBmM2tax3PU+97pRL+vi8LTXH6sOXrbEMjY3GJ4p6wbExL7IizhGff07qJaUCkaoYnkuULtBGJ0hVYhoXxXqAA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('a3fc459ac9baa9c327254ae6eb182fb60dd597ac3761159393de1564f59efa77', 4, 1, 'GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN', 8589934593, 100, 1, '2016-03-22 16:08:48.302104', '2016-03-22 16:08:48.302104', 17179873280, 'AAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAZAAAAAIAAAABAAAAAAAAAAAAAAABAAAAAAAAAAEAAAAAIyKlt0oO71F0CrYw4VWSMk/IX9S6PARHp8al61S6qj8AAAABVVNEAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAukO3QAAAAAAAAAAAH7AVp7AAAAQB0rZ3swcCS/5dUtKqTdrBYxUjI6b9C0K9bdynGsnTMDO4wLsV8IOjO+ZrSBXt9FUQHlTKgHRE5ydrNL2f4eRQM=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAwAAAAMAAAABAAAAACMipbdKDu9RdAq2MOFVkjJPyF/UujwER6fGpetUuqo/AAAAAVVTRAAAAAAA5BFB2+Hs81DQk/cAlJes5R0+3PUQaZ62NZJoKPsBWnsAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAAAQAAAABAAAAACMipbdKDu9RdAq2MOFVkjJPyF/UujwER6fGpetUuqo/AAAAAVVTRAAAAAAA5BFB2+Hs81DQk/cAlJes5R0+3PUQaZ62NZJoKPsBWnsAAAALpDt0AH//////////AAAAAQAAAAAAAAAA', 'AAAAAgAAAAMAAAACAAAAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAJUC+QAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAEAAAAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAJUC+OcAAAAAgAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{HStnezBwJL/l1S0qpN2sFjFSMjpv0LQr1t3KcaydMwM7jAuxXwg6M75mtIFe30VRAeVMqAdETnJ2s0vZ/h5FAw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('9dc1746a8a1fae0abf8756d189c3d421bb5b5a0d5c0f8a3834da6d6aae8311c7', 4, 2, 'GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN', 8589934594, 100, 1, '2016-03-22 16:08:48.325741', '2016-03-22 16:08:48.325741', 17179877376, 'AAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAZAAAAAIAAAACAAAAAAAAAAAAAAABAAAAAAAAAAEAAAAANNFzLrsuusAQh1EFJvz7NvUGFdN7Svc8ddcE7EpgQacAAAABRVVSAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAukO3QAAAAAAAAAAAH7AVp7AAAAQC5RCYrBzLMJMo9N+MYClr/hpgXNaLNAOBtG59qk+qyavtT5Euhsa+X+ukdhYkJrWJ+Hh4ngX/1WO1SpE8q/Bws=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAwAAAAMAAAABAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAAUVVUgAAAAAA5BFB2+Hs81DQk/cAlJes5R0+3PUQaZ62NZJoKPsBWnsAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAAAQAAAABAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAAUVVUgAAAAAA5BFB2+Hs81DQk/cAlJes5R0+3PUQaZ62NZJoKPsBWnsAAAALpDt0AH//////////AAAAAQAAAAAAAAAA', 'AAAAAQAAAAEAAAAEAAAAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAJUC+M4AAAAAgAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{LlEJisHMswkyj034xgKWv+GmBc1os0A4G0bn2qT6rJq+1PkS6Gxr5f66R2FiQmtYn4eHieBf/VY7VKkTyr8HCw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('335970f27c1141c865b9a77189ffe71591d13c49c8d62d57239228562bc43cf2', 4, 3, 'GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN', 8589934595, 100, 1, '2016-03-22 16:08:48.342986', '2016-03-22 16:08:48.342986', 17179881472, 'AAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAZAAAAAIAAAADAAAAAAAAAAAAAAABAAAAAAAAAAEAAAAANNFzLrsuusAQh1EFJvz7NvUGFdN7Svc8ddcE7EpgQacAAAABMQAAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAukO3QAAAAAAAAAAAH7AVp7AAAAQJwPDiB+yuKFlFstdLMotpJlApsm34y8aJSlr1PjJEUi6fz6FucRMktKYHhJMINqUGzzm0qEwHesc6Uo1wwRygc=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAwAAAAMAAAABAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAATEAAAAAAAAA5BFB2+Hs81DQk/cAlJes5R0+3PUQaZ62NZJoKPsBWnsAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAAAQAAAABAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAATEAAAAAAAAA5BFB2+Hs81DQk/cAlJes5R0+3PUQaZ62NZJoKPsBWnsAAAALpDt0AH//////////AAAAAQAAAAAAAAAA', 'AAAAAQAAAAEAAAAEAAAAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAJUC+LUAAAAAgAAAAMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{nA8OIH7K4oWUWy10syi2kmUCmybfjLxolKWvU+MkRSLp/PoW5xEyS0pgeEkwg2pQbPObSoTAd6xzpSjXDBHKBw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('63fd31091c6a3333a8ee23297c255e1d899a275519c48defd3ce0708a904c12b', 4, 4, 'GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN', 8589934596, 100, 1, '2016-03-22 16:08:48.359911', '2016-03-22 16:08:48.359911', 17179885568, 'AAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAZAAAAAIAAAAEAAAAAAAAAAAAAAABAAAAAAAAAAEAAAAANNFzLrsuusAQh1EFJvz7NvUGFdN7Svc8ddcE7EpgQacAAAABMjEAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAukO3QAAAAAAAAAAAH7AVp7AAAAQBqkEspJ7xLLBgXnC77mo+US4DBjZsB89rAXQO3zmcyH5qEc4nf/D4DMS8R1nHf8c8staaUV3/S1dpr8AR93CQA=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAwAAAAMAAAABAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAATIxAAAAAAAA5BFB2+Hs81DQk/cAlJes5R0+3PUQaZ62NZJoKPsBWnsAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAAAQAAAABAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAATIxAAAAAAAA5BFB2+Hs81DQk/cAlJes5R0+3PUQaZ62NZJoKPsBWnsAAAALpDt0AH//////////AAAAAQAAAAAAAAAA', 'AAAAAQAAAAEAAAAEAAAAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAJUC+JwAAAAAgAAAAQAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{GqQSyknvEssGBecLvuaj5RLgMGNmwHz2sBdA7fOZzIfmoRzid/8PgMxLxHWcd/xzyy1ppRXf9LV2mvwBH3cJAA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('9b28e1c8e857b0efd958c70c36d777f36e053d4f0d2073d3276c18cfc85f9249', 4, 5, 'GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN', 8589934597, 100, 1, '2016-03-22 16:08:48.377069', '2016-03-22 16:08:48.377069', 17179889664, 'AAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAZAAAAAIAAAAFAAAAAAAAAAAAAAABAAAAAAAAAAEAAAAANNFzLrsuusAQh1EFJvz7NvUGFdN7Svc8ddcE7EpgQacAAAABMjIAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAukO3QAAAAAAAAAAAH7AVp7AAAAQPtRQAtUfiEmaZWw4ux/nbuh8y8NoG8mBwPEyFcqXHD2+/LrQ5TA6OUcovIB48cu5wlE8S23KIfYK4nE1clR+gw=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAwAAAAMAAAABAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAATIyAAAAAAAA5BFB2+Hs81DQk/cAlJes5R0+3PUQaZ62NZJoKPsBWnsAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAAAQAAAABAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAATIyAAAAAAAA5BFB2+Hs81DQk/cAlJes5R0+3PUQaZ62NZJoKPsBWnsAAAALpDt0AH//////////AAAAAQAAAAAAAAAA', 'AAAAAQAAAAEAAAAEAAAAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAJUC+IMAAAAAgAAAAUAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{+1FAC1R+ISZplbDi7H+du6HzLw2gbyYHA8TIVypccPb78utDlMDo5Ryi8gHjxy7nCUTxLbcoh9gricTVyVH6DA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('8208aa13fc4d71b7ae079072b3a3af1bfd8806ba6fd354d3fcbd127b7c0fe232', 4, 6, 'GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN', 8589934598, 100, 1, '2016-03-22 16:08:48.394234', '2016-03-22 16:08:48.394234', 17179893760, 'AAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAZAAAAAIAAAAGAAAAAAAAAAAAAAABAAAAAAAAAAEAAAAANNFzLrsuusAQh1EFJvz7NvUGFdN7Svc8ddcE7EpgQacAAAABMzEAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAukO3QAAAAAAAAAAAH7AVp7AAAAQMzLClp/m92NuPEoN1e7F87rGGHpCoXCIrw8t9cd8tC3ukKYQViHyj2F/X0Mu83o/ooo5cXpxLyn9IbZZXt+CgU=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAwAAAAMAAAABAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAATMxAAAAAAAA5BFB2+Hs81DQk/cAlJes5R0+3PUQaZ62NZJoKPsBWnsAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAAAQAAAABAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAATMxAAAAAAAA5BFB2+Hs81DQk/cAlJes5R0+3PUQaZ62NZJoKPsBWnsAAAALpDt0AH//////////AAAAAQAAAAAAAAAA', 'AAAAAQAAAAEAAAAEAAAAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAJUC+GoAAAAAgAAAAYAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{zMsKWn+b3Y248Sg3V7sXzusYYekKhcIivDy31x3y0Le6QphBWIfKPYX9fQy7zej+iijlxenEvKf0htlle34KBQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('7c663b4fe86794c57b4f3d718b5048be1aa1e084e52f3468dd470829a057cfeb', 4, 7, 'GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN', 8589934599, 100, 1, '2016-03-22 16:08:48.411848', '2016-03-22 16:08:48.411848', 17179897856, 'AAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAZAAAAAIAAAAHAAAAAAAAAAAAAAABAAAAAAAAAAEAAAAANNFzLrsuusAQh1EFJvz7NvUGFdN7Svc8ddcE7EpgQacAAAABMzIAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAukO3QAAAAAAAAAAAH7AVp7AAAAQPYL/L7JhjheV0aToVoB98Iuwa4Z3rcSsuf4zY0ndS8v2fy1mDzGOuS4n0Fwdcdhzy77qOdmFV3kSsR75YqLawY=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAwAAAAMAAAABAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAATMyAAAAAAAA5BFB2+Hs81DQk/cAlJes5R0+3PUQaZ62NZJoKPsBWnsAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAAAQAAAABAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAATMyAAAAAAAA5BFB2+Hs81DQk/cAlJes5R0+3PUQaZ62NZJoKPsBWnsAAAALpDt0AH//////////AAAAAQAAAAAAAAAA', 'AAAAAQAAAAEAAAAEAAAAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAJUC+FEAAAAAgAAAAcAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{9gv8vsmGOF5XRpOhWgH3wi7BrhnetxKy5/jNjSd1Ly/Z/LWYPMY65LifQXB1x2HPLvuo52YVXeRKxHvliotrBg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('57d54e294ca2d6206226a8950976bbec3852a05f977c895b68510e329ed1cf9b', 4, 8, 'GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN', 8589934600, 100, 1, '2016-03-22 16:08:48.42908', '2016-03-22 16:08:48.42908', 17179901952, 'AAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAZAAAAAIAAAAIAAAAAAAAAAAAAAABAAAAAAAAAAEAAAAANNFzLrsuusAQh1EFJvz7NvUGFdN7Svc8ddcE7EpgQacAAAABMzMAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAukO3QAAAAAAAAAAAH7AVp7AAAAQDZLOY+f8aVbrWmcdsUz5KDWGikLBfYEESNyeF/4BlFppWpejMrS36byCy2yScN9zEhx5dZgVumSfp/bthUYbwM=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAwAAAAMAAAABAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAATMzAAAAAAAA5BFB2+Hs81DQk/cAlJes5R0+3PUQaZ62NZJoKPsBWnsAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAAAQAAAABAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAATMzAAAAAAAA5BFB2+Hs81DQk/cAlJes5R0+3PUQaZ62NZJoKPsBWnsAAAALpDt0AH//////////AAAAAQAAAAAAAAAA', 'AAAAAQAAAAEAAAAEAAAAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAJUC+DgAAAAAgAAAAgAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{Nks5j5/xpVutaZx2xTPkoNYaKQsF9gQRI3J4X/gGUWmlal6MytLfpvILLbJJw33MSHHl1mBW6ZJ+n9u2FRhvAw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('a11c4e1aada500470b2f9519a3797f6cfb70f8a776869fbf4b4b516b4d2e8133', 5, 1, 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', 8589934601, 100, 1, '2016-03-22 16:08:48.457258', '2016-03-22 16:08:48.457258', 21474840576, 'AAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAZAAAAAIAAAAJAAAAAAAAAAAAAAABAAAAAAAAAAMAAAABRVVSAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAFVU0QAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAAAX14QAAAAABAAAAAgAAAAAAAAAAAAAAAAAAAAFKYEGnAAAAQHYMSNjb0f+r4Z0pfzyekxkzkV3nav7I9MIPXyPdlnPT0KM5l7Rp0aFsqFXJPACzggMqTJrWxY5k+HP6eCrG+Ag=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAAAAAAAEAAAABRVVSAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAFVU0QAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAAAX14QAAAAABAAAAAgAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAAAAAAAEAAAABRVVSAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAFVU0QAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAAAX14QAAAAABAAAAAgAAAAAAAAAAAAAAAAAAAAEAAAAFAAAAAAAAAAA00XMuuy66wBCHUQUm/Ps29QYV03tK9zx11wTsSmBBpwAAAAJUC9z4AAAAAgAAABIAAAAJAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', 'AAAAAgAAAAMAAAADAAAAAAAAAAA00XMuuy66wBCHUQUm/Ps29QYV03tK9zx11wTsSmBBpwAAAAJUC+DgAAAAAgAAAAgAAAAIAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAFAAAAAAAAAAA00XMuuy66wBCHUQUm/Ps29QYV03tK9zx11wTsSmBBpwAAAAJUC+B8AAAAAgAAAAkAAAAIAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{dgxI2NvR/6vhnSl/PJ6TGTORXedq/sj0wg9fI92Wc9PQozmXtGnRoWyoVck8ALOCAypMmtbFjmT4c/p4Ksb4CA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('b5e88105a360ca97acb39a2636f7cf5cdf7a901acd0d4be9c8091ba227e0452c', 5, 2, 'GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN', 8589934601, 100, 1, '2016-03-22 16:08:48.46722', '2016-03-22 16:08:48.46722', 21474844672, 'AAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAZAAAAAIAAAAJAAAAAAAAAAAAAAABAAAAAAAAAAMAAAABRVVSAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAFVU0QAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAAAX14QAAAAABAAAAAQAAAAAAAAAAAAAAAAAAAAH7AVp7AAAAQKYsEVsOUuHcbex7veV09JgjxkZyqr2FcMzTYGPS+DFi3FhbhKgQJQnhi+dGRrcbOexMx5umUBXRodtHpPVsNgE=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAAAAAAAIAAAABRVVSAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAFVU0QAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAAAX14QAAAAABAAAAAQAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAAAAAAAIAAAABRVVSAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAFVU0QAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAAAX14QAAAAABAAAAAQAAAAAAAAAAAAAAAAAAAAEAAAAFAAAAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAJUC9+0AAAAAgAAAAsAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', 'AAAAAgAAAAMAAAAEAAAAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAJUC+DgAAAAAgAAAAgAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAFAAAAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAJUC+B8AAAAAgAAAAkAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{piwRWw5S4dxt7Hu95XT0mCPGRnKqvYVwzNNgY9L4MWLcWFuEqBAlCeGL50ZGtxs57EzHm6ZQFdGh20ek9Ww2AQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('4781659c29cabdfdc55dd8d007ddd1540f6fb45f3b4ce648e45c32257e47c4a6', 5, 3, 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', 8589934602, 100, 1, '2016-03-22 16:08:48.477169', '2016-03-22 16:08:48.477169', 21474848768, 'AAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAZAAAAAIAAAAKAAAAAAAAAAAAAAABAAAAAAAAAAMAAAABMQAAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAFVU0QAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAAAvrwgAAAAABAAAAAQAAAAAAAAAAAAAAAAAAAAFKYEGnAAAAQJ0o6N2Jk5+i0bkILbE3UTiUpyZvOJLNvARX5gYko0KCuad0n456Jm9Cqxr7seluIFSoNbxCJOrC54kyaTuO1Ak=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAAAAAAAMAAAABMQAAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAFVU0QAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAAAvrwgAAAAABAAAAAQAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAAAAAAAMAAAABMQAAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAFVU0QAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAAAvrwgAAAAABAAAAAQAAAAAAAAAAAAAAAAAAAAEAAAAFAAAAAAAAAAA00XMuuy66wBCHUQUm/Ps29QYV03tK9zx11wTsSmBBpwAAAAJUC9z4AAAAAgAAABIAAAAKAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', 'AAAAAQAAAAEAAAAFAAAAAAAAAAA00XMuuy66wBCHUQUm/Ps29QYV03tK9zx11wTsSmBBpwAAAAJUC+AYAAAAAgAAAAoAAAAIAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{nSjo3YmTn6LRuQgtsTdROJSnJm84ks28BFfmBiSjQoK5p3Sfjnomb0KrGvux6W4gVKg1vEIk6sLniTJpO47UCQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('fac63542d996fcba0e6bcb723ca94b5a3b415b36e4eeac64c881dfd61d478fe7', 5, 4, 'GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN', 8589934602, 100, 1, '2016-03-22 16:08:48.486726', '2016-03-22 16:08:48.486726', 21474852864, 'AAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAZAAAAAIAAAAKAAAAAAAAAAAAAAABAAAAAAAAAAMAAAABRVVSAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAFVU0QAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAAAX14QAAAAABAAAAAgAAAAAAAAAAAAAAAAAAAAH7AVp7AAAAQDcsuEiZkPgFoOKVqaXf7q1n198y1BZNFYjn1vVH5bxadN9DKREt/ULptZ/3gDYD/fiw5VJIiJzGy+r8ZWYeDg4=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAAAAAAAQAAAABRVVSAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAFVU0QAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAAAX14QAAAAABAAAAAgAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAAAAAAAQAAAABRVVSAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAFVU0QAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAAAX14QAAAAABAAAAAgAAAAAAAAAAAAAAAAAAAAEAAAAFAAAAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAJUC9+0AAAAAgAAAAsAAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', 'AAAAAQAAAAEAAAAFAAAAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAJUC+AYAAAAAgAAAAoAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{Nyy4SJmQ+AWg4pWppd/urWfX3zLUFk0ViOfW9UflvFp030MpES39Qum1n/eANgP9+LDlUkiInMbL6vxlZh4ODg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('8915d7a8cc6be26c19195a736b535d5d7bba506f267267449787240bae9c1c80', 5, 5, 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', 8589934603, 100, 1, '2016-03-22 16:08:48.495982', '2016-03-22 16:08:48.495982', 21474856960, 'AAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAZAAAAAIAAAALAAAAAAAAAAAAAAABAAAAAAAAAAMAAAABRVVSAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAExAAAAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAAAvrwgAAAAABAAAAAQAAAAAAAAAAAAAAAAAAAAFKYEGnAAAAQNFl2eV/OTWdcSDTd/MytqUjZaSAXFEX1cRK1Ba5PUrHlxO4WdopI8D0KjJo195Xy85Dqx+iTCEM0Xr0/lGM6Qs=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAAAAAAAUAAAABRVVSAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAExAAAAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAAAvrwgAAAAABAAAAAQAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAAAAAAAUAAAABRVVSAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAExAAAAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAAAvrwgAAAAABAAAAAQAAAAAAAAAAAAAAAAAAAAEAAAAFAAAAAAAAAAA00XMuuy66wBCHUQUm/Ps29QYV03tK9zx11wTsSmBBpwAAAAJUC9z4AAAAAgAAABIAAAALAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', 'AAAAAQAAAAEAAAAFAAAAAAAAAAA00XMuuy66wBCHUQUm/Ps29QYV03tK9zx11wTsSmBBpwAAAAJUC9+0AAAAAgAAAAsAAAAIAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{0WXZ5X85NZ1xINN38zK2pSNlpIBcURfVxErUFrk9SseXE7hZ2ikjwPQqMmjX3lfLzkOrH6JMIQzRevT+UYzpCw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('0e12e13702a9573c885291f36b36561c288d8fc4d2f92dcf484132b6c8d408bf', 5, 6, 'GDSBCQO34HWPGUGQSP3QBFEXVTSR2PW46UIGTHVWGWJGQKH3AFNHXHXN', 8589934603, 100, 1, '2016-03-22 16:08:48.505761', '2016-03-22 16:08:48.505761', 21474861056, 'AAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAZAAAAAIAAAALAAAAAAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAA5BFB2+Hs81DQk/cAlJes5R0+3PUQaZ62NZJoKPsBWnsAAAACVAvkAAAAAAEAAAAKAAAAAAAAAAAAAAAAAAAAAfsBWnsAAABAcbF71a/Gjo9HpuNHsBpUkWKsdKnRvR737FyZoPnCBlCKHfCyvt/Ykg3PG1SStsWIpb9zUB/XZFjvgwi7F6zwBw==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAAAAAAAYAAAAAAAAAAVVTRAAAAAAA5BFB2+Hs81DQk/cAlJes5R0+3PUQaZ62NZJoKPsBWnsAAAACPDRbtAAAAAEAAAAKAAAAAAAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAAAAAAAYAAAAAAAAAAVVTRAAAAAAA5BFB2+Hs81DQk/cAlJes5R0+3PUQaZ62NZJoKPsBWnsAAAACPDRbtAAAAAEAAAAKAAAAAAAAAAAAAAAAAAAAAQAAAAUAAAAAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAAlQL37QAAAACAAAACwAAAAMAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAFAAAAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAJUC9+0AAAAAgAAAAsAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{cbF71a/Gjo9HpuNHsBpUkWKsdKnRvR737FyZoPnCBlCKHfCyvt/Ykg3PG1SStsWIpb9zUB/XZFjvgwi7F6zwBw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('b9925fafee10dce3211337718217a7a0691ca60d9f67c56d9a3ec823acd0c95e', 5, 7, 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', 8589934604, 100, 1, '2016-03-22 16:08:48.515189', '2016-03-22 16:08:48.515189', 21474865152, 'AAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAZAAAAAIAAAAMAAAAAAAAAAAAAAABAAAAAAAAAAMAAAABMjEAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAFVU0QAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAABHhowAAAAABAAAAAQAAAAAAAAAAAAAAAAAAAAFKYEGnAAAAQDT4gS9N8FQ4cyYjoOqFMhn3iEqPrUO8fcc0XAUbfuBYucNKYmSt57nBfRtOzIUChOlKitxV1+0lDYp38fPv5Aw=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAAAAAAAcAAAABMjEAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAFVU0QAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAABHhowAAAAABAAAAAQAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAAAAAAAcAAAABMjEAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAFVU0QAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAABHhowAAAAABAAAAAQAAAAAAAAAAAAAAAAAAAAEAAAAFAAAAAAAAAAA00XMuuy66wBCHUQUm/Ps29QYV03tK9zx11wTsSmBBpwAAAAJUC9z4AAAAAgAAABIAAAAMAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', 'AAAAAQAAAAEAAAAFAAAAAAAAAAA00XMuuy66wBCHUQUm/Ps29QYV03tK9zx11wTsSmBBpwAAAAJUC99QAAAAAgAAAAwAAAAIAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{NPiBL03wVDhzJiOg6oUyGfeISo+tQ7x9xzRcBRt+4Fi5w0piZK3nucF9G07MhQKE6UqK3FXX7SUNinfx8+/kDA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('a89dc0b7e9e01af735994cb66cf775bfd37fb0e61225254294c00627f2cfe91a', 5, 8, 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', 8589934605, 100, 1, '2016-03-22 16:08:48.524458', '2016-03-22 16:08:48.524458', 21474869248, 'AAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAZAAAAAIAAAANAAAAAAAAAAAAAAABAAAAAAAAAAMAAAABMjIAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAEyMQAAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAABHhowAAAAABAAAAAQAAAAAAAAAAAAAAAAAAAAFKYEGnAAAAQMDEDKXp605d/im9Ptwenn13YSUaKKjat7MDBnNKxHnQ5OFY1L9yszv4qo7Ax4Nqd+B9YfvKxzGw4jQGQ9UdOgg=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAAAAAAAgAAAABMjIAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAEyMQAAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAABHhowAAAAABAAAAAQAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAAAAAAAgAAAABMjIAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAEyMQAAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAABHhowAAAAABAAAAAQAAAAAAAAAAAAAAAAAAAAEAAAAFAAAAAAAAAAA00XMuuy66wBCHUQUm/Ps29QYV03tK9zx11wTsSmBBpwAAAAJUC9z4AAAAAgAAABIAAAANAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', 'AAAAAQAAAAEAAAAFAAAAAAAAAAA00XMuuy66wBCHUQUm/Ps29QYV03tK9zx11wTsSmBBpwAAAAJUC97sAAAAAgAAAA0AAAAIAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{wMQMpenrTl3+Kb0+3B6efXdhJRooqNq3swMGc0rEedDk4VjUv3KzO/iqjsDHg2p34H1h+8rHMbDiNAZD1R06CA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('c92bb5f0ce6cbf74949af7b6404e0aae1839dcb174ca07b86b0690386b488e30', 5, 9, 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', 8589934606, 100, 1, '2016-03-22 16:08:48.533834', '2016-03-22 16:08:48.533834', 21474873344, 'AAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAZAAAAAIAAAAOAAAAAAAAAAAAAAABAAAAAAAAAAMAAAABRVVSAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAEyMgAAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAABHhowAAAAABAAAAAQAAAAAAAAAAAAAAAAAAAAFKYEGnAAAAQOn18OTylqpbRyiXNURKYg5fc1rW4P7OfdyzIhzEP6eD0gS+Se4UQMOw0zsvfC3dfS366KHEWRXB8qQLqQ7lLAs=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAAAAAAAkAAAABRVVSAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAEyMgAAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAABHhowAAAAABAAAAAQAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAAAAAAAkAAAABRVVSAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAEyMgAAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAABHhowAAAAABAAAAAQAAAAAAAAAAAAAAAAAAAAEAAAAFAAAAAAAAAAA00XMuuy66wBCHUQUm/Ps29QYV03tK9zx11wTsSmBBpwAAAAJUC9z4AAAAAgAAABIAAAAOAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', 'AAAAAQAAAAEAAAAFAAAAAAAAAAA00XMuuy66wBCHUQUm/Ps29QYV03tK9zx11wTsSmBBpwAAAAJUC96IAAAAAgAAAA4AAAAIAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{6fXw5PKWqltHKJc1REpiDl9zWtbg/s593LMiHMQ/p4PSBL5J7hRAw7DTOy98Ld19LfroocRZFcHypAupDuUsCw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('8af50985527a5383992cef73235c1f9a650aa613984936afd47b72bf0b23d07a', 5, 10, 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', 8589934607, 100, 1, '2016-03-22 16:08:48.543335', '2016-03-22 16:08:48.543335', 21474877440, 'AAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAZAAAAAIAAAAPAAAAAAAAAAAAAAABAAAAAAAAAAMAAAABMzEAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAFVU0QAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAABfXhAAAAAACAAAAAQAAAAAAAAAAAAAAAAAAAAFKYEGnAAAAQGOBpoZRIru8JJjmktVn8mJoQDVulo6EgqS8X71h1EvU+AS8SOvUBZWAzx+eQPom6Hagxc2R9HQgAIR96KYz/A4=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAAAAAAAoAAAABMzEAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAFVU0QAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAABfXhAAAAAACAAAAAQAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAAAAAAAoAAAABMzEAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAFVU0QAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAABfXhAAAAAACAAAAAQAAAAAAAAAAAAAAAAAAAAEAAAAFAAAAAAAAAAA00XMuuy66wBCHUQUm/Ps29QYV03tK9zx11wTsSmBBpwAAAAJUC9z4AAAAAgAAABIAAAAPAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', 'AAAAAQAAAAEAAAAFAAAAAAAAAAA00XMuuy66wBCHUQUm/Ps29QYV03tK9zx11wTsSmBBpwAAAAJUC94kAAAAAgAAAA8AAAAIAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{Y4GmhlEiu7wkmOaS1WfyYmhANW6WjoSCpLxfvWHUS9T4BLxI69QFlYDPH55A+ibodqDFzZH0dCAAhH3opjP8Dg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('487644504432e9323eace0dd116cbb3218f2801391a91b2646cb67d797897abf', 5, 11, 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', 8589934608, 100, 1, '2016-03-22 16:08:48.55282', '2016-03-22 16:08:48.55282', 21474881536, 'AAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAZAAAAAIAAAAQAAAAAAAAAAAAAAABAAAAAAAAAAMAAAABMzIAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAEzMQAAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAABfXhAAAAAACAAAAAQAAAAAAAAAAAAAAAAAAAAFKYEGnAAAAQNgcJcTXnPHUexPnq4VY23CVwk8zKucnao7p0LfZtQLhJr8PRvA/iWgToaaCPxb3WDFAC84vQ6dFxzJsXMdC/wc=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAAAAAAAsAAAABMzIAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAEzMQAAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAABfXhAAAAAACAAAAAQAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAAAAAAAsAAAABMzIAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAEzMQAAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAABfXhAAAAAACAAAAAQAAAAAAAAAAAAAAAAAAAAEAAAAFAAAAAAAAAAA00XMuuy66wBCHUQUm/Ps29QYV03tK9zx11wTsSmBBpwAAAAJUC9z4AAAAAgAAABIAAAAQAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', 'AAAAAQAAAAEAAAAFAAAAAAAAAAA00XMuuy66wBCHUQUm/Ps29QYV03tK9zx11wTsSmBBpwAAAAJUC93AAAAAAgAAABAAAAAIAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{2BwlxNec8dR7E+erhVjbcJXCTzMq5ydqjunQt9m1AuEmvw9G8D+JaBOhpoI/FvdYMUALzi9Dp0XHMmxcx0L/Bw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('a34de60105499cdc69a3020fc67fa40229cd2fba20efa64e7e3530e6dcb5a4f4', 5, 12, 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', 8589934609, 100, 1, '2016-03-22 16:08:48.562225', '2016-03-22 16:08:48.562225', 21474885632, 'AAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAZAAAAAIAAAARAAAAAAAAAAAAAAABAAAAAAAAAAMAAAABMzMAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAEzMgAAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAABfXhAAAAAACAAAAAQAAAAAAAAAAAAAAAAAAAAFKYEGnAAAAQK9w7ViDX2zIK5hOpddWTQUhso6ZmdVCf+M3ExrCAJrNzpVaHaHgYOnXaRjP9RrHxzm6u/9pb+UWWqRatwxHBwk=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAAAAAAAwAAAABMzMAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAEzMgAAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAABfXhAAAAAACAAAAAQAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAAAAAAAwAAAABMzMAAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAEzMgAAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAABfXhAAAAAACAAAAAQAAAAAAAAAAAAAAAAAAAAEAAAAFAAAAAAAAAAA00XMuuy66wBCHUQUm/Ps29QYV03tK9zx11wTsSmBBpwAAAAJUC9z4AAAAAgAAABIAAAARAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', 'AAAAAQAAAAEAAAAFAAAAAAAAAAA00XMuuy66wBCHUQUm/Ps29QYV03tK9zx11wTsSmBBpwAAAAJUC91cAAAAAgAAABEAAAAIAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{r3DtWINfbMgrmE6l11ZNBSGyjpmZ1UJ/4zcTGsIAms3OlVodoeBg6ddpGM/1GsfHObq7/2lv5RZapFq3DEcHCQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('94e908960415a58313962f8319cc695922cf0a45b56b3b6be9b81778134b9b81', 5, 13, 'GA2NC4ZOXMXLVQAQQ5IQKJX47M3PKBQV2N5UV5Z4OXLQJ3CKMBA2O2YL', 8589934610, 100, 1, '2016-03-22 16:08:48.57187', '2016-03-22 16:08:48.57187', 21474889728, 'AAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAZAAAAAIAAAASAAAAAAAAAAAAAAABAAAAAAAAAAMAAAABRVVSAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAEzMwAAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAABfXhAAAAAACAAAAAQAAAAAAAAAAAAAAAAAAAAFKYEGnAAAAQBPeMF0R7VBgHYBWwmRBc9sjGMe8HiotoY3HFgb/+gj+0xpAKL5prASTRqEWW39fYFM4xLyLBkvP1wtdHnapjQ4=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAAAAAAA0AAAABRVVSAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAEzMwAAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAABfXhAAAAAACAAAAAQAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAADTRcy67LrrAEIdRBSb8+zb1BhXTe0r3PHXXBOxKYEGnAAAAAAAAAA0AAAABRVVSAAAAAADkEUHb4ezzUNCT9wCUl6zlHT7c9RBpnrY1kmgo+wFaewAAAAEzMwAAAAAAAOQRQdvh7PNQ0JP3AJSXrOUdPtz1EGmetjWSaCj7AVp7AAAAABfXhAAAAAACAAAAAQAAAAAAAAAAAAAAAAAAAAEAAAAFAAAAAAAAAAA00XMuuy66wBCHUQUm/Ps29QYV03tK9zx11wTsSmBBpwAAAAJUC9z4AAAAAgAAABIAAAASAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', 'AAAAAQAAAAEAAAAFAAAAAAAAAAA00XMuuy66wBCHUQUm/Ps29QYV03tK9zx11wTsSmBBpwAAAAJUC9z4AAAAAgAAABIAAAAIAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{E94wXRHtUGAdgFbCZEFz2yMYx7weKi2hjccWBv/6CP7TGkAovmmsBJNGoRZbf19gUzjEvIsGS8/XC10edqmNDg==}', 'none', NULL, NULL);


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO schema_migrations VALUES ('20150310224849');
INSERT INTO schema_migrations VALUES ('20150313225945');
INSERT INTO schema_migrations VALUES ('20150313225955');
INSERT INTO schema_migrations VALUES ('20150501160031');
INSERT INTO schema_migrations VALUES ('20150508003829');
INSERT INTO schema_migrations VALUES ('20150508175821');
INSERT INTO schema_migrations VALUES ('20150508183542');
INSERT INTO schema_migrations VALUES ('20150508215546');
INSERT INTO schema_migrations VALUES ('20150609230237');
INSERT INTO schema_migrations VALUES ('20150629181921');
INSERT INTO schema_migrations VALUES ('20150825180131');
INSERT INTO schema_migrations VALUES ('20150825223417');
INSERT INTO schema_migrations VALUES ('20150902224148');
INSERT INTO schema_migrations VALUES ('20150929205440');
INSERT INTO schema_migrations VALUES ('20151006205250');
INSERT INTO schema_migrations VALUES ('20151011210811');
INSERT INTO schema_migrations VALUES ('20151020211921');
INSERT INTO schema_migrations VALUES ('20151020225251');
INSERT INTO schema_migrations VALUES ('20151020235257');


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
-- Name: hs_ledger_by_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX hs_ledger_by_id ON history_ledgers USING btree (id);


--
-- Name: hs_transaction_by_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX hs_transaction_by_id ON history_transactions USING btree (id);


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
-- Name: index_history_transactions_on_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_history_transactions_on_id ON history_transactions USING btree (id);


--
-- Name: trade_effects_by_order_book; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX trade_effects_by_order_book ON history_effects USING btree (((details ->> 'sold_asset_type'::text)), ((details ->> 'sold_asset_code'::text)), ((details ->> 'sold_asset_issuer'::text)), ((details ->> 'bought_asset_type'::text)), ((details ->> 'bought_asset_code'::text)), ((details ->> 'bought_asset_issuer'::text))) WHERE (type = 33);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

