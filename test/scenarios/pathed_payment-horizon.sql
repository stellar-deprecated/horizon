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
    details hstore
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
12884910080	gsDu9aPmZy7uH5FzmfJKW7jWyXGHjSWbcb8k6UH743pYzaxWcWd
12884914176	gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ
12884918272	gT9jHoPKoErFwXavCrDYLkSVcVd9oyVv94ydrq6FnPMXpKHPTA
12884922368	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ
\.


--
-- Data for Name: history_ledgers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_ledgers (sequence, ledger_hash, previous_ledger_hash, transaction_count, operation_count, closed_at, created_at, updated_at, id) FROM stdin;
1	41310a0181a3a82ff13c049369504e978734cf17da1baf02f7e4d881e8608371	\N	0	0	1970-01-01 00:00:00	2015-05-10 17:36:43.192021	2015-05-10 17:36:43.192021	4294967296
2	caa48be035d0bc5109ac4a6cfe83949b339c7799dc9d12439012ec52999d3bee	41310a0181a3a82ff13c049369504e978734cf17da1baf02f7e4d881e8608371	0	0	2015-05-10 17:36:41	2015-05-10 17:36:43.201125	2015-05-10 17:36:43.201125	8589934592
3	221f151b5169184bd61aee56a6b86c0b614524f26604fe0432aca2dfe0fc8ae8	caa48be035d0bc5109ac4a6cfe83949b339c7799dc9d12439012ec52999d3bee	0	0	2015-05-10 17:36:42	2015-05-10 17:36:43.209822	2015-05-10 17:36:43.209822	12884901888
4	37d7fa4b2b03f18bbf15f873f615e6f08b2d7c79e632c578d656c389f4a645ee	221f151b5169184bd61aee56a6b86c0b614524f26604fe0432aca2dfe0fc8ae8	0	0	2015-05-10 17:36:43	2015-05-10 17:36:43.290565	2015-05-10 17:36:43.290565	17179869184
5	8532019026b83e5df0f5c4b825ee643135f86ea354739c8c57eb26024c75b6ff	37d7fa4b2b03f18bbf15f873f615e6f08b2d7c79e632c578d656c389f4a645ee	0	0	2015-05-10 17:36:44	2015-05-10 17:36:43.337767	2015-05-10 17:36:43.337767	21474836480
6	3e7d7464ef21bb1c1202fa531c6d961e30598a6391e75300575a203dc317e7d4	8532019026b83e5df0f5c4b825ee643135f86ea354739c8c57eb26024c75b6ff	0	0	2015-05-10 17:36:45	2015-05-10 17:36:43.387508	2015-05-10 17:36:43.387508	25769803776
7	f764231c6726a21b4d64eeb437ce28405c61e204bab801e7807f80054d20e506	3e7d7464ef21bb1c1202fa531c6d961e30598a6391e75300575a203dc317e7d4	0	0	2015-05-10 17:36:46	2015-05-10 17:36:43.408021	2015-05-10 17:36:43.408021	30064771072
\.


--
-- Data for Name: history_operation_participants; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_operation_participants (id, history_operation_id, history_account_id) FROM stdin;
21	12884905984	0
22	12884905984	12884905984
23	12884910080	0
24	12884910080	12884910080
25	12884914176	0
26	12884914176	12884914176
27	12884918272	0
28	12884918272	12884918272
29	12884922368	0
30	12884922368	12884922368
31	17179873280	12884918272
32	17179877376	12884914176
33	17179881472	12884922368
34	17179885568	12884922368
35	21474840576	12884905984
36	21474840576	12884914176
37	21474844672	12884910080
38	21474844672	12884922368
39	21474848768	12884910080
40	21474848768	12884918272
41	21474852864	12884905984
42	21474852864	12884922368
43	25769807872	12884922368
44	30064775168	12884914176
45	30064775168	12884918272
\.


--
-- Name: history_operation_participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('history_operation_participants_id_seq', 45, true);


--
-- Data for Name: history_operations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_operations (id, transaction_id, application_order, type, details) FROM stdin;
12884905984	12884905984	0	0	"to"=>"gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq", "from"=>"gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC", "amount"=>"1000000000", "currency_code"=>"XLM"
12884910080	12884910080	0	0	"to"=>"gsDu9aPmZy7uH5FzmfJKW7jWyXGHjSWbcb8k6UH743pYzaxWcWd", "from"=>"gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC", "amount"=>"1000000000", "currency_code"=>"XLM"
12884914176	12884914176	0	0	"to"=>"gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ", "from"=>"gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC", "amount"=>"1000000000", "currency_code"=>"XLM"
12884918272	12884918272	0	0	"to"=>"gT9jHoPKoErFwXavCrDYLkSVcVd9oyVv94ydrq6FnPMXpKHPTA", "from"=>"gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC", "amount"=>"1000000000", "currency_code"=>"XLM"
12884922368	12884922368	0	0	"to"=>"gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ", "from"=>"gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC", "amount"=>"1000000000", "currency_code"=>"XLM"
17179873280	17179873280	0	3	\N
17179877376	17179877376	0	3	\N
17179881472	17179881472	0	3	\N
17179885568	17179885568	0	3	\N
21474840576	21474840576	0	0	"to"=>"gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ", "from"=>"gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq", "amount"=>"1000000000", "currency_code"=>"USD", "currency_issuer"=>"gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq"
21474844672	21474844672	0	0	"to"=>"gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ", "from"=>"gsDu9aPmZy7uH5FzmfJKW7jWyXGHjSWbcb8k6UH743pYzaxWcWd", "amount"=>"200000000", "currency_code"=>"EUR", "currency_issuer"=>"gsDu9aPmZy7uH5FzmfJKW7jWyXGHjSWbcb8k6UH743pYzaxWcWd"
21474848768	21474848768	0	0	"to"=>"gT9jHoPKoErFwXavCrDYLkSVcVd9oyVv94ydrq6FnPMXpKHPTA", "from"=>"gsDu9aPmZy7uH5FzmfJKW7jWyXGHjSWbcb8k6UH743pYzaxWcWd", "amount"=>"1000000000", "currency_code"=>"EUR", "currency_issuer"=>"gsDu9aPmZy7uH5FzmfJKW7jWyXGHjSWbcb8k6UH743pYzaxWcWd"
21474852864	21474852864	0	0	"to"=>"gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ", "from"=>"gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq", "amount"=>"200000000", "currency_code"=>"USD", "currency_issuer"=>"gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq"
25769807872	25769807872	0	1	\N
30064775168	30064775168	0	0	"to"=>"gT9jHoPKoErFwXavCrDYLkSVcVd9oyVv94ydrq6FnPMXpKHPTA", "from"=>"gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ", "amount"=>"10", "currency_code"=>"EUR", "currency_issuer"=>"gsDu9aPmZy7uH5FzmfJKW7jWyXGHjSWbcb8k6UH743pYzaxWcWd"
\.


--
-- Data for Name: history_transaction_participants; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_transaction_participants (id, transaction_hash, account, created_at, updated_at) FROM stdin;
19	5f43d0b85870aad5e31ecdcb4510ddee3e532f90423f00efaae18fc7b0921296	gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq	2015-05-10 17:36:43.215721	2015-05-10 17:36:43.215721
20	5f43d0b85870aad5e31ecdcb4510ddee3e532f90423f00efaae18fc7b0921296	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2015-05-10 17:36:43.217109	2015-05-10 17:36:43.217109
21	bb8d37f8b8c19a0a48b20a1572ed24c7aac6d4601be98eec24bf1658e07f0417	gsDu9aPmZy7uH5FzmfJKW7jWyXGHjSWbcb8k6UH743pYzaxWcWd	2015-05-10 17:36:43.230188	2015-05-10 17:36:43.230188
22	bb8d37f8b8c19a0a48b20a1572ed24c7aac6d4601be98eec24bf1658e07f0417	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2015-05-10 17:36:43.231076	2015-05-10 17:36:43.231076
23	3e049c19427b65afc50dd9e711fbad0807ed9b875d859feed447c2761ac7d05f	gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	2015-05-10 17:36:43.24238	2015-05-10 17:36:43.24238
24	3e049c19427b65afc50dd9e711fbad0807ed9b875d859feed447c2761ac7d05f	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2015-05-10 17:36:43.243342	2015-05-10 17:36:43.243342
25	43c19bbf9170c058de29f5643a3f41f9bd19c0cfb4b6ccc310d0cf2e999722d2	gT9jHoPKoErFwXavCrDYLkSVcVd9oyVv94ydrq6FnPMXpKHPTA	2015-05-10 17:36:43.255469	2015-05-10 17:36:43.255469
26	43c19bbf9170c058de29f5643a3f41f9bd19c0cfb4b6ccc310d0cf2e999722d2	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2015-05-10 17:36:43.256318	2015-05-10 17:36:43.256318
27	a6c1ca1fb651e0c045b1b7e632bce0e032c1d3f64c86cba90ea1923787394a77	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ	2015-05-10 17:36:43.269138	2015-05-10 17:36:43.269138
28	a6c1ca1fb651e0c045b1b7e632bce0e032c1d3f64c86cba90ea1923787394a77	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2015-05-10 17:36:43.27017	2015-05-10 17:36:43.27017
29	b6b8fb7e5fea0cc43d76ba49e39044a5777b1ecebeefbd406cb56af89df64fc3	gT9jHoPKoErFwXavCrDYLkSVcVd9oyVv94ydrq6FnPMXpKHPTA	2015-05-10 17:36:43.296985	2015-05-10 17:36:43.296985
30	e57382a5b04b9097bb946690fceb30dde144d24bdb6a9ba4af6298d00ddc6db2	gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	2015-05-10 17:36:43.307288	2015-05-10 17:36:43.307288
31	bf0a65e79c8cb7fe9617eafccc25b976c2702bb524f7e3f6c1fbd130f14964ce	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ	2015-05-10 17:36:43.315671	2015-05-10 17:36:43.315671
32	33bd683964d7650acdd5717d0d7f91f52463d297b5b7385b7365b8d6c50aa0ac	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ	2015-05-10 17:36:43.325188	2015-05-10 17:36:43.325188
33	4bf5deda27d85b2a7001dc4d143c402dee08a16725a0973c83bd68317e9232af	gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq	2015-05-10 17:36:43.343394	2015-05-10 17:36:43.343394
34	a484f70456e76beb8a678bda05adaf18dfe5bcb6a286c69da48d247a0126e91a	gsDu9aPmZy7uH5FzmfJKW7jWyXGHjSWbcb8k6UH743pYzaxWcWd	2015-05-10 17:36:43.35281	2015-05-10 17:36:43.35281
35	e7ea3c40c43e2f0d49851e9930652e16f4461c934654ab23a76aff83886eba60	gsDu9aPmZy7uH5FzmfJKW7jWyXGHjSWbcb8k6UH743pYzaxWcWd	2015-05-10 17:36:43.362168	2015-05-10 17:36:43.362168
36	69beaf62a65ac96ef4c8f0bb300ae949f99f3bfcc4ade707b7e8ed6fa79617cf	gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq	2015-05-10 17:36:43.373079	2015-05-10 17:36:43.373079
37	5f79e48cf2fdf04076e9c8e59fe2e67564d447f38a2e0fda2df9326d2135191a	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ	2015-05-10 17:36:43.392089	2015-05-10 17:36:43.392089
38	1b9649dde9f45ddc8dd0eeaf7656eb29799ebcdab7ef75c8ce5d213462af9513	gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	2015-05-10 17:36:43.414081	2015-05-10 17:36:43.414081
\.


--
-- Name: history_transaction_participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('history_transaction_participants_id_seq', 38, true);


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
5f43d0b85870aad5e31ecdcb4510ddee3e532f90423f00efaae18fc7b0921296	3	1	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	1	10	10	1	-1	2015-05-10 17:36:43.213429	2015-05-10 17:36:43.213429	12884905984
bb8d37f8b8c19a0a48b20a1572ed24c7aac6d4601be98eec24bf1658e07f0417	3	2	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2	10	10	1	-1	2015-05-10 17:36:43.228579	2015-05-10 17:36:43.228579	12884910080
3e049c19427b65afc50dd9e711fbad0807ed9b875d859feed447c2761ac7d05f	3	3	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	3	10	10	1	-1	2015-05-10 17:36:43.240652	2015-05-10 17:36:43.240652	12884914176
43c19bbf9170c058de29f5643a3f41f9bd19c0cfb4b6ccc310d0cf2e999722d2	3	4	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	4	10	10	1	-1	2015-05-10 17:36:43.253755	2015-05-10 17:36:43.253755	12884918272
a6c1ca1fb651e0c045b1b7e632bce0e032c1d3f64c86cba90ea1923787394a77	3	5	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	5	10	10	1	-1	2015-05-10 17:36:43.267202	2015-05-10 17:36:43.267202	12884922368
b6b8fb7e5fea0cc43d76ba49e39044a5777b1ecebeefbd406cb56af89df64fc3	4	1	gT9jHoPKoErFwXavCrDYLkSVcVd9oyVv94ydrq6FnPMXpKHPTA	12884901889	10	10	1	-1	2015-05-10 17:36:43.294972	2015-05-10 17:36:43.294972	17179873280
e57382a5b04b9097bb946690fceb30dde144d24bdb6a9ba4af6298d00ddc6db2	4	2	gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	12884901889	10	10	1	-1	2015-05-10 17:36:43.305669	2015-05-10 17:36:43.305669	17179877376
bf0a65e79c8cb7fe9617eafccc25b976c2702bb524f7e3f6c1fbd130f14964ce	4	3	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ	12884901889	10	10	1	-1	2015-05-10 17:36:43.314148	2015-05-10 17:36:43.314148	17179881472
33bd683964d7650acdd5717d0d7f91f52463d297b5b7385b7365b8d6c50aa0ac	4	4	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ	12884901890	10	10	1	-1	2015-05-10 17:36:43.323631	2015-05-10 17:36:43.323631	17179885568
4bf5deda27d85b2a7001dc4d143c402dee08a16725a0973c83bd68317e9232af	5	1	gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq	12884901889	10	10	1	-1	2015-05-10 17:36:43.341796	2015-05-10 17:36:43.341796	21474840576
a484f70456e76beb8a678bda05adaf18dfe5bcb6a286c69da48d247a0126e91a	5	2	gsDu9aPmZy7uH5FzmfJKW7jWyXGHjSWbcb8k6UH743pYzaxWcWd	12884901889	10	10	1	-1	2015-05-10 17:36:43.351208	2015-05-10 17:36:43.351208	21474844672
e7ea3c40c43e2f0d49851e9930652e16f4461c934654ab23a76aff83886eba60	5	3	gsDu9aPmZy7uH5FzmfJKW7jWyXGHjSWbcb8k6UH743pYzaxWcWd	12884901890	10	10	1	-1	2015-05-10 17:36:43.360663	2015-05-10 17:36:43.360663	21474848768
69beaf62a65ac96ef4c8f0bb300ae949f99f3bfcc4ade707b7e8ed6fa79617cf	5	4	gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq	12884901890	10	10	1	-1	2015-05-10 17:36:43.371215	2015-05-10 17:36:43.371215	21474852864
5f79e48cf2fdf04076e9c8e59fe2e67564d447f38a2e0fda2df9326d2135191a	6	1	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ	12884901891	10	10	1	-1	2015-05-10 17:36:43.390544	2015-05-10 17:36:43.390544	25769807872
1b9649dde9f45ddc8dd0eeaf7656eb29799ebcdab7ef75c8ce5d213462af9513	7	1	gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	12884901890	10	10	1	-1	2015-05-10 17:36:43.411809	2015-05-10 17:36:43.411809	30064775168
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

