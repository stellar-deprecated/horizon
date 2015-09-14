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
DROP INDEX public.trade_effects_by_order_book;
DROP INDEX public.index_history_transactions_on_id;
DROP INDEX public.index_history_transaction_statuses_lc_on_all;
DROP INDEX public.index_history_transaction_participants_on_transaction_hash;
DROP INDEX public.index_history_transaction_participants_on_account;
DROP INDEX public.index_history_operations_on_type;
DROP INDEX public.index_history_operations_on_transaction_id;
DROP INDEX public.index_history_operations_on_id;
DROP INDEX public.index_history_ledgers_on_sequence;
DROP INDEX public.index_history_ledgers_on_previous_ledger_hash;
DROP INDEX public.index_history_ledgers_on_ledger_hash;
DROP INDEX public.index_history_ledgers_on_importer_version;
DROP INDEX public.index_history_ledgers_on_id;
DROP INDEX public.index_history_ledgers_on_closed_at;
DROP INDEX public.index_history_effects_on_type;
DROP INDEX public.index_history_accounts_on_id;
DROP INDEX public.hs_transaction_by_id;
DROP INDEX public.hs_ledger_by_id;
DROP INDEX public.hist_op_p_id;
DROP INDEX public.hist_e_id;
DROP INDEX public.hist_e_by_order;
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
DROP TABLE public.history_effects;
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
    importer_version integer DEFAULT 1 NOT NULL
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
    max_fee integer NOT NULL,
    fee_paid integer NOT NULL,
    operation_count integer NOT NULL,
    transaction_status_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id bigint,
    tx_envelope text,
    tx_result text,
    tx_meta text
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
0	GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H
8589938689	GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU
8589942785	GA5WBPYA5Y4WAEHXWR2UKO2UO4BUGHUQ74EUPKON2QHV4WRHOIRNKKH2
\.


--
-- Data for Name: history_effects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_effects (history_account_id, history_operation_id, "order", type, details) FROM stdin;
8589938689	8589938689	1	0	{"starting_balance": "1000.0"}
0	8589938689	2	3	{"amount": "1000.0", "asset_type": "native"}
8589938689	8589938689	3	10	{"weight": 2, "public_key": "GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU"}
8589942785	8589942785	1	0	{"starting_balance": "1000.0"}
0	8589942785	2	3	{"amount": "1000.0", "asset_type": "native"}
8589942785	8589942785	3	10	{"weight": 2, "public_key": "GA5WBPYA5Y4WAEHXWR2UKO2UO4BUGHUQ74EUPKON2QHV4WRHOIRNKKH2"}
8589938689	17179873281	1	6	{"auth_required_flag": true}
8589938689	21474840577	1	12	{"weight": 2, "public_key": "GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU"}
8589938689	25769807873	1	4	{"low_threshold": 0, "med_threshold": 2, "high_threshold": 2}
8589938689	30064775169	1	5	{"home_domain": "nullstyle.com"}
8589938689	34359742465	1	10	{"weight": 1, "public_key": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}
8589938689	38654709761	1	10	{"weight": 5, "public_key": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}
8589938689	42949677057	1	6	{"auth_required_flag": false}
8589938689	47244644353	1	11	{"weight": 0, "public_key": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4"}
\.


--
-- Data for Name: history_ledgers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_ledgers (sequence, ledger_hash, previous_ledger_hash, transaction_count, operation_count, closed_at, created_at, updated_at, id, importer_version) FROM stdin;
1	5ade5048fb66795219cbb45a55bf5e2710f739610d10e6875bf7f85d85900669	\N	0	0	1970-01-01 00:00:00	2015-09-14 15:40:36.14926	2015-09-14 15:40:36.14926	4294967296	1
2	ce8002bbd302e2a6fe45a21ff04a371e97035f74ee21d0c47d7277d17d22a161	5ade5048fb66795219cbb45a55bf5e2710f739610d10e6875bf7f85d85900669	2	2	2015-09-14 15:40:34	2015-09-14 15:40:36.161072	2015-09-14 15:40:36.161072	8589934592	1
3	b672807b38125a1d00d58b6a38f9bab1a8912470fb3d87855503d18df0ecb843	ce8002bbd302e2a6fe45a21ff04a371e97035f74ee21d0c47d7277d17d22a161	1	1	2015-09-14 15:40:35	2015-09-14 15:40:36.226512	2015-09-14 15:40:36.226512	12884901888	1
4	c8931d5fe22b256a23309e21f510dbbcb99a095d6f0f47d3db62fafe98c304b0	b672807b38125a1d00d58b6a38f9bab1a8912470fb3d87855503d18df0ecb843	1	1	2015-09-14 15:40:36	2015-09-14 15:40:36.243954	2015-09-14 15:40:36.243954	17179869184	1
5	503d782c90922cd52e0687c2cf4894289dc2a5f3c089b6fdb71754a806f9c177	c8931d5fe22b256a23309e21f510dbbcb99a095d6f0f47d3db62fafe98c304b0	1	1	2015-09-14 15:40:37	2015-09-14 15:40:36.26437	2015-09-14 15:40:36.26437	21474836480	1
6	cd5e935959d1068e8cd70aa142944416c58b257a80b455f96cefefd146666a84	503d782c90922cd52e0687c2cf4894289dc2a5f3c089b6fdb71754a806f9c177	1	1	2015-09-14 15:40:38	2015-09-14 15:40:36.284714	2015-09-14 15:40:36.284714	25769803776	1
7	d258f7ae0d0a653ffabed20d94074b121973e8e1004a7cfd3af2a12e2ab73d10	cd5e935959d1068e8cd70aa142944416c58b257a80b455f96cefefd146666a84	1	1	2015-09-14 15:40:39	2015-09-14 15:40:36.305579	2015-09-14 15:40:36.305579	30064771072	1
8	79a8ff63e6e3cfc193a1474a2bc4250d363a851022e160ec6a0a4ecb5dcaed6e	d258f7ae0d0a653ffabed20d94074b121973e8e1004a7cfd3af2a12e2ab73d10	1	1	2015-09-14 15:40:40	2015-09-14 15:40:36.325636	2015-09-14 15:40:36.325636	34359738368	1
9	ad8f9f41583a7c9897e45b2fa6ddf2a75d87961fba41c01d4072cd36255f1e3b	79a8ff63e6e3cfc193a1474a2bc4250d363a851022e160ec6a0a4ecb5dcaed6e	1	1	2015-09-14 15:40:41	2015-09-14 15:40:36.344134	2015-09-14 15:40:36.344134	38654705664	1
10	ee005c6dcc6985dd5eed8ea88b9e0d2a5a44721ccd619ee33395085dcd34844e	ad8f9f41583a7c9897e45b2fa6ddf2a75d87961fba41c01d4072cd36255f1e3b	1	1	2015-09-14 15:40:42	2015-09-14 15:40:36.370276	2015-09-14 15:40:36.370276	42949672960	1
11	595db732de66a51ea1b601539d5fdbcb47a76939456917f5dbd20d5352c852e5	ee005c6dcc6985dd5eed8ea88b9e0d2a5a44721ccd619ee33395085dcd34844e	1	1	2015-09-14 15:40:43	2015-09-14 15:40:36.390234	2015-09-14 15:40:36.390234	47244640256	1
12	71cb46bba93f412742d9d9da13eb114b917d432d1da632e37f875191abbf4934	595db732de66a51ea1b601539d5fdbcb47a76939456917f5dbd20d5352c852e5	0	0	2015-09-14 15:40:44	2015-09-14 15:40:36.410405	2015-09-14 15:40:36.410405	51539607552	1
\.


--
-- Data for Name: history_operation_participants; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_operation_participants (id, history_operation_id, history_account_id) FROM stdin;
205	8589938689	0
206	8589938689	8589938689
207	8589942785	0
208	8589942785	8589942785
209	12884905985	8589938689
210	17179873281	8589938689
211	21474840577	8589938689
212	25769807873	8589938689
213	30064775169	8589938689
214	34359742465	8589938689
215	38654709761	8589938689
216	42949677057	8589938689
217	47244644353	8589938689
\.


--
-- Name: history_operation_participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('history_operation_participants_id_seq', 217, true);


--
-- Data for Name: history_operations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_operations (id, transaction_id, application_order, type, details) FROM stdin;
8589938689	8589938688	1	0	{"funder": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "account": "GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU", "starting_balance": "1000.0"}
8589942785	8589942784	1	0	{"funder": "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H", "account": "GA5WBPYA5Y4WAEHXWR2UKO2UO4BUGHUQ74EUPKON2QHV4WRHOIRNKKH2", "starting_balance": "1000.0"}
12884905985	12884905984	1	5	{"inflation_dest": "GA5WBPYA5Y4WAEHXWR2UKO2UO4BUGHUQ74EUPKON2QHV4WRHOIRNKKH2"}
17179873281	17179873280	1	5	{"set_flags": [1], "set_flags_s": ["auth_required_flag"]}
21474840577	21474840576	1	5	{"master_key_weight": 2}
25769807873	25769807872	1	5	{"low_threshold": 0, "med_threshold": 2, "high_threshold": 2}
30064775169	30064775168	1	5	{"home_domain": "nullstyle.com"}
34359742465	34359742464	1	5	{"signer_key": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4", "signer_weight": 1}
38654709761	38654709760	1	5	{"signer_key": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4", "signer_weight": 5}
42949677057	42949677056	1	5	{"clear_flags": [1], "clear_flags_s": ["auth_required_flag"]}
47244644353	47244644352	1	5	{"signer_key": "GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4", "signer_weight": 0}
\.


--
-- Data for Name: history_transaction_participants; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_transaction_participants (id, transaction_hash, account, created_at, updated_at) FROM stdin;
187	c502e5f9e7039113e759e6f6f03e9a505b603050d226281616ead224687bb341	GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H	2015-09-14 15:40:36.166256	2015-09-14 15:40:36.166256
188	c502e5f9e7039113e759e6f6f03e9a505b603050d226281616ead224687bb341	GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU	2015-09-14 15:40:36.167562	2015-09-14 15:40:36.167562
189	233b91f42160232ba585a7f3b8a40bf6fce087232368b25efb91050d0aa0d631	GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H	2015-09-14 15:40:36.195211	2015-09-14 15:40:36.195211
190	233b91f42160232ba585a7f3b8a40bf6fce087232368b25efb91050d0aa0d631	GA5WBPYA5Y4WAEHXWR2UKO2UO4BUGHUQ74EUPKON2QHV4WRHOIRNKKH2	2015-09-14 15:40:36.197054	2015-09-14 15:40:36.197054
191	04b208c35cdea084e66c1ba0e5ad5326114b9b50a99b5597287335b3584bcd69	GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU	2015-09-14 15:40:36.230959	2015-09-14 15:40:36.230959
192	c997d6e4187037794ebfd2b2be797d5f1885b4699b6aad361aacfc622bb3178d	GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU	2015-09-14 15:40:36.24855	2015-09-14 15:40:36.24855
193	fdeb7a49724f4c0cbb0d36a5670d2259ef6462187ccb2434241f4aa075341ad7	GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU	2015-09-14 15:40:36.268682	2015-09-14 15:40:36.268682
194	3bd6d8e7ec47b88cc36306e6e36369a2557b000207b3ac4703e3545ea8aa743b	GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU	2015-09-14 15:40:36.28922	2015-09-14 15:40:36.28922
195	cf00bee9d8e0ac590853cacace7a7696f4a46aa10561acce0df67faf8c3014a8	GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU	2015-09-14 15:40:36.310433	2015-09-14 15:40:36.310433
196	3085e341f9dfbf33af6d46e2f52ab5c1e40ad27b0a7bb52582e03b48488eded6	GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU	2015-09-14 15:40:36.329605	2015-09-14 15:40:36.329605
197	200e7ec45d463685358491b2b40e4404df022e5d64e1ff0a0802ed3cb7fd71d9	GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU	2015-09-14 15:40:36.348104	2015-09-14 15:40:36.348104
198	b6ab876aba16c873634f9fb4f330dfd1369c7811daefbd91a4761ab420dea164	GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU	2015-09-14 15:40:36.37444	2015-09-14 15:40:36.37444
199	a231960781a8822ef4a32ce714c3a231f195ec34fad46cc296ba3cea55659436	GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU	2015-09-14 15:40:36.394534	2015-09-14 15:40:36.394534
\.


--
-- Name: history_transaction_participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('history_transaction_participants_id_seq', 199, true);


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

COPY history_transactions (transaction_hash, ledger_sequence, application_order, account, account_sequence, max_fee, fee_paid, operation_count, transaction_status_id, created_at, updated_at, id, tx_envelope, tx_result, tx_meta) FROM stdin;
04b208c35cdea084e66c1ba0e5ad5326114b9b50a99b5597287335b3584bcd69	3	1	GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU	8589934593	0	0	1	-1	2015-09-14 15:40:36.229004	2015-09-14 15:40:36.229004	12884905984	AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAACgAAAAIAAAABAAAAAAAAAAAAAAABAAAAAAAAAAUAAAABAAAAADtgvwDuOWAQ97R1RTtUdwNDHpD/CUepzdQPXlonciLVAAAAAQAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABruS+TAAAAEAj8SX0e6VBpvT0BZxgnXwHbpE4g/ZDs5t1kUrnZHEU3opDe5tBG8dBJSnc1I/gnewcCDrU/ARtBf7mo20OztgD	BLIIw1zeoITmbBug5a1TJhFLm1Cpm1WXKHM1s1hLzWkAAAAAAAAACgAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAA==	AAAAAAAAAAEAAAABAAAAAwAAAAAAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAACVAvj9gAAAAIAAAABAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAABAAAAAQAAAAEAAAADAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAAJUC+P2AAAAAgAAAAEAAAAAAAAAAQAAAAA7YL8A7jlgEPe0dUU7VHcDQx6Q/wlHqc3UD15aJ3Ii1QAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==
c997d6e4187037794ebfd2b2be797d5f1885b4699b6aad361aacfc622bb3178d	4	1	GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU	8589934594	0	0	1	-1	2015-09-14 15:40:36.246546	2015-09-14 15:40:36.246546	17179873280	AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAACgAAAAIAAAACAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABruS+TAAAAEDeowCAMfWkYHEBTuD0w0glGCT+Wc/L+VwjU49isD+ic3sXvL+mtFhJm2vhSiL1l1jZZUAFwNEPtgHQizKHBIsF	yZfW5BhwN3lOv9Kyvnl9XxiFtGmbaq02Gqz8YiuzF40AAAAAAAAACgAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAA==	AAAAAAAAAAEAAAABAAAABAAAAAAAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAACVAvj7AAAAAIAAAACAAAAAAAAAAEAAAAAO2C/AO45YBD3tHVFO1R3A0MekP8JR6nN1A9eWidyItUAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAABAAAAAQAAAAEAAAAEAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAAJUC+PsAAAAAgAAAAIAAAAAAAAAAQAAAAA7YL8A7jlgEPe0dUU7VHcDQx6Q/wlHqc3UD15aJ3Ii1QAAAAEAAAAAAQAAAAAAAAAAAAAAAAAAAA==
c502e5f9e7039113e759e6f6f03e9a505b603050d226281616ead224687bb341	2	1	GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H	1	0	0	1	-1	2015-09-14 15:40:36.1638	2015-09-14 15:40:36.1638	8589938688	AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAACgAAAAAAAAABAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAACVAvkAAAAAAAAAAABVvwF9wAAAEAyLaR2fVgILqGaCBqUVNeDZLkdLHhTwdgGWEdd+j3h+YWEJsAf5NDUck1E4tqwwtOfAG55xlF5whQIJfOzup8D	xQLl+ecDkRPnWeb28D6aUFtgMFDSJigWFurSJGh7s0EAAAAAAAAACgAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==	AAAAAAAAAAEAAAABAAAAAgAAAAAAAAAAYvwdC9CRsrYcDdZWNGsqaNfTR8bywsjubQRHAlb8BfcBY0V4XYn/9gAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAABAAAAAgAAAAAAAAACAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAAJUC+QAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAACAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wFjRXYJfhv2AAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==
233b91f42160232ba585a7f3b8a40bf6fce087232368b25efb91050d0aa0d631	2	2	GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H	2	0	0	1	-1	2015-09-14 15:40:36.191991	2015-09-14 15:40:36.191991	8589942784	AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAACgAAAAAAAAACAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAO2C/AO45YBD3tHVFO1R3A0MekP8JR6nN1A9eWidyItUAAAACVAvkAAAAAAAAAAABVvwF9wAAAEBKgdS7Vvjozk3v+LhcvS8HmmdK6EytK/oybUkROkB9qw5tI2C8fUyHaIzTDCazLhOTococ5eulq91j3OrvVpUF	IzuR9CFgIyulhafzuKQL9vzghyMjaLJe+5EFDQqg1jEAAAAAAAAACgAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==	AAAAAAAAAAEAAAABAAAAAgAAAAAAAAAAYvwdC9CRsrYcDdZWNGsqaNfTR8bywsjubQRHAlb8BfcBY0V2CX4b7AAAAAAAAAACAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAABAAAAAgAAAAAAAAACAAAAAAAAAAA7YL8A7jlgEPe0dUU7VHcDQx6Q/wlHqc3UD15aJ3Ii1QAAAAJUC+QAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAACAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9wFjRXO1cjfsAAAAAAAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==
fdeb7a49724f4c0cbb0d36a5670d2259ef6462187ccb2434241f4aa075341ad7	5	1	GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU	8589934595	0	0	1	-1	2015-09-14 15:40:36.266797	2015-09-14 15:40:36.266797	21474840576	AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAACgAAAAIAAAADAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAEAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAa7kvkwAAABAEJmVJo1j1vNodZFZjPqHcUtPVb2BUIPsA4Xn24EyEqP2Vi+wNU5ZIJG8T9D3fAmABCAv3bqsowPDRxMd9JdrAQ==	/et6SXJPTAy7DTalZw0iWe9kYhh8yyQ0JB9KoHU0GtcAAAAAAAAACgAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAA==	AAAAAAAAAAEAAAABAAAABQAAAAAAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAACVAvj4gAAAAIAAAADAAAAAAAAAAEAAAAAO2C/AO45YBD3tHVFO1R3A0MekP8JR6nN1A9eWidyItUAAAABAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAABAAAAAQAAAAEAAAAFAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAAJUC+PiAAAAAgAAAAMAAAAAAAAAAQAAAAA7YL8A7jlgEPe0dUU7VHcDQx6Q/wlHqc3UD15aJ3Ii1QAAAAEAAAAAAgAAAAAAAAAAAAAAAAAAAA==
3bd6d8e7ec47b88cc36306e6e36369a2557b000207b3ac4703e3545ea8aa743b	6	1	GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU	8589934596	0	0	1	-1	2015-09-14 15:40:36.287242	2015-09-14 15:40:36.287242	25769807872	AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAACgAAAAIAAAAEAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAAAAAABAAAAAAAAAAEAAAACAAAAAQAAAAIAAAAAAAAAAAAAAAAAAAABruS+TAAAAEDjSE+jZXkHQ4zCa862Dah5FA9jy/7Stp6+Q/3NUrR91k7akobifwYDYWQ0166Q1Ndp+zq1bL+9aniYF4CMi4gC	O9bY5+xHuIzDYwbm42NpolV7AAIHs6xHA+NUXqiqdDsAAAAAAAAACgAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAA==	AAAAAAAAAAEAAAABAAAABgAAAAAAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAACVAvj2AAAAAIAAAAEAAAAAAAAAAEAAAAAO2C/AO45YBD3tHVFO1R3A0MekP8JR6nN1A9eWidyItUAAAABAAAAAAIAAAAAAAAAAAAAAAAAAAAAAAABAAAAAQAAAAEAAAAGAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAAJUC+PYAAAAAgAAAAQAAAAAAAAAAQAAAAA7YL8A7jlgEPe0dUU7VHcDQx6Q/wlHqc3UD15aJ3Ii1QAAAAEAAAAAAgACAgAAAAAAAAAAAAAAAA==
cf00bee9d8e0ac590853cacace7a7696f4a46aa10561acce0df67faf8c3014a8	7	1	GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU	8589934597	0	0	1	-1	2015-09-14 15:40:36.308295	2015-09-14 15:40:36.308295	30064775168	AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAACgAAAAIAAAAFAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAADW51bGxzdHlsZS5jb20AAAAAAAAAAAAAAAAAAAGu5L5MAAAAQBffi1g7gwdZ07+o/JgewKaLHadDeRL1nmQmuw7cp8ER/3XL/p/2uQQteKnGO3F/saogD/IBLa6HahFq6jGqYAk=	zwC+6djgrFkIU8rKznp2lvSkaqEFYazODfZ/r4wwFKgAAAAAAAAACgAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAA==	AAAAAAAAAAEAAAABAAAABwAAAAAAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAACVAvjzgAAAAIAAAAFAAAAAAAAAAEAAAAAO2C/AO45YBD3tHVFO1R3A0MekP8JR6nN1A9eWidyItUAAAABAAAAAAIAAgIAAAAAAAAAAAAAAAAAAAABAAAAAQAAAAEAAAAHAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAAJUC+POAAAAAgAAAAUAAAAAAAAAAQAAAAA7YL8A7jlgEPe0dUU7VHcDQx6Q/wlHqc3UD15aJ3Ii1QAAAAEAAAANbnVsbHN0eWxlLmNvbQAAAAIAAgIAAAAAAAAAAAAAAAA=
3085e341f9dfbf33af6d46e2f52ab5c1e40ad27b0a7bb52582e03b48488eded6	8	1	GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU	8589934598	0	0	1	-1	2015-09-14 15:40:36.32792	2015-09-14 15:40:36.32792	34359742464	AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAACgAAAAIAAAAGAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt7wAAAAEAAAAAAAAAAa7kvkwAAABA47f+3OKM6OgG0emuVh4l/Kcx5062smpg3NIcWNjCzi20UmPBiwUfzTqXzmmzTI4QjX0DjMRKjVHSskSFVzn8AQ==	MIXjQfnfvzOvbUbi9Sq1weQK0nsKe7UlguA7SEiO3tYAAAAAAAAACgAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAA==	AAAAAAAAAAEAAAABAAAACAAAAAAAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAACVAvjxAAAAAIAAAAGAAAAAAAAAAEAAAAAO2C/AO45YBD3tHVFO1R3A0MekP8JR6nN1A9eWidyItUAAAABAAAADW51bGxzdHlsZS5jb20AAAACAAICAAAAAAAAAAAAAAAAAAAAAQAAAAEAAAABAAAACAAAAAAAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAACVAvjxAAAAAIAAAAGAAAAAQAAAAEAAAAAO2C/AO45YBD3tHVFO1R3A0MekP8JR6nN1A9eWidyItUAAAABAAAADW51bGxzdHlsZS5jb20AAAACAAICAAAAAQAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt7wAAAAEAAAAAAAAAAA==
200e7ec45d463685358491b2b40e4404df022e5d64e1ff0a0802ed3cb7fd71d9	9	1	GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU	8589934599	0	0	1	-1	2015-09-14 15:40:36.346306	2015-09-14 15:40:36.346306	38654709760	AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAACgAAAAIAAAAHAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt7wAAAAUAAAAAAAAAAa7kvkwAAABAyv/O6Z1tfEBXS+yEOgankEmDBaid24gife+ZV4yt24SRwwFdk5ulgIHxftqdHQ2XdA5EKnBsfErkDG6DlY1qAg==	IA5+xF1GNoU1hJGytA5EBN8CLl1k4f8KCALtPLf9cdkAAAAAAAAACgAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAA==	AAAAAAAAAAEAAAABAAAACQAAAAAAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAACVAvjugAAAAIAAAAHAAAAAQAAAAEAAAAAO2C/AO45YBD3tHVFO1R3A0MekP8JR6nN1A9eWidyItUAAAABAAAADW51bGxzdHlsZS5jb20AAAACAAICAAAAAQAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt7wAAAAEAAAAAAAAAAAAAAAEAAAABAAAAAQAAAAkAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAlQL47oAAAACAAAABwAAAAEAAAABAAAAADtgvwDuOWAQ97R1RTtUdwNDHpD/CUepzdQPXlonciLVAAAAAQAAAA1udWxsc3R5bGUuY29tAAAAAgACAgAAAAEAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAFAAAAAAAAAAA=
b6ab876aba16c873634f9fb4f330dfd1369c7811daefbd91a4761ab420dea164	10	1	GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU	8589934600	0	0	1	-1	2015-09-14 15:40:36.372533	2015-09-14 15:40:36.372533	42949677056	AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAACgAAAAIAAAAIAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAEAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABruS+TAAAAECMkVgdcr1lYL0ud1Me0pkgsK3mSeeMa3ue7B8uEMSahjUaQhgDDLz4jcQGLMusJbRWhUS0YFKoDb1fE+/HdFMP	tquHaroWyHNjT5+08zDf0TaceBHa772RpHYatCDeoWQAAAAAAAAACgAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAA==	AAAAAAAAAAEAAAABAAAACgAAAAAAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAACVAvjsAAAAAIAAAAIAAAAAQAAAAEAAAAAO2C/AO45YBD3tHVFO1R3A0MekP8JR6nN1A9eWidyItUAAAABAAAADW51bGxzdHlsZS5jb20AAAACAAICAAAAAQAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt7wAAAAUAAAAAAAAAAAAAAAEAAAABAAAAAQAAAAoAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAlQL47AAAAACAAAACAAAAAEAAAABAAAAADtgvwDuOWAQ97R1RTtUdwNDHpD/CUepzdQPXlonciLVAAAAAAAAAA1udWxsc3R5bGUuY29tAAAAAgACAgAAAAEAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAAFAAAAAAAAAAA=
a231960781a8822ef4a32ce714c3a231f195ec34fad46cc296ba3cea55659436	11	1	GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU	8589934601	0	0	1	-1	2015-09-14 15:40:36.392652	2015-09-14 15:40:36.392652	47244644352	AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAACgAAAAIAAAAJAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt7wAAAAAAAAAAAAAAAa7kvkwAAABAzk/q3zRROZ9L8yXb18qkhm7/1nX4VmUAKgms3tV7DJ4JrF5x2Mch5RPvQIgCV/hU32RvGvqTP/zYMQew0YckBQ==	ojGWB4Gogi70oyznFMOiMfGV7DT61GzClro86lVllDYAAAAAAAAACgAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAA==	AAAAAAAAAAEAAAABAAAACwAAAAAAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAACVAvjpgAAAAIAAAAJAAAAAQAAAAEAAAAAO2C/AO45YBD3tHVFO1R3A0MekP8JR6nN1A9eWidyItUAAAAAAAAADW51bGxzdHlsZS5jb20AAAACAAICAAAAAQAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt7wAAAAUAAAAAAAAAAAAAAAEAAAABAAAAAQAAAAsAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAlQL46YAAAACAAAACQAAAAAAAAABAAAAADtgvwDuOWAQ97R1RTtUdwNDHpD/CUepzdQPXlonciLVAAAAAAAAAA1udWxsc3R5bGUuY29tAAAAAgACAgAAAAAAAAAAAAAAAA==
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY schema_migrations (version) FROM stdin;
20150508215546
20150310224849
20150313225945
20150313225955
20150501160031
20150508003829
20150508175821
20150508183542
20150609230237
20150629181921
20150825223417
20150825180131
20150902224148
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
-- Name: public; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM nullstyle;
GRANT ALL ON SCHEMA public TO nullstyle;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

