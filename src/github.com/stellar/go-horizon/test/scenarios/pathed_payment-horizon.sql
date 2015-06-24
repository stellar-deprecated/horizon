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
12884914176	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ
12884918272	gT9jHoPKoErFwXavCrDYLkSVcVd9oyVv94ydrq6FnPMXpKHPTA
12884922368	gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ
\.


--
-- Data for Name: history_ledgers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_ledgers (sequence, ledger_hash, previous_ledger_hash, transaction_count, operation_count, closed_at, created_at, updated_at, id) FROM stdin;
1	a9d12414d405652b752ce4425d3d94e7996a07a52228a58d7bf3bd35dd50eb46	\N	0	0	1970-01-01 00:00:00	2015-06-09 23:21:28.027319	2015-06-09 23:21:28.027319	4294967296
2	7ecf08b4d92223b9a258ad00c2926f4f110b263b370b780c8d8b581d6e40175c	a9d12414d405652b752ce4425d3d94e7996a07a52228a58d7bf3bd35dd50eb46	0	0	2015-06-09 23:21:25	2015-06-09 23:21:28.036702	2015-06-09 23:21:28.036702	8589934592
3	8e929170e0f55d86f537d96652701fc1649743e486db27f23bf9b19049136c0b	7ecf08b4d92223b9a258ad00c2926f4f110b263b370b780c8d8b581d6e40175c	0	0	2015-06-09 23:21:26	2015-06-09 23:21:28.046438	2015-06-09 23:21:28.046438	12884901888
4	b761e85c7797d1a5dd75f43926354c5094556af34cb8758ae70398bd130208bd	8e929170e0f55d86f537d96652701fc1649743e486db27f23bf9b19049136c0b	0	0	2015-06-09 23:21:27	2015-06-09 23:21:28.11662	2015-06-09 23:21:28.11662	17179869184
5	443d41db9c106e6689b8accaa1648ce9a9449638059d633ba0ef0721234a8ab5	b761e85c7797d1a5dd75f43926354c5094556af34cb8758ae70398bd130208bd	0	0	2015-06-09 23:21:28	2015-06-09 23:21:28.165952	2015-06-09 23:21:28.165952	21474836480
6	12736735d3fbcc7405cee4fd61acb3ba7d9b84724e2907dd960e37e3e17c8f89	443d41db9c106e6689b8accaa1648ce9a9449638059d633ba0ef0721234a8ab5	0	0	2015-06-09 23:21:29	2015-06-09 23:21:28.214591	2015-06-09 23:21:28.214591	25769803776
7	37394167a126b489ea095a412941a6f346c0e8c1749ed859ab61269f8deddefc	12736735d3fbcc7405cee4fd61acb3ba7d9b84724e2907dd960e37e3e17c8f89	0	0	2015-06-09 23:21:30	2015-06-09 23:21:28.230058	2015-06-09 23:21:28.230058	30064771072
\.


--
-- Data for Name: history_operation_participants; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_operation_participants (id, history_operation_id, history_account_id) FROM stdin;
79	12884905984	0
80	12884905984	12884905984
81	12884910080	0
82	12884910080	12884910080
83	12884914176	0
84	12884914176	12884914176
85	12884918272	0
86	12884918272	12884918272
87	12884922368	0
88	12884922368	12884922368
89	17179873280	12884922368
90	17179877376	12884914176
91	17179881472	12884918272
92	17179885568	12884914176
93	21474840576	12884905984
94	21474840576	12884922368
95	21474844672	12884910080
96	21474844672	12884914176
97	21474848768	12884905984
98	21474848768	12884914176
99	21474852864	12884910080
100	21474852864	12884918272
101	25769807872	12884914176
102	30064775168	12884918272
103	30064775168	12884922368
\.


--
-- Name: history_operation_participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('history_operation_participants_id_seq', 103, true);


--
-- Data for Name: history_operations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_operations (id, transaction_id, application_order, type, details) FROM stdin;
12884905984	12884905984	0	0	{"funder": "gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC", "account": "gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq", "starting_balance": 1000000000}
12884910080	12884910080	0	0	{"funder": "gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC", "account": "gsDu9aPmZy7uH5FzmfJKW7jWyXGHjSWbcb8k6UH743pYzaxWcWd", "starting_balance": 1000000000}
12884914176	12884914176	0	0	{"funder": "gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC", "account": "gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ", "starting_balance": 1000000000}
12884918272	12884918272	0	0	{"funder": "gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC", "account": "gT9jHoPKoErFwXavCrDYLkSVcVd9oyVv94ydrq6FnPMXpKHPTA", "starting_balance": 1000000000}
12884922368	12884922368	0	0	{"funder": "gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC", "account": "gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ", "starting_balance": 1000000000}
17179873280	17179873280	0	6	{"limit": 9223372036854775807, "trustee": "gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq", "trustor": "gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ", "currency_code": "USD", "currency_type": "alphanum", "currency_issuer": "gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq"}
17179877376	17179877376	0	6	{"limit": 9223372036854775807, "trustee": "gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq", "trustor": "gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ", "currency_code": "USD", "currency_type": "alphanum", "currency_issuer": "gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq"}
17179881472	17179881472	0	6	{"limit": 9223372036854775807, "trustee": "gsDu9aPmZy7uH5FzmfJKW7jWyXGHjSWbcb8k6UH743pYzaxWcWd", "trustor": "gT9jHoPKoErFwXavCrDYLkSVcVd9oyVv94ydrq6FnPMXpKHPTA", "currency_code": "EUR", "currency_type": "alphanum", "currency_issuer": "gsDu9aPmZy7uH5FzmfJKW7jWyXGHjSWbcb8k6UH743pYzaxWcWd"}
17179885568	17179885568	0	6	{"limit": 9223372036854775807, "trustee": "gsDu9aPmZy7uH5FzmfJKW7jWyXGHjSWbcb8k6UH743pYzaxWcWd", "trustor": "gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ", "currency_code": "EUR", "currency_type": "alphanum", "currency_issuer": "gsDu9aPmZy7uH5FzmfJKW7jWyXGHjSWbcb8k6UH743pYzaxWcWd"}
21474840576	21474840576	0	1	{"to": "gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ", "from": "gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq", "amount": 1000000000, "currency_code": "USD", "currency_type": "alphanum", "currency_issuer": "gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq"}
21474844672	21474844672	0	1	{"to": "gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ", "from": "gsDu9aPmZy7uH5FzmfJKW7jWyXGHjSWbcb8k6UH743pYzaxWcWd", "amount": 200000000, "currency_code": "EUR", "currency_type": "alphanum", "currency_issuer": "gsDu9aPmZy7uH5FzmfJKW7jWyXGHjSWbcb8k6UH743pYzaxWcWd"}
21474848768	21474848768	0	1	{"to": "gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ", "from": "gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq", "amount": 200000000, "currency_code": "USD", "currency_type": "alphanum", "currency_issuer": "gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq"}
21474852864	21474852864	0	1	{"to": "gT9jHoPKoErFwXavCrDYLkSVcVd9oyVv94ydrq6FnPMXpKHPTA", "from": "gsDu9aPmZy7uH5FzmfJKW7jWyXGHjSWbcb8k6UH743pYzaxWcWd", "amount": 1000000000, "currency_code": "EUR", "currency_type": "alphanum", "currency_issuer": "gsDu9aPmZy7uH5FzmfJKW7jWyXGHjSWbcb8k6UH743pYzaxWcWd"}
25769807872	25769807872	0	3	\N
30064775168	30064775168	0	2	{"to": "gT9jHoPKoErFwXavCrDYLkSVcVd9oyVv94ydrq6FnPMXpKHPTA", "from": "gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ", "amount": 10, "currency_code": "EUR", "currency_type": "alphanum", "currency_issuer": "gsDu9aPmZy7uH5FzmfJKW7jWyXGHjSWbcb8k6UH743pYzaxWcWd"}
\.


--
-- Data for Name: history_transaction_participants; Type: TABLE DATA; Schema: public; Owner: -
--

COPY history_transaction_participants (id, transaction_hash, account, created_at, updated_at) FROM stdin;
75	ab38509dc9e16c08b084d7f7279fd45f5f4d348ab3b2ed9877c697beaa7e4108	gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq	2015-06-09 23:21:28.052041	2015-06-09 23:21:28.052041
76	ab38509dc9e16c08b084d7f7279fd45f5f4d348ab3b2ed9877c697beaa7e4108	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2015-06-09 23:21:28.05323	2015-06-09 23:21:28.05323
77	88d85fff231b69afb52095b55f0e5d41a860036829bfdad02aa772f47d0ec5de	gsDu9aPmZy7uH5FzmfJKW7jWyXGHjSWbcb8k6UH743pYzaxWcWd	2015-06-09 23:21:28.065489	2015-06-09 23:21:28.065489
78	88d85fff231b69afb52095b55f0e5d41a860036829bfdad02aa772f47d0ec5de	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2015-06-09 23:21:28.066601	2015-06-09 23:21:28.066601
79	0971ddff00734a3b5741023c6200502e887419d57032c76cacb89d9d9860e54a	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ	2015-06-09 23:21:28.076616	2015-06-09 23:21:28.076616
80	0971ddff00734a3b5741023c6200502e887419d57032c76cacb89d9d9860e54a	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2015-06-09 23:21:28.077596	2015-06-09 23:21:28.077596
81	527a9354ca0029fa8d18da6a6772638501bccd143b743764135ce5bb3396c53b	gT9jHoPKoErFwXavCrDYLkSVcVd9oyVv94ydrq6FnPMXpKHPTA	2015-06-09 23:21:28.087763	2015-06-09 23:21:28.087763
82	527a9354ca0029fa8d18da6a6772638501bccd143b743764135ce5bb3396c53b	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2015-06-09 23:21:28.088708	2015-06-09 23:21:28.088708
83	928b1c9a45888f7fb5a55a5e28a63f20da17a9cb4054c0f8329b7405c5aea71b	gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	2015-06-09 23:21:28.100068	2015-06-09 23:21:28.100068
84	928b1c9a45888f7fb5a55a5e28a63f20da17a9cb4054c0f8329b7405c5aea71b	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2015-06-09 23:21:28.10103	2015-06-09 23:21:28.10103
85	1b92d9a9651b11379a62c13a21958d516cf3dfe15f3628981243f0b4475c02fa	gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	2015-06-09 23:21:28.120855	2015-06-09 23:21:28.120855
86	f44b155ce8e6a7db7dd6294166bb710a481f102514b3c73fcada10ff20dca37c	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ	2015-06-09 23:21:28.127882	2015-06-09 23:21:28.127882
87	3b8ea3d88d938d788d46819084d6faa9bbc7a5e2ec3283b2735ac77a008fd45c	gT9jHoPKoErFwXavCrDYLkSVcVd9oyVv94ydrq6FnPMXpKHPTA	2015-06-09 23:21:28.134761	2015-06-09 23:21:28.134761
88	f1da88fab880edf76f42a5dd0c8c9f4ea3d452f2b61371338f3308049bccdb5a	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ	2015-06-09 23:21:28.153001	2015-06-09 23:21:28.153001
89	dc94538a35e5b30387324ce287fc96946c1a010c4ae252dad5ed1c7bec88916f	gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq	2015-06-09 23:21:28.171045	2015-06-09 23:21:28.171045
90	f97bc27bb24e9a9441deb32ef52ac5e3df55e876f2d0f2be80b356e9177cb58b	gsDu9aPmZy7uH5FzmfJKW7jWyXGHjSWbcb8k6UH743pYzaxWcWd	2015-06-09 23:21:28.181202	2015-06-09 23:21:28.181202
91	49cfaf8425c1a3bf2db73da7c5bf95ebbc7ca422c1a65bc060f08529c5305cca	gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq	2015-06-09 23:21:28.190398	2015-06-09 23:21:28.190398
92	cb8eaeb1850b5058b33eb948b05b455a381de250c54671412225993a6f3fd2df	gsDu9aPmZy7uH5FzmfJKW7jWyXGHjSWbcb8k6UH743pYzaxWcWd	2015-06-09 23:21:28.201416	2015-06-09 23:21:28.201416
93	dffaa6b14246bb4cc3ab8ac414aec9cb93e86003cb22ff1297b3fe4623974d98	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ	2015-06-09 23:21:28.21893	2015-06-09 23:21:28.21893
94	be7a12b20365db042bb64eda66494bc8aeb69a70fbdca1ce38f3471dc2b7b5fe	gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	2015-06-09 23:21:28.234924	2015-06-09 23:21:28.234924
\.


--
-- Name: history_transaction_participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('history_transaction_participants_id_seq', 94, true);


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
ab38509dc9e16c08b084d7f7279fd45f5f4d348ab3b2ed9877c697beaa7e4108	3	1	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	1	10	10	1	-1	2015-06-09 23:21:28.050149	2015-06-09 23:21:28.050149	12884905984
88d85fff231b69afb52095b55f0e5d41a860036829bfdad02aa772f47d0ec5de	3	2	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	2	10	10	1	-1	2015-06-09 23:21:28.063666	2015-06-09 23:21:28.063666	12884910080
0971ddff00734a3b5741023c6200502e887419d57032c76cacb89d9d9860e54a	3	3	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	3	10	10	1	-1	2015-06-09 23:21:28.075118	2015-06-09 23:21:28.075118	12884914176
527a9354ca0029fa8d18da6a6772638501bccd143b743764135ce5bb3396c53b	3	4	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	4	10	10	1	-1	2015-06-09 23:21:28.086247	2015-06-09 23:21:28.086247	12884918272
928b1c9a45888f7fb5a55a5e28a63f20da17a9cb4054c0f8329b7405c5aea71b	3	5	gspbxqXqEUZkiCCEFFCN9Vu4FLucdjLLdLcsV6E82Qc1T7ehsTC	5	10	10	1	-1	2015-06-09 23:21:28.098266	2015-06-09 23:21:28.098266	12884922368
1b92d9a9651b11379a62c13a21958d516cf3dfe15f3628981243f0b4475c02fa	4	1	gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	12884901889	10	10	1	-1	2015-06-09 23:21:28.119397	2015-06-09 23:21:28.119397	17179873280
f44b155ce8e6a7db7dd6294166bb710a481f102514b3c73fcada10ff20dca37c	4	2	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ	12884901889	10	10	1	-1	2015-06-09 23:21:28.126516	2015-06-09 23:21:28.126516	17179877376
3b8ea3d88d938d788d46819084d6faa9bbc7a5e2ec3283b2735ac77a008fd45c	4	3	gT9jHoPKoErFwXavCrDYLkSVcVd9oyVv94ydrq6FnPMXpKHPTA	12884901889	10	10	1	-1	2015-06-09 23:21:28.133364	2015-06-09 23:21:28.133364	17179881472
f1da88fab880edf76f42a5dd0c8c9f4ea3d452f2b61371338f3308049bccdb5a	4	4	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ	12884901890	10	10	1	-1	2015-06-09 23:21:28.151267	2015-06-09 23:21:28.151267	17179885568
dc94538a35e5b30387324ce287fc96946c1a010c4ae252dad5ed1c7bec88916f	5	1	gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq	12884901889	10	10	1	-1	2015-06-09 23:21:28.169061	2015-06-09 23:21:28.169061	21474840576
f97bc27bb24e9a9441deb32ef52ac5e3df55e876f2d0f2be80b356e9177cb58b	5	2	gsDu9aPmZy7uH5FzmfJKW7jWyXGHjSWbcb8k6UH743pYzaxWcWd	12884901889	10	10	1	-1	2015-06-09 23:21:28.179314	2015-06-09 23:21:28.179314	21474844672
49cfaf8425c1a3bf2db73da7c5bf95ebbc7ca422c1a65bc060f08529c5305cca	5	3	gsPsm67nNK8HtwMedJZFki3jAEKgg1s4nRKrHREFqTzT6ErzBiq	12884901890	10	10	1	-1	2015-06-09 23:21:28.188943	2015-06-09 23:21:28.188943	21474848768
cb8eaeb1850b5058b33eb948b05b455a381de250c54671412225993a6f3fd2df	5	4	gsDu9aPmZy7uH5FzmfJKW7jWyXGHjSWbcb8k6UH743pYzaxWcWd	12884901890	10	10	1	-1	2015-06-09 23:21:28.199644	2015-06-09 23:21:28.199644	21474852864
dffaa6b14246bb4cc3ab8ac414aec9cb93e86003cb22ff1297b3fe4623974d98	6	1	gqdUHrgHUp8uMb74HiQvYztze2ffLhVXpPwj7gEZiJRa4jhCXQ	12884901891	10	10	1	-1	2015-06-09 23:21:28.217359	2015-06-09 23:21:28.217359	25769807872
be7a12b20365db042bb64eda66494bc8aeb69a70fbdca1ce38f3471dc2b7b5fe	7	1	gsKuurNYgtBhTSFfsCaWqNb3Ze5Je9csKTSLfjo8Ko2b1f66ayZ	12884901890	10	10	1	-1	2015-06-09 23:21:28.233099	2015-06-09 23:21:28.233099	30064775168
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

