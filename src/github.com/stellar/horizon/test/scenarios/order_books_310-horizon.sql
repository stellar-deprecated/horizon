--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.1
-- Dumped by pg_dump version 9.6.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

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
-- Name: gorp_migrations; Type: TABLE; Schema: public; Owner: -
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
-- Name: history_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE history_accounts (
    id bigint DEFAULT nextval('history_accounts_id_seq'::regclass) NOT NULL,
    address character varying(64)
);


--
-- Name: history_effects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE history_effects (
    history_account_id bigint NOT NULL,
    history_operation_id bigint NOT NULL,
    "order" integer NOT NULL,
    type integer NOT NULL,
    details jsonb
);


--
-- Name: history_ledgers; Type: TABLE; Schema: public; Owner: -
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
    max_tx_set_size integer NOT NULL,
    protocol_version integer DEFAULT 0 NOT NULL
);


--
-- Name: history_operation_participants; Type: TABLE; Schema: public; Owner: -
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
-- Name: history_operations; Type: TABLE; Schema: public; Owner: -
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
-- Name: history_transaction_participants; Type: TABLE; Schema: public; Owner: -
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
-- Name: history_transactions; Type: TABLE; Schema: public; Owner: -
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
-- Name: history_operation_participants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY history_operation_participants ALTER COLUMN id SET DEFAULT nextval('history_operation_participants_id_seq'::regclass);


--
-- Name: history_transaction_participants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY history_transaction_participants ALTER COLUMN id SET DEFAULT nextval('history_transaction_participants_id_seq'::regclass);


--
-- Data for Name: gorp_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO gorp_migrations VALUES ('1_initial_schema.sql', '2017-02-23 13:54:51.059578-06');
INSERT INTO gorp_migrations VALUES ('2_index_participants_by_toid.sql', '2017-02-23 13:54:51.06302-06');
INSERT INTO gorp_migrations VALUES ('3_use_sequence_in_history_accounts.sql', '2017-02-23 13:54:51.065467-06');
INSERT INTO gorp_migrations VALUES ('4_add_protocol_version.sql', '2017-02-23 13:54:51.072906-06');


--
-- Data for Name: history_accounts; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO history_accounts VALUES (1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_accounts VALUES (2, 'GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4');
INSERT INTO history_accounts VALUES (3, 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU');
INSERT INTO history_accounts VALUES (4, 'GBXGQJWVLWOYHFLVTKWV5FGHA3LNYY2JQKM7OAJAUEQFU6LPCSEFVXON');


--
-- Name: history_accounts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('history_accounts_id_seq', 4, true);


--
-- Data for Name: history_effects; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO history_effects VALUES (2, 8589938689, 1, 0, '{"starting_balance": "1000.0000000"}');
INSERT INTO history_effects VALUES (1, 8589938689, 2, 3, '{"amount": "1000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (2, 8589938689, 3, 10, '{"weight": 1, "public_key": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}');
INSERT INTO history_effects VALUES (3, 8589942785, 1, 0, '{"starting_balance": "6000.0000000"}');
INSERT INTO history_effects VALUES (1, 8589942785, 2, 3, '{"amount": "6000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (3, 8589942785, 3, 10, '{"weight": 1, "public_key": "GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU"}');
INSERT INTO history_effects VALUES (4, 8589946881, 1, 0, '{"starting_balance": "6000.0000000"}');
INSERT INTO history_effects VALUES (1, 8589946881, 2, 3, '{"amount": "6000.0000000", "asset_type": "native"}');
INSERT INTO history_effects VALUES (4, 8589946881, 3, 10, '{"weight": 1, "public_key": "GBXGQJWVLWOYHFLVTKWV5FGHA3LNYY2JQKM7OAJAUEQFU6LPCSEFVXON"}');
INSERT INTO history_effects VALUES (3, 12884905985, 1, 20, '{"limit": "922337203685.4775807", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}');
INSERT INTO history_effects VALUES (4, 12884910081, 1, 20, '{"limit": "922337203685.4775807", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}');
INSERT INTO history_effects VALUES (3, 12884914177, 1, 20, '{"limit": "922337203685.4775807", "asset_code": "BTC", "asset_type": "credit_alphanum4", "asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}');
INSERT INTO history_effects VALUES (4, 12884918273, 1, 20, '{"limit": "922337203685.4775807", "asset_code": "BTC", "asset_type": "credit_alphanum4", "asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}');
INSERT INTO history_effects VALUES (3, 17179873281, 1, 2, '{"amount": "5000.0000000", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}');
INSERT INTO history_effects VALUES (2, 17179873281, 2, 3, '{"amount": "5000.0000000", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}');
INSERT INTO history_effects VALUES (4, 17179877377, 1, 2, '{"amount": "5000.0000000", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}');
INSERT INTO history_effects VALUES (2, 17179877377, 2, 3, '{"amount": "5000.0000000", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}');
INSERT INTO history_effects VALUES (3, 17179881473, 1, 2, '{"amount": "5000.0000000", "asset_code": "BTC", "asset_type": "credit_alphanum4", "asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}');
INSERT INTO history_effects VALUES (2, 17179881473, 2, 3, '{"amount": "5000.0000000", "asset_code": "BTC", "asset_type": "credit_alphanum4", "asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}');
INSERT INTO history_effects VALUES (4, 17179885569, 1, 2, '{"amount": "5000.0000000", "asset_code": "BTC", "asset_type": "credit_alphanum4", "asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}');
INSERT INTO history_effects VALUES (2, 17179885569, 2, 3, '{"amount": "5000.0000000", "asset_code": "BTC", "asset_type": "credit_alphanum4", "asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}');


--
-- Data for Name: history_ledgers; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO history_ledgers VALUES (1, '63d98f536ee68d1b27b5b89f23af5311b7569a24faf1403ad0b52b633b07be99', NULL, 0, 0, '1970-01-01 00:00:00', '2017-02-23 19:56:17.544867', '2017-02-23 19:56:17.544867', 4294967296, 9, 1000000000000000000, 0, 100, 100000000, 100, 0);
INSERT INTO history_ledgers VALUES (2, '2d0b8509a7d180682a674a0afaa47c85efc0e2c1fb7a29050f8dc61e4bc5c740', '63d98f536ee68d1b27b5b89f23af5311b7569a24faf1403ad0b52b633b07be99', 3, 3, '2017-02-23 19:56:14', '2017-02-23 19:56:17.548861', '2017-02-23 19:56:17.548861', 8589934592, 9, 1000000000000000000, 300, 100, 100000000, 10000, 3);
INSERT INTO history_ledgers VALUES (3, '844cbf079a6e94f9557b67e8aa4f4dd628342727b90539a607035e878ac99226', '2d0b8509a7d180682a674a0afaa47c85efc0e2c1fb7a29050f8dc61e4bc5c740', 4, 4, '2017-02-23 19:56:15', '2017-02-23 19:56:17.569013', '2017-02-23 19:56:17.569013', 12884901888, 9, 1000000000000000000, 700, 100, 100000000, 10000, 3);
INSERT INTO history_ledgers VALUES (4, '10bcd3bd19f79d4a8ad5901565faca3e2630bb8c7a4b80c3ab0d4a1ac348bad2', '844cbf079a6e94f9557b67e8aa4f4dd628342727b90539a607035e878ac99226', 4, 4, '2017-02-23 19:56:16', '2017-02-23 19:56:17.581982', '2017-02-23 19:56:17.581982', 17179869184, 9, 1000000000000000000, 1100, 100, 100000000, 10000, 3);
INSERT INTO history_ledgers VALUES (5, 'a174b298337244ca311f351190e5cf63734ed4d9f3ba9bf1e3d48233a3e1ef4a', '10bcd3bd19f79d4a8ad5901565faca3e2630bb8c7a4b80c3ab0d4a1ac348bad2', 33, 33, '2017-02-23 19:56:17', '2017-02-23 19:56:17.602444', '2017-02-23 19:56:17.602444', 21474836480, 9, 1000000000000000000, 4400, 100, 100000000, 10000, 3);


--
-- Data for Name: history_operation_participants; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO history_operation_participants VALUES (1, 8589938689, 1);
INSERT INTO history_operation_participants VALUES (2, 8589938689, 2);
INSERT INTO history_operation_participants VALUES (3, 8589942785, 1);
INSERT INTO history_operation_participants VALUES (4, 8589942785, 3);
INSERT INTO history_operation_participants VALUES (5, 8589946881, 1);
INSERT INTO history_operation_participants VALUES (6, 8589946881, 4);
INSERT INTO history_operation_participants VALUES (7, 12884905985, 3);
INSERT INTO history_operation_participants VALUES (8, 12884910081, 4);
INSERT INTO history_operation_participants VALUES (9, 12884914177, 3);
INSERT INTO history_operation_participants VALUES (10, 12884918273, 4);
INSERT INTO history_operation_participants VALUES (11, 17179873281, 2);
INSERT INTO history_operation_participants VALUES (12, 17179873281, 3);
INSERT INTO history_operation_participants VALUES (13, 17179877377, 2);
INSERT INTO history_operation_participants VALUES (14, 17179877377, 4);
INSERT INTO history_operation_participants VALUES (15, 17179881473, 2);
INSERT INTO history_operation_participants VALUES (16, 17179881473, 3);
INSERT INTO history_operation_participants VALUES (17, 17179885569, 2);
INSERT INTO history_operation_participants VALUES (18, 17179885569, 4);
INSERT INTO history_operation_participants VALUES (19, 21474840577, 3);
INSERT INTO history_operation_participants VALUES (20, 21474844673, 3);
INSERT INTO history_operation_participants VALUES (21, 21474848769, 3);
INSERT INTO history_operation_participants VALUES (22, 21474852865, 3);
INSERT INTO history_operation_participants VALUES (23, 21474856961, 3);
INSERT INTO history_operation_participants VALUES (24, 21474861057, 3);
INSERT INTO history_operation_participants VALUES (25, 21474865153, 3);
INSERT INTO history_operation_participants VALUES (26, 21474869249, 3);
INSERT INTO history_operation_participants VALUES (27, 21474873345, 3);
INSERT INTO history_operation_participants VALUES (28, 21474877441, 3);
INSERT INTO history_operation_participants VALUES (29, 21474881537, 3);
INSERT INTO history_operation_participants VALUES (30, 21474885633, 3);
INSERT INTO history_operation_participants VALUES (31, 21474889729, 3);
INSERT INTO history_operation_participants VALUES (32, 21474893825, 3);
INSERT INTO history_operation_participants VALUES (33, 21474897921, 3);
INSERT INTO history_operation_participants VALUES (34, 21474902017, 3);
INSERT INTO history_operation_participants VALUES (35, 21474906113, 3);
INSERT INTO history_operation_participants VALUES (36, 21474910209, 3);
INSERT INTO history_operation_participants VALUES (37, 21474914305, 3);
INSERT INTO history_operation_participants VALUES (38, 21474918401, 3);
INSERT INTO history_operation_participants VALUES (39, 21474922497, 3);
INSERT INTO history_operation_participants VALUES (40, 21474926593, 3);
INSERT INTO history_operation_participants VALUES (41, 21474930689, 3);
INSERT INTO history_operation_participants VALUES (42, 21474934785, 3);
INSERT INTO history_operation_participants VALUES (43, 21474938881, 3);
INSERT INTO history_operation_participants VALUES (44, 21474942977, 3);
INSERT INTO history_operation_participants VALUES (45, 21474947073, 3);
INSERT INTO history_operation_participants VALUES (46, 21474951169, 3);
INSERT INTO history_operation_participants VALUES (47, 21474955265, 3);
INSERT INTO history_operation_participants VALUES (48, 21474959361, 3);
INSERT INTO history_operation_participants VALUES (49, 21474963457, 3);
INSERT INTO history_operation_participants VALUES (50, 21474967553, 3);
INSERT INTO history_operation_participants VALUES (51, 21474971649, 3);


--
-- Name: history_operation_participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('history_operation_participants_id_seq', 51, true);


--
-- Data for Name: history_operations; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO history_operations VALUES (8589938689, 8589938688, 1, 0, '{"funder": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "account": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4", "starting_balance": "1000.0000000"}', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_operations VALUES (8589942785, 8589942784, 1, 0, '{"funder": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "account": "GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU", "starting_balance": "6000.0000000"}', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_operations VALUES (8589946881, 8589946880, 1, 0, '{"funder": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "account": "GBXGQJWVLWOYHFLVTKWV5FGHA3LNYY2JQKM7OAJAUEQFU6LPCSEFVXON", "starting_balance": "6000.0000000"}', 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H');
INSERT INTO history_operations VALUES (12884905985, 12884905984, 1, 6, '{"limit": "922337203685.4775807", "trustee": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4", "trustor": "GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU');
INSERT INTO history_operations VALUES (12884910081, 12884910080, 1, 6, '{"limit": "922337203685.4775807", "trustee": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4", "trustor": "GBXGQJWVLWOYHFLVTKWV5FGHA3LNYY2JQKM7OAJAUEQFU6LPCSEFVXON", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GBXGQJWVLWOYHFLVTKWV5FGHA3LNYY2JQKM7OAJAUEQFU6LPCSEFVXON');
INSERT INTO history_operations VALUES (12884914177, 12884914176, 1, 6, '{"limit": "922337203685.4775807", "trustee": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4", "trustor": "GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU", "asset_code": "BTC", "asset_type": "credit_alphanum4", "asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU');
INSERT INTO history_operations VALUES (12884918273, 12884918272, 1, 6, '{"limit": "922337203685.4775807", "trustee": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4", "trustor": "GBXGQJWVLWOYHFLVTKWV5FGHA3LNYY2JQKM7OAJAUEQFU6LPCSEFVXON", "asset_code": "BTC", "asset_type": "credit_alphanum4", "asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GBXGQJWVLWOYHFLVTKWV5FGHA3LNYY2JQKM7OAJAUEQFU6LPCSEFVXON');
INSERT INTO history_operations VALUES (17179873281, 17179873280, 1, 1, '{"to": "GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU", "from": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4", "amount": "5000.0000000", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4');
INSERT INTO history_operations VALUES (17179877377, 17179877376, 1, 1, '{"to": "GBXGQJWVLWOYHFLVTKWV5FGHA3LNYY2JQKM7OAJAUEQFU6LPCSEFVXON", "from": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4", "amount": "5000.0000000", "asset_code": "USD", "asset_type": "credit_alphanum4", "asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4');
INSERT INTO history_operations VALUES (17179881473, 17179881472, 1, 1, '{"to": "GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU", "from": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4", "amount": "5000.0000000", "asset_code": "BTC", "asset_type": "credit_alphanum4", "asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4');
INSERT INTO history_operations VALUES (17179885569, 17179885568, 1, 1, '{"to": "GBXGQJWVLWOYHFLVTKWV5FGHA3LNYY2JQKM7OAJAUEQFU6LPCSEFVXON", "from": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4", "amount": "5000.0000000", "asset_code": "BTC", "asset_type": "credit_alphanum4", "asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4');
INSERT INTO history_operations VALUES (21474840577, 21474840576, 1, 3, '{"price": "0.1000000", "amount": "10000.0000000", "price_r": {"d": 10, "n": 1}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_type": "native", "buying_asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU');
INSERT INTO history_operations VALUES (21474844673, 21474844672, 1, 3, '{"price": "0.1111111", "amount": "9000.0000000", "price_r": {"d": 9, "n": 1}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_type": "native", "buying_asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU');
INSERT INTO history_operations VALUES (21474848769, 21474848768, 1, 3, '{"price": "0.1250000", "amount": "8000.0000000", "price_r": {"d": 8, "n": 1}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_type": "native", "buying_asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU');
INSERT INTO history_operations VALUES (21474852865, 21474852864, 1, 3, '{"price": "0.1428571", "amount": "7000.0000000", "price_r": {"d": 7, "n": 1}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_type": "native", "buying_asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU');
INSERT INTO history_operations VALUES (21474856961, 21474856960, 1, 3, '{"price": "0.1666667", "amount": "6000.0000000", "price_r": {"d": 6, "n": 1}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_type": "native", "buying_asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU');
INSERT INTO history_operations VALUES (21474861057, 21474861056, 1, 3, '{"price": "0.2000000", "amount": "5000.0000000", "price_r": {"d": 5, "n": 1}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_type": "native", "buying_asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU');
INSERT INTO history_operations VALUES (21474865153, 21474865152, 1, 3, '{"price": "0.2500000", "amount": "4000.0000000", "price_r": {"d": 4, "n": 1}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_type": "native", "buying_asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU');
INSERT INTO history_operations VALUES (21474869249, 21474869248, 1, 3, '{"price": "0.3333333", "amount": "3000.0000000", "price_r": {"d": 3, "n": 1}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_type": "native", "buying_asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU');
INSERT INTO history_operations VALUES (21474873345, 21474873344, 1, 3, '{"price": "0.5000000", "amount": "2000.0000000", "price_r": {"d": 2, "n": 1}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_type": "native", "buying_asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU');
INSERT INTO history_operations VALUES (21474877441, 21474877440, 1, 3, '{"price": "1.0000000", "amount": "1000.0000000", "price_r": {"d": 1, "n": 1}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_type": "native", "buying_asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU');
INSERT INTO history_operations VALUES (21474881537, 21474881536, 1, 3, '{"price": "10.0000000", "amount": "100.0000000", "price_r": {"d": 1, "n": 10}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_type": "native", "buying_asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU');
INSERT INTO history_operations VALUES (21474885633, 21474885632, 1, 3, '{"price": "0.0990099", "amount": "10100.0000000", "price_r": {"d": 101, "n": 10}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_type": "native", "buying_asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU');
INSERT INTO history_operations VALUES (21474889729, 21474889728, 1, 3, '{"price": "0.1098901", "amount": "9100.0000000", "price_r": {"d": 91, "n": 10}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_type": "native", "buying_asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU');
INSERT INTO history_operations VALUES (21474893825, 21474893824, 1, 3, '{"price": "0.1234568", "amount": "8100.0000000", "price_r": {"d": 81, "n": 10}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_type": "native", "buying_asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU');
INSERT INTO history_operations VALUES (21474897921, 21474897920, 1, 3, '{"price": "0.1408451", "amount": "7100.0000000", "price_r": {"d": 71, "n": 10}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_type": "native", "buying_asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU');
INSERT INTO history_operations VALUES (21474902017, 21474902016, 1, 3, '{"price": "0.1639344", "amount": "6100.0000000", "price_r": {"d": 61, "n": 10}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_type": "native", "buying_asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU');
INSERT INTO history_operations VALUES (21474906113, 21474906112, 1, 3, '{"price": "0.1960784", "amount": "5100.0000000", "price_r": {"d": 51, "n": 10}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_type": "native", "buying_asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU');
INSERT INTO history_operations VALUES (21474910209, 21474910208, 1, 3, '{"price": "0.2439024", "amount": "4100.0000000", "price_r": {"d": 41, "n": 10}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_type": "native", "buying_asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU');
INSERT INTO history_operations VALUES (21474914305, 21474914304, 1, 3, '{"price": "0.3225806", "amount": "3100.0000000", "price_r": {"d": 310000028, "n": 100000009}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_type": "native", "buying_asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU');
INSERT INTO history_operations VALUES (21474918401, 21474918400, 1, 3, '{"price": "0.4761905", "amount": "2100.0000000", "price_r": {"d": 21, "n": 10}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_type": "native", "buying_asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU');
INSERT INTO history_operations VALUES (21474922497, 21474922496, 1, 3, '{"price": "0.9090909", "amount": "1100.0000000", "price_r": {"d": 11, "n": 10}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_type": "native", "buying_asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU');
INSERT INTO history_operations VALUES (21474926593, 21474926592, 1, 3, '{"price": "5.0000000", "amount": "200.0000000", "price_r": {"d": 1, "n": 5}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_type": "native", "buying_asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU');
INSERT INTO history_operations VALUES (21474930689, 21474930688, 1, 3, '{"price": "0.0980392", "amount": "10200.0000000", "price_r": {"d": 51, "n": 5}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_type": "native", "buying_asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU');
INSERT INTO history_operations VALUES (21474934785, 21474934784, 1, 3, '{"price": "0.1086957", "amount": "9200.0000000", "price_r": {"d": 46, "n": 5}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_type": "native", "buying_asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU');
INSERT INTO history_operations VALUES (21474938881, 21474938880, 1, 3, '{"price": "0.1219512", "amount": "8200.0000000", "price_r": {"d": 41, "n": 5}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_type": "native", "buying_asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU');
INSERT INTO history_operations VALUES (21474942977, 21474942976, 1, 3, '{"price": "0.1388889", "amount": "7200.0000000", "price_r": {"d": 36, "n": 5}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_type": "native", "buying_asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU');
INSERT INTO history_operations VALUES (21474947073, 21474947072, 1, 3, '{"price": "0.1612903", "amount": "6200.0000000", "price_r": {"d": 31, "n": 5}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_type": "native", "buying_asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU');
INSERT INTO history_operations VALUES (21474951169, 21474951168, 1, 3, '{"price": "0.1923077", "amount": "5200.0000000", "price_r": {"d": 26, "n": 5}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_type": "native", "buying_asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU');
INSERT INTO history_operations VALUES (21474955265, 21474955264, 1, 3, '{"price": "0.2380952", "amount": "4200.0000000", "price_r": {"d": 21, "n": 5}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_type": "native", "buying_asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU');
INSERT INTO history_operations VALUES (21474959361, 21474959360, 1, 3, '{"price": "0.3125000", "amount": "3200.0000000", "price_r": {"d": 16, "n": 5}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_type": "native", "buying_asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU');
INSERT INTO history_operations VALUES (21474963457, 21474963456, 1, 3, '{"price": "0.4545455", "amount": "2200.0000000", "price_r": {"d": 11, "n": 5}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_type": "native", "buying_asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU');
INSERT INTO history_operations VALUES (21474967553, 21474967552, 1, 3, '{"price": "0.8333333", "amount": "1200.0000000", "price_r": {"d": 6, "n": 5}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_type": "native", "buying_asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU');
INSERT INTO history_operations VALUES (21474971649, 21474971648, 1, 3, '{"price": "3.3333333", "amount": "300.0000000", "price_r": {"d": 3, "n": 10}, "offer_id": 0, "buying_asset_code": "USD", "buying_asset_type": "credit_alphanum4", "selling_asset_type": "native", "buying_asset_issuer": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}', 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU');


--
-- Data for Name: history_transaction_participants; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO history_transaction_participants VALUES (1, 8589938688, 1);
INSERT INTO history_transaction_participants VALUES (2, 8589938688, 2);
INSERT INTO history_transaction_participants VALUES (3, 8589942784, 1);
INSERT INTO history_transaction_participants VALUES (4, 8589942784, 3);
INSERT INTO history_transaction_participants VALUES (5, 8589946880, 1);
INSERT INTO history_transaction_participants VALUES (6, 8589946880, 4);
INSERT INTO history_transaction_participants VALUES (7, 12884905984, 3);
INSERT INTO history_transaction_participants VALUES (8, 12884910080, 4);
INSERT INTO history_transaction_participants VALUES (9, 12884914176, 3);
INSERT INTO history_transaction_participants VALUES (10, 12884918272, 4);
INSERT INTO history_transaction_participants VALUES (11, 17179873280, 2);
INSERT INTO history_transaction_participants VALUES (12, 17179873280, 3);
INSERT INTO history_transaction_participants VALUES (13, 17179877376, 2);
INSERT INTO history_transaction_participants VALUES (14, 17179877376, 4);
INSERT INTO history_transaction_participants VALUES (15, 17179881472, 2);
INSERT INTO history_transaction_participants VALUES (16, 17179881472, 3);
INSERT INTO history_transaction_participants VALUES (17, 17179885568, 2);
INSERT INTO history_transaction_participants VALUES (18, 17179885568, 4);
INSERT INTO history_transaction_participants VALUES (19, 21474840576, 3);
INSERT INTO history_transaction_participants VALUES (20, 21474844672, 3);
INSERT INTO history_transaction_participants VALUES (21, 21474848768, 3);
INSERT INTO history_transaction_participants VALUES (22, 21474852864, 3);
INSERT INTO history_transaction_participants VALUES (23, 21474856960, 3);
INSERT INTO history_transaction_participants VALUES (24, 21474861056, 3);
INSERT INTO history_transaction_participants VALUES (25, 21474865152, 3);
INSERT INTO history_transaction_participants VALUES (26, 21474869248, 3);
INSERT INTO history_transaction_participants VALUES (27, 21474873344, 3);
INSERT INTO history_transaction_participants VALUES (28, 21474877440, 3);
INSERT INTO history_transaction_participants VALUES (29, 21474881536, 3);
INSERT INTO history_transaction_participants VALUES (30, 21474885632, 3);
INSERT INTO history_transaction_participants VALUES (31, 21474889728, 3);
INSERT INTO history_transaction_participants VALUES (32, 21474893824, 3);
INSERT INTO history_transaction_participants VALUES (33, 21474897920, 3);
INSERT INTO history_transaction_participants VALUES (34, 21474902016, 3);
INSERT INTO history_transaction_participants VALUES (35, 21474906112, 3);
INSERT INTO history_transaction_participants VALUES (36, 21474910208, 3);
INSERT INTO history_transaction_participants VALUES (37, 21474914304, 3);
INSERT INTO history_transaction_participants VALUES (38, 21474918400, 3);
INSERT INTO history_transaction_participants VALUES (39, 21474922496, 3);
INSERT INTO history_transaction_participants VALUES (40, 21474926592, 3);
INSERT INTO history_transaction_participants VALUES (41, 21474930688, 3);
INSERT INTO history_transaction_participants VALUES (42, 21474934784, 3);
INSERT INTO history_transaction_participants VALUES (43, 21474938880, 3);
INSERT INTO history_transaction_participants VALUES (44, 21474942976, 3);
INSERT INTO history_transaction_participants VALUES (45, 21474947072, 3);
INSERT INTO history_transaction_participants VALUES (46, 21474951168, 3);
INSERT INTO history_transaction_participants VALUES (47, 21474955264, 3);
INSERT INTO history_transaction_participants VALUES (48, 21474959360, 3);
INSERT INTO history_transaction_participants VALUES (49, 21474963456, 3);
INSERT INTO history_transaction_participants VALUES (50, 21474967552, 3);
INSERT INTO history_transaction_participants VALUES (51, 21474971648, 3);


--
-- Name: history_transaction_participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('history_transaction_participants_id_seq', 51, true);


--
-- Data for Name: history_transactions; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO history_transactions VALUES ('db398eb4ae89756325643cad21c94e13bfc074b323ee83e141bf701a5d904f1b', 2, 1, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 1, 100, 1, '2017-02-23 19:56:17.549278', '2017-02-23 19:56:17.549278', 8589938688, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAABAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAACVAvkAAAAAAAAAAABVvwF9wAAAEAYjQcPT2G5hqnBmgGGeg9J8l4c1EnUlxklElH9sqZr0971F6OLWfe/m4kpFtI+sI0i1qLit5A0JyWnbhYLW5oD', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAAAIAAAAAAAAAALW4F0ehO6Ay9C0PsGEgvc1711U98Yj4mLkm9Q75kC3vAAAAAlQL5AAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAIAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2sVNYGtQAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAABAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnZAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAACAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnY/+cAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{GI0HD09huYapwZoBhnoPSfJeHNRJ1JcZJRJR/bKma9Pe9Reji1n3v5uJKRbSPrCNItai4reQNCclp24WC1uaAw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('67c059e1118f4f79b83648e5769b8bf1f1fbf0259d90d2e4a5a8aa0852c41687', 2, 2, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 2, 100, 1, '2017-02-23 19:56:17.555475', '2017-02-23 19:56:17.555475', 8589942784, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAACAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAAN+EdYAAAAAAAAAAABVvwF9wAAAEDUoLr1FIIMdF1JOK2RVg4EDQvL+exej1s795GdZKz5tJB94pDkbAiz8k+mPv0OVuST8ah1MzkZYglos0c1AcID', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAAAIAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAADfhHWAAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAIAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2o1sQwtQAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAACAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnY/84AAAAAAAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{1KC69RSCDHRdSTitkVYOBA0Ly/nsXo9bO/eRnWSs+bSQfeKQ5GwIs/JPpj79Dlbkk/GodTM5GWIJaLNHNQHCAw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('f7cb8309318368f694c8830bf789841e7e2c46dce30e60969d88bd0ce588cbe9', 2, 3, 'GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 3, 100, 1, '2017-02-23 19:56:17.55936', '2017-02-23 19:56:17.55936', 8589946880, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAADAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAbmgm1V2dg5V1mq1elMcG1txjSYKZ9wEgoSBaeW8UiFoAAAAN+EdYAAAAAAAAAAABVvwF9wAAAEAQAaCgnhAHvWviyyciJH3kp9yoTQtn2SFjbCqLUUPBKzcRt8huITE9etfxlEBrW4iiJkrgyQeOCq/IGbGe2RAA', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAAAIAAAAAAAAAAG5oJtVdnYOVdZqtXpTHBtbcY0mCmfcBIKEgWnlvFIhaAAAADfhHWAAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAIAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2lWLJatQAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAACAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnY/7UAAAAAAAAAAMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{EAGgoJ4QB71r4ssnIiR95KfcqE0LZ9khY2wqi1FDwSs3EbfIbiExPXrX8ZRAa1uIoiZK4MkHjgqvyBmxntkQAA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('bd486dbdd02d460817671c4a5a7e9d6e865ca29cb41e62d7aaf70a2fee5b36de', 3, 1, 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 8589934593, 100, 1, '2017-02-23 19:56:17.569459', '2017-02-23 19:56:17.569459', 12884905984, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAABAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABVVNEAAAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt73//////////AAAAAAAAAAGu5L5MAAAAQB9kmKW2q3v7Qfy8PMekEb1TTI5ixqkI0BogXrOt7gO162Qbkh2dSTUfeDovc0PAafhDXxthVAlsLujlBmyjBAY=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAGAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAAAMAAAABAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAAAMAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAADfhHVzgAAAACAAAAAgAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAACAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAA34R1gAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAADAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAA34R1ecAAAAAgAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{H2SYpbare/tB/Lw8x6QRvVNMjmLGqQjQGiBes63uA7XrZBuSHZ1JNR94Oi9zQ8Bp+ENfG2FUCWwu6OUGbKMEBg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('811192c38643df73c015a5a1d77b802dff05d4f50fc6d10816aa75c0a6109f9a', 3, 2, 'GBXGQJWVLWOYHFLVTKWV5FGHA3LNYY2JQKM7OAJAUEQFU6LPCSEFVXON', 8589934593, 100, 1, '2017-02-23 19:56:17.571766', '2017-02-23 19:56:17.571766', 12884910080, 'AAAAAG5oJtVdnYOVdZqtXpTHBtbcY0mCmfcBIKEgWnlvFIhaAAAAZAAAAAIAAAABAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABVVNEAAAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt73//////////AAAAAAAAAAFvFIhaAAAAQPlg7GLhJg0x7jpAw1Ew6H2XF6yRImfJIwFfx09Nui5btOJAFewFANfOaAB8FQZl5p3A5g3k6DHDigfUNUD16gc=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAGAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAAAMAAAABAAAAAG5oJtVdnYOVdZqtXpTHBtbcY0mCmfcBIKEgWnlvFIhaAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAAAMAAAAAAAAAAG5oJtVdnYOVdZqtXpTHBtbcY0mCmfcBIKEgWnlvFIhaAAAADfhHVzgAAAACAAAAAgAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAACAAAAAAAAAABuaCbVXZ2DlXWarV6UxwbW3GNJgpn3ASChIFp5bxSIWgAAAA34R1gAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAADAAAAAAAAAABuaCbVXZ2DlXWarV6UxwbW3GNJgpn3ASChIFp5bxSIWgAAAA34R1ecAAAAAgAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{+WDsYuEmDTHuOkDDUTDofZcXrJEiZ8kjAV/HT026Llu04kAV7AUA185oAHwVBmXmncDmDeToMcOKB9Q1QPXqBw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('3476bc649563488cf025d82790aa9c44649188232b150d2864d13fe9face5406', 3, 3, 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 8589934594, 100, 1, '2017-02-23 19:56:17.574063', '2017-02-23 19:56:17.574063', 12884914176, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAACAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABQlRDAAAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt73//////////AAAAAAAAAAGu5L5MAAAAQEKBv+8zL1epwxC+sJhEYPmbjL9XScXtctoMIdet5dhgk7YJVJzAnRSgYTvfyoIJKJdQmX66uh2o+rG9K6JImgY=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAGAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAAAMAAAABAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAUJUQwAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAAAMAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAADfhHVzgAAAACAAAAAgAAAAIAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAADAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAA34R1c4AAAAAgAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{QoG/7zMvV6nDEL6wmERg+ZuMv1dJxe1y2gwh163l2GCTtglUnMCdFKBhO9/Kggkol1CZfrq6Haj6sb0rokiaBg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('7df857c23c7dfeb974d7c3956775685a8edfa8496bb781fd346c8e2025fad9bf', 3, 4, 'GBXGQJWVLWOYHFLVTKWV5FGHA3LNYY2JQKM7OAJAUEQFU6LPCSEFVXON', 8589934594, 100, 1, '2017-02-23 19:56:17.57617', '2017-02-23 19:56:17.57617', 12884918272, 'AAAAAG5oJtVdnYOVdZqtXpTHBtbcY0mCmfcBIKEgWnlvFIhaAAAAZAAAAAIAAAACAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABQlRDAAAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt73//////////AAAAAAAAAAFvFIhaAAAAQBH/ML6+RzWquFPh8gLF2RuZzYtjjpPeHv/od9M74xlU09Xa4a5e1NhMtMSRIoLItg1EaDWE9zvtHflVWIAaSwQ=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAGAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAAAAAAMAAAABAAAAAG5oJtVdnYOVdZqtXpTHBtbcY0mCmfcBIKEgWnlvFIhaAAAAAUJUQwAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAAAMAAAAAAAAAAG5oJtVdnYOVdZqtXpTHBtbcY0mCmfcBIKEgWnlvFIhaAAAADfhHVzgAAAACAAAAAgAAAAIAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAADAAAAAAAAAABuaCbVXZ2DlXWarV6UxwbW3GNJgpn3ASChIFp5bxSIWgAAAA34R1c4AAAAAgAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{Ef8wvr5HNaq4U+HyAsXZG5nNi2OOk94e/+h30zvjGVTT1drhrl7U2Ey0xJEigsi2DURoNYT3O+0d+VVYgBpLBA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('ea945436a3b650efa88063e737518cf1928d9a43d1aba3ec684704f160b3733e', 4, 1, 'GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4', 8589934593, 100, 1, '2017-02-23 19:56:17.582445', '2017-02-23 19:56:17.582445', 17179873280, 'AAAAALW4F0ehO6Ay9C0PsGEgvc1711U98Yj4mLkm9Q75kC3vAAAAZAAAAAIAAAABAAAAAAAAAAAAAAABAAAAAAAAAAEAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAABVVNEAAAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt7wAAAAukO3QAAAAAAAAAAAH5kC3vAAAAQH/ZkzR/eC0F7xP9zApeHvMH7nqetzaSdYh8WHyrwwvbEnx4Db6gz0grnRJBJS66OZbGmCk7yzHm8DkJ7bJ4QAU=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAwAAAAMAAAABAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAAAQAAAABAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAALpDt0AH//////////AAAAAQAAAAAAAAAA', 'AAAAAgAAAAMAAAACAAAAAAAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt7wAAAAJUC+QAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAEAAAAAAAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt7wAAAAJUC+OcAAAAAgAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{f9mTNH94LQXvE/3MCl4e8wfuep63NpJ1iHxYfKvDC9sSfHgNvqDPSCudEkElLro5lsaYKTvLMebwOQntsnhABQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('416a63c3f1491537698cdb6f981097ed8e44ca27d2d9006bd0ba68832ebf9d55', 4, 2, 'GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4', 8589934594, 100, 1, '2017-02-23 19:56:17.586216', '2017-02-23 19:56:17.586216', 17179877376, 'AAAAALW4F0ehO6Ay9C0PsGEgvc1711U98Yj4mLkm9Q75kC3vAAAAZAAAAAIAAAACAAAAAAAAAAAAAAABAAAAAAAAAAEAAAAAbmgm1V2dg5V1mq1elMcG1txjSYKZ9wEgoSBaeW8UiFoAAAABVVNEAAAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt7wAAAAukO3QAAAAAAAAAAAH5kC3vAAAAQFFGLGFFXbEDRdk2eFyQATNpHuqO/sFrpqsxmNNwGa+MLibNQJLDXWafC4W8KMKQ/hE0M0TLxZeu/O8tYnBuwwA=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAwAAAAMAAAABAAAAAG5oJtVdnYOVdZqtXpTHBtbcY0mCmfcBIKEgWnlvFIhaAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAAAQAAAABAAAAAG5oJtVdnYOVdZqtXpTHBtbcY0mCmfcBIKEgWnlvFIhaAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAALpDt0AH//////////AAAAAQAAAAAAAAAA', 'AAAAAQAAAAEAAAAEAAAAAAAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt7wAAAAJUC+M4AAAAAgAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{UUYsYUVdsQNF2TZ4XJABM2ke6o7+wWumqzGY03AZr4wuJs1AksNdZp8LhbwowpD+ETQzRMvFl6787y1icG7DAA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('c29948d1ca87bad2e3299c1b018c996c22ff5d56f5753bc38f0fd88c4d2c5d94', 4, 3, 'GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4', 8589934595, 100, 1, '2017-02-23 19:56:17.589381', '2017-02-23 19:56:17.589381', 17179881472, 'AAAAALW4F0ehO6Ay9C0PsGEgvc1711U98Yj4mLkm9Q75kC3vAAAAZAAAAAIAAAADAAAAAAAAAAAAAAABAAAAAAAAAAEAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAABQlRDAAAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt7wAAAAukO3QAAAAAAAAAAAH5kC3vAAAAQLn0NeCsam5YrmtsMJQVOLyOTPqDb7SMTCZGofm5ShU6fcl3PPieInQNtk1FmRVeUxdYX1rsW2KH1HQbJ644Hw0=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAwAAAAMAAAABAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAUJUQwAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAAAQAAAABAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAUJUQwAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAALpDt0AH//////////AAAAAQAAAAAAAAAA', 'AAAAAQAAAAEAAAAEAAAAAAAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt7wAAAAJUC+LUAAAAAgAAAAMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{ufQ14Kxqbliua2wwlBU4vI5M+oNvtIxMJkah+blKFTp9yXc8+J4idA22TUWZFV5TF1hfWuxbYofUdBsnrjgfDQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('554ea22913ebf01fc4b3a4d60b59ae28f379b800d5b6da40a6987a53ebd87f07', 4, 4, 'GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4', 8589934596, 100, 1, '2017-02-23 19:56:17.592571', '2017-02-23 19:56:17.592571', 17179885568, 'AAAAALW4F0ehO6Ay9C0PsGEgvc1711U98Yj4mLkm9Q75kC3vAAAAZAAAAAIAAAAEAAAAAAAAAAAAAAABAAAAAAAAAAEAAAAAbmgm1V2dg5V1mq1elMcG1txjSYKZ9wEgoSBaeW8UiFoAAAABQlRDAAAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt7wAAAAukO3QAAAAAAAAAAAH5kC3vAAAAQF34mYyRLbVT42QtFuY5UN0sr9EcuE3ltA/9yAxiNOvukbVTOaz86uCXpEZlX1FnExYDZwOZJWVXfsbdovbVUwc=', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAA=', 'AAAAAAAAAAEAAAACAAAAAwAAAAMAAAABAAAAAG5oJtVdnYOVdZqtXpTHBtbcY0mCmfcBIKEgWnlvFIhaAAAAAUJUQwAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAQAAAAQAAAABAAAAAG5oJtVdnYOVdZqtXpTHBtbcY0mCmfcBIKEgWnlvFIhaAAAAAUJUQwAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAALpDt0AH//////////AAAAAQAAAAAAAAAA', 'AAAAAQAAAAEAAAAEAAAAAAAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt7wAAAAJUC+JwAAAAAgAAAAQAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{XfiZjJEttVPjZC0W5jlQ3Syv0Ry4TeW0D/3IDGI06+6RtVM5rPzq4JekRmVfUWcTFgNnA5klZVd+xt2i9tVTBw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('c48b48982dcd1f079d90ee3289dc2b6269bce088bd7183ddba8e3dca25b1e84b', 5, 1, 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 8589934595, 100, 1, '2017-02-23 19:56:17.602938', '2017-02-23 19:56:17.602938', 21474840576, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAADAAAAAAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAXSHboAAAAAAEAAAAKAAAAAAAAAAAAAAAAAAAAAa7kvkwAAABAOL8799gdl4G9kC/cOT6pQu2zfD5GhhExAKtKmb7s8ozksyqIYI21eqCLcluwLlb2wBim5Owr0y2zzxYH7vqOBw==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAAAEAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAN4G/GVAAAAAEAAAAKAAAAAAAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAAAEAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAN4G/GVAAAAAEAAAAKAAAAAAAAAAAAAAAAAAAAAQAAAAUAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAADfhHSlQAAAACAAAAIwAAAAMAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAgAAAAMAAAADAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAA34R1c4AAAAAgAAAAIAAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAAFAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAA34R1bUAAAAAgAAAAMAAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{OL8799gdl4G9kC/cOT6pQu2zfD5GhhExAKtKmb7s8ozksyqIYI21eqCLcluwLlb2wBim5Owr0y2zzxYH7vqOBw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('437a48108dd143273dcf1c28296d6048d0915c6072650eb5f794b89560a40c0c', 5, 2, 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 8589934596, 100, 1, '2017-02-23 19:56:17.605343', '2017-02-23 19:56:17.605343', 21474844672, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAAEAAAAAAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAU9GsEAAAAAAEAAAAJAAAAAAAAAAAAAAAAAAAAAa7kvkwAAABAuUnZlMxj8taqMo/PYfI4rBl41Cpps/XHGlNot5+TWTZE9A06ipER6Q7XqbxhNzmAR8NaQbS3Ds0RQv44r3GLCg==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAAAIAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAN2nnlVAAAAAEAAAAJAAAAAAAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAAAIAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAN2nnlVAAAAAEAAAAJAAAAAAAAAAAAAAAAAAAAAQAAAAUAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAADfhHSlQAAAACAAAAIwAAAAQAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAFAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAA34R1ZwAAAAAgAAAAQAAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{uUnZlMxj8taqMo/PYfI4rBl41Cpps/XHGlNot5+TWTZE9A06ipER6Q7XqbxhNzmAR8NaQbS3Ds0RQv44r3GLCg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('9f9ea714b1a39664b1e6df0fafd1aa17eda71bb05715fe1371246f3208b3a1b1', 5, 3, 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 8589934597, 100, 1, '2017-02-23 19:56:17.606999', '2017-02-23 19:56:17.606999', 21474848768, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAAFAAAAAAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAASoF8gAAAAAAEAAAAIAAAAAAAAAAAAAAAAAAAAAa7kvkwAAABA9LQUhBPQFZOopSh/vuUNPcUm0DLI9wD4aw449Ccu6ADMejat8t2MyuzWvx8RwQMPd9zdXlwCE5d8cT3upwuPAg==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAN1IQEVAAAAAEAAAAIAAAAAAAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAN1IQEVAAAAAEAAAAIAAAAAAAAAAAAAAAAAAAAAQAAAAUAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAADfhHSlQAAAACAAAAIwAAAAUAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAFAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAA34R1YMAAAAAgAAAAUAAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{9LQUhBPQFZOopSh/vuUNPcUm0DLI9wD4aw449Ccu6ADMejat8t2MyuzWvx8RwQMPd9zdXlwCE5d8cT3upwuPAg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('f966ab310137dae86c7ee7ee08850339537c78f854eaaaea78d7fd834134da79', 5, 4, 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 8589934598, 100, 1, '2017-02-23 19:56:17.608604', '2017-02-23 19:56:17.608604', 21474852864, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAAGAAAAAAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAQTFM8AAAAAAEAAAAHAAAAAAAAAAAAAAAAAAAAAa7kvkwAAABAaZXT/bkDz3FqTJhXKtcSev5gzrE0wL2GSnszf7t4qBTcnW3P4heHeAFIkSjtgz0m7IgGT1goVlbtdA5PtZNNCw==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAAAQAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAANzo4jVAAAAAEAAAAHAAAAAAAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAAAQAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAANzo4jVAAAAAEAAAAHAAAAAAAAAAAAAAAAAAAAAQAAAAUAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAADfhHSlQAAAACAAAAIwAAAAYAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAFAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAA34R1WoAAAAAgAAAAYAAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{aZXT/bkDz3FqTJhXKtcSev5gzrE0wL2GSnszf7t4qBTcnW3P4heHeAFIkSjtgz0m7IgGT1goVlbtdA5PtZNNCw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('360d890880eebd224d7506b9881352fbc6b6b1921f84a85e9807f0775b5560bc', 5, 5, 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 8589934599, 100, 1, '2017-02-23 19:56:17.610165', '2017-02-23 19:56:17.610165', 21474856960, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAAHAAAAAAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAN+EdYAAAAAAEAAAAGAAAAAAAAAAAAAAAAAAAAAa7kvkwAAABAp1hMoM8rNid3pnBSv/sqgRwIIyLgkeBbUMH9SYTGgXXWZSB1Q7Rv54QgXbJ5XNxPqA9kgz/LYpJc3V9Lsk+mBA==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAAAUAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAANyJhCVAAAAAEAAAAGAAAAAAAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAAAUAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAANyJhCVAAAAAEAAAAGAAAAAAAAAAAAAAAAAAAAAQAAAAUAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAADfhHSlQAAAACAAAAIwAAAAcAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAFAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAA34R1VEAAAAAgAAAAcAAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{p1hMoM8rNid3pnBSv/sqgRwIIyLgkeBbUMH9SYTGgXXWZSB1Q7Rv54QgXbJ5XNxPqA9kgz/LYpJc3V9Lsk+mBA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('bc1c988cc29d96ba3ed032e48f862cda1c9ed615b07ac8db51ef399cd3fa2941', 5, 6, 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 8589934600, 100, 1, '2017-02-23 19:56:17.611716', '2017-02-23 19:56:17.611716', 21474861056, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAAIAAAAAAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAALpDt0AAAAAAEAAAAFAAAAAAAAAAAAAAAAAAAAAa7kvkwAAABAd6LAs45dbBkADWNU5etnooaywHqrB19Tf40hy6/miUAnNAx6o8/ueoRawn+3RJyRvQW3WKpZPbp4zB49zcYkDw==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAAAYAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAALpDt0AAAAAAEAAAAFAAAAAAAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAAAYAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAALpDt0AAAAAAEAAAAFAAAAAAAAAAAAAAAAAAAAAQAAAAUAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAADfhHSlQAAAACAAAAIwAAAAgAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAFAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAA34R1TgAAAAAgAAAAgAAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{d6LAs45dbBkADWNU5etnooaywHqrB19Tf40hy6/miUAnNAx6o8/ueoRawn+3RJyRvQW3WKpZPbp4zB49zcYkDw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('61b33dced6b81dde0e86b61ba4abc280b6c35c6e4ba8045b5082f74a9a2b60ed', 5, 7, 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 8589934601, 100, 1, '2017-02-23 19:56:17.613422', '2017-02-23 19:56:17.613422', 21474865152, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAAJAAAAAAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAJUC+QAAAAAAEAAAAEAAAAAAAAAAAAAAAAAAAAAa7kvkwAAABAFHqWUK4Luj4d8sUiQ18OB6fikbsPQXZAOIfZ32sgs62+Q17GMnwYqsxFo1ti49R7cMLadDsnhHjknkOQMzc+Dg==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAAAcAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAJUC+QAAAAAAEAAAAEAAAAAAAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAAAcAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAJUC+QAAAAAAEAAAAEAAAAAAAAAAAAAAAAAAAAAQAAAAUAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAADfhHSlQAAAACAAAAIwAAAAkAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAFAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAA34R1R8AAAAAgAAAAkAAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{FHqWUK4Luj4d8sUiQ18OB6fikbsPQXZAOIfZ32sgs62+Q17GMnwYqsxFo1ti49R7cMLadDsnhHjknkOQMzc+Dg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('163aab67c5a24a59eda5e4b4e5f32924f603cff52a5e4fb25eae987538c23106', 5, 8, 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 8589934602, 100, 1, '2017-02-23 19:56:17.614981', '2017-02-23 19:56:17.614981', 21474869248, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAAKAAAAAAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAG/COsAAAAAAEAAAADAAAAAAAAAAAAAAAAAAAAAa7kvkwAAABAm8aNJ18QdO28lh/q/TJRX9IDlSqhaNzxgla/NgydpGXxdgAYYA9bSLdcknkQ8zFwfSdYmmjKqnDxYG1U00rLBw==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAAAgAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAG/COsAAAAAAEAAAADAAAAAAAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAAAgAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAG/COsAAAAAAEAAAADAAAAAAAAAAAAAAAAAAAAAQAAAAUAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAADfhHSlQAAAACAAAAIwAAAAoAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAFAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAA34R1QYAAAAAgAAAAoAAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{m8aNJ18QdO28lh/q/TJRX9IDlSqhaNzxgla/NgydpGXxdgAYYA9bSLdcknkQ8zFwfSdYmmjKqnDxYG1U00rLBw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('627fdbd55feaf21e6e96addebb0f5fc73540ff9505d5d0dc76c9ec69f4d2f76f', 5, 9, 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 8589934603, 100, 1, '2017-02-23 19:56:17.616495', '2017-02-23 19:56:17.616495', 21474873344, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAALAAAAAAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAEqBfIAAAAAAEAAAACAAAAAAAAAAAAAAAAAAAAAa7kvkwAAABA2pl8oiRj9zUIFp9AYMaKOb0OAbMsMjJNUUHewa3JwSH0V2Zaol7gkH5ymr3CNwO1e5X8fGilLZm+x5P7okPWDQ==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAAAkAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAEqBfIAAAAAAEAAAACAAAAAAAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAAAkAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAEqBfIAAAAAAEAAAACAAAAAAAAAAAAAAAAAAAAAQAAAAUAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAADfhHSlQAAAACAAAAIwAAAAsAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAFAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAA34R1O0AAAAAgAAAAsAAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{2pl8oiRj9zUIFp9AYMaKOb0OAbMsMjJNUUHewa3JwSH0V2Zaol7gkH5ymr3CNwO1e5X8fGilLZm+x5P7okPWDQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('e252b8842716f49fe824df8c95e51a55b40db1b51017ba97dc59b2d971e5cb10', 5, 10, 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 8589934604, 100, 1, '2017-02-23 19:56:17.618045', '2017-02-23 19:56:17.618045', 21474877440, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAAMAAAAAAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAACVAvkAAAAAAEAAAABAAAAAAAAAAAAAAAAAAAAAa7kvkwAAABA0lB577a6VFTmqiBKQXiyg6YgjTPcU8n9Mldb5GdKeZ8DRkWG797qE3Tn/WL5uFYnY6qldsI9U31ASttn/Mh8Cg==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAAAoAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAACVAvkAAAAAAEAAAABAAAAAAAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAAAoAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAACVAvkAAAAAAEAAAABAAAAAAAAAAAAAAAAAAAAAQAAAAUAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAADfhHSlQAAAACAAAAIwAAAAwAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAFAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAA34R1NQAAAAAgAAAAwAAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{0lB577a6VFTmqiBKQXiyg6YgjTPcU8n9Mldb5GdKeZ8DRkWG797qE3Tn/WL5uFYnY6qldsI9U31ASttn/Mh8Cg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('b962b228793859d32de9d6a3d3e782acb8f2d0b9e3a17a91571a402d7cd47a8a', 5, 11, 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 8589934605, 100, 1, '2017-02-23 19:56:17.61977', '2017-02-23 19:56:17.61977', 21474881536, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAANAAAAAAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAAO5rKAAAAAAoAAAABAAAAAAAAAAAAAAAAAAAAAa7kvkwAAABAikMlBAAA6oi4Rg6Gp3svzTPGcaUQx4HtpN0TgusXrMTkbVsBpvHNs+w0bFF9BOgtyGYK2/6zfkXYMVEB9X6aCg==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAAAsAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAAO5rKAAAAAAoAAAABAAAAAAAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAAAsAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAAO5rKAAAAAAoAAAABAAAAAAAAAAAAAAAAAAAAAQAAAAUAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAADfhHSlQAAAACAAAAIwAAAA0AAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAFAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAA34R1LsAAAAAgAAAA0AAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{ikMlBAAA6oi4Rg6Gp3svzTPGcaUQx4HtpN0TgusXrMTkbVsBpvHNs+w0bFF9BOgtyGYK2/6zfkXYMVEB9X6aCg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('0343d98ff86bf4b5f9e24db8b3889fe34df7a166cfde7e9098a83c11f7eb9722', 5, 12, 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 8589934606, 100, 1, '2017-02-23 19:56:17.621242', '2017-02-23 19:56:17.621242', 21474885632, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAAOAAAAAAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAXhBGyAAAAAAoAAABlAAAAAAAAAAAAAAAAAAAAAa7kvkwAAABAjAuehle1J2zs3RaLV5FD/TsgwVWQTHrGyz9xtHfjohTp9ugklMElF1GFa7zxijTpghCK1A0yyVuIrf8mIQiuBA==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAAAwAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAANnt8bVAAAAAoAAABlAAAAAAAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAAAwAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAANnt8bVAAAAAoAAABlAAAAAAAAAAAAAAAAAAAAAQAAAAUAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAADfhHSlQAAAACAAAAIwAAAA4AAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAFAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAA34R1KIAAAAAgAAAA4AAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{jAuehle1J2zs3RaLV5FD/TsgwVWQTHrGyz9xtHfjohTp9ugklMElF1GFa7zxijTpghCK1A0yyVuIrf8mIQiuBA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('e82691759c9c5796c5cc91a1c71f233b6c5a38af9ad5976c7e655078818838e7', 5, 13, 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 8589934607, 100, 1, '2017-02-23 19:56:17.623058', '2017-02-23 19:56:17.623058', 21474889728, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAAPAAAAAAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAVMAXOAAAAAAoAAABbAAAAAAAAAAAAAAAAAAAAAa7kvkwAAABAj4F6inPyng6e0YtLtA9CBE8NYDuuMERmHR9ePEt3dFa0gma/P84LRkWeDa4Zb2E6wKVLnrjcqRdWHjE1YN3CAw==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAAA0AAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAANmOk6VAAAAAoAAABbAAAAAAAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAAA0AAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAANmOk6VAAAAAoAAABbAAAAAAAAAAAAAAAAAAAAAQAAAAUAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAADfhHSlQAAAACAAAAIwAAAA8AAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAFAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAA34R1IkAAAAAgAAAA8AAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{j4F6inPyng6e0YtLtA9CBE8NYDuuMERmHR9ePEt3dFa0gma/P84LRkWeDa4Zb2E6wKVLnrjcqRdWHjE1YN3CAw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('d80c809a4065600d7705e7db04e1260bf39582d941446a95fb9cea66680ef0c3', 5, 14, 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 8589934608, 100, 1, '2017-02-23 19:56:17.624817', '2017-02-23 19:56:17.624818', 21474893824, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAAQAAAAAAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAS2/nqAAAAAAoAAABRAAAAAAAAAAAAAAAAAAAAAa7kvkwAAABAGYwwYwUMaDuxhjfxFrmYgv62lZiUxTe8QNw75Za/PCyZ/ZS4NK6peWAJh+m8H33lhcVsst5ElAhFZ+zwZZ3VDQ==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAAA4AAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAANkvNZVAAAAAoAAABRAAAAAAAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAAA4AAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAANkvNZVAAAAAoAAABRAAAAAAAAAAAAAAAAAAAAAQAAAAUAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAADfhHSlQAAAACAAAAIwAAABAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAFAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAA34R1HAAAAAAgAAABAAAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{GYwwYwUMaDuxhjfxFrmYgv62lZiUxTe8QNw75Za/PCyZ/ZS4NK6peWAJh+m8H33lhcVsst5ElAhFZ+zwZZ3VDQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('fd0bc444f5e90e9a61a5aa011a8b62376ef2d7e304418a188a294bb0b95740f8', 5, 15, 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 8589934609, 100, 1, '2017-02-23 19:56:17.626348', '2017-02-23 19:56:17.626348', 21474897920, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAARAAAAAAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAQh+4GAAAAAAoAAABHAAAAAAAAAAAAAAAAAAAAAa7kvkwAAABAvgqC6TyEhSrhF7K4wwOgd0sCvmFAQgfM1Ez+eEwWbm/BPJSW0WpOTxU5feEKAOpLYaHJvvvD+WZKm5PI/yadBw==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAAA8AAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAANjP14VAAAAAoAAABHAAAAAAAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAAA8AAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAANjP14VAAAAAoAAABHAAAAAAAAAAAAAAAAAAAAAQAAAAUAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAADfhHSlQAAAACAAAAIwAAABEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAFAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAA34R1FcAAAAAgAAABEAAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{vgqC6TyEhSrhF7K4wwOgd0sCvmFAQgfM1Ez+eEwWbm/BPJSW0WpOTxU5feEKAOpLYaHJvvvD+WZKm5PI/yadBw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('04b1a1a09159b1c7bb43fd1dc0f282958d0a01c337d72a0324c0262b58d93615', 5, 16, 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 8589934610, 100, 1, '2017-02-23 19:56:17.628017', '2017-02-23 19:56:17.628017', 21474902016, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAASAAAAAAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAOM+IiAAAAAAoAAAA9AAAAAAAAAAAAAAAAAAAAAa7kvkwAAABAE0N79ktAplSSjovU50IktziuRrJN6xmRkF7fsV+YjK5g8XWPegdWuH8u55zCzZcBzddo8CaiuEWpJMPjMZZICA==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAABAAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAANhweXVAAAAAoAAAA9AAAAAAAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAABAAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAANhweXVAAAAAoAAAA9AAAAAAAAAAAAAAAAAAAAAQAAAAUAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAADfhHSlQAAAACAAAAIwAAABIAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAFAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAA34R1D4AAAAAgAAABIAAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{E0N79ktAplSSjovU50IktziuRrJN6xmRkF7fsV+YjK5g8XWPegdWuH8u55zCzZcBzddo8CaiuEWpJMPjMZZICA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('5d37d98f720dfb3dce49331f403bfa3f9ef13122fae954a73b7b688b180b1516', 5, 17, 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 8589934611, 100, 1, '2017-02-23 19:56:17.629707', '2017-02-23 19:56:17.629708', 21474906112, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAATAAAAAAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAL39Y+AAAAAAoAAAAzAAAAAAAAAAAAAAAAAAAAAa7kvkwAAABAXUhb5QTAO+vV5kTEQqOp9yi4sDerjU5vIT5VH3MiOG381zIplmafJjLNHS02enkonOHtHWIvqznVQjHqQ389DQ==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAABEAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAL39Y+AAAAAAoAAAAzAAAAAAAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAABEAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAL39Y+AAAAAAoAAAAzAAAAAAAAAAAAAAAAAAAAAQAAAAUAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAADfhHSlQAAAACAAAAIwAAABMAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAFAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAA34R1CUAAAAAgAAABMAAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{XUhb5QTAO+vV5kTEQqOp9yi4sDerjU5vIT5VH3MiOG381zIplmafJjLNHS02enkonOHtHWIvqznVQjHqQ389DQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('a3d82c4ac237e77f385f3cdf5a358cabc4b0c12b7f58b59c197fdba8a76010cf', 5, 18, 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 8589934612, 100, 1, '2017-02-23 19:56:17.631208', '2017-02-23 19:56:17.631208', 21474910208, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAAUAAAAAAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAJi8paAAAAAAoAAAApAAAAAAAAAAAAAAAAAAAAAa7kvkwAAABAiJwFcozA9Q4Vj/tABAkphbvOi6Hs325bHDBpTi6J/LN3SVHGsYQ2UwD1recgYoYtoWD1+qkKdFMSzeuIZodJDQ==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAABIAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAJi8paAAAAAAoAAAApAAAAAAAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAABIAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAJi8paAAAAAAoAAAApAAAAAAAAAAAAAAAAAAAAAQAAAAUAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAADfhHSlQAAAACAAAAIwAAABQAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAFAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAA34R1AwAAAAAgAAABQAAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{iJwFcozA9Q4Vj/tABAkphbvOi6Hs325bHDBpTi6J/LN3SVHGsYQ2UwD1recgYoYtoWD1+qkKdFMSzeuIZodJDQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('e09337eedf136665192e840b23bf26b86fc85b93bb401d3a1ce4ee2a1b579213', 5, 19, 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 8589934613, 100, 1, '2017-02-23 19:56:17.632806', '2017-02-23 19:56:17.632806', 21474914304, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAAVAAAAAAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAHN752AAX14QkSejmcAAAAAAAAAAAAAAAAAAAAAa7kvkwAAABAEhl1VhzJ53lV9jnMsTC9/D5/tr0jaWCgSc0KCmdSqlqbQ/kDEgvT+jfSLDuQ6gM9GJCSfoFXT4preQ0mpLvCCQ==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAABMAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAHN752AAX14QkSejmcAAAAAAAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAABMAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAHN752AAX14QkSejmcAAAAAAAAAAAAAAAAAAAAAQAAAAUAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAADfhHSlQAAAACAAAAIwAAABUAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAFAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAA34R0/MAAAAAgAAABUAAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{Ehl1VhzJ53lV9jnMsTC9/D5/tr0jaWCgSc0KCmdSqlqbQ/kDEgvT+jfSLDuQ6gM9GJCSfoFXT4preQ0mpLvCCQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('f140ddf0c75f70ddf0d79391e6b5992b9c56b9c23c040008b908c70a413eb03d', 5, 20, 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 8589934614, 100, 1, '2017-02-23 19:56:17.634379', '2017-02-23 19:56:17.634379', 21474918400, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAAWAAAAAAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAE47KSAAAAAAoAAAAVAAAAAAAAAAAAAAAAAAAAAa7kvkwAAABAW7ujBoctNRfa1M6+T0tShj0Q+l9ybp9C6jQmrSEUeBSwAqucU1YAMlc3XzqIBy35EsuVN0k0hD81/rrCNCtICg==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAABQAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAE47KSAAAAAAoAAAAVAAAAAAAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAABQAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAE47KSAAAAAAoAAAAVAAAAAAAAAAAAAAAAAAAAAQAAAAUAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAADfhHSlQAAAACAAAAIwAAABYAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAFAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAA34R09oAAAAAgAAABYAAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{W7ujBoctNRfa1M6+T0tShj0Q+l9ybp9C6jQmrSEUeBSwAqucU1YAMlc3XzqIBy35EsuVN0k0hD81/rrCNCtICg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('5d46530574ecf525512b5184af69899d95a826ec6bbad2e0b2d34b3efa352d7f', 5, 21, 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 8589934615, 100, 1, '2017-02-23 19:56:17.635894', '2017-02-23 19:56:17.635894', 21474922496, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAAXAAAAAAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAACj6auAAAAAAoAAAALAAAAAAAAAAAAAAAAAAAAAa7kvkwAAABAmEz+ciLZWEXIlsEWtrY1Ii1fzoax2dGCE/Fu0GhOyqbw90Dvs+k3aVOmQLTByU5JWjEvd6Op+oV3i+7KPPtxAw==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAABUAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAACj6auAAAAAAoAAAALAAAAAAAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAABUAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAACj6auAAAAAAoAAAALAAAAAAAAAAAAAAAAAAAAAQAAAAUAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAADfhHSlQAAAACAAAAIwAAABcAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAFAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAA34R08EAAAAAgAAABcAAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{mEz+ciLZWEXIlsEWtrY1Ii1fzoax2dGCE/Fu0GhOyqbw90Dvs+k3aVOmQLTByU5JWjEvd6Op+oV3i+7KPPtxAw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('bc2a16ca82b7d0bd903c26482736cceb9f4efa077071e72849654b3aced94136', 5, 22, 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 8589934616, 100, 1, '2017-02-23 19:56:17.637398', '2017-02-23 19:56:17.637398', 21474926592, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAAYAAAAAAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAAdzWUAAAAAAUAAAABAAAAAAAAAAAAAAAAAAAAAa7kvkwAAABAJnrtXGyjkqpAJAFfDY0JyJjXfS9/xXLLHdu3XT20IxpJCBQ2K0fhYnVis0tnbacC9/vTcmLnWxKg1oGCR9usBA==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAABYAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAAdzWUAAAAAAUAAAABAAAAAAAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAABYAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAAdzWUAAAAAAUAAAABAAAAAAAAAAAAAAAAAAAAAQAAAAUAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAADfhHSlQAAAACAAAAIwAAABgAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAFAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAA34R06gAAAAAgAAABgAAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{JnrtXGyjkqpAJAFfDY0JyJjXfS9/xXLLHdu3XT20IxpJCBQ2K0fhYnVis0tnbacC9/vTcmLnWxKg1oGCR9usBA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('a0bdbdb1aa35b7f2aec201b618fca59405e4c375f8f76a24ef25e885a96fd7ed', 5, 23, 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 8589934617, 100, 1, '2017-02-23 19:56:17.638865', '2017-02-23 19:56:17.638865', 21474930688, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAAZAAAAAAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAXv6x8AAAAAAUAAAAzAAAAAAAAAAAAAAAAAAAAAa7kvkwAAABAGqxC/cid99JKEBv6Y7vmkU1u+UQ+SwDxHIjLeMmmrt5Uv2TCs6Ct4tokvwjlGsbBo1scU8nQmwuXui8bfNGTAA==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAABcAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAANXU5wVAAAAAUAAAAzAAAAAAAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAABcAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAANXU5wVAAAAAUAAAAzAAAAAAAAAAAAAAAAAAAAAQAAAAUAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAADfhHSlQAAAACAAAAIwAAABkAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAFAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAA34R048AAAAAgAAABkAAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{GqxC/cid99JKEBv6Y7vmkU1u+UQ+SwDxHIjLeMmmrt5Uv2TCs6Ct4tokvwjlGsbBo1scU8nQmwuXui8bfNGTAA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('9b90554626c9bfa396b4f61cc910d383a38f1223c8f5478edde6fe60a7f2f406', 5, 24, 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 8589934618, 100, 1, '2017-02-23 19:56:17.640312', '2017-02-23 19:56:17.640312', 21474934784, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAAaAAAAAAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAVa6CYAAAAAAUAAAAuAAAAAAAAAAAAAAAAAAAAAa7kvkwAAABATU8XW0HLVKABibMcV0H3VxUkGh/dQhUcM0eFCkFzVgeXmY9g1V/MnP9DsNs1aipuJVlAGS0B88gxbmoQ5h6rDA==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAABgAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAANV1iPVAAAAAUAAAAuAAAAAAAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAABgAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAANV1iPVAAAAAUAAAAuAAAAAAAAAAAAAAAAAAAAAQAAAAUAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAADfhHSlQAAAACAAAAIwAAABoAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAFAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAA34R03YAAAAAgAAABoAAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{TU8XW0HLVKABibMcV0H3VxUkGh/dQhUcM0eFCkFzVgeXmY9g1V/MnP9DsNs1aipuJVlAGS0B88gxbmoQ5h6rDA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('0e17e87fcda53937d77cbf1e2658fcdf41eb0689e9649545bb14a5960832e5b8', 5, 25, 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 8589934619, 100, 1, '2017-02-23 19:56:17.641778', '2017-02-23 19:56:17.641778', 21474938880, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAAbAAAAAAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAATF5S0AAAAAAUAAAApAAAAAAAAAAAAAAAAAAAAAa7kvkwAAABALhl41aevL0eWZT/dx9jwFRVb7nDeDsjPeuPKK5QCBgWZjBWFwwRXz+gTiHccCvG5W4d93ucAU4xOkbCj1VH9CQ==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAABkAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAANUWKuVAAAAAUAAAApAAAAAAAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAABkAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAANUWKuVAAAAAUAAAApAAAAAAAAAAAAAAAAAAAAAQAAAAUAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAADfhHSlQAAAACAAAAIwAAABsAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAFAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAA34R010AAAAAgAAABsAAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{Lhl41aevL0eWZT/dx9jwFRVb7nDeDsjPeuPKK5QCBgWZjBWFwwRXz+gTiHccCvG5W4d93ucAU4xOkbCj1VH9CQ==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('f277e4abf7d0d326fa63ee62415f7a117e43453072677d1f6e9618c8d2bb8524', 5, 26, 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 8589934620, 100, 1, '2017-02-23 19:56:17.643229', '2017-02-23 19:56:17.643229', 21474942976, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAAcAAAAAAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAQw4jQAAAAAAUAAAAkAAAAAAAAAAAAAAAAAAAAAa7kvkwAAABAxjfuAsXsrTxv+5NVYnsb0soqC6ZoluT/Xobjrt45eAeNZMwp9/RV2hLXySkVOVk2O814/dgyeap7M+LgWibPBg==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAABoAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAANS2zNVAAAAAUAAAAkAAAAAAAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAABoAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAANS2zNVAAAAAUAAAAkAAAAAAAAAAAAAAAAAAAAAQAAAAUAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAADfhHSlQAAAACAAAAIwAAABwAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAFAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAA34R00QAAAAAgAAABwAAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{xjfuAsXsrTxv+5NVYnsb0soqC6ZoluT/Xobjrt45eAeNZMwp9/RV2hLXySkVOVk2O814/dgyeap7M+LgWibPBg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('5e3622bf6dab1276155014b8387f261a0bbfbef247caa05e9c4be8c890dad958', 5, 27, 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 8589934621, 100, 1, '2017-02-23 19:56:17.64466', '2017-02-23 19:56:17.64466', 21474947072, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAAdAAAAAAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAOb3zsAAAAAAUAAAAfAAAAAAAAAAAAAAAAAAAAAa7kvkwAAABAcFijipV/lZRIDYicNpHFwnaL4J0Fmwkcr0G9VxH4lZSYgLjgQnvgniCBQrvu2eqyqOFHC8H04T7D9jXseYr4Cg==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAABsAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAANRXbsVAAAAAUAAAAfAAAAAAAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAABsAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAANRXbsVAAAAAUAAAAfAAAAAAAAAAAAAAAAAAAAAQAAAAUAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAADfhHSlQAAAACAAAAIwAAAB0AAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAFAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAA34R0ysAAAAAgAAAB0AAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{cFijipV/lZRIDYicNpHFwnaL4J0Fmwkcr0G9VxH4lZSYgLjgQnvgniCBQrvu2eqyqOFHC8H04T7D9jXseYr4Cg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('b00c83ae8f3d0cd4f1760517182abdf0440eca6efcd2b0fa893aac85b35e42cb', 5, 28, 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 8589934622, 100, 1, '2017-02-23 19:56:17.646202', '2017-02-23 19:56:17.646202', 21474951168, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAAeAAAAAAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAMG3EIAAAAAAUAAAAaAAAAAAAAAAAAAAAAAAAAAa7kvkwAAABAbHyKtzQE0yWfACwWf+1pYV3POGcAKxlNttLK4B5LmX34VwUIGjWHqKIiw/aDtsaIqBJI62bfkYn6KiMWiRnlAg==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAABwAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAMG3EIAAAAAAUAAAAaAAAAAAAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAABwAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAMG3EIAAAAAAUAAAAaAAAAAAAAAAAAAAAAAAAAAQAAAAUAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAADfhHSlQAAAACAAAAIwAAAB4AAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAFAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAA34R0xIAAAAAgAAAB4AAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{bHyKtzQE0yWfACwWf+1pYV3POGcAKxlNttLK4B5LmX34VwUIGjWHqKIiw/aDtsaIqBJI62bfkYn6KiMWiRnlAg==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('3f731b66c1a3d2c4cf9d15bb17e910beaa6f6fa6a77cccfd62f5eabcd3ecfcc5', 5, 29, 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 8589934623, 100, 1, '2017-02-23 19:56:17.647682', '2017-02-23 19:56:17.647682', 21474955264, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAAfAAAAAAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAJx2UkAAAAAAUAAAAVAAAAAAAAAAAAAAAAAAAAAa7kvkwAAABAkkZq5sVwc5pr6NYfqlSYkQevr273ibhO9EwVykO2mQ4+ka+BrQj++wfcsuJFbGaeE6NtzQxTf7XQaGZpwjk5Cw==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAAB0AAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAJx2UkAAAAAAUAAAAVAAAAAAAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAAB0AAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAJx2UkAAAAAAUAAAAVAAAAAAAAAAAAAAAAAAAAAQAAAAUAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAADfhHSlQAAAACAAAAIwAAAB8AAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAFAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAA34R0vkAAAAAgAAAB8AAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{kkZq5sVwc5pr6NYfqlSYkQevr273ibhO9EwVykO2mQ4+ka+BrQj++wfcsuJFbGaeE6NtzQxTf7XQaGZpwjk5Cw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('492c8c2808bf649ba321f0f75dda11581107bff229ef457340aab8494f5ad412', 5, 30, 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 8589934624, 100, 1, '2017-02-23 19:56:17.649137', '2017-02-23 19:56:17.649137', 21474959360, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAAgAAAAAAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAHc1lAAAAAAAUAAAAQAAAAAAAAAAAAAAAAAAAAAa7kvkwAAABAGoxQs3i+aE6OAegBkTmA0dqEadD541CFUYMVQ1aCii5ioLMaP6i5oSZ5+4c0VfY2MAPmpxdNCOY3vwH4XD8yCw==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAAB4AAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAHc1lAAAAAAAUAAAAQAAAAAAAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAAB4AAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAHc1lAAAAAAAUAAAAQAAAAAAAAAAAAAAAAAAAAAQAAAAUAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAADfhHSlQAAAACAAAAIwAAACAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAFAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAA34R0uAAAAAAgAAACAAAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{GoxQs3i+aE6OAegBkTmA0dqEadD541CFUYMVQ1aCii5ioLMaP6i5oSZ5+4c0VfY2MAPmpxdNCOY3vwH4XD8yCw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('c03dfbea35606bd565f3609a306aa27a82aa14b3fd142f1a13b79c1871f54a3b', 5, 31, 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 8589934625, 100, 1, '2017-02-23 19:56:17.650548', '2017-02-23 19:56:17.650548', 21474963456, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAAhAAAAAAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAFH01cAAAAAAUAAAALAAAAAAAAAAAAAAAAAAAAAa7kvkwAAABAlTGl5Ll7WR6ooHo4TPTHiPsPhYQEcPuFd4lby43niifsCCnLkZfzoZYxODmAHHv/RXkskBH7eRkxCZYBRXRQBA==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAAB8AAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAFH01cAAAAAAUAAAALAAAAAAAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAAB8AAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAFH01cAAAAAAUAAAALAAAAAAAAAAAAAAAAAAAAAQAAAAUAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAADfhHSlQAAAACAAAAIwAAACEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAFAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAA34R0scAAAAAgAAACEAAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{lTGl5Ll7WR6ooHo4TPTHiPsPhYQEcPuFd4lby43niifsCCnLkZfzoZYxODmAHHv/RXkskBH7eRkxCZYBRXRQBA==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('42e47f8fdcb738c844e1556c9fad18eb8887d78681ef5e9616898eb6e1c5e8eb', 5, 32, 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 8589934626, 100, 1, '2017-02-23 19:56:17.652094', '2017-02-23 19:56:17.652094', 21474967552, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAAiAAAAAAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAACy0F4AAAAAAUAAAAGAAAAAAAAAAAAAAAAAAAAAa7kvkwAAABAaSoEc/Kxao3Z6gUsTh1QfLjlT486TQKgtu9NhqT8EzSQ2jFCWgP+odJUnTIPRU74DOgqwEgcHBGpovaass24Dw==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAACAAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAACy0F4AAAAAAUAAAAGAAAAAAAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAACAAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAACy0F4AAAAAAUAAAAGAAAAAAAAAAAAAAAAAAAAAQAAAAUAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAADfhHSlQAAAACAAAAIwAAACIAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAFAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAA34R0q4AAAAAgAAACIAAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{aSoEc/Kxao3Z6gUsTh1QfLjlT486TQKgtu9NhqT8EzSQ2jFCWgP+odJUnTIPRU74DOgqwEgcHBGpovaass24Dw==}', 'none', NULL, NULL);
INSERT INTO history_transactions VALUES ('ee96865dfca78c43c4074317f3dbcd7ca978643b973bc9a5dc4f2588f981c6d7', 5, 33, 'GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 8589934627, 100, 1, '2017-02-23 19:56:17.65355', '2017-02-23 19:56:17.65355', 21474971648, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAAjAAAAAAAAAAAAAAABAAAAAAAAAAMAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAAstBeAAAAAAoAAAADAAAAAAAAAAAAAAAAAAAAAa7kvkwAAABA2FwoenXJVOTi9oyWHyNL+0wLRdikDwB4qdNJmj+OQi8a0jRgjQG/1/EsSq885q7mUvX57XCjUGH+rf70B+CFAg==', 'AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAAAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAACEAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAAstBeAAAAAAoAAAADAAAAAAAAAAAAAAAA', 'AAAAAAAAAAEAAAACAAAAAAAAAAUAAAACAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAAAAACEAAAAAAAAAAVVTRAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAAstBeAAAAAAoAAAADAAAAAAAAAAAAAAAAAAAAAQAAAAUAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAADfhHSlQAAAACAAAAIwAAACMAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA', 'AAAAAQAAAAEAAAAFAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAA34R0pUAAAAAgAAACMAAAACAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==', '{2FwoenXJVOTi9oyWHyNL+0wLRdikDwB4qdNJmj+OQi8a0jRgjQG/1/EsSq885q7mUvX57XCjUGH+rf70B+CFAg==}', 'none', NULL, NULL);


--
-- Name: gorp_migrations gorp_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY gorp_migrations
    ADD CONSTRAINT gorp_migrations_pkey PRIMARY KEY (id);


--
-- Name: history_operation_participants history_operation_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY history_operation_participants
    ADD CONSTRAINT history_operation_participants_pkey PRIMARY KEY (id);


--
-- Name: history_transaction_participants history_transaction_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY history_transaction_participants
    ADD CONSTRAINT history_transaction_participants_pkey PRIMARY KEY (id);


--
-- Name: by_account; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX by_account ON history_transactions USING btree (account, account_sequence);


--
-- Name: by_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX by_hash ON history_transactions USING btree (transaction_hash);


--
-- Name: by_ledger; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX by_ledger ON history_transactions USING btree (ledger_sequence, application_order);


--
-- Name: hist_e_by_order; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX hist_e_by_order ON history_effects USING btree (history_operation_id, "order");


--
-- Name: hist_e_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX hist_e_id ON history_effects USING btree (history_account_id, history_operation_id, "order");


--
-- Name: hist_op_p_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX hist_op_p_id ON history_operation_participants USING btree (history_account_id, history_operation_id);


--
-- Name: hist_tx_p_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX hist_tx_p_id ON history_transaction_participants USING btree (history_account_id, history_transaction_id);


--
-- Name: hop_by_hoid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX hop_by_hoid ON history_operation_participants USING btree (history_operation_id);


--
-- Name: hs_ledger_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX hs_ledger_by_id ON history_ledgers USING btree (id);


--
-- Name: hs_transaction_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX hs_transaction_by_id ON history_transactions USING btree (id);


--
-- Name: htp_by_htid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX htp_by_htid ON history_transaction_participants USING btree (history_transaction_id);


--
-- Name: index_history_accounts_on_address; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_history_accounts_on_address ON history_accounts USING btree (address);


--
-- Name: index_history_accounts_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_history_accounts_on_id ON history_accounts USING btree (id);


--
-- Name: index_history_effects_on_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_history_effects_on_type ON history_effects USING btree (type);


--
-- Name: index_history_ledgers_on_closed_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_history_ledgers_on_closed_at ON history_ledgers USING btree (closed_at);


--
-- Name: index_history_ledgers_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_history_ledgers_on_id ON history_ledgers USING btree (id);


--
-- Name: index_history_ledgers_on_importer_version; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_history_ledgers_on_importer_version ON history_ledgers USING btree (importer_version);


--
-- Name: index_history_ledgers_on_ledger_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_history_ledgers_on_ledger_hash ON history_ledgers USING btree (ledger_hash);


--
-- Name: index_history_ledgers_on_previous_ledger_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_history_ledgers_on_previous_ledger_hash ON history_ledgers USING btree (previous_ledger_hash);


--
-- Name: index_history_ledgers_on_sequence; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_history_ledgers_on_sequence ON history_ledgers USING btree (sequence);


--
-- Name: index_history_operations_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_history_operations_on_id ON history_operations USING btree (id);


--
-- Name: index_history_operations_on_transaction_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_history_operations_on_transaction_id ON history_operations USING btree (transaction_id);


--
-- Name: index_history_operations_on_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_history_operations_on_type ON history_operations USING btree (type);


--
-- Name: index_history_transactions_on_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_history_transactions_on_id ON history_transactions USING btree (id);


--
-- Name: trade_effects_by_order_book; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trade_effects_by_order_book ON history_effects USING btree (((details ->> 'sold_asset_type'::text)), ((details ->> 'sold_asset_code'::text)), ((details ->> 'sold_asset_issuer'::text)), ((details ->> 'bought_asset_type'::text)), ((details ->> 'bought_asset_code'::text)), ((details ->> 'bought_asset_issuer'::text))) WHERE (type = 33);


--
-- PostgreSQL database dump complete
--

